#!/bin/bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
DIR=/etc/OpenCL/vendors
FILES=$SCRIPT_DIR/trm
SETTINGS=$SCRIPT_DIR/settings

package="screen"

# Install dependencies
for packageName in $package; do
  dpkg -l | grep -qw $packageName || sudo apt install -y $packageName
done

# Install drivers separately
if [ -d "$DIR" ]; then
    echo "Drivers already installed"
else
    TEMP_DEB="$(mktemp)" &&
    wget -O "$TEMP_DEB" 'https://repo.radeon.com/amdgpu-install/latest/ubuntu/focal/' &&
    sudo dpkg -i "$TEMP_DEB" || { echo "Failed to install drivers"; exit 1; }
    rm -f "$TEMP_DEB"

    sudo amdgpu-install -y --usecase=opencl --opencl=rocr --accept-eula || { echo "Failed to install OpenCL"; exit 1; }
fi

# Extract TeamRedMiner
if [ -d "$FILES" ]; then
    echo "TeamRedMiner already installed"
else
    sudo mkdir $SCRIPT_DIR/trm
    sudo tar -xvzf teamredminer*.tgz -C $FILES || { echo "Failed to extract TeamRedMiner"; exit 1; }
fi

# Copy config file
sudo cp $SETTINGS/amdeth.sh $FILES/teamredminer*/ || { echo "Failed to copy config file"; exit 1; }
sudo chmod +x $FILES/teamredminer*/amdeth.sh

# Start miner
echo "Starting miner, run screen -r to attach"
screen -S miner -dm bash -c '$FILES/teamredminer*/amdeth.sh' || { echo "Failed to start miner"; exit 1; }
