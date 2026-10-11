# ubuntu

Scripts and notes for Ubuntu hosts, applied by hand rather than through `dotfm`.

| File | What it does |
|---|---|
| `ics.sh` | shares the host's internet connection with a second interface, like Windows ICS; usage is in its header |
| `ics.test.sh` | tests for `ics.sh` that need no root |

## Sharing a connection

Both setups below share `<wan>` (the interface with the default route) with a
subnet on `<lan>`, IPv4 only. systemd-networkd masquerades the subnet, and ufw
lets its traffic out; netplan has no setting for either.

| | `ics.sh enable` | NAT only, by hand |
|---|---|---|
| `<lan>` address | set by `05-ics-<lan>.network`, which wins over netplan's file for that interface | left to netplan |
| DHCP and DNS for the subnet | served from the host | none; hosts are configured statically |
| Files | `05-ics-<lan>.network`, `60-ics.conf`, two ufw rules | one networkd drop-in, one ufw rule |

Use `ics.sh` for a new segment. Use the NAT-only setup when netplan already
gives `<lan>` an address and the hosts on it keep theirs.

### NAT only, by hand

```bash
sudo mkdir -p /etc/systemd/network/10-netplan-<lan>.network.d
printf '[Network]\nIPMasquerade=ipv4\n' |
  sudo tee /etc/systemd/network/10-netplan-<lan>.network.d/masquerade.conf
sudo networkctl reload
sudo ufw route allow in on <lan> out on <wan> from 192.168.137.0/24
```

The drop-in extends the `.network` file netplan generates under
`/run/systemd/network/`, so `netplan apply` leaves it in place.
`IPMasquerade=ipv4` also turns on IPv4 forwarding for the interface. Replies
come back through ufw's default rule for established connections.

Hosts on the subnet use the host's `<lan>` address as their gateway and any
reachable DNS server.

Check:

```bash
sudo ufw status verbose | grep -E 'FWD|Default'   # ALLOW FWD ... on <lan>
sudo nft list table ip io.systemd.nat            # ip saddr @masq_saddr masquerade
```

Remove:

```bash
sudo ufw route delete allow in on <lan> out on <wan> from 192.168.137.0/24
sudo rm -r /etc/systemd/network/10-netplan-<lan>.network.d
sudo networkctl reload
```

### Pitfalls

- **`iptables-persistent` removes ufw.** The two packages conflict, so
  installing it uninstalls ufw and leaves the host with no firewall. It also
  saves Docker's rules and restores them at boot, ahead of Docker's own. Keep
  ufw, and recover with `sudo apt install ufw`, which brings back the rules
  kept in `/etc/ufw` and removes `iptables-persistent` in turn.
- **Ports published by Docker bypass ufw.** Docker's chains accept them before
  ufw's rules are reached, so `ufw deny` does not close them. Bind them to
  `127.0.0.1` in the compose file instead.
- **Docker's FORWARD policy is DROP**, the same as ufw's routed default.
  Without the `ufw route` rule the subnet gets an address and a gateway and
  still cannot reach anything past the host.
- **`ufw route allow` on an inactive ufw prints `ERROR: problem running`**
  (ufw 0.36.2) and still saves the rule; after `ufw enable` the same command
  reports `Skipping adding existing rule`.
