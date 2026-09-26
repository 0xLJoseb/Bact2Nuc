***************26/09/2025***************
- Fixed dependency installation for DeepLocPro by pinning the PyTorch version to 2.5.1+cu124 and using a compatible setuptools version.
- Fixed DeepLocPro environment configuration and dependency handling.
- Fixed PSORTb execution in the main pipeline by preventing stdout redirection, which could cause the process to hang in certain environments.
- Updated the main pipeline to ensure PSORTb and DeepLocPro execute correctly using their dedicated environments.


***************20/08/2025***************
- Improved Ensembling:
    In previous versions, the combination of results between PSORTb and DeepLocPro was performed through a simple average of the scores when both tools agreed on the sa    me localization for a protein. Now, instead of averaging, the final score is calculated using relative weights derived from the F1-Score of each tool against a trai    ning proteome.

    (This feature is currently in Beta, but it provides a more robust strategy than a simple average. --> Implemented in "combinar.py")

- New file:
    Added generation of "records_tmp.csv".
    This file contains DeepLocPro predictions with score > 0.5.

- Combined file:
    Now "archivo_combinado.csv" is generated using the derived F1-scores weights, pondering both tools for each protein.

***************18/08/2025***************
- New site flag:
    Added support for the Cell wall category (Gram-positive only)

- Option added to prevent invalid runs: 
    When selecting the "Outer Membrane" or "Periplasmic" site for Gram-positive bacteria, the program will now stop execution and display an error message.
    When selecting the "Cell wall" site for Gram-negative bacteria, the program will now stop execution and display an error message.

- Modified 'bin/combinar.py' introducing a dynamic dictionary that adapts to the Gram type specified by the user. (improves normalization of locations between both tools)

***************09/08/2025***************
- Modified 'bin/combinar.py' to add sys.exit(1) when both input files are empty, preventing the pipeline from continuing.
- Updated 'main.sh' to stop execution if 'combinar.py' returns an error.

***************08/08/2025***************
- New site flag:
    Added support for the Cytoplasmic Membrane category.

- Category unification:
    The "Cell wall & surface" category from DeepLocPro is unified with "Outer Membrane" from PSORTb, making the predictions from both tools equivalent for this category

- Modification in bin/combinar.py:

    Normalized prediction labels:

        "CytoplasmicMembrane" → "Cytoplasmic Membrane"

        "Cell wall & surface" → "Outer Membrane"


***************26/05/2025***************
The following changes have been made to the overall project:

- The code is gradually being translated into English.
- A new '"Site"' flag has been added [Cytoplasmic]. This required some updates in "main.sh". A new annotated proteome was also added to help test and confirm that everything works as expected with this new '"Site"' flag.
- Some typos were fixed. 

***************12/03/2025***************

The following changes have been made to the overall project:

- Changes in 'main.sh': the default proteome is now '"extracellular.fasta"'.
- Updates to the test proteomes ('extracellular.fasta', 'periplasmic.fasta', and 'outer.fasta'): these files are now annotated with the expected results to verify that everything works correctly.
- Modifications in 'bin/combinar.py' for cases involving the "Outer Membrane" localization: since PSORTb and DeepLocPro use '"OuterMembrane"' and '"Outer Membrane"', respectively, for this localization, duplicate records were being generated in '"archivo_combinado.csv"'. This issue was fixed by adding a function that normalizes localization names to '"Outer Membrane"' in these cases.

***************11/03/2025***************

The following general changes have been made to the project:

- Changes in the 'main.sh' script: a new '"Site"' flag was added to allow selection of additional localization sites for prediction [Extracellular, Periplasmic, Outer Membrane]. This also required changes in various parts of the code to reference the selected localization site information.
- In 'combinar.py', adjustments were made to handle cases where one of the two prediction results (PSORTb | DeepLocPro) was empty.
- Various syntax adjustments were made throughout the code to support output folder names that include spaces. Additionally, the 'README.md' file was updated. 
