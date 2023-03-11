#!/bin/bash
# Script to generate and upload a WireGuard public key to a remote server
# and configure the client to join the private network.
#
# Warning: If you do not have root access to the remote server, you are required
# to set dedicated user permissions to write to the /etc/wireguard 
# directory, and then use that user's credentials to establish the SSH 
# connection and transfer the files.


# Function to generate the WireGuard public key
function generate_wireguard_key {
  local private_key=$(wg genkey)
  local public_key=$(echo "$private_key" | wg pubkey)
  echo "$public_key"
}

# Print usage message if the number of arguments is incorrect
if [ $# -ne 1 ]; then
  echo "Usage: $0 <username@hostname>"
  exit 1
fi

# Set the remote server target
remote_server=$1

# Get the local hostname
hostname=$(hostname)

# Create temporary file for public key
tmpfile=$(mktemp)
echo "$public_key" > "$tmpfile"

# Upload the public key to the remote server using SCP
scp "$tmpfile" "${remote_server}:/etc/wireguard/${hostname}.public"

# Delete temporary file
rm "$tmpfile"


# Configure the client to join the private network
sudo tee /etc/wireguard/wg0.conf > /dev/null << EOF
[Interface]
PrivateKey = $(wg genkey)
Address = 10.0.0.2/24
DNS = 8.8.8.8

[Peer]
PublicKey = $(cat "/etc/wireguard/${remote_server##*@}.public")
Endpoint = $(ssh "$remote_server" 'ip a | awk '\''/inet / && !/127.0.0.1/ { sub(/\/.*/, "", $2); print $2; exit }'\'''):51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF

# Start the WireGuard service on the client machine
sudo systemctl enable wg-quick@wg0.service
sudo systemctl start wg-quick@wg0.service

echo "WireGuard configuration complete. You should now be able to access the private network."
