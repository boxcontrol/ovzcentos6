#!/bin/bash
clear
echo 'Going to install OpenVZ for you..'
yum update -y
yum install -y wget 

echo 'now adding openvz Repo'
cd /etc/yum.repos.d
wget http://download.openvz.org/openvz.repo
rpm --import http://download.openvz.org/RPM-GPG-Key-OpenVZ

echo 'Installing OpenVZ Kernel'
yum install -y vzkernel.x86_64

echo 'Installing additional tools'
yum install -y vzctl vzquota ploop

echo 'Changing around some config files..'
sed -i 's/kernel.sysrq = 0/kernel.sysrq = 1/g' /etc/sysctl.conf
sed -i 's/net.ipv4.ip_forward = 0/net.ipv4.ip_forward = 1/g' /etc/sysctl.conf
echo 'net.ipv4.conf.default.proxy_arp = 0' >> /etc/sysctl.conf
echo 'net.ipv4.conf.all.rp_filter = 1' >> /etc/sysctl.conf
echo 'net.ipv4.conf.default.send_redirects = 1' >> /etc/sysctl.conf
echo 'net.ipv4.conf.all.send_redirects = 0' >> /etc/sysctl.conf
echo 'net.ipv4.icmp_echo_ignore_broadcasts=1' >> /etc/sysctl.conf
echo 'net.ipv4.conf.default.forwarding=1' >> /etc/sysctl.conf

echo 'Done with that, purging your sys configs'
sysctl -p

sed -i 's/NEIGHBOUR_DEVS=detect/NEIGHBOUR_DEVS=all/g' /etc/vz/vz.conf
sed -i 's/SELINUX=enabled/SELINUX=disabled/g' /etc/sysconfig/selinux

echo 'Downloading few OVZ templates from: http://wiki.openvz.org/Download/template/precreated'
cd /vz/template/cache
wget http://download.openvz.org/template/precreated/centos-6-x86_64.tar.gz
wget http://download.openvz.org/template/precreated/debian-7.0-x86_64.tar.gz
wget http://download.openvz.org/template/precreated/contrib/debian-7.0-amd64-minimal.tar.gz
wget http://download.openvz.org/template/precreated/ubuntu-13.04-x86_64.tar.gz

echo 'Finishing installation'
yum install -y ntp
ntpdate -u us.pool.ntp.org
chkconfig ntpd on
service iptables stop
service ip6tables stop
chkconfig iptables off
chkconfig ip6tables off

echo 'Installation is now finished server will be rebooted...'
reboot
