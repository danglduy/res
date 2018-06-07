#!/bin/bash
function f_create_user() {
  # Create new user & prompt for password creation
  read -p "Your username: " user
  printf "\n"
  sudo adduser --gecos $user $user
  #Add user $user to sudo group
  sudo usermod -a -G sudo $user
}

function f_disable_root_ssh_login() {
  #Disable SSH Root Login
  sudo sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
}

function f_disable_ssh_password() {
  #Disable SSH Password Authentication
  sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
  sudo sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
}

function f_create_ssh_key() {
  v_root_ssh_keypath="/root/.ssh/authorized_keys"
  #Check root ssh key exist
  if [ sudo test -f "$v_root_ssh_keypath" ]; then
    #If exist copy the key to the user and delete the root's key folder
    sudo cp -R /root/.ssh /home/$user/.ssh
    sudo chown -R $user:$user /home/$user/.ssh
    sudo chmod 700 /home/$user/.ssh
    sudo chmod 600 /home/$user/.ssh/authorized_keys
    sudo rm -R /root/.ssh
  else
    sudo -u $user mkdir -p /home/$user/.ssh
    #If not exist create key file to the user
    sudo touch /home/$user/.ssh/authorized_keys
    echo "$v_public_key" | sudo tee --append /home/$user/.ssh/authorized_keys
    sudo chown -R $user:$user /home/$user/.ssh
    sudo chmod 700 /home/$user/.ssh
    sudo chmod 600 /home/$user/.ssh/authorized_keys
  fi
  sudo service sshd restart
}

function f_create_swap() {
  #Create swap disk image if the system doesn't have swap.
  checkswap="$(sudo swapon --show)"
  if [ -z "$checkswap" ]; then
    sudo mkdir -v /var/cache/swap
    sudo dd if=/dev/zero of=/var/cache/swap/swapfile bs=$v_swap_bs count=1M
    sudo chmod 600 /var/cache/swap/swapfile
    sudo mkswap /var/cache/swap/swapfile
    sudo swapon /var/cache/swap/swapfile
    echo "/var/cache/swap/swapfile none swap sw 0 0" | sudo tee -a /etc/fstab
  fi
}

function f_config_nano_erb() {
  #Nano config for erb
  sudo wget -P /usr/share/nano/ https://raw.githubusercontent.com/scopatz/nanorc/master/erb.nanorc
  sudo -u $user cat <<EOT >> /home/$user/.nanorc
  set tabsize 2
  set tabstospaces
  include "/usr/share/nano/erb.nanorc"
EOT
}

function f_disable_sudo_password_for_apt() {
  sudo touch /etc/sudoers.d/tmpsudo$user
  echo "$user ALL=(ALL) NOPASSWD: /usr/bin/sudo apt-get" | sudo tee --append etc/sudoers.d/tmpsudo$user
  sudo chmod 0440 /etc/sudoers.d/tmpsudo$user
}

function f_enable_sudo_password_for_apt() {
  sudo rm /etc/sudoers.d/tmpsudo$user
}

function f_install_sublimetext() {
  #Sublime Text
  wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
  echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
  sudo apt-get update
  sudo apt-get -y install sublime-text
}

function f_install_vncserver() {
  sudo apt-get -y install vnc4server
  #Create vncserver launch file
  sudo -u $user touch /home/$user/vncserver.sh
  sudo -u $user chmod +x /home/$user/vncserver.sh
  if [ $v_vnc_localhost == true ]; then
    sudo -u $user echo "vncserver -geometry 1280x650 -localhost" > /home/$user/vncserver.sh
  else
    sudo -u $user echo "vncserver -geometry 1280x650" > /home/$user/vncserver.sh
  fi
}

function f_install_gui() {
  sudo apt-get update
  sudo apt-get -y install xfce4 xfce4-goodies gnome-icon-theme
}

function f_install_essential_packages() {
  sudo apt-get -y update
  sudo apt-get -y install dirmngr whois apt-transport-https unzip
}

function f_install_nginx() {
  sudo apt-get -y install nginx-extras
}

function f_install_rails() {
  f_disable_sudo_password_for_apt
  #Install rvm, ruby and rails stable for $user user
  sudo -u $user gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
  sudo -u $user \curl -sSL https://get.rvm.io | sudo -u $user bash -s stable --rails
  f_enable_sudo_password_for_apt

  #NodeJS certificate & repo
  curl -sL https://deb.nodesource.com/setup_8.x | sudo bash -

  #Yarn certificate & repo
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

  sudo apt-get -y update
  sudo apt-get -y install nodejs yarn
  f_config_nano_erb
}

function f_install_postgresql() {
  #Postgresql certificate & repo
  wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
  sudo touch /etc/apt/sources.list.d/pgdg.list
  echo "deb http://apt.postgresql.org/pub/repos/apt/ $distro_code-pgdg main" | sudo tee --append /etc/apt/sources.list.d/pgdg.list
  sudo apt-get -y update
  sudo apt-get -y install postgresql-10 postgresql-client-10 libpq-dev
}

function f_install_firewall() {
  if [ $v_firewall == "ufw" ]; then
    sudo apt-get -y install ufw
    for i in "${v_portslist[@]}"
    do
      :
      echo "Added port $i to firewall ports open list"; sudo ufw allow $i/tcp &> /dev/null
      done
    sudo ufw reload
    sudo ufw --force enable
  fi

  if [ $v_firewall == "firewalld" ]; then
    sudo apt-get -y install firewalld
    for i in "${v_portslist[@]}"
    do
      :
      echo "Added port $i to firewall ports open list"; sudo firewall-cmd --zone=public --permanent --add-port=$i/tcp &> /dev/null
      done
    sudo firewall-cmd --zone=public --remove-service=ssh --permanent
    sudo firewall-cmd --reload
    sudo service firewalld restart
  fi
}

function f_postinstall() {
  sudo apt-get -y update
  sudo apt-get -y upgrade
  sudo apt-get -y dist-upgrade
  sudo apt-get -y autoremove
  sudo apt-get -y autoclean
}
