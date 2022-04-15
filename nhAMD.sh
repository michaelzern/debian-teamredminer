#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
DIR=/etc/OpenCL/vendors
FILES=$SCRIPT_DIR/trm
SETTINGS=$SCRIPT_DIR/settings

package="screen"

#install dependencies
for packageName in $package; do
  dpkg -l | grep -qw $packageName || sudo apt install -y $packageName
done

#install drivers seperately
if [ -d "$DIR" ]; then
    echo "Drivers already installed"
    else
    TEMP_DEB="$(mktemp)" &&
    wget -O "$TEMP_DEB" 'https://repo.radeon.com/amdgpu-install/latest/ubuntu/focal/' &&
    sudo dpkg -i "$TEMP_DEB"
    rm -f "$TEMP_DEB"

    sudo amdgpu-install -y --usecase=opencl --opencl=rocr --accept-eula
fi

# extract
if [ -d "$FILES" ]; then
    echo "TeamRedMiner already installed"
    else
      sudo mkdir $SCRIPT_DIR/trm
      sudo tar -xvzf teamredminer*.tgz -C $FILES
fi

#copy config file
sudo cp $SETTINGS/amdeth.sh $FILES/teamredminer*/
sudo chmod +x $FILES/teamredminer*/amdeth.sh

#start miner
echo "starting miner, run screen -r to attach"
screen -S miner -dm bash -c '$FILES/teamredminer*/amdeth.sh'
