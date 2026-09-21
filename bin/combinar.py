#!/usr/bin/python3
import pandas as pd
import os
import re
import argparse #Para automatizar la entrada
import sys

#Seccion de pesos (Derivados del F1_score) | Updated --> 20/09/2026
DPLGRAMNEG_weights = {
    "Cytoplasmic" : 0.530876833845104,
    "Cytoplasmic Membrane" : 0.506035889070147,
    "Periplasmic" : 0.524603403518892,
    "Outer Membrane" : 0.544897036989220,
    "Extracellular" : 0.544909439327440
}

DPLGRAMPOS_weights = {
    "Cell wall" : 0.491474997139261,
    "Cytoplasmic" : 0.533730875798097,
    "Cytoplasmic Membrane" : 0.531310122261528,
    "Extracellular" : 0.557971963841216
}

PSTBGRAMNEG_weights = {
    "Cytoplasmic" : 0.469123166154896,
    "Cytoplasmic Membrane" : 0.493964110929853,
    "Periplasmic" : 0.475396596481108,
    "Outer Membrane" : 0.455102963010780,
    "Extracellular" : 0.455090560672560
}

PSTBGRAMPOS_weights = {
    "Cell wall" : 0.508525002860739,
    "Cytoplasmic" : 0.466269124201903,
    "Cytoplasmic Membrane" : 0.468689877738472,
    "Extracellular" : 0.442028036158784
}

# Para que se vea ordenado de menor a mayor
def ext_numero(acc_num):
    numeros = re.findall(r'\d+', acc_num) # Busca ultima secuencia de digitos en la cadena
    return int(numeros[-1]) if numeros else float('inf') # Si no hay mas numeros retorna infinito

def build_replacements(gram: str): #Diccionario cuya estructura va a cambiar segun el gram
    base = {
        "OuterMembrane" : "Outer Membrane",
        "CytoplasmicMembrane" : "Cytoplasmic Membrane",
    }
    if gram == "positive": #Unificamos psort y deeploc para cell wall en gram pos
        base.update({
            "Cellwall" : "Cell wall",
            "Cell wall & surface" : "Cell wall",
        })
    elif gram == "negative": # "Cell wall & surface" se traslada a "Outer Membrane" en gram neg
        base.update({
            "Cell wall & surface" : "Outer Membrane",
        })
    else:
        pass #solo base 
    return base 

def norm_loc(localization: str, replacements: dict):
    return replacements.get(localization, localization) #Convertimos cada palabra en su respectivo reemplazo

def weight(tool, loc): # 0.5 se refiere a un valor default en caso de que las localizaciones de las proteinas no pertenezcan a ninguna loc de los dicts
    if tool == "PSORTb":
        return W_PSTB.get(loc, 0.5)
    else:
        return W_DPL.get(loc, 0.5)

# Configurando agumentos de entrada
parser = argparse.ArgumentParser(description='Combina resultados de PSORTb y Deeplocpro')
parser.add_argument('--psortb', required=True, help='Ruta al archivo CSV de PSORTb')
parser.add_argument('--deeploc', required=True, help='Ruta al archivo CSV de Deeplocpro')
parser.add_argument('--output', required=True, help='Ruta de salida para el archivo CSV combinado')
parser.add_argument('--gram', required=True, choices=['positive', 'negative', 'archaea'], help='Gram escogido para la ejecucion del analisis')
args = parser.parse_args()

 #Flujo
if args.gram == "negative":
    W_DPL = DPLGRAMNEG_weights
    W_PSTB = PSTBGRAMNEG_weights
elif args.gram == "positive":
    W_DPL = DPLGRAMPOS_weights
    W_PSTB = PSTBGRAMPOS_weights
else: # Archaea ? 
    W_DPL = {}
    W_PSTB = {}

ruta_arc1 = args.psortb
ruta_arc2 = args.deeploc

# Cargar CSVs
archivo1 = pd.read_csv(ruta_arc1, header=None, names=["Accession number", "Localization", "Score"])
archivo2 = pd.read_csv(ruta_arc2, header=None, names=["Accession number", "Localization", "Score"])

archivo1["Tool"] = "PSORTb"
archivo2["Tool"] = "DeepLocPro"

# Normalizacion loc. 
replacements = build_replacements(args.gram)
archivo1["Localization"] = archivo1["Localization"].apply(lambda x: norm_loc(str(x), replacements))
archivo2["Localization"] = archivo2["Localization"].apply(lambda x: norm_loc(str(x), replacements))


# Verif empty & Concat
if archivo1.empty and archivo2.empty:
    print("Ambos archivos están vacíos. No hay datos para combinar.")
    sys.exit(1)
elif archivo1.empty:
    print("El archivo de PSORTb está vacío. Usando solo el archivo de Deeploc.")
    combinado = archivo2
elif archivo2.empty:
    print("El archivo de Deeploc está vacío. Usando solo el archivo de PSORTb.")
    combinado = archivo1
else:
    # Concatenar si ambos archivos tienen datos
    combinado = pd.concat([archivo1, archivo2], ignore_index=True)


agg = (combinado.groupby(["Accession number", "Localization", "Tool"], as_index=False)["Score"].max()) #Aggregated dataframe con el puntaje mas alto de Loc por tool
# Peso por fila
agg["W"] = agg.apply(lambda r: weight(r["Tool"], r["Localization"]), axis=1) #Basicamente colocamos en la col "W" el peso por herramienta definido por GRAM

agg["Weighted"] =  agg["Score"].astype(float) * agg["W"] #Multiplicamos score por peso

# Score_num es la suma de todos los "Score * W". Por otro lado, Score_denom es la suma de todos los "W"
agg_tmp = (agg.groupby(["Accession number", "Localization"], as_index=False).agg(Score_num=("Weighted", "sum"), Score_denom=("W", "sum")))

agg_tmp = agg_tmp[agg_tmp["Score_denom"] > 0] #Divisiones por cero? -> Pero no deberia pasar

agg_tmp["Score"] = (agg_tmp["Score_num"] / agg_tmp["Score_denom"]).astype(float)

resultado = agg_tmp[["Accession number", "Localization", "Score"]]

#Nos quedamos con la fila con valor maximo en el score
idx = resultado.groupby("Accession number")["Score"].idxmax()

resultado = resultado.loc[idx].copy()

resultado["Score"] = resultado["Score"].round(4) #Resultados con 4 decimales
resultado["Accession number numeric"] = resultado["Accession number"].apply(ext_numero) # Aplicamos la funcion
resultado = resultado.sort_values(by="Accession number numeric", ascending=True) # Organizamos por AC numerico

resultado = resultado.drop(columns=["Accession number numeric"]) # Dropeamos la columna AC numeric

resultado.to_csv(args.output, index=False) #Convertimos el DF resultado en un CSV y sin indice.

print(f"El archivo combinado se ha guardado en: {args.output}")

