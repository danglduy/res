#!/bin/bash

# Change authentication from unix to user/password
string1="local   all             all                                     peer"
string2="local   all             all                                     md5"
sudo sed -i "s/$string1/$string2/g" /etc/postgresql/10/main/pg_hba.conf
sudo service postgresql restart

# Create database, role with password.
role='sample_app'
rolepassword='12345678' # sample only, change to your own secure password
dbdevelopment=$role'_development'
dbtest=$role'_test'
dbproduction=$role'_production'
sudo -u postgres psql -c "CREATE ROLE $role WITH LOGIN ENCRYPTED PASSWORD '$rolepassword';"
sudo -u postgres psql -c "ALTER USER $role CREATEDB;"
#sudo -H -u postgres psql -U $role -d template1 -c "CREATE DATABASE $dbdevelopment;" -W
#sudo -H -u postgres psql -U $role -d template1 -c "CREATE DATABASE $dbtest;" -W
#sudo -H -u postgres psql -U $role -d template1 -c "CREATE DATABASE $dbproduction;" -W

# Change role password (change with your own secure password) : 
# sudo -H -u postgres psql -c "ALTER USER sample_app WITH LOGIN ENCRYPTED PASSWORD '123456789';"
