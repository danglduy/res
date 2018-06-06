# Description
Rails Environment Setup for Debian 9 and Ubuntu 16.04/18.04.

This script will:
- Install GUI (XFCE), VNC Server and Sublime Text (not enabled by default)
- Disable root ssh access
- Disable ssh password authentication
- Install RVM, Rails, PostgreSQL

This script is under development and not ready for production use. Use at your own risk!

# Install
```Shell
#Update system packages repository and install curl
sudo apt-get update
sudo apt-get install curl

#Get the script
wget https://raw.githubusercontent.com/zldang/les/master/res.sh

#Change variables for your environment
nano res.sh 

#Add run permission
chmod +x res.sh

#Run
./res.sh
```
