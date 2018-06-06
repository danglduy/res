#!/bin/bash

if [ $v_create_user == true ]; then
  f_create_user
else
  user=$(whoami)
fi

f_create_swap

f_install_essential_packages

if [ $v_disable_root_ssh_login == true ]; then
  f_disable_root_ssh_login
fi

if [ $v_disable_ssh_password == true ]; then
  f_disable_ssh_password
fi

if [ $v_create_ssh_key == true ]; then
  f_create_ssh_key

fi

if [ $v_install_gui == true ]; then
  f_install_gui
fi

if [ $v_install_nginx_srv == true ]; then
     f_install_nginx
fi

if [ $v_install_rails == true ]; then
  v_portslist+=(3000 5000)
  f_install_rails
fi

if [ $v_install_firewall == true ]; then
  f_install_firewall
fi

f_postinstall
