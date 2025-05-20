#!/bin/sh

IFACE="eth0.2"
WISDM_SERVERS="172.104.6.188 remonteiot.com google.com"

echo "===== Centegix Gateway Connectivity Check ====="
echo "Running on $(cat /etc/hostname 2>/dev/null || echo unknown) at $(date)"

# Step 1: Interface status
IF_STATUS=$(ifconfig $IFACE 2>/dev/null | grep -q "RUNNING" && echo "UP" || echo "DOWN")
echo
echo "1. Interface $IFACE status: $IF_STATUS"

# Step 2: IP address (BusyBox-safe with awk)
IP_ADDR=$(ifconfig $IFACE | grep 'inet addr:' | grep -v '169.254' | awk -F: '{print $2}' 
| awk '{print $1}')
if [ -n "$IP_ADDR" ]; then
  echo "2. IP address on $IFACE: $IP_ADDR"
else
  echo "2. IP address on $IFACE: Not found"
fi

# Step 3: DHCP or Static
echo
echo "3. IP Assignment Type:"
if ps | grep -q "[u]dhcpc.*$IFACE"; then
  echo "   $IFACE is using DHCP (udhcpc is active)"
else
  echo "   $IFACE is likely using a static IP"
fi

# Step 4: Default Gateway and Ping Test
GW=$(ip route | grep "^default.*$IFACE" | awk '{print $3}')
echo
if [ -n "$GW" ]; then
  ping -I $IFACE -c 2 -W 1 $GW > /dev/null 2>&1
  STATUS=$([ $? -eq 0 ] && echo "Reachable" || echo "Unreachable")
  echo "4. Default Gateway: $GW"
  echo "   Ping Test to $GW is $STA

