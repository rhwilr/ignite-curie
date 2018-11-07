#!/usr/bin/env bash

# sync mirrors and install Ansible
pacman -Syy python2-passlib ansible

# install and update the submodules
git submodule init && git submodule update

# the playbook.
ansible-playbook -i localhost playbook.yml