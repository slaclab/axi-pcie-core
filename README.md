# axi-pcie-core

# Before you clone the GIT repository

1) Create a github account:
> https://github.com/

2) On the Linux machine that you will clone the github from, generate a SSH key (if not already done)
> https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/

3) Add a new SSH key to your GitHub account
> https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/

4) Setup for large filesystems on github
``` $ git lfs install```

# Clone the GIT repository
``` $ git clone --recursive git@github.com:slaclab/axi-pcie-core```

# How to build the Linux Driver Software

1) Clone the aes-stream-driver GIT repository
```
$ git clone --recursive git@github.com:slaclab/aes-stream-drivers
```

2) Go to the data_dev driver directory and build the driver:
```
$ aes-stream-drivers/data_dev/driver/
$ make
```

3) Add the new driver
```
$ sudo /sbin/insmod ./datadev.ko || exit 1
```
