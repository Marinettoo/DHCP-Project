# DHCP-Project
This repository is dedicated for DHCP practice 1 in the Network Services and Internet module in ASIR

# Guide to configuring a DHCP Server

This project explains how to set up and configure a **DHCP server** using **Vagrant** and **VirtualBox** with **Ubuntu** machine.
It include one server and two clients (one with a dynamic IP and one with a reserverd IP), all connected via internal private networks.

## Requisitos Previos

We ensure that these programs are installed:

- VirtualBox
- Vagrant

---

## Project Structure

| Folder / File       | Description |
|--------------------------|-------------|
| `Vagrantfile`            | Main configuration file for launching virtual machines with Vagrant. |
| `provisioning/`          | Contains automated configuration scripts. |
| `setup-server.sh`        | Script to configure the DHCP server. |
| `setup-client.sh`        | Script to configure the DHCP client. |
| `dhcp-conf/`             | Contains the configuration files for the DHCP service.. |
| `dhcpd.conf`             | Main configuration file for the DHCP daemon. |
| `README.md`              | Project Documentation. |

