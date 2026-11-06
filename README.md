# 🚨 Grafana Alerting Lab

A **30-minute** hands-on lab: create alert rules in Grafana, route them with notification policies, and get paged when a pizzeria's oven catches fire. Runs on any local Kubernetes cluster.

Companion of [k8s-monitoring-lab](https://github.com/professordiogodev/k8s-monitoring-lab) (Prometheus, Grafana, Loki). This lab is standalone: it installs its own small Prometheus + Grafana in the `alerting-lab` namespace.

## Quick start

Requirements: local Kubernetes ([OrbStack](https://orbstack.dev), Docker Desktop, kind, minikube), `kubectl`, `helm`.

```bash
git clone https://github.com/professordiogodev/grafana-alerting-lab
cd grafana-alerting-lab
./scripts/up.sh        # default kube-context "orbstack"; else: export CTX=<your-context>
./scripts/pf.sh        # Grafana http://localhost:3000 (admin / pizza)
```

Then follow **[labs/alerting.md](labs/alerting.md)**.

Break the oven: `./scripts/chaos.sh fire` · Fix: `./scripts/chaos.sh off` · Solution: `./scripts/solution.sh` · Clean: `./scripts/down.sh`

## Layout

```
app/                 pizzeria app + webhook sink (python stdlib, mounted via ConfigMap)
manifests/           deployments
helm/                Prometheus and Grafana values
solution/            alerting as code (rules, contact points, policies, mute timing)
labs/alerting.md     the lab
```

License: MIT
