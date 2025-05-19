#!/bin/sh

DEVICE="eth0.2"

echo "===== Centegix Gateway Diagnostic ====="

# 1. Check Layer 2 Interface State
echo -n "1. Interface $DEVICE status: "
ip -o link show $DEVICE | awk '{print $9}'

# 2. Extract a VALID (non-169.254) IP address from eth0.2
echo -n "2. IP address on $DEVICE: "
IP=$(ip -4 addr show $DEVICE | awk '/inet / {print $2}' | cut -d/ 
-f1 | grep -v "^169\.254\.")
if [ -z "$IP" ]; then
  echo "None found (only link-local or unassigned)"
else
  echo "$IP (Valid)"
fi

# 3. Get the default gateway for eth0.2 only
echo -n "3. Default gateway for $DEVICE: "
GATEWAY=$(ip route | awk -v dev="$DEVICE" '$1 == "default" && $0 ~ 
dev {print $3; exit}')
if [ -z "$GATEWAY" ]; then
  echo "Not found"
else
  echo "$GATEWAY"

  echo -n "   Ping test to $GATEWAY: "
  ping -I $DEVICE -c 1 -w 1 $GATEWAY > /dev/null 2>&1 && echo 
"Reachable" || echo "Unreachable"
fi

# 4. DNS Resolution Check
echo -n "4. DNS resolution test for centegix.wisdm.rakwireless.com: 
"
if host centegix.wisdm.rakwireless.com > /dev/null 2>&1; then
  echo "Successful"
else
  echo "Failed"
fi

# 5. Active connections using valid IP
echo "5. Active connections using IP $IP:"
if [ -n "$IP" ]; then
  netstat -an | grep "$IP" || echo "No active connections found"
else
  echo "Skipped (No valid IP address to check)"
fi

echo "===== Diagnostics Complete ====="




