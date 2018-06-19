# Description
Rails Environment Setup for Debian 9 and Ubuntu 16.04/18.04.

This script will:
- Install GUI (XFCE), VNC Server and Sublime Text (not enabled by default)
- Disable root ssh access
- Disable ssh password authentication
- Install RVM, Rails, PostgreSQL

This script is under development and not ready for production use. Use at your own risk!

# Install
Update system packages repository and install sudo, curl

```Shell
apt-get update
apt-get -y install curl sudo wget git
```
Clone the project

```Shell
git clone https://github.com/zldang/res.git
```
Change variables for your environment

```Shell
cd res
nano res.sh 
```
Add run permission

```Shell
chmod +x res.sh
```
Run

```Shell
./res.sh
```
