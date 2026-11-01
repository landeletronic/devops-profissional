# estrutura-repositorio Specification

## Purpose

Define o inventário canônico do repositório `devops-profissional`, as regras
que a raiz deve satisfazer e o processo de verificação de integridade entre
as três vias (estação Windows, VM `pve-lab`, GitHub). Criada a partir da change
`2026-11-01-consolidacao-estrutura-repositorio`.

## Requirements

### Requirement: Inventário canônico em quatro diretórios

O repositório SHALL conter exatamente quatro diretórios de conteúdo na raiz:
`docs/` (material didático, documentação DevOps e manifestos OpenSpec),
`lab/` (infraestrutura funcional do laboratório), `scripts/` (automação) e
`notas/` (caderno de laboratório). Qualquer novo item de conteúdo SHALL ser
colocado em um desses diretórios segundo sua natureza.

#### Scenario: Raiz atende à regra do repositório

- **WHEN** o conteúdo da raiz é listado
- **THEN** os únicos itens são `README.md`, `CREDITS.md`, `.gitignore`,
  `.gitattributes` e os diretórios `docs/`, `lab/`, `scripts/`, `notas/`

#### Scenario: Documentação nova vai para docs/

- **WHEN** um novo documento didático ou de operação é criado
- **THEN** ele é gravado em `docs/`, nunca na raiz nem em `notas/`
  (exceto o caderno de laboratório)

### Requirement: A VM espelha o repositório

A estrutura de diretórios da VM `pve-lab` SHALL ser idêntica à do repositório
para os quatro diretórios canônicos, para que qualquer verificação de
integridade possa comparar inventários diretamente.

#### Scenario: Comparação em três vias

- **WHEN** o inventário é levantado em Windows, `pve-lab` e GitHub
- **THEN** os três listam os mesmos itens nos mesmos diretórios

### Requirement: Movimentação sem duplicação

Reestruturações SHALL usar movimentação (`mv` — rename atômico no mesmo
sistema de arquivos), nunca cópia, e SHALL registrar hash e contagem de
bytes antes e depois de cada item movido.

#### Scenario: Integridade provada por hash

- **WHEN** um arquivo ou diretório é movido
- **THEN** o hash (ou a contagem de arquivos e bytes) registrado antes
  confere com o registrado depois

#### Scenario: Backup precede ação sem volta

- **WHEN** uma reestruturação será executada em arquivos não rastreados pelo git
- **THEN** um backup `tar.gz` é criado antes do primeiro movimento

### Requirement: Ambiente Python nunca é movido

Um diretório que contenha `.venv` Python SHALL NUNCA ser movido. Quando o
caminho de um ambiente existente mudar, o ambiente SHALL ser recriado com
`rm -rf .venv && uv sync`, regenerando tudo a partir do `uv.lock`.

#### Scenario: Sintoma de shebang invalidado

- **WHEN** após uma mudança de caminho, executar `alembic` (ou outro script
  do `bin/`) retorna `Failed to spawn ... No such file or directory`
- **THEN** o diagnóstico verifica os shebangs de `.venv/bin/*` e a correção
  é a recriação completa do ambiente

#### Scenario: uv sync não é correção suficiente

- **WHEN** `uv sync` responde `Checked N packages` sem reinstalar
- **THEN** o ambiente é considerado **não reparado** e procede-se com a
  recriação do zero

### Requirement: Integração do script de automação

O script `scripts/aiops-lab.sh` SHALL resolver todos os caminhos de trabalho
a partir de variáveis absolutas e SHALL ser executável por
`./scripts/aiops-lab.sh up|down|status|logs|reset` a partir da raiz do
projeto, independentemente do diretório atual.

#### Scenario: Contrato de uso preservado

- **WHEN** `./scripts/aiops-lab.sh up` é executado após uma reestruturação
- **THEN** o comando termina com exit 0 e os serviços respondem
  (`:8000` → 200, `:3001` → 405)

### Requirement: Evidência observável em toda verificação

Toda verificação de integridade SHALL relatar o valor observado (exit code,
HTTP code, hash ou contagem), nunca inferir sucesso por correspondência de
texto. Itens não aplicáveis SHALL permanecer no relatório como
`N/A — motivo`.

#### Scenario: Estado detectado por exit code

- **WHEN** um comando é usado para detectar estado
- **THEN** o código de saída (`$LASTEXITCODE` / `$?`) é o indicador,
  e a saída textual é apenas evidência complementar
