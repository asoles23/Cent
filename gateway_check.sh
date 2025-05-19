#!/bin/sh

DEVICE="eth0.2"

echo "===== Centegix Gateway Diagnostic ====="

# 1. Check Layer 2 Interface State
echo -n "1. Interface $DEVICE status: "
ip -o link show $DEVICE | awk '{print $9}'

# 2. Check IP address on eth0.2 (must not be 169.254.x.x)
echo -n "2. IP address on $DEVICE: "
IP=$(ip -4 addr show $DEVICE | awk '/inet / {print $2}' | cut -d/ -f1)
if echo "$IP" | grep -q "^169\.254\."; then
  echo "$IP (Invalid - Link-local)"
else
  echo "$IP (Valid)"
fi

# 3. Check Default Gateway associated with eth0.2
echo -n "3. Default gateway for $DEVICE: "
GATEWAY=$(ip route | awk -v dev="$DEVICE" '$0 ~ dev && $1 == "default" 
{print $3; exit}')
if [ -z "$GATEWAY" ]; then
  echo "Not found"
else
  echo "$GATEWAY"

  echo -n "   Ping test to $GATEWAY: "
  ping -I $DEVICE -c 1 -w 1 $GATEWAY > /dev/null 2>&1 && echo 
"Reachable" || echo "Unreachable"
fi

# 4. DNS Resolution Check (centegix.wisdm.rakwireless.com)
echo -n "4. DNS resolution test for centegix.wisdm.rakwireless.com: "
host centegix.wisdm.rakwireless.com > /dev/null 2>&1 && echo 
"Successful" || echo "Failed"

# 5. Active connections using eth0.2 IP
echo "5. Active connections using IP $IP:"
if [ -n "$IP" ] && ! echo "$IP" | grep -q "^169\.254\."; then
  netstat -an | grep "$IP" || echo "No active connections found"
else
  echo "Skipped (No valid IP address to check)"
fi

echo "===== Diagnostics Complete ====="


