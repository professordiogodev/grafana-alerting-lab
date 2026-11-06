#!/usr/bin/env bash
# Installs: Prometheus, Grafana, the pizzeria and a webhook sink, all in namespace 'alerting-lab'.
source "$(dirname "$0")/common.sh"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts >/dev/null 2>&1 || true
helm repo add grafana https://grafana.github.io/helm-charts >/dev/null 2>&1 || true
helm repo update >/dev/null

say "Apps: pizzeria + webhook sink"
$K apply -f "$ROOT/manifests/10-apps.yaml"
$K -n $NS create configmap pizzeria-code --from-file="$ROOT/app/pizzeria.py" --dry-run=client -o yaml | $K apply -f -
$K -n $NS create configmap webhook-sink-code --from-file="$ROOT/app/webhook_sink.py" --dry-run=client -o yaml | $K apply -f -

say "Prometheus"
$H upgrade --install prometheus prometheus-community/prometheus -n $NS -f "$ROOT/helm/prometheus-values.yaml" --wait --timeout 5m

say "Grafana"
EXTRA=()
if [[ -n "${SOLUTION:-}" ]]; then
  $K -n $NS create configmap alerting-solution --from-file="$ROOT/solution/alerting" --dry-run=client -o yaml | $K apply -f -
  EXTRA=(-f "$ROOT/solution/mount-values.yaml")
fi
$H upgrade --install grafana grafana/grafana -n $NS -f "$ROOT/helm/grafana-values.yaml" \
  --set-file dashboards.lab.pizzeria.json="$ROOT/dashboard.json" ${EXTRA[@]+"${EXTRA[@]}"} --wait --timeout 5m

$K -n $NS rollout status deploy/pizzeria deploy/webhook-sink --timeout=180s
say "Ready! Run ./scripts/pf.sh  → Grafana http://localhost:3000 (admin / pizza)"
