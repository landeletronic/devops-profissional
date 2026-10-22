# GLOSSÁRIO DEVOPS — o idioma da profissão

> **Para quem é:** para quem está construindo o vocabulário antes do hands-on.
> Termo em **negrito** = como aparece na vida real. Em *itálico* = a situação
> em que você vai ouvir ou ler aquele termo.
>
> Nenhum termo aqui é dispensável — todos são usados por profissionais no
> dia a dia, em reunião, em ticket, em PR e em entrevista.

---

## 0. Pronúncia — a parte que ninguém ensina

A maior parte do vocabulário DevOps é **inglês**. Errar a pronúncia em reunião
assusta mais do que não saber o termo. Aqui estão os que mais causam vergonha:

| Termo | Pronúncia | Cuidado |
|---|---|---|
| **Kubernetes** | ku-ber-**NÉ**-tis | sílaba tônica na última. K8s é a abreviação (8 letras entre K e s) |
| **kubectl** | ku-**CTRL** | "kube control" contraído. É o comando mais usado do K8s |
| **etcd** | **ét**-si-di | o banco de dados do control plane |
| **YAML** | **IÉ**-mol | nunca "iámil" |
| **CI/CD** | sê-ê-**Í** / sê-**DÊ** | não é "xi-ê" |
| **Docker** | **DÓ**-ker | com som de d, não de t |
| **Ansible** | en-**SI**-bol | |
| **Terraform** | **TÉ**-ra-form | |
| **Prometheus** | pro-me-**TÉ**-us | |
| **Grafana** | graf-**A**-na | |
| **nginx** | en-**JÍNKS** | não "n-gin-ícks" |
| **systemd** | **SIS**-tem-dê | |
| **hash** | **RÁXI** | não "hác". *Mesmo som de cache* |
| **cache** | **CÁXI** | |
| **commit** | co-**MÍT** | não "có-mit" |
| **pull / push** | PÔ-li / PÚ-xi | no dia a dia se usa o termo em inglês mesmo |
| **repo** | re-**PÔ** | curto de *repository* |
| **sudo** | **SÚ**-dô | sequência: so-dô |
| **latency** | la-**TÊN**-ci | atraso |
| **throughput** | **TRÚ**-put | vazão |
| **regex** | **RÊ**-geks | expressão regular |
| **queue** | **KÍU** | fila |
| **branch** | BRÁNIX | nunca "brânchi" |

> **Regra prática:** em reunião, ninguém julga você por errar pronúncia de uma
> ferramenta. Julgam por não saber o que a ferramenta **resolve**. Se travar,
> diga o termo e siga — depois confira aqui.

---

## Como este glossário está organizado

Os termos vêm em **blocos**, na mesma ordem em que você vai encontrá-los no
módulo do [`PLANO-DE-ENSINO.md`](PLANO-DE-ENSINO.md):

| Bloco | Módulo | O que ele cobre |
|---|---|---|
| 1 | M1 | máquina, Linux, rede |
| 2 | M2 | Git e colaboração |
| 3 | M3 | build, imagens, containers |
| 4 | M4 | Kubernetes |
| 5 | M5 | infraestrutura como código |
| 6 | M6 | CI/CD e entrega |
| 7 | M7 | observabilidade |
| 8 | M8 | segurança |
| 9 | M9–M11 | confiabilidade, processo, carreira |
| 10 | M10 | IA e agente |
| — | — | **Pares que confundem** · **Siglas** · **Frases de reunião** |

A seção **Pares que confundem** é a mais valiosa do documento — é onde quase
todo iniciante erra, inclusive em entrevista.

---

## Bloco 1 — Máquina, Linux e rede (M1)

**servidor** — um computador que fica ligado 24h e que outros acessam pela rede.
*Não é uma máquina "mais potente" — é uma máquina com outro propósito.*

**host** — qualquer máquina identificada por um nome ou IP. Pode ser servidor,
notebook ou VM. *Termo genérico usado quando não importa o papel da máquina.*

**VM (máquina virtual)** — um computador simulado dentro de outro computador,
com seu próprio sistema operacional. *O `pve-lab` é uma VM.*

**hipervisor** — o software que cria e gerencia VMs (VirtualBox, KVM, Proxmox).
*É a camada que está "abaixo" das VMs.*

**container** — processo isolado com seu próprio espaço de sistema de arquivos.
*Não é uma máquina: é um processo que acha que é uma máquina.*

**processo** — um programa em execução. `ps aux` lista todos. *Tudo que roda é
processo — inclusive o `dockerd` que cuida dos containers.*

**daemon** — processo que roda em segundo plano, sem interface. *`sshd`, `dockerd`,
`systemd` são daemons. A letra final é o "d": Docker**d**, SSH**d**.*

**serviço (service)** — um programa configurado para iniciar sozinho no boot e
reiniciar se cair. Gerenciado pelo `systemctl`. *`systemctl status docker` mostra
o estado de um serviço.*

**porta** — um "número de apartamento" dentro de um IP. HTTP usa 80, HTTPS 443,
SSH 22. *Toda porta aberta é uma porta de entrada que alguém pode tentar.*

**protocolo** — o "idioma" combinado entre dois lados. HTTP, SSH, TCP, DNS.
*Porta é o endereço; protocolo é o idioma falado dentro dela.*

**IP** — endereço numérico de uma máquina na rede (ex.: `192.168.15.10`).
*Dois tipos: privado (dentro da sua rede) e público (na internet).*

**DNS** — a agenda de telefones da internet: traduz nome em IP
(`github.com` → `140.82.x.x`). *Erro clássico: "DNS não resolve" = o nome não
acha o IP — a máquina pode estar no ar.*

**HTTP/HTTPS** — o protocolo da web. *HTTPS é HTTP com TLS (criptografia) na frente.*

**TLS/SSL** — a criptografia que faz o cadeado do navegador. *Antigamente SSL;
hoje se diz TLS. SSL é palavra antiga.*

**SSH** — acesso remoto a terminal de outra máquina pela rede. *É como você
entra no `pve-lab`: `ssh pve-lab`.*

**shell / terminal / prompt** — shell é o interpretador de comandos (bash, zsh);
terminal é a janela; prompt é a linha onde você digita. *Dizer "abrir o terminal"
para indicar "digitar comandos" é corriqueiro.*

**comando, flag, argumento** — `grep -rn "texto" arquivo` → comando=`grep`,
flag=`-rn`, argumento=`"texto" arquivo`. *Flag é o que começa com `-` e muda
o comportamento.*

**stdout / stderr** — saída normal e saída de erro. *`2>` redireciona stderr:
`comando 2>erros.log`. Isso aparece em todo script.*

**PATH** — lista de pastas onde o sistema procura comandos. *Se aparece
"command not found", em 90% dos casos o binário existe mas não está no PATH.*

**variável de ambiente** — valor em memória visível aos processos.
`echo $PATH`. *Segredos nunca vão em variável de ambiente versionada.*

**usuário / grupo / root** — root é o superusuário (uid 0). Grupo define
permissões coletivas. *`tlandskron` está nos grupos `sudo` e `docker`.*

**sudo** — rodar um comando com permissão de root. *Não é "login como root" —
é um comando pontual com privilégio elevado.*

**permissão / chmod** — quem lê, quem escreve, quem executa. `644`, `755`.
*Cada dígito é um trio de bits: dono, grupo, outros.*

**log** — registro cronológico do que aconteceu. *Logs contam a história;
métricas mostram o estado atual.*

**arquivo de configuração** — texto que define comportamento
(`/etc/docker/daemon.json`). *Configuração é texto versionável, não segredo.*

**recursos (resources)** — no Kubernetes significa CPU e memória. *Fora do K8s
significa qualquer coisa útil — a palavra muda de sentido com o contexto.*

**ambiente (environment)** — um conjunto isolado de máquinas/serviços com um
propósito: desenvolvimento, homologação, produção. *"Ambiente" nunca é
sinônimo de "infraestrutura".*

**dependência** — o que seu código precisa para rodar. *Dependência é a causa
nº 1 de "funciona na minha máquina".*

**versão / LTS** — LTS = *Long Term Support*, versão com suporte estendido.
*Em produção, sempre LTS.*

**script / automação** — sequência de comandos em arquivo. *Automatizar não é
opção: é o que separa operação de clique repetido.*

---

## Bloco 2 — Git e colaboração (M2)

**repositório (repo)** — pasta com histórico completo versionado. *Um repo =
uma unidade de trabalho que pode ser publicada.*

**commit** — um instantâneo do código com mensagem e autor. *Atomo do histórico.
Se não está em commit, não existe para o time.*

**mensagem de commit** — descreve **o que** mudou e **por quê**.
`fix: corrige timeout no healthcheck do banco`. *Mensagem ruim é dívida técnica.*

**branch (ramo)** — linha de desenvolvimento paralela.
*`main` é a linha principal; feature branches saem dela.*

**merge** — junta duas branches. *Pode gerar conflito.*

**conflito** — duas pessoas mudaram a mesma linha. *Não é erro: é Git dizendo
"decida você qual versão vale".*

**stage / staging** — área de preparação entre editar e commitar.
`git add` coloca no stage. *Permite montar commits lógicos.*

**diff** — mostra exatamente o que mudou. *É o que se lê em revisão de código.*

**push / pull** — push envia para o remoto; pull traz. *Pull antes de push,
sempre.*

**clone** — copia um repositório inteiro com histórico.

**fork** — cópia de um repo **de outra pessoa** para sua conta.
*Fork é de terceiros; clone é do mesmo servidor.*

**pull request (PR)** — proposta formal de mudar o código, com revisão.
*É onde a conversa técnica acontece. Abrir PR é obrigatório em time.*

**revisão (code review)** — alguém lê e comenta seu PR antes do merge.

**branch protection** — regra que **impede** merge sem aprovação e sem testes
passando. *Sem ela, qualquer pessoa quebra a produção.*

**tag / release** — marcação no histórico, normalmente de versão (`v1.2.0`).
*Release é o que você entrega; tag é o marcador no Git.*

**rollback (por Git)** — voltar o código para um commit anterior.
*Metade do trabalho de operação é rollback bem-feito.*

**histórico** — a memória do projeto. *É por isso que Git existe: ninguém
precisa lembrar por que aquela linha está ali.*

**.gitignore** — lista do que **não** versionar. *Segredo versionado é incidente
de segurança.*

---

## Bloco 3 — Build, imagens e containers (M3)

**build** — o ato de transformar código + dependências em algo executável.
*Em Docker, build = gerar imagem.*

**artefato (artifact)** — resultado de um build, pronto para distribuir.
*Imagem, binário, jar, pacote npm são artefatos.*

**imagem (image)** — pacote imutável com código, dependências e configuração.
*É o "molde". Você não edita imagem — você recria.*

**container (em sentido oposto à imagem)** — uma **instância em execução** da
imagem. *Imagem = receita. Container = o prato feito.*

**Dockerfile** — receita de build da imagem: instruções linha a linha.
*Ordem das linhas importa — é o que define o cache do build.*

**camada (layer)** — cada instrução do Dockerfile vira uma camada. *Camadas
não mudam depois de criadas; por isso a ordem otimiza rebuild.*

**registry** — servidor que guarda imagens (Docker Hub, GHCR, ECR).
*Imagem sem registry é imagem presa na sua máquina.*

**tag** — nome/versão de uma imagem (`kube-news:1.4`, `:latest`).
*`:latest` em produção é proibido — ninguém sabe o que tem dentro.*

**digest** — identificador criptográfico único da imagem (sha255...).
*Tag muda; digest não. É a prova de imutabilidade.*

**multi-stage build** — Dockerfile com vários estágios: compila num, roda no
outro. *Resultado: imagem final sem compilador, minúscula.*

**usuário não-root** — container rodando com uid ≠ 0.
*Rodar como root dentro do container é falha de segurança, não conveniência.*

**volume** — armazenamento que **sobrevive** ao container. *Sem volume, tudo que
o container escreve some quando ele morre.*

**rede de container** — rede virtual isolada onde os containers conversam.
*O port mapping expõe uma porta de dentro para fora.*

**healthcheck** — comando que o Docker executa para saber se o processo está
saudável. *Sem ele, container "rodando" pode estar morto por dentro.*

**PID 1** — o processo raiz de um container. *Se não trata os sinais, o
`docker stop` demora 10s e depois mata na marra.*

**sinal (signal) / SIGTERM / SIGKILL** — SIGTERM = "pode desligar com calma";
SIGKILL = "morra agora". *Aplicação que ignora SIGTERM força timeout em todo deploy.*

**processo zumbi** — filho morto que o pai não recolheu. *Sintoma de PID 1
incapaz de reap filhos.*

**engine / daemon / runtime** — engine é o software (Docker); daemon é o
processo em background (`dockerd`); runtime é quem efetivamente roda os
containers (containerd, runc).

**rollback de imagem** — voltar para a versão anterior da imagem.
*Mais rápido que corrigir: trocar tag e redesplegar.*

---

## Bloco 4 — Kubernetes (M4)

**cluster** — conjunto de máquinas gerenciadas como uma só. *No K8s: control
plane + workers.*

**control plane** — o "cérebro": API server, etcd, scheduler, controller-manager.
*Nunca roda sua aplicação — só decide.*

**node / nó** — máquina (ou container, no kind) onde os pods rodam.
*Contém kubelet, kube-proxy e o runtime.*

**kubelet** — agente em cada nó que executa o que o control plane pede.
*É ele que mantém o nó "Ready".*

**API server** — porta única de entrada do cluster. *Tudo passa por ele —
nunca se mexe no etcd diretamente.*

**etcd** — banco chave-valor que guarda o estado do cluster. *Se o etcd morre,
o cluster não sabe o que ele próprio é.*

**scheduler** — decide **em qual nó** cada pod novo roda.
*Ele só planeja; quem executa é o kubelet.*

**controller-manager** — dono da reconciliação: compara desejo × real e age.
*Um controller é um loop infinito, não um script.*

**estado desejado** — o que você declarou no YAML. **estado real** — o que está
acontecendo. *O K8s existe para eliminar a diferença entre os dois.*

**reconciliação** — o ciclo que fecha essa diferença.
*Se você apagar um pod, o controller "repara" — não por mágica, por loop.*

**manifest / YAML** — arquivo declarando recursos do cluster.
*Texto versionado = infraestrutura como código, inclusive no K8s.*

**declarativo × imperativo** — declarativo: "quero 3 réplicas". Imperativo:
"crie um pod". *K8s é declarativo; `kubectl run` é atalho imperativo.*

**pod** — a menor unidade do K8s: um ou mais containers juntos, com a mesma rede.
*Na prática, quase sempre 1 container por pod. Pod é efêmero — morre e nasce.*

**namespace** — partição lógica dentro do cluster (`teste-a`, `kube-system`).
*Não é isolamento de segurança por si só — é separação de nome e cota.*

**deployment** — declaração de pods + como mantê-los. *Dono do ciclo de vida:
cria ReplicaSets, faz rollout, faz rollback.*

**replicaset** — mantém N pods idênticos vivos. *Você raramente o toca — é
criado pelo deployment.*

**statefulset** — deployment para workloads com estado (banco, fila).
*Diferença: nomes estáveis e ordem de subida.*

**daemonset** — garante um pod por nó. *Usado por coletor de logs, CNI, monitoramento.*

**job / cronjob** — tarefa que termina (job) ou roda agendada (cronjob).
*Diferente de deployment, que nunca termina.*

**service** — endereço estável e IP fixo para um grupo de pods voláteis.
*Pod morre, service continua. É por isso que ele existe.*

**ClusterIP / NodePort / LoadBalancer** — os 3 tipos de service: só dentro do
cluster · exposta em porta alta de cada nó · pede um balanceador externo.
*Ingress fica acima de todos, roteando por nome/host.*

**DNS interno** — nome de serviço dentro do cluster (`postgres:5432`).
*É como um micro-DNS para serviços.*

**ConfigMap** — configuração não sensível em chave-valor.
**Secret** — igual, mas base64 (não é criptografia!). *Secret = obscuridade,
não segurança. Criptografia é outra camada.*

**probe / sonda** — períodicamente o kubelet pergunta: está vivo? está pronto?
*Resposta errada = reinício ou remoção do Service.*

**liveness** — "está morto?" → falhou, **reinicia** o container.
**readiness** — "pode receber tráfego?" → falhou, **tira do Service**, não reinicia.
*Confundir os dois é a causa nº 1 de incidente.*

**startup probe** — para apps lentos a subir: dá tempo antes de liveness atuar.

**resources: request × limit** — request = o que o K8s **reserva**; limit =
o teto. *Estourou limit = OOMKill (morte por memória).*

**rollout** — subida gradual de uma nova versão.
**rollback** — desfazer o rollout. *`kubectl rollout undo` — guarde esse comando.*

**escala (scaling)** — horizontal (mais pods) × vertical (mais recursos por pod).
*Horizontal é o padrão em nuvem.*

**evento (event)** — registro de algo que aconteceu (criação, falha, aviso).
*Diferente de log: evento é do cluster, log é do processo.*

**Warning** — evento de erro. *O agente AIOps deste projeto coleta exatamente
esses.*

**NotReady / Pending / OOMKilled** — estados que importam: sem tráfego ·
não agendado · morto por memória.

**RBAC** — quem pode fazer o quê (Role, ClusterRole, binding).
*Princípio do menor privilégio aplicado a API do cluster.*

**ServiceAccount** — identidade de um pod dentro do cluster.
*É a "conta corrente" que usa para falar com a API.*

**NetworkPolicy** — firewall entre pods. *Sem ela, todo pod fala com todo pod.*

**kubectl** — CLI do cluster. `get`, `describe`, `logs`, `apply`, `delete`.
*`describe` conta a história; `logs` conta o que o processo disse.*

**contexto / kubeconfig** — qual cluster você está mandando.
*Contexto errado é como apagar produção achando que é homologação.*

**CRD** — extensão: você define seu próprio tipo de recurso.
**operador** — programa que gerencia CRDs com lógica própria.
**Helm** — gerenciador de pacote do K8s ("apt do Kubernetes").

**cluster kind** — cluster de aprendizado onde os nós são containers.
*Não é produção — é para estudar sem custo. Perfeito para M4.*

---

## Bloco 5 — Infraestrutura como código (M5)

**infraestrutura** — o que existe antes do seu código rodar: VMs, rede, disco,
containers, banco. *Quem não documenta infra tem infra por conta de ninguém.*

**provisionar** — criar um recurso que não existia (VM, rede, bucket).
**configurar** — ajustar algo que já existe (instalar pacote, editar conf).
*A divisão é exatamente Terraform × Ansible.*

**declarativo × imperativo** — declarar o resultado final vs. listar passos.
*IaC moderno é declarativo: você diz "quero", não "faça assim".*

**estado (state)** — o mapa entre o que está declarado e o que existe de fato.
*Sem state, Terraform não sabe o que já criou. É o arquivo mais valioso e mais
perigoso do projeto.*

**drift** — quando o mundo real se desviou do declarado (alguém mexeu na mão).
*Drift é a prova de que alguém operou fora do processo.*

**plan / apply / destroy** — simular · executar · apagar.
*`plan` antes de `apply` é profissionalismo, não burocracia.*

**idempotente** — rodar 10 vezes dá o mesmo resultado de rodar 1 vez.
*É a propriedade que torna automação segura de repetir.*

**provider** — plugin que fala com uma API (AWS, Docker, Proxmox).
**módulo** — bloco reutilizável de configuração Terraform.
**output** — valor exposto de um módulo para outro usar.

**playbook** — lista de tarefas Ansible a executar em uma máquina.
**inventário** — lista de máquinas alvo do playbook.
**task / handler / fact** — tarefa · reação a mudança · dado coletado da máquina.

**convergência** — o sistema chegar ao estado declarado, por onde quer que
parta. *É o objetivo final de IaC.*

---

## Bloco 6 — CI/CD e entrega (M6)

**pipeline** — cadeia automática de etapas que roda a cada mudança.
*Build → test → scan → deploy → smoke. Uma esteira.*

**CI (Continuous Integration)** — integração contínua: todo push é **verificado**
automaticamente. *O objetivo não é rodar testes — é que ninguém commit quebrado.*

**CD (Continuous Delivery / Deployment)** — entrega contínua: o que passou no CI
**vai para produção** sem intervenção manual. *Delivery = pode ir; Deployment =
vai.*

**gate de qualidade** — barreira que bloqueia avanço se um critério falhar.
*Branch protection é um gate.*

**suíte de testes** — conjunto de testes. *Unitário (função) · integração
(componentes juntos) · e2e (ponta a ponta, como usuário).*

**teste de regressão** — garantir que o que funcionava **ainda** funciona.

**cobertura** — % do código exercitado pelos testes. *Cobertura alta não prova
que testa certo — só que passou por cima.*

**artefato assinado** — artefato com prova de origem e integridade.
**versionamento semântico (semver)** — `MAIOR.MENOR.CORREÇÃO`. *Quebrar API = MAIOR.*

**ambiente: dev / hml(stg) / prod** — desenvolvimento · homologação/staging ·
produção. *Ninguém testa direto em produção. Quem testa, descobre na frente
dos clientes.*

**deploy** — colocar a versão nova rodando. *Não é "subir servidor".*

**release** — a versão entregue, com escopo definido.
**hotfix** — correção urgente que pula fila.

**canary / blue-green** — estratégias de entrega gradual.
*Canary = 5% dos usuários primeiro. Blue-green = dois ambientes, troca de um.*

**feature flag** — ligar/desligar funcionalidade **sem deploy**.
*A entrega mais segura é a que pode ser desligada em 1 segundo.*

**rollback** — voltar para a versão anterior. *O rollback bom é o que ninguém
percebe.*

**especificação / spec-driven development** — escrever **o que** deve funcionar
antes de escrever **como**. *É o método da imersão deste projeto (OpenSpec).*

---

## Bloco 7 — Observabilidade (M7)

**monitoramento × observabilidade** — monitoramento responde "está tudo certo?"
com dashboards que você já imaginou. Observabilidade responde **perguntas que
você não previu**. *Monitoramento é olhar; observabilidade é diagnosticar.*

**métrica** — número agregado ao longo do tempo (latência, erros, CPU).
*Para "está pior que ontem?"*

**log** — texto cronológico do que aconteceu. *Para "o que aconteceu às 14h?"*

**trace** — caminho completo de uma requisição entre serviços, com duração
de cada trecho (span). *Para "por que demorou 4 segundos?"*

**span** — um trecho dentro do trace, com início e fim.

**coletor / scraper** — agente que puxa métricas (Prometheus).
**exporter** — expõe métricas de um sistema que não fala métricas.

**dashboard / painel** — visualização. *Dashboard bonito sem SLO é decoração.*

**alerta** — aviso de que algo precisa de atenção. **notificação** — o meio
(channel). *Ruim é o alerta que ninguém olha.*

**ruído de alerta** — alerta que dispara sem ação possível. *Ruím que
desliga o alerta é pior: é assim que se perde uma falha real.*

**latência** — tempo de resposta. **throughput** — requisições por segundo.
**taxa de erro** — % de falhas. **utilização** — quanto do recurso está em uso.

**SLI (Indicator)** — a **medida** (ex.: latência p99).
**SLO (Objective)** — a **meta** interna (ex.: p99 < 500 ms em 30 dias).
**SLA (Agreement)** — o **contrato** com o cliente, com penalidade.
*SLI mede · SLO promete para si · SLA promete para o outro.*

**budget de erro (error budget)** — o quanto você **pode falhar** antes de
estourar o SLO. *É a moeda: se o budget acabou, congela feature e conserta.*

**burn rate / alerta de queima** — quão rápido o budget está sendo queimado.
*É o alerta que avisa **antes** do SLO cair.*

**uptime × disponibilidade** — uptime = tempo ligado; disponibilidade = tempo
**utilizável**. *Ligado e quebrado conta como uptime.*

**post-mortem** — análise escrita de um incidente: impacto, causa, linha do
tempo, ações com dono e prazo. *Sem post-mortem, o incidente se repete.*

**causa raiz (root cause)** — a razão mais profundo que permitiu a falha.
*Se a ação corretiva não remove a causa raiz, não é corretiva.*

**runbook** — instrução passo a passo para operar um cenário.
*É o que você escreve às 3h para não repetir às 4h.*

---

## Bloco 8 — Segurança (M8)

**autenticação (authN)** — **quem** é você (login, chave, token).
**autorização (authZ)** — o que você **pode** fazer.
*Saber quem é não é saber o que pode. São camadas separadas.*

**credencial / token / chave / segredo** — o que prova identidade ou dá acesso.
*Nunca em código, nunca em log, nunca em imagem.*

**princípio do menor privilégio** — conceder só o mínimo necessário.
*Toda permissão larga demais é um incidente esperando o gatilho.*

**segredo (secret) × configuração** — segredo = tem valor se vazar (senha, chave).
Configuração = não tem (porta, endpoint). *Tratar configuração como segredo
esconde problema real.*

**criptografia em trânsito × em repouso** — durante a rede · parado em disco.
*São duas proteções diferentes e ambas são obrigatórias.*

**scan de vulnerabilidade** — procurar falhas conhecidas (CVE) em imagem, código
ou dependência. *Barato antes do deploy; caríssimo depois.*

**CVE** — identificador público de uma vulnerabilidade específica.
**patch** — correção de segurança publicada.

**segurança por padrão (secure by default)** — o padrão já é o seguro.
*Não depender de alguém lembrar de configurar.*

**defesa em profundidade** — várias camadas, porque uma cai.
*Segurança nunca é um muro — é uma cebola.*

**superfície de ataque** — tudo que um atacante pode tentar.
*Expor menos é a defesa mais barata que existe.*

**vazamento (leak)** — segredo que escapou (commit, log, imagem, variável).
*Remediar não é apagar o arquivo: é **rotacionar** a credencial.*

**isolamento / sandbox** — limitar o que um processo alcança.
*É o que o container faz (e o que a rede de pod reforça).*

---

## Bloco 9 — Confiabilidade, processo e carreira (M9–M11)

**confiabilidade** — entregar o que foi prometido, mesmo quando partes quebram.
*Não é "nunca cair" — é "cair sem o cliente notar".*

**resiliência** — capacidade de **voltar** depois de uma falha.
**tolerância a falha** — continuar operando **durante** a falha.

**SRE (Site Reliability Engineering)** — engenharia de confiabilidade aplicada a
software, com métricas e orçamento de erro. *É a prática, não o cargo.*

**toil** — trabalho manual, repetitivo, sem valor agregado e que cresce.
*Se você faz toda semana na mão, é toil — e é o que se automatiza primeiro.*

**plantão (on-call)** — responsável por atender incidente fora do horário.
*Plantão sem runbook e sem escalação é cargo de mártir.*

**escalação** — subir o problema para quem pode resolver mais.
**severidade (SEV1, SEV2...)** — classificação de impacto. *SEV1 = produção caída
para muita gente.*

**incidente** — interrupção do serviço. **problema** — a causa que gera
incidentes repetidos. *Incidente é sintoma; problema é a doença.*

**mitigação × resolução** — conter o dano agora · eliminar a causa.
*Mitigar primeiro: parar o sangramento antes de diagnosticar.*

**MTTD / MTTR** — tempo até detectar / até recuperar. *Medir MTTR é o primeiro
passo para reduzi-lo.*

**blast radius (raio de impacto)** — até onde a falha ou a mudança se espalha.
*Mudança com blast radius grande exige mais cuidado — não menos.*

**SPOF** — *Single Point of Failure*, ponto único de falha.
*Se só existe um, esse um vai falhar.*

**redundância** — ter cópia de tudo que é crítico.

**dimensionamento (sizing)** — decidir quanta máquina um sistema precisa.
*Dimensão errada = pagar por coisa que não usa, ou cair no pico.*

**ADR (Architecture Decision Record)** — registro curto de uma decisão e seu
porquê. *Documento que explica "por que não fizemos da outra forma".*

**documentação viva** — doc que muda junto com o código.
*Doc velho é pior que doc nenhuma: dá confiança falsa.*

**portfólio** — conjunto de trabalho visível que prova o que você faz.
*No DevOps, vale mais um repo com README excelente que cinco certificados.*

---

## Bloco 10 — IA na operação (M10)

**LLM** — modelo de linguagem grande. *É o "cérebro" que gera texto.*

**modelo** — o LLM específico (`minimax-m3.1-flash-free`).
**provider** — quem serve o modelo (`opencode`).

**prompt** — a instrução que você dá ao modelo.
**contexto** — tudo o que o modelo enxerga para responder (arquivos, histórico,
ferramentas). *Prompt é o pedido; contexto é o que ele sabe.*

**token** — unidade de texto que o modelo processa. *Cobrança é por token —
contexto grande é caro, mesmo no free tier que tem limite.*

**alucinação** — quando o modelo afirma algo com confiança e está errado.
*Nunca aceite afirmação do modelo sem evidência.*

**tool / ferramenta (function)** — capacidade que o modelo pode **chamar**
(executar comando, consultar API). *O modelo não faz — ele propõe e o seu
código executa.*

**tool call** — a chamada em si, geralmente JSON.
**function calling** — padrão de o modelo pedir uma função.

**harness** — o que **sobrevive** ao projeto: instruções, skills, permissões,
MCP. *Contexto é descartável; harness é permanente.*

**loop** — ciclo que repete até critério de aceite.
**inner loop** — ciclo por etapa (critério da etapa).
**outer loop** — ciclo com o usuário (o objetivo de quem pediu).
**ReAct** — pensar → agir → observar, repetindo.

**MCP (Model Context Protocol)** — protocolo padrão para modelo conectar a
ferramentas externas. *É o USB dos agentes.*

**agente** — LLM + ferramentas + loop + critério de parada.

**portão humano (human gate)** — o ponto único onde um humano aprova antes da
ação de escrita. *É a diferença entre sugestão e execução.*

**ação sem volta** — apagar, remover, esvaziar nó. *Fica fora da superfície
do agente, sempre.*

**idempotente (para ações)** — repetir a ação não causa dano adicional.
*É o que torna seguro deixar o agente tentar de novo.*

**guardrails (guarda-rails)** — limites que impedem o agente de sair do trilho.

**chain-of-thought** — pedir raciocínio passo a passo.
*Ajuda em diagnóstico; só gasta token em conversão de formato.*

**zero-shot / few-shot** — sem exemplos / com poucos exemplos no prompt.

---

## ⚠️ Pares que confundem — a seção mais importante

> Errar estes pares é o sinal mais visível de iniciante em entrevista e em
> reunião. Leia devagar.

### Infraestrutura e build

| Pare | A diferença |
|---|---|
| **imagem × container** | Imagem = molde imutável. Container = instância em execução. *Você roda N containers da mesma imagem.* |
| **artefato × imagem** | Artefato é o gênero (qualquer saída de build). Imagem é um tipo de artefato. |
| **VM × container** | VM tem sistema operacional próprio. Container compartilha o kernel do host. |
| **host × node** | host é genérico ("aquela máquina"). node é host **dentro de um cluster**. |
| **processo × serviço** | Processo pode estar rodando agora e sumir. Serviço é gerenciado e volta sozinho. |
| **volume × bind mount** | Volume é gerenciado pelo Docker. Bind mount é uma pasta sua apontada para dentro. |
| **config × secret** | Config não tem valor se vazar. Secret tem — e exige rotação. |

### Kubernetes

| Pare | A diferença |
|---|---|
| **pod × container** | Pod é a unidade do K8s; container é o processo. *Quase sempre 1:1.* |
| **deployment × service × pod** | Deployment **mantém** pods. Pod é a instância. Service dá **endereço estável**. |
| **replicaset × deployment** | ReplicaSet mantém N pods. Deployment **gerencia** ReplicaSets e faz rollout. |
| **liveness × readiness** | Liveness falhou → **reinicia**. Readiness falhou → **tira do Service**, não reinicia. |
| **namespace × rede** | Namespace separa **nomes e cotas**, não tráfego. Tráfego é NetworkPolicy. |
| **estado desejado × estado real** | Desejado = YAML. Real = o que roda. Reconciliação fecha a diferença. |
| **declarativo × imperativo** | "Quero 3" × "crie 1 agora". |
| **request × limit** | Request = reserva. Limit = teto (estourou = OOMKill). |
| **ConfigMap × Secret** | Ambos são pares chave-valor. Secret é só **obscuridade** (base64), não criptografia. |
| **evento × log** | Evento é do **cluster** (criação, falha). Log é do **processo**. |
| **kubectl × kubeconfig** | kubectl é o comando. kubeconfig é **aonde** ele aponta. |
| **control plane × worker** | Control plane decide. Worker executa. *Nunca rode app no control plane.* |

### Entrega

| Pare | A diferença |
|---|---|
| **CI × CD** | CI **verifica**. CD **entrega**. São duas coisas, dois objetivos. |
| **build × deploy** | Build gera o pacote. Deploy coloca rodando. |
| **deploy × release** | Deploy é o ato. Release é a versão com escopo. |
| **rollback × revert** | Rollback volta o **sistema** ao ar. Revert desfaz **código** no Git. |
| **branch × fork × clone** | Branch = linha paralela no **mesmo** repo. Fork = cópia do repo **de outro**. Clone = baixar. |
| **push × pull** | Push envia. Pull traz. |
| **ambiente × infraestrutura** | Ambiente é o **palco** (hml, prod). Infraestrutura é o **que está em pé**. |
| **feature × release** | Feature é uma funcionalidade. Release é o conjunto entregue. |
| **patch × hotfix × release** | Patch = correção. Hotfix = correção urgente. Release = entrega. |
| **canary × blue-green** | Canaria = fração de usuários primeiro. Blue-green = dois ambientes, troca seca. |

### Operação e métricas

| Pare | A diferença |
|---|---|
| **métrica × log × trace** | Métrica = número ao longo do tempo. Log = texto. Trace = caminho de uma requisição. |
| **monitoramento × observabilidade** | Monitoramento responde o que você **já pensou** em perguntar. Observabilidade, o que **não** pensou. |
| **SLI × SLO × SLA** | Medida × meta interna × contrato externo com penalidade. |
| **uptime × disponibilidade** | Tempo ligado × tempo **utilizável**. |
| **alerta × notificação** | O aviso × o canal. |
| **erro × falha × incidente × problema** | Erro (no código) → falha (comportamento) → incidente (impacto no serviço) → problema (causa repetida). |
| **mitigação × resolução** | Conter agora × eliminar a causa. |
| **rollback × revert** | Sistema × código. |
| **latência × throughput** | Quanto tempo demora × quantas por segundo. |
| **escala × dimensionamento** | Crescer × calcular o tamanho certo. |

### Processo e segurança

| Pare | A diferença |
|---|---|
| **authN × authZ** | Quem é você × o que pode fazer. |
| **provisionar × configurar** | Criar × ajustar. Terraform × Ansible. |
| **idempotente × determinístico** | Repetir não muda × mesma entrada, mesma saída. |
| **SRE × sysadmin** | SRE mede e automatiza com dados. Sysadmin mantém manualmente. |
| **toil × trabalho** | Toil é manual, repetitivo e sem valor agregado. |
| **incidente × problema** | Sintoma × doença. |
| **severidade × prioridade** | Quão grave é × quanto devemos atacar agora. |

---

## Siglas — tabela de bolso

| Sigla | Significado | Bloco |
|---|---|---|
| **CI** | Continuous Integration — Integração Contínua | 6 |
| **CD** | Continuous Delivery/Deployment — Entrega Contínua | 6 |
| **IaC** | Infrastructure as Code — Infraestrutura como Código | 5 |
| **CI/CD** | Pipeline de verificação + entrega | 6 |
| **CLI** | Command Line Interface — interface de linha de comando | 1 |
| **API** | Application Programming Interface | 4 |
| **RBAC** | Role-Based Access Control — controle de acesso por papel | 4/8 |
| **SLI** | Service Level **Indicator** — a medida | 7 |
| **SLO** | Service Level **Objective** — a meta | 7 |
| **SLA** | Service Level **Agreement** — o contrato | 7 |
| **MTTR** | Mean Time To Recovery — tempo médio de recuperação | 9 |
| **MTTD** | Mean Time To Detect — tempo médio de detecção | 9 |
| **MTBF** | Mean Time Between Failures — tempo entre falhas | 9 |
| **SRE** | Site Reliability Engineering | 9 |
| **SPOF** | Single Point of Failure — ponto único de falha | 9 |
| **ADR** | Architecture Decision Record — registro de decisão | 9 |
| **OOM** | Out of Memory — morte por memória | 4 |
| **CRD** | Custom Resource Definition | 4 |
| **CNI** | Container Network Interface — rede dos pods | 4 |
| **TLS** | Transport Layer Security — criptografia da web | 1 |
| **DNS** | Domain Name System | 1 |
| **IP** | Internet Protocol | 1 |
| **SSH** | Secure Shell | 1 |
| **LTS** | Long Term Support — suporte estendido | 1 |
| **PID** | Process ID — identificador de processo | 3 |
| **OS** | Operating System — sistema operacional | 1 |
| **URL** | Uniform Resource Locator — endereço | 1 |
| **VM** | Virtual Machine — máquina virtual | 1 |
| **CVE** | Common Vulnerabilities and Exposures | 8 |
| **RAG** | Retrieval-Augmented Generation — recuperação + geração | 10 |
| **MCP** | Model Context Protocol | 10 |
| **LLM** | Large Language Model — modelo de linguagem | 10 |
| **JSON** | formato de dados chave-valor | — |
| **YAML** | formato dos manifests do K8s | 4 |
| **TODO / FIXME** | marcadores de código pendente | — |

---

## Frases de reunião — como perguntar sem parecer perdido

> Não existe pergunta burra em DevOps. Existe **não perguntar** e descobrir
> depois em produção. Estas frases são profissionais e diretas.

**Para entender o contexto**
- *"Isso é sobre build, sobre deploy ou sobre o que roda em produção?"*
- *"Qual o impacto pro usuário agora?"*
- *"Isso é novo ou sempre foi assim?"*
- *"Tem documentação ou é conhecimento da pessoa X?"*

**Para pedir reformulação**
- *"Pode explicar em termos de infraestrutura?"*
- *"Resumindo: é sobre criar recurso ou sobre configurar?"*
- *"Se me der o nome do serviço, eu busco."*

**Para saber se é seguro seguir**
- *"Como a gente detecta se isso falhar?"*
- *"Tem rollback? Em quanto tempo?"*
- *"Qual o blast radius dessa mudança?"*
- *"Isso já foi testado em homologação?"*

**Para assumir responsabilidade**
- *"Pode me passar o runbook / onde está o passo a passo?"*
- *"Quem é o dono disso?"*
- *"Vou tentar e volto em X minutos com o resultado."*

**Para dizer que não sabe (e isso é profissional)**
- *"Não conheço esse termo — pode me dar o contexto?"*
- *"Isso é novidade pra mim; me manda a doc que eu leio."*
- *"Prefiro confirmar antes de executar."*

---

## Regras de ouro do vocabulário

1. **Nunca diga "não funciona"**. Diga **o que** você fez, **o que** esperava e
   **o que** aconteceu. É a regra nº 1 de `AGENTS.md` deste projeto.
2. **Distinga observação de explicação.** "O pod reiniciou" é observação.
   "O pod reiniciou **porque** estourou o limit de memória" é explicação.
3. **Prefira nomes concretos.** "O deploy de terça" em vez de "a coisa".
4. **Se não sabe, pergunte o nome** — e anote aqui. Este glossário deve crescer
   com você, a cada módulo do `PLANO-DE-ENSINO.md`.
5. **Termo não é entendimento.** Saber a definição de *reconciliação* não é
   saber explicar por que seu pod voltou sozinho. A **Prova** de cada módulo é
   o teste real.

---

*Arquivo do projeto — junto com `AGENTS.md` (regras), `AMBIENTE.md` (ambiente) e
`PLANO-DE-ENSINO.md` (currículo). Atualize-o a cada módulo.*
