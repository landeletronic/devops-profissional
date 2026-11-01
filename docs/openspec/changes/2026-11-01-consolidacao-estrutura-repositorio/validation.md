# Evidência de validação — Consolidação da estrutura (2026-11-01)

Todas as evidências abaixo foram **observadas** na execução real, por exit
code, HTTP code, hash ou contagem. Nenhum item é inferido.

## 1. Segurança antes do movimento

| Item | Resultado | Evidência |
|---|---|---|
| Backup criado antes do 1º `mv` | Aprovado | `/tmp/backup-antes-consolidar.tar.gz` — 6.886.463 bytes |
| Backup sem `.venv` | Aprovado | `--exclude='.../boilerplate-k8s-aiops/.venv'` no tar |
| Inventário antes registrado | Aprovado | md5 + bytes: `be0d718d` AGENTS.md, `a00e05d5` AMBIENTE.md, `24747812` GLOSSARIO, `fd50be95` PLANO, `43b49577` aiops-lab.sh, `fbb9233c` AULA-M0 |
| Riscos levantados antes de agir | Aprovado | `riscos.sh`: bind mounts ausentes, `.venv` 274 MB, composição rodando a partir do caminho antigo |

## 2. Movimentação

| Item | Resultado | Evidência |
|---|---|---|
| 7 itens de estudo → `docs/` | Aprovado | 7× `[OK]` na Fase 2 |
| Primeira tentativa falhou com causa real | Aprovado (registrado) | `mv: cannot move ... 'scripts/aiops-lab.sh': No such file or directory` — diretório destino inexistente |
| Causa corrigida e movimento refeito | Aprovado | Fase 2b: `scripts/` e `lab/` criados, 3× `[OK]` |
| `boilerplate-k8s-aiops` intacto | Aprovado | 10.423 arquivos antes **e** depois |
| `kube-news` intacto | Aprovado | 122 arquivos antes **e** depois |
| Script corrigido | Aprovado | linha 18 → `BOILERPLATE="$LAB_DIR/lab/boilerplate-k8s-aiops"`; hash `43b49577` → `d69616e0` |
| Estrutura final = GitHub | Aprovado | raiz: `docs`, `lab`, `notas`, `scripts`; `docs/` com 10 itens |

## 3. Reparo do `.venv`

| Item | Resultado | Evidência |
|---|---|---|
| Shebangs quebrados após mover | Falha detectada | 26 de 39 executáveis apontavam para o caminho sem `/lab/` |
| `uv sync` como correção | **Insuficiente** | `Resolved 110 packages in 7ms` / `Checked 108 packages in 283ms` — nada reinstalado; `alembic: Failed to spawn` |
| `rm -rf .venv && uv sync` | Aprovado | 110 pacotes reinstalados do `uv.lock` |
| Shebangs depois | Aprovado | **0 quebrados** de 36 scripts |
| `alembic` funcional | Aprovado | `alembic 1.18.5` |
| Imports | Aprovado | `uvicorn, alembic, fastapi` → `imports OK` |

## 4. Restauração da stack (Gate Fase 1)

| Item | Resultado | Evidência |
|---|---|---|
| Containers | Aprovado | postgres, pgadmin, aiops-control-plane — 3× `Up` |
| `kubectl` | Aprovado | responde; namespaces `teste-a`, `teste-b` presentes |
| Memória da VM (Fase 0) | Aprovado | `MemTotal: 8130996 kB (7.8 GB)`, `MemAvailable: 6207776 kB (5.9 GB)` |
| App `:8000` | Aprovado | `curl localhost:8000/api/health` → **HTTP 200** |
| MCP `:3001` | Aprovado | `curl localhost:3001/mcp` → **HTTP 405** (exige POST, normal) |
| App via IP da VM | Aprovado | `192.168.15.10:8000/api/health` → **HTTP 200** |
| Acesso do Windows | Aprovado | `Invoke-WebRequest` → `HTTP 200`, corpo `{"status":"ok"}` |
| Migrations | Aprovado | `alembic current` → `a3c1f0e2b9d4 (head)` |
| Dados preservados | Aprovado | 174 relatórios originais (`2026-10-22`→`2026-10-26`) + 1 gerado na subida (`2026-11-01 22:19:10`) = 175 |
| Cenários de falha | Aprovado | `teste-a`: `ImagePullBackOff`; `teste-b`: 10 pods `Error` — **intencionais** (D8) |
| `up` com exit code | Aprovado | `exit do up: 0` |

## 5. Commit e sincronização

| Item | Resultado | Evidência |
|---|---|---|
| Commit do plano | Aprovado | `c628ec8` — 350 inserções, exit 0 |
| Push | Aprovado | `250ca7c..c628ec8  main -> main`, exit 0 |
| Local == remoto | Aprovado | `c628ec85a5051d076073eb3f60aaac4961a101a2` em ambos |
| Raiz conforme R7 | Aprovado | `README.md`, `CREDITS.md`, `.gitignore`, `.gitattributes` + `docs`, `lab`, `notas`, `scripts` |

## 6. Itens que não se aplicam

| Item | Motivo |
|---|---|
| Rollback do backup | N/A — nenhum dado perdido, backup não precisou ser usado |
| Alteração do upstream KubeDev | N/A — clone permanece intacto e material de estudo untracked (R13) |
