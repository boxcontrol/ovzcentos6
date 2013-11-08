#!/bin/bash
clear
echo 'Going to install OpenVZ for you..'
yum update -y
yum install -y wget 

echo 'adding swap'
dd if=/dev/zero of=/swapfile bs=1024 count=512k
mkswap /swapfile
swapon /swapfile
echo  '/swapfile          swap            swap    defaults        0 0' >> /etc/fstab
chown root:root /swapfile 
chmod 0600 /swapfile
sysctl vm.swappiness=20
echo 'vm.swappiness=20' >> /etc/sysctl.conf
 I
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
wget http://download.openvz.org/template/precreated/contrib/debian-7.0-amd64-minimal.tar.gz

echo 'Finishing installation'
yum install -y ntp
ntpdate -u us.pool.ntp.org
chkconfig ntpd on
service iptables stoplets
service ip6tables stop
chkconfig iptables off
chkconfig ip6tables off

echo 'installing kernel tools'
yum update kernel*
yum install -y kexec-tools

latestkernel=`ls -t /boot/vmlinuz-* | sed "s/\/boot\/vmlinuz-//g" | head -n1` 
echo $latestkernel 
kexec -l /boot/vmlinuz-${latestkernel} --initrd=/boot/initramfs-${latestkernel}.img --append="`cat /proc/cmdline`"
kexec -e
