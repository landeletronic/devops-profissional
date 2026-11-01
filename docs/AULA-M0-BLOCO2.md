# AULA M0 — BLOCO 2: Mecanismos (o *porquê*)

> **Para quem:** iniciante em DevOps que completou o M0 e quer entender **por
> que** as coisas aconteceram — não só o que digitar. Conceito antes do
> comando; todo exemplo é real, do laboratório.
>
> **Data:** 2026-11-01 · **Requisito:** ter lido o M0 no
> [`notas/CADERNO-DE-LABORATORIO.md`](../notas/CADERNO-DE-LABORATORIO.md)
> · **Questões ligadas:** Q7–Q12 do simulado.
>
> Os erros aqui **aconteceram de verdade** e estão registrados no caderno.
> Errar em laboratório é o preço — errar em produção é o prejuízo.

---

## 1. A cascata do Err01 — como um `apt install` errou sem dar erro

### O sintoma que ninguém esperava

O objetivo era simples: instalar o **Node 24**. O terminal mostrou sucesso
parcial e depois:

```
$ sudo: gpg: command not found
$ v20.19.2
$ -bash: npm: command not found
```

Pediu-se 24, recebeu-se 20, e **sem `npm`**. Sem nenhum erro *durante* a
instalação.

### A cascata em 5 etapas

Falhas raramente são um evento. São uma **cadeia** — e cada etapa só é
possível porque a anterior não foi pega:

```
(1) gpg ausente
     │  gpg --dearmor nunca rodou
     ▼
(2) keyring nunca criado
     │  /etc/apt/keyrings/nodesource.gpg NAO existe
     ▼
(3) apt le o repositorio SEM chave
     │  "repository is not signed ... disabled by default"
     ▼
(4) install nodejs CAI PARA OUTRA FONTE        ← a perigosa
     │  fonte do Debian ainda ativa: Node 20
     ▼
(5) nodejs do Debian nao traz npm
        "npm: command not found"
```

| # | Etapa | Marca no terminal |
|---|---|---|
| 1 | `gpg` ausente → keyring nunca criado | `sudo: gpg: command not found` |
| 2 | `apt` lê o repositório sem chave | `Err:11 ... No such file or directory` |
| 3 | `apt` **desativa** o repositório por falta de assinatura | `E: ... is not signed` + `N: ... disabled by default` |
| 4 | `install nodejs` **cai para outra fonte** | instalou `20.19.2`, não 24 |
| 5 | `nodejs` do Debian **não traz `npm`** | `npm: command not found` |

### Por que a etapa (4) é a mais perigosa

> **A etapa (4) não falha — ela entrega outra coisa.**

O `apt` não parou, não gritou, não devolveu exit code negativo. Ele fez
**exatamente o que foi pedido** — *instalar o `nodejs` disponível* — só que
"disponível" já não era mais o NodeSource (desativado na etapa 3), e sim o
Debian. O sistema **obedeceu com a resposta errada**.

Sintomas de cascata perigosa:

- O erro **não aparece no momento da ação**; aparece **depois**, em outro
  comando (`npm: command not found`);
- A ação **parece funcionar** (exit 0);
- A causa está **três comandos atrás** de onde você está olhando.

**Analogia:** é como pedir um prato no restaurante e receber outro — mas o
garçom anota "pedido concluído" e vai embora. O problema só aparece quando
você corta. A falha que *grita* é a menos perigosa; a que *entrega errado
em silêncio* quebra produção.

### A correção — e as prevenções

A correção reinstalou a cadeia inteira, na ordem inversa do dano:

```bash
sudo apt-get install -y gnupg                      # (1) o que faltou
curl -fsSL .../nodesource-repo.gpg.key -o /tmp/nodesource.key
cat /tmp/nodesource.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
ls -la /etc/apt/keyrings/nodesource.gpg            # checkpoint ANTES do update
sudo apt-get update
apt policy nodejs                                   # ve o Candidate ANTES de instalar
sudo apt-get install -y nodejs
```

**Prevenções que sobram daqui:**

1. Instale **todos** os pré-requisitos documentados — não "os dois primeiros
   que parecem necessários" (`ca-certificates curl gnupg` eram **três**);
2. **Checkpoint antes do próximo passo** — o `ls` do keyring custa 100 ms e
   mata a cascata na etapa (2);
3. **Leia o `Candidate` antes de instalar** (etapa seguinte);
4. **Compare o resultado com o pedido.** *"Não deu erro" não é sucesso.*

---

## 2. `apt policy` — a linha `Candidate:` é uma pergunta que você faz antes

Depois do Err01, o mesmo comando passou a ser rotina **antes** de qualquer
instalação:

```
$ apt policy nodejs
nodejs:
  Installed: 20.19.2+dfsg-1+deb13u3
  Candidate: 24.22.1-1nodesource1        <-- o que sera instalado
  Version table:
     24.22.1-1nodesource1 500
        500 https://deb.nodesource.com/node_24.x nodistro/main amd64 Packages
     *** 20.19.2+dfsg-1+deb13u3 500
        500 http://security.debian.org/debian-security trixie-security/main
```

### Como o `apt` escolhe

1. Cada fonte tem uma **prioridade** (`500` é o padrão);
2. Prioridades **empatadas** → vence a **versão mais alta** (24 > 20);
3. O vencedor aparece na linha **`Candidate:`**.

### O que `Candidate` entrega que nada mais entrega

> **`Candidate` é a resposta à pergunta "o que será instalado" — e ela
> existe antes de você instalar.**

Nenhuma outra linha do `apt` diz isso. `Installed` diz o passado; a
*version table* dá as opções; **só `Candidate` dá a decisão**. Ler essa
linha antes do `install` é cortar a cascata do Err01 na etapa (3) — antes
do disparo.

**Analogia:** o `Candidate` é a *nota de pedido* que o garçom mostra antes
de levar a cozinha. O Err01 foi um pedido que ninguém leu antes de assinar.

### Bonus: o `-s` — agir antes de agir

```bash
$ sudo apt-get -s install nodejs     # simulação: nada é instalado
```

O `-s` (simulate) mostra **o que iria acontecer**, sem acontecer nada. É o
`apt policy` levado ao extremo: em vez de *ler antes de agir*, o sistema
*age antes de agir de verdade*. O M0 usou a mesma disciplina em outros
pontos — `jq . /etc/docker/daemon.json` (valida antes de reiniciar o
daemon) e `ls /etc/apt/keyrings/nodesource.gpg` (checkpoint antes do
`apt-get update`).

---

## 3. Os oito pacotes que ninguém pediu — dependência declarada × coincidência

Na instalação do Node 24:

```
The following packages will be REMOVED:
  libnode115 node-acorn node-corepack nodejs-doc
The following NEW packages will be installed:
  libpython3-stdlib libpython3.13-minimal ... python3 python3.13 ...
```

**4 removidos, 8 instalados — incluindo um `python3` que ninguém pediu.**
Esperado ou problema?

### Os 4 removidos: troca de versão maior

Os removidos são os pacotes do **Node 20** do Debian, substituídos pelos do
24. O próprio `apt` avisou `dependency problems, but removing anyway` —
dependências quebradas **de propósito**, porque é uma troca de versão maior.
Se não removesse, ficariam dois Nós convivendo.

### Os 8 instalados: `Depends: python3`, comprovado

O `python3` **não foi coincidência** — é dependência **declarada**:

```
$ apt-cache depends nodejs
  Depends: python3
```

O `node-gyp` (compila módulos nativos, tipo `bcrypt`) é escrito em Python,
então o pacote `nodejs` do NodeSource **declara** `python3`.

### A régua: quando é sinal de problema?

| Situação | Veredito |
|---|---|
| Pacote **removido** veio da fonte antiga | Esperado (troca) |
| Pacote **instalado** aparece em `apt-cache depends` | Esperado (dependência) |
| Pacote removido **não** era da fonte antiga | **Suspeito** |
| Pacote instalado **não** está na cadeia declarada | **Suspeito** |

> **Encruzilhada do M0:** esse `python3` entrou *por causa* do Node — e foi
> ele que o `uv` usou **depois** no `uv sync`
> (`Using CPython 3.13.5 interpreter at: /usr/bin/python3`). Duas decisões
> que pareciam separadas se encontrando. É o tipo de efeito colateral que só
> aparece se você **ler as saídas**.

---

## 4. Três tipos de shell — e o `uv` que "não estava instalado"

### A tabela que resolve metade dos misterios

| Shell | Lê `.profile`? | Lê `.bashrc`? | Quando acontece |
|---|---|---|---|
| **login interativo** | ✅ | ✅ | você digita `ssh pve-lab` |
| **interativo não-login** | ❌ | ✅ | outro terminal na mesma sessão |
| **não-interativo** | ❌ | ❌ | `ssh host "cmd"`, `cron`, systemd |

O `.profile` é quem adiciona `$HOME/.local/bin` ao `PATH` — onde o `uv`
foi instalado:

```bash
# .profile linhas 25-26
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
```

### O alarme falso

Um teste com o padrão de trabalho do projeto:

```bash
$ ssh pve-lab "bash script.sh"     # shell NAO-interativo
# resultado: uv AUSENTE
```

**Leitura errada disponível:** *"o `uv` não está instalado"*, *"o PATH
quebrou"*, *"preciso reinstalar"*. Todas **falsas**.

**Causa real:** shell **não-interativo** não leu `.profile` nem `.bashrc`
→ `$HOME/.local/bin` nunca entrou no `PATH` → o `uv` estava lá **o tempo
todo**.

**Correção:** forçar shell login:

```bash
$ bash -lc 'command -v uv'
/home/tlandskron/.local/bin/uv
```

**Analogia:** o `uv` não sumiu da casa — você entrou pela porta dos fundos,
onde o aquecimento (o `.profile`) não alcança. A casa é a mesma; o ambiente
diferente.

> **Lição clássica:** *"funciona na mão, não funciona no cron"*. É um
> problema de **contexto**, não de instalação. Toda automação que depende de
> variáveis de ambiente precisa perguntar: **este shell lê o arquivo que
> monta meu PATH?**

---

## 5. `idempotência` — o snippet que checa antes de agir

O instalador do `uv` criou um snippet no `.bashrc` que **checa antes de
adicionar** o diretório ao `PATH`:

```bash
case ":${PATH}:" in
    *:"$HOME/.local/bin":*) ;;              # ja esta: nao faz nada
    *) export PATH="$HOME/.local/bin:$PATH" ;;  # nao esta: adiciona
esac
```

**Propriedade:** **idempotência** — *rodar 10 vezes dá o mesmo resultado de
rodar 1 vez*. Sem o `case`, cada nova sessão **duplicaria** o diretório no
`PATH` (funciona, mas é lixo acumulado). Com ele, o snippet é seguro de
repetir **por projeto**, não por sorte.

### A família das disciplinas do M0

| Ferramenta | Propriedade | Efeito |
|---|---|---|
| snippet do `uv` | **idempotente** | repetir não duplica |
| `uv.lock` (644 KB) | **determinístico** | mesma entrada, mesma saída |
| `apt-get -s` | **simulação** | agir sem agir |
| `jq . daemon.json` | **validação** | checar antes de reiniciar |

> Glossário, Bloco 5: **idempotente × determinístico** — *repetir não muda*
> × *mesma entrada, mesma saída*. O M0 usou as duas: o `uv` é idempotente,
> o `uv.lock` é determinístico.

---

## 6. `.gitattributes` — o `\r` que mata script no Linux

### O aviso

```
warning: in the working copy of 'scripts/aiops-lab.sh',
LF will be replaced by CRLF the next time Git touches it
```

### O que acontece sem ele

No Windows, o Git converte `LF` → `CRLF` por padrão. Para texto corrente é
inofensivo. **Para `.sh` é fatal**: o `bash` lê o `\r` como **parte do
comando** e recusa a linha:

```bash
# sintoma classico (script com CRLF):
$'\r': command not found
```

O script morre — ou pior, morre **no meio**, no ponto onde o `\r` aparece,
e o erro parece apontar para uma linha que **não** é a culpada.

### A correção

```
# .gitattributes
* text=auto eol=lf
*.sh text eol=lf
```

e o renormalizar:

```bash
git add --renormalize .
```

**Depois disso, zero avisos.** Requisito de qualquer repositório que roda em
duas plataformas — caso clássico de *"na minha máquina funciona"*, aqui com
a assinatura exata: **na sua máquina (Windows) o arquivo é salvo, no
outro (Linux) ele não roda.**

**Analogia:** o Git é o tradutor entre as duas plataformas. Sem o
`.gitattributes`, ele traduz **demais** — muda o fim de linha como se fosse
palavra. O arquivo muda de forma no caminho, e o Linux recebe um script que
não é mais o que você escreveu.

---

## Resumo do Bloco 2

| Mecanismo | O que ele ensina | Defesa |
|---|---|---|
| Cascata do Err01 | Falha silenciosa **entrega errado** | checkpoints + comparar resultado com pedido |
| `apt policy` | A resposta existe **antes** da ação | ler `Candidate` sempre |
| Dependências | "ninguém pediu" ≠ problema | `apt-cache depends` prova |
| Tipos de shell | Mesmo binário, **ambiente diferente** | `bash -lc` em automação |
| Idempotência | Repetir com segurança é **projeto** | checar antes de agir |
| `.gitattributes` | Arquivo **muda no caminho** | fixar `eol=lf` |

> **Fio comum:** nos seis casos, o sistema **não avisou**. Não porque é
> malicioso — porque obedeceu. A diferença entre quem erra e quem opera é
> **quem pergunta antes**: `ls` no keyring, `Candidate` antes do install,
> `command -v` antes de concluir, `git check-attr` antes do push.
> **Ler antes de agir — e comparar depois.**

---

*Relacionado:* [`GLOSSARIO-DEVOPS.md`](GLOSSARIO-DEVOPS.md) verbetes
*cascata, idempotente, contexto, determinístico* ·
[`AULA-M0-PROFUNDIZACAO.md`](AULA-M0-PROFUNDIZACAO.md) (Bloco 1) ·
[`PLAYBOOK-INCIDENTES.md`](PLAYBOOK-INCIDENTES.md) incidentes a–f.
