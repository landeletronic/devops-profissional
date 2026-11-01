# Aula — M0 em profundidade

> Os seis conceitos do simulado M0, explicados do zero, com esquemas e um
> **comando de verificação para cada um**. A regra desta aula é:
> *nenhuma afirmação sem evidência* — se está escrito aqui, você pode conferir
> no seu próprio terminal.

---

## 🪂 Você chegou de paraquedas? Comece aqui

Este é o **caderno de estudos de um iniciante em DevOps/AIOps** — não é
documentação oficial de produto. O autor é um estudante em transição de
carreira e o material registra **o que ele aprendeu, o que errou e como
consertou**. Você é bem-vindo a ler e a copiar os comandos, mas saiba que isto
é **material de aprendizagem**, não tutorial validado para produção.

### O contexto, em quatro linhas

| | |
|---|---|
| **O que é o M0** | o módulo **0** do treinamento: **montar o laboratório** — de uma VM Debian sem nada instalado até um cluster Kubernetes operante com uma aplicação no ar. |
| **O laboratório** | duas máquinas: uma **Windows** (editor, Git) e uma VM Debian **`pve-lab`** (`192.168.15.10`), onde **tudo é executado** (Docker, Kubernetes, banco, aplicação). |
| **O simulado** | ao fim do M0, **21 perguntas** em 4 blocos para testar o que realmente ficou claro. Foram respondidas as 6 primeiras — e **3 estavam erradas**. |
| **Esta aula** | é a **explicação de aprofundamento exatamente dessas 6 perguntas erradas**. Cada tópico nasceu de uma pergunta real e de uma resposta errada. |

### Onde está o quê neste repositório

| Documento | O que contém |
|---|---|
| [`README.md`](../README.md) | ponto de entrada — o que é este repositório e por que existe |
| [`notas/CADERNO-DE-LABORATORIO.md`](../notas/CADERNO-DE-LABORATORIO.md) | **o registro de estudo**: todos os passos, erros e correções — **incluindo as 21 perguntas do simulado na íntegra** e a correção das 6 respondidas |
| [`docs/GLOSSARIO-DEVOPS.md`](GLOSSARIO-DEVOPS.md) | **87 verbetes** de DevOps explicados em linguagem simples |
| [`docs/PLANO-DE-ENSINO.md`](PLANO-DE-ENSINO.md) | o roteiro do treinamento (módulos M0 a M6) |
| **este documento** | só a explicação das 6 perguntas erradas |

> **Se quiser ver a pergunta original, a resposta dada e a correção** de cada
> um dos 6 conceitos, tudo isso está em
> [`notas/CADERNO-DE-LABORATORIO.md`](../notas/CADERNO-DE-LABORATORIO.md),
> na seção **"Simulado M0"**. Aqui abaixo só aparece a **explicação**.

---

## Como usar este documento

Cada tópico tem a mesma estrutura:

| Seção | O que é |
|---|---|
| **O problema** | a pergunta errada, na forma em que ela aparece |
| **O conceito** | a ideia, sem jargão |
| **O esquema** | o diagrama — a parte que fixa |
| **Veja você mesmo** | comando real do seu laboratório |
| **Analogia** | para quando o técnico sair da cabeça |
| **Em uma frase** | o que levar para a entrevista |

No final: um **fichamento** (resumo em tabela) e uma **autoavaliação** nova.

> **Os esquemas usam caracteres de caixa** (`┌─┐│└┘`) em bloco de código —
> eles aparecem corretamente em **qualquer** visor: Bloco de Notas, VS Code,
> GitHub ou terminal. Sem dependência de plugin.

> **✅ Comandos verificados, não presumidos.** Cada comando desta aula foi
> executado no `pve-lab` antes de virar texto, e as **saídas exibidas são as
> reais** — incluindo a correção de um experimento meu que estava errado
> (ver a *nota de honestidade* no Tópico 2). O padrão é o mesmo do caderno:
> *nenhuma afirmação sem evidência*.

---

# Tópico 1 — Arquitetura: por que `localhost` falha

> ### 📋 A pergunta que originou este tópico
>
> **Q1 — Bloco 1 · Fundamentos**
>
> *"Descreva a arquitetura do laboratório: quem edita, quem executa. Por que
> `http://localhost:8000` não funciona a partir do seu Windows?"*
>
> ✏️ A resposta **dada** (parcialmente errada) e a **correção** estão no
> [caderno de laboratório — Simulado M0](../notas/CADERNO-DE-LABORATORIO.md).
> O que segue é o **aperfeiçoamento** dela.

## O problema

Você digita `http://localhost:8000` no navegador do Windows e dá erro — mas a
aplicação **está no ar** e responde normalmente quando chamada pelo IP da VM.
Como algo que funciona pode não funcionar?

## O conceito

`localhost` **não é um endereço de lugar**. É um **apelido para a própria
máquina em que o comando está rodando** — formalmente, a interface **loopback**
(`127.0.0.1`).

A frase chave é esta:

> **`localhost` aponta para onde você está, não para onde está a resposta.**

Seu Windows tem um `localhost`. O `pve-lab` tem outro `localhost`. São
endereços **diferentes** que significam **a mesma palavra**: *"esta máquina"*.

O erro acontece porque os dois papéis estão separados **de propósito**:

| Máquina | Papel | Tem o projeto instalado? |
|---|---|---|
| **Windows** | editor, Git, agente, navegador | ❌ não |
| **pve-lab** (`192.168.15.10`) | execução: Docker, cluster, banco, app | ✅ sim |

O processo `uvicorn` escuta na VM. Quando você pergunta por `localhost`, o
Windows procura **dentro de si mesmo** e não acha nada — porque **lá não existe
tal processo**.

## O esquema

```
   SEU WINDOWS  (editor + navegador)             pve-lab  (192.168.15.10)
┌────────────────────────────────────┐   ┌──────────────────────────────────┐
│                                    │   │                                  │
│  navegador                         │   │   uvicorn  escuta em             │
│   │                                │   │   0.0.0.0:8000                   │
│   ├─ localhost:8000 ──┐            │   │      │                          │
│   │                   │            │   │      ├─ aceita conexões de      │
│   │   127.0.0.1       │            │   │      │  QUALQUER interface      │
│   │   (loopback)      │            │   │      │                          │
│   │   volta pra MIM   │            │   │      │                          │
│   │                   ▼            │   │      │                          │
│   │            ┌────────────┐      │   │      │                          │
│   │            │ nada aqui! │ ❌   │   │      │                          │
│   │            └────────────┘      │   │      │                          │
│   │                                │   │      │                          │
│   └─ 192.168.15.10:8000 ──────── rede local ──▶  ✅ 200 OK                │
│                                    │   │                                  │
└────────────────────────────────────┘   └──────────────────────────────────┘

  A seta de CIMA morre dentro do Windows.
  A seta de BAIXO atravessa a rede e chega à VM.
```

### Por que a app aceita de qualquer lugar: `0.0.0.0`

Repare no esquema: o `uvicorn` liga em `0.0.0.0:8000`, **não** `127.0.0.1:8000`.

| Endereço de escuta | Significado |
|---|---|
| `127.0.0.1:8000` | escuta **só** para a própria máquina — invisível na rede |
| `192.168.15.10:8000` | escuta **só** naquela interface |
| `0.0.0.0:8000` | escuta em **todas** as interfaces — acessível por qualquer uma |

Por isso o `README` manda `--host 0.0.0.0`: se fosse `127.0.0.1`, a VM
responderia a ela mesma e o Windows nunca chegaria.

> **Nome do conceito: endereçamento.** *Para onde o tráfego vai* — glossário,
> Bloco 4.

## Veja você mesmo

**No Windows (PowerShell):**

```powershell
ipconfig | Select-String "IPv4"          # seu IP NAO e 192.168.15.10
curl.exe http://localhost:8000            # falha - nada escuta aqui
curl.exe http://192.168.15.10:8000        # 200 - chega na VM
Test-NetConnection 192.168.15.10 -Port 8000 | Select-Object TcpTestSucceeded
```

**No `pve-lab`:**

```bash
ip -4 addr show | grep inet               # mostra 192.168.15.10
ss -tlnp | grep 8000                      # QUEM escuta, e em QUAL endereco
```

O `ss` deve mostrar algo como:

```
LISTEN  0  511  0.0.0.0:8000  0.0.0.0:*  users:(("uvicorn",pid=...,fd=...))
```

**Leia esse retorno assim:** `0.0.0.0:8000` = *aceito de qualquer interface*;
`users:(("uvicorn"...))` = *é o `uvicorn` que está falando comigo*. Se o `ss`
**não** mostrasse a linha, o problema seria **a aplicação** — e não a rede.

## Analogia

Um prédio tem **dois portões**: o da sua casa e o do seu prédio.

- `localhost` = *"ir pela porta da minha casa"*. Se a recepção está no **outro**
  prédio, você bate na sua própria porta e não acha ninguém.
- `192.168.15.10` = *"ir pelo endereço correto do prédio"*.

O endereço não mudou; **mudou quem você estava chamando**.

## Em uma frase

> `localhost` é **relativo a quem pergunta** — para achar um serviço em outra
> máquina, você precisa do **endereço daquela máquina**, não do apelido da sua.

---

# Tópico 2 — `ca-certificates`: a cadeia de confiança

> ### 📋 A pergunta que originou este tópico
>
> **Q2 — Bloco 1 · Fundamentos**
>
> *"Por que o `ca-certificates` foi instalado antes de qualquer outra coisa? O
> que concretamente quebraria sem ele?"*
>
> ✏️ A resposta **dada** (parcialmente errada) e a **correção** estão no
> [caderno de laboratório — Simulado M0](../notas/CADERNO-DE-LABORATORIO.md).
> O que segue é o **aperfeiçoamento** dela.

## O problema

A resposta *"precisa ler os certificados dos sites para visualizar ou baixar"*
fica no campo, mas não explica **o que quebra concretamente** — e sem `ca-certificates`
**nada baixa, nada instala, nada clona**.

## O conceito

HTTPS/TLS tem um problema de fundo: ao conectar, você não sabe se o servidor é
**realmente** github.com ou um atacante fingindo ser. A solução é o servidor
**mostrar um certificado** — um documento dizendo *"sou github.com"* — que é
**assinado digitalmente por uma terceira pessoa de confiança**, uma
**Certificate Authority (CA)**.

Para verificar essa assinatura, o seu sistema precisa saber **em quais
autoridades ele confia**. Essa lista é o `ca-certificates`.

Portanto:

> **`ca-certificates` não guarda certificados de sites. Guarda a lista de
> autoridades emitentes em quem o seu sistema confia.**

A palavra `ca` no nome é a pista: **CA = Certificate Authority**.

Se a CA que assinou o certificado do servidor **não está** na sua lista, o
sistema **não tem como verificar** — e recusa. Não porque o site esteja
errado, mas porque **você não tem com quem conferir**.

## O esquema

```
        ┌──────────┐
        │  SEU     │  curl / apt / git
        │  SISTEMA │ ─────────────────────┐
        └──────────┘                      │
                                          ▼
                              ┌──────────────────────┐
                              │   SERVIDOR            │
                              │   github.com          │
                              └──────────┬───────────┘
                                         │  devolve um CERTIFICADO:
                                         │  "isto e github.com",
                                         │  assinado pela CA X
                                         ▼
                       ┌─────────────────────────────────────┐
                       │  O SEU SISTEMA CONFIRA:             │
                       │                                     │
                       │  A CA X esta na minha lista?        │
                       │  /etc/ssl/certs/ca-certificates.crt │
                       └───────────────┬─────────────────────┘
                                       │
                    ┌──────────────────┴──────────────────┐
                    ▼                                     ▼
            ┌──────────────┐                    ┌─────────────────────┐
            │   SIM ✅      │                    │   NAO ❌            │
            │  confio na    │                    │  nao sei quem e     │
            │  assinatura   │                    │  esse servidor      │
            │  -> continua  │                    │  -> RECUSA          │
            └──────────────┘                    └──────────┬──────────┘
                                                           ▼
                                                "SSL certificate problem:
                                                 unable to get local
                                                 issuer certificate"
```

### Onde isso aparece no M0

Foi o **primeiro** pacote instalado, no Passo 1 — e por boa razão: **todos os
repositórios são HTTPS**. Sem a lista de CAs, a cadeia inteira falha antes do
primeiro `apt-get update`:

```
download.docker.com        HTTPS  ─┐
deb.nodesource.com          HTTPS  ─┼──> precisa validar TLS
pkgs.k8s.io                 HTTPS  ─┤
prod-cdn.packages.k8s.io    HTTPS  ─┘
github.com (git clone)      HTTPS  ──── precisa validar TLS
```

## Veja você mesmo

**No `pve-lab`:**

```bash
ls -la /etc/ssl/certs/ca-certificates.crt          # o arquivo existe
grep -c "BEGIN CERTIFICATE" /etc/ssl/certs/ca-certificates.crt   # quantas CAs
```

**Saída real desta máquina:**

```
-rw-r--r-- 1 root root 222073 Oct 22 10:19 /etc/ssl/certs/ca-certificates.crt
148
```

**148 autoridades** — é a lista de quem o seu sistema confia. (O pacote tem
222 KB; quase tudo é certificado de raiz, não código.)

**Ver a troca acontecendo ao vivo:**

```bash
curl -v https://github.com -o /dev/null 2>&1 | grep -iE 'issuer|subject|verify'
```

**Saída real:**

```
*  subject: CN=github.com
*  issuer: C=GB; O=Sectigo Limited; CN=Sectigo Public Server Authentication CA DV E36
*  SSL certificate verify ok.
```

Leia as três linhas:

| Linha | O que responde |
|---|---|
| `subject: CN=github.com` | **de quem é** o certificado |
| `issuer: … Sectigo … CA …` | **quem assinou** — a Certificate Authority |
| `SSL certificate verify ok.` | **a verificação passou** — a CA do `issuer` **está** na sua lista |

**Ou com `openssl`, que mostra a cadeia inteira:**

```bash
echo | openssl s_client -connect github.com:443 -servername github.com 2>/dev/null | grep "Verify return"
# -> Verify return code: 0 (ok)
```

`0 (ok)` é o mesmo `ok.` do `curl` por outro caminho — **prova de que a
verificação acontece**, não é suposição.

> **E quando falha?** Se a CA do `issuer` **não** estiver no bundle, o `curl`
> interrompe a conexão com a mensagem clássica:
>
> ```
> curl: (60) SSL certificate problem: unable to get local issuer certificate
> ```
>
> **Repare em quem está o problema:** o servidor está perfeitamente de pé. Quem
> falhou foi **a sua capacidade de confiar**. A atitude segura é **recusar** —
> é segurança falhando **para o lado seguro**.
>
> ⚠️ **Nota de honestidade, já que esta aula promete evidência:** eu testei
> forçar isso com `curl --cacert /arquivo-vazio`, e ele responde
> `(77) error setting certificate file` — um erro **de arquivo**, não **de
> confiança**. Não é o mesmo fenômeno, e por isso **não** é o experimento
> certo. O comando que **prova** a verificação é o de cima
> (`SSL certificate verify ok.`).

## Analogia

Você recebe um passaporte. Para saber se ele é verdadeiro, olha o **selo** — mas
só consegue reconhecer o selo se **souber desenhar o autêntico**.

`ca-certificates` é a **pasta com os autógrafos oficiais**. Sem ela, todo
passaporte parece falso — inclusive os verdadeiros.

## Em uma frase

> Sem `ca-certificates` o sistema **não consegue verificar ninguém** — e a
> atitude segura é **recusar tudo**, não aceitar tudo. É segurança falhando
> **para o lado errado**.

---

# Tópico 3 — Repositórios, assinaturas e o `apt policy`

> ### 📋 A pergunta que originou este tópico
>
> **Q3 — Bloco 1 · Fundamentos**
>
> *"Cite **três** razões pelas quais o Node **24** foi o escolhido — sendo a
> principal delas baseada em evidência, não em gosto."*
>
> ✏️ A resposta **dada** (citou só **uma** razão — falhou por entregar menos do
> que a pergunta pedia) e a **correção** estão no
> [caderno de laboratório — Simulado M0](../notas/CADERNO-DE-LABORATORIO.md).
> O que segue é o **aperfeiçoamento** dela.

## O problema

Você pediu Node **24** e recebeu **20**, **sem nenhum erro na hora da
instalação**. E a pergunta do simulado pedia **três** razões para o 24 e veio
uma.

## O conceito — três coisas separadas

### 3.1 — De onde vem o pacote: repositório + chave

Um repositório Linux não é só uma pasta de arquivos. Ele publica dois:

1. os **pacotes** (`.deb`)
2. uma **assinatura digital** feita com a chave privada do autor

Para conferir essa assinatura, o `apt` precisa da **chave pública** do autor —
guardada num arquivo chamado **keyring**, que o sistema só aceita se estiver
num diretório declarado como confiável (no Debian 13: `/etc/apt/keyrings/`).

**Sem o keyring, o `apt` não consegue validar nada — e recusa o repositório
inteiro.**

### 3.2 — Onde ele escolhe: `apt policy` e o `Candidate`

Uma mesma máquina pode ter **vários repositórios** oferecendo o mesmo pacote.
O `apt` precisa escolher. A regra:

| Etapa | O que acontece |
|---|---|
| 1 | lista **todas as fontes** e a **prioridade** de cada (`500` é o padrão) |
| 2 | se as prioridades **empatam**, vence a **versão mais alta** |
| 3 | o vencedor aparece na linha **`Candidate:`** |

**`Candidate` é a resposta à pergunta "o que vai ser instalado"** — e ela
existe **antes** de você instalar.

### 3.3 — Por que "não deu erro" não é sucesso

A cascata do Err01 tem cinco etapas, e só a **primeira** foi um erro visível:

```
(1)  gpg ausente  ──>  keyring NUNCA criado          [erro visivel: "command not found"]
                              │
(2)  apt lê o repo sem chave  ──>  "is not signed"     [erro visivel: E: / N:]
                              │
(3)  apt DESATIVA o repo                          [N: disabled by default]
                              │
(4)  install nodejs  ──>  cai para a FONTE DO DEBIAN [SEM ERRO! instala 20.x]
                              │
(5)  nodejs do Debian nao traz npm                  [npm: command not found]
```

**A etapa (4) é a perigosa.** Ela não falha — ela **entrega outra coisa**. Foi
por isso que o `apt policy` foi a correção: ele mostra a etapa (4) **antes** de
ela acontecer.

## O esquema

```
          REPOSITÓRIO                          SEU SISTEMA
   ┌──────────────────────────┐      ┌────────────────────────────────┐
   │  deb.nodesource.com      │      │  /etc/apt/keyrings/            │
   │                          │      │                                │
   │  nodejs_24.deb           │      │  nodesource.gpg  ◄── CHAVE     │
   │  + ASSINATURA            │      │  docker.asc                    │
   └────────────┬─────────────┘      │  kubernetes.gpg                │
                │                     └───────────────┬────────────────┘
                │  pacote + assinatura                 │ chave publica
                ▼                                      ▼
                ┌──────────────────────────────────────────┐
                │                 apt                      │
                │   "a assinatura confere com esta chave?"  │
                └───────────────────┬──────────────────────┘
                                    │
              ┌─────────────────────┴─────────────────────┐
              ▼                                           ▼
     ┌─────────────────┐                        ┌──────────────────────┐
     │  SIM  ✅         │                        │  NAO  ❌             │
     │  repo confiavel  │                        │  repo DESATIVADO     │
     │  -> apt policy   │                        │  -> apt cai para     │
     └────────┬────────┘                        │     OUTRA fonte      │
              │                                  └──────────────────────┘
              ▼
   ┌──────────────────────────────────────────┐
   │  apt policy nodejs                       │
   │                                          │
   │  fonte A (nodesource)  500  ── 24.22.1   │──┐
   │  fonte B (debian)      500  ── 20.19.2   │──┤
   │                                          │  │
   │  prioridade EMPATADA -> vence MAIOR      │◄─┘
   │                                          │
   │  Candidate: 24.22.1-1nodesource1   ◄────── A LINHA QUE RESPONDE
   └──────────────────────────────────────────┘
```

## Veja você mesmo

```bash
ls -la /etc/apt/keyrings/                  # os keyrings existem?
grep -rh "^deb" /etc/apt/sources.list.d/   # quais repos estao ligados
apt policy nodejs                           # a linha Candidate
apt policy docker-ce kubectl                # o mesmo principio
apt-cache depends nodejs | head -5          # de onde veio o python3
apt-get -s install nodejs                   # -s = SIMULACAO, nao instala
```

**O `-s` (simulate) é ouro:** ele mostra **o que iria acontecer** sem acontecer
nada. É o `apt policy` levado ao extremo — ler antes de agir.

## Analogia

- **Repositório** = a loja.
- **Keyring** = o cadastro da polícia: só você entrega a encomenda se o
  vendedor consta lá.
- **`Candidate`** = o etiquetador de preço automático: *"destes cinco
  fornecedores, este é o que vou levar"* — e o etiquetador está **na prateleira
  antes** de você pagar.

## Em três frases

> 1. Sem keyring **nenhum** repositório passa — e o `apt` **desliga** em vez de parar.
> 2. `apt policy` mostra **`Candidate:`**, que é *o que será instalado*.
> 3. **Instale todos os pré-requisitos documentados de uma vez** — dependência
>    ausente é **latente**.

---

# Tópico 4 — Docker: `daemon` × `container` (`live-restore` × volume)

> ### 📋 A pergunta que originou este tópico
>
> **Q4 — Bloco 1 · Fundamentos** · *resposta ERRADA*
>
> *"O que a directiva `live-restore: true` faz no `daemon.json`? Dê uma
> situação real em que ela salva você."*
>
> ✏️ A resposta **dada** (errada — confundiu `live-restore` com persistência de
> dados) e a **correção** estão no
> [caderno de laboratório — Simulado M0](../notas/CADERNO-DE-LABORATORIO.md).
> O que segue é o **aperfeiçoamento** dela.
>
> > **Esta era uma das três perguntas que eu errei.** Se quiser ver como eu
> > errei e o porquê, comece pelo caderno — aqui só está o conceito certo.

## O problema

> *"quando o container atualiza/reboot/crash ele retorna ao estado normal sem
> perder os dados"* ❌

Isso descreve **persistência de dados**, que é trabalho do **volume**.
`live-restore` responde a **outra pergunta**, sobre **outra camada**.

## O conceito — dois eixos diferentes

O Docker tem **três camadas**, e é aqui que a confusão nasce:

```
┌─────────────────────────────────────────────────────────────────┐
│  CAMADA 3 - CONTAINERS          (o que roda)                    │
│     postgres    pgadmin    app                                  │
├─────────────────────────────────────────────────────────────────┤
│  CAMADA 2 - DAEMON              (o gerente: docker.service)     │
│     cria, para, reinicia, gerencia tudo. CONFIGURADO AQUI.      │
├─────────────────────────────────────────────────────────────────┤
│  CAMADA 1 - HOST (pve-lab)      (o sistema operacional)         │
│     disco, rede, systemd                                        │
└─────────────────────────────────────────────────────────────────┘
```

`live-restore` configura a **camada 2**: o que acontece com a **camada 3**
quando a **própria camada 2** reinicia.

`volume` configura a **camada 3**: o que acontece com os **dados** quando o
**container** é recriado.

**São eixos distintos.** A tabela 2×2 é o esquema que resolve tudo:

| | **Container é PARADO/RECREADO** | **DAEMON reinicia** |
|---|---|---|
| **Com `volume`** | dados **sobrevivem** (estão fora do container) | — |
| **Sem `volume`** | dados **perdem** (estavam dentro do container) | — |
| **Com `live-restore`** | — | containers **continuam rodando** |
| **Sem `live-restore`** | — | **todos os containers caem** ❌ |

- **`volume`** governa a **coluna da esquerda** (destino dos **dados**).
- **`live-restore`** governa a **coluna da direita** (destino dos **processos**).

Seu laboratório usa **os dois**: `volume` = `postgres_data`, `live-restore` =
`true` no `daemon.json`.

## O esquema

```
              SITUAÇÃO A: o DAEMON reinicia
              (systemctl restart docker / apt upgrade docker-ce)
     ┌────────────────────────────────────────────────────────┐
     │                                                        │
     │   SEM live-restore              COM live-restore       │
     │   ┌──────────────────┐          ┌──────────────────┐   │
     │   │ daemon reinicia  │          │ daemon reinicia  │   │
     │   │      │           │          │      │           │   │
     │   │      ▼           │          │      ▼           │   │
     │   │ mata TODOS       │          │ containers       │   │
     │   │ os containers ❌  │          │ CONTINUAM ✅     │   │
     │   │                  │          │                  │   │
     │   │ seu Postgres     │          │ Postgres segue   │   │
     │   │ cai, app cai     │          │ no ar, app no ar │   │
     │   └──────────────────┘          └──────────────────┘   │
     │                                                        │
     │   onde esta a directiva?  ->  /etc/docker/daemon.json  │
     │   (CONFIGURACAO DO DAEMON, nao do container)           │
     └────────────────────────────────────────────────────────┘

              SITUAÇÃO B: o CONTAINER é recriado
              (docker compose up --force-recreate / deploy)
     ┌────────────────────────────────────────────────────────┐
     │                                                        │
     │   SEM volume                      COM volume           │
     │   ┌──────────────────┐          ┌──────────────────┐   │
     │   │ dados dentro do  │          │ dados em         │   │
     │   │ container        │          │ /var/lib/docker/ │   │
     │   │      │           │          │ volumes/...      │   │
     │   │      ▼           │          │      │           │   │
     │   │ container some   │          │ container some   │   │
     │   │ -> dados POSTAM  ❌          │      ▼           │   │
     │   │                  │          │ volume PERMANECE ✅│   │
     │   └──────────────────┘          └──────────────────┘   │
     │                                                        │
     │   onde esta?  ->  docker-compose.yml (volumes:)        │
     └────────────────────────────────────────────────────────┘
```

## Veja você mesmo

```bash
docker info | grep -i "live restore"        # Live Restore Enabled: true
cat /etc/docker/daemon.json                 # a directiva na fonte

docker inspect boilerplate-k8s-aiops-postgres-1 \
  --format 'restart: {{.HostConfig.RestartPolicy.Name}}'

docker inspect boilerplate-k8s-aiops-postgres-1 \
  --format '{{range .Mounts}}{{.Type}}  {{.Source}}{{"\n"}}{{end}}'
#   -> volume  /var/lib/docker/volumes/.../_data   (PROVA do volume)
```

### O experimento definitivo (opcional)

Com `live-restore` **ativo**, isto é seguro:

```bash
systemctl restart docker
sleep 3
docker ps          # os containers continuam la?
```

Se você vir `postgres` e `pgadmin` **ainda `Up`**, viu `live-restore` com os
próprios olhos. **Antes** de rodar, saiba o contrário: se você fizesse isso
com `live-restore: false`, **todos cairiam**. É exatamente o que a directiva
evita.

> **Se algo sair do controle:** `cd ~/projetos/imersao-aiops-prod-01 && ./aiops-lab.sh up`
> reergue tudo.

### O nome engana

`live-restore` **não** significa *"restaura ao vivo"*. É *"manter vivo durante
a restauração do daemon"* — ou seja, **não derrubar o que está rodando** quando
o próprio gerente reinicia.

## Analogia

- **`live-restore`** = o **gerente do galpão** sai de férias e o galpão **segue
  funcionando**. O problema é do gerente, não das máquinas.
- **`volume`** = os **arquivos** ficam no **armário do prédio**, não na mesa do
  funcionário. Se a mesa for trocada, os arquivos ficam.

**Gerente ≠ mesa. Processo ≠ dados.**

## Em uma frase

> `live-restore` protege **processos** contra restart do **daemon**;
> `volume` protege **dados** contra recriação do **container**. Nunca confunda
> os dois eixos.

---

# Tópico 5 — Kubernetes: cluster × contexto

> ### 📋 A pergunta que originou este tópico
>
> **Q5 — Bloco 1 · Fundamentos** · *resposta ERRADA*
>
> *"Qual a diferença entre o **cluster** `aiops` e o **contexto** `kind-aiops`?
> E o que acontece se o `kubectl` apontar para o contexto errado?"*
>
> ✏️ A resposta **dada** (errada — falou de "dois clusters", que é outro assunto)
> e a **correção** estão no
> [caderno de laboratório — Simulado M0](../notas/CADERNO-DE-LABORATORIO.md).
> O que segue é o **aperfeiçoamento** dela.
>
> > **Esta era uma das três perguntas que eu errei.** Se quiser ver como eu
> > errei e o porquê, comece pelo caderno — aqui só está o conceito certo.

## O problema

A pergunta era *"cluster × contexto"*. A resposta dada falou de **dois clusters
rodando** — que é outro assunto. Este tópico separa os dois com rigor.

## O conceito

### 5.1 — Cluster: o **lado servidor**

O cluster é **o conjunto de máquinas (nós) e seus componentes**. No seu caso:

```
cluster aiops
├── nó: aiops-control-plane        (o container "servidor")
│   ├── kube-apiserver             (a porta de entrada)
│   ├── etcd                       (o banco de estado)
│   ├── kube-scheduler             (decide ONDE cada pod roda)
│   └── kube-controller-manager    (mantém o estado desejado)
├── pods: coredns, kindnet, kube-proxy, local-path-storage
└── pods: teste-a, teste-b (os cenarios de falha)
```

Existe ou não existe. É **coisa de servidor**.

### 5.2 — Contexto: o **lado cliente**

Um contexto é **uma linha numa configuração local** — o arquivo `kubeconfig`
(`~/.kube/config`). Ele diz **ao `kubectl`**:

- **qual servidor** falar (`server: https://...`)
- **com qual credencial**
- **qual namespace** usar por padrão

> **Contexto = ponteiro/perfil.** Ele **não é** o cluster. É o **mapa** para
> achar ele.

Por isso a relação é **N para 1**: vários contextos podem apontar para o
**mesmo** cluster, e um mesmo `kubeconfig` guarda contexto para **vários**
clusters ao mesmo tempo.

## O esquema

```
  SEU WINDOWS / pve-lab - LADO CLIENTE
  ┌─────────────────────────────────────────────────────────────┐
  │  ~/.kube/config  (kubeconfig)                               │
  │                                                             │
  │  contextos = PONTEIROS, nao clusters                        │
  │  ┌───────────────────────────┐   ┌────────────────────────┐ │
  │  │ NOME: kind-aiops          │   │ NOME: outro-cluster    │ │
  │  │ server: https://127.0.0.x │   │ server: https://10.0.x │ │
  │  │ user: kind-admin          │   │ user: admin            │ │
  │  │ namespace: default        │   │ namespace: default     │ │
  │  └────────────┬──────────────┘   └───────────┬────────────┘ │
  │               │                              │              │
  │   ATIVO ◄─────┤                              │              │
  │   (current)   │                              │              │
  └───────────────┼──────────────────────────────┼──────────────┘
                  │                              │
                  │  fala com                    │  fala com
                  ▼                              ▼
  LADO SERVIDOR ┌─────────────────────┐   ┌─────────────────────┐
                │  CLUSTER aiops      │   │  OUTRO CLUSTER      │
                │  control-plane      │   │  2 nos              │
                │  9 pods             │   │                     │
                └─────────────────────┘   └─────────────────────┘

  Um kubeconfig -> varios contextos -> varios clusters.
  O "current-context" e o ponteiro ATIVO.
```

### 5.3 — O que acontece com o contexto errado

Este é o ponto que importa, e ele é **silencioso**:

```
  kubectl apply -f app.yaml
         │
         ▼
  le current-context  ──>  "kind-OUTRO"
         │
         ▼
  envia para o cluster ERRADO
         │
         ▼
  "deployment.apps/app created"        ◄── SEM NENHUM ERRO
         │
         ▼
  voce abre http://192.168.15.10:8000   ◄── nada responde
         │
         ▼
  "por que nao funcionou?"              ◑  funcionou... NOUTRO LUGAR
```

**O `kubectl` não avisa.** Ele obedece ao ponteiro. Por isso a pergunta de
diagnóstico **sempre** deve ser: *"apontando para qual cluster?"* — antes de
investigar código, imagem ou manifesto.

> **Nome do conceito: contexto** — glossário, Bloco 4. É o mesmo princípio do
> `localhost` do Tópico 1: **depende de onde você está falando**.

## Veja você mesmo

```bash
kubectl config get-contexts            # todos + qual tem "*" (ativo)
kubectl config current-context         # so o ativo
kubectl cluster-info                   # QUE cluster o ativo aponta
kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}'; echo
kind get clusters                      # os clusters QUE EXISTEM de verdade
```

**A comparação que resolve tudo:**

```bash
kubectl config current-context    # diz: "kind-aiops"
kind get clusters                 # diz: "aiops"
```

Se o **nome do contexto** e o **nome do cluster** forem coerentes, está tudo
bem. Se forem diferentes, **é para investigar**.

### O achado que costura os Tópicos 1 e 5

Olhe **o endereço do servidor** que o contexto ativo declara:

```bash
kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}'; echo
```

**Saída real:**

```
https://127.0.0.1:35735
```

**`127.0.0.1` — localhost.** A API do cluster está em **loopback da máquina que
roda o `kubectl`**.

```
   pve-lab  (192.168.15.10)
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   kubectl roda AQUI                                         │
│      │                                                      │
│      └──> https://127.0.0.1:35735   ◄── localhost DESTA     │
│                                    maquina -> ✅ funciona   │
│                                                             │
└─────────────────────────────────────────────────────────────┘

   SEU WINDOWS
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   se voce rodasse kubectl AQUI                              │
│      │                                                      │
│      └──> https://127.0.0.1:35735   ◄── localhost do        │
│                                    WINDOWS -> ❌ nada aqui  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**É o Tópico 1 outra vez, sob outra roupa.** O `kind` **tuneia** a API do
cluster para o `localhost` da máquina onde ele roda — porque o nó do Kubernetes
é um container naquela mesma máquina. Consequências práticas:

1. **O `kubectl` precisa rodar no `pve-lab`** — de lá, `127.0.0.1:35735` resolve
   para a VM, e funciona.
2. Para rodar `kubectl` **do Windows**, você precisaria encaminhar essa porta
   (`kubectl proxy` / `port-forward`) **e** mudar o kubeconfig. Não é o caso
   aqui.
3. **`localhost` é relativo a quem pergunta** — vale para `curl` (Tópico 1) e
   para a **API do cluster** (Tópico 5). Mesma raiz, dois sintomas.

> **Por que isso importa em diagnóstico:** se algum dia você tentar `kubectl`
> do Windows e ele reclamar de conexão, o código está **certo** — o erro é de
> **onde** você está executando. É a pergunta *"qual máquina?"* de novo.

## Analogia

- **Cluster** = o **prédio** (endereço físico, com gente dentro).
- **Contexto** = a **contato salvo no seu celular** — nome, endereço e chave.
- **`current-context`** = o contato **selecionado agora**.

Você pode ter vários contatos salvos para o mesmo prédio (dois contextos → um
cluster), e um contato pode ficar **desatualizado** — você liga e a pessoa
antiga atende. **O aparelho não avisa que está ligando para o lugar errado.**

## Em uma frase

> **Cluster é servidor; contexto é configuração local.** Antes de diagnosticar
> qualquer coisa no `kubectl`, confirme **para qual cluster** ele está falando.

---

# Tópico 6 — Python: intérprete × ambiente × `uv`

> ### 📋 A pergunta que originou este tópico
>
> **Q6 — Bloco 1 · Fundamentos** · *resposta quase completa*
>
> *"Neste ambiente existem, ou podem existir, dois `python3`. De onde veio o
> `python3` que o `uv` usou no `uv sync`? E por que ele veio?"*
>
> ✏️ A resposta **dada** (quase completa — acertou a origem, mas não explicou
> *por que* existem dois) e a **correção** estão no
> [caderno de laboratório — Simulado M0](../notas/CADERNO-DE-LABORATORIO.md).
> O que segue é o **aperfeiçoamento** dela.

## O problema

Você acertou que *"um deles estava nas dependências do nodejs"* — mas não
disse **qual** foi usado, nem **por que** existem dois em primeiro lugar.

## O conceito — três coisas que se confundem

| Termo | O que é | Neste laboratório |
|---|---|---|
| **Intérprete** | o executável `python3` que roda código | `/usr/bin/python3` → **3.13.5** |
| **Ambiente virtual** | uma **pasta isolada** com seus próprios pacotes | `boilerplate-k8s-aiops/.venv/` |
| **Gerenciador** | ferramenta que **baixa intérpretes e pacotes** | `uv` → **0.13.5** |

### Por que existem dois `python3`?

```
  apt install nodejs   (NodeSource)
        │
        │  apt-cache depends nodejs
        │     Depends: python3        ◄── declarado pelo proprio pacote
        ▼
  /usr/bin/python3  3.13.5 instalado no sistema
```

**Por que o Node pede Python?** O `node-gyp` — ferramenta que **compila
módulos nativos** (tipo `bcrypt`, que exige compilador C) — é escrito em
Python. Você pediu Node; o Python chegou **como dependência declarada**.

### Por que o `uv` usou esse, e não um próprio?

A saída foi explícita:

```
Using CPython 3.13.5 interpreter at: /usr/bin/python3
```

O `uv` **procura um intérprete compatível** com o que o projeto pede
(`.python-version`) e **usa um que já existe** quando encontra. Só baixa um
próprio se não achar.

> **E a beleza:** **duas decisões que pareciam separadas se encontraram** — o
> Python instalado *por causa* do Node foi o que o `uv` usou *depois*. É o
> tipo de efeito colateral que **só aparece se você ler as saídas**.

### Por que existe o `.venv` — e por que não instalar no sistema

Se os 108 pacotes fossem para `/usr/bin/python3`:

1. você **quebraria** ferramentas do sistema que usam Python
2. **dois projetos** com versões incompatíveis brigariam pelo mesmo lugar
3. **ninguém conseguiria reproduzir** — não haveria lista de versões

O `.venv` resolve os três: fica **dentro da pasta do projeto**, é descartável,
e o `uv.lock` (644 KB) **trava cada versão**.

## O esquema

```
  SEU SISTEMA (pve-lab)                 PROJETO (boilerplate-k8s-aiops/)
  ┌──────────────────────────┐          ┌────────────────────────────────┐
  │                          │          │                                │
  │  /usr/bin/python3        │          │  .venv/                        │
  │  3.13.5                  │◄───copiado/de───│  python  (mesmo 3.13.5)   │
  │  (veio do Depends: do    │          │  └── site-packages/            │
  │   nodejs, p/ node-gyp)   │          │        fastapi  langchain ...  │
  │                          │          │        108 pacotes             │
  │  ferramentas do sistema  │          │                                │
  │  usam ISTO                │          │  TRAVADO POR:  uv.lock         │
  │                          │          │  (644 KB, 1 versao exata/pacote)│
  └──────────────────────────┘          └────────────────────────────────┘
                 ▲                                    ▲
                 │                                    │
                 └───────────────┐    ┌───────────────┘
                                 ▼    ▼
                          ┌──────────────────┐
                          │       uv         │
                          │  0.13.5 (Rust)   │
                          │                  │
                          │  uv sync  -> cria/instala no .venv
                          │  uv run   -> roda DENTRO do .venv
                          └──────────────────┘

  REGRAS:
   · nunca instale pacote no /usr/bin/python3 do sistema
   · "uv run X" = "X dentro do ambiente certo"
   · mudou o pyproject.toml? -> uv sync de novo
   · sem .venv? -> uv sync recria tudo do uv.lock (reprodutivel)
```

## Veja você mesmo

```bash
which -a python3                      # todos os python3 que existem

cd ~/projetos/imersao-aiops-prod-01/boilerplate-k8s-aiops
uv run python -c "import sys; print(sys.executable)"   # onde ele roda?
uv run python -c "import sys; print(sys.version)"      # qual versao?

python3 -c "import fastapi"           # DEVE FALHAR (fora do venv)
uv run python -c "import fastapi"     # DEVE FUNCIONAR
```

**Saída real desta máquina:**

```
/usr/bin/python3
/bin/python3

/home/tlandskron/projetos/imersao-aiops-prod-01/boilerplate-k8s-aiops/.venv/bin/python
3.13.5

fora do venv: ModuleNotFoundError: No module named 'fastapi'
dentro (uv run): importou OK -> 0.139.2
```

**Leia a prova:** o `fastapi` **existe** no `.venv` e **não existe** no sistema.
Mesmo interpretador (3.13.5), mesmo comando — **dois resultados diferentes,
dependendo do ambiente**. É o isolamento funcionando, não é teoria.

> ⚠️ **Armadilha registrada no caderno:** estes comandos precisam de um
> **terminal interativo**. Se você rodá-los num script ou via
> `ssh host "bash script.sh"`, o shell é **não-interativo, não-login** — ele
> **não lê `.profile` nem `.bashrc`**, o `uv` sai do `PATH` e aparece
> `uv: command not found`. Foi exatamente isso que quase gerou um alarme
> falso no Passo 4. Num terminal normal, funcionando.

## Analogia

- **Intérprete** = a **língua** que fala Python.
- **`.venv`** = o seu **caderno de anotações** — você não escreve no dicionário
  público do sistema.
- **`uv.lock`** = a **receita exata**: *50 g de farinha* em vez de *"uma
  pitada"* — por isso o `uv sync` resolveu **110 pacotes em 1 ms**, porque não
  havia nada a decidir.
- **`uv run`** = **usar o seu caderno**, não o dicionário.

## Em uma frase

> Um **intérprete** é a língua, um **ambiente virtual** é o seu caderno, e um
> **lock file** é a receita exata — instale sempre no caderno, nunca no
> dicionário público.

---

# Fichamento — os seis em tabela

| # | Conceito | O erro comum | A verdade | Prova no terminal |
|---|---|---|---|---|
| 1 | **Endereçamento** | achar que `localhost` é um lugar | `localhost` = *esta máquina*; serviço em outra exige o **IP dela** | `curl localhost:8000` vs `curl 192.168.15.10:8000` |
| 2 | **Cadeia de confiança** | achar que guarda certificados de sites | guarda a lista de **CAs confiáveis**; sem ela, **nada é verificável** | `grep -c BEGIN /etc/ssl/certs/ca-certificates.crt` |
| 3 | **Repositórios / apt** | "não deu erro" = deu certo | sem keyring o repo **desativa** e o `apt` **cai para outra fonte**; `Candidate:` responde antes | `apt policy nodejs` · `apt-get -s install` |
| 4 | **daemon × container** | confundir `live-restore` com volume | `live-restore` protege **processos** (restart do daemon); `volume` protege **dados** (recriação do container) | `docker info \| grep -i live` · `docker inspect ... .Mounts` |
| 5 | **cluster × contexto** | falar de dois clusters | cluster = **servidor**; contexto = **ponteiro local** no `kubeconfig`; contexto errado **não avisa** | `kubectl config get-contexts` + `kind get clusters` |
| 6 | **Python** | achar que uv "cria" um python novo sempre | o uv **usa o que existe** se servir; `.venv` isola; `uv.lock` trava | `uv run python -c "import sys; print(sys.executable)"` |

---

# Autoavaliação — responda sem olhar

**A1.** No seu Windows, `http://localhost:8000` falha. Um colega diz *"então
instala o projeto no Windows"*. Explique por que essa solução está **errada no
conceito**, mesmo que fizesse funcionar.

**A2.** Um colega instala `curl` mas esquece o `ca-certificates`. Descreva o
**primeiro sintoma** que ele veria e **por que o erro aponta para o lugar
errado**.

**A3.** O `apt policy` mostra duas fontes, ambas com prioridade `500`. Você
quer a 20, não a 24. Dê **duas** formas de obter a versão que você quer, sem
mexer no repositório.

**A4.** Complete: *"se eu reiniciar o **daemon** do Docker com `live-restore:
false`, _____; se eu recriar o **container** sem `volume`, _____."* — e diga
qual dos dois é recuperação de **dado**.

**A5.** Você roda `kubectl apply -f app.yaml` e recebe
`deployment.apps/app created`. Depois, `kubectl get pods` mostra o pod **Running**
— mas o site não abre. **Três** perguntas que você faria, **nesta ordem**, e
por que a primeira é a mais importante.

**A6.** Por que `uv sync` resolveu **110 pacotes em 1 ms**? O que o
`uv.lock` de 644 KB contém que torna isso possível — e o que aconteceria se ele
não existisse?

**A7. (síntese)** Explique como **`localhost`** e **contexto errado** são o
**mesmo tipo de problema**, e nomeie o verbete do glossário que cobre os dois.

---

## Próximo passo

- Se errar **A1, A4 ou A5** → refaça a leitura dos Tópicos 1, 4 e 5.
- Se errar **A2, A3 ou A6** → os Tópicos 2, 3 e 6.
- **A7** é a pergunta de entrevista: quem acerta, entendeu a **estrutura**, não
  o vocabulário.

---

## O que ficou pendente — resolvido

Este documento cobre o **Bloco 1** do simulado. O caderno registra **21
perguntas no total, em 4 blocos** — e **todas foram respondidas** em
2026-11-01:

| Bloco | Perguntas | Estado |
|---|---|---|
| **1 — Fundamentos** | Q1 a Q6 | ✅ respondido e corrigido *(este documento)* |
| **2 — Mecanismos** | Q7 a Q12 | ✅ respondido e corrigido — aprofundamento em [`AULA-M0-BLOCO2.md`](AULA-M0-BLOCO2.md) |
| **3 — Diagnóstico** | Q13 a Q18 | ✅ respondido e corrigido |
| **4 — Síntese** | Q19 a Q21 | ✅ respondido e corrigido |

**Autoavaliação A1–A7:** ✅ respondida (registro no caderno).

O enunciado completo das 21 está em
[`notas/CADERNO-DE-LABORATORIO.md`](../notas/CADERNO-DE-LABORATORIO.md),
seção **"Simulado M0 — enunciado completo"**; as correções dos Blocos 2, 3
e 4 seguem na seção **"Correção do Bloco 2, 3 e 4"**.

---

## Onde continuar a leitura

| Documento | Para quê |
|---|---|
| [`README.md`](../README.md) | o repositório inteiro — visão geral |
| [`notas/CADERNO-DE-LABORATORIO.md`](../notas/CADERNO-DE-LABORATORIO.md) | **o registro de estudo**: passo a passo, erros, correções e o simulado completo |
| [`docs/GLOSSARIO-DEVOPS.md`](GLOSSARIO-DEVOPS.md) | os **87 termos** usados aqui, em linguagem simples |
| [`docs/PLANO-DE-ENSINO.md`](PLANO-DE-ENSINO.md) | o roteiro dos módulos M0 a M6 |

Este documento permanece como a **explicação do Bloco 1**; os demais blocos
estão corrigidos no caderno, e o Bloco 2 ganhou aula própria em
[`AULA-M0-BLOCO2.md`](AULA-M0-BLOCO2.md).
