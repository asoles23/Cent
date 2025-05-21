#!/bin/sh

IFACE="eth0.2"
WISDM_SERVERS="google.com centegix.wisdm.rakwireless.com centegix.com"

echo "===== Centegix Gateway Connectivity Check ====="

HOST=$(hostname 2>/dev/null)
[ -z "$HOST" ] && HOST="unknown"
echo "Running on $HOST at $(date)"

# Step 1: Interface status
IF_STATUS=$(ifconfig $IFACE 2>/dev/null | grep -q "RUNNING" && echo "UP" || echo "DOWN")
echo
echo "1. Interface $IFACE status: $IF_STATUS"

# Step 2: IP address
IP_LINE=$(ifconfig $IFACE 2>/dev/null | grep 'inet addr:' | grep -v '169.254')
IP_ADDR=$(echo "$IP_LINE" | cut -d':' -f2 | cut -d' ' -f1)
if [ -n "$IP_ADDR" ]; then
  echo "2. IP address on $IFACE: $IP_ADDR"
else
  echo "2. IP address on $IFACE: Not found"
fi

# Step 

