#!/usr/bin/env bash
set -euo pipefail

show="all"

while [[ $# -gt 0 ]]; do
  case $1 in
    --show) show="$2"; shift 2 ;;
    *) echo "Unknown parameter: $1"; exit 1 ;;
  esac
done

if [[ "$show" == "all" || "$show" == "hostname" ]]; then
  echo "Hostname: $(hostname)"
  if [[ "$show" == "hostname" ]]; then exit 0; fi
fi

if [[ "$show" == "all" || "$show" == "ipv4" ]]; then
  echo "IPv4 Addresses:"
  if command -v ip >/dev/null 2>&1; then
    ip -4 addr show scope global | grep -oP '(?<=inet )\S+' | sed 's/^/  /' || true
  else
    ifconfig | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | sed 's/^/  /' || true
  fi
  if [[ "$show" == "ipv4" ]]; then exit 0; fi
fi

if [[ "$show" == "all" || "$show" == "ipv6" ]]; then
  echo "IPv6 Addresses:"
  if command -v ip >/dev/null 2>&1; then
    ip -6 addr show scope global | grep -oP '(?<=inet6 )\S+' | sed 's/^/  /' || true
  else
    ifconfig | grep 'inet6 ' | grep -v '::1' | awk '{print $2}' | sed 's/^/  /' || true
  fi
  if [[ "$show" == "ipv6" ]]; then exit 0; fi
fi

if [[ "$show" == "interfaces" ]]; then
  if command -v ip >/dev/null 2>&1; then
    ip addr show
  else
    ifconfig
  fi
  exit 0
fi

if [[ "$show" == "all" || "$show" == "external" ]]; then
  ext_ip=$(curl -s --max-time 5 https://api.ipify.org || echo "[Failed to fetch - network access issue]")
  echo "External IP: $ext_ip"
  if [[ "$show" == "external" ]]; then exit 0; fi
fi
