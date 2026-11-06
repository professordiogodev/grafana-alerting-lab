#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
trap 'kill 0' EXIT
$K -n $NS port-forward svc/grafana 3000:3000 >/dev/null &
$K -n $NS port-forward svc/prometheus 9090:9090 >/dev/null &
$K -n $NS port-forward svc/pizzeria 8080:8080 >/dev/null 2>&1 &
say "Grafana http://localhost:3000 (admin / pizza)    Prometheus http://localhost:9090"
wait
