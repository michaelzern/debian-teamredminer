# Auto setup for TeamRedMiner and OpenCL ROCr drivers tested on Ubuntu 20.04

This script automates the setup process for TeamRedMiner and OpenCL ROCr drivers on Ubuntu 20.04. The miner is configured to work with NiceHash by default, but you can easily change the pool settings.

## Prerequisites

- Ubuntu 20.04
- AMD GPU(s) compatible with TeamRedMiner

## Download TeamRedMiner

Download the latest version of TeamRedMiner from the official GitHub repository's releases page:

[https://github.com/todxx/teamredminer/releases](https://github.com/todxx/teamredminer/releases)

Place the downloaded `teamredminer-*.tgz` file in the same directory as the setup script.

## Configure the miner

Edit the `settings/amdeth.sh` file to configure the miner with your preferred pool and worker settings.

## Running the script

Execute the setup script:

```bash
./nhAMD.sh
```

# Verify miner working
To verify the miner is working, use the following commands:
```
# List all active screen sessions
screen -ls

# Return to the running screen session (if only one session is active)
screen -r

# If multiple sessions are active, use the session ID from the `screen -ls` output
screen -r session_id
```

Detach from the screen session by pressing Ctrl+A followed by Ctrl+D

# Troubleshooting

If you encounter any issues, ensure that your system meets the prerequisites and that you have downloaded the correct version of TeamRedMiner for your GPU(s). Consult the [TeamRedMiner GitHub repository](https://github.com/todxx/teamredminer) for additional documentation and support.