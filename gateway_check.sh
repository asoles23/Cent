#!/bin/sh

IFACE="eth0.2"
WISDM_SERVERS="172.104.6.188 remonteiot.com google.com"

echo "===== Centegix Gateway Diagnostics ====="
echo "Running on $(cat /etc/hostname 2>/dev/null || echo unknown) at $(date)"

echo
echo "===== Step 1: Interface Info for $IFACE ====="
ifconfig $IFACE | grep -E "inet addr|HWaddr|RUNNING"

echo
echo "===== Step 2: IP & Route Verification ====="
ip addr show $IFACE | grep "inet "
ip route | grep $IFACE | grep default

echo
echo "===== Step 3: IP Assignment Type for $IFACE ====="
if ps | grep -q "[u]dhcpc.*$IFACE"; then
  echo "$IFACE is using DHCP (udhcpc is active)"
else
  echo "$IFACE is likely using a static IP"
fi

echo
echo "===== Step 4: Default Gateway Check ====="
GW=$(ip route | grep "^default.*$IFACE" | awk '{print $3}')
if [ -n "$GW" ]; then
  echo "Default Gateway: $GW"
  ping -I $IFACE -c 2 -W 1 $GW > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    echo "Ping Test: Reachable"
  else
    echo "Ping Test: Unreachable"
  fi
else
  echo "No default gateway found on $IFACE"
fi

echo
echo "===== Step 5: DNS Resolution via $IFACE ====="
SRC_IP=$(ip -4 addr show $IFACE | awk '/inet / {print $2}' | cut -d/ -f1)
if [ -z "$SRC_IP" ]; then
  echo "No valid IP found on $IFACE"
else
  for domain in $WISDM_SERVERS; do
    echo -n "Resolving $domain... "
    curl --interface "$SRC_IP" --max-time 5 -s "http://$domain" > /dev/null
    if [ $? -eq 0 ]; then
      echo "Success"
    else
      echo "Failed"
    fi
  done
fi

echo
echo "===== Step 6: Active Connections (Filtered) ====="
if netstat -anp 2>/dev/null | grep -q .; then
  netstat -anp | grep -E 'ESTABLISHED|443|8883|172\.104\.6\.188'
else
  netstat -an | grep -E 'ESTABLISHED|443|8883|172\.104\.6\.188'
fi

echo
echo "===== Diagnostics Complete ====="

