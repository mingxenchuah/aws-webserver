#!/bin/bash

# update OS
yum clean all
yum upgrade -y

# disable ipv6
cat >> /etc/sysctl.conf << EOL
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
EOL
sed -i 's/^.*AddressFamily.*$/AddressFamily inet/g' /etc/ssh/sshd_config
#sysctl -p
#systemctl restart sshd

# install extra packages
yum install -y ntp telnet mtr tree

# configure NTP and timezone
yum erase -y chrony
systemctl enable ntpd
#systemctl start ntpd
timedatectl set-timezone Australia/Melbourne
timedatectl set-ntp yes
ntpd -gq

# set limits
echo 'fs.file-max = 65536' >> /etc/sysctl.conf
rm -f /etc/security/limits.d/*
cat > /etc/security/limits.d/custom.conf << EOL
* soft     nproc          65535
* hard     nproc          65535
* soft     nofile         65535
* hard     nofile         65535
EOL

# enable SELINUX
sed -i 's/^SELINUX=.*$/SELINUX=enforcing/g' /etc/selinux/config
