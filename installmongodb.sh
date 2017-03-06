#!/bin/bash

# This script installs and sets up Postgresql 9.6 with Postgis extension 2.3 for van Oord Openearth Environment.

# Set variables

clear
echo "This script will install and configure MongoDB software for your system"
# Check whether you are root

if [ "$(whoami)" != "root" ]; then
        echo "Sorry, you are not root, please run with sudo rights"
        exit 1
fi


APTCHECK=false

# Check if mongodb community resource is there and add if needed

while [ $APTCHECK == "false" ];
do
clear
echo  Checking whether postgres community resource is there...
 if  [ -f "/etc/apt/sources.list.d/mongodb-org-3.2.list" ];then
   echo "Yep it is there! Now preparing to install mongodb"
   APTCHECK="true"
 else
   echo "Adding it to your sources.list and updating your keyring"
   UBUNTUVERSION=$(lsb_release -cs)
   echo $UBUNTUVERSION
   apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
   echo deb http://repo.mongodb.org/apt/ubuntu "${UBUNTUVERSION,,}"/mongodb-org/3.2 multiverse | \
   tee "/etc/apt/sources.list.d/mongodb-org-3.2.list" ;
   apt  update
   apt  install -y mongodb-org
   APTCHECK="true"
 fi
done

mkdir -p /var/data/mongodb
sed -i.bak "s/hostname/$HOSTNAME/" ./mongod.conf
cp mongod.conf /etc/.
systemctl restart mongod.service
systemctl status mongod
