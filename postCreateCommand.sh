#!/bin/bash

echo "#=============================================================================="
echo "Activate Python virtual environment"
echo "#=============================================================================="
source /opt/python/venv/bin/activate
echo "Done..."

cd /workdir

echo "#=============================================================================="
echo "Add user binary packages to PATH"
echo "#=============================================================================="
echo "export PATH=$PATH:/home/user/.local/bin" >> /home/user/.bashrc
echo "Done..."



echo "#=============================================================================="
echo "Install APT dependencies"
echo "#=============================================================================="
sudo apt-get update
sudo apt-get install --no-install-recommends -y udev ca-certificates curl gnupg plantuml graphviz

echo "#=============================================================================="
echo "Add Node.js repositories and install"
echo "#=============================================================================="
# Configure Node.js PPA using LTS version 20.x
echo $NODE_JS_MAJOR
echo "https://deb.nodesource.com/setup_$NODE_JS_MAJOR.x"
curl -fsSL https://deb.nodesource.com/setup_$NODE_JS_MAJOR.x | sudo bash - 
sudo apt-get update
sudo apt-get install nodejs -y

echo "#=============================================================================="
echo "Install Python dependencies"
echo "#=============================================================================="
pip3 install cmake_format invoke robotframework

cd /opt/toolchains

cd /workdir

# Clean up stale packages
echo "#=============================================================================="
echo "Clean up APT stale packages"
echo "#=============================================================================="
sudo apt-get clean -y
sudo apt-get autoremove --purge -y
sudo rm -rf /var/lib/apt/lists/*

# Copy udev rules for OpenOCD to work
echo "#=============================================================================="
echo "Copy udev rules for OpenOCD to work"
echo "#=============================================================================="
wget -O 60-openocd.rules https://sf.net/p/openocd/code/ci/master/tree/contrib/60-openocd.rules?format=raw
sudo mkdir -p /etc/udev/rules.d
sudo cp 60-openocd.rules /etc/udev/rules.d
sudo rm 60-openocd.rules

# Setup Zephyr build environment
echo "#=============================================================================="
echo "Setup Zephyr build environment"
echo "#=============================================================================="
west update --narrow -o=--depth=1
west zephyr-export
