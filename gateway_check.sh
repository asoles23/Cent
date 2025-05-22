#!/bin/sh

echo ""
echo "===== Centegix Gateway Connectivity Check ====="
echo "Running on $(hostname) at $(date)"

# Step 1: Check if eth0.2 exists and is up
echo ""
echo "1. Interface eth0.2 status:"
ip link show eth0.2 | grep -q "state UP"
if [ $? -eq 0 ]; then
  echo "   eth0.2 is UP"
else
  echo "   eth0.2 is DOWN or does not exist"
fi

# Step 2: Display IP address for eth0.2
echo ""
echo "2. IP address on eth0.2:"
IP_ADDR=$(ip addr show eth0.2 | awk '/inet / {print $2}' | cut -d'/' -f1)
if [ -n "$IP_ADDR" ]; then
  echo "   IP Address: $IP_ADDR"
else
  echo "   No IP address assigned"
fi

# Step 3: Gateway connectivity check
echo ""
echo "3. Default Gateway:"
DEFAULT_GW=$(ip route show dev eth0.2 | awk '/default/ {print $3}')
if [ -n "$DEFAULT_GW" ]; then
  echo "   Default Gateway: $DEFAULT_GW"
  if ping -c 2 -I eth0.2 -W 2 "$DEFAULT_GW" >/dev/null 2>&1; then
    echo "   Ping Test to $DEFAULT_GW: Reachable"
  else
    echo "   Ping Test to $DEFAULT_GW: Unreachable"
  fi
else
  echo "   Default Gateway not found on eth0.2"
fi

# Step 4: Reachability check with netcat (nc)
echo ""
echo "4. Reachability Test via nc (ports 80 and 443):"
HOSTS="google.com centegix.com centegix.wisdm.rakwireless.com"
for HOST in $HOSTS; do
  for PORT in 80 443; do
    if nc -zvw2 "$HOST" "$PORT" >/dev/null 2>&1; then
      echo "   $HOST:$PORT - Reachable"
    else
      echo "   $HOST:$PORT - Unreachable"
    fi
  done
done

# Step 5: Active connections
echo ""
echo "5. Active Connections (Bound to $IP_ADDR):"
netstat -tunlp | grep "$IP_ADDR"

echo ""
echo "===== Connectivity Check Complete ====="

