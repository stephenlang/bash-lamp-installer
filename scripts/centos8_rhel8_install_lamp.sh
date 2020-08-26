#!/usr/bin/env bash

# centos8_rhel8_install_lamp.sh
# LAMP installer setting up Apache, PHP, MySQL, Holland and attempts to
# set some sane defaults.
#
# Copyright (c) 2020, Stephen Lang
# All rights reserved.
#
# Git repository available at:
# https://github.com/stephenlang/bash-lamp-installer
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
#
# Redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.


#################################################
# Base Package Installation Tasks
#################################################

# Update system
yum -y update

# Install EPEL and IUS Repo
yum install -y epel-release

# Check to ensure EPEL repo was installed
if [ `rpm -qa |grep -i epel-release | wc -l` -lt 1 ]; then
	echo "Error:  EPEL repository could not be installed."
	echo "Please install EPEL repository and rerun script."
	echo "https://support.rackspace.com/how-to/install-epel-and-additional-repositories-on-centos-and-red-hat/"
	sleep 2
	exit 1
fi

# Install base packages
yum install -y crontabs openssh-server vim chrony sysstat man wget rsync screen
systemctl enable crond
systemctl enable sshd
systemctl enable chronyd
systemctl start crond
systemctl start sshd
systemctl start chronyd


#################################################
# Web Server Package Installation Tasks
#################################################

# Apache variables
# Taking defaults for the time being

# PHP variables
max_execution_time=30
memory_limit=64M
error_reporting='E_ALL \& ~E_NOTICE | E_DEPRECATED'
post_max_size=8M
upload_max_filesize=2M
short_open_tag='On'
expose_php=Off

# Install Apache and PHP packages
yum install -y httpd httpd-tools mod_ssl php-common php-gd php-mysqlnd php-opcache php-xml php-devel mod_php

# Copy over templates
mkdir /var/www/vhosts
mkdir /etc/httpd/vhost.d
cp ../templates/rhel8/apache/default.template /etc/httpd/vhost.d
cp ../templates/rhel8/apache/ssl.conf.template /etc/httpd/conf.d/ssl.conf
cp ../templates/rhel8/apache/status.conf.template /etc/httpd/conf.d/status.conf
cp ../templates/rhel8/php/php.ini.template /etc/php.ini

# Setup couple one offs
if [ `grep "Listen 443" /etc/httpd/conf/httpd.conf |wc -l` = 0 ]; then
	sed -i '/^Listen 80/a Listen 443' /etc/httpd/conf/httpd.conf
fi

if [ `grep "IncludeOptional vhost.d/" /etc/httpd/conf/httpd.conf |wc -l` = 0 ]; then
	echo "IncludeOptional vhost.d/*.conf" >> /etc/httpd/conf/httpd.conf
fi

# Setup Apache variables
# Taking defaults for the time being

# Setup PHP variables
sed -i "s/\$memory_limit/$memory_limit/g" /etc/php.ini
sed -i "s/\$short_open_tag/$short_open_tag/g" /etc/php.ini
sed -i "s/\$expose_php/$expose_php/g" /etc/php.ini
sed -i "s/\$max_execution_time/$max_execution_time/g" /etc/php.ini
sed -i "s/\$error_reporting/$error_reporting/g" /etc/php.ini
sed -i "s/\$register_globals/$register_globals/g" /etc/php.ini
sed -i "s/\$post_max_size/$post_max_size/g" /etc/php.ini
sed -i "s/\$upload_max_filesize/$upload_max_filesize/g" /etc/php.ini

# Secure /server-status behind htaccess
srvstatus_htuser=serverinfo
srvstatus_htpass=`< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c16`
echo "$srvstatus_htuser $srvstatus_htpass" > /root/.serverstatus
htpasswd -b -c /etc/httpd/status-htpasswd $srvstatus_htuser $srvstatus_htpass

# Set services to start on boot and start up
systemctl enable httpd
systemctl start httpd

# Open up ports 80 and 443 in iptables
firewall-cmd --zone=public --add-service=http
firewall-cmd --zone=public --permanent --add-service=http
firewall-cmd --zone=public --add-service=https
firewall-cmd --zone=public --permanent --add-service=https
firewall-cmd --reload


#################################################
# MySQL Server Package Installation Tasks
#################################################

# MySQL variables
# Taking default for the time being
mysqlrootpassword=`< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c16`

# Install MySQL packages
yum install -y mariadb mariadb-devel mariadb-server

# Copy over templates
#cp ../templates/rhel8/mysql/mysql-logrotate.template /etc/logrotate.d/mysqllogs

# Setup MYSQL variables
# Taking defaults for the time being

# Set services to start on boot and restart
systemctl enable mariadb
systemctl start mariadb

# Set some basic security stuff within MYSQL
mysql -e "UPDATE mysql.user SET Password = PASSWORD('$mysqlrootpassword') WHERE User = 'root'"
mysql -e "DROP USER ''@'localhost'"
mysql -e "DROP USER ''@'$(hostname)'"
mysql -e "DROP DATABASE test"
mysql -e "FLUSH PRIVILEGES"

# Set MySQL root password in /root/.my.cnf
cp ../templates/rhel8/mysql/dot.my.cnf.template /root/.my.cnf
sed -i "s/\$mysqlrootpassword/$mysqlrootpassword/g" /root/.my.cnf


#################################################
# Holland Installation Tasks
#################################################

# Install Holland packages
yum install -y holland holland-mysqldump holland-common

# Copy over templates and configure backup directory
cp ../templates/rhel8/holland/default.conf.template /etc/holland/backupsets/default.conf

# Setup nightly cronjob
echo "30 3 * * * root /usr/sbin/holland -q bk" > /etc/cron.d/holland

# Run holland
/usr/sbin/holland -q bk


#################################################
# Setup Report
#################################################

# Setup report variables
txtbld=$(tput bold)
lightblue=`tput setaf 6`
nc=`tput sgr0`
real_ip=`curl --silent -4 icanhazip.com 2>&1`

# Generate setup report

cat << EOF > /root/setup_report

${txtbld}---------------------------------------------------------------
                 LAMP Installation Complete
---------------------------------------------------------------${nc}

The LAMP installation has been completed!  Some important information is
posted below.  A copy of this setup report exists in /root/setup_report.

${txtbld}---------------------------------------------------------------
                 Security Credentials
---------------------------------------------------------------${nc}

${lightblue}Apache Server Status URL:${nc}   http://$real_ip/server-status
${lightblue}Apache Server Status User:${nc}  serverinfo
${lightblue}Apache Server Status Pass:${nc}  $srvstatus_htpass

${lightblue}MySQL Root User:${nc}  root 
${lightblue}MySQL Root Pass:${nc}  $mysqlrootpassword

If you lose this setup report, the credentails can be found in:
${lightblue}Apache Server Status:${nc}  /root/.serverstatus
${lightblue}MySQL Credentials:${nc}     /root/.my.cnf

${txtbld}---------------------------------------------------------------
                 Nightly MySQL Backups
---------------------------------------------------------------${nc}

MySQL backups are being performed via Holland (www.hollandbackup.org) and
is set to run nightly at 3:30AM server time.  

The critical information about Holland is below:

${lightblue}Backup directory:${nc}  /var/spool/holland
${lightblue}Backups run time:${nc}  Nightly at 3:30AM server time
${lightblue}Retention rate:${nc}    7 days

${lightblue}Holland log file:${nc}  /var/log/holland/holland.log
${lightblue}Holland configs:${nc}   /etc/holland/holland.conf
                   /etc/holland/backupsets/default.conf
                   /etc/cron.d/holland

${txtbld}---------------------------------------------------------------${nc}

EOF

cat /root/setup_report
