# Checklist de verificação — auditoria do laboratório AIOps

**Data:** 2026-11-01
**Para quem é:** iniciante em DevOps em transição de carreira — use este
roteiro para auditar o ambiente **antes** de uma demonstração, **depois** de
um reset ou quando algo parecer estranho.

**Princípio antes do checklist:** auditoria não é "olhar e achar que está
bem" — é **comparar o que se observou com o que se esperava**, item por item.
**Analogia:** é a lista do piloto antes da decolagem. Piloto experiente não
salta a lista por "conhecer o avião": a lista existe justamente porque a
memória falha no dia em que importa.

---

## Quando rodar este checklist

| Momento | Foco |
|---|---|
| Antes de uma demonstração/aula | seções 1 a 6 (ambiente no ar) |
| Depois de `aiops-lab.sh reset` | seções 2 a 5 (cluster e dados recriados) |
| Depois de mover/reestruturar arquivos | seções 1, 5 e 7 (venv, migrations, repo) |
| Suspeita de "cay no meio" | seção 4 (serviços) + incidentes do Playbook |

---

## Regra de ouro (leia antes de qualquer caixa)

> **Verifique por EXIT CODE, HTTP CODE ou HASH — nunca por string.**
>
> Uma mensagem bonita pode aparecer mesmo quando o serviço caiu; um número
> **não** mente. Detectar estado por `-match` de texto deu **3 falsos
> alarmes** neste laboratório — por isso o projeto registra estado por
> `$LASTEXITCODE` / `$?` / `%{http_code}` (ver
> [`DECISOES-TECNICAS.md`](DECISOES-TECNICAS.md), D6).

Como ler este checklist:

- Cada item traz **o que verificar**, o **comando exato** e o **resultado
  esperado**.
- `[ ]` = pendente · `[x]` = conferido com valor observado.
- **Sucesso só com valor observado** (R9): só marque `[x]` se o número
  apareceu no seu terminal — não se "deveria funcionar".

**Exemplo de item N/A (regra R10):**

> [ ] **N/A — API paga:** verificar cobrança de API paga.
> **Motivo:** o laboratório é 100% gratuito por regra (R1) — o
> `ANTHROPIC_API_KEY` nunca é preenchido; não há cobrança a conferir.
> Item marcado como N/A **permanece na lista** com o motivo — nada simplesmente
> some do relatório.

---

## 1. Ambiente (`pve-lab` — 192.168.15.10)

| # | O que verificar | Comando | Resultado esperado |
|---|---|---|---|
| 1.1 | Acesso SSH sem senha | `ssh pve-lab "echo ok"` | `ok` e exit code 0 |
| 1.2 | RAM livre (sobe cluster só com folga) | `ssh pve-lab "free -m"` | `available` **> 2000** MB |
| 1.3 | Disco livre | `ssh pve-lab "df -h /"` | uso **< 90%** |
| 1.4 | Daemon Docker ativo | `ssh pve-lab "systemctl is-active docker; echo exit=\$?"` | `active` e `exit=0` |
| 1.5 | Versões da toolchain | `ssh pve-lab "docker --version; kubectl version --client; kind version; uv --version"` | versões registradas no README (Docker 29.9.2, kubectl v1.37.1, kind v0.33.0, uv 0.13.5) |

**Armadilha (incidente b):** RAM baixa pode deixar o `ping` responder e a
porta 22 **ABERTA** mesmo com o SSH travado em thrashing de swap — não confira
só a porta, confira o banner/sessão.

## 2. Cluster kind (`aiops`)

| # | O que verificar | Comando | Resultado esperado |
|---|---|---|---|
| 2.1 | Cluster existe | `ssh pve-lab "kind get clusters \| grep -qx aiops; echo \$?"` | `0` |
| 2.2 | Nó único Ready | `ssh pve-lab "kubectl --context kind-aiops get nodes"` | `aiops-control-plane ... Ready` |
| 2.3 | Pods de sistema rodando | `ssh pve-lab "kubectl --context kind-aiops get pods -n kube-system --no-headers"` | todos `Running`/`Completed` |
| 2.4 | API acessível | `ssh pve-lab "kubectl --context kind-aiops get --raw=/healthz"` | `ok` |

**Cuidado:** `kubectl get events` mostra **histórico**, não estado atual —
avisos do bootstrap continuam listados mesmo resolvidos. *Evento não é estado.*

## 3. Cenários de falha intencionais (SUCESSO = falha esperada)

| # | O que verificar | Comando | Resultado esperado |
|---|---|---|---|
| 3.1 | `teste-a` — imagem inexistente | `ssh pve-lab "kubectl --context kind-aiops get pods -n teste-a"` | pod em **`ImagePullBackOff`** (imagem `ngin:latest`) |
| 3.2 | `teste-b` — senha errada | `ssh pve-lab "kubectl --context kind-aiops get pods -n teste-b"` | pods do kube-news em **`Error`**; `postgre` em **`Running`** |

**Armadilha:** um iniciante vê `ImagePullBackOff` e tenta "consertar" a imagem.
Não é bug — é o **cenario plantado** para estudar diagnóstico.

## 4. Serviços

| # | O que verificar | Comando | Resultado esperado |
|---|---|---|---|
| 4.1 | App — health check | `ssh pve-lab "curl -s -o /dev/null -w '%{http_code}\n' http://localhost:8000/api/health"` | **`200`** |
| 4.2 | App — corpo da resposta | `ssh pve-lab "curl -s http://localhost:8000/api/health"` | `{"status":"ok"}` |
| 4.3 | MCP — endpoint | `ssh pve-lab "curl -s -o /dev/null -w '%{http_code}\n' http://localhost:3001/mcp"` | **`405`** (esperado: exige POST) |
| 4.4 | Postgres pronto | `ssh pve-lab "docker compose -f ~/projetos/imersao-aiops-prod-01/boilerplate-k8s-aiops/docker-compose.yml exec -T postgres pg_isready -U aiops -d aiops_k8s; echo \$?"` | `accepting connections` e exit `0` |
| 4.5 | pgAdmin responde | `ssh pve-lab "curl -s -o /dev/null -w '%{http_code}\n' http://localhost:5050/"` | `200` ou `302` |

**Cuidado:** `405` no MCP **não é erro** — é o comportamento esperado de um
endpoint que só aceita `POST` (JSON-RPC). Tratar qualquer número ≠ 200 como
queda gera falso alarme.

## 5. Dados (relatórios no PostgreSQL)

| # | O que verificar | Comando | Resultado esperado |
|---|---|---|---|
| 5.1 | Banco acessível | `ssh pve-lab "docker compose -f .../docker-compose.yml exec -T postgres psql -U aiops -d aiops_k8s -c 'select 1;'"` | `1` (exit 0) |
| 5.2 | Tabela `reports` com dados | `ssh pve-lab "docker compose -f .../docker-compose.yml exec -T postgres psql -U aiops -d aiops_k8s -tAc 'select count(*) from reports;'"` | número **> 174** (baseline: 174 originais + relatórios novos gerados pela app — o total **cresce** por design; sessão observada: 174 → 175 → 176) |
| 5.3 | Migration na head | `ssh pve-lab "docker compose -f .../docker-compose.yml exec -T postgres psql -U aiops -d aiops_k8s -tAc 'select version_num from alembic_version;'"` | `a3c1f0e2b9d4` |

## 6. Aplicação Python (`uv`, `.venv` e migrations)

| # | O que verificar | Comando | Resultado esperado |
|---|---|---|---|
| 6.1 | `uv` presente e no PATH | `ssh pve-lab "bash -lc 'uv --version'"` | `uv 0.13.5` (exit 0) |
| 6.2 | `.venv` íntegro (shebangs) | `ssh pve-lab "head -1 <projeto>/.venv/bin/alembic"` | `#!/.../.venv/bin/python` com caminho **existente** |
| 6.3 | Dependências batem com o lock | `ssh pve-lab "bash -lc 'cd <projeto> && uv sync'"` | `Checked ... packages` **sem** erro de spawn |
| 6.4 | Alembic executa de verdade | `ssh pve-lab "bash -lc 'cd <projeto> && uv run alembic current'"` | mostra a head `a3c1f0e2b9d4` (exit 0) |
| 6.5 | Nenhuma chave de API paga | `ssh pve-lab "grep -R 'ANTHROPIC_API_KEY=' <projeto>/.env 2>/dev/null \| grep -v '=$'"` | **vazio** — chave nunca preenchida (R1) |

**Armadilha (incidente c):** se 6.2 apontar para caminho inexistente, o
`.venv` foi movido e tem shebangs quebrados — `uv sync` **não** conserta
(`Checked 108 packages` e nada muda). Correção: `rm -rf .venv && uv sync`.

**Cuidado (R1):** o `.env` pode existir com a variável **vazia**; o problema é
ter **valor real**. Nunca cole token em log, chat ou commit (R4).

## 7. Acesso externo (a partir do Windows — 192.168.15.38)

| # | O que verificar | Comando | Resultado esperado |
|---|---|---|---|
| 7.1 | App via IP da VM | `curl.exe -s -o NUL -w "%{http_code}`n" http://192.168.15.10:8000/api/health` | **`200`** |
| 7.2 | MCP via IP da VM | `curl.exe -s -o NUL -w "%{http_code}`n" http://192.168.15.10:3001/mcp` | **`405`** |
| 7.3 | pgAdmin via IP da VM | navegador → `http://192.168.15.10:5050` | tela de login do pgAdmin |

**Armadilha (incidente e):** no Windows, `http://localhost:8000` **não** é o
lab — `localhost` é a própria máquina. Serviço de outra máquina se acessa
pelo IP: `192.168.15.10`.

## 8. Integridade de repositório

| # | O que verificar | Comando (no Windows, em `devops-profissional`) | Resultado esperado |
|---|---|---|---|
| 8.1 | Working tree limpo | `git status --porcelain` | saída **vazia** (exit 0) |
| 8.2 | Local == remoto | `git fetch origin && git status -sb` | `Your branch is up to date with 'origin/...'` |
| 8.3 | Raiz conforme regra | `git ls-tree --name-only HEAD` | só `README.md`, `CREDITS.md`, `.gitignore`, `.gitattributes`, `docs/`, `lab/`, `scripts/`, `notas/` |
| 8.4 | Nenhum segredo versionado | `git ls-files \| Select-String -Pattern "\.env$\|id_rsa\|token"` | **vazio** (R4/R1: nada de token ou `.env` real no repo) |

**Cuidado:** o `.gitignore` deve esconder `.env`, `.venv/`, `node_modules/` —
mas confira com `git ls-files`, porque "está no .gitignore" não prova que
**não foi commitado antes** de a regra existir.

## 9. Modelo de relatório de evidências

Copie e preencha com o **valor observado** no seu terminal (R9). Exemplo
honesto de uma auditoria:

```
AUDITORIA — 2026-11-01 — pve-lab 192.168.15.10

[ x ] 1.2 RAM livre ............ observed: available 5812 MB   (> 2000)
[ x ] 2.2 Nó Ready ............. observed: aiops-control-plane Ready
[ x ] 3.1 teste-a .............. observed: ImagePullBackOff    (falha plantada OK)
[ x ] 4.1 App health ........... observed: HTTP 200
[ x ] 4.3 MCP /mcp ............. observed: HTTP 405            (esperado: exige POST)
[ x ] 5.2 Relatórios ........... observed: count = 176 (baseline 174 + gerados pela app; cresce por design)
[ N/A ] API paga ............... motivo: laboratório 100% gratuito (R1)
[   ] 7.2 Local == remoto ...... PENDENTE — verificar no Windows

Veredito: ambiente íntegro; 1 item pendente.
```

## 10. Registro de evidências

- [ ] Todos os itens auditados têm **valor observado** registrado (R9).
- [ ] Itens não aplicáveis estão marcados **`N/A — motivo`** e **constam da
      lista** (R10).
- [ ] Nenhum token/segredo foi colado em log, chat ou commit (R4).
- [ ] Erros novos foram anotados no
      [`PLAYBOOK-INCIDENTES.md`](PLAYBOOK-INCIDENTES.md) com sintoma, causa e
      correção.
- [ ] Pendências do relatório foram levadas para a próxima auditoria (nada
      some: item pendente continua na lista).

## 11. Erros comuns ao rodar o próprio checklist

| Erro ao auditar | O que aconteceu | Como evitar |
|---|---|---|
| `ssh pve-lab "uv run ..."` → comando não encontrado | shell não-interativo sem PATH (incidente d) | usar `bash -lc '...'` em todo comando remoto que chame `uv` |
| Testar `localhost` **no Windows** e dar `000` | localhost é relativo a quem pergunta (incidente e) | testar de fora com `192.168.15.10`; `localhost` só dentro da VM |
| Marcar `[x]` sem anotar o número | é o pecado contra R9 — sucesso presumido | anotar o valor observado **na hora**, não de memória |
| Apagar um item "porque não se aplica" | quebra R10 — o item deve virar `N/A — motivo` | manter a linha na lista com o motivo escrito |

---

*Checklist de estudo. As saídas são as esperadas no laboratório em
2026-11-01; confirme sempre no seu terminal antes de marcar qualquer caixa.*
