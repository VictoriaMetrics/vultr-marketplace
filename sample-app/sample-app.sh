#!/bin/bash
################################################
## Prerequisites
chmod +x /root/vultr-helper.sh
. /root/vultr-helper.sh
error_detect_on
install_cloud_init latest

################################################
# Install Nginx, MariaDB, and the htpassword utility, which is a part of apache2-utils.
# Use apt_safe() from vultr-helper.sh to avoid database locks.
apt_safe nginx mariadb-server apache2-utils

################################################
# Add basic authentication to the default Nginx site.
sed -i'' "/^\tlocation \/ {$/a \ \t\tauth_basic \"Restricted Content\";\n\t\tauth_basic_user_file /etc/nginx/.htpasswd;" /etc/nginx/sites-enabled/default

################################################
## Prepare server snapshot for Marketplace

update_and_clean_packages
set_vultr_kernel_option
clean_tmp
clean_keys
clean_logs
clean_history
clean_random
clean_machine_id
clean_cloud_init

################################################
## Install provisioning scripts
mkdir -p /var/lib/cloud/scripts/per-boot/
mkdir -p /var/lib/cloud/scripts/per-instance/

mv /root/setup-per-boot.sh /var/lib/cloud/scripts/per-boot/setup-per-boot.sh
mv /root/setup-per-instance.sh /var/lib/cloud/scripts/per-instance/setup-per-instance.sh

chmod +x /var/lib/cloud/scripts/per-boot/setup-per-boot.sh
chmod +x /var/lib/cloud/scripts/per-instance/setup-per-instance.sh

################################################
## Finish cleanup and wipe free disk space
## Non-zero return codes are benign and expected.
error_detect_off

clean_mloc
clean_free_space
trim_ssd
