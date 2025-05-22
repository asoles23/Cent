5. Active Connections (Bound to IPs):

===== Connectivity Check Complete =====
root@Berne_Union_Local-GW2:~# curl -s https://raw.githubusercontent.com/asoles23
/Cent/main/gateway_check.sh | sh -x
+ hostname
+ echo unknown
+ HOST=unknown
+ echo 

+ echo '===== Centegix Gateway Connectivity Check ====='
===== Centegix Gateway Connectivity Check =====
+ date
+ echo 'Running on unknown at Thu May 22 16:18:36 UTC 2025'
Running on unknown at Thu May 22 16:18:36 UTC 2025
+ echo 

+ echo '1. Interface eth0.2 status:'
1. Interface eth0.2 status:
+ + grepip -q link 'state UP' show
 eth0.2
+ '[' 0 -eq 0 ]
+ echo '   eth0.2 is UP'
   eth0.2 is UP
+ echo 

+ echo '2. IP address on eth0.2:'
2. IP address on eth0.2:
+ + + awk '/inet / {print $2}'
cutip -4 -d/ addr -f1+ 
 showgrep eth0.2 -v

BusyBox v1.33.1 (2025-01-21 06:25:51 UTC) multi-call binary.

Usage: grep [-HhnlLoqvsrRiwFE] [-m N] [-A/B/C N] PATTERN/-e PATTERN.../-f FILE [FILE]...

Search for PATTERN in FILEs (or stdin)

        -H      Add 'filename:' prefix
        -h      Do not add 'filename:' prefix
        -n      Add 'line_no:' prefix
        -l      Show only names of files that match
        -L      Show only names of files that don't match
        -c      Show only count of matching lines
        -o      Show only the matching part of line
        -q      Quiet. Return 0 if PATTERN is found, 1 otherwise
        -v      Select non-matching lines
        -s      Suppress open and read errors
        -r      Recurse
        -R      Recurse and dereference symlinks
        -i      Ignore case
        -w      Match whole words only
        -x      Match whole lines only
        -F      PATTERN is a literal (not regexp)
        -E      PATTERN is an extended regexp
        -m N    Match up to N times per file
        -A N    Print N lines of trailing context
        -B N    Print N lines of leading context
        -C N    Same as '-A N -B N'
        -e PTRN Pattern to match
        -f FILE Read pattern from file
+ '^169\.'
sh: ^169\.: not found
+ IP_ADDRS=
+ '[' -n  ]
+ echo '   No valid global IP address assigned'
   No valid global IP address assigned
+ echo 

+ echo '3. Default Gateway:'
3. Default Gateway:
+ awk '/default/ {print $3}'
+ ip route show dev eth0.2
+ DEFAULT_GW=10.21.100.1
+ '[' -n 10.21.100.1 ]
+ echo '   Default Gateway: 10.21.100.1'
   Default Gateway: 10.21.100.1
+ ping -c 2 -I eth0.2 -W 2 10.21.100.1
+ echo '   Ping Test to 10.21.100.1: Unreachable'
   Ping Test to 10.21.100.1: Unreachable
+ echo 

+ echo '4. Reachability Test via nc (ports 80 and 443):'
4. Reachability Test via nc (ports 80 and 443):
+ HOSTS='google.com centegix.com centegix.wisdm.rakwireless.com'
+ nc -zvw2 google.com 80
+ echo '   google.com:80 - Unreachable'
   google.com:80 - Unreachable
+ nc -zvw2 google.com 443
+ echo '   google.com:443 - Unreachable'
   google.com:443 - Unreachable
+ nc -zvw2 centegix.com 80
+ echo '   centegix.com:80 - Unreachable'
   centegix.com:80 - Unreachable
+ nc -zvw2 centegix.com 443
+ echo '   centegix.com:443 - Unreachable'
   centegix.com:443 - Unreachable
+ nc -zvw2 centegix.wisdm.rakwireless.com 80
+ echo '   centegix.wisdm.rakwireless.com:80 - Unreachable'
   centegix.wisdm.rakwireless.com:80 - Unreachable
+ nc -zvw2 centegix.wisdm.rakwireless.com 443
+ echo '   centegix.wisdm.rakwireless.com:443 - Unreachable'
   centegix.wisdm.rakwireless.com:443 - Unreachable
+ echo 

+ echo '5. Active Connections (Bound to IPs):'
5. Active Connections (Bound to IPs):
+ echo 

+ echo '===== Connectivity Check Complete ====='
===== Connectivity Check Complete =====
root@Berne_Union_Local-GW2:~# 
