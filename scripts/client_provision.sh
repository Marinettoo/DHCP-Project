#!/bin/bash

#If any command fails, we stop the execution
set -e

#Update client and netfork tools
apt update -y
apt install -y net-tools iproute2 isc-dhcp-client

#We show the interfaces for checking that everything has goen ok
echo "Client has been configured succesfuly"
dhclient -v
ip a
