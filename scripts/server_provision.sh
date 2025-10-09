#!/bin/bash
# Stop execution if any command fails
set -e

echo "Installing DHCP server..."
apt update -y
apt install -y isc-dhcp-server net-tools iproute2

# Detect internal network interface (with 192.168.57.x)
INTERFACE=$(ip -o -4 addr show | awk '/192\.168\.57\./ {print $2}')
sed -i "s/^INTERFACESv4=.*/INTERFACESv4=\"$INTERFACE\"/" /etc/default/isc-dhcp-server

# Backup original configuration
cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.bak

# Write DHCP configuration
cat > /etc/dhcp/dhcpd.conf <<EOF
default-lease-time 86400;
max-lease-time 691200;
authoritative;

subnet 192.168.57.0 netmask 255.255.255.0 {
  range 192.168.57.25 192.168.57.50;
  option routers 192.168.57.10;
  option broadcast-address 192.168.57.255;
  option domain-name-servers 8.8.8.8, 4.4.4.4;
  option domain-name "home.local";
}

# Fixed IP for client c2
host c2 {
  hardware ethernet 08:00:27:aa:bb:cc;
  fixed-address 192.168.57.31;
  option domain-name-servers 1.1.1.1;
  default-lease-time 3600;
}
EOF

# Restart and enable DHCP service
systemctl restart isc-dhcp-server
systemctl enable isc-dhcp-server

echo "DHCP server installed and running:"
systemctl status isc-dhcp-server --no-pager
