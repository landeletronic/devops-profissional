# Créditos e atribuições

Este repositório reúne dois tipos de material com origens distintas. A
separação é declarada aqui de forma explícita, como manda a boa prática.

---

## Material de terceiros

### KubeDev — *imersão AIOps em Produção*

A aplicação-alvo, o projeto boilerplate, os documentos de requisito, as
especificações e os cenários de falha deste laboratório têm origem na imersão
**"AIOps em Produção"**, da **KubeDev**.

- **Repositório original:**
  <https://github.com/KubeDev/imersao-aiops-prod-01>
- **Autores:** equipe KubeDev / instrutores da imersão
- **Uso aqui:** material cedido aos participantes para fins de estudo,
  reproduzido com atribuição e sem qualquer pretensão de autoria.

O que foi aproveitado:

| Item | Caminho |
|---|---|
| Boilerplate da aplicação (FastAPI + LangChain + MCP) | `lab/boilerplate-k8s-aiops/` |
| Documentos de requisito (PRDs) | `lab/boilerplate-k8s-aiops/docs/prds/` |
| Especificações e mudanças (OpenSpec) | `lab/boilerplate-k8s-aiops/openspec/` |
| Manifestos de Kubernetes com cenários de falha | `lab/boilerplate-k8s-aiops/manifestos-k8s/` |
| Migrações de banco (Alembic) | `lab/boilerplate-k8s-aiops/alembic/` |
| Aplicação `kube-news` | `lab/kube-news/` |
| **Slides das aulas** (4 PDFs) | `docs/slides/` |
| **Módulo de exercícios** *prompt e contexto na prática* | `docs/prompt-e-contexto-na-pratica/` |
| Regras do ambiente e script de subida | `docs/AGENTS.md`, `docs/AMBIENTE.md`, `scripts/aiops-lab.sh` |

> **Observação sobre licença:** o repositório original **não possui arquivo de
> licença**. Na ausência de licença, vigora a proteção legal padrão — todos os
> direitos reservados ao autor. Este material é reproduzido aqui
> exclusivamente no contexto de estudo da imersão, com atribuição. Para uso,
> redistribuição ou derivação — **em especial os slides, que são a
> apresentação da aula** —, **consulte o repositório original e os autores**.

### Projetos de terceiros utilizados

A aplicação depende de projetos com suas próprias licenças, resolvidas
automaticamente pelo `uv` a partir do `uv.lock` — nenhum deles é copiado para
este repositório:

FastAPI · Starlette · Uvicorn · SQLAlchemy · Alembic · LangChain ·
LangGraph · LangChain Anthropic · MCP Python SDK · Kubernetes (client Python) ·
Pydantic · httpx · asyncpg

---

## Material autoral deste repositório

Produzido durante o estudo, com autoria própria:

| Item | Caminho |
|---|---|
| Glossário de DevOps — 16 blocos, 870 linhas | `docs/GLOSSARIO-DEVOPS.md` |
| Plano de ensino estruturado | `docs/PLANO-DE-ENSINO.md` |
| Caderno de laboratório — passo a passo, saídas reais, erros e correções | `notas/CADERNO-DE-LABORATORIO.md` |
| Override do Docker Compose | `lab/boilerplate-k8s-aiops/docker-compose.override.yml` |
| Este arquivo e o `README.md` | raiz |

---

## Declaração

Este é um **repositório de estudo**. Nenhuma parte deste material deve ser
entendida como obra original da KubeDev nem como distribuição autorizada da
imersão. Eventuais erros nas versões, comandos ou interpretações são da
autoria deste repositório e não dos instrutores.
