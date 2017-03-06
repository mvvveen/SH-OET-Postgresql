#!/bin/bash

# This script installs and sets up Postgresql 9.6 with Postgis extension 2.3 for van Oord Openearth Environment.

# Set variables

clear
echo "This script will install and configure PostgresSql software for your system"
# Check whether you are root

if [ "$(whoami)" != "root" ]; then
        echo "Sorry, you are not root, please run with sudo rights"
        exit 1
fi


APTCHECK=false

# Check if postgres community resource is there and add if needed

while [ $APTCHECK == "false" ];
do
clear
echo  Checking whether postgres community resource is there...
 if grep -q 'pgdg' "/etc/apt/sources.list";then
   echo "Yep it is there! Now preparing to install barman"
   APTCHECK="true"
 else
   echo "Adding it to your sources.list and updating your keyring"
   UBUNTUVERSION=$(lsb_release -cs)
   echo $UBUNTUVERSION
   echo  deb http://apt.postgresql.org/pub/repos/apt/ "${UBUNTUVERSION,,}"-pgdg main >> /etc/apt/sources.list
   sudo apt-get install wget ca-certificates
   wget -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
   sudo apt-get update
   APTCHECK="true"
 fi
done

echo "Updating repositories"

#Install Postgres

echo Really installing PostgresSql now
sudo apt-get install -y postgresql-9.6 postgresql-9.6-postgis-2.3

#asking the user the name of the barman server
function askuser {
        echo -n "What is the name of the barman server? : "
        read BKSERVER
        echo "You entered the following info"
        echo "Applicationserver:" $BKSERVER
        echo -n "is that correct (y/n)"
        read yn
}

#askuser

#while [ "$yn" != "y" ]; do
# askuser
#done

# Adjust the walarchving command
#sed -i.bak "s/bkserver/$BKSERVER/" ./postgresql.conf

#Making sure postgres is listening on all interfaces walarchiving is enabled and the walarchive command is filled.

if [  -f /etc/postgresql/9.6/main/postgresql.conf ]; then
	cp /etc/postgresql/9.6/main/postgresql.conf /etc/postgresql/9.6/main/postgresql.conf.org
	cp ./postgresql.conf /etc/postgresql/9.6/main/postgresql.conf
else
	echo "Postgres not correctly installed"
fi


#Making sure  postgres will answer on the local subnet.
if [  -f /etc/postgresql/9.6/main/pg_hba.conf ]; then
	cat ./pg_hba.conf >> /etc/postgresql/9.6/main/pg_hba.conf
else
	echo "Postgres not correctly installed"
fi

# Generate SSH keypair and copy it to backup server (development in progress)

#su postgres -c "mkdir ~/.ssh"
#su postgres -c "chmod 700 ~/.ssh"
#su postgres -c "ssh-keygen -t rsa"
#su postgres -c "ssh-copy-id vo-srv-openearth@$BKSERVER"

mkdir -p /var/data/openearth
mkdir -p /var/data/walarchive
chown postgres:postgres /var/data/walarchive
chown postgres:postgres /var/data/openearth
su postgres -c "/usr/lib/postgresql/9.6/bin/initdb -D /var/data/openearth/"

systemctl restart postgresql

#change the password of the postgres user
sudo -u postgres psql -U postgres -d postgres -c "alter user postgres with password 'abc';"

#add postgresql as a service in UFW
ufw enable
cp ./postgresql-server /etc/ufw/applications.d/.
ufw allow in from 10.0.0.0/8 to any app postgresql 

echo Check the path of the data directory it should point to /var/data/openearth

ps aux|grep postgres

