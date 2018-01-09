#!/bin/sh
set -e

echo 'APT::Periodic::Enable "0";' > /etc/apt/apt.conf.d/99-disable-periodic

apt-get update || true
apt-get dist-upgrade -y

apt-get install -y qemu-guest-agent
