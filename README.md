
# Generate VLAN using Wireguard
In this repository we learn how to use scripts to set up Wireguard between private network
of computers and then configure clients to reroute their SSH ports exposing them to WAN
through exit node gateway. This enables also us to host blockchain validators that 
require p2p traffic 

Original problem what initiate creation of these set of scripts was language barrier with
Japanese ISP to provide me access to home router. After a few days nuking the modem with
jack the ripper without access granted I came up with idea of creating virtual private network
and using routing tables to route traffic from polkadot/kusama p2p ports to
be exposed through close by dedicated server from Linode to Internet.

Target of all this work is to provide easy as possible tools for anyone to purchase bare metal
hardware and became validating the new financial/power structures. Current issue is that these
systems are total silos for only in reach of technically talented people and will this way
lead to just another possibly even worse system over time due to inequality.


## Install
original wireguard scripts are deprecated and we chose to use
[innernet](https://github.com/tonarino/innernet) for VPN management.  
dl chmod and execute ./innernet-install.sh

for arch
```
git clone https://github.com/kusamaxi/wireguard-exit-node && chmod +x wireguard-exit-node/innernet-install-arch.sh && sudo ./wireguard-exit-node/innernet-install-arch.sh
```

for others
```
git clone https://github.com/kusamaxi/wireguard-exit-node && chmod +x wireguard-exit-node/innernet-install-cargo.sh && sudo ./wireguard-exit-node/innernet-install-cargo.sh
```
## Usage
at clients
`innernet --help`
at server
```bash
innernet-server --help
sudo innernet-server new```
