# Bact2Nuc
Automates the prediction of subcellular localization and NLS using PSORTb, Deeplocpro 1.0 and NLStradamus.
## Requirements
- **Dependencies:**
  - Docker (for PSORTb).
- **System requirements:**
  - Recommended disk space: approximately 6 GB
  - At least 8 GB of RAM recommended
  - Internet connection: Needed to download dependencies and Docker images.

## Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/0xLJoseb/Biosoft
   cd Biosoft
2. Run the dependencies script **dependencies.sh** 
   ```bash
   ./dependencies.sh
  
## Usage
```bash
BIOSOFT: Automates the prediction of subcellular localization and NLS using PSORTb, Deeplocpro and NLStradamus.
[*]Usage: ./main.sh [OPTIONS]

OPTIONS:
  --site SITE        Location to analyze. Default: Extracellular.
     [*] Extracellular
     [*] Periplasmic [Gram-negative only]
     [*] Outer Membrane [Gram-negative only]
     [*] Cytoplasmic
     [*] Cytoplasmic Membrane
     [*] Cell wall [Gram-positive only]
}
  --gram GRAM        Gram group of the organism (negative, positive, archaea). Default: negative.
  --proteome FILE    FASTA file with the input proteome. Default: proteoma.fasta.
  --output DIR       Output directory for results. Default: resultados/.
  --threads N        Number of threads for NLStradamus. Default: all available cores.
  --help             Shows this help message.

#Example:
  ./main.sh --proteome proteoma.fasta --output resultados --gram negative --site Extracellular
```

## Results
- psortb_results/: PSORTb predictions.
- deeploc_results/: Deeplocpro predictions.
- Comb/: Directory with a CSV containing both predictions.
- NLSPredicts/: Directory containing NLS results.

## Tools Used
This project uses the following bioinformatic tools:

- **PSORTb**  
  Tool for predicting the subcellular localization of proteins in bacteria. Available at: [brinkmanlab/psortb_commandline_docker](https://github.com/brinkmanlab/psortb_commandline_docker).  

- **DeepLoc**  
  Neural network-based tool for subcellular localization prediction. Available at: [Jaimomar99/deeplocpro](https://github.com/Jaimomar99/deeplocpro).  

- **NLStradamus**  
  Tool for predicting nuclear localization signals (NLS). Available at: [NLStradamus](http://www.moseslab.csb.utoronto.ca/NLStradamus/).  

[![PSORTb](https://img.shields.io/badge/PSORTb-GitHub-blue)](https://github.com/brinkmanlab/psortb_commandline_docker)
[![DeepLoc](https://img.shields.io/badge/DeepLoc-GitHub-green)](https://github.com/Jaimomar99/deeplocpro)

## References
- **PSORTb**

  PSORTb v3.0: N.Y. Yu, J.R. Wagner, M.R. Laird, G. Melli, S. Rey, R. Lo, P. Dao, S.C. Sahinalp, M. Ester, L.J. Foster, F.S.L. Brinkman (2010) PSORTb 3.0: Improved protein subcellular localization prediction with refined localization subcategories and predictive capabilities for all prokaryotes, Bioinformatics 26(13):1608-1615
- **DeepLocPro**

  Jaime Moreno, Henrik Nielsen, Ole Winther, Felix Teufel (2024). Predicting the subcellular location of prokaryotic proteins with DeepLocPro. Bioinformatics. 10.1093/bioinformatics/btae677
- **NLStradamus**  

  Nguyen Ba, A. N., Pogoutse, A., Provart, N., & Moses, A. M. (2009). NLStradamus: a simple Hidden Markov Model for nuclear localization signal prediction. *BMC Bioinformatics*, *10*(1), 202. https://doi.org/10.1186/1471-2105-10-202  
