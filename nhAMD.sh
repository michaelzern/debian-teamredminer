#!/bin/bash

set -e

function prompt_settings() {
    read -p "Enter your username (default: 3Ls6aHvZvxMFGdt729grtst5AahrVntGxv): " USERNAME
    read -p "Enter your password (default: x): " PASSWORD
    read -p "Enter your pool (default: stratum+ssl://stratum.usa-east.nicehash.com:33353): " POOL
    read -p "Enter your algorithm (default: kawpow): " ALGO

    USERNAME=${USERNAME:-3Ls6aHvZvxMFGdt729grtst5AahrVntGxv}
    PASSWORD=${PASSWORD:-x}
    POOL=${POOL:-stratum+ssl://stratum.usa-east.nicehash.com:33353}
    ALGO=${ALGO:-kawpow}

    local SETTINGS="$SCRIPT_DIR/settings"
    local AMD_ETH_SH="$SETTINGS/settings.sh"

    cp "$AMD_ETH_SH" "$AMD_ETH_SH.bak"
    sed -i "s|USERNAME=.*|USERNAME=\"$USERNAME\"|" "$AMD_ETH_SH"
    sed -i "s|PASS=.*|PASS=\"$PASSWORD\"|" "$AMD_ETH_SH"
    sed -i "s|POOL=.*|POOL=\"$POOL\"|" "$AMD_ETH_SH"
    sed -i "s|ALGO=.*|ALGO=\"$ALGO\"|" "$AMD_ETH_SH"
}

function usage() {
    echo "Usage: $0 [-c CONFIG_FILE] [-h]"
    echo
    echo "Options:"
    echo "  -c CONFIG_FILE    Specify a custom configuration file for the mining software"
    echo "  -h                Display help information"
}

function check_dependencies() {
    local dependencies=("wget" "tar" "screen" "dpkg")
    for dep in "${dependencies[@]}"; do
        command -v "$dep" >/dev/null 2>&1 || { echo >&2 "The required command '$dep' is not installed. Please install it and try again."; exit 1; }
    done
}

function detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [[ "$ID_LIKE" == *"debian"* ]]; then
            echo "debian"
        else
            echo "$ID"
        fi
    else
        echo "unknown"
    fi
}

function install_dependencies() {
    local package="screen"
    for packageName in $package; do
        dpkg -l | grep -qw $packageName || sudo apt-get install -y $packageName
    done
}

function install_drivers() {
    local DIR=/etc/OpenCL/vendors
    if [ -d "$DIR" ]; then
        echo "Drivers already installed"
    else
        local TEMP_DEB="$(mktemp)"
        wget -O "$TEMP_DEB" 'https://repo.radeon.com/amdgpu-install/latest/ubuntu/focal/'
        sudo dpkg -i "$TEMP_DEB"
        rm -f "$TEMP_DEB"
        sudo amdgpu-install -y --usecase=opencl --opencl=rocr --accept-eula
    fi
}

function install_miner() {
    local FILES="$SCRIPT_DIR/trm"
    if [ -d "$FILES" ]; then
        echo "TeamRedMiner already installed"
    else
        sudo mkdir "$SCRIPT_DIR/trm"
        sudo tar -xvzf teamredminer*.tgz -C "$FILES"
    fi
}

function copy_config() {
    local SETTINGS="$SCRIPT_DIR/settings"
    local CONFIG_FILE="${1:-$SETTINGS/settings.sh}"
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Custom configuration file not found: $CONFIG_FILE"
        exit 1
    fi
    sudo cp "$CONFIG_FILE" "$FILES/teamredminer*/"
    sudo chmod +x "$FILES/teamredminer*/settings.sh"
}

function start_miner() {
    echo "Starting miner, run screen -r to attach"
    screen -S miner -dm bash -c '"$FILES/teamredminer*/settings.sh"'
}

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

check_dependencies

distro=$(detect_distro)
if [ "$distro" != "debian" ]; then
    echo "This script currently supports Debian-based distributions only."
    exit 1
fi

CUSTOM_CONFIG=""
while getopts ":c:h" opt; do
    case $opt in
        c)
            CUSTOM_CONFIG="$OPTARG"
            ;;
        h)
            usage
            exit 0
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            usage
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            usage
            exit 1
            ;;
    esac
done

install_dependencies
install_drivers
install_miner
prompt_settings
copy_config "$CUSTOM_CONFIG"
start_miner
