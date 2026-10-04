#!/usr/bin/env bash
# Exercise ics.sh's decisions without touching a network: the functions are
# sourced, and the end-to-end cases run with --dry-run, which needs no root
# and changes nothing.
set -u

script="$(dirname "$0")/ics.sh"
# shellcheck source=ics.sh
source "$script"

pass=0
fail=0
check() { # <label> <expected> <actual>
  if [ "$2" = "$3" ]; then
    pass=$((pass + 1)); printf '  ok   %s\n' "$1"
  else
    fail=$((fail + 1)); printf '  FAIL %s\n    want: %s\n    got:  %s\n' "$1" "$2" "$3"
  fi
}
contains() { # <label> <needle> <haystack>
  if printf '%s' "$3" | grep -qF -- "$2"; then
    pass=$((pass + 1)); printf '  ok   %s\n' "$1"
  else
    fail=$((fail + 1)); printf '  FAIL %s\n    missing: %s\n' "$1" "$2"
  fi
}

echo "candidate interfaces leave out loopback, containers and virtual bridges"
links='lo               UNKNOWN        00:00:00:00:00:00 <LOOPBACK,UP,LOWER_UP>
eno1             UP             7c:10:c9:3f:98:eb <BROADCAST,MULTICAST,UP,LOWER_UP>
enx00e04c680001  DOWN           00:e0:4c:68:00:01 <NO-CARRIER,BROADCAST,MULTICAST,UP>
wlp2s0           DOWN           aa:bb:cc:dd:ee:ff <BROADCAST,MULTICAST>
docker0          DOWN           66:bf:3d:a8:12:93 <NO-CARRIER,BROADCAST,MULTICAST,UP>
br-2bfc5c89dcd8  DOWN           4e:c3:4f:56:4a:0c <NO-CARRIER,BROADCAST,MULTICAST,UP>
vethf25f2a3@if2  UP             7a:44:c0:c1:92:55 <BROADCAST,MULTICAST,UP,LOWER_UP>
virbr0           DOWN           52:54:00:00:00:01 <NO-CARRIER,BROADCAST,MULTICAST,UP>'
check "physical and wireless only" "eno1 enx00e04c680001 wlp2s0" "$(printf '%s\n' "$links" | ics_candidates | paste -sd' ')"

echo "the shared-side address must be IPv4 with a prefix from /8 to /30"
for ok in 192.168.137.1/24 10.0.0.1/8 172.16.5.1/30; do
  check "accepts $ok" "0" "$(ics_valid_addr "$ok"; echo $?)"
done
for bad in 192.168.137.1 300.1.1.1/24 192.168.137.1/31 192.168.137.1/7 abc/24 1.2.3/24; do
  check "rejects $bad" "1" "$(ics_valid_addr "$bad"; echo $?)"
done

echo "the networkd file owns address, DHCP and masquerade for the shared side"
net=$(ics_render_network enx1 192.168.137.1/24 1.1.1.1)
contains "matches the interface" "Name=enx1" "$net"
contains "assigns the address" "Address=192.168.137.1/24" "$net"
contains "serves DHCP" "DHCPServer=yes" "$net"
contains "masquerades" "IPMasquerade=ipv4" "$net"
contains "comes up without a cable" "ConfigureWithoutCarrier=yes" "$net"
contains "hands out the DNS server" "DNS=1.1.1.1" "$net"
check "file sorts before netplan's 10-netplan-*" "/etc/systemd/network/05-ics-enx1.network" "$(ics_network_path enx1)"

echo "ufw rules are the same text for adding and deleting"
check "dhcp in, then route out" "allow in on enx1 to any port 67 proto udp comment ics
route allow in on enx1 out on eno1 comment ics" "$(ics_ufw_rules enx1 eno1)"

echo "--ssh is consumed locally and every other argument reaches the remote"
check "strips --ssh HOST" "enable --lan enx1 --dry-run" "$(ics_remote_args enable --ssh remote-ollama --lan enx1 --dry-run | paste -sd' ')"
check "strips --ssh=HOST" "disable --lan enx1" "$(ics_remote_args disable --ssh=remote-ollama --lan enx1 | paste -sd' ')"

echo "dry-run plans without root and without changing anything"
out=$(bash "$script" enable --lan enx1 --wan eno1 --dry-run 2>&1); rc=$?
check "exit 0" "0" "$rc"
contains "plans the networkd file" "/etc/systemd/network/05-ics-enx1.network" "$out"
contains "plans the ufw route rule" "ufw route allow in on enx1 out on eno1 comment ics" "$out"
contains "uses the ICS default address" "Address=192.168.137.1/24" "$out"
out=$(bash "$script" disable --lan enx1 --wan eno1 --dry-run 2>&1); rc=$?
check "disable exit 0" "0" "$rc"
contains "disable deletes the ufw route rule" "ufw delete route allow in on enx1 out on eno1 comment ics" "$out"
contains "disable removes the networkd file" "rm -f /etc/systemd/network/05-ics-enx1.network" "$out"

echo "rejects what it cannot act on"
out=$(bash "$script" enable --lan enx1 --wan enx1 --dry-run 2>&1); rc=$?
check "same lan and wan" "2" "$rc"
out=$(bash "$script" enable --lan enx1 --wan eno1 --addr 192.168.137.1 --dry-run 2>&1); rc=$?
check "address without prefix" "2" "$rc"
out=$(bash "$script" frobnicate 2>&1); rc=$?
check "unknown mode" "2" "$rc"

echo
printf 'pass=%d fail=%d\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
