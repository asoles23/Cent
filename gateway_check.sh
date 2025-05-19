#!/bin/bash

#!/bin/bash

DEVICE="eth0.2"

echo "===== Centegix Gateway Diagnostic ====="

# 1. Check Layer 2 Interface State
echo -n "1. Interface $DEVICE status: "
ip -o link show $DEVICE | awk '{print $9}'

# 2. Check Valid IP Address
echo -n "2. IP address on $DEVICE: "
IP=$(ip -4 addr show $DEVICE | awk '/inet / {print $2}' | cut -d/ -f1)
if [[ "$IP" =~ ^169\.254\. ]]; then
  echo "$IP (Invalid - Link-local)"
else
  echo "$IP (Valid)"
fi

# 3. Check Default Gateway Reachability
GATEWAY=$(ip route | awk '/default/ {print $3}')
echo -n "3. Default gateway ($GATEWAY) ping result: "
ping -c 1 -w 1 $GATEWAY &> /dev/null && echo "Reachable" || echo "Unreachable"

# 4. Check DNS Resolution
echo -n "4. DNS resolution test for remoteiot.com: "
host remoteiot.com &> /dev/null && echo "Successful" || echo "Failed"

# 5. Check Active Connections on eth0.2 IP
echo "5. Active network connections using IP $IP:"
if [[ -n "$IP" && ! "$IP" =~ ^169\.254\. ]]; then
  netstat -an | grep "$IP" || echo "No active connections found"
else
  echo "Skipped (No valid IP address to check)"
fi

echo "===== Diagnostics Complete ====="

