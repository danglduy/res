#!/bin/bash
distro="$(lsb_release -i -s)"
distro="${distro,,}"
distro_code="$(lsb_release -c -s)"
read "Your domain name:" domain_name
printf "\n"

# Ubuntu
if [ $distro == "ubuntu" ]; then
  sudo apt-get -y update
  sudo apt-get -y install software-properties-common
  sudo add-apt-repository ppa:certbot/certbot
  sudo apt-get -y update
  sudo apt-get -y install python-certbot-nginx
  sudo apt-get -y install python3-pip python3-dev
  sudo pip3 install pyasn1 setuptools wheel pyyaml
  sudo pip3 install certbot-dns-cloudflare
fi

sudo certbot certonly \
  --dns-cloudflare \
  --dns-cloudflare-credentials ./cloudflare.ini \
  --register-unsafely-without-email \
  -d $domain_name \
  -d www.$domain_name

sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
sudo service nginx restart
