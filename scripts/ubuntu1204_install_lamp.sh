#!/usr/bin/env bash

# ubuntu1204_install_lamp.sh
# LAMP installer setting up Apache, PHP, MySQL, Holland and attempts to
# set some sane defaults.
#
# Copyright (c) 2016, Stephen Lang
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
apt-get update
apt-get -y upgrade

# Install base packages
apt-get install -y cron openssh-server vim ntp sysstat man wget rsync screen


#################################################
# Web Server Package Installation Tasks
#################################################

# Apache variables
timeout=30
keep_alive=On
keep_alive_requests=120
keep_alive_timeout=5
prefork_start_servers=4
prefork_min_spare_servers=4
prefork_max_spare_servers=9
prefork_server_limit=`free -m | grep "Mem:" | awk '{print $2/2/15}' | xargs printf "%.0f"`
prefork_max_clients=`free -m | grep "Mem:" | awk '{print $2/2/15}' | xargs printf "%.0f"`
prefork_max_requests_per_child=1000
prefork_listen_backlog=`free -m | grep "Mem:" | awk '{print $2/2/15*2}' | xargs printf "%.0f"`
worker_start_servers=4
worker_max_clients=1024
worker_min_spare_threads=64
worker_max_spare_threads=192
worker_threads_per_child=64
worker_max_requests_per_child=0

# PHP variables
max_execution_time=30
memory_limit=64M
error_reporting='E_ALL \& ~E_NOTICE | E_DEPRECATED'
register_globals=Off
post_max_size=8M
upload_max_filesize=2M
short_open_tag='On'
expose_php=Off
session_save_path='/var/lib/php5/session'

# Install Apache and PHP packages
apt-get install -y libapache2-mod-php5 php5-cli php-pear php5-mysql php-apc php5-gd php5-dev php5-curl php5-mcrypt
/usr/sbin/a2enmod cgi dir env ssl mime alias status deflate rewrite setenvif autoindex reqtimeout auth_basic authn_file authz_host authz_user negotiation authz_default authz_groupfile
/usr/sbin/php5enmod mcrypt

# Copy over templates
mkdir /var/www/vhosts
mkdir -p /var/lib/php5/session
chown root:www-data /var/lib/php5/session
chmod 770 /var/lib/php5/session
cp ../templates/ubuntu1204/apache/default.template /etc/apache2/sites-available/
cp ../templates/ubuntu1204/apache/apache2.conf.template /etc/apache2/apache2.conf
cp ../templates/ubuntu1204/apache/ports.conf.template /etc/apache2/ports.conf
cp ../templates/ubuntu1204/apache/ssl.conf.template /etc/apache2/conf.d/ssl.conf
cp ../templates/ubuntu1204/apache/status.conf.template /etc/apache2/mods-available/status.conf
cp ../templates/ubuntu1204/php/php.ini.template /etc/php5/apache2/php.ini

# Setup Apache variables
sed -i "s/\$timeout/$timeout/g" /etc/apache2/apache2.conf
sed -i "s/\$keep_alive_setting/$keep_alive/g" /etc/apache2/apache2.conf
sed -i "s/\$keep_alive_requests/$keep_alive_requests/g" /etc/apache2/apache2.conf
sed -i "s/\$keep_alive_timeout/$keep_alive_timeout/g" /etc/apache2/apache2.conf
sed -i "s/\$prefork_start_servers/$prefork_start_servers/g" /etc/apache2/apache2.conf
sed -i "s/\$prefork_min_spare_servers/$prefork_min_spare_servers/g" /etc/apache2/apache2.conf
sed -i "s/\$prefork_max_spare_servers/$prefork_max_spare_servers/g" /etc/apache2/apache2.conf
sed -i "s/\$prefork_server_limit/$prefork_server_limit/g" /etc/apache2/apache2.conf
sed -i "s/\$prefork_max_clients/$prefork_max_clients/g" /etc/apache2/apache2.conf
sed -i "s/\$prefork_max_requests_per_child/$prefork_max_requests_per_child/g" /etc/apache2/apache2.conf
sed -i "s/\$prefork_listen_backlog/$prefork_listen_backlog/g" /etc/apache2/apache2.conf
sed -i "s/\$worker_start_servers/$worker_start_servers/g" /etc/apache2/apache2.conf
sed -i "s/\$worker_max_clients/$worker_max_clients/g" /etc/apache2/apache2.conf
sed -i "s/\$worker_min_spare_threads/$worker_min_spare_threads/g" /etc/apache2/apache2.conf
sed -i "s/\$worker_max_spare_threads/$worker_max_spare_threads/g" /etc/apache2/apache2.conf
sed -i "s/\$worker_threads_per_child/$worker_threads_per_child/g" /etc/apache2/apache2.conf
sed -i "s/\$worker_max_requests_per_child/$worker_max_requests_per_child/g" /etc/apache2/apache2.conf

# Setup PHP variables
sed -i "s/\$memory_limit/$memory_limit/g" /etc/php5/apache2/php.ini
sed -i "s/\$short_open_tag/$short_open_tag/g" /etc/php5/apache2/php.ini
sed -i "s/\$expose_php/$expose_php/g" /etc/php5/apache2/php.ini
sed -i "s/\$max_execution_time/$max_execution_time/g" /etc/php5/apache2/php.ini
sed -i "s/\$error_reporting/$error_reporting/g" /etc/php5/apache2/php.ini
sed -i "s/\$register_globals/$register_globals/g" /etc/php5/apache2/php.ini
sed -i "s/\$post_max_size/$post_max_size/g" /etc/php5/apache2/php.ini
sed -i "s/\$upload_max_filesize/$upload_max_filesize/g" /etc/php5/apache2/php.ini
sed -i "s@\$session_save_path@$session_save_path@g" /etc/php5/apache2/php.ini

# Secure /server-status behind htaccess
srvstatus_htuser=serverinfo
srvstatus_htpass=`< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c16`
echo "$srvstatus_htuser $srvstatus_htpass" > /root/.serverstatus
htpasswd -b -c /etc/apache2/status-htpasswd $srvstatus_htuser $srvstatus_htpass

# Restart Apache to apply new settings
service apache2 restart

# Open up ports 80 and 443 in UFW
ufw allow 80
ufw allow 443


#################################################
# MySQL Server Package Installation Tasks
#################################################

# MySQL variables
datadir=/var/lib/mysql
socket=/var/run/mysqld/mysqld.sock
log_error=/var/log/mysql/error.log
table_open_cache=2048
query_cache_size=32M
max_heap_table_size=64M
max_connections=`echo $(( $prefork_max_clients + 2 ))`
wait_timeout=180
net_read_timeout=30
net_write_timeout=30
back_log=128
key_buffer_size=64M
innodb_buffer_pool_size=`free -m | grep "Mem:" | awk '{print $2*20/100}' | xargs printf "%.0f"M`
innodb_log_buffer_size=64M
log_bin=/var/lib/mysql/bin-log
log_relay=/var/lib/mysql/relay-log
log_slow=/var/lib/mysql/slow-log
includedir=/etc/mysql/conf.d
mysqlrootpassword=`< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c16`

# Install MySQL packages
export DEBIAN_FRONTEND=noninteractive
apt-get install -y mysql-server mysql-client libmysqlclient-dev 
mkdir -p /etc/mysql/conf.d
mkdir -p /var/lib/mysqltmp
chown mysql:mysql /var/lib/mysqltmp

# Copy over templates
cp ../templates/ubuntu1204/mysql/my.cnf.template /etc/mysql/my.cnf
cp ../templates/ubuntu1204/mysql/mysql-logrotate.template /etc/logrotate.d/mysqllogs

# Setup MYSQL variables
sed -i "s@\$datadir@$datadir@g" /etc/mysql/my.cnf
sed -i "s@\$socket@$socket@g" /etc/mysql/my.cnf
sed -i "s@\$log_error@$log_error@g" /etc/mysql/my.cnf
sed -i "s/\$table_open_cache/$table_open_cache/g" /etc/mysql/my.cnf
sed -i "s/\$query_cache_size/$query_cache_size/g" /etc/mysql/my.cnf
sed -i "s/\$max_heap_table_size/$max_heap_table_size/g" /etc/mysql/my.cnf
sed -i "s/\$max_connections/$max_connections/g" /etc/mysql/my.cnf
sed -i "s/\$wait_timeout/$wait_timeout/g" /etc/mysql/my.cnf
sed -i "s/\$net_read_timeout/$net_read_timeout/g" /etc/mysql/my.cnf
sed -i "s/\$net_write_timeout/$net_write_timeout/g" /etc/mysql/my.cnf
sed -i "s/\$back_log/$back_log/g" /etc/mysql/my.cnf
sed -i "s/\$key_buffer_size/$key_buffer_size/g" /etc/mysql/my.cnf
sed -i "s/\$innodb_buffer_pool_size/$innodb_buffer_pool_size/g" /etc/mysql/my.cnf
sed -i "s/\$innodb_log_buffer_size/$innodb_log_buffer_size/g" /etc/mysql/my.cnf
sed -i "s@\$log_bin@$log_bin@g" /etc/mysql/my.cnf
sed -i "s@\$log_relay@$log_relay@g" /etc/mysql/my.cnf
sed -i "s@\$log_slow@$log_slow@g" /etc/mysql/my.cnf
sed -i "s@\$log_error@$log_error@g" /etc/mysql/my.cnf
sed -i "s@\$includedir@$includedir@g" /etc/mysql/my.cnf
sed -i "s@\$log_slow@$log_slow@g" /etc/logrotate.d/mysqllogs

# Set some basic security stuff within MYSQL
mysql -e "UPDATE mysql.user SET Password = PASSWORD('$mysqlrootpassword') WHERE User = 'root'"
mysql -e "DROP USER ''@'localhost'"
mysql -e "DROP USER ''@'$(hostname)'"
mysql -e "DROP DATABASE test"
mysql -e "FLUSH PRIVILEGES"

# Set MySQL root password in /root/.my.cnf
cp ../templates/ubuntu1204/mysql/dot.my.cnf.template /root/.my.cnf
sed -i "s/\$mysqlrootpassword/$mysqlrootpassword/g" /root/.my.cnf

# Restart MySQL to apply changes
rm -f /var/lib/mysql/ib_logfile0
rm -f /var/lib/mysql/ib_logfile1
service mysql restart


#################################################
# Holland Installation Tasks
#################################################

# Setup Holland repo
eval $(cat /etc/os-release)
DIST="xUbuntu_${VERSION_ID}"
[ $ID == "debian" ] && DIST="Debian_${VERSION_ID}.0"
curl -s http://download.opensuse.org/repositories/home:/holland-backup/${DIST}/Release.key | sudo apt-key add -
echo "deb http://download.opensuse.org/repositories/home:/holland-backup/${DIST}/ ./" > /etc/apt/sources.list.d/holland.list

# Install Holland packages
apt-get update
apt-get install -y holland holland-mysqldump holland-common

# Copy over templates and configure backup directory
cp ../templates/ubuntu1204/holland/default.conf.template /etc/holland/backupsets/default.conf
sed -i 's@/var/spool/holland@/var/lib/mysqlbackup@g' /etc/holland/holland.conf

# Setup nightly cronjob
echo "30 3 * * * root /usr/sbin/holland -q bk" > /etc/cron.d/holland

# Run holland
/usr/sbin/holland -q bk


#################################################
# PHPMyAdmin Installation Tasks
#################################################

# PHPMyAdmin variables
htuser=serverinfo
htpass=`< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c16`

# Install PHPMyAdmin package
export DEBIAN_FRONTEND=noninteractive
apt-get install -y phpmyadmin

# Copy over templates
cp ../templates/ubuntu1204/phpmyadmin/phpMyAdmin.conf.template /etc/phpmyadmin/phpMyAdmin.conf
cp ../templates/ubuntu1204/phpmyadmin/config.inc.php.template /etc/phpmyadmin/config.inc.php

# Setup PHPMyAdmin variables
echo "$htuser $htpass" > /root/.phpmyadminpass

# Set PHPMyAdmin before htaccess file
htpasswd -b -c /etc/phpmyadmin/phpmyadmin-htpasswd $htuser $htpass

# Symlink in apache config and restart apache
rm -f /etc/apache2/conf.d/phpMyAdmin.conf
ln -s /etc/phpmyadmin/phpMyAdmin.conf /etc/apache2/conf.d/phpMyAdmin.conf
service apache2 restart


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

${lightblue}PHPMyAdmin URL:${nc}  http://$real_ip/phpmyadmin
${lightblue}PHPMyAdmin User:${nc} serverinfo / root
${lightblue}PHPMyAdmin Pass:${nc} $htpass / $mysqlrootpassword

${lightblue}MySQL Root User:${nc}  root 
${lightblue}MySQL Root Pass:${nc}  $mysqlrootpassword

** For security purposes, there is an htaccess file in front of phpmyadmin.
So when the popup window appears, use the serverinfo username and password. 
Once your on the phpmyadmin landing page, use the root MySQL credentials.

If you lose this setup report, the credentails can be found in:
${lightblue}Apache Server Status:${nc}  /root/.serverstatus
${lightblue}PHPMyAdmin:${nc}            /root/.phpmyadmin
${lightblue}MySQL Credentials:${nc}     /root/.my.cnf

${txtbld}---------------------------------------------------------------
                 Nightly MySQL Backups
---------------------------------------------------------------${nc}

MySQL backups are being performed via Holland (www.hollandbackup.org) and
is set to run nightly at 3:30AM server time.  

The critical information about Holland is below:

${lightblue}Backup directory:${nc}  /var/lib/mysqlbackup
${lightblue}Backups run time:${nc}  Nightly at 3:30AM server time
${lightblue}Retention rate:${nc}    7 days

${lightblue}Holland log file:${nc}  /var/log/holland/holland.log
${lightblue}Holland configs:${nc}   /etc/holland/holland.conf
                   /etc/holland/backupsets/default.conf
                   /etc/cron.d/holland

${txtbld}---------------------------------------------------------------${nc}

EOF

cat /root/setup_report
