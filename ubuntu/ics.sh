#!/usr/bin/env bash
# ics.sh — share this Ubuntu host's internet connection with a second
# interface, the way Windows ICS does (see windows/ics.ps1).
#
#   ics.sh enable  [--lan IF] [--wan IF] [--addr A.B.C.D/N] [--dns "IP ..."]
#   ics.sh disable [--lan IF] [--wan IF] [--addr A.B.C.D/N]
#   ics.sh status  [--lan IF]
#   ... --ssh HOST    run it on HOST over ssh (from Linux or Git Bash)
#   ... --dry-run     print the plan; needs no root and changes nothing
#
# Without --lan the interfaces are listed for a pick, as ics.ps1 does. --wan
# defaults to the interface of the default route, --addr to ICS's own
# 192.168.137.1/24, --dns to 1.1.1.1.
#
# systemd-networkd does the work ICS does: one .network file gives the shared
# side its address, a DHCP server and IPv4 masquerade, so nothing is
# installed. Its name sorts before netplan's generated 10-netplan-*.network,
# so it wins if a netplan pattern also matches the interface. ufw is the
# firewall in front: its default forward policy is DROP, and Docker's is
# too, so the shared side gets DHCP let in and a route rule out to the WAN.
# Forwarding is kept on by a sysctl.d file; disabling removes the file but
# leaves the live value, which Docker also depends on.
#
# Over --ssh the script copies itself to the host and runs there under
# `ssh -t`, so sudo can ask for its password on the terminal.

ICS_DEFAULT_ADDR=192.168.137.1/24
ICS_DEFAULT_DNS=1.1.1.1
ICS_SYSCTL=/etc/sysctl.d/60-ics.conf

ics_candidates() {
  awk '{ n = $1; sub(/@.*/, "", n)
         if (n == "lo" || n ~ /^(docker|br-|veth|virbr|vnet|cni|flannel|cali|vxlan)/) next
         print n }'
}

ics_valid_addr() {
  [[ $1 =~ ^([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})/([0-9]{1,2})$ ]] || return 1
  local i
  for i in 1 2 3 4; do (( BASH_REMATCH[i] <= 255 )) || return 1; done
  (( BASH_REMATCH[5] >= 8 && BASH_REMATCH[5] <= 30 ))
}

ics_network_path() {
  printf '/etc/systemd/network/05-ics-%s.network\n' "$1"
}

ics_render_network() { # <lan> <addr> <dns>
  cat <<EOF
# Written by dotfiles ubuntu/ics.sh; removed by \`ics.sh disable\`.
[Match]
Name=$1

[Network]
Address=$2
DHCPServer=yes
IPMasquerade=ipv4
ConfigureWithoutCarrier=yes

[DHCPServer]
PoolOffset=100
PoolSize=100
EmitDNS=yes
DNS=$3
EOF
}

ics_ufw_rules() { # <lan> <wan>
  printf 'allow in on %s to any port 67 proto udp comment ics\n' "$1"
  printf 'route allow in on %s out on %s comment ics\n' "$1" "$2"
}

ics_remote_args() {
  while [ $# -gt 0 ]; do
    case $1 in
      --ssh) shift 2 ;;
      --ssh=*) shift ;;
      *) printf '%s\n' "$1"; shift ;;
    esac
  done
}

ics_usage() {
  sed -n '2,14p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

ics_run() {
  if [ "$ICS_DRY" = 1 ]; then printf '+ %s\n' "$*"; else "$@"; fi
}

ics_write() { # <path> <content>
  if [ "$ICS_DRY" = 1 ]; then
    printf '+ write %s\n%s\n' "$1" "$2"
  else
    printf '%s\n' "$2" > "$1"
    echo "wrote $1"
  fi
}

ics_pick_lan() { # <wan>
  local -a names
  mapfile -t names < <(ip -br link | ics_candidates | grep -vx "$1")
  [ ${#names[@]} -gt 0 ] || { echo "no interface to share to besides $1; plug one in" >&2; return 1; }
  echo "=== Interfaces (WAN: $1) ===" >&2
  local i
  for i in "${!names[@]}"; do
    printf '[%2d] %s  (%s)\n' "$i" "${names[$i]}" "$(ip -br -4 addr show dev "${names[$i]}" | awk '{print $2, $3}')" >&2
  done
  local n
  while :; do
    read -r -p "Select the shared (LAN) interface: " n < /dev/tty
    [[ $n =~ ^[0-9]+$ ]] && (( n < ${#names[@]} )) && break
    echo "Enter a number between 0 and $(( ${#names[@]} - 1 ))." >&2
  done
  printf '%s\n' "${names[$n]}"
}

ics_enable() { # <lan> <wan> <addr> <dns>
  local path rule
  path=$(ics_network_path "$1")
  ics_write "$ICS_SYSCTL" "net.ipv4.ip_forward = 1"
  ics_run sysctl -q -p "$ICS_SYSCTL"
  ics_write "$path" "$(ics_render_network "$1" "$3" "$4")"
  ics_run networkctl reload
  ics_run networkctl reconfigure "$1"
  while IFS= read -r rule; do
    # shellcheck disable=SC2086 # the rule is ufw's own word list
    ics_run ufw $rule
  done < <(ics_ufw_rules "$1" "$2")
  [ "$ICS_DRY" = 1 ] && return 0
  if networkctl status "$1" --no-pager 2>/dev/null | grep -q "Network File: $path"; then
    echo "ICS enabled: $1 ($3) shares $2"
  else
    echo "warning: $1 is not managed by $path; check \`networkctl status $1\`" >&2
    return 1
  fi
}

ics_disable() { # <lan> <wan> <addr>
  local rule
  while IFS= read -r rule; do
    # shellcheck disable=SC2086
    ics_run ufw delete $rule || true
  done < <(ics_ufw_rules "$1" "$2")
  ics_run rm -f "$(ics_network_path "$1")" "$ICS_SYSCTL"
  ics_run networkctl reload
  ics_run ip address del "$3" dev "$1" || true
  ics_run networkctl reconfigure "$1" || true
  [ "$ICS_DRY" = 1 ] || echo "ICS disabled on $1"
}

ics_status() { # <lan>
  echo "== ip_forward: $(sysctl -n net.ipv4.ip_forward)"
  echo "== ICS files"; ls -1 /etc/systemd/network/05-ics-*.network "$ICS_SYSCTL" 2>/dev/null || echo "(none)"
  echo "== ufw rules"; ufw status | grep -E '# ics$' || echo "(none)"
  [ -n "$1" ] && { echo "== $1"; networkctl status "$1" --no-pager; }
  return 0
}

ics_main() {
  set -o errexit -o pipefail -o nounset
  local self=${BASH_SOURCE[0]} mode=${1:-} lan='' wan='' addr=$ICS_DEFAULT_ADDR dns=$ICS_DEFAULT_DNS host=''
  ICS_DRY=0
  case $mode in
    enable|disable|status) shift ;;
    -h|--help) ics_usage; return 0 ;;
    *) ics_usage >&2; return 2 ;;
  esac
  local -a args=("$@")
  while [ $# -gt 0 ]; do
    case $1 in
      --lan) lan=$2; shift 2 ;;
      --wan) wan=$2; shift 2 ;;
      --addr) addr=$2; shift 2 ;;
      --dns) dns=$2; shift 2 ;;
      --ssh) host=$2; shift 2 ;;
      --ssh=*) host=${1#--ssh=}; shift ;;
      --dry-run) ICS_DRY=1; shift ;;
      *) echo "unknown argument: $1" >&2; return 2 ;;
    esac
  done

  if [ -n "$host" ]; then
    local tmp rc=0
    tmp=$(ssh "$host" mktemp /tmp/ics.XXXXXX.sh)
    # shellcheck disable=SC2029 # the remote temp path is meant to expand here
    ssh "$host" "cat > '$tmp'" < "$self"
    local -a forward
    mapfile -t forward < <(ics_remote_args "$mode" "${args[@]}")
    ssh -t "$host" "bash $(printf '%q ' "$tmp" "${forward[@]}")" || rc=$?
    ssh "$host" rm -f "$tmp"
    return $rc
  fi

  ics_valid_addr "$addr" || { echo "--addr needs IPv4 with a /8../30 prefix, e.g. $ICS_DEFAULT_ADDR" >&2; return 2; }
  [ -n "$wan" ] || wan=$(ip route show default | awk '{ print $5; exit }')
  [ -n "$wan" ] || { echo "no default route; pass --wan" >&2; return 2; }
  if [ -z "$lan" ] && [ "$mode" != status ]; then lan=$(ics_pick_lan "$wan"); fi
  [ "$lan" != "$wan" ] || { echo "--lan and --wan must differ" >&2; return 2; }

  if [ "$ICS_DRY" = 0 ] && [ "$(id -u)" -ne 0 ]; then
    exec sudo bash "$self" "$mode" "${args[@]}"
  fi
  if [ "$ICS_DRY" = 0 ] && [ -n "$lan" ] && ! ip link show "$lan" >/dev/null 2>&1; then
    echo "no such interface: $lan" >&2; return 2
  fi

  case $mode in
    enable) ics_enable "$lan" "$wan" "$addr" "$dns" ;;
    disable) ics_disable "$lan" "$wan" "$addr" ;;
    status) ics_status "$lan" ;;
  esac
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  ics_main "$@"
fi
