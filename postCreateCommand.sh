#!/bin/bash

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
sudo mkdir -p /etc/apt/keyrings
echo $NODE_JS_MAJOR
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_"$NODE_JS_MAJOR".x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
sudo apt-get update
sudo apt-get install nodejs -y

echo "#=============================================================================="
echo "Install Python dependencies"
echo "#=============================================================================="
pip3 install --user cmake_format invoke robotframework

cd /opt/toolchains

# Download and extract openocd-esp32
echo "#=============================================================================="
echo "Download and extract openocd-esp32"
echo "#=============================================================================="
sudo wget -O openocd-esp32.tar.gz https://github.com/espressif/openocd-esp32/releases/download/v0.12.0-esp32-20230419/openocd-esp32-linux-amd64-0.12.0-esp32-20230419.tar.gz
sudo tar -xzf openocd-esp32.tar.gz
sudo rm openocd-esp32.tar.gz

cd /workdir

# Download and extract nrf command line tools
echo "#=============================================================================="
echo "Download and extract JLink and nrf command line tools"
echo "#=============================================================================="
NRF_CLI_URL=https://nsscprodmedia.blob.core.windows.net/prod/software-and-other-downloads/desktop-software/nrf-command-line-tools/sw/versions-"$NRF_CLI_MAJOR"-x-x/"$NRF_CLI_MAJOR"-"$NRF_CLI_MINOR"-"$NRF_CLI_PATCH"/nrf-command-line-tools_"$NRF_CLI_MAJOR"."$NRF_CLI_MINOR"."$NRF_CLI_PATCH"_amd64.deb
sudo curl -o nrf-command-line-tools.deb -O $NRF_CLI_URL
sudo dpkg -i --force-overwrite nrf-command-line-tools.deb
sudo rm nrf-command-line-tools.deb
JLINK_PATH=$(ls /opt/nrf-command-line-tools/share/JLink_Linux*)
sudo apt install -y $JLINK_PATH --fix-broken

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
sudo cp 60-openocd.rules /etc/udev/rules.d
sudo rm 60-openocd.rules

# Trigger udev rules
echo "#=============================================================================="
echo "Trigger udev rules"
echo "#=============================================================================="
sudo service udev restart
sudo udevadm control --reload-rules && sudo udevadm trigger

# Setup Zephyr build environment
echo "#=============================================================================="
echo "Setup Zephyr build environment"
echo "#=============================================================================="
west update --narrow -o=--depth=1
west zephyr-export
