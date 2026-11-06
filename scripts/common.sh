set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CTX="${CTX:-orbstack}"           # override: export CTX=docker-desktop
NS=alerting-lab
K="kubectl --context $CTX"
H="helm --kube-context $CTX"
say() { printf '\n\033[1;35m🚨 %s\033[0m\n' "$*"; }
for bin in kubectl helm; do command -v $bin >/dev/null || { echo "missing: $bin"; exit 1; }; done
$K cluster-info >/dev/null 2>&1 || { echo "❌ cluster for context '$CTX' not reachable (OrbStack: 'orb start k8s')"; exit 1; }
