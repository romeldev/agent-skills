#!/usr/bin/env bash
#
# port-audit.sh — stack-agnostic listening-port inventory and free-port check.
#
# PURPOSE
#   Evidence before picking ports for a new worktree. Never trust a documented
#   port table alone: another process (or a stale config) may hold a port.
#   This script lists what is actually listening and/or verifies candidates.
#
# USAGE
#   ./port-audit.sh                 # list every listening TCP/UDP port
#   ./port-audit.sh 3011 8011       # verify candidates are FREE (exit 0/1)
#
# EXIT
#   0  all listed ports are free (or, with no args, inventory listed OK)
#   1  at least one listed port is occupied
#   2  no inventory tool available (ss/lsof) or invalid argument
#
# REQUIREMENTS
#   Linux:  ss (iproute2) — standard on modern distros
#   macOS:  lsof — ships with the OS
#   bash 3.2+ compatible, no external deps.
#
# NOTES
#   The parser does not assume a fixed column layout: `ss -tlnu` column order
#   differs between TCP/UDP rows and between iproute2 versions, so we scan
#   every field for the "local address:port" token ending in :<digits>.
#
# LICENSE
#   MIT — reference script for the worktree-runtime skill.

set -euo pipefail

listening() {
  if command -v ss >/dev/null 2>&1; then
    # Match the FIRST token ending in :<digits> on each row (the local
    # address). Works for TCP (tcp LISTEN 0 N addr peer) and UDP
    # (udp UNCONN 0 0 addr peer) and for IPv6 ([::]:port).
    ss -H -tlnu 2>/dev/null \
      | awk '{ for (i = 1; i <= NF; i++) if ($i ~ /:[0-9]+$/) { n = split($i, a, ":"); print a[n]; break } }' \
      | sort -n -u
  elif command -v lsof >/dev/null 2>&1; then
    lsof -nP -iTCP -sTCP:LISTEN -iUDP 2>/dev/null \
      | awk 'NR>1 {print $9}' \
      | sed -E 's/.*:([0-9]+)$/\1/' \
      | sort -n -u
  else
    echo "port-audit: no ss nor lsof available; cannot inventory ports" >&2
    return 2
  fi
}

main() {
  if [ "$#" -eq 0 ]; then
    if ! listening >/tmp/port-audit.$$; then
      rm -f /tmp/port-audit.$$
      return 2
    fi
    echo "# Listening ports:"
    tr '\n' ' ' < /tmp/port-audit.$$
    echo
    echo "# Note: prefer ss/lsof output as ground truth over config files."
    rm -f /tmp/port-audit.$$
    return 0
  fi

  local port token
  local status=0
  # Build a single awk-side set once instead of re-scanning per port.
  local audit
  audit="$(listening)" || return 2

  if [ -z "$audit" ]; then
    echo "port-audit: empty inventory — is ss/lsof working? refusing to call ports free" >&2
    return 2
  fi

  for port in "$@"; do
    case "$port" in
      ''|*[!0-9]*)
        echo "port-audit: invalid port '$port'" >&2
        status=2
        continue
        ;;
    esac
    if printf '%s\n' "$audit" | grep -qx "$port"; then
      echo "OCCUPIED  :$port"
      status=1
    else
      echo "FREE      :$port"
    fi
  done
  return "$status"
}

main "$@"