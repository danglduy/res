#!/bin/bash
#This script is for setting up Debian/Ubuntu Server.

### SET VARIABLES

#Create user or use the current user? Rails/RVM should not be installed run under root user.
#If the computer only has root or you want to setup Rails under a new user, set this var to true.
v_create_user=false

#Disable password login? If true, password login via SSH will be disabled. Option: true/false
v_disable_ssh_password=true

#Create ~/.ssh/authorized_keys . Option: true/false
v_create_ssh_key=true

#Disable root login through SSH? Option: true/false
v_disable_root_ssh_login=true

#Set public key, replace with your own from puttygen/ssh-keygen.
#You can leave blank f you already set keys during setup the droplet (Digital Ocean/Vultr), or your $passwordlogin == false
#For Linode/normal user: Define this or you need to specify your own in ~/.ssh/authorized_keys
#BE CAREFUL: If $passwordlogin == false, $publickey == '', you don't setup your droplet with any keys \
# and you don't define your public key in ~/.ssh/authorized_keys, you WILL be blocked from SSH Login.
v_public_key=''

#Swap block size? 512 => 512MB swap, 1024 => 1GB swap.
v_swap_bs=512

#Do you use GUI? If yes we install GUI tools: XFCE, VNC, Sublime Text. Option: true/false
v_install_gui=false

#Access VNC from localhost only (only if $guiinstall == true). Option: true/false
v_vnc_localhost=true

#Install Rails with Postgres? Option: true/false
v_install_rails=true

#Install nginx as reverse proxy? Option: true/false
v_install_nginx_srv=false

#Install Firewall? Option: true/false
v_install_firewall=true

#Firewall option? Option: "ufw"/"firewalld"
v_firewall="ufw"

#Ports for opening. Default 22. Add your ports. By default if install http server we open 80 and 443 port.
v_portslist=(22)

### END OF SETTING VARIABLES SECTION

distro="$(lsb_release -i -s)"
distro_code="$(lsb_release -c -s)"

source <(curl -s https://raw.githubusercontent.com/zldang/res/master/inc/functions.sh)
source <(curl -s https://raw.githubusercontent.com/zldang/res/master/inc/install.sh)


