#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
$H uninstall grafana -n $NS 2>/dev/null || true
$H uninstall prometheus -n $NS 2>/dev/null || true
$K delete ns $NS --ignore-not-found
say "Clean 🧹"
