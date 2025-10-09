# DHCP-Project
This repository is dedicated for DHCP practice 1 in the Network Services and Internet module in ASIR

# Guide to configuring a DHCP Server

This project explains how to set up and configure a **DHCP server** using **Vagrant** and **VirtualBox** with **Ubuntu** machine.
It include one server and two clients (one with a dynamic IP and one with a reserverd IP), all connected via internal private networks.

## Prerequisites

We ensure that these programs are installed:

- VirtualBox
- Vagrant

---

## How to guide
### 1.Prepare the Vagrantfile and the virtual machines
We will open our terminal and write the following commands:
```shell
cd ~/DHCP-Project
vagrant init ubuntu/focal64
```
This will generate an initial ```Vagrantfile``` with Ubuntu OS. We will edit this file for adding three machines (**server**, **c1** and **c2**) with it networks. This is our final fle content:
```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"

  # DHCP Server machine
  config.vm.define "server" do |server|
    server.vm.hostname = "server"

    #host-only network (192.168.56.0/24)
    server.vm.network "private_network", ip: "192.168.56.10" # Host-only

    #internal network (192.168.57.0/24) for DHCP
    server.vm.network "private_network", ip: "192.168.57.10",
      virtualbox__intnet: "intnet" # Internal network

    server.vm.provision "shell", path: "scripts/server_provision.sh"
      echo "Provisioning server..."
    SHELL
  end

  # Client c1 
  config.vm.define "c1" do |c1|
    c1.vm.hostname = "c1"

    # Connected only to the internal network via DHCP
    c1.vm.network "private_network", type: "dhcp",
      virtualbox__intnet: "intnet"

    c1.vm.provision "shell", path: "scripts/client_provision.sh"
      echo "Provisioning c1..."
    SHELL
  end

  # Client c2 
  config.vm.define "c2" do |c2|
    c2.vm.hostname = "c2"

    # Also connected to the internal network via DHCP
    c2.vm.network "private_network", type: "dhcp",
      virtualbox__intnet: "intnet"

    c2.vm.provision "shell", path: "scripts/client_provision.sh"
      echo "Provisioning c2..."
    SHELL
  end
end

```
- In this snippet, the server receives two interfaces: the first one on the host-only network ```192.168.56.0/24``` (static IP ```192.168.56.10```) and the second on the internal network ```192.168.57.0/24``` (IP ```192.168.57.10```, where it will listen for DHCP). The clients ```c1``` and ```c2``` connect to the same internal network using DHCP (type: "dhcp"), so they will get their IP addresses from the server.

### 2.Configure the DHCP server
Once the vagrant file is created and the three machines have booted up, we will enter the 'server' machine writting the command: ```vagrant ssh server``` we will check the 3 interfaces with ```ip a ``` command. We will see something like this:

- ```enp0s3```: Vagrant NAT - for internet
- ```enp0s8```: Host-only: it communicate with the admin
- ```enp0s9```: Internal isolated DHCP Network

*The interface name might change*

#### 1- Install the DHCP service
We will type:
```shell
sudo apt update
sudo apt install -y isc-dhcp-server
```
After that, we will edit ```/etc/default/isc-dhcp-server``` And we modify ```INTERFACESv4="[*The interface name*]"``` in a way that the DHCP demon, listen in the network ```192.168.57.0/24```

#### 2- Configure directions range:
We make a security copy of the principal configuration file:
``` bash
sudo cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.bak
sudo nano /etc/dhcp/dhcpd.conf
```
We add a subnet section just like the next one:

```shell
subnet 192.168.57.0 netmask 255.255.255.0 {
range 192.168.57.25 192.168.57.50;
option broadcast-address 192.168.57.255;
option routers 192.168.57.10;
option domain-name-servers 8.8.8.8, 4.4.4.4;
default-lease-time 86400; # 1 día
max-lease-time 691200; # 8 días
option domain-name "micasa.es";
}
```
We reboot the service:
```shell
sudo systemctl restart isc-dhcp-server
```
#### 3- Keeping a fixed IP address for c2
In the same ```/etc/dhcp/dhcpd.conf``` We will add at the end a host entry, with C2 mask (we can obtain it by typing ```ip a``` in the C2 VM)


```shell
host c2 {
hardware ethernet 08:00:27:ae:79:7c; # This is my personal MAC address
fixed-address 192.168.57.4;
default-lease-time 3600; # 1 hora
option domain-name-servers 1.1.1.1;
}
```
Once this is done, our server will be ready. It will assign dinamic IPs in the .25-.50 range to every new client and will assign .4 only to C2.

### 3.Configure the clients and verify
Now we will configure c1 and c2 for obtaining an IP adrees by DHCP in the network:

#### C1 Client
We enter to C1 Client and we type ```sudo dhclient```. After that, ```ip a``` must show that c1 has an IP in 192.168.57.25-50. 

#### C2 Client
As same as C1 client, we type ```sudo dhclient``` and it should obtain the IP 192.168.57.4. We check with ```ip a```.

Finally, we can revise in the server the DHCP leases file:
```sudo cat /var/lib/dhcp/dhcpd.leases```








