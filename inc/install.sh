#!/bin/bash

if [ $v_create_user == true ]; then
  f_create_user
  homepath="/home/$user"
else
  user=$(whoami)
  if [ $user == "root" ]; then
    homepath="/root"
  else
    homepath="/home/$user"
  fi
fi

if [ $v_install_mdb == true  ]; then
  read -sp "Set mysql root password: " MYSQL_ROOT_PASSWORD
  printf "\n"
fi

read -p "Add a domain (y/n)? " add_domain
printf "\n"
if [ $add_domain == "y" ]; then
  read -p "Write your domain name: " domain_name
  printf "\n"
fi

f_create_swap

f_install_essential_packages
if [ $user != "root" ]; then
  # Only disable root ssh login if the current user is not root or a new user is created
  if [ $v_disable_root_ssh_login == true ]; then
    f_disable_root_ssh_login
  fi
fi

if [ $v_disable_ssh_password == true ]; then
  f_disable_ssh_password
fi

if [ $user != "root" ]; then
  # Only create ssh key if the current user is not root or a new user is created
  if [ $v_create_ssh_key == true ]; then
    f_create_ssh_key
  fi
fi

if [ $v_install_gui == true ]; then
  f_install_gui
fi

if [ $v_install_vncserver == true ]; then
  f_install_vncserver
fi

if [ $v_install_sublimetext == true ]; then
  f_install_sublimetext
fi

if [ $v_install_ruby_manager == true ]; then
  f_install_ruby_manager
fi

if [ $v_install_postgresql == true ]; then
  f_install_postgresql
else
  f_install_postgresql_client
fi

if [ $v_install_mdb == true ]; then
  if [ $distro == "debian"  ]; then
    f_install_mariadb
    f_secure_mariadb
  elif [ $distro == "ubuntu" ]; then
    if [ $v_mdb_edition == "mysql" ]; then
      f_install_mysql
      f_secure_mysql
    else
      f_install_mariadb
      f_secure_mariadb
    fi
  fi
  f_secure_db
fi

if [ $v_install_nginx_srv == true ]; then
  f_install_nginx
fi

if [ $v_install_firewall == true ]; then
  f_install_firewall
fi

f_postinstall
