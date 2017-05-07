#!/bin/sh
set -e

# vagrant requires sudo without a password
if [ ! -s /etc/sudoers.d/vagrant ]; then
	echo "vagrant ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/vagrant
fi

# Create rc.local if missing
if [ ! -e /etc/rc.local ]; then
	printf "#!/bin/sh\n\nexit 0" > /etc/rc.local
fi
# Make sure SSH host keys are generated at boot if they're missing
if ! grep -Fq "test -f /etc/ssh/ssh_host_dsa_key || dpkg-reconfigure openssh-server" /etc/rc.local; then
	sed -i -e '$i test -f /etc/ssh/ssh_host_dsa_key || dpkg-reconfigure openssh-server' /etc/rc.local
	chmod +x /etc/rc.local
fi

# Add default vagrant key to authorized_keys
mkdir -p /home/vagrant/.ssh
wget https://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub -O /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh

# Install nfs-common for shared folders
apt-get install -y nfs-common 
apt-get clean
