#!/bin/bash

# It is running as root
export AZURE_DNS="$1"
export NBITCOIN_NETWORK="$2"
export LETSENCRYPT_EMAIL="$3"
export LIGHTNING_DOCKER_REPO="$4"
export LIGHTNING_DOCKER_REPO_BRANCH="$5"
export CHARGED_ALIAS="$6"
export CHARGED_IP="$7"

export DOWNLOAD_ROOT="`pwd`"
export LIGHTNING_ENV_FILE="`pwd`/.env"

export CHARGED_HOST="$AZURE_DNS"
export LIGHTNING_DOCKER_COMPOSE="`pwd`/lightning-charge-docker/docker-compose.yml"
export ACME_CA_URI="https://acme-staging.api.letsencrypt.org/directory"

CHARGED_ALIAS="oneclick${CHARGED_ALIAS:-`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1`}"

echo "DNS NAME: $AZURE_DNS"

# Put the variable in /etc/environment for reboot
cp /etc/environment /etc/environment.bak
echo "AZURE_DNS=\"$AZURE_DNS\"" >> /etc/environment
echo "LIGHTNING_DOCKER_COMPOSE=\"$LIGHTNING_DOCKER_COMPOSE\"" >> /etc/environment
echo "DOWNLOAD_ROOT=\"$DOWNLOAD_ROOT\"" >> /etc/environment
echo "LIGHTNING_ENV_FILE=\"$LIGHTNING_ENV_FILE\"" >> /etc/environment


# Put the variable in /etc/profile.d when a user log interactively
touch "/etc/profile.d/lightning-env.sh"
echo "export AZURE_DNS=\"$AZURE_DNS\"" >> /etc/profile.d/lightning-env.sh
echo "export LIGHTNING_DOCKER_COMPOSE=\"$LIGHTNING_DOCKER_COMPOSE\"" >> /etc/profile.d/lightning-env.sh
echo "export DOWNLOAD_ROOT=\"$DOWNLOAD_ROOT\"" >> /etc/profile.d/lightning-env.sh
echo "export LIGHTNING_ENV_FILE=\"$LIGHTNING_ENV_FILE\"" >> /etc/profile.d/lightning-env.sh

# Install docker (https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/#set-up-the-repository) and docker-compose 
apt-get update 2>error
apt-get install -y \
    git \
    curl \
    apt-transport-https \
    ca-certificates \
    software-properties-common \
    2>error

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

apt-get update
apt-get install -y docker-ce

# Install docker-compose
curl -L https://github.com/docker/compose/releases/download/1.17.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Clone lightning-charge-docker
git clone $LIGHTNING_DOCKER_REPO
cd lightning-charge-docker
git checkout $LIGHTNING_DOCKER_REPO_BRANCH
cd ..

# Schedule for reboot

echo "
# File is saved under /etc/init/start_containers.conf
# After file is modified, update config with : $ initctl reload-configuration

description     \"Start containers (see http://askubuntu.com/a/22105 and http://askubuntu.com/questions/612928/how-to-run-docker-compose-at-bootup)\"

start on filesystem and started docker
stop on runlevel [!2345]

# if you want it to automatically restart if it crashes, leave the next line in
# respawn # might cause over charge

script
    . /etc/profile.d/lightning-env.sh
    cd \"`dirname \$LIGHTNING_ENV_FILE`\"
    docker-compose -f \"\$LIGHTNING_DOCKER_COMPOSE\" up -d
end script" > /etc/init/start_containers.conf

initctl reload-configuration

export CHARGED_API_TOKEN=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
# Set .env file
touch $LIGHTNING_ENV_FILE
echo "CHARGED_HOST=$CHARGED_HOST" >> $LIGHTNING_ENV_FILE
echo "ACME_CA_URI=$ACME_CA_URI" >> $LIGHTNING_ENV_FILE
echo "NBITCOIN_NETWORK=$NBITCOIN_NETWORK" >> $LIGHTNING_ENV_FILE
echo "LETSENCRYPT_EMAIL=$LETSENCRYPT_EMAIL" >> $LIGHTNING_ENV_FILE
echo "CHARGED_API_TOKEN=$CHARGED_API_TOKEN" >> $LIGHTNING_ENV_FILE
echo "CHARGED_ALIAS=$CHARGED_ALIAS" >> $LIGHTNING_ENV_FILE
echo "CHARGED_IP=$CHARGED_IP" >> $LIGHTNING_ENV_FILE

cd "`dirname $LIGHTNING_ENV_FILE`"
docker-compose -f "$LIGHTNING_DOCKER_COMPOSE" up -d 

chmod +x changedomain.sh
chmod +x lightning-restart.sh
chmod +x lightning-update.sh
chmod +x lightning-show.sh
chmod +x lightning-cli.sh
chmod +x bitcoin-cli.sh
ln -s `pwd`/changedomain.sh /usr/bin/changedomain.sh
ln -s `pwd`/lightning-restart.sh /usr/bin/lightning-restart.sh
ln -s `pwd`/lightning-update.sh /usr/bin/lightning-update.sh
ln -s `pwd`/lightning-show.sh /usr/bin/lightning-show.sh
ln -s `pwd`/lightning-cli.sh /usr/bin/lightning-cli.sh
ln -s `pwd`/bitcoin-cli.sh /usr/bin/bitcoin-cli.sh