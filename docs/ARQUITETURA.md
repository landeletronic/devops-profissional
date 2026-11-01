# Arquitetura do laboratório AIOps

**Data:** 2026-11-01
**Para quem é:** iniciante em DevOps em transição de carreira — este documento
explica *como o laboratório está montado* antes de qualquer comando.

> Caderno de estudo do repositório
> [`devops-profissional`](https://github.com/landeletronic/devops-profissional).
> Tudo aqui é ambiente de **estudo**, não de produção.

---

## 1. Por que duas máquinas?

Antes de falar de IP e porta, o **princípio**: separar *onde se edita* de
*onde se executa* evita uma classe inteira de bugs.

**Analogia do dia a dia:** pense em uma oficina mecânica. O **balcão de
atendimento** (Windows) é onde você escreve a ordem de serviço, conversa com o
cliente e arquiva os papéis. A **oficina** (pve-lab) é onde o carro entra, a
ferramenta suja e o motor abre. Você não lifta o carro no balcão — mas também
não escreve a nota fiscal no chão da oficina.

Se o editor, o Git e o cluster rodassem na mesma máquina, cada teste arriscado
poderia quebrar o próprio ambiente de trabalho. Com a separação:

- **Windows** só edita e versiona (editor, Git, agente). **Nunca executa
  containers.**
- **pve-lab** executa tudo (Docker, Kubernetes, banco, serviços). Se algo
  quebrar lá, o balcão continua funcionando.

### Regras que decorrem da separação (R2 e R3)

- `pve-lab` é uma **VM Debian comum** (`192.168.15.10`). **Nunca** Proxmox,
  nunca `192.168.15.221`, nunca porta `8006` (R2).
- **Sem WSL2** (R3): o que existiu em WSL2 é legado; a execução é sempre via
  SSH no `pve-lab`.

---

## 2. Diagrama geral (rede `192.168.15.0/24`)

```
                     REDE LOCAL 192.168.15.0/24
 ┌─────────────────────────────┐        ┌──────────────────────────────────────────────┐
 │  WINDOWS  192.168.15.38     │        │  PVE-LAB (VM Debian)  192.168.15.10          │
 │  ESTAÇÃO — só edita         │        │  EXECUTA TUDO                                │
 │                             │        │                                              │
 │  • editor de código         │  SSH   │  ssh pve-lab (alias, chave ed25519)          │
 │  • Git + GitHub             │ ─────► │                                              │
 │  • agente (OpenCode)        │  SCP   │  ┌────────────────────────────────────────┐  │
 │                             │ ─────► │  │ Docker Engine                         │  │
 │  NUNCA executa containers   │        │  │  ┌──────────────────────────────────┐ │  │
 │                             │  HTTP  │  │  │ cluster kind "aiops" (1 node)    │ │  │
 │  curl/navegador ────────────│ ─────► │  │  │  aiops-control-plane (container)│ │  │
 │  (testa os serviços abaixo) │        │  │  │                                  │ │  │
 │                             │        │  │  │  ns teste-a → nginx "ngin:latest"│ │  │
 │                             │        │  │  │        → ImagePullBackOff (ok!)  │ │  │
 │                             │        │  │  │  ns teste-b → kube-news (senha   │ │  │
 │                             │        │  │  │        errada) → Error (ok!)     │ │  │
 │                             │        │  │  └──────────────────────────────────┘ │  │
 │                             │        │  │  ┌──────────────┐ ┌─────────────────┐ │  │
 │                             │        │  │  │ app FastAPI  │ │ MCP Server      │ │  │
 │                             │        │  │  │ uvicorn :8000│ │ npx       :3001 │ │  │
 │                             │        │  │  └──────┬───────┘ └─────────────────┘ │  │
 │                             │        │  └─────────┼─────────────────────────────┘  │
 │                             │        │            │ 5432 (docker compose)          │
 │                             │        │  ┌─────────▼─────────────────────────────┐  │
 │                             │        │  │ PostgreSQL 17 + pgAdmin               │  │
 │                             │        │  │ container ...-postgres-1              │  │
 │                             │        │  │ db aiops_k8s · user aiops             │  │
 │                             │        │  │ tabela reports (~175 linhas)          │  │
 │                             │        │  │ pgAdmin exposto em :5050              │  │
 │                             │        │  └───────────────────────────────────────┘  │
 └─────────────────────────────┘        └──────────────────────────────────────────────┘
```

> **Armadilha:** dentro do `pve-lab`, `localhost` funciona (é a própria
> máquina). **De fora** (Windows), `localhost` é o Windows — e lá não há
> nenhum serviço. Por isso os testes externos usam sempre
> `http://192.168.15.10:<porta>`. Ver incidente (e) do
> [`PLAYBOOK-INCIDENTES.md`](PLAYBOOK-INCIDENTES.md).

---

## 3. Tabela de endereçamento

| Endereço | Porta | Serviço | Como verificar |
|---|---|---|---|
| `192.168.15.38` | — | Windows (estação, **não** executa o lab) | N/A — não há serviços no Windows (R10) |
| `192.168.15.10` | 22 | SSH do `pve-lab` | `ssh pve-lab` |
| `192.168.15.10` | **8000** | App FastAPI (uvicorn) | `GET /api/health` → `200` |
| `192.168.15.10` | **3001** | MCP Server (`/mcp`) | `GET` → `405` (esperado: exige POST) |
| `192.168.15.10` | **5432** | PostgreSQL 17 (exposto pelo compose) | `pg_isready -U aiops -d aiops_k8s` |
| `192.168.15.10` | **5050** | pgAdmin 4 (porta do compose `5050:80`) | `http://192.168.15.10:5050` |
| `127.0.0.1` (dentro do `pve-lab`) | dinâmica | API do cluster kind (ex.: `35735` em uma sessão) | `kubectl cluster-info` |

**Analogia da porta:** a **porta** é a porta da casa e o **IP** é o endereço.
`192.168.15.10:8000` lê-se "casa de número 10, porta 8000". Serviço nenhum
"abre a casa inteira" — cada serviço ocupa a sua porta.

---

## 4. Fluxo de uma requisição (Windows → app → banco → resposta)

Exemplo real: pedir a saúde da aplicação a partir do Windows.

```
Windows (192.168.15.38)
   │
   │  1) curl http://192.168.15.10:8000/api/health
   ▼
pve-lab (192.168.15.10) — porta 8000
   │
   │  2) uvicorn recebe a rota /api/health
   ▼
App FastAPI (my_agent_app)
   │
   │  3) se a rota precisa de dados: conexão psycopg → container postgres:5432
   │     (db aiops_k8s, user aiops, tabela reports)
   ▼
PostgreSQL responde as linhas
   │
   │  4) a app monta o JSON e devolve o status HTTP
   ▼
Windows recebe: 200  +  {"status":"ok"}
```

**Princípio:** o *código de status HTTP* (200, 404, 500) é o que prova que a
requisição foi bem-sucedida — não a beleza da mensagem. Este projeto registra
sucesso só com **valor observado** (R9): ou o `200` aparece no terminal, ou
não é sucesso.

---

## 5. O que é o `kind` (Kubernetes dentro de Docker)

**Conceito primeiro:** Kubernetes (K8s) é o orquestrador de containers — em
termos de cidade, é a **prefeitura** que distribui os serviços (pods) pelos
quarteirões (nós), decide onde cada um mora e recria os que morrerem.

**Problema prático:** um cluster "de verdade" precisa de máquinas inteiras
disponíveis. Num laboratório com uma única VM, isso é caro e demorado.

**Solução do `kind` (Kubernetes IN Docker):** ele roda o cluster **dentro de
containers Docker**. **Analogia:** em vez de construir um quarteirão da cidade
inteira, você monta uma **maquete em escala dentro de um aquário** — a
prefeitura (API do K8s) funciona de verdade, mas o "terreno" é um container.

No laboratório:

- Cluster: `aiops` (1 nó: `aiops-control-plane`, um container Docker).
- Criado/gerenciado pelo `scripts/aiops-lab.sh` (subcomandos `up`, `reset`...).
- A API dele fica numa porta local dinâmica (em uma sessão observamos
  `127.0.0.1:35735`).

**Cuidado:** o cluster inteiro depende da RAM da VM. Quando a VM ficou com
apenas 260 MB livres, o nó do kind foi morto pelo OOM killer com **exit 137**
(SIGKILL) e o `kubectl` passou a falhar com
`dial tcp 127.0.0.1:35735: connect: connection refused`. Detalhes no
[`PLAYBOOK-INCIDENTES.md`](PLAYBOOK-INCIDENTES.md), incidente (a).

---

## 6. O que é o MCP Server (Model Context Protocol)

**Conceito:** o MCP é um **padrão de conexão entre IA e ferramentas**. Pense
nele como um **adaptador de tomada universal**: em vez de cada IA inventar uma
forma de falar com cada ferramenta, todos concordam em um conector padrão.

**Analogia do correio:** a IA é quem escreve a carta, o MCP Server é o
**carteiro com uniforme** — ele entende o endereço (o pedido em JSON-RPC),
entrega na ferramenta certa (aqui, o cluster Kubernetes) e traz a resposta de
volta. Sem o carteiro, a IA teria que conhecer cada rua da ferramenta
individualmente.

No laboratório:

| Item | Valor |
|---|---|
| Executável | `npx -y mcp-server-kubernetes` (via Node 24 + npm) |
| URL | `http://192.168.15.10:3001/mcp` |
| Transporte | HTTP (variável `ENABLE_UNSAFE_STREAMABLE_HTTP_TRANSPORT=1`) |
| Resposta a `GET` | **`405` — esperado**, porque o endpoint exige `POST` com JSON-RPC |

**Armadilha:** `405 Method Not Allowed` **não é erro aqui** — é a prova de
que o serviço está no ar e protegido contra o método errado. Interpretar
qualquer número diferente de `200` como "caiu" daria um falso alarme (o
princípio é o mesmo do incidente de detecção por string, ver
[`DECISOES-TECNICAS.md`](DECISOES-TECNICAS.md), D6).

---

## 7. Os cenários de falha intencionais

São falhas **proposital** para praticar diagnóstico de incidente. São
**sucesso** quando mostram a falha esperada:

| Namespace | Manifesto | Falha plantada | Estado que prova o sucesso |
|---|---|---|---|
| `teste-a` | `nginx.yaml` | imagem inexistente `ngin:latest` (falta um "x") | pod com `ImagePullBackOff` |
| `teste-b` | `kube-news.yaml` | senha errada de banco | pods `Error` (o `postgre` do cenário fica `Running`) |

---

## 8. Onde cada coisa vive no repositório

```
devops-profissional/
├── README.md              ← único de entrada (raiz só pode ter isto)
├── CREDITS.md
├── .gitignore / .gitattributes
├── docs/                  ← referência (este arquivo fica aqui)
│   ├── ARQUITETURA.md
│   ├── RUNBOOK-LABORATORIO.md
│   ├── PLAYBOOK-INCIDENTES.md
│   ├── CHECKLIST-VERIFICACAO.md
│   └── DECISOES-TECNICAS.md
├── lab/                   ← código do laboratório (boilerplate-k8s-aiops, kube-news)
├── scripts/               ← aiops-lab.sh
└── notas/                 ← caderno de laboratório
```

---

*Documento de estudo. Versões e portas refletem o laboratório no momento da
observação — sempre confirme no próprio ambiente antes de concluir.*
