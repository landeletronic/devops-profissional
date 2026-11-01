# Runbook do laboratório — operação do ambiente AIOps

**Data:** 2026-11-01
**Para quem é:** iniciante em DevOps em transição de carreira — este é o
roteiro de **operação diária**: o que comandar, o que esperar e o que fazer
quando não sobe.

> Princípio antes do comando: um **runbook** é a receita de cozinha da
> infraestrutura — escrito para que *outra pessoa* consiga cozinhar o mesmo
> prato sem ter estado na cozinha na vez anterior. Comando sem saída esperada
> não é receita, é adivinhação (R9: sucesso só com valor observado).

---

## 1. Pré-requisitos

Antes de qualquer subcomando, confirme o essencial:

| # | Pré-requisito | Comando | Saída esperada |
|---|---|---|---|
| 1 | Acesso ao `pve-lab` | `ssh pve-lab` | shell Debian sem pedir senha |
| 2 | Docker ativo | `systemctl is-active docker` | `active` (exit 0) |
| 3 | RAM folgada | `free -m` | `available` acima de ~2000 MB |
| 4 | Disco folgado | `df -h /` | uso abaixo de ~90% |
| 5 | Script presente | `ls -l scripts/aiops-lab.sh` | permissão `-rwxr-xr-x` |
| 6 | Variáveis do lab | `grep -E 'LAB_DIR\|BOILERPLATE' scripts/aiops-lab.sh` | `LAB_DIR=$HOME/projetos/imersao-aiops-prod-01` e `BOILERPLATE` apontando para o `boilerplate-k8s-aiops` dentro dele |

**Como verificar o exit code** (o número que o shell devolve ao fim do
comando — `0` = sucesso):

```bash
systemctl is-active docker
echo "exit code: $?"
# saída esperada: active / exit code: 0
```

Em PowerShell (Windows), o equivalente é `$LASTEXITCODE` — nunca use `-match`
de string para detectar estado (ver D6 em [`DECISOES-TECNICAS.md`](DECISOES-TECNICAS.md)).

**Armadilha:** no Windows, `.sh` não roda direto. O padrão seguro é:
escrever o `.sh` → `scp` para o `pve-lab` → `ssh pve-lab "bash /tmp/x.sh"`.
O PowerShell converte `/dev/null` em `C:\dev\null` e interpreta `$(...)`
localmente (ver incidente (f) do [`PLAYBOOK-INCIDENTES.md`](PLAYBOOK-INCIDENTES.md)).

---

## 2. Os subcomandos do `aiops-lab.sh`

O script vive em `scripts/aiops-lab.sh` e aceita:
`up | down | status | logs | mcplogs | reset` (sem argumento, roda `status`).

| Subcomando | O que faz | Ação destrutiva? |
|---|---|---|
| `up` | cluster → cenários → Postgres + migrations → MCP → app (nesse ordem) | Não |
| `down` | mata uvicorn e MCP, `docker compose down` (**cluster mantido**) | Para serviços |
| `status` | Docker, pods, eventos Warning, serviços HTTP, 10 últimos relatórios | Não |
| `logs` | `tail -f /tmp/aiops-app.log` | Não |
| `mcplogs` | `tail -f /tmp/mcp-server.log` | Não |
| `reset` | `kind delete cluster` + recria cluster e cenários | **Sim — perde tudo dentro do cluster** |

### 2.1 Subir tudo

```bash
./scripts/aiops-lab.sh up
```

Sequência que o script executa (e o que você deve observar em cada etapa):

```
==> criando/subindo cluster kind 'aiops'
  OK contexto: kind-aiops
==> aplicando cenarios de falha (nginx com imagem inexistente, kube-news com senha errada)
  OK cenarios aplicados em teste-a e teste-b
==> subindo PostgreSQL + pgAdmin
  OK PostgreSQL pronto
==> aplicando migrations (alembic)
  OK migrations aplicadas
==> subindo MCP Server Kubernetes (npx, transporte HTTP)
  OK MCP Server respondendo (tentativa N)
==> subindo a aplicacao do agente AIOps
  OK aplicacao no ar (tentativa N)
```

> **Saída esperada (marcada como esperada):** a ordem acima é a que o script
> imprime. Cada linha `OK` corresponde a uma verificação real feita pelo
> próprio script (curl com `--max-time`, `pg_isready`, etc.). Se aparecer
> `!!` (warn) ou `ER` (err), vá para a seção 4.

### 2.2 Parar

```bash
./scripts/aiops-lab.sh down
# esperado:
# ==> parando a aplicacao e o MCP
#   OK containers parados (cluster kind mantido)
```

### 2.3 Status

```bash
./scripts/aiops-lab.sh status
```

Saída esperada (estrutura):

```
── Docker ──
  daemon: active
  <nome-do-container>    Up X minutes

── Kubernetes (kind) ──
  cluster: aiops
  kube-system   coredns-...   1/1   Running
  ...

── Eventos Warning ──
  ...

── Servicos ──
  MCP   :3001/mcp  -> no ar (HTTP 405)
  App   :8000/api/health -> 200

── Relatorios (PostgreSQL) ──
  status | severity | namespace | title
  ...
```

**Cuidado:** `Eventos Warning` mostra **histórico**, não estado atual — os
avisos do bootstrap continuam listados mesmo depois de resolvidos. *Evento não
é estado.*

### 2.4 Logs

```bash
./scripts/aiops-lab.sh logs        # app  → /tmp/aiops-app.log
./scripts/aiops-lab.sh mcplogs     # MCP  → /tmp/mcp-server.log
# Ctrl+C encerra o tail -f
```

### 2.5 Reset

```bash
./scripts/aiops-lab.sh reset
# esperado:
# ==> destruindo o cluster e recriando os cenarios
```

**Ação sem volta:** `reset` apaga o cluster inteiro (namespaces, pods,
configurações dentro dele). O Postgres roda **fora** do cluster (docker
compose), então os relatórios no volume `postgres_data` sobrevivem — mas
confirme antes de assumir.

---

## 3. Verificar cada componente por código (nunca por string)

**Princípio:** o número que importa é o **HTTP code** (ou o exit code). A
mensagem é só leitura complementar.

### 3.1 App FastAPI (porta 8000)

```bash
curl -s -o /dev/null -w '%{http_code}\n' http://192.168.15.10:8000/api/health
# esperado: 200

curl -s http://192.168.15.10:8000/api/health
# observado: {"status":"ok"}
```

### 3.2 MCP Server (porta 3001)

```bash
curl -s -o /dev/null -w '%{http_code}\n' http://192.168.15.10:3001/mcp
# esperado: 405   ← NÃO é erro: o endpoint exige POST (JSON-RPC)
```

### 3.3 Postgres (porta 5432, container `boilerplate-k8s-aiops-postgres-1`)

```bash
docker compose -f "$BOILERPLATE/docker-compose.yml" exec -T postgres \
  pg_isready -U aiops -d aiops_k8s
# esperado: accepting connections  (exit 0)
```

### 3.4 pgAdmin (porta do compose = 5050)

```bash
curl -s -o /dev/null -w '%{http_code}\n' http://192.168.15.10:5050/
# esperado: 200 ou 302 (redireciona para o login)
```

### 3.5 Cluster kind

```bash
kind get clusters | grep -qx aiops; echo "exit: $?"
# esperado: exit: 0

kubectl --context kind-aiops get nodes
# esperado: aiops-control-plane   Ready   control-plane   Xh   v1.37.x
```

### 3.6 Exit code no PowerShell (Windows)

```powershell
ssh pve-lab "systemctl is-active docker"
$LASTEXITCODE          # 0 = sucesso; qualquer outro = falha
```

---

## 4. Sequência de diagnóstico quando algo não sobe

Ordem recomendada — **da causa mais grosseira para a mais fina** (como um
médico: primeiro sinais vitais, depois exames):

```
1. A máquina responde?          ssh pve-lab
2. O Docker está ativo?         systemctl is-active docker   → exit 0?
3. Tem RAM livre?               free -m                      → available > 2000?
4. Tem disco?                   df -h /                      → uso < 90%?
5. O cluster está vivo?         kubectl get nodes             → Ready?
6. O que os eventos dizem?      kubectl get events -A --field-selector type=Warning
7. O serviço responde?          curl -s -o /dev/null -w '%{http_code}' <url>
8. O log do serviço diz o quê?  tail -n 50 /tmp/aiops-app.log (ou mcplogs)
```

Interpretação dos sinais:

| Sinal observado | Provável causa | Ver |
|---|---|---|
| `ssh` → `Connection timed out during banner exchange` | VM em thrashing de swap | Incidente (b) do Playbook |
| `kubectl` → `dial tcp 127.0.0.1:35735: connect: connection refused` | nó do kind morto (OOM 137) | Incidente (a) do Playbook |
| `error: Failed to spawn: alembic / cause: No such file or directory` | `.venv` com shebangs quebrados | Incidente (c) do Playbook |
| `uvicorn: command not found` via SSH | shell não-interativo sem PATH | Incidente (d) do Playbook |
| curl em `localhost` no Windows não conecta | localhost é relativo a quem pergunta | Incidente (e) do Playbook |

**Cuidado:** leia a **mensagem inteira** antes de diagnosticar — um `mv` para
diretório inexistente falha com o caminho do destino no erro; metade da
mensagem vira diagnóstico errado (lição 8).

---

## 5. Confirmar que os cenários `teste-a` / `teste-b` estão corretos

**Princípio:** nestes namespaces, **a falha é o resultado esperado**. Um
cenário "quebrado de verdade" seria um cenário mal plantado.

### 5.1 `teste-a` — imagem inexistente (`ngin:latest`)

```bash
kubectl --context kind-aiops get pods -n teste-a
# observado (esperado): STATUS = ImagePullBackOff (ou ErrImagePull)

kubectl --context kind-aiops get pods -n teste-a -o wide
# esperado: imagem ngin:latest (sem o "x" do nginx)
```

### 5.2 `teste-b` — senha errada de banco

```bash
kubectl --context kind-aiops get pods -n teste-b
# esperado: pods do kube-news em ERROR; o pod do postgre em Running
```

**Armadilha:** quem está começando costuma "consertar" o cenário vendo
`ImagePullBackOff` e corrigindo a imagem. Não faça isso — o cenário é de
**estudo de incidente**: o errado é o diagnóstico precipitado, não o pod.

---

## 6. Checklist de encerramento (resumo)

- [ ] `./scripts/aiops-lab.sh status` sem `ER`
- [ ] `GET /api/health` → `200`
- [ ] `GET :3001/mcp` → `405`
- [ ] `pg_isready` → exit 0
- [ ] `kubectl get nodes` → `Ready`
- [ ] `teste-a` → `ImagePullBackOff`; `teste-b` → `Error` (falhas intencionais)
- [ ] Nenhum token no log, no chat ou no commit (R4)

Para a auditoria completa, use o
[`CHECKLIST-VERIFICACAO.md`](CHECKLIST-VERIFICACAO.md).

---

*Runbook de estudo. Comandos e saídas refletem o laboratório em 2026-11-01;
saídas marcadas como "esperado" são o alvo de verificação, não gravação de
produção.*
