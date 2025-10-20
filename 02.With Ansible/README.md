# DHCP Project — 02. With Ansible

This project explains how to set up and configure a **DHCP server** using **Vagrant + VirtualBox + Ubuntu** with **Ansible** for provisioning.  
It includes one server and two clients (one with a dynamic IP and one with a reserved IP), all connected via an internal private network.

---

## Prerequisites
Make sure the following programs are installed on your host machine:

- VirtualBox  
- Vagrant  
- Ansible

---

## How to guide

### 1. Prepare the Vagrantfile and the virtual machines
Open a terminal and go to the project folder (eaxmple `~/DHCP-Project/02.With Ansible`). Create or edit the `Vagrantfile` so it contains the following:

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

  end

  # Client c1 
  config.vm.define "c1" do |c1|
    c1.vm.hostname = "c1"

    # Connected only to the internal network via DHCP
    c1.vm.network "private_network", type: "dhcp",
      virtualbox__intnet: "intnet"

  end

  # Client c2 
  config.vm.define "c2" do |c2|
    c2.vm.hostname = "c2"

    # Also connected to the internal network via DHCP
    c2.vm.network "private_network", type: "dhcp",
      virtualbox__intnet: "intnet"

  end
end
```

Bring the machines up:

```bash
vagrant up
```

Vagrant will create the three VMs and expose SSH ports for each VM (used by the Ansible inventory).

---

### 2. Inventory and Ansible configuration
The repository provides an `inventory.yaml` and `ansible.cfg` prepared to connect to the Vagrant VMs.

`inventory.yaml`:

```yaml
all:
  vars:
    ansible_user: vagrant
    ansible_python_interpreter: /usr/bin/python3

  children:
    server:
      hosts:
        server:
          ansible_host: 127.0.0.1
          ansible_port: 2222
          ansible_private_key_file: .vagrant/machines/server/virtualbox/private_key

    clients:
      hosts:
        c1:
          ansible_host: 127.0.0.1
          ansible_port: 2200
          ansible_private_key_file: .vagrant/machines/c1/virtualbox/private_key
        c2:
          ansible_host: 127.0.0.1
          ansible_port: 2201
          ansible_private_key_file: .vagrant/machines/c2/virtualbox/private_key
```

`ansible.cfg` :

```
[defaults]
inventory = ./inventory.yaml
remote_user = vagrant
private_key_file = insecure_private_key
host_key_checking = False
interpreter_python = auto_silent
deprecation_warnings = False
```

> Note: `ansible_private_key_file` in the inventory points to the private keys created by Vagrant under `.vagrant/machines/...`. `ansible.cfg` points to `inventory.yaml` and disables host key checking for convenience.

---

### 3. Configure the DHCP server (Ansible-managed)
The DHCP configuration file used by the playbook is located at `playbooks/files/dhcpd.conf`. Its content shoudl be something like this:

```
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

host c2 {
  hardware ethernet 08:00:27:aa:bb:cc;
  fixed-address 192.168.57.31;
  option domain-name-servers 1.1.1.1;
  default-lease-time 3600;
}
```

`playbooks/server-playbook.yaml` installs the DHCP server, sets the interface to listen, copies the `dhcpd.conf`, and restarts the service:

```yaml
---
- name: configurar el servidor DHCP
  hosts: server
  become: true
  tasks:
    - name: instalar DHCP y herramientas de red
      apt:
        name: isc-dhcp-server,net-tools,iproute2
        state: present
        update_cache: yes

    - name: configurar interfaz del DHCP
      lineinfile:
        path: /etc/default/isc-dhcp-server
        regexp: '^INTERFACESv4='
        line: 'INTERFACESv4="eth2"'  # comprobamos con ip a

    - name: Copiar configuración dhcpd.conf
      copy:
        src: files/dhcpd.conf
        dest: /etc/dhcp/dhcpd.conf
        owner: root
        group: root
        mode: '0644'

    - name: Reiniciar el servicio DHCP
      service:
        name: isc-dhcp-server
        state: restarted
        enabled: yes
```

---

### 4. Configure the clients
`playbooks/clients_playbook.yaml` installs the client tools and run `dhclient`:

```yaml
---
- name: configurar clientes DHCP
  hosts: clients
  become: true #convierte en sudoer a qn lo ejecute
  tasks:
    - name: instalar cliente DHCP y herramientas
      apt:
        name: isc-dhcp-client,net-tools,iproute2
        state: present
        update_cache: yes

    - name: solicitar IP al servidor DHCP
      command: dhclient -v
```

When the clients playbook runs, each client will request an IP from the DHCP server. `c1` will obtain a dynamic IP from the range `25-50`. `c2` will get the reserved address `31` (associated with MAC `08:00:27:aa:bb:cc`).

---

### 5. Run the playbooks and verify

1. Start Vagrant machines:

```bash
vagrant up
```

2. Run the server playbook:

```bash
ansible-playbook -i inventory.yaml playbooks/server-playbook.yaml
```

3. Run the clients playbook:

```bash
ansible-playbook -i inventory.yaml playbooks/clients_playbook.yaml
```

4. Verify on the server:

```bash
vagrant ssh server
ip a                # check the interface name!!!!
sudo systemctl status isc-dhcp-server
sudo cat /etc/dhcp/dhcpd.conf
sudo cat /var/lib/dhcp/dhcpd.leases
exit
```

5. Verify on clients:

```bash
vagrant ssh c1
ip a   # should show an address in 192.168.57.25-192.168.57.50
exit

vagrant ssh c2
ip a   # should show the ip 192.168.57.31
exit
```

---

## demostration of operation

```bash
# 1) Bring up the VMs
vagrant up

# 2) Configure the server with Ansible
ansible-playbook -i inventory.yaml playbooks/server-playbook.yaml

# Quick check on server:
vagrant ssh server
ip a
sudo systemctl status isc-dhcp-server
sudo cat /etc/dhcp/dhcpd.conf
sudo cat /var/lib/dhcp/dhcpd.leases
exit

# 3) Configure clients so they request DHCP
ansible-playbook -i inventory.yaml playbooks/clients_playbook.yaml

# Check clients:
vagrant ssh c1
ip a   
exit

vagrant ssh c2
ip a   
exit

# 4) Final check of leases on the server:
vagrant ssh server
sudo cat /var/lib/dhcp/dhcpd.leases
exit
```

**result:**  
- In `c1`, if we wrtie `ip a` command, we should se a line which says: `inet 192.168.57.26/24 brd 192.168.57.255 scope global dynamic` 

- In `c2` the IP address is exactly 192.168.57.31, the reserved in the dhcpd.conf file.



