#!/bin/sh

yum -y install jq
yum -y install curl
yum -y install git

bash /root/scan/create_bleeping.sh
service bleeping status
