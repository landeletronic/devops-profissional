# Design: Consolidação da estrutura do repositório

## Context

O projeto vive em duas máquinas com papéis distintos: **Windows** (estação —
editor, Git, agente) e **pve-lab** (VM Debian — Docker, kind, Kubernetes,
execução). O repositório `devops-profissional` no GitHub é o artefato público;
a VM carrega um clone do upstream KubeDev com material de estudo por cima,
deliberadamente sem rastreamento (R13).

Até esta change, os dois lados divergiam. O GitHub já espelhava a estrutura
alvo (imposta pelo commit anterior), mas a VM mantinha tudo na raiz. Pior: a
aplicação estava **rodando** a partir do caminho que seria movido, o script
tinha caminho relativo derivado da própria localização, e nada disso estava
protegido pelo git — os arquivos em `pve-lab` são untracked, ou seja, sem
rede de segurança.

O momento da mudança coincidiu com um bloqueio de infraestrutura: a VM tinha
260 MB de RAM (não os 8 GB documentados) e o node do kind foi morto pelo OOM
killer. A memória foi ajustada para 8 GB pelo dono, o que tornou possível
restaurar a stack de forma confiável depois da reestruturação.

## Decisions

### D1 — Mover, não copiar

**Decisão:** todos os itens usam `mv` no mesmo sistema de arquivos (rename
atômico e instantâneo), nunca `cp`.

**Alternativa rejeitada:** copiar e apagar depois. Rejeitada porque duplicaria
temporariamente 256 MB, criaria risco de divergência entre cópias e não
eliminaria o arquivo de origem de forma verificável.

### D2 — Backup antes de qualquer movimento

**Decisão:** `tar czf` de todo o repositório sem `.venv`, salvo em
`/tmp/backup-antes-consolidar.tar.gz` (6.886.463 bytes) antes do primeiro `mv`.

**Alternativa rejeitada:** confiar que "nada vai dar errado". Rejeitada porque
os arquivos da VM são untracked — não há `git stash`, `git checkout` ou histórico
para recorrer.

### D3 — Verificação por hash, não por listagem visual

**Decisão:** md5 + contagem de bytes de cada arquivo/diretório registrados
**antes** e comparados **depois**.

**Alternativa rejeitada:** "olhar se parece certo". Rejeitada porque 10.423
arquivos não são comparáveis visualmente; e porque a lição da sessão foi
explicitamente que leitura por string produz falsos positivos.

### D4 — Corrigir o script, não reverter o movimento

**Decisão:** mover `aiops-lab.sh` para `scripts/` e corrigir **uma única
linha** (`BOILERPLATE`) para apontar ao novo local.

**Alternativa rejeitada:** deixar o script na raiz. Rejeitada porque a raiz
deve conter apenas `README.md`, `CREDITS.md`, `.gitignore`, `.gitattributes`
e diretórios (R7) — e porque o GitHub já o tinha em `scripts/`.

**Nota:** a hipótese inicial de que `LAB_DIR` relativo quebraria o script
mostrou-se **incorreta** — `LAB_DIR` é absoluto (`$HOME/projetos/...`), então
o que precisava mudar era só a linha 18. Verificado lendo o script inteiro
antes de agir.

### D5 — Nunca mover diretório com `.venv` ativo

**Decisão:** após o movimento, reconhecer que os shebangs de `.venv/bin/*`
contêm caminho absoluto antigo e **recriar o ambiente do zero**.

**Evidência do problema:** 26 dos 39 executáveis apontavam para
`.../imersao-aiops-prod-01/boilerplate-k8s-aiops/.venv/bin/python`
(caminho sem `/lab/`).

**Alternativa rejeitada:** `uv sync` para "consertar". Rejeitada porque
demonstrou ser insuficiente — retorna `Checked 108 packages in 283ms` e não
reinstala nada. Correção real: `rm -rf .venv && uv sync`, regenerando tudo a
partir do `uv.lock` (644.097 bytes).

**Lição incorporada:** a partir de agora, mover `.venv` é proibido por padrão;
o `uv.lock` é a fonte da verdade, não o próprio ambiente.

### D6 — Parar a stack com elegância antes de mexer

**Decisão:** `docker compose down` (sem `-v`) para preservar o volume nomeado
`boilerplate-k8s-aiops_postgres_data`, encerrando app e MCP antes.

**Alternativa rejeitada:** `docker kill` ou apagar o volume. Rejeitadas porque
os 174 relatórios de estudo são dado do usuário.

### D7 — `docs/openspec/` na raiz, não `openspec/`

**Decisão:** os manifestos OpenSpec ficam em `docs/openspec/`.

**Alternativa rejeitada:** `openspec/` na raiz, como os projetos
`boilerplate-k8s-aiops` e `kube-news` fazem. Rejeitada porque a R7 restringe
a raiz a `README.md`, `CREDITS.md`, `.gitignore`, `.gitattributes` e
diretórios — e `openspec/` como diretório de raiz violaria o espírito da regra
ao adicionar um quinto diretório sem função de navegação. Decisão confirmada
pelo dono do projeto.

### D8 — Cenários de falha não são falha

**Decisão:** pods `ImagePullBackOff` (teste-a) e `Error` (teste-b) são
**critério de sucesso** da Fase 1, pois são os cenários intencionais do M0
(imagem `ngin:latest` inexistente e senha errada de banco).

**Alternativa rejeitada:** tentar "consertar" os pods. Rejeitada porque
destruiria o cenário de estudo — a app depende deles para gerar relatórios.

## Risks and mitigations

| Risco | Mitigação |
|---|---|
| Perda de arquivo não rastreado | Backup em `/tmp` antes do primeiro `mv` |
| Divergência VM ↔ GitHub | Verificação em 3 vias (hash) no Gate F5 |
| `.venv` invalidado | `uv.lock` presente (644.097 B) + recriação comprovada |
| OOM volta a matar o node | RAM elevada para 8 GB; `MemAvailable` monitorado |
| Script quebra após movimento | Linha 18 corrigida + `up` executado com exit 0 |
