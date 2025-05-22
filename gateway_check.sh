#!/bin/sh

# Safe hostname fallback
HOST=$(hostname 2>/dev/null || echo "unknown")

echo ""
echo "===== Centegix Gateway Connectivity Check ====="
echo "Running on $HOST at $(date)"

# Step 1: Check interface status
echo ""
echo "1. Interface eth0.2 status:"
ip link show eth0.2 | grep -q "state UP"
if [ $? -eq 0 ]; then
  echo "   eth0.2 is UP"
else
  echo "   eth0.2 is DOWN or does not exist"
fi

# Step 2: IP address on eth0.2 (filter out link-local 169.*)
echo ""
echo "2. IP address on eth0.2:"
IP_ADDRS=$(ip -4 addr show eth0.2 | awk '/inet / {print $2}' | cut -d'/' -f1 | grep -v 
'^169\.')
if [ -n "$IP_ADDRS" ]; then
  for IP in $IP_ADDRS; do
    echo "   IP Address: $IP"
  done
else
  echo "   No valid global IP address assigned"
fi

# Step 3: Default gateway ping test
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

# Step 4: nc connectivity test
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

# Step 5: Active connections bound to each global IP
echo ""
echo "5. Active Connections (Bound to IPs):"
for IP in $IP_ADDRS; do
  echo "   Connections for $IP:"
  netstat -tunlp 2>/dev/null | grep "$IP" | sed 's/^/      /'
done

echo ""
echo "===== Connectivity Check Complete ====="

