#!/bin/sh

echo ""
echo "===== Centegix Gateway Connectivity Check ====="

# Step 0: Hostname and time
HOST=`hostname 2>/dev/null`
if [ "$HOST" = "" ]; then HOST="unknown"; fi
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

# Step 2: IP address
echo "2. IP address on eth0.2: \c"
PRIMARY_IP=""
for IP in `ip -4 addr show eth0.2 | grep 'inet ' | awk '{print $2}' | cut -d/ -f1`; do
  echo "$IP" | grep "^169\." >/dev/null
  if [ $? -ne 0 ] && [ "$PRIMARY_IP" = "" ]; then
    PRIMARY_IP="$IP"
  fi
done
if [ "$PRIMARY_IP" != "" ]; then
  echo "$PRIMARY_IP"
else
  echo "No valid IP assigned"
fi

# Step 3: IP assignment type
ech

