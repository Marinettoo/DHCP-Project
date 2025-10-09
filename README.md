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

## Project Structure

DHCP
- Vagrantfile
- provisioning
  - setup-server.sh
  - setup-client.sh
- dhcp-conf
  - dhcpd.conf
- README.md

