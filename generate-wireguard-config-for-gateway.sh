#!/bin/bash
# Script to generate a WireGuard configuration file for an exit node and all peer nodes.
# Designed to be initiated at exit node for traffic.
# Usage: ./generate-wireguard-config-for-gateway.sh [<ipv4_address> <ipv6_address>]
# Example:
#  ./generate-wireguard-config-for-gateway.sh 1.1.1.1 2a02:4780:bad:f00d::1

# Function to generate the configuration for each peer
function generate_peer_config {
  local node_name=$1
  local peer_public_key=$2
  local peer_ip_address="10.0.0.$(( $(echo $node_name | sed 's/[^0-9]*//g') + 1))"
  cat << EOF
# Peer: $node_name
[Peer]
PublicKey = $peer_public_key
AllowedIPs = $peer_ip_address/32
Endpoint = $exit_public_ipv4:51820
PersistentKeepalive = 25
EOF
}

# Function to generate the WireGuard configuration file
function generate_wireguard_config {
  local exit_hostname=$(hostname)
  local exit_private_key=$(wg genkey)
  local exit_public_key=$(echo "$exit_private_key" | wg pubkey)
  cat << EOF > /etc/wireguard/wg0.conf
[Interface]
PrivateKey = $exit_private_key
Address = 10.0.0.1/24
ListenPort = 51820

EOF
  for public_key_file in /etc/wireguard/*.public; do
    local node_name=$(basename "${public_key_file%.*}")
    if [ "$node_name" != "$exit_hostname" ]; then
      local peer_public_key=$(cat "$public_key_file")
      cat << EOF >> /etc/wireguard/wg0.conf
$(generate_peer_config "$node_name" "$peer_public_key")
EOF
    fi
  done
}

# Function to print the usage message
function print_usage {
  echo "Usage: $0 [<ipv4_address> <ipv6_address>]"
  echo ""
  echo "Generates a WireGuard configuration file for an exit node and all peer nodes."
  echo "Designed to be initiated at exit node for traffic."
  echo ""
  echo "Arguments:"
  echo "  ipv4_address: (optional) The public IPv4 address of the exit node. Default: 103.29.69.245"
  echo "  ipv6_address: (optional) The public IPv6 address of the exit node. Default: 2400:8902::f03c:93ff:fe32:e12d"
}

# Print usage message if the number of arguments is incorrect
if [ $# -gt 2 ]; then
  print_usage
  exit 1
fi

# Set default IP addresses if not provided
exit_public_ipv4="${1:-103.29.69.245}"
exit_public_ipv6="${2:-2400:8902::f03c:93ff:fe32:e12d}"

# Generate the WireGuard configuration file
generate_wireguard_config

echo "WireGuard configuration generated at /etc/wireguard/wg0.conf"
