#!/usr/bin/env bash
# ./scripts/chaos.sh fire|slow|rush|off  [pod-index 0|1]
# fire|slow|rush break ONE pod; off fixes all pods.
source "$(dirname "$0")/common.sh"
MODE="${1:-fire}"
hit() { $K -n $NS exec "$1" -- wget -qO- "http://127.0.0.1:8080/chaos?mode=$MODE"; }
PODS=($($K -n $NS get pods -l app=pizzeria -o name))
if [[ "$MODE" == "off" ]]; then for p in "${PODS[@]}"; do hit "$p" >/dev/null; done; say "all ovens fixed ✅"; exit 0; fi
POD="${PODS[${2:-0}]}"
say "chaos '$MODE' -> $POD"; hit "$POD"
