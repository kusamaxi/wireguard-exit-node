#!/bin/bash
# Script to generate a WireGuard configuration file for an exit node and all peer nodes.
# Designed to be initiated at exit node for traffic.

# Function to generate the configuration for each peer
function generate_peer_config {
  local node_name=$1
  local peer_public_key=$2
  local peer_ip_address=$3
  cat << EOF
# Peer: $node_name
[Peer]
PublicKey = $peer_public_key
AllowedIPs = $peer_ip_address/32
EOF
  if [ -n "$exit_public_ipv6" ]; then
    cat << EOF
Endpoint = $exit_public_ipv4:51820,[$exit_public_ipv6]:51820
EOF
  else
    cat << EOF
Endpoint = $exit_public_ipv4:51820
EOF
  fi
  cat << EOF
PersistentKeepalive = 25
EOF
}

# Function to generate the WireGuard configuration file
function generate_wireguard_config {
  local exit_private_key=$(wg genkey)
  local exit_public_key=$(echo "$exit_private_key" | wg pubkey)
  wg pubkey < /etc/wireguard/gw00.key > /etc/wireguard/gw00.public
  cat << EOF > /etc/wireguard/gw00.conf
[Interface]
PrivateKey = $exit_private_key
Address = 10.42.0.1/16
ListenPort = 51820

EOF
  for public_key_file in /etc/wireguard/*.public; do
    local node_name=$(basename "${public_key_file%.*}")
    if [ "$node_name" == "xi01" ]; then
      local peer_public_key=$(cat "$public_key_file")
      cat << EOF >> /etc/wireguard/gw00.conf
$(generate_peer_config "$node_name" "$peer_public_key" "10.42.1.1")
EOF
    elif [ "$node_name" == "xi02" ]; then
      local peer_public_key=$(cat "$public_key_file")
      cat << EOF >> /etc/wireguard/gw00.conf
$(generate_peer_config "$node_name" "$peer_public_key" "10.42.1.2")
EOF
    fi
  done
}

# Generate the WireGuard configuration file
exit_public_ipv4=$(ip a | awk '/inet / && !/127.0.0.1/ { sub(/\/.*/, "", $2); print $2; exit }')
exit_public_ipv6=$(ip a | awk '/inet6 / && !/::1/ { sub(/\/.*/, "", $2); print $2; exit }')
generate_wireguard_config

echo "WireGuard configuration generated at /etc/wireguard/gw00.conf"
