# Proposal: Consolidação da estrutura do repositório

## Why

O repositório e a VM `pve-lab` estavam com layouts divergentes: o GitHub tinha
`docs/`, `lab/`, `scripts/` e `notas/`, enquanto a VM mantinha arquivos de estudo
na raiz e a infraestrutura (`aiops-lab.sh`, `boilerplate-k8s-aiops/`, `kube-news/`)
também na raiz. A divergência custava tempo em toda verificação de integridade
(havia que comparar inventário em duas formas diferentes) e impedia a pergunta
mais básica de qualquer auditoria: "o que deveria estar aqui?".

Além disso, o projeto passou a produzir documentação DevOps (plano de autonomia,
arquitetura, runbooks) sem um lugar formal para os manifestos de change que
registram *por que* cada mudança estrutural aconteceu.

Esta change estabelece uma única forma canônica: **o GitHub é o espelho da
verdade e a VM o reproduz**, com os manifestos OpenSpec documentando a mudança
que tornou isso possível.

## What Changes

- **Estrutura canônica** — repositório e VM passam a ter o mesmo inventário:
  - `docs/` — material didático, documentação DevOps e `openspec/`
  - `lab/` — infraestrutura funcional (`boilerplate-k8s-aiops/`, `kube-news/`)
  - `scripts/` — automação (`aiops-lab.sh`)
  - `notas/` — caderno de laboratório
- **Movimento, não cópia** — os 10 itens foram movidos com `mv` (rename
  atômico), sem duplicação. Verificação por hash antes e depois.
- **Correção de caminho em `aiops-lab.sh`** — `BOILERPLATE` passa de
  `$LAB_DIR/boilerplate-k8s-aiops` para `$LAB_DIR/lab/boilerplate-k8s-aiops`,
  única linha que precisou mudar no script.
- **Manifestos OpenSpec** — novo diretório `docs/openspec/` com `config.yaml`,
  esta change e a spec capability `estrutura-repositorio`.
- **Sem alteração no upstream KubeDev** — o clone em `pve-lab` continua com
  material de estudo untracked (R13).

## Capabilities affected

- **Capability nova:** `estrutura-repositorio` — define o inventário canônico,
  as regras de integridade e o processo de verificação em três vias.
- **Afetada indiretamente:** a operação do laboratório (caminho do script mudou,
  mas o contrato `./scripts/aiops-lab.sh up|down|status|logs|reset` permanece).

## Impact

- **Repositório (GitHub):** sem perda — apenas adição de `docs/openspec/`.
- **VM `pve-lab`:** reestruturação física de 10 itens + 3 diretórios; exige
  recriação do `.venv` Python (shebangs com caminho absoluto) e reerguimento da
  stack (Fase 1 do plano).
- **Dados:** volume do PostgreSQL preservado — 174 relatórios intactos.
- **Riscos:** mover diretório com `.venv` invalida executáveis; mitigado com
  backup prévio (`/tmp/backup-antes-consolidar.tar.gz`) e `rm -rf .venv && uv sync`.
