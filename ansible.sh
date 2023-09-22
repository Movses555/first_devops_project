#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
sudo apt-get --assume-yes update
sudo apt-get --assume-yes install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt-get --assume-yes install ansible

