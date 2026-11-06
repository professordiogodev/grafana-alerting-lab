#!/usr/bin/env bash
# Stuck? Load the complete, provisioned solution (alert rules, contact points, policies, mute timing).
# Warning: Grafana restarts, and UI-built alert resources are kept but may collide in names.
cd "$(dirname "$0")/.." && SOLUTION=1 ./scripts/up.sh
