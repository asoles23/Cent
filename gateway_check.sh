#!/bin/sh

IFACE="eth0.2"
WISDM_SERVERS="google.com centegix.wisdm.rakwireless.com centegix.com"

echo
echo "===== Centegix Gateway Connectivity Check ====="

HOST=$(hostname 2>/dev/null)
[ -z "$HOST" ] && HOST="unknown"
echo "Running on $HOST at $(date)"
echo

# Step 1: Interface status
IF_STATUS=$(ifconfig $IFACE 2>/dev/null | grep -q "RUNNING" && echo "UP" || echo "DOWN")
echo "1. Interface $IFACE status: $IF_STATUS"

# Step 2: IP address
IP_LINE=$(ifconfig $IFACE 2>/dev/null | grep 'inet addr:' | grep -v '169.254')
IP_ADDR=$(echo "$IP_LINE" | cut -d':' -f2 | cut -d' ' -f1)
echo "2. IP address on $IFACE: ${IP_ADDR:-Not found}"

# Step 3: DHCP or Static
echo "3. IP Assignment Type:"
if ps | grep udhcpc | grep -q "$IFACE"; then
  echo "   $IFACE is using DHCP (udhcpc is active)"
else
  echo "   $IFACE is likely using a static IP"
fi

# Step 4: Default Gateway and Ping Test
GW=$(ip route | grep "^default" | grep "$IFACE" | cut -d' ' -f3)
echo
echo "4. Default Gateway: ${GW:-Not found on $IFACE}"
if [ -n "$GW" ]; then
  ping -I $IFACE -c 2 -W 1 $GW > /dev/null 2>&1
  STATUS=$([ $? -eq 0 ] && echo "Reachable" || echo "Unreachable")
  echo "   Ping Test to $GW is $STATUS"
fi

# Step 5: DNS Resolution
echo
echo "5. DNS Resolution via $IFACE:"
if [ -z "$IP_ADDR" ]; then
  echo "   No valid IP to test DNS"
else
  for domain in $WISDM_SERVERS; do
    curl --interface "$IP_ADDR" --max-time 5 -s "http://$domain" > /dev/null
    RESULT=$([ $? -eq 0 ] && echo "Success" || echo "Failed")
    printf "   %-30s : %s\n" "$domain" "$RESULT"
  done
fi

# Step 6: Active Connections (Filtered by IP)
echo
echo "6. Active Connections (Filtered):"
if [ -n "$IP_ADDR" ]; then
  if netstat -anp 2>/dev/null | grep -q .; then
    netstat -anp | grep "$IP_ADDR" | grep ESTABLISHED | while read line; do
      echo "   $line"
    done
  else
    echo "   No active connections found"
  fi
else
  echo "   Cannot check active connections (no valid IP on $IFACE)"
fi

echo
echo "===== Diagnostics Complete ====="

