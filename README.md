packer templates for libvirt Ubuntu vagrant boxes

Basic usage:

Edit `http/preseed.cfg`, commenting/editing `d-i mirror/http/proxy string http://10.0.0.1:3142/` as required.

`packer build -var-file=config/zesty-amd64.json ubuntu.json`

Default disk size is 40GB. Need more? Specify `-var disk_size=newsize`. Size is in MB.

Default logins are:
* root/vagrant 
* vagrant/vagrant with the vagrant insecure key.



If using packer older than v1.1.2, you will need to set `iso_checksum_type` to `none` in ubuntu.json
