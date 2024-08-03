#!/usr/bin/env bash

# install_lamp.sh 
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


# Detect OS and run associated script

if [ -f /etc/redhat-release ]; then

        if [ `cat /etc/redhat-release |grep -c "release 6"` -eq 1 ]; then
		cd scripts
                bash centos6_rhel6_install_lamp.sh

        elif [ `cat /etc/redhat-release | grep -c "release 7"` -eq 1 ]; then
		cd scripts
                bash centos7_rhel7_install_lamp.sh

        elif [ `cat /etc/redhat-release | grep -c "release 8"` -eq 1 ]; then
                cd scripts
                bash centos8_rhel8_install_lamp.sh

        else
                echo "Unsupported operating system"
        fi
fi

if [ -f /etc/lsb-release ]; then

        if [ `cat /etc/lsb-release | grep -c "RELEASE=12"` -eq 1 ]; then
		cd scripts
                bash ubuntu1204_install_lamp.sh

        elif [ `cat /etc/lsb-release | grep -c "RELEASE=14"` -eq 1 ]; then
                cd scripts
		bash ubuntu1404_install_lamp.sh

        elif [ `cat /etc/lsb-release | grep -c "RELEASE=16"` -eq 1 ]; then
                cd scripts
		bash ubuntu1604_install_lamp.sh

        elif [ `cat /etc/lsb-release | grep -c "RELEASE=18"` -eq 1 ]; then
                cd scripts
                bash ubuntu1804_install_lamp.sh

        elif [ `cat /etc/lsb-release | grep -c "RELEASE=20"` -eq 1 ]; then
                cd scripts
                bash ubuntu2004_install_lamp.sh
		
        else
                echo "Unsupported operating system"
        fi
fi

if [ -f /etc/os-release ]; then
        . /etc/os-release

        if [[ "$ID" == "debian" && "$VERSION_ID" == "12" ]]; then
                cd scripts
                bash debian12_install_lamp.sh
        else
                echo "Unsupported operating system" 
        fi
fi
