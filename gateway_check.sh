#!/bin/sh

# Interface to test
IFACE="eth0.2"

# WISDM & diagnostic endpoints
WISDM_SERVERS="172.104.6.188 remonteiot.com google.com"

echo "===== Centegix Gateway Diagnostics ====="
echo "Running on $(hostname) at $(date)"

# Step 1: Basic Interface Info
echo "\n===== Step 1: Interface Info for $IFACE ====="
ifconfig $IFACE

# Step 2: IP Address and Routes
echo "\n===== Step 2: IP & Route Verification ====="
ip addr show $IFACE
ip route show

# Step 3: Check DHCP or Static Assignment
echo "\n===== Step 3: IP Assignment Type for $IFACE ====="
if grep -q "$IFACE" /etc/network/interfaces 2>/dev/null; then
  METHOD=$(grep -A2 "$IFACE" /etc/network/interfaces | grep -i 
'static\|dhcp' | head -1)
  if echo "$METHOD" | grep -qi 'dhcp'; then
    echo "$IFACE appears to be using DHCP (from interfaces file)."
  elif echo "$METHOD" | grep -qi 'static'; then
    echo "$IFACE appears to be using a static IP (from interfaces file)."
  else
    echo "⚠️  Could not determine from /etc/network/interfaces."
  fi
else
  if ps | grep -q "[u]dhcpc.*$IFACE"; then
    echo "$IFACE is being managed by DHCP (udhcpc is active)."
  else
    echo "$IFACE is likely using a static IP or unknown config."
  fi
fi

# Step 4: Default Gateway Test
echo "\n===== Step 4: Default Gateway Check ====="
GW=$(ip route show default 0.0.0.0/0 dev $IFACE | awk '{print $3}')
if [ -n "$GW" ]; then
  echo "Default Gateway via $IFACE: $GW"
  ping -I $IFACE -c 3 "$GW"
else
  echo "❌ No default gateway found on $IFACE"
fi

# Step 5: DNS Resolution Test via eth0.2
echo "\n===== Step 5: DNS Resolution Check via $IFACE ====="
SRC_IP=$(ip -4 addr show $IFACE | awk '/inet / {print $2}' | cut -d/ -f1)
if [ -z "$SRC_IP" ]; then
  echo "❌ Could not determine source IP for $IFACE."
else
  for domain in $WISDM_SERVERS; do
    echo -n "Resolving $domain via $SRC_IP ... "
    timeout 5 curl --interface "$SRC_IP" -s "http://$domain" > /dev/null
    if [ $? -eq 0 ]; then
      echo "✅ Success"
    else
      echo "❌ Failed"
    fi
  done
fi

# Step 6: Active Connections (Filtered)
echo "\n===== Step 6: Active Connections (Filtered) ====="
if netstat -anp 2>/dev/null | grep -q .; then
  netstat -anp | grep -E 'ESTABLISHED|172\.104\.6\.188|443|8883'
else
  echo "⚠️  'netstat -p' not supported. Showing basic connection info 
instead."
  netstat -an | grep -E 'ESTABLISHED|172\.104\.6\.188|443|8883'
fi

# Step 7: Listening Services
echo "\n===== Step 7: Listening Ports ====="
netstat -tuln

# Step 8: Routing Table
echo "\n===== Step 8: Routing Table ====="
netstat -rn

echo "\n===== Diagnostics Complete ====="

