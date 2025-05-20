#!/bin/sh

IFACE="eth0.2"
WISDM_SERVERS="172.104.6.188 remonteiot.com google.com"

echo "===== Centegix Gateway Diagnostics ====="
echo "Running on $(cat /etc/hostname 2>/dev/null || echo unknown) at $(date)"

# Step 1: Interface status
IF_STATUS=$(ifconfig $IFACE 2>/dev/null | grep -q "RUNNING" && echo "UP" || echo "DOWN")
echo "1. Interface $IFACE status: $IF_STATUS"

# Step 2: IP Address
IP_ADDR=$(ip -4 addr show $IFACE | awk '/inet / {print $2}' | cut -d/ -f1)
if [ -n "$IP_ADDR" ]; then
  echo "2. IP address on $IFACE: $IP_ADDR"
else
  echo "2. IP address on $IFACE: Not found"
fi

# Step 3: Default Gateway and Ping
GW=$(ip route | grep "^default.*$IFACE" | awk '{print $3}')
if [ -n "$GW" ]; then
  ping -I $IFACE -c 2 -W 1 $GW > /dev/null 2>&1
  STATUS=$([ $? -eq 0 ] && echo "Reachable" || echo "Unreachable")
  echo "3. Default Gateway: $GW Ping Test to $GW is $STATUS"
else
  echo "3. Default Gateway: Not found on $IFACE"
fi

# Step 4: DNS resolution via eth0.2
SRC_IP=$(ip -4 addr show $IFACE | awk '/inet / {print $2}' | cut -d/ -f1)
echo "4. DNS Resolution via $IFACE:"
if [ -z "$SRC_IP" ]; then
  echo "   No valid IP to test DNS"
else
  for domain in $WISDM_SERVERS; do
    curl --interface "$SRC_IP" --max-time 5 -s "http://$domain" > /dev/null
    RESULT=$([ $? -eq 0 ] && echo "Success" || echo "Failed")
    echo "   $domain: $RESULT"
  done
fi

# Step 5: Active Connections (Filtered)
echo "5. Active Connections (Filtered):"
if netstat -anp 2>/dev/null | grep -q .; then
  netstat -anp | grep -E 'ESTABLISHED|443|8883|172\.104\.6\.188'
else
  netstat -an | grep -E 'ESTABLISHED|443|8883|172\.104\.6\.188'
fi

echo "===== Diagnostics Complete ====="

