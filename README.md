# Ignite-Curie

Ignite-Curie is an Ansible playbook meant to provision a personal server
running Arch Linux. It is intended to run locally on a fresh Arch install (ie,
taking the place of any post-installation), but due to Ansible's idempotent
nature it may also be run on top of an already configured machine.

Ignite-Curie will mount a fileserver and setup a plex server. 
This behaviour may be changed by skipping the `media-server` tag.

## Running

First, sync mirrors and install Ansible:

    $ pacman -Syy python2-passlib ansible

Second, install and update the submodules:

    $ git submodule init && git submodule update

Run the playbook as root.

    $ ansible-playbook -i localhost playbook.yml

When run, Ansible will prompt for the user password. This only needs to be
provided on the first run when the user is being created. On later runs,
providing any password -- whether the current user password or a new one -- will
have no effect.