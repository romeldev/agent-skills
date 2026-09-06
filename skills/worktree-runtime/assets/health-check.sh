#!/usr/bin/env bash
#
# health-check.sh — stack-agnostic HTTP verification for worktree services.
#
# PURPOSE
#   The evidence half of worktree-runtime: never declare a worktree "ready"
#   without a real HTTP response on every service and on the front->back link.
#   A curl 2xx/3xx response per target is the only thing that counts.
#
# USAGE
#   ./health-check.sh <name> <url> [<name> <url> ...]
#   ./health-check.sh < file.txt      # lines:  name<TAB>url  (or two columns)
#
# EXAMPLES
#   ./health-check.sh frontend http://localhost:3011 backend http://localhost:8011/health
#   printf 'frontend\t%s\nbackend\t%s\n' \
#     'http://localhost:3011' 'http://localhost:8011/health' | ./health-check.sh
#
# EXIT
#   0  every target responded with an HTTP status (any 2xx/3xx)
#   1  at least one target failed (connection error, timeout, 4xx/5xx)
#   2  usage error
#
# REQUIREMENTS
#   curl. POSIX sh + bashisms avoided; bash 3.2+ compatible.
#
# LICENSE
#   MIT — reference script for the worktree-runtime skill.

set -euo pipefail

TIMEOUT_SECS="${WORKTREE_HEALTH_TIMEOUT:-5}"

failures=0
targets=0

check_one() {
  local name="$1" url="$2" code ts
  targets=$((targets + 1))

  # -s silent, -L follow redirects (3xx), -o /dev/null discard body,
  # -w write code, --max-time bound the wait.
  code="$(curl -s -L -o /dev/null --max-time "$TIMEOUT_SECS" -w '%{http_code}' "$url" 2>/dev/null)" \
    || code="000"
  ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if [ "$code" = "000" ]; then
    printf 'FAIL    %-20s %-40s error at %s\n' "$name" "$url" "$ts"
    failures=$((failures + 1))
    return 1
  fi
  case "$code" in
    2*|3*)
      printf 'OK      %-20s %-40s HTTP %s at %s\n' "$name" "$url" "$code" "$ts"
      ;;
    *)
      printf 'FAIL    %-20s %-40s HTTP %s at %s\n' "$name" "$url" "$code" "$ts"
      failures=$((failures + 1))
      ;;
  esac
}

read_targets() {
  # Lines of name<TAB>url read from the given stdin (or the calling stdin).
  local name url
  while IFS=$'\t' read -r name url; do
    [ -n "${name:-}" ] || continue
    [ -n "${url:-}" ] || continue
    check_one "$name" "$url" || true
  done
}

main() {
  if [ "$#" -eq 0 ]; then
    if [ -t 0 ]; then
      # Interactive terminal and no args: nothing to check.
      echo "usage: $0 <name> <url> [<name> <url> ...]" >&2
      echo "       $0 < targets.txt        # lines: name<TAB>url" >&2
      echo "       $0 targets.txt          # same content via file" >&2
      exit 2
    fi
    read_targets          # stdin redirected: consume it
  elif [ "$#" -eq 1 ] && [ -f "$1" ]; then
    read_targets < "$1"  # named target file
  else
    if [ "$(( $# % 2 ))" -ne 0 ]; then
      echo "health-check: odd number of arguments; expected name url pairs" >&2
      exit 2
    fi
    while [ "$#" -ge 2 ]; do
      check_one "$1" "$2" || true
      shift 2
    done
  fi

  echo "# targets=$targets failures=$failures"
  [ "$failures" -eq 0 ]
}

main "$@"