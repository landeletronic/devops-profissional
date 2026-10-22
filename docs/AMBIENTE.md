# Ambiente do laboratório — AIOps em Produção

Documento de operação do ambiente deste projeto. Para o **plano de estudos**,
veja [`PLANO-DE-ENSINO.md`](PLANO-DE-ENSINO.md). Para as **regras permanentes**,
veja [`AGENTS.md`](AGENTS.md).

> **Arquitetura: estação Windows + servidor `pve-lab`.**
> O Windows **edita** (editor, Git, GitHub, OpenCode). O `pve-lab` **executa**
> (toolchain, repositório, cluster, serviços). **Não usar WSL2. Não usar Proxmox.**

---

## Como entrar

```powershell
ssh pve-lab        # alias no ~/.ssh/config do Windows, sem senha
```

Todo comando de infraestrutura roda **dentro da sessão SSH** do `pve-lab`.

---

## Topologia da rede do laboratório

```
192.168.15.38   Windows    ESTAÇÃO de trabalho (editor, Git, OpenCode)
192.168.15.10   pve-lab    VM Debian — EXECUÇÃO (toolchain, cluster, serviços)
```

| Host | IP | Papel | Acesso |
|---|---|---|---|
| Windows | `192.168.15.38` | estação — **não** é equipamento de testes | — |
| `pve-lab` | `192.168.15.10` (DHCP) | **VM Debian — onde tudo roda** | `ssh pve-lab` (usuário `tlandskron`) |

### Fora do escopo

- **Proxmox / `192.168.15.221`** — não usar. Não acessar a UI `:8006`, não criar
  nem gerenciar VMs por lá.
- **WSL2** — não usar. O que existia lá é legado (ver §"Legado" no final).

### ⚠️ O IP do `pve-lab` é atribuído por DHCP

O IP pode mudar e quebrar o `~/.ssh/config`, o `kubeconfig` e as notas.

**Use o alias `pve-lab`**, nunca o IP cru. Para estabilizar, crie uma **reserva
DHCP no roteador** (`192.168.15.1`) para o MAC `BC-24-11-36-B2-77`.

### Acesso SSH — estabelecido

Chave ed25519 dedicada `~/.ssh/pve-lab` no Windows, com alias `pve-lab` no
`~/.ssh/config`. Acesso **sem senha** verificado.

Chave pública instalada no `pve-lab`:

```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHkk3k99gFawuwvwruaoPaGTEcNGuIyxk93tiBiH6slf pve-lab (lab AIOps) - tlandskron@B550M-AORUS-ELITE
```

---

## Specs do `pve-lab`

| Item | Valor |
|---|---|
| SO | Debian GNU/Linux 13 (trixie) · kernel 6.12 · x86_64 |
| vCPUs | **4** (host: Intel i7-13700) |
| **RAM** | **8 GB** — VM ajustada de 4 para 8 GB |
| Swap | 4,0 GiB (partição LVM) |
| Disco | 246 GB · **232 GB livres** |
| cgroup | v2 (`cgroup2fs`) — compatível com Kubernetes |
| Rede | `ens18`, DHCP `192.168.15.10/24`, gateway `192.168.15.1` |
| DNS | resolvendo (`deb.debian.org`) |
| Estado | **instalação limpa** — só SSH rodando |

### Estado: vazia

Nada de runtime ou ferramenta está instalado:

```
curl · wget · git · jq · docker · podman · containerd · kubectl · kubeadm
kind · helm · node · npm · python3
```

Também faltam `swapon`, `fdisk`, `parted`, `nc`, `htop`. **O M0 começa com
`apt update && apt install`** — e isso é proposital: você vê uma máquina chegar
do zero.

### 8 GB comporta o cluster de 3 nós do M4

| Componente | RAM |
|---|---|
| kind control-plane | ~1,0 GiB |
| kind worker ×2 | ~1,0 GiB |
| kube-news (2 réplicas) | ~0,2 GiB |
| PostgreSQL 17 | ~0,25 GiB |
| **Total** | **~2,5 GiB** |

Com 7,5 GiB disponíveis há **folga para a turbulência do M4** (matar nós,
esgotar recursos) sem o OOM killer do host embaralhar o experimento.

### ⚠️ Swap ativo vs. requisito do Kubernetes

Kubernetes exige **swap desligado** nos nós. O `pve-lab` tem 4 GiB de swap ativo.

Como o M4 usa **kind** — cujos nós são containers dentro desta máquina — isso
**não bloqueia**. Se usar **kubeadm**, será preciso `swapoff -a` e ajustar o
`/etc/fstab`, senão o swap volta no reboot.

---

## Consequência prática de rodar tudo no `pve-lab`

Os serviços deixam de ficar em `localhost` do Windows. **Toda porta é acessada
pelo IP do servidor:**

| Antes (WSL2, mirrored) | Agora (`pve-lab`) |
|---|---|
| `http://localhost:8000/reports` | `http://192.168.15.10:8000/reports` |
| `http://localhost:3001/mcp` | `http://192.168.15.10:3001/mcp` |
| `localhost:5432` (psql) | `192.168.15.10:5432` |

Isso é **mais realista**: é assim que se acessa um servidor de verdade, e não
como se acessa uma VM local.

---

## Comandos do laboratório

Instalado como `aiops-lab` (atalho global) e como `./aiops-lab.sh` na raiz do repo.

```bash
aiops-lab up       # sobe cluster + postgres + MCP server + app, e aplica os cenarios de falha
aiops-lab status   # estado de todos os componentes
aiops-lab down     # para containers e app (mantem o cluster)
aiops-lab reset    # destroi e recria o cluster e os cenarios de falha
aiops-lab logs     # log da aplicacao do agente
aiops-lab mcplogs  # log do MCP Server
```

### Portas

| Porta | Servico | Acesso (do Windows) |
|---|---|---|
| 8000 | Agente AIOps (FastAPI) | <http://192.168.15.10:8000/reports> |
| 3001 | MCP Server Kubernetes | <http://192.168.15.10:3001/mcp> |
| 5432 | PostgreSQL 17 | `aiops:aiops123@192.168.15.10:5432/aiops_k8s` |
| 5050 | pgAdmin | <http://192.168.15.10:5050> |
| 37367 | API do kind (variável) | via `kubectl` |

---

## Onde as coisas vivem

| O quê | Onde |
|---|---|
| Editor, Git, GitHub, OpenCode | Windows |
| Chave SSH do `pve-lab` | `C:\Users\tlandskron\.ssh\pve-lab` |
| Alias `pve-lab` | `C:\Users\tlandskron\.ssh\config` |
| **Toolchain** (Docker, kind, kubectl, git) | `pve-lab` |
| **Repositório** `imersao-aiops-prod-01` | `pve-lab:~/projetos/imersao-aiops-prod-01` |
| **Cluster, Postgres, MCP, agente** | `pve-lab` |
| Notas de estudo (`notas/`) | dentro do repositório, no `pve-lab` |

---

## Ferramentas — alvo do M0

O `pve-lab` está vazio. O M0 instala:

| Ferramenta | Papel | Origem |
|---|---|---|
| `curl`, `wget`, `git`, `jq`, `ca-certificates` | base | `apt` |
| Docker Engine + Compose | containers | repo oficial do Docker |
| kubectl | cliente do cluster | binário oficial |
| kind | cluster de aprendizado | release oficial |
| Node.js 24 LTS | app `kube-news` + agente | nvm ou `apt` |
| Python 3 + `uv` | agente FastAPI + testes | `apt` + script oficial |

**Nada disso está instalado ainda.** Essa instalação é a primeira entrega do M0.

---

## ANTHROPIC_API_KEY — não usar

**Regra 1 do projeto: nenhuma API paga, em especial `ANTHROPIC_API_KEY`.**

O boilerplate do upstream usa `ChatAnthropic`. Ele **não** será configurado com
chave paga. O caminho é o **adaptador para os modelos gratuitos do OpenCode** —
ver `AGENTS.md` → Regra 1.

Atenção: a interface do agente vai mostrar o relatório como `INCOMPLETO` **até
que o adaptador exista**. Isso é esperado e **não** é um defeito do ambiente.

---

## Suítes de testes

```bash
cd ~/projetos/imersao-aiops-prod-01/boilerplate-k8s-aiops

uv run pytest            # unitários      — 214 passando
uv run pytest -m db      # banco          — 30 passando
uv run pytest -m kind    # integração com o cluster kind
uv run pytest -m e2e     # fluxo completo (usa o adaptador, nao chave paga)
```

Estado medido na montagem anterior: **214 unitários + 30 de banco passando**.
Os testes `kind` e `e2e` exigem o cluster `aiops` com contexto ativo.

---

## Comandos de diagnóstico

```bash
# logs da aplicacao
tail -f /tmp/aiops-app.log
tail -f /tmp/mcp-server.log

# estado do cluster
kubectl get pods -A
kubectl get events -A --field-selector type=Warning
kubectl describe pod <pod> -n <namespace>

# relatorios do agente
cd ~/projetos/imersao-aiops-prod-01/boilerplate-k8s-aiops
docker compose exec postgres psql -U aiops -d aiops_k8s \
  -c "select status, severity, namespace, title from reports order by created_at desc;"

# inspecionar a imagem da tabela
docker compose exec -T postgres psql -U aiops -d aiops_k8s \
  -c "\d reports"
```

---

## Reinstalação do ambiente (`pve-lab`, do zero)

Se o `pve-lab` for recriado:

```bash
# 1. base
sudo apt update && sudo apt install -y \
  curl wget git jq ca-certificates gnupg lsb-release apt-transport-https \
  software-properties-common build-essential

# 2. Docker Engine
sudo curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
sudo systemctl enable --now docker

# 3. daemon.json com live-restore
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json >/dev/null <<'JSON'
{
  "live-restore": true,
  "log-driver": "json-file",
  "log-opts": { "max-size": "10m", "max-file": "3" }
}
JSON
sudo systemctl restart docker

# 4. kubectl
KVER=$(curl -L -s https://dl.k8s.io/release/stable.txt)
curl -LO "https://dl.k8s.io/release/${KVER}/bin/linux/amd64/kubectl"
sudo install -m 0755 kubectl /usr/local/bin/kubectl

# 5. kind + jq
curl -Lo kind https://kind.sigs.k8s.io/dl/v0.31.0/kind-linux-amd64
sudo install -m 0755 kind /usr/local/bin/kind

# 6. uv (Python)
curl -LsSf https://astral.sh/uv/install.sh | sh

# 7. Node.js 24 LTS
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
export NVM_DIR="$HOME/.nvm"; . "$NVM_DIR/nvm.sh"
nvm install 24; nvm alias default 24

# 8. repositorio
mkdir -p ~/projetos && cd ~/projetos
git clone https://github.com/<upstream>/imersao-aiops-prod-01.git

# 9. lab
cd imersao-aiops-prod-01 && ./aiops-lab.sh up
```

> **`live-restore` é importante:** sem ele, reiniciar o Docker derruba todos os
> containers e o cluster kind morre junto.

---

## Legado: o que existe no WSL2 e será abandonado

> **Regra 2b: não usar WSL2.** O abaixo fica documentado apenas para não perder
> histórico — nada disso deve ser executado.

- Toolchain completa em `~/` do Ubuntu 26.04 (Node 24, uv, kubectl, kind, jq,
  Docker Engine 29.9.2, Compose v5.6.1)
- Cluster kind `aiops` (K8s v1.35.0, 1 nó) com PostgreSQL 17 + pgAdmin
- MCP Server Kubernetes na :3001, agente FastAPI na :8000
- 214 testes unitários + 30 de banco passando
- Serviço `wsl-keepalive.service` (impedia a VM de desligar por ociosidade)
- `vmIdleTimeout=-1` e `networkingMode=Mirrored` em `C:\Users\tlandskron\.wslconfig`
- `~/.aiops-env` (PATH centralizado, Node 24 sobre Node 26)
- Docker Engine nativo (não Docker Desktop — questão de licença corporativa)
