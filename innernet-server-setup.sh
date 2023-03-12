#!/bin/bash

network_name="rotkonet"
network_cidr="10.42.0.0/16"

# subnet
subnet_name="xi"
subnet_nodes=(01 02)
subnet_cidr="10.42.1.0/24"

# homenet
homenet_name="pc"
homenet_name=(01 02)
homenet_cidr="10.42.1.0/24"

external_endpoint=$(ip a | grep "inet " | awk '{print $2}' | cut -d '/' -f1):51820
auto_external_endpoint=false
listen_port=51820

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    --network-name)
    network_name="$2"
    shift
    shift
    ;;
    --network-cidr)
    network_cidr="$2"
    shift
    shift
    ;;
    --external-endpoint)
    external_endpoint="$2"
    shift
    shift
    ;;
    --auto-external-endpoint)
    auto_external_endpoint=true
    shift
    ;;
    --listen-port)
    listen_port="$2"
    shift
    shift
    ;;
    -h|--help)
    echo "Usage: $0 [--network-name NETWORK_NAME] [--network-cidr NETWORK_CIDR] [--external-endpoint EXTERNAL_ENDPOINT] [--auto-external-endpoint] [--listen-port LISTEN_PORT]"
    exit 0
    ;;
    *)
    echo "Unknown option: $1"
    echo "Usage: $0 [--network-name NETWORK_NAME] [--network-cidr NETWORK_CIDR] [--external-endpoint EXTERNAL_ENDPOINT] [--auto-external-endpoint] [--listen-port LISTEN_PORT]"
    exit 1
    ;;
esac
done

if [ "$auto_external_endpoint" = true ]; then
    external_endpoint=$(ip a | grep "inet " | awk '{print $2}' | cut -d '/' -f1):51820
fi

echo "Usage: $0 [--network-name NETWORK_NAME] [--network-cidr NETWORK_CIDR] [--external-endpoint EXTERNAL_ENDPOINT] [--auto-external-endpoint] [--listen-port LISTEN_PORT]"
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

# create subnet
innernet-server add-cidr --name "$subnet_name" --cidr "$subnet_cidr" --yes "$network_name"
# loop through subnet
for node in "${subnet_nodes[@]}"; do
  innernet-server add-peer "$network_name" --auto-ip --name "$node"
done

# create homenet
innernet-server add-cidr --name "$homenet_name" --cidr "$homenet_cidr" --yes "$network_name"
# loop through homenet
for node in "${subnet_nodes[@]}"; do
  innernet-server add-peer "$network_name" --auto-ip --name "$node"
done
