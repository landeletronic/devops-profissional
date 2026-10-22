# Plano de Ensino — Do Zero ao DevOps Profissional

**Para quem é este documento:** para alguém que está começando em TI do zero, mas
disposto a construir uma carreira técnica.

**Objetivo final:** tornar-se capaz de **operar, automatizar e evoluir** a
infraestrutura de uma empresa — com um diferencial: saber colocar **IA** no
caminho crítico da operação, com segurança.

**Duração estimada:** 11 meses, ~10 h/semana (≈ 480 h totais).

**Material de origem:** a imersão *AIOps em Produção* (repo `imersao-aiops-prod-01`,
4 slides de aula, boilerplate de agente AIOps) + as lacunas de DevOps clássico que
esse material não cobre.

---

## 0. O princípio que governa este plano

> **Você não aprende a operar infraestrutura executando comandos.
> Você aprende executando, observando e explicando.**

Cada módulo tem uma **Prova**. Não é "o comando rodou" — é **você explicar o que
aconteceu e por que**. Sem a prova explicada, o módulo não está concluído.

Isso não é preciosismo pedagógico. É a diferença entre quem decora e quem
consegue **diagnosticar um problema real às 3h da manhã** — que é o trabalho.

### Os quatro papéis que o DevOps exerce

| Papel | O que faz | Onde você vai treinar |
|---|---|---|
| **Constrói** | escreve o código e a infraestrutura | M3, M4, M5 |
| **Entrega** | leva do código à produção, repetível | M2, M6 |
| **Opera** | mantém no ar, sabe o que está rodando | M4, M7 |
| **Evolui** | melhora, mede, documenta decisões | M7, M9, M10 |

O erro clássico do iniciante é tentar ser os quatro ao mesmo tempo. O plano
**serializa**: cada módulo só exige o anterior.

---

## 1. Ritmo de estudo

### A semana padrão (10 h)

| Dia | Tempo | O quê | Onde |
|---|---|---|---|
| Seg / Qua / Qui | 1 h cada | **Teoria**: ler + exercícios de leitura | MATERIAL DIDÁTICO |
| Sex / Sáb | 1 h cada | **Exercícios** guided (ambiente guiado) | HANDS-ON NIVEL 1 |
| Dom | 3–4 h | **Lab**: projeto com prazo aberto | HANDS-ON NIVEL 2 |
| — | 1 h | **Anotação**: escrever o que aprendeu | `notas/` |

### A regra dos 3 níveis de mão na massa

O mesmo tema é praticado em três profundidades. Isso é proposital: quem só
assiste vídeo não opera; quem só copia comando não entende.

| Nível | Como é | Objetivo |
|---|---|---|
| **N1 — Guiado** | tutorial passo a passo, você segue | Ver o conceito **funcionando** |
| **N2 — Projeto** | enunciado com objetivo, você decide como | **Conquistar** a habilidade |
| **N3 — Livre** | problema real, sem passo a passo | **Dominar** |

> Só se avança de um módulo para o próximo quando o **N2** do módulo atual está
> pronto. O N3 é a Diferença entre "sabe fazer" e "sabe fazer sob pressão".

### O ciclo de cada módulo (2 a 3 semanas)

```
Semana A:  Teoria ──────────► exercícios guiados (N1)
Semana B:  Projeto (N2) ─────► depurar, errar, refazer
Semana C:  Consolidação ─────► refazer sem ajuda + escrever a Prova
```

**Semana C é onde o aprendizado acontece.** Sem ela, você vicia no N1 e nunca
desenvolve autonomia.

### Ritmo de leitura

- **1 h de leitura = 20 min de leitura + 40 min de práctica.** Ler sem executar
  não fixa nada.
- Ao terminar qualquer material, escreva **3 linhas**: o que é, por que importa,
  onde você vai usar. No arquivo `notas/`.
- Se um parágrafo não fez sentido: anote a dúvida e **siga**. A comprehension
  chega depois, no N2.
- **Termo travou? Abra `GLOSSARIO-DEVOPS.md` antes de travar o estudo.** Ele é
  organizado por bloco (M1…M10) na mesma ordem do plano — procure no bloco do
  módulo atual. Para dúvidas rápidas, use as tabelas **Pares que confundem**,
  **Siglas** e **Frases de reunião** no fim do arquivo.
- Toda vez que um termo **novo** aparecer e não estiver no glossário, acrescente
  a entrada no bloco do módulo correspondente. O glossário cresce com você.

---

## 2. Mapa geral dos 11 módulos

| # | Módulo | Semanas | Horas | Entregável (a Prova) |
|---|---|---|---|---|
| **M0** | Ambientação e o guia de campo | 1 | 10 | Ambiente reproducible + tour do repo |
| **M1** | Computação, Linux e rede | 6 | 60 | Script de diagnóstico de host |
| **M2** | Git e GitHub | 3 | 30 | PR + CI rodando num repo próprio |
| **M3** | Containers com Docker | 4 | 40 | App containerizada e validada |
| **M4** | Orquestração com Kubernetes | 7 | 70 | Cluster multi-node no pve-lab + app com probes provadas |
| **M5** | Infraestrutura como código | 5 | 50 | Infra do lab inteira em código, do zero |
| **M6** | CI/CD | 4 | 40 | Pipeline que sobe, testa e publica |
| **M7** | Observabilidade | 4 | 40 | Dashboard de SLO + alerta que antecipa a falha |
| **M8** | Segurança e redes | 3 | 30 | Pipeline com hardening e NetworkPolicy |
| **M9** | Cloud real | 4 | 40 | Mesmo workload na nuvem, sem mudar o código |
| **M10** | AIOps: o agente na operação | 5 | 50 | Agente detectando, propondo e corrigendo |
| **M11** | Profissionalização | 4 | 40 | Post-mortem + portfólio + entrevista |
| | **TOTAL** | **50 sem** | **500 h** | |

> As semanas são **estimativas**. Trimestre de prova de trabalho na empresa? Dobre
> o M1. Sentou e o conceito clicked? Pule o N1 e vá direto ao N2.
> **O cronograma é um mapa, não um trilho.** O critério de avanço é a Prova.

---

## 3. Os módulos em detalhe

---

### M0 — Ambientação e o guia de campo
**Semana 1 · 10 h · Objetivo: saber onde você está e ter o todo à vista.**

**Conceito.** Antes de operar, você precisa saber o que está na mesa. Este módulo
não ensina tecnologia — ensina **o mapa**.

**Material didático**
- O `Guia de Preparação` da imersão (o PDF que você já tem) — 30 min
- Os 4 slides da aula 01 — 1 h, **apenas para saber o que existe** (não para
  entender tudo)
- Leitura do README do repo `imersao-aiops-prod-01` — 30 min

**Mão na massa (N1)**
1. Abrir o repositório e mapear as três partes: `boilerplate-k8s-aiops` (o agente),
   `kube-news` (a app alvo), `prompt-e-contexto-na-pratica` (exercícios)
2. Subir a interface web do agente e **clicar em cada relatório**. Ver um agente
   propor uma correção é o que vai te dar lapidação para as 500 h seguintes
3. Rodar `aiops-lab status` e entender **cada linha** da saída
4. Abrir o cluster e ver os pods: `kubectl get pods -A`

**Prova.** Em 5 minutos, sem consultar: explique para uma pessoa não técnica o que
é um container, um cluster Kubernetes e um agente — e por que o agente precisa de
um "sim" humano antes de agir.

**Entregável.** `notas/M0-mapa.md` — o diagrama que **você** desenhou do sistema,
com suas palavras.

---

### M1 — Computação, Linux e rede
**Semanas 2–7 · 60 h · Objetivo: entende o computador por baixo.**

> **Este é o módulo mais importante e o mais ignorado.** Sem ele, todo o resto é
> decorado. Com ele, você **diagnostica** em vez de pesquisar no Google.

**Conceito — os 5 blocos**

1. **O computador** — CPU, memória, disco, processo, sistema de arquivos
2. **O terminal** — comandos são texto; o shell é um interpretador
3. **O Linux** — usuário, permissão, serviço, porta, processo
4. **A rede** — IP, porta, DNS, HTTP, TCP
5. **O processo systemd** — o que roda, quem reinicia, como você descobre

**Material didático**

| Recurso | Formato | Tempo | Obrigatório? |
|---|---|---|---|
| *The Linux Command Line* (William Shotts) — `linuxcommand.org` | PDF grátis | 8 h | **Sim** (cap. 1–8) |
| *Linux Journey* — `linuxjourney.com` | site interativo | 4 h | Sim |
| Curso "CS50's Introduction to Linux" (Harvard, free) | vídeo | 6 h | Sim |
| "Bash Scripting" —fireship.io (30 min) | vídeo | 0,5 h | Sim |
| *Pro Git* cap. 1–3 — `git-scm.com/book` | PDF grátis | 3 h | Sim (pré-requisito do M2) |
| *Computer Networking* — Prof. Kurose (1ª aula) | vídeo | 4 h | Opcional |
| Fireship: "Linux in 100 seconds", "Docker in 100 seconds" | vídeo | 0,5 h | Sim |

**Mão na massa**

- **N1 (sem 2–3):** um terminal Linux do zero. Criar usuário, permissões
  (`chmod`), ler um arquivo de configuração, ver processos (`ps`), ver portas
  (`ss`), ler logs (`journalctl`).
- **N2 (sem 4–5):** **Script de diagnóstico de host.** Escreva um script Bash que
  recebe um host e responde: CPU, memória, disco, portas abertas, serviços
  systemd ativos, últimos erros. Ele deve rodar **no pve-lab**, por SSH, e
  devolver um relatório. (Este script é a base do seu script de plantão.)
- **N3 (sem 6–7):** o mesmo script, agora contra **vários** hosts, com
  paralelismo, timeout por host, e saída em JSON.

**Prova.** Responda por escrito, sem consultar:
1. Qual a diferença entre `chmod 755` e `chmod 644`? O que cada bit controla?
2. Uma aplicação responde "connection refused" na porta 8080. Quatro causas
   possíveis — **liste quatro e diga como distinguir cada uma**.
3. O que `journalctl -u docker -f` mostra e por que você usaria isso?
4. Explique o que um processo "zombie" é e como isso se relaciona com PID 1.

**Entregável.** `notas/M1-diagnostico.md` + o script no seu repo.

---

### M2 — Git e GitHub
**Semanas 8–10 · 30 h · Objetivo: versionar e colaborar sem medo.**

**Conceito.** Git guarda **histórico** — e histórico é a diferença entre "corrigi
o bug" e "consigo voltar ao estado anterior". No trabalho em equipe, Git é o
protocolo de **conversação** sobre mudanças.

**Material didático**
- *Pro Git* (git-scm.com/book) — o livro oficial, grátis — 6 h
- Fireship: "Git in 100 seconds" e "Git Branching" (15 min cada)
- GitHub Skills (github.com/skills) — trilhas oficiais de GitHub

**Mão na massa**
- **N1:** `init` → `add` → `commit` → `log` → `diff` → `branch` → `merge` →
  `rebase` → `revert` → `stash`. Entenda **cada** comando.
- **N2:** refatore a `kube-news` em 5 commits semânticos
  (`feat:`, `fix:`, `refactor:`, `test:`, `docs:`) e abra um Pull Request com
  descrição e checklist. Peça review a alguém — ou a uma IA — e responda.
- **N3:** resolva um conflito de merge **de propósito** (crie um, resolva, explique).

**Prova.**
1. Qual a diferença entre `merge` e `rebase`? Quando usar cada um?
2. O que faz `git reset --hard`? Quando é **perigoso**?
3. Escreva a mensagem de commit de uma mudança que quebra a API. (Critério: diz
   **o que** mudou e **por quê**, não "ajustei o bug")
4. O que é `.gitignore` e por que `secrets.env` nunca pode estar versionado?

**Entregável.** Um repositório seu, público, com README decente.

---

### M3 — Containers com Docker
**Semanas 11–14 · 40 h · Objetivo: a mesma coisa em toda máquina.**

**Conceito.** O problema "funciona na minha máquina" é resolvido empacotando código
+ dependências + configuração num **artefato imutável**. Daí saem imagem ×
container, camadas, registry, volumes, redes e o `PID 1`.

**Material didático**

| Recurso | Formato | Tempo |
|---|---|---|
| Skill `containerizar-docker` (dentro do repo) | documento | 1 h |
| Docker Official Get Started — `docs.docker.com/get-started` | site | 4 h |
| *Docker Deep Dive* (Nigel Poulton) — capítulos 1–6 | PDF/livro | 5 h |
| Labs "Docker Swarm" / "Container Security" — `labs.play-with-docker.com` | browser | 4 h |
| Fireship: "Docker Compose in 100 seconds" | vídeo | 0,5 h |

**Mão na massa**
- **N1 (sem 11–12):** containerize a `kube-news`. Dockerfile + `.dockerignore` +
  compose com Postgres. Valide com as **13 regras (D1–D13)** da skill.
- **N2 (sem 13):** **faça do zero uma imagem de produção** de um serviço seu (ou
  da `kube-news` reescrita): multi-stage build, usuário não-root, `tini` como
  PID 1, healthcheck, sem segredo na imagem. Publique no seu registry.
- **N3 (sem 14):** a mesma app, **com e sem** `tini`, e **com e sem** `USER
  non-root`. Meça: quanto tempo um `docker stop` leva em cada caso? Por quê?

**Prova.**
1. Imagem e container: qual a diferença, e o que acontece com o filesystem do
   container quando ele morre?
2. Por que a ordem das camadas no Dockerfile importa para o tempo de build?
3. Um container ignora SIGTERM. Qual o efeito prático no `docker stop` e no
   Kubernetes, e o que causa?
4. Por que `latest` é proibido em produção? (responda com um cenário concreto)

**Entregável.** `notas/M3-docker.md` + imagem publicada + relatório D1–D13.

---

### M4 — Orquestração com Kubernetes
**Semanas 15–21 · 70 h · Objetivo: declarar o estado e deixar o cluster perseguir.**

> **Módulo central da carreira.** É aqui que o DevOps se distingue do "administrador
> de servidor".

**Conceito.** Estado desejado × estado real; reconciliação; control plane ×
workers; a cadeia Deployment → ReplicaSet → Pod; Service e seus tipos;
ConfigMap/Secret; probes; resources; RBAC; namespace.

> **✅ Capacidade do `pve-lab` — resolvida.** A VM tem **8 GB de RAM** (4 vCPU,
> 232 GB livres, cgroup v2). O cluster de 3 nós consome ~2,5 GiB, sobrando
> **~5 GiB de folga** — suficiente para a turbulência da fase N3 (matar nós,
> esgotar recursos) sem o OOM killer do host embaralhar o experimento.

**Material didático**

| Recurso | Formato | Tempo |
|---|---|---|
| *Kubernetes: Up and Running* (bohrium.io) | PDF grátis | 6 h |
| *Kubernetes the Hard Way* (kelseyhightower) | repo + vídeo | 6 h |
| Docs oficiais — `kubernetes.io/docs` (conceitos) | site | 8 h |
| Skill `deploy-kubernetes` (dentro do repo) | documento | 1 h |
| Slides aula 01 (páginas de Docker→K8s) | PDF | 2 h |
| KodeKloud / killercoda (labs guiados) | browser | 6 h |

**Mão na massa**

- **N1 (sem 15–16):** no cluster kind local, seguindo o tutorial, aplique a
  `kube-news`: Deployment, Service, probes, resources. Valide K1–K12.
- **N2 (sem 17–19):** **cluster kind multi-node (3 nós) no `pve-lab`** — não no
  Windows. Crie os nós com um `kind-config.yaml` de 3 nós (os "nós" são
  **containers** dentro do `pve-lab`, não VMs — **não usar Proxmox**) e prove:
  - rollout completo
  - **balanceamento** (`/health` alterna o hostname entre réplicas)
  - **readiness** tirando o pod do Service
  - **liveness** reiniciando o pod
  - **persistência** do banco sobrevive à morte do pod
  - um pod **deliberadamente** morto é reposto sem intervenção
- **N3 (sem 20–21):** **turbulência.** Mate nós, apague pods, esgote recursos.
  Escreva o **post-mortem** de cada incidente. O que o cluster se auto-recuperou
  e o que precisou de você?

**Prova.**
1. Explique reconciliação sem usar a palavra "desejado" nem "real".
2. liveness vs readiness: o que cada uma reinicia/tira? Quando usar **as duas**?
3. Por que existe Service se o Pod tem IP? O que acontece com as conexões
   existentes quando um pod morre?
4. Um pod está `Running` mas `NotReady`. O Service o usa? O kubelet o reinicia?
   (resposta: Service **não** usa; kubelet **não** reinicia — liveness é outra
   probe. Essa confusão é a causa nº1 de incidente.)
5. Quais são os 3 tipos de Service e até onde cada um alcança?

**Entregável.** `notas/M4-kubernetes.md` + post-mortens da fase de turbulência.

---

### M5 — Infraestrutura como Código
**Semanas 22–26 · 50 h · Objetivo: a infraestrutura é código, versionado e repetível.**

**Conceito.** Sem IaC, a infraestrutura é estado vivo que ninguém sabe explicar.
Com IaC, ela é **declaração versionada** — reviewável, repetível, destrutível.

**Material didático**
- Terraform: `developer.hashicorp.com/terraform/tutorials` (oficial) — 6 h
- Terraform Registry + provider `kreuzwerker/docker` — 3 h
- Ansible: "Getting Started" + playbooks — 4 h
- *Terraform: Up & Running* (Yevgeniy Brikman, grátis online) — 4 h
- Slides aula 02 (spec-driven dev) — 2 h

> **Sem Proxmox, o que provisionar?** O `pve-lab` é uma VM fixa e a regra do
> projeto proíbe o Proxmox. Então o M5 se divide do jeito que a divisão real
> pede — **Ansible configura a máquina que existe; Terraform provisiona
> o que não existe:**
>
> | Ferramenta | Papel no M5 | Alvo |
> |---|---|---|
> | **Ansible** | configura o servidor | `pve-lab` — base inteira |
> | **Terraform** | provisiona containers e volumes | Docker no `pve-lab` |
> | *Terraform + cloud* | provisiona VMs de verdade | **delegado ao M9** |
>
> A **Prova 3** já pede exatamente essa divisão — e aqui você vai poder
> respondê-la com a experiência em vez da teoria.

**Mão na massa**
- **N1 (sem 22–23):** **Ansible configura o `pve-lab` do zero.** Escreva um
  playbook que instala tudo o que hoje está faltando (`curl`, `git`, `jq`,
  Docker Engine, `daemon.json`, `kubectl`, `kind`, `uv`, Node 24) e configure
  o `tlandskron` no grupo `docker`. Prova: **destrua a VM e reconstrua com
  `ansible-playbook` — deve ficar idêntica.** Este playbook é o que torna o
  M0 reproduzível.
- **N2 (sem 24–25):** **Terraform declara a pilha do laboratório** — rede Docker,
  volume do Postgres, os containers (`postgres`, `pgadmin`, `mcp-server`,
  `agent`). Depois: `terraform destroy` e `terraform apply` e prove que volta
  **idêntico**.
- **N3 (sem 26):** **Infra do zero.** Apague tudo e reconstrua com **um comando**
  (`ansible-playbook` + `terraform apply`). Meça o tempo. Depois descubra um
  arquivo de estado perdido — e recupere.

**Prova.**
1. Por que o estado do Terraform precisa estar em storage remoto e versionado?
2. O que é *drift* e como você o detecta? (Rode `terraform plan` sem mudar nada
   e mostre a saída quando existe drift.)
3. Terraform ou Ansible: qual você usaria para **criar** um container e para
   **configurar** um serviço já criado? Por que a divisão? **Responda com base
   no que você fez em N1 e N2.**
4. Sua infra inteira é destruída e reconstruída. O que NÃO volta igual? (state,
   dados, secrets — e o que fazer com cada um)
5. O `ansible-playbook` reconstruiu o `pve-lab` idêntico. Qual parte **não**
   foi idêntica? (resposta: segredo e estado — e por que isso é inevitável)

**Entregável.** `notas/M5-iac.md` + repositório `infra/` com o playbook do
`pve-lab` e a pilha do lab em Terraform. Os dois devem recriar o ambiente
**a partir de uma VM Debian vazia**.

---

### M6 — CI/CD
**Semanas 27–30 · 40 h · Objetivo: do `git push` à produção, repetível.**

**Conceito.** CI é *verificação automatizada*; CD é *entrega automatizada*. O
objetivo não é "deploy rápido" — é **nenhum commit chegar à produção sem passar
pelas mesmas verificações**.

**Material didático**
- GitHub Actions — `docs.github.com/actions` (oficial) — 6 h
- *GitHub Actions: The Missing Manual* (free, `rgiesley`/prisma) — 4 h
- GitHub Skills (oficial) — `github.com/skills` — 4 h
- Fireship: "GitHub Actions in 100 seconds" — 0,5 h
- Slides aula 02 (ciclo de change do OpenSpec) — 2 h

**Mão na massa**
- **N1 (sem 27–28):** um workflow que roda o **test suite** a cada push e **bloqueia
  o merge** se falhar (branch protection). Rode no seu repo do M2.
- **N2 (sem 29):** pipeline completo da `kube-news`: **build** da imagem →
  **scan** (Trivy) → **push** no registry → **deploy** no kind → **smoke test** →
  **rollback** automático se o smoke falhar.
- **N3 (sem 30):** **matrix strategy** (vários nodes e versões) + **cache** de
  dependências. Meça: quanto o cache economizou no tempo de build?

**Prova.**
1. CI vs CD: onde exatamente está a diferença no seu pipeline?
2. O que é *branch protection* e o que impede sem ela?
3. Seu deploy quebrou a produção. Como o pipeline reverte sozinho? Escreva o fluxo.
4. Por que fazer **scan de segurança** da imagem **antes** do deploy, e não
   depois?

**Entregável.** `notas/M6-cicd.md` + pipeline rodando no seu repo.

---

### M7 — Observabilidade
**Semanas 31–34 · 40 h · Objetivo: saber o que está acontecendo antes do cliente reclamar.**

**Conceito.** Três pilares: **métricas** (o que está acontecendo, numérico),
**logs** (o que aconteceu, texto) e **traces** (o caminho de uma requisição).
E o nível mais maduro: **SLO** — metas de confiabilidade acordadas com o negócio.

**Material didático**
- *Prometheus: Up & Running* (grátis) — 4 h
- *The Site Reliability Book* (SRE Book, grátis, Google) — 6 h
- Tutoriais oficiais do Grafana — 3 h
- OpenTelemetry docs — 2 h
- Fireship: "Prometheus in 100 seconds", "Grafana in 100 seconds" — 0,5 h

**Mão na massa**
- **N1 (sem 31–32):** Prometheus coletando o cluster + a `kube-news` (que já
  expõe `/metrics`). Dashboard com CPU, memória, latência, erro, **e** o
  endpoint `/health` da app.
- **N2 (sem 33):** **defina um SLO** para a `kube-news` (ex.: 99,5% de requisições
  < 500 ms). Construa o **burn rate alert** que antecipa a violação. **Prove que
  o alerta dispara ANTES do SLO ser violado** — esse é o ponto.
- **N3 (sem 34):** **alerta Ruído**. Escreva 10 alertas propositalmente ruins.
  Depois reduza a 2 que realmente importam. Documente o critério de descarte.

**Prova.**
1. Métrica vs log vs trace: qual responde "por que essa requisição demorou 4 s"?
2. O que é um SLO e por que ele é melhor que "99,9% de uptime" como meta?
3. *Error budget*: o que ele é, e que decisão ele habilita?
4. Seu alerta disparou 30 vezes com a mesma causa. O que está errado — o alerta
   ou a causa? Como se resolve isso na raiz?

**Entregável.** `notas/M7-observabilidade.md` + dashboard + SLO definido.

---

### M8 — Segurança e redes
**Semanas 35–37 · 30 h · Objetivo: a menor permissão possível, e a rede sob controle.**

**Conceito.** Segurança em DevOps é **gratuita quando o padrão é seguro**
(security by default) e cara quando é adicionada depois. Princípios: menor privilégio,
defesa em profundidade, o que a IA **não** pode fazer.

**Material didático**
- CIS Benchmark (Kubernetes) — 3 h
- Kubernetes Security (docs oficiais) — 3 h
- Trivy / Grype — docs — 2 h
- OWASP Top 10 — 2 h
- Kyverno / NetworkPolicy — docs — 2 h

**Mão na massa**
- **N1 (sem 35):** RBAC real: crie ServiceAccounts por workload, com **uma
  permissão por papel**. Prove que o agent de análise **não** consegue escrever no
  cluster — e que a tentativa é **negada e registrada**.
- **N2 (sem 36):** NetworkPolicy: a app só fala com o banco; o banco só fala com
  a app. Mais Pod Security Standards, seccomp, `readOnlyRootFilesystem`.
- **N3 (sem 37):** **red team do seu próprio pipeline.** Tente: commitar um
  segredo (o scanner pega?), injetar dependência maliciosa, usar a CI para
  vazar variável de ambiente. Documente o que passou e o que foi barrado.

**Prova.**
1. Princípio do menor privilégio: o que impede um controlador de Kubernetes de
   deletar seu namespace? (RBAC + você não deve dar `cluster-admin` a workloads)
2. Um segredo está no `.env` e foi commitado. Qual o procedimento **correto** de
   remediação, e por que reescrever o histórico **não basta**?
3. Sua app está exposta com NodePort em todas as interfaces. Quais as 3 opções
   para expor publicamente com controle, e o trade-off de cada?
4. Por que o agente de IA **não** deve ter permissão de escrita por padrão?

**Entregável.** `notas/M8-seguranca.md` + relatório do red team.

---

### M9 — Cloud real
**Semanas 38–41 · 40 h · Objetivo: o mesmo workload, em outro lugar.**

**Conceito.** *"Kubernetes é agnóstico: o que se constrói aqui vale lá."* Esta fase
**prova** a frase. E introduz o que muda: elasticidade, custo, identidade, gerência
de estado, e a realidade de que **cloud não é computador de graça**.

**Material didático**
- AWS Certified Cloud Practitioner (course gratuito da AWS) — 6 h
- Terraform: AWS provider — 4 h
- *AWS Well-Architected* (os 6 pilares, resumo) — 3 h
- Free tier e modelo de custos: entenda antes de criar qualquer coisa

**Mão na massa**
- **N1 (sem 38):** crie uma conta (free tier) e **estude o custo antes de
  provisionar**. Faça uma estimativa escrita do que vai custar.
- **N2 (sem 39–40):** **suba o mesmo workload da M4 na nuvem**: cluster gerenciado
  (EKS/GKE/AKS) ou VMs, o mesmo manifesto, sem alteração. Meça o custo real de
  24 h e compare com a estimativa.
- **N3 (sem 41):** **economize.** Reduza o custo do ambiente em 50% sem quebrar
  nada. Documente o antes/depois e o que você mudou.

**Prova.**
1. Quais as 4 diferenças **reais** entre o cluster no `pve-lab` e o gerenciado?
2. Descreva seu ambiente de custo: o que mais consome? Como se reduz?
3. "Elasticidade" e "escala" são a mesma coisa? Qual a diferença no plano de custo?
4. O que é *managed* e o que continua sendo seu?

**Entregável.** `notas/M9-cloud.md` + relatório de custo antes/depois.

---

### M10 — AIOps: o agente na operação
**Semanas 42–46 · 50 h · Objetivo: seu diferencial de mercado.**

> **Este é o núcleo do material da imersão.** As Fases 0–4 dos slides (conceitos,
> prompt, contexto, harness, loop) são **pré-requisito** — e é por isso que este
> módulo vem **depois** das fundações, e não antes.

**Conceito — os quatro**

```
Loop  ·  Harness  ·  Contexto  ·  Prompt
```

E os três ciclos: **outer** (objetivo de quem pediu), **inner** (critério de
aceite da etapa), **ReAct** (pensar → agir → observar).

**Material didático**

| Recurso | Formato | Tempo |
|---|---|---|
| Slides aula 01 (páginas 1–20) | PDF | 4 h |
| Slides aula 01 (páginas 21–29) — Docker/K8s | PDF | 3 h |
| Slides aula 02 (páginas 1–13) — spec-driven dev | PDF | 3 h |
| Slides aula 02 (páginas 14–18) — agente | PDF | 3 h |
| `prompt-e-contexto-na-pratica/` (4 exercícios) | código | 6 h |
| LangChain — docs de agents + tools | site | 4 h |
| MCP — spec + docs | site | 3 h |
| Anthropic "Building effective agents" | artigo | 2 h |

**Mão na massa**

- **N1 (sem 42–43):** os **4 exercícios de prompt/contexto**. Meça tokens de
  entrada e saída de cada. Compare zero-shot × few-shot × chain-of-thought.
- **N2 (sem 44):** **reconstrua o agente do zero**, a partir dos PRDs e do
  OpenSpec — não copiando o código pronto. O coletor, o agente de análise, a
  persistência, o agente de correção, o portão humano.
  **Requisito do projeto: nenhuma API paga.** Use o backend gratuito (ver
  `AGENTS.md`) e **explique a arquitetura do adaptador** no seu README.
- **N3 (sem 45–46):** **o incidente completo ponta a ponta**: provoque a falha,
  o agente detecta → investiga → **propose** → você **aprova** → ele corrige →
  verifica. Escreva o post-mortem.

**Prova.**
1. Explique a diferença entre **prompt**, **contexto**, **harness** e **loop**,
   e o que cada um controla.
2. Chain-of-thought: quando **custa** caro e quando **não** ajuda? (Resposta: em
   diagnóstico ajuda — afunila; em conversão de formato só gasta token)
3. Onde mora a **permissão** do agente: no cliente ou no servidor? Qual a
   consequência de cada escolha? (ver `AGENTS.md` — há uma tabela)
4. Por que "executar" ≠ "concluir"? O que faz a diferença?
5. O que impede o agente de deletar um nó do cluster? (as 4 camadas: host,
   server, credencial, cluster — e o que a cada uma barra)

**Entregável.** `notas/M10-agente.md` + **o seu agente**, funcionando, com README
explicando a arquitetura. Este é o **item que vai para o portfólio**.

---

### M11 — Profissionalização
**Semanas 47–50 · 40 h · Objetivo: transformar competência em carreira.**

**Conceito.** Um DevOps sênior não é o que sabe mais ferramentas — é o que:
**entrega resultado de negócio**, **deixa o time mais rápido**, **não é o
gargalo**, e **deixa registro de por quê**.

**Material didático**
- *The Site Reliability Workbook* (SRE, grátis) — 4 h
- *The Phoenix Project* (romance DevOps) — 3 h
- *"The Mythical Man-Month"* (classics) — 2 h
- Leitura de **post-mortems públicos** (Google SRE, Uber, Netflix) — 3 h
- Vagas de emprego de DevOps/SRE no seu mercado: leia **10** e extraia o que
  pedem. **Este é o seu mapa de compétences.**

**Mão na massa**
- **N1 (sem 47):** **escreva 3 post-mortens** (dos seus labs), no formato do
  repo: impacto, causa, linha do tempo, ação corretiva com dono e prazo.
- **N2 (sem 48):** **portfólio.** Organize seus repositórios com README
  profissional. O repositório do agente AIOps é a peça principal.
- **N3 (sem 49–50):** **simulação de entrevista.** Responda a 15 perguntas
  técnicas de DevOps em voz alta, gravando. Peça feedback.

**Prova.** (esta é sobre você)
1. Das 10 vagas que você leu: quais **3 skills** aparecem em todas? Você tem?
2. Descreva uma decisão de infraestrutura que você tomou e **por quê** — sem
   consultar nada.
3. Qual foi o incidente que mais te ensinou, e o que você **mudou** como
   resultado?

**Entregável.** `notas/M11-profissional.md` + portfólio publicado + lista de
skills do "mapa de competências" com seu status (dominado / praticado / lido).

---

## 4. Material didático — visão consolidada

### Fontes por tipo

| Tipo | Fontes |
|---|---|
| **Livros grátis** | *The Linux Command Line* · *Pro Git* · *Kubernetes: Up and Running* · *Prometheus: Up & Running* · *The Site Reliability Book/Workbook* · *Terraform: Up & Running* |
| **Docs oficiais** | Linux (`man`), Docker, Kubernetes, Terraform, GitHub Actions, Prometheus, MCP, LangChain, OpenTelemetry |
| **Cursos gratuitos** | CS50 Linux (Harvard) · AWS Cloud Practitioner · Linux Journey · KodeKloud · killercoda · labs.play-with-docker |
| **Vídeos (curtos)** | Fireship (Docker, K8s, CI/CD, Prometheus, Terraform) · Hussein Nasser (rede, Postgres) · Techno Tim (K8s, IaC) |
| **Laboratórios** | O próprio repo da imersão · `labs.play-with-docker.com` · killercoda |
| **Leitura profissional** | Post-mortems públicos (Google SRE) · RFCs do Kubernetes · ADRs do próprio repo |
| **Comunidade** | Issues e PRs do repositório da imersão · r/kubernetes · r/devops |

### A regra do material

> **Nenhum material entra na lista sem um entregável associado.**
> Se você vai ler, tem que produzir algo. Material sem entrega vira
> consumption de conteúdo — e não vira skill.

### Kit de sobrevivência (para imprimir e ter ao lado)

Manter **um** arquivo `notas/KIT.md` com: os 30 comandos que você mais usa, como
diagnosticar "não funciona", os 5 erros mais comuns, e onde fica cada coisa.
Atualizar todo mês.

O **`GLOSSARIO-DEVOPS.md`** é a outra metade deste kit: o KIT.md guarda
*comandos*, o glossário guarda *palavras*. Imprima (ou deixe aberto numa aba)
as três tabelas de bolso: **Pares que confundem**, **Siglas** e
**Frases de reunião**.

---

## 5. Como medir o progresso

### Indicadores por módulo

| Módulo | Indicador objetivo |
|---|---|
| M1 | script de diagnóstico rodando em 3 hosts por SSH |
| M2 | PR aberto, revisado e mergeado no repo próprio |
| M3 | imagem publicada, D1–D13 todos ✅ ou N/A justificado |
| M4 | cluster de 3 nós no pve-lab, K1–K12 ✅, 3 post-mortens |
| M5 | `terraform destroy` + `apply` reconstrui o lab idêntico |
| M6 | pipeline: build → scan → deploy → smoke → rollback automático |
| M7 | SLO definido + burn-rate alert que antecipa a violação |
| M8 | relatório de red team + RBAC negando escrita ao agente |
| M9 | custo medido, −50% sem quebrar |
| M10 | **agente detectando → propondo → corrigindo**, com portão humano |
| M11 | portfólio + 3 post-mortens + mapa de competências |

### Revisão a cada 90 dias

A cada trimestre, responda e registre:
1. Qual competência nova **eu consigo fazer sem consultar nada**?
2. Qual é o meu **maior buraco** agora? (você descobre pelo próximo módulo)
3. O que eu faria **diferente** no lab anterior?
4. Meu repositório **contaria** essa história de forma clara?

### O sinal de alerta

> Se você está há 2 semanas sem conseguir fechar a Prova de um módulo, **pare de
> avançar e diagnose**. A causa quase sempre é: base conceitual faltando
> (volte ao N1) ou dificuldade real de ambiente (peça ajuda).
>
> **Nunca é "falta de disciplina".** Quase sempre é buraco de conceito.

---

## 6. Riscos do plano e como contornar

| Risco | Sinal | Contorno |
|---|---|---|
| **Tutorial hell** | assiste 3 vídeos, não constrói nada | Regra: 1 material → 1 entrega. Vídeo sem prática = não conta. |
| **Fundamento pulado** | travar no M4 e não entender "reconciliação" | Volte ao N1. Pular base custa 3× depois. |
| **Fase sem data** | "faço quando tiver tempo" | Fases com data. Se não fez a semana, reagende — mas não empurre 2x. |
| **Perfeccionismo** | quer refazer o lab inteiro antes de entregar | Entregue a versão feia e funcionando. Refine depois. |
| **Ferramenta demais** | quer aprender Terraform, Ansible, Pulumi e CDK | **Uma por vez.** Terraform basta por anos. |
| **Só Copilot/prompt** | copia código que não entende | Regra: **não comite código que você não consegue explicar.** |
| **Tudo local** | nada fora do `pve-lab` | O módulo de cloud é obrigatório, mesmo que seja o free tier. |
| **Esquecimento do portão humano** | quer dar permissão de escrita ao agente para "testar" | É o exercício **mais importante** do M10. Não negocie. |

---

## 7. Adaptação por ritmo

**Se você tem 3 h/semana** (trabalho em tempo integral): dobre o M1, o M4 e o M7.
Total estimado: 16–18 meses.

**Se você tem 15 h/semana** (folga): comprima M1 e M4 (você já mexer com
infraestrutura?), e use o tempo extra no **N3** de cada módulo — que é onde está
a profundidade real. Total estimado: 8 meses.

**Se você é dev de software com experiência eminfra:** pule o N1 de M1, M2 e M3;
comece no N2 de M4. Total estimado: 6 meses. **Ainda faça as Provas** — elas
mudam de forma, não de conteúdo.

**Se você trava num módulo:** não pule. Diagnostique (regra do §5) e peça ajuda
específica: *"não entendo X"* em vez de *"não consigo fazer o M4"*.

---

## 8. O mapa de uma semana concreta (exemplo, M4)

| | Segunda | Quarta | Sexta | Sábado | Domingo |
|---|---|---|---|---|---|
| **Tema** | Estado desejado × real. O que é um control plane. | ReplicaSet × Pod. Como um Deployment vira Pod. | Services e tipos. DNS interno. | Probes: liveness vs readiness. Na prática. | **LAB**: aplicar a app no cluster e provar K1–K12 |
| **1 h** | Leitura: docs "Controllers" + slides p.26 | Leitura: docs "Workloads" | Leitura: docs "Services" | Vídeo + exercício guiado | Projeto: 3 h de lab, sem pressa |
| **Onde** | `notas/M4-k8s.md` | idem | idem | idem | idem |

No sábado, você **não** avança para Service NodePort. No domingo, você
**descobre** que o Service não funciona — e resolve. Essa é a diferença entre
assistir e aprender.

---

## 9. O que o mercado pede (leitura de vagas)

Antes da M11, faça o exercício que define todo o plano:

1. Pegue **10 vagas** de DevOps/SRE/junior SRE do seu mercado
2. Extraia as skills mais frequentes
3. Marque com você o que você já tem
4. **As lacunas reais ajustam o plano.** Se 8 de 10 pedem Terraform, M5 sobe de
   prioridade. Se pedem AWS, M9 sobe.

> O plano que **você** ajusta com base no **mercado real** é infinitamente mais
> eficaz do que um plano genérico. E é exatamente isso que o professor do
> material faz: o slide 3 fala em "Forward Deployed Engineer" e "o que a reunião
> que acontece sem você pergunta" — **o mercado é o critério**.

---

## 10. Checklist de salida — "pronto para o mercado"

- [ ] Consigo explicar qualquer erro de um sistema que **não é meu** (M1)
- [ ] Meu código está em Git, com histórico legível e PR revisado (M2)
- [ ] Consigo empacotar qualquer app e **provar** que funciona (M3)
- [ ] Consigo subir e **depurar** qualquer workload em Kubernetes (M4)
- [ ] Consso recriar a infra inteira do zero, em código (M5)
- [ ] Consigo entregar mudança em produção **sem tocar no servidor** (M6)
- [ ] Consigo saber o estado da minha operação **antes** do cliente (M7)
- [ ] Consigo dizer o que meu sistema pode fazer e o que não pode (M8)
- [ ] Consigo rodar o mesmo workload na nuvem e explicar a diferença (M9)
- [ ] Consigo colocar um agente de IA na operação **sem abrir a porta da farmácia** (M10)
- [ ] Tenho portfólio, post-mortens e sei falar do meu trabalho (M11)

---

## Apêndice — Onde as coisas estão

```
imersao-aiops-prod-01/                    # o repositório da imersão
├── boilerplate-k8s-aiops/                # o agente AIOps (FastAPI + LangChain + MCP)
│   ├── src/my_agent_app/
│   │   ├── collector/                    # coleta de eventos Warning do K8s
│   │   ├── agents/                       # análise (só leitura) e correção (com escrita)
│   │   ├── models/                       # relatório, status, transições
│   │   ├── web/ + templates/             # interface + botão "Executar correção"
│   │   └── api/                          # health check
│   ├── docs/prds/                        # 001 coleta · 002 análise · 003 interface · 004 correção
│   ├── openspec/                         # ciclo de change (propor → aplicar → sincronizar)
│   ├── manifests-k8s/                    # cenários de falha
│   ├── tests/                            # unit · kind · db · e2e
│   └── .claude/commands/opsx/            # comandos do OpenSpec
├── kube-news/                            # app Node.js alvo (Express + Sequelize + Postgres)
│   ├── src/                              # código + Dockerfile + Dockerfile.dev
│   ├── k8s/                              # manifesto + kind-config
│   ├── docs/adrs/                        # 9 decisões de arquitetura
│   ├── docs/postmortens/                 # 2 post-mortens (modelo para o seu)
│   └── .claude/skills/                   # skills de Docker e Kubernetes
├── prompt-e-contexto-na-pratica/         # 4 exercícios de engenharia de prompt
├── slides/                               # 4 PDFs = as 4 aulas
└── aiops-lab.sh                          # up / down / status / reset / logs
```

**Seus arquivos (nesta raiz):**

| Arquivo | Para que serve |
|---|---|
| `PLANO-DE-ENSINO.md` | **este documento** — o currículo |
| `AGENTS.md` | regras permanentes: sem API paga, `pve-lab`, GitHub, vocabulário |
| `AMBIENTE.md` | o ambiente montado e o **por que** de cada decisão |
| `GLOSSARIO-DEVOPS.md` | o **dialeto** da profissão — 16 blocos, siglas, pares que confundem, frases de reunião |
| `aiops-lab.sh` | operação do laboratório |
| `notas/` | **seu** registro de cada módulo (crie a pasta) |

**Onde o seu trabalho acontece:**

| Onde | O quê |
|---|---|
| **Windows** (`192.168.15.38`) | estação: editor, Git, GitHub, OpenCode — **não** é equipamento de testes |
| **`pve-lab`** (`ssh pve-lab`) | **execução**: toolchain, repo `~/projetos/imersao-aiops-prod-01`, cluster, serviços |
| seu GitHub | **o portfólio** — cada módulo vira um repositório público |

> **Não usar WSL2. Não usar Proxmox.** O Windows edita, o `pve-lab` executa.
> É o desenho real de um ambiente DevOps — não uma VM local com `localhost`.

**Acesso:**

```powershell
ssh pve-lab        # alias, sem senha — no ~/.ssh/config do Windows
```

Os serviços ficam no IP do servidor, nunca em `localhost`:

| Serviço | URL (do Windows) |
|---|---|
| Interface do agente | <http://192.168.15.10:8000/reports> |
| MCP Server | <http://192.168.15.10:3001/mcp> |
| pgAdmin | <http://192.168.15.10:5050> |
