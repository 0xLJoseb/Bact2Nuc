#!/bin/bash

# Bact2Nuc - Dependency installer
#
# Installs the dependencies required to run Bact2Nuc:
#   - Python virtual environment for Bact2Nuc scripts
#    	-Biopython / pandas
#   - DeepLocPro in an isolated virtual environment
#   - Docker
#   - PSORTb
#   - Perl 
#   - NLStradamus

set -e

echo " [!] Bact2Nuc - Dependency installation"
echo


# Helper functions

install_system_package() {
    PACKAGE="$1"

    if command -v apt-get &>/dev/null; then
        sudo apt-get update
        sudo apt-get install -y "$PACKAGE"

    elif command -v pacman &>/dev/null; then
        sudo pacman -Sy --noconfirm "$PACKAGE"

    elif command -v dnf &>/dev/null; then
        sudo dnf install -y "$PACKAGE"

    else
        echo "[X] Unsupported package manager."
        echo "    Please install '$PACKAGE' manually."
        exit 1
    fi
}


# 1. System dependencies

echo "[1/6] Installing system dependencies..."

# Required commands used by the installer and pipeline:
#   python3, git, wget, tar, perl, docker

for COMMAND in python3 git wget tar; do
    if ! command -v "$COMMAND" &>/dev/null; then
        echo "[+] $COMMAND not found. Installing..."

        if command -v apt-get &>/dev/null; then
            sudo apt-get update
            sudo apt-get install -y "$COMMAND"

        elif command -v pacman &>/dev/null; then
            sudo pacman -Sy --noconfirm "$COMMAND"

        elif command -v dnf &>/dev/null; then
            sudo dnf install -y "$COMMAND"

        else
            echo "[X] Could not install $COMMAND automatically."
            exit 1
        fi
    else
        echo "[+] $COMMAND already installed."
    fi
done

# Python virtual environments
if ! python3 -m venv --help &>/dev/null; then
    echo "[+] Python venv support not found. Installing..."

    if command -v apt-get &>/dev/null; then
        sudo apt-get update
        sudo apt-get install -y python3-venv

    elif command -v pacman &>/dev/null; then
        sudo pacman -Sy --noconfirm python

    elif command -v dnf &>/dev/null; then
        sudo dnf install -y python3
    fi
fi

echo "[+] System dependencies ready."
echo


# 2. Python environment for Bact2Nuc

echo "[2/6] Creating Bact2Nuc Python environment..."

Bact_ENV="venv_bact2nuc"

if [ ! -d "$Bact_ENV" ]; then
    python3 -m venv "$Bact_ENV"
else
    echo "[+] $Bact_ENV already exists."
fi

echo "[+] Installing Python dependencies..."

"$Bact_ENV/bin/python" -m pip install --upgrade pip

# Dependencies currently used by bin/ Python scripts.
"$Bact_ENV/bin/python" -m pip install \
    biopython \
    pandas

echo "[+] Bact2Nuc Python environment ready."
echo


# 3. DeepLocPro

echo "[3/6] Installing DeepLocPro..."

DEEploc_ENV="venv_deeploc"
DEEploc_REPO="deeplocpro"

if [ ! -d "$DEEploc_ENV" ]; then
    python3 -m venv "$DEEploc_ENV"
else
    echo "[+] $DEEploc_ENV already exists."
fi

echo "[+] Installing DeepLocPro dependencies..."

"$DEEploc_ENV/bin/python" -m pip install --upgrade pip

# DeepLocPro imports pkg_resources.
# pkg_resources was removed from setuptools >= 82.
"$DEEploc_ENV/bin/python" -m pip install "setuptools<82"

if [ ! -d "$DEEploc_REPO" ]; then
    git clone https://github.com/Jaimomar99/deeplocpro
else
    echo "[+] DeepLocPro repository already exists."
fi

echo "[+] Installing DeepLocPro..."

"$DEEploc_ENV/bin/python" -m pip install "./$DEEploc_REPO"

echo "[+] DeepLocPro installed."
echo


# 4. Docker + PSORTb

echo "[4/6] Installing Docker and PSORTb..."

if ! command -v docker &>/dev/null; then

    echo "[+] Docker not found. Installing..."

    if command -v apt-get &>/dev/null; then
        sudo apt-get update
        sudo apt-get install -y docker.io

    elif command -v pacman &>/dev/null; then
        sudo pacman -Sy --noconfirm docker

    elif command -v dnf &>/dev/null; then
        sudo dnf install -y docker

    else
        echo "[X] Could not install Docker automatically."
        echo "    Please install Docker manually."
        exit 1
    fi

else
    echo "[+] Docker already installed."
fi

# Start Docker if systemd is available.
if command -v systemctl &>/dev/null; then
    sudo systemctl enable --now docker
fi

# Download PSORTb Docker image.
echo "[+] Downloading PSORTb Docker image..."

sudo docker pull brinkmanlab/psortb_commandline:1.0.2

# Download PSORTb wrapper.
if [ ! -f "psortb" ]; then
    wget -O psortb \
        https://raw.githubusercontent.com/brinkmanlab/psortb_commandline_docker/master/psortb
    chmod +x psortb
else
    echo "[+] PSORTb wrapper already exists."
fi

echo "[+] PSORTb installed."
echo


# 5. Perl + NLStradamus

echo "[5/6] Installing NLStradamus..."

if ! command -v perl &>/dev/null; then
    echo "[+] Perl not found. Installing..."
    install_system_package perl
else
    echo "[+] Perl already installed."
fi

if [ ! -d "NLStradamus" ]; then

    echo "[+] Downloading NLStradamus..."

    wget -O NLStradamus.tar.gz \
        http://www.moseslab.csb.utoronto.ca/NLStradamus/NLStradamus/NLStradamus.1.8.tar.gz

    if [ ! -f "NLStradamus.tar.gz" ]; then
        echo "[X] Failed to download NLStradamus."
        exit 1
    fi

    tar -xzf NLStradamus.tar.gz

    mkdir NLStradamus

    mv CHANGELOG.txt \
       example* \
       NLStradamus.cpp \
       README.txt \
       mcm3.fasta \
       nlstradamus.pl \
       NLStradamus/

    rm NLStradamus.tar.gz

else
    echo "[+] NLStradamus already installed."
fi

echo "[+] NLStradamus installed."
echo


# 6. Verification

echo "[6/6] Verifying dependencies..."
echo

# Python environment
echo "[+] Checking Biopython..."
"$Bact_ENV/bin/python" -c \
    "from Bio import SeqIO; print('    Biopython OK')"

echo "[+] Checking pandas..."
"$Bact_ENV/bin/python" -c \
    "import pandas; print('    pandas OK')"

# DeepLocPro
echo "[+] Checking DeepLocPro..."
"$DEEploc_ENV/bin/python" -c \
    "import DeepLocPro; print('    DeepLocPro OK')"

echo "[+] Checking pkg_resources..."
"$DEEploc_ENV/bin/python" -c \
    "import pkg_resources; print('    pkg_resources OK')"

# Perl
echo "[+] Checking Perl..."
perl --version >/dev/null
echo "    Perl OK"

# Docker
echo "[+] Checking Docker..."
sudo docker --version

# PSORTb
if [ -x "psortb" ]; then
    echo "    PSORTb wrapper OK"
else
    echo "[X] PSORTb wrapper not found."
    exit 1
fi

# NLStradamus
if [ -d "NLStradamus" ]; then
    echo "    NLStradamus OK"
else
    echo "[X] NLStradamus directory not found."
    exit 1
fi

echo
echo "[+] Installation completed successfully!"
echo
echo "Python environment:"
echo "    $Bact_ENV"
echo
echo "DeepLocPro environment:"
echo "    $DEEploc_ENV"
echo
echo "PSORTb:"
echo "    ./psortb"
echo
echo "NLStradamus:"
echo "    ./NLStradamus"
echo
echo "Bact2Nuc dependencies are ready."


