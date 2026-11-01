# Tasks: Consolidação da estrutura do repositório

## 1. Preparação e segurança

- [x] 1.1 Levantar inventário completo dos dois lados (GitHub via `gh api`, VM via `ls`/`find`) — *evidência: listagem idêntica em 4 diretórios*
- [x] 1.2 Verificar riscos antes de mover (bind mounts, subrepos git, `.venv`, `.env`) — *evidência: saída de `riscos.sh`*
- [x] 1.3 Criar backup de segurança sem `.venv` — *evidência: `/tmp/backup-antes-consolidar.tar.gz`, 6.886.463 bytes*
- [x] 1.4 Registrar inventário com hashes antes do movimento — *evidência: md5 e byte-size de 6 arquivos + 4 diretórios*

## 2. Movimentação (mover, nunca copiar)

- [x] 2.1 Mover 7 itens de estudo para `docs/` (`AGENTS.md`, `AMBIENTE.md`, `GLOSSARIO-DEVOPS.md`, `PLANO-DE-ENSINO.md`, `AULA-M0-PROFUNDIZACAO.md`, `prompt-e-contexto-na-pratica/`, `slides/`) — *evidência: hashes conferem*
- [x] 2.2 Criar diretórios `scripts/` e `lab/` que não existiam — *evidência: `mkdir -p`, causa real do primeiro `mv` falhar*
- [x] 2.3 Mover `aiops-lab.sh` → `scripts/`, `boilerplate-k8s-aiops/` → `lab/`, `kube-news/` → `lab/` — *evidência: 10.423 arquivos e 122 arquivos contados antes/depois*
- [x] 2.4 Corrigir linha 18 do script: `BOILERPLATE="$LAB_DIR/lab/boilerplate-k8s-aiops"` — *evidência: hash `43b49577` → `d69616e0`*

## 3. Reparo do ambiente Python

- [x] 3.1 Diagnosticar shebangs quebrados após o movimento — *evidência: 26 de 39 executáveis com caminho absoluto antigo*
- [x] 3.2 Tentar `uv sync` (insuficiente — só "Checked 108 packages") — *evidência: falha documentada, não reinstala*
- [x] 3.3 Recriar ambiente: `rm -rf .venv && uv sync` — *evidência: 0 shebangs quebrados, `alembic 1.18.5`, 110 pacotes do lock*

## 4. Restauração e verificação

- [x] 4.1 Subir stack com `./scripts/aiops-lab.sh up` — *evidência: exit 0*
- [x] 4.2 Verificar containers, node kind e `kubectl` — *evidência: 3 `Up`, `kubectl responde`*
- [x] 4.3 Verificar app `:8000` e MCP `:3001` — *evidência: HTTP 200 e 405*
- [x] 4.4 Verificar acesso a partir do Windows via `192.168.15.10` — *evidência: `HTTP 200`, corpo `{"status":"ok"}`
- [x] 4.5 Verificar migrations e dados — *evidência: `a3c1f0e2b9d4 (head)`, 174 relatórios originais + 1 gerado na subida*
- [x] 4.6 Confirmar cenários de falha `teste-a`/`teste-b` — *evidência: `ImagePullBackOff` e `Error` (intencionais)*

## 5. Formalização OpenSpec

- [x] 5.1 Criar `docs/openspec/config.yaml` com contexto do projeto — *evidência: schema `spec-driven`*
- [x] 5.2 Escrever proposal desta change — *evidência: Why / What Changes / Capabilities / Impact*
- [x] 5.3 Escrever `tasks.md` — *evidência: este arquivo*
- [x] 5.4 Escrever `design.md` — *evidência: D1–D8 com alternativas rejeitadas*
- [x] 5.5 Escrever `validation.md` — *evidência: tabelas com valor observado*
- [x] 5.6 Escrever spec capability `estrutura-repositorio` — *evidência: Requirements SHALL + Scenarios*

## 6. Pendências desta change

- [ ] 6.1 Commit dos manifestos OpenSpec e sincronização com o GitHub — *pendente de autorização de commit (R6)*
