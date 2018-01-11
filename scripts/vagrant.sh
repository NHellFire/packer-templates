#!/bin/sh
set -e

# vagrant requires sudo without a password
if [ ! -s /etc/sudoers.d/vagrant ]; then
	echo "vagrant ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/vagrant
fi

# Add default vagrant key to authorized_keys
mkdir -p /home/vagrant/.ssh
wget https://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub -O /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh
