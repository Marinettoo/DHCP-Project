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

    # – First interface: host-only network (192.168.56.0/24)
    server.vm.network "private_network", ip: "192.168.56.10" # Host-only

    # – Second interface: internal network (192.168.57.0/24) for DHCP
    server.vm.network "private_network", ip: "192.168.57.10",
      virtualbox__intnet: "intnet" # Internal network

    server.vm.provision "shell", inline: <<-SHELL
      # Here you can include provisioning commands for the server
      echo "Provisioning server..."
    SHELL
  end

  # Client c1 (Dynamic IP from DHCP in the internal network)
  config.vm.define "c1" do |c1|
    c1.vm.hostname = "c1"

    # Connected only to the internal network via DHCP
    c1.vm.network "private_network", type: "dhcp",
      virtualbox__intnet: "intnet"

    c1.vm.provision "shell", inline: <<-SHELL
      echo "Provisioning c1..."
    SHELL
  end

  # Client c2 (Static IP via DHCP by MAC address)
  config.vm.define "c2" do |c2|
    c2.vm.hostname = "c2"

    # Also connected to the internal network via DHCP
    c2.vm.network "private_network", type: "dhcp",
      virtualbox__intnet: "intnet"

    c2.vm.provision "shell", inline: <<-SHELL
      echo "Provisioning c2..."
    SHELL
  end
end

```
- In this snippet, the server receives two interfaces: the first one on the host-only network ```192.168.56.0/24``` (static IP ```192.168.56.10```) and the second on the internal network ```192.168.57.0/24``` (IP ```192.168.57.10```, where it will listen for DHCP). The clients ```c1``` and ```c2``` connect to the same internal network using DHCP (type: "dhcp"), so they will get their IP addresses from the server.

### 2.Configure the DHCP server
Once the vagrant file is created and the three machines have booted up, we will enter the server machine writting the command: ```vagrant ssh server``` we will check the 3 interfaces with ```ip a ``` command. We will see something like this:

- ```enp0s3```: Vagrant NAT - for internet
- ```enp0s8```: Host-only: it communicate with the admin
- ```enp0s9```: Internal isolated DHCP Network



