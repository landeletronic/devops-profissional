# CADERNO DE LABORATÓRIO — registro de execução

> **Propósito:** registrar cada comando executado no `pve-lab`, com a explicação
> e o resultado, para conferência e revisão. É a memória do hands-on — o
> `PLANO-DE-ENSINO.md` diz **o que** fazer; este caderno diz **o que foi feito
> e o que deu**.
>
> **Canônico:** `pve-lab:~/projetos/imersao-aiops-prod-01/notas/CADERNO-DE-LABORATORIO.md`
> **Espelho de leitura:** `C:\Users\tlandskron\Downloads\AIOps\CADERNO-DE-LABORATORIO.md`
> Em caso de divergência, vale o do repositório.

---

## Convenções

| Marca | Significado |
|---|---|
| `[OK]` | funcionou como esperado, sem nada a notar |
| `[NOTA]` | funcionou, mas a saída ensina algo que vale registrar |
| `[ATENÇÃO]` | funcionou, mas há algo a acompanhar |
| `[ERRO]` | falhou — e o erro fica registrado com o diagnóstico |

**Arquitetura do projeto:** o **Windows** é a estação (editor, Git, OpenCode);
o **`pve-lab`** é onde as coisas **executam** (toolchain, cluster, serviços).
Os comandos deste caderno são todos executados **dentro do `pve-lab`**, salvo
indicação em contrário.

---

## Contexto inicial — o que já estava pronto antes do Passo 0

Antes de qualquer instalação, a máquina já tinha os preparos feitos. Ficam
registrados aqui porque também foram comandos, e porque você precisa saber
**por que** eles funcionam sem pedir senha.

| Preparo | Como foi feito | Por quê |
|---|---|---|
| **SSH sem senha** | chave `~/.ssh/pve-lab` no Windows + alias `pve-lab` no `~/.ssh/config` | para entrar sem digitar senha a cada comando. ACL da chave restrita com `icacls /inheritance:r` |
| **Escalonamento sem senha** | `/etc/sudoers.d/tlandskron` com `NOPASSWD:ALL` | instalar pacote exige root; sem isso todo `sudo` trava pedindo senha |
| **Grupos** | usuário nos grupos `sudo` (27) e `docker` (1001) | `sudo` dá privilégio; `docker` dará acesso ao daemon quando ele existir |
| **Repositório** | clone limpo do upstream em `~/projetos/imersao-aiops-prod-01`, branch `feat/estudo-devops` | migrar sem sujeira, no espírito do M2 |
| **Máquina** | Debian 13 (trixie), kernel 6.12, 4 vCPU, 7,8 GiB RAM, 4 GiB swap, 232 GB livres, cgroup v2 | capacidade suficiente para kind + app + banco |

> **Armadilha conhecida:** o PATH do shell **root** não inclui `/usr/sbin`.
> É por isso que `usermod` e `groupadd` davam "command not found" quando
> rodados como root. A solução é usar `sudo` (cujo PATH está correto) em vez
> de `su -`.

---

## Passo 0 — Diagnóstico: o que já existe

- **Data:** 2026-10-22
- **Objetivo:** saber, antes de instalar qualquer coisa, o que a máquina já tem.

**Comando:**

```bash
for f in curl wget jq git docker kubectl kind uv node python3; do
  echo -n "$f: "
  command -v $f >/dev/null && echo "ok" || echo "AUSENTE"
done
```

**Por quê (linha a linha):**

- `for f in ...` — repete o bloco seguinte uma vez para cada nome da lista.
- `echo -n "$f: "` — imprime o nome **sem** pular linha; `-n` segura o `\n`.
- `command -v $f >/dev/null` — pergunta "existe um programa com esse nome no
  meu PATH?". Manda a resposta para o lixo (`>/dev/null`) porque o que importa
  é o **código de saída**: `0` = existe, `1` = não existe.
- `&& echo "ok" || echo "AUSENTE"` — se existiu escreve `ok`, senão `AUSENTE`.

**Saída:**

```
curl: AUSENTE
wget: AUSENTE
jq: AUSENTE
git: ok
docker: AUSENTE
kubectl: AUSENTE
kind: AUSENTE
uv: AUSENTE
node: AUSENTE
python3: AUSENTE
```

**Leitura da saída:** a máquina está **praticamente crua** — só o `git` existe.
Isso é bom: cada peça do M0 será instalada na sua frente, sem surpresa.

**Veredito:** `[OK]` — diagnóstico concluído. Lista de pendências definida.

---

## Passo 1 — Base: `ca-certificates`, `curl`, `jq`

- **Data:** 2026-10-22
- **Objetivo:** instalar as ferramentas de rede e leitura de JSON que **todo o
  resto** depende. Sem `curl` não baixa nada; sem `ca-certificates` o `curl`
  não confia em HTTPS; sem `jq` não se lê a saída de ferramentas em JSON.

**Comando:**

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl jq
```

**Por quê (linha a linha):**

- **`apt-get update`** — **não instala nada**. Baixa o **catálogo** atualizado
  dos repositórios (o que existe e em que versão). Sem isso, o `install` pode
  instalar uma versão antiga porque acha que o catálogo é o da instalação da
  máquina. Regra: **sempre** `update` antes de `install`.
- **`sudo`** — roda como `root`. Instalar pacote altera o sistema inteiro, então
  só root pode. Com o `NOPASSWD` configurado, não pede senha.
- **`apt-get install -y`** — instala. `-y` responde "sim" às perguntas.
- **`ca-certificates`** — os certificados de confiança da internet. É a
  dependência **silenciosa**: sem ele todo `curl https://...` falha com
  "certificado não confiável" e a pessoa fica horas no problema errado.
- **`curl`** — baixa arquivos por HTTP/HTTPS. É o que a documentação oficial
  do Docker usa.
- **`jq`** — lê e formata **JSON**. O Kubernetes responde em JSON; `kubectl`
  converte para humano, mas às vezes você quer o JSON cru para filtrar.
- **`wget` não foi instalado** — faz o mesmo que `curl`. É questão de gosto,
  não de certo/errado. Basta adicionar na lista se preferir.

**Saída (integral):**

```
Hit:1 http://deb.debian.org/debian trixie InRelease
Get:2 http://deb.debian.org/debian trixie-updates InRelease [47.3 kB]
Get:3 http://security.debian.org/debian-security trixie-security InRelease [43.4 kB]
Get:4 http://security.debian.org/debian-security trixie-security/main Sources [239 kB]
Get:5 http://security.debian.org/debian-security trixie-security/main amd64 Packages [269 kB]
Fetched 599 kB in 0s (1,636 kB/s)
Reading package lists... Done
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
ca-certificates is already the newest version (20250419+deb13u1).
ca-certificates set to manually installed.
The following additional packages will be installed:
  bash-completion libcurl4t64 libjq1 libonig5
The following NEW packages will be installed:
  bash-completion curl jq libcurl4t64 libjq1 libonig5
0 upgraded, 6 newly installed, 0 to remove and 0 not upgraded.
Need to get 1,417 kB of archives.
After this operation, 4,814 kB of additional disk space will be used.
Get:1 http://security.debian.org/debian-security trixie-security/main amd64 libcurl4t64 amd64 8.14.1-2+deb13u7 [392 kB]
Get:2 http://deb.debian.org/debian trixie/main amd64 bash-completion all 1:2.16.0-7 [319 kB]
Get:3 http://deb.debian.org/debian trixie/main amd64 libonig5 amd64 6.9.9-1+b1 [189 kB]
Get:4 http://security.debian.org/debian-security trixie-security/main amd64 curl amd64 8.14.1-2+deb13u7 [270 kB]
Get:5 http://security.debian.org/debian-security trixie/main amd64 libjq1 amd64 1.7.1-6+deb13u4 [168 kB]
Get:6 http://deb.debian.org/debian trixie/main amd64 jq amd64 1.7.1-6+deb13u4 [78.9 kB]
Fetched 1,417 kB in 0s (5,943 kB/s)
Selecting previously unselected package bash-completion.
(Reading database ... 31017 files and directories currently installed.)
Preparing to unpack .../0-bash-completion_1%3a2.16.0-7_all.deb ...
Unpacking bash-completion (1:2.16.0-7) ...
Selecting previously unselected package libcurl4t64:amd64.
Preparing to unpack .../1-libcurl4t64_8.14.1-2+deb13u7_amd64.deb ...
Unpacking libcurl4t64 (8.14.1-2+deb13u7) ...
Selecting previously unselected package curl.
Preparing to unpack .../2-curl_8.14.1-2+deb13u7_amd64.deb ...
Unpacking curl (8.14.1-2+deb13u7) ...
Selecting previously unselected package libonig5:amd64.
Preparing to unpack .../3-libonig5_6.9.9-1+b1_amd64.deb ...
Unpacking libonig5 (6.9.9-1+b1) ...
Selecting previously unselected package libjq1:amd64.
Preparing to unpack .../4-libjq1_1.7.1-6+deb13u4_amd64.deb ...
Unpacking libjq1 (1.7.1-6+deb13u4) ...
Selecting previously unselected package jq.
Preparing to unpack .../5-jq_1.7.1-6+deb13u4_amd64.deb ...
Unpacking jq (1.7.1-6+deb13u4) ...
Setting up libcurl4t64:amd64 (8.14.1-2+deb13u7) ...
Setting up bash-completion (1:2.16.0-7) ...
Setting up curl (8.14.1-2+deb13u7) ...
Setting up libonig5:amd64 (6.9.9-1+b1) ...
Setting up libjq1:amd64 (1.7.1-6+deb13u4) ...
Setting up jq:amd64 (1.7.1-6+deb13u4) ...
Processing triggers for libc-bin (2.41-12+deb13u4) ...
```

**Leitura da saída — as linhas que ensinam:**

| Linha | O que ela diz |
|---|---|
| `Hit:1 ... trixie InRelease` | "Hit" = o repositório **já estava** com o catálogo atual. "Get" = baixou de novo. `Fetched 599 kB` = o `update` só baixou listas, **nenhum programa**. |
| `ca-certificates is already the newest version (20250419+deb13u1)` | já existia. Instalar de novo não quebra nada — o apt é idempotente nesse ponto. |
| `The following NEW packages will be installed: bash-completion curl jq libcurl4t64 libjq1 libonig5` | pedimos 3 e o apt instalou 6. Os outros 3 são **dependências** — programas que os nossos precisam para funcionar. |
| `libcurl4t64` | `-t64` = *time64*. É a migração do Debian para contadores de tempo de 64 bits (problema do ano 2038). O `t64` no nome é só transição de empacotamento — **não é uma biblioteca diferente**. |
| `libjq1` | a biblioteca do jq. O sufixo `1` é a versão da API compartilhada (`soname`). O programa `jq` e a biblioteca `libjq1` são pacotes separados porque outros programas também usam a biblioteca. |
| `libonig5` | Oniguruma — a biblioteca de expressões regulares que o `jq` usa internamente. |
| `bash-completion` | **bônus não pedido**: completarão de Tab para comandos. Sai de graça como dependência e vai economizar muita digitação. |
| `0 upgraded, 6 newly installed` | nada foi atualizado, só adicionado. Num sistema novo é o esperado. |
| `Reading database ... 31017 files` | o banco de dados de pacotes do apt. Cada arquivo instalado é rastreado aqui — é por isso que `apt-get remove` sabe o que apagar. |
| `Processing triggers for libc-bin` | "triggers" são rotezes que rodam **depois** da instalação para o sistema se ajustar. É normal e automático. |

**Veredito:** `[NOTA]` — instalação limpa. 6 pacotes, 4.814 kB, nenhuma
atualização, nenhum erro. O `ca-certificates` já estava presente.

**Verificação (2026-10-22):**

```bash
curl --version | head -1
jq --version
```

Saída:

```
curl 8.14.1 (x86_64-pc-linux-gnu) libcurl/8.14.1 OpenSSL/3.5.7 zlib/1.3.1 brotli/1.1.0 zstd/1.5.7 libidn2/2.3.8 libpsl/0.21.2 libssh2/1.11.1 nghttp2/1.64.0 nghttp3/1.8.0 librtmp/2.3 OpenLDAP/2.6.10
jq-1.7
```

**Leitura da verificação:**

| Linha | O que ela diz |
|---|---|
| `curl 8.14.1` | a versão do binário casa com a do pacote (`8.14.1-2+deb13u7`). O resto da linha lista as bibliotecas compiladas dentro: `OpenSSL` (criptografia), `zstd`/`brotli` (compressão), `nghttp2` (HTTP/2), `OpenLDAP` (autenticação). |
| `jq-1.7` | **pegadinha registrada**: o pacote era `jq 1.7.1-6+deb13u4`, mas o binário reporta `jq-1.7`. Não é erro — o `jq` não embute o *patch* na string de versão. **Versão do pacote ≠ versão do binário**: uma mostra detalhe que a outra não mostra. |

**Veredito da verificação:** `[OK]` — ambos os binários respondem.

---

## Passo 2a — registrar o repositório oficial do Docker

- **Data:** 2026-10-22
- **Objetivo:** fazer o `apt` saber **de onde** baixar o Docker Engine. O
  Debian **não distribui** o Engine nos repositórios dele — a Docker Inc.
  mantém o repositório próprio, e a gente o registra.

**Comando:**

```bash
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

cat /etc/apt/sources.list.d/docker.list
```

**Por quê (linha a linha):**

- **`install -m 0755 -d /etc/apt/keyrings`** — cria o diretório das chaves já
  com permissão certa. `-d` = directory, `-m 0755` = modo (dono lê/escreve/
  executa, os outros leem/executam).
- **`curl -fsSL ... -o ...`** — baixa a **chave GPG**. `-f` falha silenciosamente
  em erro HTTP (em vez de salvar uma página de erro como se fosse chave),
  `-s` modo silencioso, `-S` mostra erros mesmo no silencioso, `-L` segue
  redirecionamento.
- **A chave GPG é o que garante autenticidade.** Ela assina os pacotes do
  repositório. Sem ela o `apt` recusa instalar; com ela ele consegue **provar**
  que o pacote veio mesmo da Docker Inc. e não foi adulterado no caminho.
  É a mesma lógica do cadeado no navegador.
- **`chmod a+r`** — `a` = *all*, `r` = read. Todo mundo pode ler a chave.
- **A linha `deb [arch=... signed-by=...] URL versão canal` tem formato fixo:**
  - `deb` = repositório de pacotes **binários** (existe também `deb-src`, para código-fonte);
  - `[arch=amd64]` = só para esta arquitetura, para não dar erro em outras;
  - `[signed-by=...]` = **qual chave** valida **este** repositório. É a forma
    moderna e mais segura: em vez de confiar na chave para tudo, você diz
    "essa chave vale só para essa URL";
  - a URL do repositório;
  - `trixie` = a **versão** do Debian, extraída do sistema (ver abaixo);
  - `stable` = canal. Existem também `test` e `nightly`.
- **`$(dpkg --print-architecture)`** — imprime `amd64`. `dpkg` é o gerenciador
  de pacotes de baixo nível do Debian; o `apt` é a camada amigável em cima.
- **`$(. /etc/os-release && echo "$VERSION_CODENAME")`** — o truque mais
  elegante do bloco. `.` **importa** aquele arquivo no shell atual (é um
  sinônimo de `source`), fazendo as variáveis dele virarem variáveis suas.
  O `/etc/os-release` tem `VERSION_CODENAME=trixie`, então o resultado é
  `trixie` — escrito **pelo próprio sistema**. Se a máquina um dia subir para
  o Debian 14, este comando continuaria certo sem ninguém editar nada.
- **`| sudo tee ... > /dev/null`** — o `tee` grava no arquivo **como root**
  (um `>` comum não conseguiria, porque roda como você). O `> /dev/null`
  esconde o texto que o `tee` repete na tela.
- **`cat ...`** — mostra o arquivo criado. É o seu **checkpoint**: a última
  linha deve terminar com `stable`.

> **A ideia que vale fixar:** adicionar um repositório no Debian é apenas
> **criar um arquivo de texto** em `/etc/apt/sources.list.d/`. Não existe
> "instalar repositório" mágico — é configuração pura, e é removível apagando
> o arquivo. É a mesma filosofia do `daemon.json` que vem no passo 2b.

**Saída:**

```
deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian   trixie stable
```

**Leitura da saída:**

| Trecho | O que confirma |
|---|---|
| `arch=amd64` | a expansão de `$(dpkg --print-architecture)` deu certo |
| `signed-by=/etc/apt/keyrings/docker.asc` | a chave está no caminho esperado |
| `trixie` | a expansão de `$(. /etc/os-release ...)` deu certo — puxado do próprio sistema |
| `stable` | canal correto para máquina de estudo |
| espaços duplos antes de `trixie` | sobra do `\` de continuação de linha. **Inofensivo** — o `apt` tolera espaços múltiplos entre os campos. |

**Veredito:** `[OK]` — repositório registrado, com chave assinada e versão
extraída do sistema (não digitada à mão).

---

## Passo 2b — instalar o Docker Engine

- **Data:** 2026-10-22
- **Objetivo:** instalar o daemon, o cliente, o runtime e os plugins de build e
  compose — a partir do repositório oficial registrado no 2a.

**Comando:**

```bash
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo docker version
```

**Por quê (linha a linha):**

- **`apt-get update`** — obrigatório aqui: sem ele o `apt` não saberia que o
  repositório do Docker existe. A saída confirma — aparece
  `Get:6 https://download.docker.com/linux/debian trixie InRelease`, exatamente
  a URL registrada no Passo 2a. Sem aquele arquivo, este `Get` não ocorreria.
- **Os cinco pacotes, e por que são cinco:**
  - **`docker-ce`** — o **daemon** (`dockerd`). `CE` = *Community Edition*.
  - **`docker-ce-cli`** — o comando `docker`. Pacote **separado de propósito**:
    cliente e servidor não precisam estar na mesma máquina.
  - **`containerd.io`** — o **runtime**. O Docker **não** roda containers
    diretamente: delega ao `containerd`, que usa o `runc`. Ver glossário
    *Bloco 3 — engine / daemon / runtime*.
  - **`docker-buildx-plugin`** — sistema de build novo, multiplataforma.
  - **`docker-compose-plugin`** — `docker compose` (v2) como **subcomando** do
    Docker, substituindo o antigo `docker-compose` (v1, em Python).
- **Por que não o `docker.io` do Debian?** Existe, mas atrasa várias versões e
  não traz `buildx` nem `compose`.

**Saída — trechos significativos** *(o log completo de 120 linhas está no
histórico do terminal; ficam registrados aqui os pontos que ensinam)*:

```
Get:6 https://download.docker.com/linux/debian trixie InRelease [32.5 kB]
Get:7 https://download.docker.com/linux/debian trixie/stable amd64 Packages [51.5 kB]

The following additional packages will be installed:
  docker-ce-rootless-extras iptables libip4tc2 libip6tc2 libnetfilter-conntrack3 libnfnetlink0 pigz xz-utils
The following NEW packages will be installed:
  containerd.io docker-buildx-plugin docker-ce docker-ce-cli docker-ce-rootless-extras
  docker-compose-plugin iptables libip4tc2 libip6tc2 libnetfilter-conntrack3 libnfnetlink0 pigz xz-utils
0 upgraded, 13 newly installed, 0 to remove and 0 not upgraded.
Need to get 103 MB of archives.
After this operation, 392 MB of additional disk space will be used.

Get:10 https://download.docker.com/linux/debian/stable amd64 docker-ce amd64 5:29.9.2-1~debian.13~trixie [24.5 MB]
...
update-alternatives: using /usr/sbin/iptables-legacy to provide /usr/sbin/iptables (iptables) in auto mode
update-alternatives: using /usr/sbin/iptables-nft to provide /usr/sbin/iptables (iptables) in auto mode

Created symlink '/etc/systemd/system/multi-user.target.wants/containerd.service' → '/usr/lib/systemd/system/containerd.service'.
Created symlink '/etc/systemd/system/multi-user.target.wants/docker.service' → '/usr/lib/systemd/system/docker.service'.
Created symlink '/etc/systemd/system/sockets.target.wants/docker.socket' → '/usr/lib/systemd/system/docker.socket'.
```

Saída do `sudo docker version`:

```
Client: Docker Engine - Community
 Version:           29.9.2
 API version:       1.56
 Go version:        go1.26.10
 Git commit:        a82e528
 Built:             Tue Oct 20 18:45:13 2026
 OS/Arch:           linux/amd64
 Context:           default

Server: Docker Engine - Community
 Engine:
  Version:          29.9.2
  API version:      1.56 (minimum version 1.40)
  Go version:       go1.26.10
  Git commit:       0367cbe
  Built:            Tue Oct 20 18:45:13 2026
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          v2.4.2
  GitCommit:        b7a25261e029d68978bbf290df0a62fc819b3c51
 runc:
  Version:          1.5.2
  GitCommit:        v1.5.2-0-g29dd3dc2
 docker-init:
  Version:          0.19.0
  GitCommit:        de40ad0
```

**Leitura da saída:**

| Linha | O que ela diz |
|---|---|
| `Get:6 ... download.docker.com/linux/debian` | o repositório do Passo 2a **funcionou** — é a mesma URL. |
| `docker-ce-rootless-extras` (não pedido) | suporte a rodar Docker **sem root**. Vem como dependência, não fica ativado. |
| `iptables` + `libip4tc2` + `libnetfilter-conntrack3` + `libnfnetlink0` | o **firewall** do Linux. O Docker cria redes virtuais e faz NAT — sem `iptables` não existe rede de container. É a base do M8. |
| `pigz` | *parallel gzip* — descompressão de imagens usando todos os 4 núcleos, ~4× mais rápido que o `gzip`. |
| `update-alternatives: using iptables-legacy ... iptables-nft` | o Debian traz **dois** backends de firewall (legado e `nftables`). O `update-alternatives` escolhe um e cria links simbólicos. **Compatibilidade, não erro.** |
| `Created symlink .../docker.service` | assim o systemd **habilita um serviço no boot**: link simbólico dentro de uma pasta `wants`. Habilitar = criar link. Desabilitar = apagar. |
| `docker.socket` | **ativação por socket** — o systemd escuta a porta e só então sobe o Docker. Economiza RAM parada. |
| `docker-init: 0.19.0` | o `tini`: processo **init** que recolhe processos zumbi. É o problema do *PID 1* do glossário (Bloco 3). Vem embutido. |
| `API version: 1.56 (minimum version: 1.40)` | cliente e servidor conversam por **API versionada**, com negociação automática de compatibilidade. |
| `Context: default` | contexts do Docker: alternar o mesmo comando para um daemon local ou remoto. |
| `Live` ausente do `docker version` | `docker version` mostra o que existe; `docker info` mostra **como está configurado**. São comandos diferentes — confundir os dois é comum. |

**Veredito:** `[OK]` — 13 pacotes, 103 MB baixados, 392 MB em disco. Cliente e
servidor na mesma versão (29.9.2), runtime `containerd` 2.4.2 e `runc` 1.5.2.

---

## Passo 2c — configurar o daemon (`daemon.json`)

- **Data:** 2026-10-22
- **Objetivo:** dois ajustes feitos **antes** de existir qualquer coisa a
  perder: containers sobrevivem a reinício do daemon, e logs rodam.

**Comando:**

```bash
sudo tee /etc/docker/daemon.json > /dev/null <<'EOF'
{
  "live-restore": true,
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF

sudo jq . /etc/docker/daemon.json
sudo systemctl restart docker
sudo docker info | grep -iE 'server version|live restore|logging driver'
```

**Por quê (linha a linha):**

- **`"live-restore": true`** — por padrão, quando o daemon do Docker
  **reinicia** (atualização, reboot, crash), ele **mata todos os containers**.
  Com `live-restore`, os containers continuam vivos através da reinicialização
  do daemon. É a diferença entre "o Docker reiniciou" e "o serviço caiu junto".
- **`log-opts` (`max-size: 10m`, `max-file: 3`)** — sem isto, o log de cada
  container cresce **sem limite** e enche o disco. Com isto, cada container
  guarda no máximo 3 × 10 MB e os antigos são apagados. É **rotação de logs**,
  obrigatória em qualquer máquina que precise durar meses.
- **`<<'EOF'`** — o delimitador está **entre aspas simples**. Isso diz ao
  shell "não interprete nada dentro deste bloco". Sem aspas, o shell tentaria
  expandir `$` e backticks **dentro do JSON** e o quebraria. Regra: para
  conteúdo literal via heredoc, **sempre quote o delimitador**.
- **`sudo jq . ...`** — valida que o JSON está **sintaticamente correto**
  **antes** de reiniciar o daemon. Se o `jq` reclamar de vírgula ou chave, o
  arquivo tem erro — e você evita reiniciar com configuração quebrada.
  (Uso direto do `jq` instalado no Passo 1.)
- **`systemctl restart docker`** — reinicia o serviço. Feito **agora**, com
  nenhum container no ar, o comando é gratuito. Em produção, seria um incidente.
- **`docker info | grep -iE`** — confirma as três coisas. `docker info` mostra
  **como o daemon está configurado** — ao contrário de `docker version`, que
  mostra **o que existe**. `-i` ignora maiúsculas; `-E` aceita expressão regular.

**Saída:**

```
{
  "live-restore": true,
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
 Server Version: 29.9.2
 Logging Driver: json-file
 Live Restore Enabled: true
```

**Leitura da saída:**

| Linha | O que ela confirma |
|---|---|
| o `jq` imprimiu o JSON de volta | o arquivo está **sintaticamente válido**. Ele reformatou conforme já estava — não houve o que corrigir. |
| `systemctl restart` sem saída | **silêncio = sucesso** no systemd. Se houvesse erro, apareceria antes do próximo prompt. |
| `Server Version: 29.9.2` | o daemon reiniciou e voltou. |
| `Logging Driver: json-file` | driver de log ativo. |
| `Live Restore Enabled: true` | **o ajuste pegou.** É a confirmação que importa. |

**Veredito:** `[OK]` — daemon configurado, validado antes do restart, três
confirmações na saída.

---

## Passo 2d — relogin e o primeiro container

- **Data:** 2026-10-22
- **Objetivo:** ativar o grupo `docker` da sessão e provar que o caminho
  completo **cliente → daemon → imagem → container → saída** funciona.

**Comando — Parte 1 (sair e entrar de novo):**

```bash
exit
```

No **PowerShell do Windows** (fora do `pve-lab`):

```bash
ssh pve-lab
```

**Por quê:** quando você conecta por SSH, o sistema monta a sessão lendo o
`/etc/group` **naquele instante**. A sessão anterior nasceu **antes** de o
Docker existir, então não carregava o grupo `docker` — mesmo que o arquivo
dissese que o usuário era membro. Não é falha de ninguém: é assim que Unix
atribui credenciais, e é por isso que todo manual de Docker diz
*"log out and log back in"*.

**Comando — Parte 2 (o teste):**

```bash
id -nG
docker run --rm hello-world
```

- **`id -nG`** — *identity, names, groups*. Grupos da **sessão atual**, em
  nomes (não números). Espera-se `docker` na lista.
- **`docker run --rm hello-world`** — o teste canônico:
  - `run` — cria um **container** de uma imagem e o executa;
  - `--rm` — **apaga o container assim que ele termina**. Sem isso ele fica
    parado como `exited` e exige `docker rm` depois. Comportamento correto
    para teste pontual;
  - `hello-world` — imagem mínima da Docker Hub que só imprime e sai.
- Este comando **também testa a rede e o registry**: a imagem vem de
  `registry-1.docker.io`. Timeout ou erro de TLS aqui seria problema de rede,
  não do Docker.

**Saída — `id -nG`:**

```
tlandskron cdrom floppy sudo audio dip video plugdev users netdev docker
```

**Saída — `docker run --rm hello-world`:**

```
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
4f55086f7dd0: Pull complete
d5e71e642bf5: Download complete
Digest: sha256:11a3eb1597e864c51b3f56733cb2e8a90bf0c284bfc05f9444d81c558bc848aa
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.
```

**Leitura da saída:**

| Linha | O que ela diz |
|---|---|
| `... users netdev docker` | o grupo `docker` entrou na sessão. O relogin funcionou. |
| `docker run` **sem `sudo`** | é a consequência direta da linha acima. Sem o relogin, apareceria `permission denied on /var/run/docker.sock`. |
| `Unable to find image 'hello-world:latest' locally` | o daemon **procurou primeiro na máquina**. Não achou, então foi buscar. É assim que o `run` decide puxar ou não. |
| `latest: Pulling from library/hello-world` | `library/` = imagem **oficial** (sem prefixo de usuário). `latest` = tag padrão — e o glossário diz: **`:latest` em produção é proibido**, porque ninguém sabe o que tem dentro. |
| `4f55086f7dd0: Pull complete` | **camadas**. A imagem é feita de camadas empilhadas, cada uma com hash próprio. Aqui são duas. Camadas são compartilhadas entre imagens — é o que faz o Docker leve. |
| `Digest: sha256:11a3eb15...` | o **digest** imutável (glossário, Bloco 3). A tag `latest` pode mudar de lugar; o digest **nunca**. É a prova de imutabilidade. |
| `(amd64)` | a plataforma. A mesma tag serve para várias arquiteturas; o daemon baixa a certa. |
| passos 1 a 4 | o ciclo inteiro do Docker em quatro frases: **cliente → daemon → imagem → container → saída**. É a estrutura mental de todo módulo de containers. |

**Veredito:** `[OK]` — M0 · Docker concluído. Grupo ativo, rede e registry
alcançáveis, camada `live-restore` operante.

---

## Passo 3a — instalar o `kubectl`

- **Data:** 2026-10-22
- **Objetivo:** ter o cliente que fala com a API do cluster. Versão **1.37**,
  a estável atual (patch 1.37.1, de 15/09/2026).

**Comando** — *mesmo molde do Passo 2a: chave em `/etc/apt/keyrings`, arquivo
`.list` em `/etc/apt/sources.list.d`, `signed-by=` apontando para a chave.
Depois de duas repetições, o padrão já é reconhecimento, não leitura:*

```bash
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.37/deb/Release.key -o /etc/apt/keyrings/kubernetes-apt-keyring.asc
sudo chmod a+r /etc/apt/keyrings/kubernetes-apt-keyring.asc

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.asc] https://pkgs.k8s.io/core:/stable:/v1.37/deb/ /" | \
  sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubectl

kubectl version --client
```

**Por quê (diferenças em relação ao Docker):**

- **`pkgs.k8s.io`** — repositório **oficial atual**. O antigo `apt.kubernetes.io`
  (Google) foi **descontinuado** quando o Kubernetes passou à governança da
  CNCF. Tutoriais antigos apontam para a URL errada — distinguir *história*
  de *procedimento* é parte do ofício.
- **`core:/stable:/v1.37/deb/`** — os `:/` são o formato do OBS (*Open Build
  Service*), que hospeda os pacotes. Estranho, mas é assim.
- **A versão está no URL de propósito.** O repositório é **por versão menor**,
  porque o `kubectl` precisa conversar com um cluster compatível. A **skew
  policy** do Kubernetes permite diferença de **no máximo 1 versão menor**
  entre cliente e servidor — nunca dois.
- **`kubectl version --client`** — testa o cliente **sem tentar falar com
  cluster nenhum**. Sem `--client`, ele tentaria conectar no servidor e
  reclamaria (ainda não existe cluster).
- **`kubectl` não precisa de `sudo`.** Ao contrário do Docker, que fala com um
  socket local de permissão restrita, o `kubectl` fala com o **API server**
  usando `~/.kube/config`, que pertence ao usuário.

**Saída:**

```
Get:5 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.37/deb  InRelease [1,227 B]
Get:6 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.37/deb  Packages [4,384 B]
Fetched 5,611 B in 1s (8,593 B/s)
The following NEW packages will be installed:
  kubectl
Need to get 12.1 MB of archives.
After this operation, 61.9 MB of additional disk space will be used.
Get:1 https://prod-cdn.packages.k8s.io/... kubectl 1.37.1-1.1 [12.1 MB]
Setting up kubectl (1.37.1-1.1) ...
Client Version: v1.37.1
Kustomize Version: v5.8.1
```

**Leitura da saída:**

| Linha | O que ela diz |
|---|---|
| `prod-cdn.packages.k8s.io` | a URL digitada redirecionou para um **CDN**. Infraestrutura bem feita se apresenta de forma invisível. |
| `Packages [4,384 B]` | catálogo de **4 kB**, contra **269 kB** do Debian. Por quê? Este repositório serve **um único pacote**. Repositório por versão menor = catálogo minúsculo. |
| `Hit:4 https://download.docker.com/linux/debian` | o repositório do Docker do Passo 2a já faz parte do fluxo normal do `apt`. Continuidade visível. |
| `Kustomize Version: v5.8.1` | o `kubectl` traz o **kustomize** embutido — alternativa nativa ao Helm (glossário, Bloco 4), personaliza manifests sem templates. |

**Veredito:** `[OK]` — cliente 1.37.1 instalado, mesma *minor* do cluster que
viria a ser criado no 3c.

---

## Passo 3b — instalar o `kind`

- **Data:** 2026-10-22
- **Objetivo:** ter o gerador de cluster **local**, onde nós somos o
  provedor de nuvem.

**Comando:**

```bash
VER=$(curl -fsSL https://api.github.com/repos/kubernetes-sigs/kind/releases/latest | jq -r .tag_name)
echo "kind $VER"
curl -fsSL -o /tmp/kind "https://kind.sigs.k8s.io/dl/${VER}/kind-linux-amd64"
sudo install -m 0755 /tmp/kind /usr/local/bin/kind
kind version
```

**Por quê:**

- **`VER=$(...)`** — o `$(...)` pega **o que o comando imprime** e usa como
  texto. Aqui, guarda a versão na variável `VER`.
  > **Chamada de atenção:** idêntico ao que aconteceu no início da sessão,
  > quando o PowerShell avaliou `$(...)` **localmente** em vez de mandar para
  > o `pve-lab`. Mesmo conceito, **host diferente** muda quem interpreta.
- **`jq -r .tag_name`** — `-r` = *raw*, imprime sem aspas do JSON; `.tag_name`
  = o campo. O JSON do GitHub é enorme e você quer **uma informação** dele.
  Primeiro uso prático do `jq` do Passo 1.
- **`kind.sigs.k8s.io/dl/...`** — URL curta oficial que redireciona para o
  GitHub Releases. Menos sujeita a erro de digitação que montar à mão.
- **`/usr/local/bin`** — binários **instalados manualmente**, fora do controle
  do gerenciador de pacotes. Regra importante:
  - `/usr/bin` → o **apt** manda ali;
  - `/usr/local/bin` → **você** manda ali.
  É por isso que o `kind` não veio de `apt`: não está nos repositórios.
- **`install -m 0755`** — instala com permissão de execução. Um `cp` puro
  deixaria sem `x` e o shell recusaria rodar.

**Saída:**

```
kind v0.33.0
kind v0.33.0 go1.26.7 linux/amd64
```

**Veredito:** `[OK]` — `kind` v0.33.0 em `/usr/local/bin`.

---

## Passo 3c — criar o cluster

- **Data:** 2026-10-22
- **Objetivo:** a máquina deixa de ser uma máquina e passa a ser um cluster.

**Comando:**

```bash
kind create cluster --name aiops-lab
kubectl get nodes
kubectl cluster-info
```

**Saída do `create cluster`:**

```
Creating cluster "aiops-lab" ...
 ✓ Ensuring node image (kindest/node:v1.37.0) 🖼️
 ✓ Preparing nodes 📦
 ✓ Writing configuration 📜
 ✓ Starting control-plane 🕹️
 ✓ Installing CNI 🔌
 ✓ Installing StorageClass 💾
Set kubectl context to "kind-aiops-lab"
```

**Leitura — os seis checkmarks:**

| Etapa | O que fez |
|---|---|
| `Ensuring node image (kindest/node:v1.37.0)` | baixou ~1 GB. A versão **1.37.0** casa com o `kubectl` 1.37.1 — compatibilidade garantida pela regra de skew. |
| `Preparing nodes` | criou o **container** que será o nó |
| `Writing configuration` | gerou os manifests do control plane e o `~/.kube/config` |
| `Starting control-plane` | subiu os quatro componentes do plano de controle |
| `Installing CNI` | instalou o plugin de rede (`kindnet`). Sem ele, **pods não têm IP**. |
| `Installing StorageClass` | storage padrão. Sem ele, `PersistentVolume` não funciona. |
| `Set kubectl context to "kind-aiops-lab"` | definiu o **contexto atual**. Glossário, Bloco 4: *contexto errado é como apagar produção achando que é homologação*. |

**Saída — primeiro `kubectl get nodes` (8 segundos depois):**

```
NAME                      STATUS     ROLES           AGE   VERSION
aiops-lab-control-plane   NotReady   control-plane   8s    v1.37.0
Kubernetes control plane is running at https://127.0.0.1:35241
```

**`NotReady` aos 8 segundos NÃO é erro.** O `kubectl` perguntou ao API server,
que respondeu com o que o **kubelet** lhe contara por último — e o kubelet
ainda não tinha terminado de subir o CNI nem reportado a condição `Ready`.
Estava-se vendo **estado real ainda convergindo para o estado desejado**:
reconciliação, em ação (glossário, Bloco 4).

**Saída — o mesmo comando, minutos depois:**

```
NAME                      STATUS   ROLES           AGE     VERSION
aiops-lab-control-plane   Ready    control-plane   5m53s   v1.37.0
```

O `-w` (*watch*) mostrou a transição. **Tempo até `Ready`: cerca de 6 minutos**
— normal numa primeira subida, quando o `kindest/node` ainda está sendo
extraído e o containerd aquecido.

**Saída — `kubectl get nodes -o wide`:**

```
NAME                      STATUS   ROLES           AGE     VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                       KERNEL-VERSION                 CONTAINER-RUNTIME
aiops-lab-control-plane   Ready    control-plane   6m27s   v1.37.0   172.18.0.2    <none>        Debian GNU/Linux 13 (trixie)   6.12.113+deb13-amd64 (amd64)   containerd://2.3.4
```

| Campo | O que ele diz |
|---|---|
| `INTERNAL-IP 172.18.0.2` | o IP vem da **bridge network** que o Docker criou. O cluster inteiro mora dentro da rede virtual do Docker. |
| `EXTERNAL-IP <none>` | **não há balanceador externo.** É por isso que o M4 ensina `NodePort` e `port-forward`: é assim que se alcança algo sem balanceador de nuvem. |
| `OS-IMAGE Debian GNU/Linux 13 (trixie)` | o node image é Debian 13 — **mesma distribuição do host**. Coincidência do `kind`, não do projeto. |
| `CONTAINER-RUNTIME containerd://2.3.4` | **atenção:** o host tem `containerd.io` **2.4.2**; o nó reporta **2.3.4**. São **dois containerds**, um dentro do outro. O `kindest/node` é um container que traz **o Kubernetes inteiro embutido**, inclusive o runtime. É isso que torna o `kind` leve e descartável. |
| o comando digitado foi `-o widede` | o `kubectl` aceitou mesmo com o erro de digitação — a correspondência de formatos de saída é tolerante. **Não conte com isso**: escreva `-o wide`. |

**Saída — `kubectl get pods -A`:**

```
NAMESPACE            NAME                                              READY   STATUS    RESTARTS   AGE
kube-system          coredns-559f6c778d-l6gqr                          1/1     Running   0          6m18s
kube-system          coredns-559f6c778d-r4d9h                          1/1     Running   0          6m18s
kube-system          etcd-aiops-lab-control-plane                      1/1     Running   0          6m25s
kube-system          kindnet-jtglk                                     1/1     Running   0          6m18s
kube-system          kube-apiserver-aiops-lab-control-plane            1/1     Running   0          6m25s
kube-system          kube-controller-manager-aiops-lab-control-plane   1/1     Running   0          6m25s
kube-system          kube-proxy-qxlz2                                  1/1     Running   0          6m18s
kube-system          kube-scheduler-aiops-lab-control-plane            1/1     Running   0          6m25s
local-path-storage   local-path-provisioner-75f7fc7dc5-54gtz           1/1     Running   0          6m18s
```

**Isto é o glossário virando lista de pods** — cada linha é um verbete do
Bloco 4:

| Pod | Verbete correspondente |
|---|---|
| `kube-apiserver` | **API server** — a porta única de entrada do cluster |
| `etcd` | **etcd** — o banco que guarda o estado |
| `kube-scheduler` | **scheduler** — decide em qual nó cada pod roda |
| `kube-controller-manager` | **controller-manager** — dono da reconciliação |
| `kindnet` | **CNI** — o plugin de rede dos pods |
| `kube-proxy` | **Service** — as regras de rede dos `ClusterIP` |
| `coredns` (×2) | **DNS interno** — resolve `postgres:5432` dentro do cluster |
| `local-path-provisioner` | implementa o `StorageClass`; está em namespace **próprio**, fora do `kube-system` |

**Leituras adicionais:**

- Todos os do `kube-system` estão em **`kube-system`** — o namespace onde
  vive o próprio Kubernetes. Você não mexe lá (glossário, Bloco 4).
- **Dois** `coredns`, mesmo num cluster de **um** nó: o Kubernetes já sobe o
  DNS em **HA** por padrão. Replicação não depende de número de nós.
- **`1/1`** em toda coluna READY: *quanto está pronto / quanto existe*. Estado
  desejado igual a estado real, em todas as linhas.
- **`RESTARTS 0`** — sinal de saúde. Se aparecer 3 ou mais, algo está
  reiniciando o container e é investigação, não normalidade.

**Veredito:** `[OK]` — **M0 · Kubernetes concluído.** Cluster `aiops-lab` no ar,
nó `Ready`, 9 pods `Running`, contexto definido.

---

## Passo 4a — `uv` (Python)

- **Data:** 2026-10-22
- **Objetivo:** instalar o gerenciador de Python do projeto. O repositório tem
  cinco `pyproject.toml` + `.python-version`, todos gerenciáveis por `uv`.
- **Versão obtida:** `uv 0.13.5`

**Comando** *(deliberadamente em 3 passos, não `curl | sh`):*

```bash
curl -LsSf https://astral.sh/uv/install.sh -o /tmp/uv-install.sh
wc -l /tmp/uv-install.sh
head -12 /tmp/uv-install.sh
sh /tmp/uv-install.sh

export PATH="$HOME/.local/bin:$PATH"
uv --version
```

**Por quê:**

- **Sobre o `curl | sh`:** padrão oficial e comum, **e hábito ruim**. Ele baixa
  e executa sem que se veja o conteúdo. Aqui: baixou, mostrou tamanho (2191
  linhas) e as primeiras 12, **e só então** executou. Não é paranoia —
  é o princípio do glossário, Bloco 8: *superfície de ataque*. Script não lido
  é superfície de ataque.
- **`export PATH=...`** — necessário só para a **sessão atual**; para as
  próximas, o instalador já cuidou (ver nota abaixo).
- **`uv`** — escrito em Rust, pela Astral (mesma equipe do `ruff`). Substitui
  `pip` + `venv` + `pyenv` + `poetry` numa ferramenta só.

**Saída:**

```
2191 /tmp/uv-install.sh
#!/bin/sh
# shellcheck shell=dash
...
downloading uv 0.13.5 x86_64-unknown-linux-gnu
installing to /home/tlandskron/.local/bin
  uv
  uvx
everything's installed!
uv 0.13.5 (x86_64-unknown-linux-gnu)
```

**Nota de persistência (verificada, não presumida):**

```
bash -lc 'command -v uv'   ->   /home/tlandskron/.local/bin/uv   (ENCONTRADO)
.bashrc  linha 115: . "$HOME/.local/bin/env"
.profile linhas 25-26: if [ -d "$HOME/.local/bin" ] ; then PATH="$HOME/.local/bin:$PATH"
```

> **Armadilha registrada:** um teste meu com `ssh host "bash script.sh"` mostrou
> `uv: AUSENTE` e quase gera um alarme falso. A causa foi o **tipo de shell**,
> não o sistema:
>
> | Shell | Lê `.profile`? | Lê `.bashrc`? | Quando |
> |---|---|---|---|
> | login interativo | ✅ | ✅ | você digita `ssh pve-lab` |
> | interativo não-login | ❌ | ✅ | outro terminal na mesma sessão |
> | **não-interativo** | ❌ | ❌ | `ssh host "cmd"`, `cron`, systemd |
>
> É a origem clássica de *"funciona na mão, não funciona no cron"*: o ambiente
> montado no `.bashrc` **não existe** no shell do agendador. É um problema de
> **contexto** — mesma família do `kubectl` que aponta para o cluster errado.
>
> E o snippet criado pelo instalador é **idempotente**: checa o `PATH` antes de
> adicionar (`case ":${PATH}:" ...`), então rodar 10 vezes = rodar 1. Glossário,
> Bloco 5, rodando dentro do `PATH`.

**Veredito:** `[OK]` — `uv 0.13.5` instalado e persistente.

---

## Passo 4b — Node 24 (com erro e correção)

- **Data:** 2026-10-22
- **Objetivo:** Node **24**, porque é o que o projeto usa — comprovado por
  evidência, não por palpite:

  ```
  ./kube-news/src/Dockerfile:1:     FROM node:24-alpine
  ./kube-news/src/Dockerfile.dev:1: FROM node:24-alpine
  ```

### Tentativa 1 — FALHOU → ver **Err01**

```bash
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_24.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
sudo apt-get update
sudo apt-get install -y nodejs
node --version
npm --version
```

Resultado: `v20.19.2` (errado) e `npm: command not found`. **Causa e correção
registradas em [Err01](#err01--faltou-gnupg--repo-sem-assinatura--node-errado).**

### Tentativa 2 — CORRIGIDA

```bash
sudo apt-get install -y gnupg

curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key -o /tmp/nodesource.key
cat /tmp/nodesource.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
ls -la /etc/apt/keyrings/nodesource.gpg

sudo apt-get update
apt policy nodejs

sudo apt-get install -y nodejs
node --version
npm --version
```

**Por quê (diferenças do molde em relação ao Docker/k8s):**

- **`gpg --dearmor`** — converte chave ASCII (`.asc`) em keyring binário (`.gpg`).
  Docker e Kubernetes usam `.asc` direto; NodeSource usa `.gpg`. **O `apt`
  aceita os dois** — o `signed-by=` aponta para o arquivo que existir.
- **`cat ... | gpg --dearmor`** — sintaxe que funciona em qualquer versão de
  `gpg`, lendo do início.
- **`ls -la .../nodesource.gpg`** — **checkpoint**. É exatamente o arquivo cuja
  ausência causou o Err01. Verificar **antes** do `apt-get update` evita a
  cascata inteira.
- **`apt policy nodejs`** — o comando mais importante da correção: mostra
  **todas as fontes** e **qual candidato o `apt` escolheria**, antes de instalar.
- **`nodistro`** — a "versão" no repositório é fixa. É proposital: faz um
  **único** repositório servir Debian e Ubuntu qualquer versão. É por isso que
  não aparece `trixie` aqui como apareceu no Docker.

**Saída-chave do `apt policy nodejs`:**

```
nodejs:
  Installed: 20.19.2+dfsg-1+deb13u3
  Candidate: 24.22.1-1nodesource1        <-- o que sera instalado
  Version table:
     24.22.1-1nodesource1 500
        500 https://deb.nodesource.com/node_24.x nodistro/main amd64 Packages
     ...
 *** 20.19.2+dfsg-1+deb13u3 500
        500 http://security.debian.org/debian-security trixie-security/main amd64 Packages
```

**Leitura:** duas fontes, **mesma prioridade 500**, e o `apt` escolhe a **versão
mais alta**: 24 > 20. A linha `Candidate` é a resposta — **ler ela antes de
instalar** evita o Err01 inteiro.

**Efeito colateral observado na instalação:**

```
The following packages will be REMOVED:
  libnode115 node-acorn node-corepack nodejs-doc
The following NEW packages will be installed:
  libpython3-stdlib libpython3.13-minimal ... python3 python3.13 ...
```

- **REMOVIDOS** — os pacotes do Node **20** do Debian, substituídos pelos do 24.
  `dpkg` avisou `dependency problems, but removing anyway`: dependências
  quebradas de propósito, na troca de versão maior. Comportamento esperado.
- **`python3` entrou sem pedido** — comprovado por
  `apt-cache depends nodejs` → **`Depends: python3`**. O pacote `nodejs` do
  NodeSource **declara** Python como dependência, porque o `node-gyp` (compila
  módulos nativos, tipo `bcrypt`) é escrito em Python. Não foi coincidência.

**Saída final:**

```
v24.22.1
11.19.1
```

**Veredito:** `[OK]` — Node **24.22.1** (o que o projeto pede) e npm 11.19.1.

---

## Passo 5 — subir o laboratório

- **Data:** 2026-10-22
- **Objetivo:** o `aiops-lab.sh up` — cluster, cenários de falha, banco,
  migrations, MCP server e aplicação, numa sequência só.

### 5a — corrigir o nome do cluster (erro do Passo 3c, meu)

O script espera o cluster **`aiops`**:

```
aiops-lab.sh:19:   CLUSTER="${CLUSTER:-aiops}"
AMBIENTE.md:208:   "Os testes kind e e2e exigem o cluster aiops"
README.md:117:     kind create cluster --name aiops
```

No Passo 3c eu mandei criar `--name aiops-lab`. Rodar o script assim criaria um
**segundo cluster** (RAM dobrada, contexto do `kubectl` ambíguo). Como o
`kind` não tem "rename", apagou-se e deixou o script recriar — a imagem já
estava em cache.

```bash
kind get clusters
kind delete cluster --name aiops-lab
kind get clusters
```

Saída:

```
aiops-lab
Deleting cluster "aiops-lab" ...
Deleted nodes: ["aiops-lab-control-plane"]
No kind clusters found.
```

**Veredito 5a:** `[OK]` — lista vazia. Cluster zerado, nome canônico garantido.

### 5b — `.env` + dependências

```bash
cd ~/projetos/imersao-aiops-prod-01/boilerplate-k8s-aiops
cp .env.example .env
grep -n 'ANTHROPIC_API_KEY' .env
uv sync
```

> ⚠️ **Regra 1:** o `ANTHROPIC_API_KEY` **não foi preenchido**. Ficou o
> placeholder do `.env.example`.

**Saída do `uv sync`:**

```
Using CPython 3.13.5 interpreter at: /usr/bin/python3
Creating virtual environment at: .venv
Resolved 110 packages in 1ms
Built my-agent-app @ file:///.../boilerplate-k8s-aiops
Prepared 108 packages in 942ms
Installed 108 packages in 30ms
 + fastapi==0.139.2
 + langchain==1.3.14
 + langchain-anthropic==1.5.0
 + anthropic==0.117.1
 + sqlalchemy==2.0.51
 + alembic==1.18.5
 + uvicorn==0.51.0
 ... (108 no total)
```

**Leitura:**

| Linha | O que ela diz |
|---|---|
| `Using CPython 3.13.5 at /usr/bin/python3` | o `uv` usou o **Python do sistema** — que aliás entrou como dependência do `nodejs` (Err01/4b). Duas decisões aparentemente separadas se encontrando. |
| `Resolved 110 packages in 1ms` | o `uv.lock` (644 KB) **trava as versões**. Resolver levou 1 ms porque não há nada a decidir. Sem lock, seria rede e tentativa. |
| `Installed 108 packages in 30ms` | 108 pacotes em **30 ms**. É o `uv` sendo escrito em Rust — `pip` levaria minutos aqui. |
| `anthropic==0.117.1` | o SDK da Anthropic foi instalado. **Instalar ≠ usar**: é só uma biblioteca no disco, não consome API nem gasta nada. |
| `.venv` criado | ambiente virtual isolado. Nada disso vazou para o `python3` do sistema. |

**Veredito 5b:** `[OK]` — 108 pacotes, versões travadas, sem chave de API.

### 5c — `./aiops-lab.sh up`

**Sequência executada** (cada etapa só roda se a anterior deu certo — `&&`):

```
==> criando cluster kind 'aiops'
 ✓ Waiting ≤ 3m0s for control-plane = Ready ⏳
 • Ready after 16s 💚
  OK contexto: kind-aiops
namespace/teste-a created
namespace/teste-b created
==> aplicando cenarios de falha (nginx com imagem inexistente, kube-news com senha errada)
  OK cenarios aplicados em teste-a e teste-b
==> subindo PostgreSQL + pgAdmin
 ✔ Image postgres:17                          Pulled    11.2s
 ✔ Image dpage/pgadmin4:latest                Pulled    11.2s
 ✔ Container boilerplate-k8s-aiops-postgres-1 Started    1.3s
 ✔ Container boilerplate-k8s-aiops-pgadmin-1  Started    0.5s
  OK PostgreSQL pronto
==> aplicando migrations (alembic)
  OK migrations aplicadas
==> subindo MCP Server Kubernetes (npx, transporte HTTP)
  OK MCP Server respondendo (tentativa 7)
==> subindo a aplicacao do agente AIOps
  OK aplicacao no ar (tentativa 3)
```

**Estado final reportado pelo `status`:**

```
── Docker ──
  daemon: active
  boilerplate-k8s-aiops-pgadmin-1     Up 26 seconds
  boilerplate-k8s-aiops-postgres-1    Up 26 seconds
  aiops-control-plane                 Up About a minute

── Kubernetes (kind) ──
  cluster: aiops
  kube-system  (8 pods)          1/1 Running
  local-path-storage (1 pod)     1/1 Running
  teste-a      nginx-...         0/1 ErrImagePull     <-- DELIBERADO
  teste-b      kubenews-... x10  9x Error, 1x Running <-- DELIBERADO
  teste-b      postgre-...       1/1 Running

── Servicos ──
  MCP   :3001/mcp  -> no ar (HTTP 405)
  App   :8000/api/health -> 200

── Relatorios (PostgreSQL) ──
     status   | severity | namespace | title
  ------------+----------+-----------+-------
   INCOMPLETO |          |           |
```

**Leitura — o que é esperado e o que é erro:**

| Linha | Veredito |
|---|---|
| `Ready after 16s` | cluster recriado em 16 s (imagem em cache) — contra ~6 min na primeira vez. |
| `teste-a nginx 0/1 ErrImagePull` | **CENÁRIO DELIBERADO**, não erro. A causa: `Failed to pull image "ngin:latest"` — repare no **typo: `ngin`**, sem o `x`. É a "imagem inexistente" que o agente vai ter que diagnosticar. |
| `teste-b kubenews 9× Error, 1× Running` | **CENÁRIO DELIBERADO**: "senha errada". Os 9 falham ao autenticar; 1 está `Running`. |
| `MCP -> no ar (HTTP 405)` | **não é erro.** O endpoint MCP exige `POST`/JSON-RPC; `GET` responde `405 Method Not Allowed`. O próprio script trata 405 como "no ar" (comentário na linha 129 do script). |
| `App -> 200` | `/api/health` respondendo. |
| `INCOMPLETO` no relatório | **exatamente o que `main.py:60` previu** sem a `ANTHROPIC_API_KEY`: *"o relatorio ficara INCOMPLETO"*. A predição do código se cumpriu — degradação graciosa em ação. |
| os `Warning` de bootstrap | **históricos, não atuais.** Ver nota abaixo. |

> **Nota essencial — evento não é estado:** a seção *Eventos Warning* mostra
> `FailedScheduling ... untolerated taint`, `NodeNotReady`, `Readiness probe
> failed ... connection refused` — todos com `53s` a `59s`. São da **janela de
> bootstrap do cluster**, já resolvidos: o nó ficou `Ready after 16s` e hoje
> todos os pods de `kube-system` estão `1/1 Running`. `kubectl get events`
> mostra **histórico**, não o presente. Distinguir *evento transitório* de
> *falha real* é **exatamente o problema central do AIOps** — e o
> `relatorio.md` do próprio projeto já debate isso: *"pode ter sido temporário
> durante o bootstrap... ou um evento fantasma já resolvido"*. Glossário,
> Bloco 7: *evento × log*, e Bloco 9: *incidente × problema*.

**Verificação da Regra 1 no `.env`:**

```
valor no .env        : e o PLACEHOLDER do .env.example (identico ao exemplo)
RESULTADO: IDENTICO ao exemplo -> Regra 1 OK.
```

**Veredito:** `[OK]` — **M0 concluído.** Cluster `aiops`, banco + migrations,
MCP em `:3001`, app em `:8000` respondendo `200`, acessível de fora do host.

---

## Pendências do M0

| Passo | O quê | Estado |
|---|---|---|
| 0 | diagnóstico | `[OK]` |
| 1 | `ca-certificates` · `curl` · `jq` | `[NOTA]` |
| 2a | repositório oficial do Docker + chave GPG | `[OK]` |
| 2b | Docker Engine (5 pacotes) | `[OK]` |
| 2c | `daemon.json` com `live-restore` e rotação de log | `[OK]` |
| 2d | relogin + `hello-world` | `[OK]` |
| 3a | `kubectl` 1.37.1 + `kustomize` | `[OK]` |
| 3b | `kind` v0.33.0 | `[OK]` |
| 3c | cluster — nome corrigido no 5a | `[OK]` |
| 4a | `uv` 0.13.5 (persistente) | `[OK]` |
| 4b | `node` 24.22.1 + `npm` 11.19.1 — *via Err01* | `[OK]` |
| 5a | cluster renomeado para `aiops` | `[OK]` |
| 5b | `.env` (sem chave) + 108 pacotes | `[OK]` |
| 5c | `aiops-lab.sh up` — tudo no ar | `[OK]` |

**M0 · 14 de 14 concluído.**

**Inventário da toolchain ao fim do Passo 4:**

| Ferramenta | Versão | | Ferramenta | Versão |
|---|---|---|---|---|
| `curl` | 8.14.1 | | `docker` | 29.9.2 |
| `jq` | 1.7 | | `kubectl` | v1.37.1 |
| `git` | 2.47.3 | | `kind` | 0.33.0 |
| `gpg` | 2.4.7 | | `uv` | 0.13.5 |
| `node` | 24.22.1 | | `npm` | 11.19.1 |
| `python3` | 3.13.5 | | cluster | `Ready`, v1.37.0 |

**Recursos ao fim do Passo 4:** disco 4,4 G / 246 G usados (**229 G livres**,
2%) · RAM 7,8 Gi total, **6,6 Gi disponíveis** com o cluster no ar.

---

## Erros registrados

### Err01 — faltou `gnupg` → repo sem assinatura → node errado

- **Data:** 2026-10-22 · **Passo:** 4b (tentativa 1)
- **Severidade:** `[ERRO]` · **Impacto:** versão errada instalada, sem `npm`
- **Estado:** **corrigido** no Passo 4b tentativa 2

**Sintoma (o que apareceu):**

```
sudo: gpg: command not found
...
Err:11 https://deb.nodesource.com/node_24.x nodistro InRelease
  Sub-process /usr/bin/sqv returned an error code (1), error message is:
  Error: Failed to parse keyring "/etc/apt/keyrings/nodesource.gpg"
    Caused by: 0: Reading "...": No such file or directory
W: OpenPGP signature verification failed: ...
E: The repository 'https://deb.nodesource.com/node_24.x nodistro InRelease' is not signed.
N: Updating from such a repository can't be done securely, and is therefore disabled by default.
...
v20.19.2
-bash: npm: command not found
```

**Causa raiz:** o pacote **`gnupg` não estava instalado**. Sem ele, o
`gpg --dearmor` não executou → `/etc/apt/keyrings/nodesource.gpg` **nunca foi
criado** → o `apt` recusou o repositório por falta de assinatura e o
**desativou** → o `apt-get install nodejs` **caiu para a fonte do Debian**
(Node 20, sem `npm`).

**Por que eu errei:** a documentação oficial lista os pré-requisitos como
`ca-certificates curl gnupg`; instalei só os dois primeiros. Até então não fez
falta — as chaves do Docker e do Kubernetes são `.asc` e o `curl -o` grava
direto. A do NodeSource exige `--dearmor`, e aí o `gpg` faltou.

> **Lição:** dependência pode ficar **latente** — um pacote ausente,
> invisível por 3 passos, exposto no 4º. Instale o grupo completo de
> pré-requisitos mesmo os que "a gente não usa ainda".

**A cascata (5 etapas):**

| # | Etapa | Marca no terminal |
|---|---|---|
| 1 | `gpg` ausente → keyring nunca criado | `sudo: gpg: command not found` |
| 2 | `apt` lê repo sem chave | `Err:11 ... No such file or directory` |
| 3 | `apt` **desativa** o repo por falta de assinatura | `E: ... is not signed` + `N: ... disabled by default` |
| 4 | `install nodejs` **cai para outra fonte** | instalou `20.19.2`, não 24 |
| 5 | `nodejs` do Debian não traz `npm` | `npm: command not found` |

**A parte perigosa é a etapa 4:** o `apt` **não parou** — instalou de outra
fonte. Pediu-se 24 e recebeu-se 20, **sem nenhum erro na hora da instalação**.

**Prefixos do `apt` que valem decorar:**

| Prefixo | Significado |
|---|---|
| `W:` | *Warning* — aviso, inesperado mas não fatal |
| `E:` | *Error* — a operação falhou |
| `N:` | *Note* — explicação do porquê, com ponteiro para a doc |

**Correção aplicada:**

```bash
sudo apt-get install -y gnupg
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key -o /tmp/nodesource.key
cat /tmp/nodesource.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
ls -la /etc/apt/keyrings/nodesource.gpg          # checkpoint ANTES do update
sudo apt-get update
apt policy nodejs                                 # ver o Candidate ANTES de instalar
sudo apt-get install -y nodejs
```

**Prevenções que ficam:**

1. Instalar **todos** os pré-requisitos documentados de uma vez.
2. `ls` no keyring **antes** de rodar `apt-get update`.
3. **`apt policy <pkg>` antes de instalar** — ler a linha `Candidate` é o
   passo que teria detetado tudo de uma vez.
4. **Comparar a versão obtida com a pedida.** "Não deu erro" não é sucesso.

---

## Nota de método

O caderno é atualizado **após cada passo concluído**, e não em tempo real.
Enquanto um passo está em execução, ele não aparece aqui. Isso é deliberado:
registra-se **o que se concluiu**, com veredito, não o que está em curso.

---

# Sumário do M0 — ambiente de estudo

**Data:** 2026-10-22 · **Estado:** `[CONCLUÍDO]` · **14 de 14 passos.**

**O que foi construído, e por quê:**

| Camada | Ferramenta | Por quê ela, e não outra |
|---|---|---|
| Base | `ca-certificates` · `curl` · `jq` | sem `ca-certificates` nada fala HTTPS; sem `curl`, nada baixa; sem `jq`, não se lê JSON de API (é o `jq` que fez o `kind` achar a versão sozinho) |
| Containers | Docker CE 29.9.2 | o `kind` roda clusters Kubernetes **dentro** de containers Docker — sem Docker, sem cluster |
| Orquestração | `kind` 0.33.0 + `kubectl` v1.37.1 | `kind` dá um cluster real de produção num laboratório; `kubectl` é a interface |
| Python | `uv` 0.13.5 | o projeto é gerenciado por `uv` (`pyproject.toml` + `uv.lock`) |
| Node | Node 24.22.1 + npm 11.19.1 | o `Dockerfile` do projeto diz `FROM node:24-alpine`; `npm` entrega o `npx` que sobe o MCP server |
| Aplicação | FastAPI + LangChain + MCP | o alvo que será operado em AIOps |

**Duas armadilhas registradas e resolvidas:**

1. **Err01** — `gnupg` ausente → keyring nunca criado → repositório desativado
   por falta de assinatura → versão errada instalada sem nenhum erro na hora.
   Lição: pré-requisito ausente é latente.
2. **Nome do cluster** — eu mandei criar `aiops-lab`; o script e toda a
   documentação esperam `aiops`. Lição: conferir o que o código espera **antes**
   de criar recursos com nome.

**Três lições de método que valem mais que as versões instaladas:**

1. **Ler a linha `Candidate` do `apt policy` antes de instalar** — e comparar a
   versão obtida com a pedida. "Não deu erro" não é sucesso.
2. **Verificar, não presumir** — o `uv` quase gerou um alarme falso porque meu
   teste usou o tipo de shell errado. O shell não-interativo não lê `.profile`
   nem `.bashrc`. É a origem clássica de *\"funciona na mão, não funciona no
   cron\"*.
3. **Evento não é estado** — os `Warning` do bootstrap já estavam resolvidos
   quando apareceram no `status`. Distinguir transitório de real é o ofício.

**Limitações conscientes (não esquecidas):**

- `ANTHROPIC_API_KEY` **não configurada** — por decisão (Regra 1). O app sobe,
  avisa, e o relatório sai `INCOMPLETO`. Os testes `e2e` **pulam**, não falham.
- Os cenários em `teste-a`/`teste-b` estão **quebrados de propósito** — são o
  que o agente AIOps terá que diagnosticar.
- O `origin` aponta para o repositório **upstream** (`KubeDev`), não para uma
  cópia sua. Sem um fork, não há para onde dar `git push`. É assunto do M2.
- `docker-compose.override.yml` — comentário sobre WSL2 que não se aplica mais
  (o `pve-lab` é uma VM). Conteúdo correto, comentário desatualizado. **Pendente
  de decisão.**

**Estado da máquina ao fim do M0:**

| Recurso | Uso | Livre |
|---|---|---|
| Disco `/` | 4,4 G de 246 G | **229 G** (2%) |
| RAM | 1,2 Gi de 7,8 Gi | **6,6 Gi** |

Sobra recurso de sobra para todo o curso.

**Como derrubar e subir de novo:**

```bash
cd ~/projetos/imersao-aiops-prod-01
./aiops-lab.sh down     # para app, MCP, banco e cenários (cluster fica)
./aiops-lab.sh up       # sobe tudo de novo
./aiops-lab.sh status   # estado atual
./aiops-lab.sh reset    # DESTROI o cluster e recria (perde tudo dentro dele)
```

---

## Pendências do M0 — RESOLVIDAS

| Item | Situação | Resolução |
|---|---|---|
| `docker-compose.override.yml` | comentário mencionava WSL2, que não existe mais no ambiente (o `pve-lab` é uma VM) | **[OK]** comentário corrigido em 2026-10-22; directiva validada, `unless-stopped` intacta |
| Push para o GitHub | `origin` apontava para o repositório **upstream** (`KubeDev/imersao-aiops-prod-01`) — de outra pessoa | **[OK]** repositório próprio criado: `landeletronic/devops-profissional` |

---

## Passo 6 — repositório próprio no GitHub

- **Data:** 2026-10-22
- **Objetivo:** dar destino ao trabalho, que até então vivia **só** na VM.
- **Resultado:** <https://github.com/landeletronic/devops-profissional> — **PÚBLICO**, 252 arquivos, 6,68 MB.

### Por que este passo era necessário

O `origin` do `pve-lab` apontava para `https://github.com/KubeDev/imersao-aiops-prod-01.git`
— **o repositório de outra pessoa**, com `credential.helper = NONE`. Não havia
para onde dar `git push`. Enquanto isso, todo o trabalho (glossário, plano,
caderno, o ambiente montado) existia **em uma única VM**. Perder a VM seria
perder tudo.

### Decisão de autoria — a mais importante

O repositório da imersão **não possui arquivo de licença**. Na ausência de
licença, por padrão legal é *todos os direitos reservados* — **não** é "livre
para usar". E o que lá estava era substancial: o `boilerplate` inteiro, PRDs,
specs do `openspec`, o app `kube-news`, os manifests de falha e os **slides das
aulas**.

**Decisão registrada:** incluir o material da KubeDev **com atribuição
explícita**, num [`CREDITS.md`](https://github.com/landeletronic/devops-profissional/blob/main/CREDITS.md)
com a origem, o link do repositório original e a nota de ausência de licença.
Separou-se o que é autorial (glossário, plano, caderno, override) do que é de
terceiros — e essa separação está **dita, não implícita**.

> **Lição de carreira:** atribuir a origem do que se usa **não enfraquece** um
> portfólio — demonstra exatamente o que um profissional sênior faz: saber de
> onde veio o que se usa, e declarar isso. O contrário é o que envergonha.

### Auditoria de segurança — 9 verificações, antes de publicar

Repositório **público** exige isto. Todas precisavam passar:

| # | Verificação | Resultado |
|---|---|---|
| 1 | nenhum `.env` (só `.env.example`) | ✅ |
| 2 | nenhum diretório de build (`.venv`, `__pycache__`, `node_modules`) | ✅ |
| 3 | nenhum `.pyc` | ✅ |
| 4 | nenhuma chave Anthropic real (dois padrões de busca) | ✅ |
| 5 | nenhuma credencial AWS (`AKIA…`) | ✅ |
| 6 | nenhum token GitHub (`ghp_…`, `github_pat_…`) | ✅ |
| 7 | nenhuma chave SSH / `.pem` / `.key` | ✅ |
| 8 | nenhum `.env` fora de `.example` | ✅ |
| 9 | `.env.example` **preservado** | ✅ |

**Duas falhas reais foram pegas pela auditoria** — e é isto que justifica rodá-la:

1. **`--exclude` do `tar` não pegou os `__pycache__` aninhados.**
   O padrão `boilerplate-k8s-aiops/__pycache__` só casa o nível **raiz**. Os 8
   diretórios dentro de `src/` e `alembic/` passaram. Corrigido com `find … -name '__pycache__' -exec rm -rf {} +`,
   que é recursivo por natureza. *Lição:* **exclusão por caminho exato não é
   recursiva.***

2. **O Windows não extraiu os diretórios `.claude/`** do `kube-news`
   (`Can't create ... Invalid argument`). Na prática não foi perda: o
   `.gitignore` deste repositório **já exclui** `.claude/` e `.codex/` por
   política. Resolvido com uma verificação por **comparação de listas de
   arquivos** — aí sim dá para afirmar *"nada faltando"* com evidência.

### Verificação por comparação de listas (o método que vale guardar)

Em vez de olhar e achar que está tudo certo, comparou-se a **lista esperada**
(existente na VM) com a **lista real** (extraída no Windows):

```
esperado (sem .claude/.codex): 248
real                          : 251
[ok] nada faltando - todos os arquivos esperados estao presentes
SOBRANDO: + .gitignore  + CREDITS.md  + README.md     (os 3, meus)
```

Os 251 = 248 esperados + 3 que eu criei. **Nada faltando, nada sobrando.**
É o mesmo princípio do *drift* do glossário, Bloco 9: comparar o **estado
desejado** contra o **estado real**, e não confiar na memória.

### `.gitattributes` — por que foi necessário

O Git avisou, em ~200 linhas:

```
warning: in the working copy of 'scripts/aiops-lab.sh', LF will be replaced by CRLF the next time Git touches it
```

No Windows o Git converte `LF` → `CRLF` por padrão. Para arquivos de texto
é inofensivo — **para `.sh` é fatal**: o `bash` lê `\r` como parte do comando e
recusa o script no Linux. A correção foi um `.gitattributes` com
`* text=auto eol=lf` e `*.sh text eol=lf`. **Depois disso, zero avisos.**

> *Lição:* repositório que roda em duas plataformas precisa fixar o fim de
> linha. Caso clássico de *"na minha máquina funciona"*.

### Comandos executados (no Windows)

```powershell
# 1. autenticar (chave digitada pelo usuário no SEU terminal, nunca no chat)
"CHAVE" | gh auth login --with-token
gh auth setup-git

# 2. identidade git (estava vazia no Windows)
git config --global user.name  "landeletronic"
git config --global user.email "landeletronica@gmail.com"

# 3. montar o repositório
git init -b main
git add -A
git add --renormalize .          # aplica o .gitattributes novo
git commit -m "chore: inicializa repositorio de estudo DevOps/AIOps"

# 4. criar no GitHub a PARTIR do diretorio correto
cd $env:USERPROFILE\Downloads\AIOps\devops-profissional
gh repo create devops-profissional --public --source=. --push `
  --description "Laboratorio e caderno de estudo de DevOps/AIOps: ..."
```

### Três erros de detecção MEUS nesta etapa

Registrados porque foram todos do mesmo tipo — e o padrão importa:

| # | Erro | Por quê |
|---|---|---|
| 1 | `"autenticado"` quando **não** estava | `-match 'Logged in'` é **case-insensitive** por padrão no PowerShell e casou dentro de *"**not logged into** any GitHub hosts"* |
| 2 | `"NAO autenticado"` quando **estava** | regex esperava `- Logged in to`; a saída real trazia `✓ Logged in to` |
| 3 | `"JA EXISTE"` quando **não** existia | `gh repo view` num repo inexistente manda erro para o **stderr** contendo a palavra *"Repository"* — e o `-match` casou |

**A causa é uma só: confiar em `string matching` de saída.** A correção foi
usar **código de saída**:

```powershell
gh repo view landeletronic/devops-profissional 2>$null | Out-Null
if ($LASTEXITCODE -eq 0) { "existe"; exit 1 }   # exit 0 = encontrou
```

> **Lição:** *\"não deu erro\" não é sucesso* — e ***\"deu erro\" não é fracasso***
> se a leitura foi errada. Verificar por **código de saída** ou por **estado
> interrogável** (JSON), nunca por texto colado numa saída. É o mesmo erro do
> Err01, visto pelo outro lado: lá o `apt` não deu erro e instalou a versão
> errada; aqui eu não dê erro e li errado duas vezes.

### Estado final verificado via API

```
nome       : devops-profissional
visibilidade: PUBLIC
url        : https://github.com/landeletronic/devops-profissional
branch     : main
arquivos   : 252  ·  6,68 MB

RAIZ:  .gitattributes  .gitignore  CREDITS.md  README.md
       [dirs] docs  lab  notas  scripts

REGRA 1:  [ok] nenhum segredo ou artefato publicado
          .env.example publicados: 5
```

**Raiz conforme exigido:** `README.md` é o único arquivo de conteúdo, mais os
3 de configuração do Git (`.gitignore`, `.gitattributes`) e o `CREDITS.md`.

**Veredito:** `[OK]` — repositório próprio, **público**, descrito, com pastas
organizadas, sem nenhum segredo, atribuição declarada.

---

## Simulado M0 — questões e correções

- **Data:** 2026-10-22
- **Método:** *recolha ativa* — recuperar da memória em vez de reler. É o método
  de estudo mais eficiente disponível, e o mais desconfortável.
- **Resultado:** Q6 quase completa · Q2 e Q3 parciais · **Q1, Q4 e Q5 erradas**
- **Padrão identificado:** responder por **intuição geral** em vez do
  **mecanismo específico**, e entregar **menos itens do que a pergunta pede**.
  As três falhas falharam do mesmo jeito: a resposta *soa plausível*, mas não é
  a que foi perguntada.

> **Nota de método sobre a nota:** errar num simulado é o cenário **barato**.
> O mesmo erro num incidente real custa muito mais. Por isso se treina assim.

### Q1 — Arquitetura e `localhost`

**Pergunta:** quem edita, quem executa, e por que `localhost:8000` não funciona
a partir do Windows?

**Resposta dada:** o Windows não tem o projeto; acesso *"via wsl2/kind"* e
*"via vm instalada em um proxmox"*.

**Avaliação:** 🔴 — acertou que o Windows não hospeda o projeto, mas cometeu os
**dois erros de escopo do ambiente** e não respondeu o que foi perguntado.

- ❌ **WSL2** — não existe aqui (Regra 2b). É justamente o comentário que foi
  removido do `docker-compose.override.yml` no mesmo dia.
- ❌ **Proxmox** — fora de escopo (Regra 2). `192.168.15.221:8006` é
  explicitamente excluído.
- ❌ Não respondeu **por que `localhost` falha**.

**Correção:**

| | |
|---|---|
| Quem edita | **Windows** — editor, Git, agente |
| Quem executa | **`pve-lab` (192.168.15.10)**, via SSH |
| Por que `localhost:8000` falha | do Windows, `localhost` **é o próprio Windows** — e lá nada roda. O processo está no `pve-lab`. Por isso: `http://192.168.15.10:8000`. |

> **Lição:** valeu a regra do glossário, Bloco 1 — *li antes de agir*. Saber
> **qual máquina** é a pergunta prévia a qualquer comando.

### Q2 — `ca-certificates`

**Resposta dada:** *"leitura dos certificados dos sites... para visualizar ou
baixar algum arquivo."*

**Avaliação:** 🟡 — campo certo, mecanismo errado.

**Correção:** o pacote instala o **bundle de CAs confiáveis** — a lista de
autoridades emitentes em quem o sistema **confia**. Sem ele o TLS **não é
validável**: nada confirma que o servidor é quem diz ser. **Não é sobre
visualizar nem baixar.**

O que quebraria concretamente:

```
apt-get update          em repo HTTPS  ->  recusa
curl https://...                          ->  SSL certificate problem: unable to get local issuer certificate
git clone https://github.com/...          ->  falha
```

**A pista está no nome:** `ca` = **Certificate Authority**, não "certificado".
Foi o primeiro pacote instalado (Passo 1) porque **sem ele nenhum dos outros
passos teria conseguido baixar nada por HTTPS.**

### Q3 — Por que Node 24

**Pedida:** três razões. **Entregue:** uma (a certa).

**Avaliação:** 🟡 — a que deu é **a** evidência:

```dockerfile
./kube-news/src/Dockerfile:1:     FROM node:24-alpine
./kube-news/src/Dockerfile.dev:1: FROM node:24-alpine
```

**As outras duas que faltaram:**

1. **`npx`** — o MCP server sobe com `npx -y mcp-server-kubernetes`. O `npx`
   vem do `npm`, que vem do pacote `nodejs` completo (o do Debian não trazia —
   foi a etapa 5 da cascata do Err01).
2. **Consistência declarada** — o repositório `node_24.x` foi escolhido **para
   bater** com o que o projeto declara. Usar 18 ou 20 seria decidir **por fora**
   do projeto.

> **Lição:** *"pediu 3, dei 1"* é entregar **um terço**. Em entrevista isso
> reprova mais do que não saber.

### Q4 — `live-restore: true` ⚠️ erro conceitual

**Resposta dada:** *"quando o container atualiza/reboot/crash ele retorna ao
estado normal sem perder os dados."*

**Avaliação:** 🔴 — descreveu **persistência de dados**, que não tem relação
com a directiva.

**Correção:**

| | |
|---|---|
| **`live-restore`** | quando o **daemon do Docker** reinicia ou é atualizado (`systemctl restart docker`, `apt upgrade docker-ce`), os containers **continuam rodando** em vez de morrerem |
| **Volume** | é isso que preserva dados entre containers/recriação |

**A situação que salva:** atualizar o Docker por segurança no meio do dia.
Sem `live-restore` → **todos os containers caem** (Postgres, app, pgAdmin).
Com ele → ficam de pé. Por isso a directiva fica no **`daemon.json`** (do
daemon), não no container.

> **Lição:** são dois conceitos de sobrevivência diferentes —
> **sobreviver a restart do daemon** ≠ **sobreviver a recriação do container**.

### Q5 — Cluster × Contexto ⚠️ erro conceitual

**Pergunta:** diferença entre cluster `aiops` e contexto `kind-aiops`.

**Resposta dada:** falou do problema de **ter dois clusters** rodando (que foi o
erro do Passo 5a). Isso é **outra coisa**.

**Avaliação:** 🔴 — a pergunta central não apareceu.

**Correção:**

| | O que é |
|---|---|
| **Cluster `aiops`** | o **lado servidor**: os containers `kind` — nós, API server, pods. Existe ou não existe. |
| **Contexto `kind-aiops`** | uma **configuração local do `kubectl`**: endereço do servidor, credencial, namespace padrão. É um **ponteiro/perfil**. |

- Um cluster pode ter **vários** contextos apontando para ele.
- Um contexto pode apontar para **outro** cluster.
- `kubectl config current-context` mostra **qual ponteiro está ativo**.

**O perigo do contexto errado:** o `kubectl` conversa com **outra máquina** e
**não avisa**. Você aplica um manifesto, nada acontece, e a pergunta vira *"por
que não funcionou?"* — quando funcionou, **noutro lugar**. É o problema de
**contexto** do glossário, Bloco 4, e a causa provável de muitos bugs de
automação.

### Q6 — Dois `python3` ✅

**Resposta dada:** *"pode existir dois python. um deles estava nas dependências
do nodejs."*

**Avaliação:** ✅ — acertou a origem, e ela foi comprovada:

```
$ apt-cache depends nodejs
  Depends: python3
```

**Faltou identificar qual foi usado:** o do sistema, `/usr/bin/python3`
(**3.13.5**) — `Using CPython 3.13.5 interpreter at: /usr/bin/python3`.

> **Observação bonita:** **duas decisões que pareciam separadas se encontraram** —
> o Python instalado *por causa* do Node foi o que o `uv` usou *depois*. É o
> tipo de efeito colateral que só aparece se você ler as saídas.

### Recado final do simulado

As perguntas que falharam falharam por **não serem respondidas**, não por
falta de conteúdo na cabeça. Q4 e Q5 exigiam **definir**, e você
**narrou** — e narrar é o que dá a *impressão* de resposta.

**Para a próxima:** antes de responder, reescrever mentalmente **o que exatamente
estão perguntando**. Metade do erro some aí.

---

## Nota de método

O caderno é atualizado **após cada passo concluído**, e não em tempo real.
Enquanto um passo está em execução, ele não aparece aqui. Isso é deliberado:
registra-se **o que se concluiu**, com veredito, não o que está em curso.

---

*Última atualização: 2026-10-22 — **M0 concluído (14/14)** · **Passo 6 —
repositório `landeletronic/devops-profissional` publicado** · **Simulado M0
aplicado e corrigido** (acertos parciais em Q2/Q3/Q6; erros conceituais
registrados em Q4 `live-restore` e Q5 cluster×contexto; erros de escopo em Q1).
Nenhuma credencial publicada (auditoria 9/9).*
