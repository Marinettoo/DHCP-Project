Vagrant.configure("2") do |config|
config.vm.box = "ubuntu/focal64"
# Máquina servidor DHCP
config.vm.define "server" do |server|
server.vm.hostname = "server"
# – Primera interfaz: red host-only (192.168.56.0/24)
server.vm.network "private_network", ip: "192.168.56.10" # Host-only
# – Segunda interfaz: red interna (192.168.57.0/24) para DHCP
server.vm.network "private_network", ip: "192.168.57.10",
virtualbox__intnet: "intnet" # Red interna
server.vm.provision "shell", inline: <<-SHELL
# Aquí se pueden incluir comandos de aprovisionamiento del servidor
echo "Provisioning server..."
SHELL
end
# Cliente c1 (IP dinámica desde DHCP en la red interna)
config.vm.define "c1" do |c1|
c1.vm.hostname = "c1"
# Conectamos solo a la red interna por DHCP
c1.vm.network "private_network", type: "dhcp",
virtualbox__intnet: "intnet"
c1.vm.provision "shell", inline: <<-SHELL
echo "Provisioning c1..."
SHELL
end
# Cliente c2 (IP fija vía DHCP por MAC)
config.vm.define "c2" do |c2|
c2.vm.hostname = "c2"
# También en la red interna por DHCP
c2.vm.network "private_network", type: "dhcp",
virtualbox__intnet: "intnet"
1
c2.vm.provision "shell", inline: <<-SHELL
echo "Provisioning c2..."
SHELL
end
end
