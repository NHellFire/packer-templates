#!/bin/sh
set -e

apt-get install -y build-essential python
apt-get clean
apt-get autoclean
