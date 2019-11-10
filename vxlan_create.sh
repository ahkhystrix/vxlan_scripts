#/bin/bash

if [ $# -lt 3 ]
then
  echo "Usage: vxlan.sh <HOST_INTERFACE> <VXLAN_IP/PREFIX> <REMOTE_HOSTs_IP>"
  exit 1
fi

# Vxlan interface by default - vxlan50
VXLAN_ID=50
VXLAN_INTERFACE="vxlan$VXLAN_ID"

VXLAN_CHECK=`ip link show type vxlan | grep $VXLAN_INTERFACE: -c`
if [ $VXLAN_CHECK -ne 0 ]
then
  echo "Error: Interface $VXLAN_INTERFACE exists!"
  exit 1
fi

# Vxlan Port by default - 4789
VXLAN_PORT=4789

# Create Vxlan Interface
ip link add $VXLAN_INTERFACE type vxlan id $VXLAN_ID dev $1 dstport $VXLAN_PORT

# Append FDB Bridge
for ip in "${@:3}"
do
  bridge fdb append to 00:00:00:00:00:00 dst $ip dev $VXLAN_INTERFACE
done

# Set IP-address for Vxlan Interface
ip addr add $2 dev $VXLAN_INTERFACE

# Set Vxlan Interface to UP
ip link set $VXLAN_INTERFACE up

