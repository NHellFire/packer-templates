#!/bin/sh
set -e
apt-get update || true
apt-get dist-upgrade -y

apt-get install -y qemu-guest-agent
