#!/bin/bash

network_name="parent"
network_cidr="10.42.0.0/16"
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

innernet-server new --network-name "$network_name" --network-cidr "$network_cidr" --external-endpoint "$external_endpoint" --listen-port "$listen_port"
innernet-server add-cidr "$network_name"
innernet-server add-peer "$network_name"

