# Playbook de incidentes — o que quebrou e como foi corrigido

**Data:** 2026-11-01
**Para quem é:** iniciante em DevOps em transição de carreira — cada incidente
aqui é um caso real do laboratório, com o texto do erro **como apareceu no
terminal**.

> **Princípio antes do comando:** um incidente se resolve na ordem
> **sintoma → causa raiz → correção → prevenção**. Pular direto para a
> correção é decorar receita: a próxima vez o sintoma vem diferente e você
> fica sem chão. Pense num bombeiro: ele não joga água onde sai fumaça — ele
> primeiro descobre **o que está queimando**.

Formato de cada caso: **Sintoma** (erro real) · **Causa raiz** ·
**Diagnóstico** (comando) · **Correção** (comando) · **Prevenção**.

---

## (a) Nó do kind morto pelo OOM killer — exit 137

**Sintoma** (texto real observado):

```
Unable to connect to the server: dial tcp 127.0.0.1:35735: connect: connection refused
```

**Causa raiz:** a VM tinha pouca RAM livre (~260 MB). O Linux matou o
container do nó `aiops-control-plane` com **SIGKILL** (exit **137** = 128 +
9). Com o nó morto, o túnel loopback da API do kind morreu junto — e era
justamente por ali que o `kubectl` conversava com o cluster.

**Analogia:** o servidor de rede da empresa foi desligado no contato de
energia. O telefone (kubectl) funciona, mas ninguém atende do outro lado —
e o erro "connection refused" faz parecer que o *telefone* quebrou, quando o
que desligou foi a *central*.

**Diagnóstico:**

```bash
docker ps -a --filter 'name=aiops-control-plane'
# esperado: STATUS = Exited (137) — a prova do SIGKILL

free -m
# observado em sessão com a falha: available ~260 MB

kubectl get nodes
# reproduz o erro: dial tcp 127.0.0.1:35735: connect: connection refused
```

**Correção:**

```bash
# devolver RAM à VM (aumentar para 8 GB na configuração da VM) e depois:
docker start aiops-control-plane
kubectl --context kind-aiops get nodes
# esperado: aiops-control-plane   Ready   ...
```

Se o nó não voltar saudável: `./scripts/aiops-lab.sh reset` (destrói e
recria o cluster — ação sem volta para o que estava dentro dele).

**Prevenção:** monitorar `free -m` antes de subir o ambiente; não rodar
workloads concorrentes na mesma VM; tratar exit 137 como "fome de RAM", não
como bug de aplicação.

---

## (b) SSH em thrashing de swap — porta aberta, sessão nunca abre

**Sintoma** (texto real observado):

```
ssh pve-lab
Connection timed out during banner exchange
```

**Causa raiz:** a VM estava **trocando tanto com o disco (swap)** que o
`sshd` não conseguia atender. A porta 22 aparecia **ABERTA** e o `ping`
respondia — porque a rede ainda funcionava — mas o processo não conseguia
CPU/tempo para completar a troca de banners do SSH.

**Analogia:** o portão da oficina está aberto e o interfone atende (ping), mas
o atendente está correndo tanto entre prateleiras que nunca chega para falar
com você. "Porta aberta" não é "serviço saudável".

**Diagnóstico:**

```bash
ping -c 4 192.168.15.10
# esperado: responde (a rede está OK — e isso NÃO descarta o problema)

# do Windows, testar a porta:
Test-NetConnection 192.168.15.10 -Port 22
# esperado: TcpTestSucceeded = True  (porta aberta, mesmo com o SSH travado)

ssh -v pve-lab
# observado: trava em "Connection timed out during banner exchange"
```

**Correção:**

```text
1. Aguardar o sistema estabilizar (ou reiniciar a VM pelo gestor da hypervisor).
2. Conferir a memória depois do boot:
   free -m        → available com folga
   vmstat 1 5     → colunas si/so (swap in/out) perto de zero
```

**Prevenção:** nunca deixar a VM chegar em thrashing — definir alerta de RAM,
evitar que múltiplos clusters/workloads disputem a mesma VM, e lembrar que
**porta aberta ≠ serviço atendendo**: verificar o banner/serviço, não só o
TCP.

---

## (c) `.venv` com shebangs quebrados após mover o projeto

**Sintoma** (texto real observado):

```
uv run alembic
error: Failed to spawn: alembic
  cause: No such file or directory
```

**Armadilha extra:** o `uv sync` **não corrige** — ele responde
`Checked 108 packages` e não reinstala nada.

**Causa raiz:** o diretório do projeto foi **movido**. O `.venv` é um
diretório com caminhos **absolutos embutidos** nos scripts dos pacotes
(shebangs tipo `#!/caminho/antigo/.venv/bin/python`). Ao mover, **26 dos 39
shebangs** de `.venv/bin` passaram a apontar para um caminho que não existe
mais. O erro é enganoso: parece que o `alembic` sumiu, quando o que sumiu foi
o *interpretador que o `alembic` pedia*.

**Analogia:** mudou-se de casa e levou a caixa de ferramentas — só que as
etiquetas das gavetas ainda dizem o endereço antigo. A chave não existe
"muito pequena"; ela está na gaveta com o rótulo errado.

**Diagnóstico:**

```bash
head -1 .venv/bin/alembic
# observado: #!/caminho/antigo/.venv/bin/python   ← caminho inexistente

ls -d /caminho/antigo 2>/dev/null
# esperado: nada (o caminho antigo não existe)

uv sync
# observado: Checked 108 packages  ← NÃO reinstala: não corrige
```

**Correção:**

```bash
rm -rf .venv
uv sync
# observado: recria 110 pacotes a partir do uv.lock

uv run alembic upgrade head
# esperado: migrations aplicadas (sem "Failed to spawn")
```

**Prevenção:** **nunca mover `.venv`** — ele é artefato reconstruível. Em
reestruturação, mova o projeto e **recrie** o `.venv` com `uv sync`
(ver D4 e D5 em [`DECISOES-TECNICAS.md`](DECISOES-TECNICAS.md)).

---

## (d) `uvicorn: command not found` via SSH (shell não-interativo)

**Sintoma** (texto real):

```
ssh pve-lab "uv run uvicorn my_agent_app.main:app --port 8000"
bash: uvicorn: command not found
```

**Causa raiz:** o SSH não-interativo **não lê os arquivos de perfil**
(`.bashrc` / `.profile`), então o `PATH` que inclui `~/.local/bin` (onde o
`uv` e o `uvicorn` moram) não é carregado. O programa existe; o shell apenas
**não sabe onde procurar**.

**Analogia:** o entregador tem o pacote na mão, mas você não deixou o número
da casa no bilhete — ele não erra o conteúdo, erra o **endereço de procura**.

**Diagnóstico:**

```bash
ssh pve-lab "which uv; echo PATH=\$PATH"
# observado: PATH sem ~/.local/bin

ssh pve-lab "bash -lc 'which uv'"
# esperado: /home/tlandskron/.local/bin/uv
```

**Correção:**

```bash
# usar um login shell (-l) ou caminho absoluto:
ssh pve-lab "bash -lc 'cd ~/projetos/imersao-aiops-prod-01 && uv run uvicorn my_agent_app.main:app --host 0.0.0.0 --port 8000'"
```

**Prevenção:** em comandos remotos via SSH, sempre `bash -lc '...'` (login
shell) ou caminho absoluto do executável. Se o script local usa `uv run ...`,
ele precisa do mesmo `PATH` — o `aiops-lab.sh` roda *dentro* do `pve-lab`
justamente por isso.

---

## (e) `localhost` errado ao acessar serviço de outra máquina

**Sintoma** (comportamento observado no Windows):

```powershell
curl.exe -s -o NUL -w "%{http_code}" http://localhost:8000/api/health
# observado: 000 (conexão recusada/não há nada ouvindo)
```

Enquanto isso, no próprio `pve-lab`:

```bash
curl -s -o /dev/null -w '%{http_code}\n' http://localhost:8000/api/health
# observado: 200
```

**Causa raiz:** **`localhost` é relativo a quem pergunta.** Para o `curl` do
`pve-lab`, `localhost` é o próprio `pve-lab` (onde a app roda). Para o
Windows, `localhost` é o Windows — e no Windows **não há** serviço algum
(R3: nada roda na estação). Serviço de outra máquina se acessa pelo **IP
dela**.

**Analogia:** perguntar "em casa tem pão?" depende de **onde você está**.
Na padaria, "em casa" é a padaria; na sua casa, é a sua cozinha.

**Diagnóstico:**

```powershell
# de fora (Windows) — IP da máquina que executa:
curl.exe -s -o NUL -w "%{http_code}`n" http://192.168.15.10:8000/api/health
# esperado: 200
```

**Correção:** usar sempre `http://192.168.15.10:<porta>` a partir do Windows;
reservar `localhost` para testes feitos **dentro** do `pve-lab`.

**Prevenção:** fixar a regra do repositório — *"os serviços ficam em
`http://192.168.15.10:<porta>`, nunca em `localhost`"* (ver README). Em
troubleshooting de rede, pergunte sempre: **de qual máquina estou perguntando?**

---

## (f) PowerShell interpretando sintaxe bash

**Sintoma** (comportamento observado):

```powershell
ssh pve-lab "comando > /dev/null 2>&1"
# observado: cria/trata como C:\dev\null no Windows — erro estranho de caminho

ssh pve-lab "grep -E 'LAB_DIR' script.sh | awk '{print $1}'"
# observado: o $(...) / aspas são interpretados LOCALLY pelo PowerShell
# antes de viajar para o pve-lab
```

**Causa raiz:** o PowerShell tem **sua própria** sintaxe de redirecionamento
(`/dev/null` não existe — ele vira `C:\dev\null`), interpola `$(...)` na
máquina de origem e trata aspas de forma diferente do bash. O comando "viaja"
para o Linux **já adulterado**.

**Analogia:** você mandou uma receita escrita em português para uma cozinha
que lê em outro idioma — o cozinheiro faz o melhor possível com o que
entendeu, e o prato sai errado **sem erro de digitação aparente**.

**Diagnóstico:** qualquer erro de caminho `C:\dev\...` ou resultado vazio
em comando remoto com pipes/aspas é suspeito de interpretação local.

**Correção (padrão seguro):**

```powershell
# 1) escrever o script em um arquivo .sh (ASCII puro)
# 2) copiar para a VM
scp .\check.sh pve-lab:/tmp/check.sh
# 3) executar LÁ dentro
ssh pve-lab "bash /tmp/check.sh"
```

E para commitar sem a PowerShell bagunçar a mensagem:

```powershell
git commit -F arquivo.txt
# em vez de git commit -m "mensagem com aspas e $variáveis"
```

**Prevenção:** nunca misturar sintaxe bash dentro de uma linha do PowerShell;
usar `.sh` + `scp` + `ssh "bash ..."`. Em `.ps1`, escrever **ASCII puro**
(PowerShell 5.1 quebra UTF-8 sem BOM — ver D10).

---

## Tabela-resumo

| # | Sintoma-chave | Causa raiz | Correção-chave |
|---|---|---|---|
| a | `connection refused` em `127.0.0.1:35735` | OOM matou o nó (exit 137) | RAM + `docker start` / `reset` |
| b | `timed out during banner exchange` | thrashing de swap | estabilizar RAM/swap |
| c | `Failed to spawn: alembic` | shebangs absolutos quebrados | `rm -rf .venv && uv sync` |
| d | `uvicorn: command not found` | PATH sem login shell | `bash -lc` |
| e | `localhost` não conecta de fora | localhost é relativo | usar `192.168.15.10` |
| f | `/dev/null` → `C:\dev\null` | PowerShell executa bash | `.sh` + scp + ssh |

---

*Playbook de estudo: os textos de erro acima são os observados neste
laboratório. Em outra máquina, o caminho e a porta podem mudar — o princípio
de diagnóstico é o mesmo.*
