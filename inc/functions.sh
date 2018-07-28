#!/bin/bash
function f_create_user {
  # Create new user & prompt for password creation
  read -p "Your username: " user
  printf "\n"
  sudo adduser --gecos $user $user
  #Add user $user to sudo group
  sudo usermod -a -G sudo $user
}

function f_disable_root_ssh_login {
  # Disable SSH Root Login
  sudo sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
}

function f_disable_ssh_password {
  # Disable SSH Password Authentication
  sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
  sudo sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
}

function f_create_ssh_key {
  v_root_ssh_keypath="/root/.ssh/authorized_keys"
  # Check root ssh key exist
  if sudo test -e $v_root_ssh_keypath; then
    # If exist copy the key to the user and delete the root's key folder
    sudo cp -R /root/.ssh $homepath/.ssh
    sudo chown -R $user:$user $homepath/.ssh
    sudo chmod 700 $homepath/.ssh
    sudo chmod 600 $homepath/.ssh/authorized_keys
    # sudo rm -R /root/.ssh
  else
    sudo -u $user mkdir -p $homepath/.ssh
    #If not exist create key file to the user
    sudo touch $homepath/.ssh/authorized_keys
    echo "$v_public_key" | sudo tee --append $homepath/.ssh/authorized_keys
    sudo chown -R $user:$user $homepath/.ssh
    sudo chmod 700 $homepath/.ssh
    sudo chmod 600 $homepath/.ssh/authorized_keys
  fi
  sudo service sshd restart
}

function f_create_swap {
  # Create swap disk image if the system doesn't have swap.
  if [ $distro_code == "trusty" ]; then
    checkswap="$(sudo swapon --summary)"
  else
    checkswap="$(sudo swapon --show)"
  fi

  if [ -z "$checkswap" ]; then
    sudo mkdir -v /var/cache/swap
    sudo dd if=/dev/zero of=/var/cache/swap/swapfile bs=$v_swap_bs count=1M
    sudo chmod 600 /var/cache/swap/swapfile
    sudo mkswap /var/cache/swap/swapfile
    sudo swapon /var/cache/swap/swapfile
    echo "/var/cache/swap/swapfile none swap sw 0 0" | sudo tee -a /etc/fstab
  fi
}

function f_disable_sudo_password_for_apt {
  sudo touch /etc/sudoers.d/tmpsudo$user
  echo "$user ALL=(ALL) NOPASSWD: /usr/bin/apt-get" | sudo tee /etc/sudoers.d/tmpsudo$user
  sudo chmod 0440 /etc/sudoers.d/tmpsudo$user
}

function f_enable_sudo_password_for_apt {
  sudo rm /etc/sudoers.d/tmpsudo$user
}

function f_install_sublimetext {
  #Sublime Text
  wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
  echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
  sudo apt-get update
  sudo apt-get -y install sublime-text
}

function f_install_vncserver {
  sudo apt-get -y install vnc4server
  # Create vncserver launch file
  sudo -H -u $user touch $homepath/vncserver.sh
  sudo -H -u $user chmod +x $homepath/vncserver.sh
  if [ $v_vnc_localhost == true ]; then
    sudo -H -u $user echo "vncserver -geometry 1280x650 -localhost" > $homepath/vncserver.sh
  else
    sudo -H -u $user echo "vncserver -geometry 1280x650" > $homepath/vncserver.sh
  fi
}

function f_install_gui {
  sudo apt-get update
  sudo apt-get -y install xfce4 xfce4-goodies gnome-icon-theme
}

function f_install_essential_packages {
  sudo apt-get -y update
  sudo apt-get -y install dirmngr whois apt-transport-https unzip
}

function f_add_domain {
  custom_domain="custom_domain-puma_https"
  custom_domain_http="custom_domain-puma_http"
  read -p "Add a domain (y/n)? " add_domain
  printf "\n"
  if [ $add_domain == "y" ]; then
    read -p "Write your domain name: " domain_name
    printf "\n"
    sudo mkdir /var/www/vhosts/$domain_name
    sudo cp inc/nginx/$custom_domain /etc/nginx/sites-available/$domain_name
    sudo cp inc/nginx/$custom_domain_http /etc/nginx/sites-available/$domain_name-http
    sudo sed -i "s/domain_name/$domain_name/g" /etc/nginx/sites-available/$domain_name
    sudo sed -i "s/domain_name/$domain_name/g" /etc/nginx/sites-available/$domain_name-http
    sudo ln -s /etc/nginx/sites-available/$domain_name /etc/nginx/sites-enabled/$domain_name
  fi
}

function f_config_nginx {
  nginx_debian="nginx_debian.conf"
  sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
  sudo rm -f /etc/nginx/nginx.conf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default /etc/nginx/conf.d/*
  sudo cp inc/nginx/$nginx_debian /etc/nginx/nginx.conf
  sudo cp inc/nginx/default /etc/nginx/sites-available/default
  sudo ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
  sudo mkdir -p /var/www/vhosts
  f_add_domain
  sudo chown -R www-data:www-data /var/www

}

function f_install_nginx {
  sudo apt-get update
  sudo apt-get install -y nginx-extras
  f_config_nginx
}

function f_install_ruby_manager {
  if [ $v_ruby_manager == "rvm" ]; then
    f_disable_sudo_password_for_apt
    # sudo -H -u $user gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
    sudo -H -u $user curl -sSL https://rvm.io/mpapis.asc | sudo -H -u $user gpg --import -
    sudo -H -u $user \curl -sSL https://get.rvm.io | sudo -H -u $user bash

    if [ $v_install_ruby == true ]; then
      sudo -H -u $user rvm install $v_ruby_version
      sudo -H -u $user rvm defaults $v_ruby_version
      sudo -H -u $user gem install bundler
    fi

    f_enable_sudo_password_for_apt
  elif [ $v_ruby_manager == "rbenv" ]; then
    # Install rbenv
    sudo apt-get -y install autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev \
      zlib1g-dev libncurses5-dev libffi-dev libgdbm-dev libsqlite3-dev
    sudo -H -u $user curl -fsSL https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-installer | sudo su - $user -c bash
    sudo -H -u $user echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> $homepath/.bash_profile
    sudo -H -u $user echo 'eval "$(rbenv init -)"' >> $homepath/.bash_profile
    sudo -H -u $user curl -fsSL https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-doctor | sudo su - $user -c bash

    if [ $v_install_ruby == true ]; then
      sudo -H -u $user -i rbenv install --verbose $v_ruby_version
      sudo -H -u $user -i rbenv global $v_ruby_version
      sudo -H -u $user -i rbenv rehash
      sudo -H -u $user -i gem install bundler
    fi

  fi

  #NodeJS certificate & repo
  curl -sL https://deb.nodesource.com/setup_8.x | sudo bash -

  #Yarn certificate & repo
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

  sudo apt-get -y update
  sudo apt-get -y install nodejs yarn
}

function f_install_postgresql_client {
  # Postgresql certificate & repo
  wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
  sudo touch /etc/apt/sources.list.d/pgdg.list
  echo "deb http://apt.postgresql.org/pub/repos/apt/ $distro_code-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list
  sudo apt-get -y update
  sudo apt-get -y install postgresql-client-10 libpq-dev
}

function f_install_postgresql {
  f_install_postgresql_client
  sudo apt-get -y install postgresql-10
}

function f_install_mariadb {
  apt-get -y install mariadb-server libmariadbclient-dev-compat
}

function f_install_mysql {
  apt-get -y install mysql-server libmysqlclient-dev
}

function f_secure_mariadb {
  sudo mysql -uroot << EOF
  UPDATE mysql.user SET Password=PASSWORD("$MYSQL_ROOT_PASSWORD") WHERE User='root';
  DELETE FROM mysql.user WHERE user='root' AND host NOT IN ('localhost', '127.0.0.1', '::1');
  DELETE FROM mysql.user WHERE user='';
  DROP DATABASE IF EXISTS test;
  UPDATE mysql.user SET plugin='' WHERE user='root';
  FLUSH PRIVILEGES;
EOF
}

function f_secure_mysql {
  sudo mysql -uroot << EOF
  UPDATE mysql.user SET Authentication_string=PASSWORD("$MYSQL_ROOT_PASSWORD") WHERE User='root';
  DELETE FROM mysql.user WHERE user='root' AND host NOT IN ('localhost', '127.0.0.1', '::1');
  DELETE FROM mysql.user WHERE user='';
  DROP DATABASE IF EXISTS test;
  UPDATE mysql.user SET plugin='native_authentication' WHERE user='root';
  FLUSH PRIVILEGES;
EOF
}

function f_install_firewall {
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

function f_postinstall {
  sudo apt-get -y update
  sudo apt-get -y upgrade
  sudo apt-get -y dist-upgrade
  sudo apt-get -y autoremove
  sudo apt-get -y autoclean
}
