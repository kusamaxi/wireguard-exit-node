#!/bin/bash

# Innernet network settings
network_name="rotkonet"
network_cidr="10.42.0.0/16"
external_endpoint="127.0.0.1"
listen_port=51820

# Subnet settings
subnet_name="xi"
subnet_cidr="10.42.1.0/24"
subnet_nodes=("xi01" "xi02")

# Homenet settings
homenet_name="pc"
homenet_cidr="10.42.2.0/24"
homenet_nodes=("pc01" "pc02")

# Function to create a new innernet network
function create_network {
  echo "Creating new innernet network:"
  echo "    Network name: $network_name"
  echo "    Network CIDR: $network_cidr"
  echo "    External endpoint: $external_endpoint"
  echo "    Listen port: $listen_port"
  echo ""
  echo "Press enter to continue, or ctrl-c to cancel"
  read _

  # create private network
  innernet-server new --network-name "$network_name" --network-cidr "$network_cidr" --external-endpoint "$external_endpoint" --listen-port "$listen_port"
}

# Function to create subnet peers
function create_subnet_peers {
  # create subnet
  innernet-server add-cidr --name "$subnet_name" --cidr "$subnet_cidr" --yes "$network_name"

  # loop through subnet nodes
  for node in "${subnet_nodes[@]}"; do
    peer_name="$subnet_name-$node"

    # create peer and save config
    innernet-server add-peer "$network_name" --auto-ip --name "$node" --save-config "/opt/innernet/$peer_name.toml" --yes
  done
}

# Function to create homenet peers
function create_homenet_peers {
  # create homenet
  innernet-server add-cidr --name "$homenet_name" --cidr "$homenet_cidr" --yes "$network_name"

  # loop through homenet nodes
  for node in "${homenet_nodes[@]}"; do
    peer_name="$homenet_name-$node"

    # create peer and save config
    innernet-server add-peer "$network_name" --auto-ip --name "$node" --save-config "/opt/innernet/$peer_name.toml" --yes
  done
}

# Main script

# Check if innernet-server is installed
if ! command -v innernet-server &> /dev/null
then
    echo "innernet-server is not installed. Please install it first."
    exit 1
fi

# Check if user is running the script as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# Create the innernet network
create_network

# Create subnet peers
create_subnet_peers

# Create homenet peers
create_homenet_peers

echo "Done!"
