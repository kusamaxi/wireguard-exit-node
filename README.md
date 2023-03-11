# Deprecated, while installing wireguard to my machines to initiate scripts, I found much more robust software for the task in aur repositories. [innernet](https://github.com/tonarino/innernet)

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


## Usage
Install first client.sh script at your private machines and servers.
Script uses hostnames for assigning private network ip address so you need to name your hostname with
a 2 digit number like this for scripts to work without modifications.
```
sudo nano /etc/hostname > example01
sudo hostname example01
```
now scripts assign ip address 10.0.0.2 for this since its last number of hostname is (n+1).
Gateway/exit nodes ip address will always be 10.0.0.1 in internal network.
this fit for my needs, pull requests for better design are welcome.

After you have ins[]talled these client side scripts you need gateway/exit node.
Purchase vm/dedicated server from cloud provider within 50ms and install gateway.sh script on it. 
My choice for this example was linode 2vcpu dedicated server from tokyo since I don't
like to be sharing my CPU core. 
