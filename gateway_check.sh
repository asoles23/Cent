#!/bin/sh

echo ""
echo "===== Centegix Gateway Connectivity Check ====="

# Step 0: Hostname and time
HOST=`hostname 2>/dev/null`
if [ "$HOST" = "" ]; then HOST="unknown"; fi
echo "Running on $HOST at \`date\`"

# Step 1: Interface status
echo ""
echo "1. Interface eth0.2 status:"
ip link show eth0.2 2>/dev/null | grep "state UP" >/dev/null
if [ $? -eq 0 ]; then
  echo "   eth0.2 is UP"
else
  echo "   eth0.2 is DOWN or not found"
fi

# Step 2: IP address on eth0.2
echo ""
echo "2. IP address on eth0.2:"
PRIMARY_IP=""
for IP in \`ip -4 addr show eth0.2 | grep 'inet ' | awk '{print \$2}' | cut -d/ -f1\`; do
  echo "\$IP" | grep "^169\\." >/dev/null
  if [ \$? -ne 0 ] && [ "\$PRIMARY_IP" = "" ]; then
    PRIMARY_IP="\$IP"
  fi
done
if [ "\$PRIMARY_IP" != "" ]; then
  echo "   IP Address: \$PRIMARY_IP"
else
  echo "   No valid IP assigned"
fi

# Step 3: IP assignment type
echo ""
echo "3. IP Assignment Type:"
UDHCPC_CHECK=\`ps | grep "udhcpc.*eth0.2" | grep -v grep\`
if [ "\$UDHCPC_CHECK" != "" ]; then
  echo "   eth0.2 is using DHCP (udhcpc is active)"
else
  echo "   eth0.2 is likely using a static IP"
fi

# Step 4: Default Gateway
<<<<<<< HEAD
DEFAULT_GW=`ip route show dev eth0.2 | grep "default" | awk '{print $3}'`
echo ""
echo "4. Default Gateway: $DEFAULT_GW"
ping -c 2 -I eth0.2 -W 2 $DEFAULT_GW >/dev/null 2>&1
if [ $? -eq 0 ]; then
  echo "   Ping Test to $DEFAULT_GW is Reachable"
else
  echo "   Ping Test to $DEFAULT_GW is Unreachable"
fi
=======
DEFAULT_GW=\`ip route show dev eth0.2 |_
>>>>>>> 6563a18 (Fix Step 2 IP parsing using grep and sed for BusyBx8)

# Step 5: Hostname connectivity test
echo ""
echo "5. Connectivity Test to Hostnames via eth0.2:"
for HOSTNAME in google.com centegix.wisdm.rakwireless.com centegix.com; do
  for PORT in 80 443; do
    nc -zvw2 $HOSTNAME $PORT >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      printf "   %-40s : Reachable\n" "$HOSTNAME:$PORT"
    else
      printf "   %-40s : Unreachable\n" "$HOSTNAME:$PORT"
    fi
  done  # ✅ this was missing
done  # ✅ closes outer loop

# Step 6: Active connections
echo ""
echo "6. Active Connections (Bound to $PRIMARY_IP):"
netstat -tunlp 2>/dev/null | grep "$PRIMARY_IP" | sed 's/^/   /'

echo ""
echo "===== Diagnostics Complete ====="
