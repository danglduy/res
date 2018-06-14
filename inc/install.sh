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

if [ $v_install_nginx_srv == true ]; then
  f_install_nginx
fi

if [ $v_install_rails == true ]; then
  v_portslist+=(3000 5000)
  f_install_rails
fi

if [ $v_install_postgresql == true ]; then
  f_install_postgresql
fi

if [ $v_install_firewall == true ]; then
  f_install_firewall
fi

f_postinstall
