# Notes on installing BittWorks II Toolkit on Ubuntu 20.04 LTS

```bash
# Load the repo to apt package manager
$ sudo apt-add-repository ppa:ondrej/php

# Update and upgrade
$ sudo apt update
$ sudo apt upgrade

# Install build-essential and php7.2
$ sudo apt install build-essential php7.2-dev

# Install the BittWorks II Toolkit from deb file
$ sudo dpkg -i bw2tk-2020.1.u18.04.amd64.deb

# Load the setup script
$ source /etc/profile.d/bwtk.sh 

# Check if Environment is setup
$ echo $BWTK

# Open the BittWorks II Toolkit GUI
$ bwconfig-gui
```