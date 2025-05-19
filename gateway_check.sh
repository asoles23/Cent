#!/bin/sh

DEVICE="eth0.2"

echo "===== Centegix Gateway Diagnostic ====="

# 1. Check Layer 2 Interface State
echo -n "1. Interface $DEVICE status: "
ip -o link show $DEVICE 2>/dev/null | awk '{print $9}'

# 2. Get valid IP (exclude 169.254.x.x)
echo -n "2. IP address on $DEVICE: "
IP=$(ip -4 addr show $DEVICE 2>/dev/null | awk '/inet / && $2 !~ 
/^169\.254/ {print $2}' | awk -F/ '{print $1}')
if [ -z "$IP" ]; then
  echo "None found (only link-local or unassigned)"
else
  echo "$IP (Valid)"
fi

# 3. Get default gateway for eth0.2
echo -n "3. Default gateway for $DEVICE: "
GATEWAY=$(ip route 2>/dev/null | awk -v dev="$DEVICE" '$1 == 
"default" && $0 ~ dev {print $3; exit}')
if [ -z "$GATEWAY" ]; then
  echo "Not found"
else
  echo "$GATEWAY"
  echo -n "   Ping test to $GATEWAY: "
  if ping -I $DEVICE -c 1 -W 1 $GATEWAY > /dev/null 2>&1; then
    echo "Reachable"
  else
    echo "Unreachable"
  fi
fi

# 4. DNS resolution using nslookup (BusyBox/OpenWrt safe)
echo -n "4. DNS resolution for centegix.wisdm.rakwireless.com: "
if nslookup centegix.wisdm.rakwireless.com > /dev/null 2>&1; then
  echo "Successful"
else
  echo "Failed"
fi

# 5. Active connections using IP
echo "5. Active connections using IP $IP:"
if [ -n "$IP" ]; then
  netstat -an | grep "$IP" || echo "No active connections found"
else
  echo "Skipped (No valid IP address to check)"
fi

echo "===== Diagnostics Complete ====="

