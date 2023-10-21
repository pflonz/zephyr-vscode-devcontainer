#!/bin/bash

# Trigger udev rules on container start
echo "#=============================================================================="
echo "Trigger udev rules"
echo "#=============================================================================="
sudo service udev restart
sudo udevadm control --reload-rules && sudo udevadm trigger