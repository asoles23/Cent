#!/bin/sh

echo ""
echo "===== Centegix Gateway Connectivity Check ====="

# Step 0: Hostname and time
HOSTNAME_OUTPUT=`hostname 2>/dev/null`
if [ "$HOSTNAME_OUTPUT" = "" ]; then
  HOST="unknown"
else
  HOST="$HOSTNAME_OUTPUT"
fi
echo "Running on $HOST at `date`"

# Step 1: Interface status
echo ""
echo "1. Interface eth0.2 status: \c"
ip link show eth0.2 2>/dev/null | grep "state UP" >/dev/null
if [ $? -eq 0 ]; then
  echo "UP"
else
  echo "DOWN or not found"
fi

# Step 2: IP address and assignment type
echo "2. IP address on eth0.2: \c"
IP_ADDRS=`ip -4 addr show eth0.2 | grep "inet " | awk '{print $2}' | cut -d/ -f1`
PRIMARY_IP=""
for IP in $IP_ADDRS; do
  echo "$IP" | grep "^169\." >/dev/null
  if [ $? -ne 0 ]; then
    if [ "$PRIMARY_IP" = "" ]; then
      PRIMARY_IP="$IP"
    fi
  fi
done

if [ "$PRIMARY_IP" != "" ]; then
  echo "$PRIMARY_IP"
else
  echo "No valid IP assigned"
fi

echo "3. IP Assignment Type:"
# Check if udhcpc is active on eth0.2
UDHCPC_PID=`ps | grep "udhcpc.*eth0.2" | grep -v grep`
if [ "$UDHCPC_PID" != "" ]; then
  echo "   eth0.2 is using DHCP (udhcpc is active)"
else
  echo "   eth0.2 is likely using a static IP"
fi

# Step 4: Default Gateway
DEFAULT_GW=`ip route show dev eth0.2 | grep "default" | awk '{print $3}'`
echo ""
echo "4. Default Gateway: $DEFAULT_GW"
ping -c 2 -I eth0.2 -W 2 $DEFAULT_GW >/dev/null 2>&1
if [ $? -eq 0 ]; then
  echo "   Ping Test to $DEFAULT_GW is Reachable"
else
  echo "   Ping Test to $DEFAULT_GW is Unreachable"
fi

# Step 5: Hostname connectivity check via nc
echo ""
echo "5. Connectivity Test to Hostnames via eth0.2:"
for HOST in google.com centegix.wisdm.rakwireless.com centegix.com; do
  for PORT in 80 443; do
    nc -zvw2 $HOST $PORT >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      printf "   %-40s : Reachable\

