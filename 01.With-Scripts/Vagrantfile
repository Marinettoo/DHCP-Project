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