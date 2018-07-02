## Bash Lamp Installer

LAMP installer setting up Apache, PHP, MySQL, Holland and attempts to set some sane defaults

### Purpose

There are many LAMP installation scripts floating around the internet.  This is simply just another one to add to the mix.  It is customized to fit the majority of the use cases I run into, and should be ready for use right out of the box.  

### Supported OS's

Currently this LAMP installer supports
- CentOS 6 / Red Hat ES 6
- CentOS 7 / Red Hat ES 7
- Ubuntu 12.04
- Ubuntu 14.04
- Ubuntu 16.04
- Ubuntu 18.04 (Beta)

### Package Versions Installed

It is important to note that for the CentOS and Red Hat operating systems, the installer makes use of the IUS repository in order to get the updated versions of PHP and MySQL.  

The specific packages and their associated versions are shown in the table below for each operating system.  The packages that deviate from the distro's default packages are denoted with IUS accordingly:

| CentOS 6 / RHEL 6 | CentOS 7 / RHEL 7 | Ubuntu 12.04 | Ubuntu 14.04 | Ubuntu 16.04 | Ubuntu 18.04 |
| ----------------- | ----------------- | ------------ | ------------ | ------------ | ------------ |
| Apache 2.2        | Apache 2.4        | Apache 2.2   | Apache 2.4   | Apache 2.4   | Apache 2.4   |
| PHP 5.6 (IUS)     | PHP 5.6 (IUS)     | PHP 5.3      | PHP 5.5      | PHP 7.0      | PHP 7.2      |
| MySQL 5.5 (IUS)   | MariaDB 5.5       | MySQL 5.5    | MySQL 5.5    | MySQL 5.7    | MySQL 5.7    |

### Additional Software Installed

The following additional software packages are installed:

| Package              | Purpose                                    |
| -------------------- | ------------------------------------------ |
| Holland              | Performs nightly MySQL dumps of database   |
| PHPMyAdmin           | Graphical interface for working with MySQL |
| Sysstat              | Logs historical system information via sar |

### Implementation

This should only be ran on fresh, base installation of the operating system.  If a LAMP installation already exists or if this server is already being used for other tasks, this script will likely break your server!  You have been warned!

Download and setup the LAMP stack by:

	cd /root
	git clone https://github.com/stephenlang/bash-lamp-installer
	cd bash-lamp-installer
	bash install_lamp.sh

Once the installer is done, you will receive a setup report that will contain the details of the setup.  An example of this is shown below:

	---------------------------------------------------------------
	                 LAMP Installation Complete
	---------------------------------------------------------------

	The LAMP installation has been completed!  Some important information is
	posted below.  A copy of this setup report exists in /root/setup_report.


	---------------------------------------------------------------
	                 Security Credentials
	---------------------------------------------------------------

	Apache Server Status URL:   http://xxx.xxx.xxx.xxx/server-status
	Apache Server Status User:  serverinfo
	Apache Server Status Pass:  **************

	PHPMyAdmin URL:  http://xxx.xxx.xxx.xxx/phpmyadmin
	PHPMyAdmin User: serverinfo / root
	PHPMyAdmin Pass: ************** / **************

	MySQL Root User:  root 
	MySQL Root Pass:  **************

	** For security purposes, there is an htaccess file in front of phpmyadmin.
	So when the popup window appears, use the serverinfo username and password. 
	Once your on the phpmyadmin landing page, use the root MySQL credentials.

	If you lose this setup report, the credentails can be found in:
	Apache Server Status:  /root/.serverstatus
	PHPMyAdmin:            /root/.phpmyadmin
	MySQL Credentials:     /root/.my.cnf

	---------------------------------------------------------------
	                 Nightly MySQL Backups
	---------------------------------------------------------------

	MySQL backups are being performed via Holland (www.hollandbackup.org) and
	is set to run nightly at 3:30AM server time.  

	The critical information about Holland is below:

	Backup directory:  /var/lib/mysqlbackup
	Backups run time:  Nightly at 3:30AM server time
	Retention rate:    7 days

	Holland log file:  /var/log/holland/holland.log
	Holland configs:   /etc/holland/holland.conf
	                   /etc/holland/backupsets/default.conf
	                   /etc/cron.d/holland
	
	---------------------------------------------------------------

