#!/bin/sh

IFACE="eth0.2"
WISDM_SERVERS="172.104.6.188 remonteiot.com google.com"

echo "===== Centegix Gateway Connectivity Check ====="
echo "Running on $(cat /etc/hostname 2>/dev/null || echo unknown) at $(date)"

# Step 1: Interface status (no BusyBox leak)
IF_UP=$(ifconfig $IFACE 2>/dev/null | grep -q "RUNNING" && echo "UP" || echo "DOWN")
echo
echo "1. Interface $IFACE status: $IF_UP"

# Step 2: Extract IP from ifconfig for eth0.2 (BusyBox-friendly)
IP_ADDR=$(ifconfig $IFACE | awk '/inet addr:/ && $2 !~ /169\.254/ {for(i=1;i<=NF;i++) 
if($i ~ /^addr:/) {split($i,a,":"); print a[2]}}')
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
GW=$(ip route | grep -e "^default" | grep -e "$IFACE" | awk '{print $3}')
echo
if [ -n "$GW" ]; then
  ping -I $IFACE -c 2 -W 1 $GW > /dev/null 2>&1
  STATUS=$([ $? -eq 0 ] && echo "Reachable" || echo "Unreachable")
  echo "4. Default Gateway: $GW"
  echo "   Ping Test to $GW is $STATUS"
else
  echo "4. Default Gateway: Not found on $IFACE"
fi

# Step 5: DNS Resolution via eth0.2
echo
echo "5. DNS Resolution via $IFACE:"
SRC_IP="$IP_ADDR"
if [ -z "$SRC_IP" ]; then
  echo "   No valid IP to test DNS"
else
  for domain in $WISDM_SERVERS; do
    curl --interface "$SRC_IP" --max-time 5 -s "http://$domain" > /dev/null
    RESULT=$([ $? -eq 0 ] && echo "Success" || echo "Failed")
    echo "   $domain: $RESULT"
  done
fi

# Step 6: Active Connections (Filtered, BusyBox-safe)
echo
echo "6. Active Connections (Filtered):"
if netstat -anp 2>/dev/null | grep -q .; then
  netstat -anp | grep -e ESTABLISHED | grep -v -e '127.0.0.1' | grep -e '443' -e '8883' 
-e '172.104.6.188'
else
  netstat -an | grep -e ESTABLISHED | grep -v -e '127.0.0.1' | grep -e '443' -e '8883' 
-e '172.104.6.188'
fi

echo
echo "===== Diagnostics Complete ====="

