#!/bin/sh

echo ""
echo "===== Centegix Gateway Connectivity Check ====="

# Step 0: Safe hostname
HOSTNAME_OUTPUT=`hostname 2>/dev/null`
if [ "$HOSTNAME_OUTPUT" = "" ]; then
  HOST="unknown"
else
  HOST="$HOSTNAME_OUTPUT"
fi

echo "Running on $HOST at `date`"

# Step 1: Interface status
echo ""
echo "1. Interface eth0.2 status:"
ip link show eth0.2 2>/dev/null | grep "state UP" >/dev/null
if [ $? -eq 0 ]; then
  echo "   eth0.2 is UP"
else
  echo "   eth0.2 is DOWN or does not exist"
fi

# Step 2: IP address (filter 169.254)
echo ""
echo "2. IP address on eth0.2:"
IP_ADDRS=`ip -4 addr show eth0.2 | grep "inet " | awk '{print $2}' | cut -d/ -f1`
VALID_IPS=""
for IP in $IP_ADDRS; do
  echo "$IP" | grep "^169\." >/dev/null
  if [ $? -ne 0 ]; then
    VALID_IPS="$VALID_IPS $IP"
    echo "   IP Address: $IP"
  fi
done
if [ "$VALID_IPS" = "" ]; then
  echo "   No valid global IP address assigned"
fi

# Step 3: Default Gateway
echo ""
echo "3. Default Gateway:"
DEFAULT_GW=`ip route show dev eth0.2 | grep "default" | awk '{print $3}'`
if [ "$DEFAULT_GW" != "" ]; then
  echo "   Default Gateway: $DEFAULT_GW"
  ping -c 2 -I eth0.2 -W 2 $DEFAULT_GW >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    echo "   Ping Test to $DEFAULT_GW: Reachable"
  else
    echo "   Ping Test to $DEFAULT_GW: Unreachable"
  fi
else
  echo "   Default Gateway not found on eth0.2"
fi

# Step 4: Reachability test
echo ""
echo "4. Reachability Test via nc (ports 80 and 443):"
for HOST in google.com centegix.com centegix.wisdm.rakwireless.com; do
  for PORT in 80 443; do
    nc -zvw2 $HOST $PORT >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      echo "   $HOST:$PORT - Reachable"
    else
      echo "   $HOST:$PORT - Unreachable"
    fi
  done
done

# Step 5: Active connections
echo ""
echo "5. Active Connections (Bound to IPs):"
if [ "$VALID_IPS" != "" ]; then
  for IP in $VALID_IPS; do
    echo "   Connections for $IP:"
    netstat -tunlp 2>/dev/null | grep "$IP" | sed 's/^/      /'
  done
else
  echo "   No valid IPs to check connections."
fi

echo ""
echo "===== Connectivity Check Complete ====="

