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

# Step 4: DNS + Port 80 Reachability
echo
echo "4. DNS + Port 80 Reachability via $IFACE:"
if [ -z "$IP_ADDR" ]; then
  echo "   No valid IP to test DNS or connections"
else
  for domain in $WISDM_SERVERS; do
    IP_RESOLVED=$(nslookup "$domain" 2>/dev/null | grep -A1 "Name:" | grep "Address" | 
tail -n1 | awk '{print $2}')
    if [ -n "$IP_RESOLVED" ]; then
      nc -z -w 3 "$domain" 80 > /dev/null 2>&1
      STATUS=$([ $? -eq 0 ] && echo "Success" || echo "Unreachable")
      printf "   %-30s : DNS OK, Port 80 %s\n" "$domain" "$STATUS"
    else
      printf "   %-30s : DNS Failed\n" "$domain"
    fi
  done
fi

# Step 5: Active Connections bound to eth0.2 IP
echo
echo "5. Active Connections (Bound to $IP_ADDR):"
if [ -n "$IP_ADDR" ]; then
  netstat -anp 2>/dev/null | grep "$IP_ADDR" | while read line; do
    echo "   $line"
  done
else
  echo "   No valid IP to filter connections."
fi

echo
echo "===== Diagnostics Complete ====="

