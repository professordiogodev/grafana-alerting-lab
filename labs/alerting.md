# 🚨 Lab: Alerting in Grafana (30 min)

Goal: get **paged for a burning oven**, route alerts by severity, and silence the noise.

```
 Prometheus ◄── alert rule (evaluated by Grafana every 10s)
                     │ fires
                     ▼
              notification policy ──► severity=critical ──► contact point "pager"
                     │
                     └─ default ───────────────────────────► contact point "kitchen-log"
                                                                   │
                                      webhook-sink pod (kubectl logs) 📬
```

## 0. Setup (5 min)

```bash
./scripts/up.sh          # ~2 min. Default context 'orbstack', else: export CTX=<ctx>
./scripts/pf.sh          # spare terminal. Grafana http://localhost:3000  admin / pizza
```

In a **second** spare terminal, watch where alerts land:

```bash
kubectl --context orbstack -n alerting-lab logs -f deploy/webhook-sink
```

Open the **🍕 Pizzeria (alerting lab)** dashboard (folder *Pizzeria*). You should see two pods with ~0% burnt.

## 1. Contact points (5 min)

*Alerting → Contact points → Add contact point*

| Name | Integration | URL |
|------|-------------|-----|
| `kitchen-log` | Webhook | `http://webhook-sink.alerting-lab.svc:8080/kitchen` |
| `pager` | Webhook | `http://webhook-sink.alerting-lab.svc:8080/pager` |

Press **Test** on each. A 📬 message appears in the sink logs. ✅

## 2. Your first alert rule (8 min)

*Alerting → Alert rules → New alert rule*

1. **Name**: `Burnt pizzas`
2. **Query A** (Prometheus), switch to *Code* mode:
   ```promql
   sum by (pod) (rate(pizzeria_orders_total{status="burnt"}[1m])) / sum by (pod) (rate(pizzeria_orders_total[1m]))
   ```
   Set it as an **Instant** query.
3. **Expressions**: *Reduce* B = last of A. *Threshold* C = B **is above** `0.2`. Set C as the alert condition.
4. **Folder**: create `Pizzeria`. **Evaluation group**: `pizzeria`, interval `10s`. **Pending period**: `30s`.
5. **Labels**: `severity = critical`, `team = kitchen`
6. **Annotations → Summary**:
   ```
   {{ $labels.pod }}: {{ humanizePercentage $values.B.Value }} of pizzas are burnt 🔥
   ```
7. **Contact point**: leave to the *notification policy* (next step). Save.

> 💡 Because the query is `sum by (pod)`, Grafana creates **one alert instance per pod**: a multi-dimensional alert. One rule, many alerts.

## 3. Notification policy (5 min)

*Alerting → Notification policies*

- Edit the **default policy**: contact point `kitchen-log`, group by `alertname`, `pod`. Under *Timing options* set group wait `5s`, group interval `30s`.
- **Add nested policy**: label `severity` `=` `critical` → contact point `pager`.

## 4. Light the fire (5 min)

```bash
./scripts/chaos.sh fire        # burns pod #0
```

Watch: *Alert rules* (Normal → **Pending** → **Firing**), the dashboard, and the webhook-sink logs. Within ~1.5 minutes you get:

```
===== 📬 12:03:41  channel=/pager  status=🔥 FIRING =====
  🔥 FIRING  Burnt pizzas  severity=critical  pod=pizzeria-...
     summary: pizzeria-...: 61% of pizzas are burnt 🔥
```

Only the **burnt pod** alerts. The other pod stays Normal.

Fix it and watch the ✅ RESOLVED notification:

```bash
./scripts/chaos.sh off
```

## 5. Silence & mute (2 min)

- **Silence** (one-off): *Alerting → Silences → New*, matcher `team = kitchen`, 10 minutes. Run `chaos.sh fire` again: the alert fires but **no notification** arrives. Remove the silence.
- **Mute timing** (recurring): *Notification policies → Mute timings → Add*: `night-shift`, 02:00 to 05:00. Attach it to the `critical` policy.

## 6. Bonus - a second alert (do as many as you have time for)

- **Warning alert**: p95 bake time above 4s for 30s (normal is ~2s), `severity=warning`. Trigger with `./scripts/chaos.sh slow`. Which contact point receives it? (default policy → `kitchen-log`)
- **No data**: `kubectl --context orbstack -n alerting-lab scale deploy/pizzeria --replicas=0`. What state does your rule go to? Change *No data handling* to *Alerting* and try again. Scale back to 2.
- **Alert on logs?** Loki can do this too (see the monitoring lab).

## Stuck?

```bash
./scripts/solution.sh      # loads the complete provisioned setup (rules, contact points, policies, mute timing)
```
Compare it with `solution/alerting/`.

## Good alert rules (take-away)

- Alert on **symptoms** (burnt pizzas), not causes (oven temp)
- Every alert needs an owner, a severity, and a "what do I do" annotation
- Use `for:` to avoid flapping; group to avoid alert storms
- If nobody acts on an alert, **delete it**

Cleanup: `./scripts/down.sh`
