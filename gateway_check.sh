#!/bin/sh

IFACE="eth0.2"
WISDM_SERVERS="172.104.6.188 remonteiot.com google.com"

echo "===== Centegix Gateway Connectivity Check ====="
echo "Running on $(cat /etc/hostname 2>/dev/null || echo unknown) at $(date)"

# Step 1: Interface status
IF_STATUS=$(ifconfig $IFACE 2>/dev/null | grep -q "RUNNING" && echo "UP" || echo "DOWN")
echo
echo "1. Interface $IFACE status: $IF_STATUS"

# Step 2: IP address (BusyBox-stable)
IP_ADDR=$(ifconfig $IFACE 2>/dev/null | grep 'inet addr:' | grep -v '169.254' | awk 
'{print $2}' | cut -d: -f2)
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
GW=$(ip route | grep "^default" | grep "$IFACE" | awk '{print $3}')
echo
if [ -n "$GW" ]; then
  ping -I $IFACE -c 2 -W 1 $GW > /dev/null 2>&1
  STATUS=$([ $? -eq 0 ] && echo "Reachable" || echo "Unreachable")
  echo "4. Default Gateway: $GW"
  echo "   Ping Test to $GW is $STATUS"
else
  echo "4. Default Gateway: Not found on $IFACE"
fi

# Step 5: DNS Resolution
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

# Step 6: Active Connections (no regex or -e flags)
echo
echo "6. Active Connections (Filtered):"
if netstat -anp 2>/dev/null | grep -q .; then
  netstat -anp | grep ESTABLISHED | grep -v '127.0.0.1' | grep 
'443\|8883\|172.104.6.188'
else
  netstat -an | grep ESTABLISHED | grep -v '127.0.0.1' | grep '443\|8883\|172.104.6.188'
fi

echo
echo "===== Diagnostics Complete ====="

