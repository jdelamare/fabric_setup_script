#!/bin/bash

# This script is not guaranteed to get the latest version.
echo "This script installs Docker, Docker Compose, Go Lang, and Hyperledger Fabric binaries."
echo "This script is INTERACTIVE!!! Stick around and press some keys..."
sleep 7

echo "############## Checking to see if cURL is installed... ##############"
curl --version >> /dev/null
if (($? == 0)); then # cURL is not installed. Install it.
    echo "Updating existing packages"
    sudo apt update
    echo "Installing cURL"
    sudo apt install curl 
    echo "cURL was not installed, but we fixed that :)"
else
    echo "cURL is already installed"
fi

echo "############## Checking to see if Docker is installed... ##############"
docker --version >> /dev/null
if (($? != 0)); then # Docker is not installed. Install it. 
    echo "Docker is NOT installed. You'll need to log out and log back in, then run this script again."
    sleep 7
    echo "Updating existing packages"
    sudo apt update
    echo "Install prerequisite packages to allow apt to use packages over HTTPS"
    sudo apt install apt-transport-https ca-certificates curl software-properties-common
    echo "Add the GPG key for the official Docker repo"
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    echo "Add the Docker repo to APT sources"
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
    echo "Update package database:"
    sudo apt update
    echo "Use the correct repo for installing Docker"
    apt-cache policy docker-ce
    echo "Installing Docker"
    sudo apt install docker-ce
    sudo usermod -aG docker ${USER}
    #sudo gpasswd -a $USER docker   # wanted to do this all in one go :*(
    #newgrp docker
    # potentially use set -e to crash if this setup doesn't work right 
    exit 0
else
    echo "Docker is already installed"
fi

echo "############## Checking to see if Docker Compose is installed... ##############"
docker-compose --version >> /dev/null
if (($? != 0)); then # Docker-compose is not installed. Install it.
    echo "Updating existing packages"
    sudo apt update
    echo "Install the latest version from GitHub"
    sudo curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
    echo "Set the permissions"
    sudo chmod +x /usr/local/bin/docker-compose
else
    echo "Docker-compose is already installed" 
fi

echo "############## Checking to see if Golang is installed... ##############"
go version >> /dev/null
if (($? != 0)); then # Golang is not installed. Install it.
    echo "Installing into the home directory"
    cd ~
    curl -O https://dl.google.com/go/go1.11.linux-amd64.tar.gz
    echo "Expanding the tar ball"
    tar xvf go1.11.linux-amd64.tar.gz
    echo "Chaning permissions and relocating the dir"
    sudo chown -R root:root ./go
    sudo mv go /usr/local
    echo "Setting environment paths"
    echo "export GOROOT=/usr/local/go \n# access go binary system wide \nexport PATH=$GOPATH/bin:$GOROOT/bin:$PATH\n# GOPATH is the location of your work directory.\nexport GOPATH=$HOME/go/" >> .bashrc
    mkdir $HOME/go
    echo "The working directory for Go programs is in \$HOME/go/"
else
    echo "Golang is already installed"
fi

echo "############## Installing Hyperledger Fabric Sample Files... ##############"
cd go/
curl -sSL http://bit.ly/2ysbOFE | bash -s 1.2.0
export PATH=$HOME/go/fabric-samples/bin:$PATH

echo "############## Testing a sample network... ##############"
cd $HOME/go/fabric-samples/first-network
echo "Generating network artifacts"
./byfn.sh generate
echo "Bringing up the network"
./byfn.sh up
echo "Bringing down the network"
./byfn.sh down


# Again, considering using set -e to make sure this stuff works. 
