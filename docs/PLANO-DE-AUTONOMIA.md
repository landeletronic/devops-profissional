# PLANO DE EXECUÇÃO AUTÔNOMA — DevOps / AIOps

> **Documento mestre de planejamento.** Uma única fonte para toda a execução
> autônoma deste projeto: restrições, modelo de trabalho com subagentes, fases,
> manifestos OpenSpec, documentação a gerar e critérios de aceite.
>
> **Autorização:** este plano **não executa nada** até o dono do projeto aprovar.
> Cada fase também tem seu próprio portão de verificação.

---

## 1. Contexto

### 1.1 O que é este projeto

Repositório público de **estudo e prática de DevOps/AIOps** de um iniciante em
transição de carreira. Não é produto de produção — é **caderno de estudo honesto**:
registra o que foi aprendido, o que foi errado e como foi corrigido.

| | |
|---|---|
| **Repositório** | `github.com/landeletronic/devops-profissional` (público) |
| **Material de origem** | `imersao-aiops-prod-01` (KubeDev), clone em `pve-lab` |
| **Estação** | Windows `192.168.15.38` — editor, Git, agente |
| **Execução** | `pve-lab` `192.168.15.10` — VM Debian, Docker, Kubernetes |
| **Módulo atual** | **M0 concluído** (14/14) · simulado aplicado (6/21 respondidas) |

### 1.2 Onde estamos agora

**Concluído e verificado:**

- M0 100% — toolchain, cluster `aiops`, aplicação `:8000`, MCP `:3001`
- Glossário (87 verbetes), Plano de Ensino, Caderno de Laboratório
- Repositório público publicado e auditado (9 verificações de segurança)
- Aula de aprofundamento M0 (6 tópicos, comandos executados e verificados)
- Simulado M0 — Bloco 1 (Q1–Q6) respondido e corrigido
- **Consolidação estrutural concluída** — `pve-lab` espelha o GitHub
  (`docs/`, `lab/`, `scripts/`, `notas/`)

**Bloqueio atual:**

> **A VM `pve-lab` tem 260 MB de RAM, não os 8 GB documentados.**
> O node do Kubernetes foi morto pelo OOM killer (`Exited 137`) e a VM está
> em *thrashing* de swap — responde a ping, mas o SSH não completa.
> **Só o dono do projeto pode resolver** (ajuste no hipervisor).

### 1.3 Pendências pedagógicas

| Item | Estado |
|---|---|
| Simulado M0 — Blocos 2, 3 e 4 (Q7–Q21) | ⏳ 15 pendentes |
| Autoavaliação da aula (A1–A7) | ⏳ pendente |
| Registro das correções no caderno | ⏳ após resposta |

---

## 2. Restrições inegociáveis

Estas regras **não podem ser contornadas**. Toda decisão da execução autônoma
é filtrada por elas.

| # | Restrição | Origem |
|---|---|---|
| **R1** | **Nenhuma API paga.** Nunca usar `ANTHROPIC_API_KEY` ou qualquer chave de serviço pago. Apenas modelos gratuitos do OpenCode. | `AGENTS.md` |
| **R2** | **`pve-lab` é VM Debian.** Nunca usar Proxmox, nunca acessar `192.168.15.221` ou `:8006`. | `AGENTS.md` |
| **R3** | **Sem WSL2.** Windows edita, `pve-lab` executa. Nada em WSL2. | `AGENTS.md` |
| **R4** | **Nunca colar token no chat.** Credenciais só no terminal do usuário. | Regra do projeto |
| **R5** | **Não alterar arquivos do usuário sem pedir.** Apontar em "Pontos de atenção". | Regra do projeto |
| **R6** | **Não commitar sem pedido explícito.** | `AGENTS.md` |
| **R7** | **Raiz do repositório só `README.md`** (mais `.gitignore`, `.gitattributes`, `CREDITS.md` e os diretórios). | Decisão do dono |
| **R8** | **Falar português do Brasil.** Material didático para iniciante: conceito antes da prática. | `AGENTS.md` |
| **R9** | **Sucesso só com evidência.** Relatar o **valor observado**, nunca "deveria funcionar". | `AGENTS.md` |
| **R10** | **Item que não se aplica vira `N/A — motivo`**, nunca some do relatório. | `AGENTS.md` |
| **R11** | **Registrar passo a passo no caderno** após cada etapa concluída. | Regra do projeto |
| **R12** | **Nunca apagar sem ação explícita.** Ações sem volta fora da superfície do agente. | Vocabulário do projeto |
| **R13** | **Preservar o upstream KubeDev.** Material de estudo fica **sem rastreamento** no clone. | Decisão do dono |

---

## 3. Padrões incorporados (lições já pagas)

Estes padrões **não são mais decisões** — são comportamento automático. Vêm de
erros reais cometidos e corrigidos nesta sessão.

### 3.1 Padrões de execução

| Padrão | Por quê (falha real que motivou) |
|---|---|
| **`.sh` → `scp` → `ssh "bash /tmp/x.sh"`** para qualquer comando não trivial | PowerShell converte `/dev/null` em `C:\dev\null` e interpreta `$(...)` localmente — derrubou 3 comandos |
| **`.ps1` em ASCII puro** (sem acentos) | PowerShell 5.1 lê UTF-8 sem BOM como ANSI e **quebra o parse** |
| **`git commit -F arquivo.txt`** | Aspas na mensagem quebram o parse do PowerShell; o `push` seguinte enviava o estado antigo **em silêncio** |
| **`bash -lc`** em vez de `bash` via SSH | Shell não-interativo não lê `.profile`/`.bashrc` → `uv: command not found` |
| **Detectar estado por `$LASTEXITCODE`**, nunca por string | `-match` case-insensitive deu **3 falsos alarmes** ("not logged into" casou com "Logged in") |
| **Verificar antes de afirmar** (hash, exit code, tamanho real) | Comparei "174 ≠ 10" como divergência — a query tinha `limit 10`; 10 era o topo, não o total |
| **Ler a mensagem de erro inteira antes de pesquisar** | O `mv` falhava por diretório de destino inexistente; assumir seria diagnosticar errado |

### 3.2 Padrões de arquitetura

| Padrão | Regra |
|---|---|
| **Nunca mover diretório com `.venv` Python** | Shebangs têm caminhos absolutos — mover invalida 26 dos 39 executáveis. Correção: `rm -rf .venv && uv sync` |
| **`uv sync` não corrói shebangs quebrados** | Diz "Checked 108 packages" e **não reinstala**. Só recriar resolve |
| **Backup antes de ação sem volta** | `tar czf` do repo inteiro antes de qualquer reestruturação |
| **Mover, não copiar** em reestruturação | Evita duplicação; `mv` no mesmo fs é `rename` (instantâneo e atômico) |
| **`localhost` é relativo a quem pergunta** | Vale para `curl`, para a API do kind (`127.0.0.1:35735`) e para qualquer serviço |
| **Serviço em outra máquina exige o IP dela** | `localhost` nunca atravessa a rede |

---

## 4. Modelo de execução autônoma

### 4.1 Princípio

Eu trabalho como **engenheiro DevOps sênior**: antes de agir, leio o estado;
depois de agir, **provo** o resultado. Nenhum relatório sem valor observado.
Quando o critério não é claro ou a ação é irreversível, **paro e pergunto**.

### 4.2 Subagentes

| Agente | Tipo | Função | Quando uso |
|---|---|---|---|
| **Explorador** | `explore` | Mapeia estado, extrai regras de documentos, audita consistência | Início de fase; antes de decisões estruturais |
| **Documentador** | `general` | Redige documentação DevOps em paralelo | Fase 3 — documentos independentes |
| **Auditor** | `general` | Verifica evidências de forma **independente** do executor | Fim de fase — confirmação cruzada |

**Regra de subagente:** um subagente **nunca** executa ação sem volta nem toca
em credenciais. Ele lê, analisa e redige. A execução no `pve-lab` fica sempre
com o agente principal, que tem o contexto das regras.

**Confirmação cruzada:** o que um agente afirma ser verdade, **outro agente
verifica**. Ninguém audita o próprio trabalho.

### 4.3 Portões de verificação (gates)

Cada fase termina num **gate**. Gate é **passou/não passou**, com evidência.
Sem evidência, a fase **não** avança.

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  EXECUTA     │────▶│  VERIFICA    │────▶│  PROVA       │
│  a tarefa    │     │  por exit    │     │  ao auditor  │
└──────────────┘     │  code/hash   │     └──────────────┘
                     └──────────────┘            │
                          │                      ▼
                          │              ┌──────────────┐
                          └─────────────▶│  PASSOU?     │
                                         │  ├ sim → fase │
                                         │  └ nao → volta│
                                         └──────────────┘
```

### 4.4 Regras de escalação — quando eu paro e pergunto

| Situação | Ação |
|---|---|
| Ação **irreversível** (apagar, reestruturação grande) | Pergunto antes |
| **Dados do usuário** em risco | Pergunto antes |
| **Regra R1–R13** em conflito com um pedido | Aponto o conflito, não contorno |
| **Ambiguidade de escopo** (o que "tudo" inclui?) | Pergunto com opções concretas |
| **Falha repetida** 2× no mesmo ponto | Pare, diagnostico, relato |
| **Bloqueio externo** (infraestrutura que não controlo) | Relato com evidência e o que preciso do dono |

---

## 5. Fases de execução

### Fase 0 — Destravar a infraestrutura ⛔ *bloqueada*

**Responsável:** dono do projeto (ação fora do alcance do agente)

| Tarefa | Critério de aceite |
|---|---|
| Aumentar RAM da VM `pve-lab` para **≥ 4 GB** (ideal 8 GB) | `free -h` mostra `MemTotal` ≥ 4 GB |
| Confirmar SSH funcional | `ssh pve-lab "echo OK"` retorna `OK` com exit 0 |

> **Por que bloqueada:** com 260 MB, o control plane do kind consome a memória
> inteira. O OOM killer vai voltar a matar o node. Nenhuma fase seguinte é
> confiável sem isso.

---

### Fase 1 — Restaurar o laboratório

**Depende:** Fase 0 · **Executor:** agente principal

| # | Tarefa | Evidência exigida |
|---|---|---|
| 1.1 | Avaliar estado real da VM (`free`, `docker ps`, `uptime`) | Saída capturada |
| 1.2 | Recriar o cluster `aiops` (o node está em estado inconsistente) | `kind get clusters` lista `aiops`; node `Up` |
| 1.3 | Reaplicar cenários `teste-a` / `teste-b` | Pods dos dois namespaces existem |
| 1.4 | Subir stack completa (`./scripts/aiops-lab.sh up`) | Containers `Up`, app `:8000` → 200, MCP `:3001` → 405 |
| 1.5 | Confirmar dados preservados | `count(*) from reports` = **174** |
| 1.6 | Testar acesso **do Windows** | `curl http://192.168.15.10:8000/api/health` → 200 |

**Gate F1:** todos os 6 itens com evidência registrada. Auditor confirma.

---

### Fase 2 — Formalizar com OpenSpec

**Depende:** Fase 1 · **Executor:** agente principal + Explorador

A reestruturação que fizemos foi uma **change real** do projeto. Ela merece
manifesto OpenSpec no formato que o projeto já usa.

| Manifesto | Tipo | Conteúdo |
|---|---|---|
| `docs/openspec/changes/2026-11-01-consolidacao-estrutura-repositorio/proposal.md` | Proposta | Why / What Changes / Capabilities / Impact |
| `.../tasks.md` | Tarefas | Checklist das etapas executadas e pendentes |
| `.../design.md` | Design | Contexto, decisões (D1–Dn), alternativas |
| `.../validation.md` | Validação | Os comandos que provaram cada item |
| `docs/openspec/specs/estrutura-repositorio/spec.md` | Spec | Requisitos SHALL/MUST + Scenarios |
| `docs/openspec/config.yaml` | Config | `schema: spec-driven` + contexto do projeto |

**Decisão estrutural a confirmar com o dono:**

> O `openspec/` do projeto fica em **`docs/openspec/`** e não na raiz — porque
> a **R7** diz que a raiz só pode ter `README.md`. Se o dono preferir `openspec/`
> na raiz (como `boilerplate-k8s-aiops` e `kube-news` fazem), é uma quebra da
> R7 que precisa de autorização explícita.

**Gate F2:** manifestos válidos, links resolvem, spec tem requirements com
cenario WHEN/THEN.

---

### Fase 3 — Documentação DevOps

**Depende:** Fase 2 · **Executor:** Documentador (subagente) + agente principal

| Documento | Conteúdo |
|---|---|
| `docs/ARQUITETURA.md` | Diagrama das duas máquinas, cluster, serviços, fluxo de rede e endereçamento |
| `docs/RUNBOOK-LABORATORIO.md` | Subir / parar / status / logs / reset / recuperação, com comandos reais |
| `docs/PLAYBOOK-INCIDENTES.md` | O que fazer em: OOM, node do kind morto, SSH em thrashing, `localhost` errado, `.venv` quebrado |
| `docs/CHECKLIST-VERIFICACAO.md` | Roteiro de auditoria com **exit code**, nunca string matching |
| `docs/DECISOES-TECNICAS.md` | Registro das decisões D1–Dn e por que existem |

**Padrão de todo documento:** diagrama ASCII em bloco de código (abre em
qualquer visor), comando **com a saída real embutida**, e ao menos uma
**analogia** para o conceito ficar memorável.

**Gate F3:** 5 documentos, todos com comandos verificados no `pve-lab`.

---

### Fase 4 — Continuidade pedagógica

**Depende:** Fase 1 · **Executor:** agente principal + Explorador

| # | Tarefa | Evidência |
|---|---|---|
| 4.1 | Resolver **Q7–Q21** (Blocos 2, 3 e 4) com correção | Respostas + correção no caderno |
| 4.2 | Gerar aula de aprofundamento do **Bloco 2** (Err01, shells, `.gitattributes`) | Documento com comandos verificados |
| 4.3 | Resolver autoavaliação **A1–A7** da aula | Respostas + correção no caderno |
| 4.4 | Atualizar caderno com tudo | Hash conferido em 4 locais |

**Gate F4:** caderno atualizado, 21/21 respondidas, 4 cópias idênticas.

---

### Fase 5 — Auditoria e entrega

**Depende:** Fases 1–4 · **Executor:** Auditor (subagente) + agente principal

| # | Tarefa | Evidência |
|---|---|---|
| 5.1 | Auditoria de segurança (9 verificações) | 9/9 passam |
| 5.2 | Conferência de integridade (hash em 3 vias: Windows ↔ pve-lab ↔ GitHub) | MD5 idênticos |
| 5.3 | Conferência da regra da raiz (R7) | Só `README.md` + diretórios |
| 5.4 | Commit com `git commit -F` + push | local == remoto |
| 5.5 | Sincronização pve-lab ↔ Windows ↔ GitHub | Inventário idêntico |
| 5.6 | Relatório final com evidências | Nada sem valor observado |

**Gate F5:** tudo verificado. Se algo falhar, **volto à fase correspondente**.

---

## 6. Sequência e dependências

```
Fase 0  Destravar (usuário)          ⛔ BLOQUEADA
   │
   ▼
Fase 1  Restaurar laboratório        ──┐
   │                                    │
   ├────────────────────────────────────┤
   ▼                                    ▼
Fase 2  OpenSpec                   Fase 4  Pedagogia
   │                                    │
   ▼                                    │
Fase 3  Documentação DevOps             │
   │                                    │
   └────────────────┬───────────────────┘
                    ▼
              Fase 5  Auditoria e entrega
```

Fases 2–3 e Fase 4 são **independentes** e podem rodar em paralelo
(é aqui que os subagentes ganham tempo).

---

## 7. Critérios globais de aceite

O plano só se considera concluído quando **todos** forem verdadeiros, com
evidência anexada:

- [ ] VM com ≥ 4 GB de RAM e SSH estável
- [ ] Cluster `aiops` de pé, cenários `teste-a`/`teste-b` aplicados
- [ ] App `:8000` → 200 e MCP `:3001` → 405 **a partir do Windows**
- [ ] 174 relatórios preservados no Postgres
- [ ] 6 manifestos OpenSpec escritos no formato do projeto
- [ ] 5 documentos DevOps gerados, com comandos verificados
- [ ] 21/21 questões do simulado respondidas e corrigidas
- [ ] Autoavaliação A1–A7 respondida
- [ ] Caderno idêntico em 4 locais (hash conferido)
- [ ] Auditoria de segurança 9/9
- [ ] GitHub: local == remoto, raiz conforme R7
- [ ] Nenhuma regra R1–R13 violada

---

## 8. Registro de progresso

Após **cada tarefa concluída**, registro no `notas/CADERNO-DE-LABORATORIO.md`:

1. O que foi feito
2. O comando usado
3. O valor **observado** (não "deveria funcionar")
4. O que deu errado e como foi resolvido

Ao fim de cada fase, reporto ao dono: **o que passou, o que não passou, e o que
preciso dele**. Itens que não se aplicam viram `N/A — motivo`.

---

## 9. Pendências de decisão do dono

Preciso de resposta antes (ou durante) a execução:

1. **Memória da VM** — Fase 0 é bloqueada sem isso.
2. **Local do `openspec/`** — `docs/openspec/` (respeita R7) ou raiz
   (quebra R7, como os outros projetos fazem)?
3. **Autorização para executar** este plano de forma autônoma, com os
   subagentes definidos na seção 4.2.

---

*Documento gerado em 2026-11-01. Atualizado a cada fase concluída.*
