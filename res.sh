#!/bin/bash
# This script is for setting up Rails environment Debian/Ubuntu Server.

### SET VARIABLES

# Create user or use the current user?
# Rails/RVM should not be installed run under root user.
# If the computer only has root or you want to setup Rails under a new user,
# set this var to true.
v_create_user=true

# Disable password login? If true, password login via SSH will be disabled.
# Option: true/false
v_disable_ssh_password=false

# Create ~/.ssh/authorized_keys . Option: true/false
v_create_ssh_key=true

# Disable root login through SSH? Option: true/false
# (Only when no $v_create_user == true)
v_disable_root_ssh_login=true

# Set public key, replace with your own from puttygen/ssh-keygen.
# You can leave blank f you already set keys during setup the droplet (Digital Ocean/Vultr), or your $v_disable_ssh_password == false
# For Linode/normal user: Define this or you need to specify your own in ~/.ssh/authorized_keys
# BE CAREFUL: If $v_disable_ssh_password == true, $v_public_key == '', you do not setup your droplet with any keys \
# and you don't define your public key in ~/.ssh/authorized_keys, you WILL be blocked from SSH Login.
v_public_key=''

# Swap block size? 512 => 512MB swap, 1024 => 1GB swap.
v_swap_bs=512

# Do you install XFCE GUI?. Option: true/false
v_install_gui=false

# Install TigerVNC Server? Option true/false
v_install_vncserver=false

# Install Sublime Text? Option true/false
v_install_sublimetext=false

# Access VNC from localhost only (only if $v_install_vncserver== true). Option: true/false
v_vnc_localhost=true

# Install ruby environment manager? Option: true/false
v_install_ruby_manager=true

# Ruby environment manager option? Option: "rvm"/"rbenv"
v_ruby_manager="rbenv"

# Install first/global ruby? Option: true/false
v_install_ruby=true

# If v_install_ruby == true, ruby version?
v_ruby_version="2.5.1"

# Install PostgreSQL server? Option: true/false
v_install_postgresql=false

# Install MySQL/MariaDB server? Option: true/false
v_install_mdb=true

# MySQL server option? Option: "mariadb"/"mysql".
# If the option is not available, the other will be selected.
v_mdb_edition="mariadb"

# Install nginx as reverse proxy? Option: true/false
v_install_nginx_srv=true

# Install Firewall? Option: true/false
v_install_firewall=true

# Firewall option? Option: "ufw"/"firewalld"
v_firewall="ufw"

# Ports for opening.
v_portslist=(22 80 443 3000)

### END OF SETTING VARIABLES SECTION

distro="$(lsb_release -i -s)"
distro="${distro,,}"
distro_code="$(lsb_release -c -s)"

source inc/functions.sh
source inc/install.sh


