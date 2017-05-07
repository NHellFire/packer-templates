#!/bin/sh
set -e
apt-get update || true
apt-get dist-upgrade -y

apt-get autoremove --purge
apt-get clean
apt-get autoclean

