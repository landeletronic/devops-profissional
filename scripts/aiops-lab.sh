#!/usr/bin/env bash
# =============================================================================
#  aiops-lab — subir / parar / status do ambiente AIOps completo
# =============================================================================
#  Uso:
#    ./aiops-lab.sh up       -> sobe cluster kind, postgres, MCP server e app
#    ./aiops-lab.sh down     -> para tudo (containers e app)
#    ./aiops-lab.sh status   -> mostra o estado de cada componente
#    ./aiops-lab.sh logs     -> segue os logs da app
#    ./aiops-lab.sh reset    -> destroi e recria o cluster e os cenarios de falha
# =============================================================================
set -uo pipefail

# shellcheck disable=SC1091
[ -f "$HOME/.aiops-env" ] && . "$HOME/.aiops-env"

LAB_DIR="${LAB_DIR:-$HOME/projetos/imersao-aiops-prod-01}"
BOILERPLATE="$LAB_DIR/boilerplate-k8s-aiops"
CLUSTER="${CLUSTER:-aiops}"
APP_PORT="${APP_PORT:-8000}"
MCP_PORT="${MCP_PORT:-3001}"

log()  { printf '\033[1;36m==>\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m  OK\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m  !!\033[0m %s\n' "$*"; }
err()  { printf '\033[1;31m  ER\033[0m %s\n' "$*"; }

ensure_docker() {
  if ! systemctl is-active --quiet docker; then
    log "subindo o daemon do Docker"
    sudo systemctl start docker
  fi
}

# ---------- cluster kind ----------
up_cluster() {
  ensure_docker
  if kind get clusters 2>/dev/null | grep -qx "$CLUSTER"; then
    ok "cluster kind '$CLUSTER' ja existe"
  else
    log "criando cluster kind '$CLUSTER'"
    kind create cluster --name "$CLUSTER" --wait 180s || { err "falha ao criar o cluster"; return 1; }
  fi
  kubectl config use-context "kind-$CLUSTER" >/dev/null
  ok "contexto: kind-$CLUSTER"
}

# ---------- cenarios de falha (PRD 001) ----------
up_scenarios() {
  kubectl --context "kind-$CLUSTER" create namespace teste-a 2>/dev/null
  kubectl --context "kind-$CLUSTER" create namespace teste-b 2>/dev/null
  log "aplicando cenarios de falha (nginx com imagem inexistente, kube-news com senha errada)"
  kubectl --context "kind-$CLUSTER" apply -n teste-a -f "$BOILERPLATE/manifestos-k8s/nginx.yaml"    >/dev/null
  kubectl --context "kind-$CLUSTER" apply -n teste-b -f "$BOILERPLATE/manifestos-k8s/kube-news.yaml" >/dev/null
  ok "cenarios aplicados em teste-a e teste-b"
}

# ---------- postgres ----------
up_db() {
  ensure_docker
  log "subindo PostgreSQL + pgAdmin"
  ( cd "$BOILERPLATE" && docker compose up -d ) || { err "falha no docker compose"; return 1; }
  for _ in $(seq 1 30); do
    if docker compose -f "$BOILERPLATE/docker-compose.yml" exec -T postgres \
        pg_isready -U aiops -d aiops_k8s >/dev/null 2>&1; then
      ok "PostgreSQL pronto"
      break
    fi
    sleep 2
  done
  log "aplicando migrations (alembic)"
  ( cd "$BOILERPLATE" && uv run alembic upgrade head >/dev/null 2>&1 ) \
    && ok "migrations aplicadas" || warn "falha nas migrations (veja o log)"
}

# ---------- MCP server ----------
up_mcp() {
  mcp_code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 3 "http://localhost:$MCP_PORT/mcp" 2>/dev/null || echo 000)
  if [ "$mcp_code" = "200" ] || [ "$mcp_code" = "405" ]; then
    ok "MCP Server ja responde em :$MCP_PORT (HTTP $mcp_code)"
    return 0
  fi
  log "subindo MCP Server Kubernetes (npx, transporte HTTP)"
  setsid nohup env ENABLE_UNSAFE_STREAMABLE_HTTP_TRANSPORT=1 PORT="$MCP_PORT" \
    npx -y mcp-server-kubernetes > /tmp/mcp-server.log 2>&1 < /dev/null &
  disown 2>/dev/null || true
  for i in $(seq 1 40); do
    mcp_code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 2 "http://localhost:$MCP_PORT/mcp" 2>/dev/null || echo 000)
    if [ "$mcp_code" = "200" ] || [ "$mcp_code" = "405" ]; then
      ok "MCP Server respondendo (tentativa $i)"
      return 0
    fi
    sleep 3
  done
  warn "MCP Server nao respondeu; veja /tmp/mcp-server.log"
  return 1
}

# ---------- aplicacao ----------
up_app() {
  if curl -sf -o /dev/null --max-time 3 "http://localhost:$APP_PORT/api/health" 2>/dev/null; then
    ok "aplicacao ja responde em :$APP_PORT"
    return 0
  fi
  log "subindo a aplicacao do agente AIOps"
  ( cd "$BOILERPLATE" && setsid nohup uv run uvicorn my_agent_app.main:app \
      --host 0.0.0.0 --port "$APP_PORT" > /tmp/aiops-app.log 2>&1 < /dev/null & ) 
  for i in $(seq 1 40); do
    if curl -sf -o /dev/null --max-time 2 "http://localhost:$APP_PORT/api/health" 2>/dev/null; then
      ok "aplicacao no ar (tentativa $i)"
      return 0
    fi
    sleep 2
  done
  warn "aplicacao nao respondeu; veja /tmp/aiops-app.log"
  return 1
}

status() {
  printf '\n\033[1m── Docker ──\033[0m\n'
  systemctl is-active docker 2>/dev/null | sed 's/^/  daemon: /'
  docker ps --format '  {{.Names}}\t{{.Status}}' 2>/dev/null
  printf '\n\033[1m── Kubernetes (kind) ──\033[0m\n'
  kind get clusters 2>/dev/null | sed 's/^/  cluster: /'
  kubectl get pods -A --no-headers 2>/dev/null | awk '{printf "  %-12s %-14s %-10s %s\n",$1,$2,$3,$4}'
  printf '\n\033[1m── Eventos Warning ──\033[0m\n'
  kubectl get events -A --field-selector type=Warning --no-headers 2>/dev/null | head -10 | sed 's/^/  /'
  printf '\n\033[1m── Servicos ──\033[0m\n'
  # o endpoint MCP responde 405 em GET (exige POST/JSON-RPC): 405/200 = no ar
  mcp_code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 3 "http://localhost:$MCP_PORT/mcp" 2>/dev/null || echo 000)
  if [ "$mcp_code" = "200" ] || [ "$mcp_code" = "405" ]; then
    echo "  MCP   :$MCP_PORT/mcp  -> no ar (HTTP $mcp_code)"
  else
    echo "  MCP   :$MCP_PORT -> offline (HTTP $mcp_code)"
  fi
  curl -sf -o /dev/null -w "  App   :$APP_PORT/api/health -> %{http_code}\n" --max-time 3 "http://localhost:$APP_PORT/api/health" 2>/dev/null || echo "  App   :$APP_PORT -> offline"
  printf '\n\033[1m── Relatorios (PostgreSQL) ──\033[0m\n'
  ( cd "$BOILERPLATE" && docker compose exec -T postgres psql -U aiops -d aiops_k8s \
      -c "select status, severity, namespace, title from reports order by created_at desc limit 10;" 2>/dev/null ) | sed 's/^/  /'
  echo
}

cmd="${1:-status}"
case "$cmd" in
  up)
    up_cluster && up_scenarios && up_db && up_mcp && up_app
    echo; status
    ;;
  down)
    log "parando a aplicacao e o MCP"
    pkill -f 'uvicorn my_agent_app.main:app' 2>/dev/null
    pkill -f 'mcp-server-kubernetes' 2>/dev/null
    ( cd "$BOILERPLATE" && docker compose down ) 2>/dev/null
    ok "containers parados (cluster kind mantido)"
    ;;
  reset)
    log "destruindo o cluster e recriando os cenarios"
    kind delete cluster --name "$CLUSTER" 2>/dev/null
    up_cluster && up_scenarios
    ;;
  status) status ;;
  logs)   tail -f /tmp/aiops-app.log ;;
  mcplogs) tail -f /tmp/mcp-server.log ;;
  *) echo "uso: $0 {up|down|status|logs|mcplogs|reset}"; exit 1 ;;
esac
