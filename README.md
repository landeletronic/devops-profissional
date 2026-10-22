# devops-profissional

> Laboratório prático e caderno de estudo de DevOps/AIOps — construído do zero
> em uma VM Debian, partindo de um sistema sem nada instalado até um cluster
> Kubernetes operante com aplicação, banco e servidor MCP no ar.

---

## Sobre

Este repositório registra o percurso de estudo de DevOps/AIOps: o que foi
instalado, com que versão, **por quê**, e — o mais importante — **o que deu
errado e como foi corrigido**.

A escolha metodológica é deliberada: nada aqui é "copiar e colar". Cada
ferramenta entrou por uma razão verificável, cada erro virou lição registrada,
e cada versão obtida foi conferida contra a versão pedida. Um DevOps não é
quem decora comandos — é quem **lê o que o sistema está dizendo**.

### O caderno de laboratório

O coração do repositório é [`notas/CADERNO-DE-LABORATORIO.md`](notas/CADERNO-DE-LABORATORIO.md):
cada passo com seu objetivo, a saída real do terminal, a leitura dessa saída e o
veredito. Inclui a seção **Erros registrados**, que documenta os problemas
encontrados com causa raiz, cascata de efeitos e prevenções.

---

## Arquitetura

Duas máquinas, com responsabilidades separadas:

```
┌──────────────────────────┐         SSH / SCP         ┌──────────────────────────────┐
│       WINDOWS            │ ────────────────────────► │       PVE-LAB                │
│   estação de trabalho    │                           │   Debian 13 (VM)             │
│                           │                           │   192.168.15.10              │
│   • editor de código     │                           │                              │
│   • Git + GitHub         │ ◄──────────────────────── │   • Docker Engine 29.9.2     │
│   • agente (OpenCode)    │     http://<ip>:8000      │   • kind (Kubernetes 1.37)   │
│                           │                           │   • uv + Python 3.13         │
│   NÃO executa nada       │                           │   • Node 24 + npm            │
│   do laboratório         │                           │                              │
└──────────────────────────┘                           └──────────────────────────────┘
```

> **Regra de ouro:** os serviços ficam em `http://192.168.15.10:<porta>` —
> **nunca** em `localhost`. Do ponto de vista do Windows, o `localhost` é o
> próprio Windows, e lá não há nada.

Isso evita toda uma classe de bugs: separar *onde se edita* de *onde se
executa* elimina as divergências de ambiente que fazem o código funcionar numa
máquina e falhar noutra.

---

## Toolchain

Instalado do zero, cada versão verificada por evidência:

| Ferramenta | Versão | Por quê **esta**, e não outra |
|---|---|---|
| `curl` · `jq` · `ca-certificates` | 8.14.1 · 1.7 | base: sem `ca-certificates` nada fala HTTPS; sem `jq` não se lê JSON de API |
| Docker Engine | **29.9.2** | o `kind` roda clusters Kubernetes **dentro** de containers |
| `kubectl` | **v1.37.1** | interface de comando — versão compatível com o cluster |
| `kind` | **v0.33.0** | cluster real de produção dentro de um laboratório |
| `uv` | **0.13.5** | gerenciador do projeto (substitui `pip` + `venv` + `pyenv`) |
| Node.js | **24.22.1** | escolhido por **evidência**: o `Dockerfile` do projeto diz `FROM node:24-alpine` |
| `npm` | 11.19.1 | entrega o `npx`, que sobe o servidor MCP |
| Python | 3.13.5 | interpretador do projeto |

**Estado do laboratório:** cluster `aiops` (`Ready`), PostgreSQL 17 + pgAdmin,
servidor MCP em `:3001`, aplicação FastAPI em `:8000`.

---

## Estrutura

```
.
├── README.md                  ← este arquivo (único na raiz)
├── CREDITS.md                 ← autoria e atribuições
├── .gitignore                 ← o que nunca vai para um repo público
├── docs/                      ← material de referência
│   ├── GLOSSARIO-DEVOPS.md    ← glossário de 16 blocos, do zero
│   ├── PLANO-DE-ENSINO.md     ← currículo estruturado
│   ├── AGENTS.md              ← regras permanentes do laboratório
│   ├── AMBIENTE.md            ← especificação do ambiente
│   ├── slides/                ← 4 PDFs das aulas (ver CREDITS.md)
│   └── prompt-e-contexto-na-pratica/  ← módulo de exercícios
├── notas/
│   └── CADERNO-DE-LABORATORIO.md  ← registro passo a passo + erros
├── scripts/
│   └── aiops-lab.sh           ← sobe/para/verifica o ambiente
└── lab/
    ├── boilerplate-k8s-aiops/ ← aplicação-alvo do estudo (ver CREDITS.md)
    └── kube-news/             ← aplicação de notícias (ver CREDITS.md)
```

### O que **não** está versionado

Por decisão, e por bom hábito:

- **`.env`** — só o `.env.example`. Nenhuma credencial versionada, nem placeholder.
- **`.venv/`**, `__pycache__/` — artefatos de build, reconstruíveis pelo `uv sync`.
- **`node_modules/`** — idem.
- **`.claude/`, `.codex/`** — configuração de ferramenta, não material de estudo.

---

## Como reproduzir

Pré-requisitos: uma máquina Debian (12 ou 13), acesso `sudo`, e rede.

```bash
git clone https://github.com/landeletronic/devops-profissional.git
cd devops-profissional

# 1. toolchain — siga docs/AMBIENTE.md
# 2. ambiente:
cd lab/boilerplate-k8s-aiops
cp .env.example .env          # NÃO preencha ANTHROPIC_API_KEY
uv sync

# 3. subir tudo:
cd ../..
./scripts/aiops-lab.sh up

# 4. conferir:
./scripts/aiops-lab.sh status
```

A aplicação fica em `http://<ip-da-maquina>:8000`.

| Comando | O que faz |
|---|---|
| `./scripts/aiops-lab.sh up` | cluster, cenários de falha, banco, migrations, MCP e aplicação |
| `./scripts/aiops-lab.sh down` | para tudo (o cluster permanece) |
| `./scripts/aiops-lab.sh status` | estado de cada componente + eventos recentes |
| `./scripts/aiops-lab.sh logs` | segue os logs da aplicação |
| `./scripts/aiops-lab.sh reset` | **destroi e recria** o cluster — perde tudo dentro dele |

---

## Lições registradas

Duas armadilhas enfrentadas e documentadas em detalhe no caderno:

1. **`gnupg` ausente** — sem ele, a chave GPG nunca virou keyring; o `apt`
   desativou o repositório por falta de assinatura e **silenciosamente instalou
   a versão errada**, de outra fonte, sem nenhum erro na hora da instalação.
   *Lição:* dependência ausente é **latente** — pode ficar invisível por
   vários passos e explodir depois. E *"não deu erro" não é sucesso*: a versão
   obtida precisa ser comparada com a pedida.

2. **Nome divergente de recurso** — um cluster foi criado com nome diferente do
   que o script e toda a documentação esperavam. Teria criado um **segundo**
   cluster. *Lição:* conferir o que o código espera **antes** de criar recursos
   nomeados.

E uma observação que resume boa parte do ofício: **evento não é estado**.
`kubectl get events` mostra histórico — os avisos do *bootstrap* de um cluster
continuam listados mesmo depois de resolvidos. Distinguir transitório de
falha real é, em essência, o problema que um agente de AIOps precisa resolver.

---

## Regras deste laboratório

- **Nenhuma API paga.** O `ANTHROPIC_API_KEY` nunca é preenchido. A aplicação
  foi desenhada para degradar com graça: sobe, registra um aviso, e o recurso
  dependente falha — **falha a feature, não o serviço**.
- **Nada é executado no Windows.** O Windows edita; o Debian executa.
- **Cada versão é verificada**, não presumida.
- **Cada erro vira registro** na seção *Erros registrados* do caderno.

---

## Créditos

O material base e a aplicação-alvo vieram de uma imersão externa — veja
[`CREDITS.md`](CREDITS.md) para a atribuição completa e os links ao original.

---

*Repositório de estudo. As versões aqui registradas refletem o ambiente no
momento da execução, não as versões atuais de cada ferramenta.*
