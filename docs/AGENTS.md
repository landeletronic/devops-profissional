# AGENTS.md — instruções do projeto AIOps

> Este arquivo é lido por qualquer agente de código que abrir o projeto.
> As regras aqui são **permanentes** e não devem ser contornadas sem pedido
> explícito do dono do projeto.

## Regra 1 — Nenhuma API paga

**Não use APIs pagas. Em especial, não use `ANTHROPIC_API_KEY`.**

Use o OpenCode com os modelos gratuitos.

### Modelos gratuitos disponíveis

Provider `opencode`, todos com suporte a tools:

```
minimax-m3.1-flash-free      deepseek-v4.1-flash-free    glm-5.3-flash-free
nemotron-3-ultra-free        nemotron-3.5-lightning-free nemotron-3.5-super-vl-free
mimo-v2.6-flash-free         longcat-2.5-preview-free    beam-free
```

### O caminho que funciona

1. `opencode serve --port 4096` — API local. A senha é gerada no log do processo.
2. Agente customizado **sem tools**, no `opencode.json` do projeto:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "agent": {
    "llm-proxy": {
      "description": "Agente sem tools: responde apenas em texto/JSON para uso como backend de LLM via API.",
      "mode": "primary",
      "tools": {},
      "permission": { "edit": "deny", "bash": "deny", "webfetch": "deny" }
    }
  }
}
```

3. API **v2** do OpenCode (as rotas v1 do proxy Go da comunidade não funcionam no v2):

```
POST /api/session              -> {"data":{"id":"ses_..."}}
POST /api/session/{id}/prompt  -> {"text": "...", "delivery": "queue",
                                   "agents":[{"id":"llm-proxy","name":"llm-proxy"}]}
GET  /api/session/{id}/message -> data[].content[].text
```

4. Como o modelo free não tem tool calling nativo, o **prompt instrui o formato**:

```
Se precisar chamar uma funcao, responda APENAS com JSON, sem markdown:
{"tool_calls":[{"id":"call_1","type":"function","function":{"name":"kubectl_get","arguments":"{\"resourceType\":\"pod\"}"}}]}
```

O adaptador extrai as tools do pedido, injeta no prompt, e faz o parse do JSON
de volta para o formato OpenAI.

### O que NÃO funciona

Chamar `https://opencode.ai/inference/openai/v1/chat/completions` direto
retorna **403 FreeTierError** ("free tier can only be used from within
OpenCode"), mesmo com token válido. Trocar o User-Agent não resolve.

## Regra 2 — O `pve-lab` é uma VM Debian. Não usar Proxmox.

O host Windows (`192.168.15.38`) **não** é o equipamento de testes.

| Host | IP | Papel | Como acessar |
|---|---|---|---|
| **pve-lab** | `192.168.15.10` (DHCP) | **VM Debian — a máquina de testes** | `ssh pve-lab` (usuário `tlandskron`) |
| Windows | `192.168.15.38` | estação de trabalho (editor, Git, OpenCode) | — |

**O `pve-lab` é uma VM Debian isolada. Não usar Proxmox** — não acessar
`192.168.15.221`, nem a UI `:8006`, nem criar/gerenciar VMs por lá. O host
`192.168.15.221` fica **fora do escopo** deste projeto.

Tudo que roda — toolchain (Docker, kind, kubectl, git), o repositório
`imersao-aiops-prod-01`, o cluster Kubernetes, o PostgreSQL, o MCP Server e o
agente AIOps — fica **no `pve-lab`**.

### Specs do `pve-lab`

| Item | Valor |
|---|---|
| SO | Debian GNU/Linux 13 (trixie) · kernel 6.12 · x86_64 |
| vCPUs | **4** (host: Intel i7-13700) |
| **RAM** | **8 GB** (7,8 GiB, 7,5 disponíveis) |
| Swap | 4,0 GiB (partição LVM) |
| Disco | 246 GB · **232 GB livres** |
| cgroup | v2 (`cgroup2fs`) — compatível com Kubernetes |
| Rede | `ens18`, DHCP, gateway `192.168.15.1` |
| Estado | **instalação limpa** — só SSH, nem `curl` |

Com 8 GB o cluster de 3 nós do M4 (~2,5 GiB) cabe **com folga**, incluindo a
fase N3 de turbulência.

**Acesso SSH estabelecido** — sem senha, via alias `pve-lab`, configurado no
`~/.ssh/config` do Windows.

**Use sempre o alias `pve-lab`, nunca o IP cru** — o IP é DHCP e pode mudar.
Reserva DHCP no roteador para o MAC `BC-24-11-36-B2-77` elimina o risco.

Detalhes em `AMBIENTE.md` e `PLANO-DE-ENSINO.md` (M4).

## Regra 2b — Não usar WSL2

**O WSL2 não faz parte do ambiente deste projeto.** Não instalar nem executar
nada no WSL2.

- A estação é o **Windows** (editor, Git, GitHub, OpenCode)
- A execução é o **`pve-lab`** (SSH)
- Tudo que antes existia no WSL2 é **legado e será migrado** para o `pve-lab`

## Regra 3 — GitHub

Acesso via login automatizado do usuário **landeletronic**.

- Token PAT no Windows Credential Manager, target
  `git:https://x-access-token@github.com`
- Escopos: `repo, workflow` (suficiente para push e para GitHub Actions)

## Vocabulário do projeto

| Termo | Significado aqui |
|---|---|
| **Outer loop** | ciclo com o usuário; critério: o objetivo de quem pediu foi atingido |
| **Inner loop** | ciclo por etapa; critério: o critério de aceite da etapa |
| **ReAct** | raciocinar → agir → observar |
| **Harness** | o que sobrevive ao projeto: instruções, skills, permissões, MCP |
| **Portão humano** | o único ponto de escrita; o agente só age após o "sim" |
| **Ação sem volta** | apagar, remover, esvaziar nó — fora da superfície do agente |

## Regras de trabalho

- **Sucesso só com evidência.** Um comando que roda não prova que funciona.
  Relate o **valor observado**, nunca "deveria funcionar".
- **Item que não se aplica** vira `N/A — motivo`, nunca some do relatório.
- **Não comite** sem pedido explícito.
- **Fale em português do Brasil.**
- **Não altere código nem dependências** da aplicação sem pedir; aponte em
  "Pontos de atenção" em vez de corrigir.
- **Leia a mensagem de erro inteira** antes de pesquisar na internet.
