# Decisões técnicas — registro D1 a D10

**Data:** 2026-11-01
**Para quem é:** iniciante em DevOps em transição de carreira — este é o
**porquê** por trás do laboratório. Cada decisão traz **contexto**,
**decisão**, **alternativa rejeitada (e por quê)** e **consequência**.

> **Princípio antes do comando:** arquitetura é escolha, e escolha tem custo.
> Registrar a alternativa rejeitada é o que impede você de reabrir a mesma
> discussão daqui a seis meses — e de achar que "sempre foi assim por acaso".
> **Analogia:** é o manual do carro: não diz só *como* dirigir, diz *por que*
> a suspensão é daquele jeito e não de outro.

---

## D1 — Windows edita, `pve-lab` executa

- **Contexto:** duas máquinas disponíveis — Windows `192.168.15.38` e VM
  Debian `pve-lab` `192.168.15.10`. Precisávamos de um lugar para editar/
  versionar e outro para rodar containers e cluster.
- **Decisão:** separação rígida de papéis — o **Windows edita** (editor, Git,
  GitHub, agente) e o **`pve-lab` executa** (Docker, kind, banco, serviços).
  Acesso por `ssh pve-lab` / `scp`.
- **Alternativa rejeitada:** rodar tudo no Windows (via Docker Desktop/WSL2).
  **Por quê:** quebra a regra R3 (sem WSL2) e mistura estação com equipamento
  de teste — um container mal configurado pode afetar a máquina de trabalho
  pessoal.
- **Consequência:** toda execução remota exige SSH (e a armadilha do shell
  não-interativo, incidente (d)); mas o ambiente de trabalho fica sempre
  íntegro — se o lab quebrar, o balcão continua aberto.

## D2 — `kind` em vez de `kubeadm` ou `minikube`

- **Contexto:** era preciso um cluster Kubernetes numa VM única, de forma
  rápida e reproduzível.
- **Decisão:** usar **`kind`** (Kubernetes IN Docker) — cluster real rodando
  dentro de containers Docker, nome do cluster `aiops`.
- **Alternativa rejeitada:** `kubeadm` (instalação "de verdade" no host) e
  `minikube`. **Por quê:** `kubeadm` exige preparar o host (cgroups,
  swap, serviços) — mais lento e mais difícil de destruir/recriar; `minikube`
  adiciona outra camada de abstração (VM/driver) desnecessária num lab já
  virtualizado. O `kind` dá cluster compatível com produção em segundos e se
  apaga com um comando.
- **Consequência:** o cluster inteiro depende do Docker e da RAM da VM — a
  escolha trouxe o incidente (a): nó morto por OOM (exit 137) e
  `connection refused` na API. Custo aceitável: monitorar memória.

## D3 — `uv` + `uv.lock` para gestão de dependências Python

- **Contexto:** a aplicação é Python 3.13 com dezenas de pacotes; era
  preciso algo rápido e **reprodutível**.
- **Decisão:** usar **`uv`** com **`uv.lock`** (644097 bytes) travado e
  **Alembic** para migrations (head `a3c1f0e2b9d4`).
- **Alternativa rejeitada:** `pip` + `requirements.txt` + `venv` manual.
  **Por quê:** `pip` resolve dependências a cada instalação — duas máquinas
  podem acabar com versões diferentes; sem lockfile, "funciona na minha
  máquina" vira regra. O `uv` resolve tudo de uma vez e o `uv.lock` é a
  **prova do que foi testado**.
- **Consequência:** para corrigir ambiente quebrado, o caminho é recriar do
  lock (`rm -rf .venv && uv sync` → 110 pacotes) — ver D5. Também nasceu a
  armadilha: `uv sync` diz `Checked 108 packages` e **não reinstala** shebangs
  velhos.

## D4 — Em reestruturação, **mover** (nunca copiar)

- **Contexto:** o material foi reorganizado nos diretórios `docs/`, `lab/`,
  `scripts/`, `notas/`.
- **Decisão:** **mover** os arquivos (`git mv`/`mv`) para os novos lugares.
- **Alternativa rejeitada:** copiar para o destino e apagar a origem depois.
  **Por quê:** cópia gera **duas versões do mesmo arquivo** por um tempo — e
  se a limpeza não acontecer (ou acontecer no dia errado), o repositório fica
  com duplicatas divergentes, quebrando a regra da raiz (R10/estrutura) e
  confundindo quem clonar depois.
- **Consequência:** o histórico do Git acompanha o caminho (com `git mv`), mas
  qualquer **movimentação de diretório invalida caminhos absolutos** — ver D5.

## D5 — **Nunca mover `.venv`**; recriar com `uv.lock`

- **Contexto:** após mover o diretório do projeto, `uv run alembic` passou a
  falhar com `error: Failed to spawn: alembic / cause: No such file or
  directory`.
- **Decisão:** tratar `.venv` como **artefato descartável**: ao mover o
  projeto, fazer `rm -rf .venv && uv sync` (recria 110 pacotes do lock).
- **Alternativa rejeitada:** mover o `.venv` junto com o projeto. **Por quê:**
  os scripts dentro de `.venv/bin` têm **shebangs com caminho absoluto** —
  mover invalidou **26 dos 39** shebangs. O `uv sync` nem corrige (diz
  `Checked 108 packages` e não reinstala).
- **Consequência:** lição registrada — o `.venv` **nunca** é conteúdo, é
  build. O `uv.lock` é o conteúdo. Essa decisão vira o incidente (c) do
  [`PLAYBOOK-INCIDENTES.md`](PLAYBOOK-INCIDENTES.md).

## D6 — Detecção de estado por **exit code**, não por `-match` de string

- **Contexto:** scripts de verificação no PowerShell detectavam sucesso
  comparando o texto da saída.
- **Decisão:** detectar estado **somente** por código numérico — `$LASTEXITCODE`
  no PowerShell, `$?` no bash, `%{http_code}` no `curl`.
- **Alternativa rejeitada:** `-match`/`grep` de mensagens. **Por quê:** deu
  **3 falsos alarmes** — a mensagem muda com versão, idioma e contexto, o
  número não. Mensagem é leitura complementar; **número é o veredito**.
- **Consequência:** toda verificação do projeto expõe o código (HTTP 200/405,
  exit 0). Custo: às vezes o "número certo" é estranho (405 no MCP é sucesso)
  — por isso cada número tem seu **significado documentado**.

## D7 — Backup `tar.gz` antes de ação sem volta em arquivos **untracked**

- **Contexto:** operações destrutivas (apagar, reestruturar) sobre arquivos
  que **ainda não foram commitados** — se sumirem, o Git não recupera.
- **Decisão:** antes de qualquer ação sem volta em arquivos untracked, gerar
  um backup `tar.gz` do que será afetado.
- **Alternativa rejeitada:** confiar no Git. **Por quê:** Git só guarda o que
  foi **commitado**; um arquivo novo (nunca stageado) não está em nenhum
  lugar além do disco — `git checkout` não traz de volta o que nunca existiu
  no histórico.
- **Consequência:** um passo extra de tarball, mas "ação sem volta" fica
  restrita ao catálogo do projeto (apagar/ remover/ esvaziar nó) e sempre
  com reversível por backup.

## D8 — `openspec/` dentro de `docs/`, não na raiz

- **Contexto:** o OpenSpec guarda especificações (`specs/`, `changes/`) do
  projeto.
- **Decisão:** manter `openspec/` **dentro de `docs/`**
  (`docs/openspec/...`).
- **Alternativa rejeitada:** deixar `openspec/` na raiz do repositório.
  **Por quê:** a raiz é contrato visual (regra inegociável): só `README.md`,
  `CREDITS.md`, `.gitignore`, `.gitattributes` e os diretórios `docs/`,
  `lab/`, `scripts/`, `notas/`. Cada pasta nova na raiz quebra o contrato e
  obriga a reescrever README, `.gitignore` e expectativas de quem clona.
- **Consequência:** caminho um pouco mais longo para o OpenSpec, mas a raiz
  fica enxuta e a estrutura é auditável com um `git ls-tree` (ver
  [`CHECKLIST-VERIFICACAO.md`](CHECKLIST-VERIFICACAO.md), item 8.3).

## D9 — Material upstream KubeDev **sem rastreamento** no clone

- **Contexto:** parte do material e da aplicação-alvo vieram da imersão
  externa (KubeDev), via repositório clonado/copiado.
- **Decisão:** manter o material upstream **sem rastreamento de histórico**
  (arquivos incorporados ao repo atual, sem `git subtree`/submódulo apontando
  para o original) e atribuir tudo em [`CREDITS.md`](../CREDITS.md).
- **Alternativa rejeitada:** submódulo Git apontando para o repositório
  original. **Por quê:** submódulo exige `git submodule update --init` em
  toda cloneagem, trava em versões do upstream e complica o onboarding de
  iniciantes — além de o upstream poder mudar/deixar de existir, quebrando o
  lab de estudo.
- **Consequência:** o repo é autossuficiente (clonou, tem tudo), mas **não
  herda atualizações** do upstream — e a autoria vive só na documentação
  (o que é justamente o propósito do `CREDITS.md`).

## D10 — Scripts `.ps1` em **ASCII puro**

- **Contexto:** scripts de automação no Windows escritos em PowerShell.
- **Decisão:** escrever os `.ps1` em **ASCII puro** (sem acentos/UTF-8).
- **Alternativa rejeitada:** UTF-8 com acentuação nos scripts.
  **Por quê:** o **PowerShell 5.1** (padrão do Windows) quebra arquivos
  UTF-8 **sem BOM** — lê bytes errados e a sintaxe falha de formas
  misteriosas ("símbolo inesperado" no meio de um comentário acentuado).
- **Consequência:** comentários e mensagens dos `.ps1` ficam sem acento —
  sacrifício aceitável em prol de executar igual em qualquer Windows.
  Documentação (em pt-BR, R8) continua com acentos normalmente.

---

## Resumo em uma tabela

| # | Decisão | Recusa principal |
|---|---|---|
| D1 | Windows edita / `pve-lab` executa | rodar tudo na estação |
| D2 | `kind` para o cluster | `kubeadm` / `minikube` |
| D3 | `uv` + `uv.lock` + Alembic | `pip` + `requirements.txt` solto |
| D4 | Mover, não copiar | duplicatas divergentes |
| D5 | Nunca mover `.venv`; recriar do lock | mover artefato com shebangs absolutos |
| D6 | Exit/HTTP code, nunca string | `-match` (3 falsos alarmes) |
| D7 | `tar.gz` antes de ação sem volta em untracked | confiar no Git para o que não commitou |
| D8 | `openspec/` em `docs/` | sujar a raiz do repo |
| D9 | Material upstream sem rastreamento | submódulo Git |
| D10 | `.ps1` em ASCII puro | UTF-8 sem BOM no PowerShell 5.1 |

---

*Registro de decisões do laboratório de estudo. Cada "alternativa rejeitada"
reflete o conhecimento no momento da escolha — se o contexto mudar, reabrir
a decisão é legítimo; esquecer o porquê, não.*
