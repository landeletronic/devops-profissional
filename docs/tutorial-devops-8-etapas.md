# Tutorial de DevOps: as 8 etapas do ciclo de desenvolvimento

> **Público-alvo:** pessoas que estão começando a estudar DevOps.
>
> **Objetivo:** explicar, de forma gradual, como uma ideia se transforma em software, como esse software é entregue aos usuários e como os dados de operação orientam as próximas melhorias.

## 1. O que é DevOps?

DevOps é uma forma de trabalhar que aproxima as equipes de **desenvolvimento** (*Development*) e **operações** (*Operations*).

Em um modelo tradicional, uma equipe desenvolve o sistema e depois entrega o resultado para outra equipe operar. Essa separação pode causar atrasos, retrabalho e dificuldades para resolver problemas.

No DevOps, as equipes compartilham responsabilidades e utilizam processos automatizados para:

- planejar melhor o trabalho;
- desenvolver e revisar código;
- testar alterações com frequência;
- criar artefatos de software;
- publicar novas versões com segurança;
- manter os sistemas disponíveis;
- observar o comportamento da aplicação;
- aprender com os resultados e melhorar continuamente.

DevOps não é apenas uma ferramenta, um cargo ou um servidor. É a combinação de **cultura, processos, colaboração, automação, métricas e tecnologia**.

## 2. O ciclo infinito de DevOps

O ciclo de DevOps costuma ser representado pelo símbolo do infinito porque não termina após a publicação do software. Depois que a aplicação é colocada em produção, os dados de uso e operação ajudam a planejar a próxima evolução.

```text
[ Planejar ] → [ Codificar ] → [ Construir ] → [ Testar ]
      ↑                                      ↓
[ Monitorar ] ← [ Operar ] ← [ Implantar ] ← [ Liberar ]
```

As oito etapas são:

1. Planejar (*Plan*)
2. Codificar (*Code*)
3. Construir (*Build*)
4. Testar (*Test*)
5. Liberar (*Release*)
6. Implantar (*Deploy*)
7. Operar (*Operate*)
8. Monitorar (*Monitor*)

As etapas são apresentadas em uma ordem didática, mas na prática podem ocorrer de forma interligada e iterativa.

---

## 3. Etapa 1 — Planejar (*Plan*)

### 3.1 Objetivo

Transformar uma necessidade de negócio ou um problema do usuário em um plano de trabalho compreensível para produto, desenvolvimento e operações.

O planejamento deve responder a perguntas como:

- Qual problema será resolvido?
- Quem é o usuário?
- Qual é o resultado esperado?
- O que precisa ser feito primeiro?
- Como saberemos se a solução funcionou?
- Quais riscos, dependências e restrições existem?

### 3.2 Relação com MVP e PRD

Um **PRD** (*Product Requirements Document*) descreve o que o produto ou funcionalidade deve fazer e por que isso é necessário.

Um **MVP** (*Minimum Viable Product*) é a menor versão do produto capaz de entregar valor real e gerar aprendizado com usuários.

No contexto DevOps, o planejamento deve ser enxuto. Em vez de tentar especificar todo o produto por muitos anos, o time define um escopo inicial, critérios de aceite, métricas e condições para uma entrega segura.

### 3.3 Atividades comuns

- entender o problema do usuário;
- definir objetivos e resultados esperados;
- dividir o trabalho em funcionalidades menores;
- criar histórias de usuário;
- definir critérios de aceite;
- organizar o backlog;
- identificar riscos e dependências;
- definir métricas de sucesso;
- planejar a infraestrutura mínima necessária;
- priorizar o que será feito no próximo ciclo.

### 3.4 Documentações e artefatos

- PRD;
- escopo do MVP;
- histórias de usuário;
- backlog;
- critérios de aceite;
- plano de release;
- registro de riscos e dependências;
- plano de métricas e telemetria;
- decisões de arquitetura, quando necessário.

### 3.5 Ferramentas comuns

- Jira;
- Azure Boards;
- Trello;
- GitHub Issues e Projects;
- GitLab Issues;
- Notion;
- documentação em Markdown.

### 3.6 Resultado esperado

Ao final dessa etapa, o time deve saber **o que será entregue, para quem, por que é importante e como o resultado será avaliado**.

---

## 4. Etapa 2 — Codificar (*Code*)

### 4.1 Objetivo

Transformar o plano em código-fonte versionado, revisável e reproduzível.

O código precisa ser compreensível não apenas para quem o escreveu, mas também para outras pessoas que precisarão corrigi-lo, testá-lo ou operá-lo.

### 4.2 Atividades comuns

- criar ou atualizar uma branch;
- implementar funcionalidades;
- escrever testes junto com o código;
- utilizar padrões de codificação;
- executar linters e formatadores;
- revisar o código de outras pessoas;
- registrar alterações no Git;
- atualizar a documentação técnica;
- remover credenciais e dados sensíveis do código.

### 4.3 Controle de versão

O **Git** registra a evolução dos arquivos do projeto. Um fluxo básico pode ser:

```bash
git checkout -b feat/nova-funcionalidade
# editar arquivos
git add .
git commit -m "feat: adiciona nova funcionalidade"
git push -u origin feat/nova-funcionalidade
```

Depois, a alteração pode ser submetida para revisão por meio de um pull request.

### 4.4 Documentações e artefatos

- `README.md`;
- guia de contribuição;
- guia de estilo de código;
- configuração de linters e formatadores;
- estratégia de branches;
- documentação de APIs;
- decisões de arquitetura;
- comentários e docstrings quando necessários;
- arquivo `.env.example` sem segredos reais;
- pull request e descrição da alteração.

### 4.5 Boas práticas de segurança

- nunca versionar senhas, tokens ou chaves privadas;
- revisar arquivos antes do commit;
- utilizar variáveis de ambiente ou gerenciadores de segredos;
- limitar permissões de usuários e tokens;
- manter dependências atualizadas;
- revisar dependências de terceiros;
- proteger a branch principal.

### 4.6 Resultado esperado

Ao final dessa etapa, existe uma alteração versionada, revisada e pronta para ser compilada ou empacotada automaticamente.

---

## 5. Etapa 3 — Construir (*Build*)

### 5.1 Objetivo

Transformar o código-fonte em um artefato que possa ser testado e, posteriormente, implantado.

Um artefato pode ser, por exemplo:

- um pacote compilado;
- uma imagem de container;
- um arquivo `.jar`;
- um pacote Python;
- um aplicativo mobile;
- arquivos estáticos para uma aplicação web.

### 5.2 Integração Contínua

Na **Integração Contínua** (*Continuous Integration — CI*), cada alteração enviada ao repositório pode iniciar automaticamente uma sequência de validações.

Uma pipeline de CI normalmente executa:

1. checkout do código;
2. instalação de dependências;
3. análise estática;
4. compilação ou empacotamento;
5. testes automatizados;
6. verificações de segurança;
7. publicação do artefato.

### 5.3 Documentações e artefatos

- `Dockerfile`;
- `compose.yaml` ou `docker-compose.yml`, quando aplicável;
- pipeline do GitHub Actions;
- `.gitlab-ci.yml`;
- `Jenkinsfile`;
- scripts de build;
- manifesto de dependências;
- manifesto de container;
- relatório de build;
- registro de versão do artefato.

### 5.4 Ferramentas comuns

- Docker;
- GitHub Actions;
- GitLab CI/CD;
- Jenkins;
- Azure Pipelines;
- Maven;
- Gradle;
- npm;
- Poetry;
- Kaniko ou Buildah.

### 5.5 Boas práticas

- manter builds reproduzíveis;
- fixar versões de dependências importantes;
- evitar credenciais em arquivos de pipeline;
- armazenar artefatos em um registry;
- identificar cada artefato com versão ou digest;
- não depender de imagens ou pacotes sem versão definida;
- separar configuração de código.

### 5.6 Resultado esperado

Ao final dessa etapa, o time possui um artefato identificável e pode reproduzir o processo de construção em um ambiente automatizado.

---

## 6. Etapa 4 — Testar (*Test*)

### 6.1 Objetivo

Verificar se o software atende aos requisitos e se as alterações não introduziram problemas conhecidos.

Testar não significa apenas clicar na aplicação. Os testes devem ser planejados e automatizados sempre que possível.

### 6.2 Tipos de teste

| Tipo | O que verifica |
|---|---|
| **Teste unitário** | Verifica uma função ou componente isolado. |
| **Teste de integração** | Verifica a comunicação entre componentes, serviços ou banco de dados. |
| **Teste de contrato** | Verifica se dois serviços continuam obedecendo ao mesmo contrato de comunicação. |
| **Teste funcional** | Verifica uma funcionalidade do ponto de vista do comportamento esperado. |
| **Teste end-to-end** | Simula um fluxo completo do usuário. |
| **Teste de carga** | Avalia o comportamento sob volume de requisições ou usuários. |
| **Teste de segurança** | Procura vulnerabilidades em código, dependências e aplicação. |
| **Teste de recuperação** | Verifica se o sistema consegue voltar a operar após uma falha. |

### 6.3 Shift-left

**Shift-left** significa antecipar a identificação de problemas para as fases iniciais do ciclo. Encontrar um erro durante a codificação ou na pipeline costuma ser menos caro do que descobrir o mesmo erro depois de uma publicação em produção.

### 6.4 Documentações e artefatos

- plano de testes;
- matriz de testes;
- casos de teste;
- critérios de aceite;
- relatórios de cobertura;
- relatórios de qualidade;
- relatórios de vulnerabilidade;
- registros de testes de carga;
- evidências de testes manuais, quando necessários;
- resultado dos quality gates.

### 6.5 Ferramentas comuns

- JUnit;
- pytest;
- Jest;
- Selenium;
- Cypress;
- Playwright;
- SonarQube;
- Trivy;
- OWASP ZAP;
- k6.

### 6.6 Resultado esperado

Ao final dessa etapa, existem evidências de que o artefato atende aos critérios definidos e está suficientemente seguro e estável para avançar no processo.

---

## 7. Etapa 5 — Liberar (*Release*)

### 7.1 Objetivo

Preparar uma versão testada para ser disponibilizada ao ambiente de implantação.

A liberação é diferente da implantação. A liberação define que uma versão está pronta; a implantação coloca essa versão em um ambiente.

### 7.2 Atividades comuns

- validar os resultados da pipeline;
- revisar alterações incluídas;
- criar uma versão numerada;
- gerar changelog ou release notes;
- verificar compatibilidade e migrações;
- confirmar o plano de rollback;
- obter aprovação quando exigida;
- registrar a versão no sistema de releases.

### 7.3 Estratégias de liberação

- **Big bang:** toda a alteração é disponibilizada de uma só vez;
- **feature flag:** o código é implantado, mas a funcionalidade pode permanecer desativada;
- **canary release:** a versão é liberada inicialmente para uma pequena parcela dos usuários;
- **blue-green:** dois ambientes existem e o tráfego pode ser alternado entre eles;
- **rolling release:** os servidores são atualizados gradualmente.

### 7.4 Documentações e artefatos

- changelog;
- release notes;
- tag do Git;
- plano de release;
- roteiro de implantação;
- roteiro de rollback;
- aprovação de mudança;
- registro de compatibilidade;
- lista de alterações conhecidas.

### 7.5 Resultado esperado

Ao final dessa etapa, existe uma versão identificada, testada e aprovada para ser implantada.

---

## 8. Etapa 6 — Implantar (*Deploy*)

### 8.1 Objetivo

Publicar o artefato em um ambiente, como desenvolvimento, homologação ou produção.

Uma implantação bem automatizada deve ser repetível. O processo não deve depender de uma sequência de comandos executados manualmente por uma única pessoa.

### 8.2 Ambientes comuns

| Ambiente | Finalidade |
|---|---|
| **Desenvolvimento** | Permitir que o time implemente e faça testes iniciais. |
| **Teste** | Executar validações automatizadas e integradas. |
| **Homologação** | Validar o comportamento próximo da produção. |
| **Produção** | Atender usuários reais. |

### 8.3 Infraestrutura como Código

**Infraestrutura como Código** (*Infrastructure as Code — IaC*) é a prática de declarar servidores, redes, bancos, permissões e outros recursos em arquivos versionados.

Isso permite:

- revisar mudanças de infraestrutura;
- reproduzir ambientes;
- reduzir configuração manual;
- auditar alterações;
- automatizar a criação e atualização dos recursos.

### 8.4 Documentações e artefatos

- arquivos Terraform;
- playbooks Ansible;
- templates CloudFormation;
- manifestos Kubernetes;
- Helm charts;
- arquivos de pipeline de deploy;
- diagrama de arquitetura;
- inventário de ambientes;
- plano de rollback;
- registro de configuração.

### 8.5 Estratégias comuns

- **Blue-green:** alternância entre dois ambientes semelhantes;
- **Canary:** implantação gradual para uma parcela do tráfego;
- **Rolling update:** atualização progressiva dos nós ou instâncias;
- **Recreate:** parada do ambiente anterior antes da criação do novo;
- **Deploy com feature flag:** código implantado, funcionalidade controlada por configuração.

### 8.6 Ferramentas comuns

- Kubernetes;
- Terraform;
- OpenTofu;
- Ansible;
- AWS, Azure e Google Cloud;
- Argo CD;
- Flux;
- Helm;
- Docker.

### 8.7 Resultado esperado

Ao final dessa etapa, a versão está disponível no ambiente desejado e existem mecanismos para verificar sua saúde e retornar à versão anterior, se necessário.

---

## 9. Etapa 7 — Operar (*Operate*)

### 9.1 Objetivo

Manter a aplicação disponível, segura, performática e capaz de atender à demanda real.

Operar não é apenas ligar servidores. Também envolve cuidar de capacidade, custos, atualizações, backups, permissões e resposta a incidentes.

### 9.2 Atividades comuns

- administrar servidores, containers e clusters;
- gerenciar configurações;
- aplicar atualizações de segurança;
- verificar backups;
- testar restaurações;
- ajustar capacidade e escalabilidade;
- gerenciar certificados;
- acompanhar custos;
- responder a incidentes;
- executar procedimentos operacionais;
- manter acessos e permissões sob controle.

### 9.3 Documentações e artefatos

- runbook;
- playbook operacional;
- procedimento de resposta a incidentes;
- plano de continuidade;
- plano de recuperação de desastre;
- política de backup;
- inventário de ativos;
- mapa de dependências;
- políticas de SLA, SLO e SLI;
- registros de incidentes;
- post-mortem.

### 9.4 SLA, SLO e SLI

- **SLI:** indicador que mede um aspecto do serviço, como disponibilidade ou latência;
- **SLO:** objetivo definido para esse indicador, como disponibilidade de 99,9%;
- **SLA:** compromisso formal firmado com o cliente ou negócio, normalmente com consequências em caso de descumprimento.

### 9.5 Ferramentas comuns

- Kubernetes;
- AWS CloudWatch;
- Azure Monitor;
- Google Cloud Monitoring;
- PagerDuty;
- Ansible;
- sistemas de backup;
- gerenciadores de segredos;
- plataformas de gerenciamento de incidentes.

### 9.6 Resultado esperado

Ao final dessa etapa, o serviço está sendo mantido de maneira previsível, com procedimentos conhecidos para operações normais e situações de falha.

---

## 10. Etapa 8 — Monitorar (*Monitor*)

### 10.1 Objetivo

Coletar e interpretar dados sobre a saúde do sistema, o desempenho da aplicação e a experiência dos usuários.

O monitoramento fecha o ciclo porque seus dados ajudam a decidir o que será planejado no próximo ciclo.

### 10.2 Os três pilares da observabilidade

| Pilar | O que representa |
|---|---|
| **Métricas** | Valores numéricos ao longo do tempo, como CPU, memória, latência e taxa de erros. |
| **Logs** | Registros de eventos produzidos pela aplicação e pela infraestrutura. |
| **Traces** | Rastreamento de uma requisição através de vários serviços. |

A observabilidade também pode incluir informações de negócio, como conversões, abandono de uma etapa do fluxo ou quantidade de usuários ativos.

### 10.3 O que monitorar?

- disponibilidade;
- latência;
- taxa de erros;
- saturação de recursos;
- uso de CPU e memória;
- filas e conexões;
- espaço em disco;
- estado de bancos de dados;
- falhas de dependências externas;
- experiência do usuário;
- indicadores de negócio;
- segurança e eventos suspeitos.

### 10.4 Alertas

Um alerta deve representar uma situação que exige ação. Alertas em excesso causam fadiga e podem fazer com que incidentes importantes sejam ignorados.

Um bom alerta informa:

- o que aconteceu;
- qual serviço foi afetado;
- qual é a severidade;
- desde quando ocorre;
- qual impacto provável existe;
- onde encontrar mais informações;
- qual runbook deve ser seguido.

### 10.5 Documentações e artefatos

- matriz de monitoramento;
- catálogo de alertas;
- dashboards;
- definição de métricas;
- regras de alerta;
- documentação de logs;
- documentação de traces;
- relatório de disponibilidade;
- relatório de incidentes;
- post-mortem;
- plano de ações corretivas.

### 10.6 Ferramentas comuns

- Prometheus;
- Grafana;
- Datadog;
- Elasticsearch, Logstash e Kibana;
- OpenTelemetry;
- Jaeger;
- Loki;
- New Relic;
- Sentry;
- PagerDuty.

### 10.7 Resultado esperado

Ao final dessa etapa, o time consegue identificar problemas, medir o impacto, responder com rapidez e transformar dados operacionais em melhorias para o próximo planejamento.

---

## 11. Documentação por etapa: visão consolidada

| Etapa | Documentações e artefatos principais |
|---|---|
| **Planejar** | PRD, escopo do MVP, backlog, histórias de usuário, critérios de aceite, riscos e métricas. |
| **Codificar** | README, guia de contribuição, estilo de código, estratégia de branches, documentação de API e pull request. |
| **Construir** | Dockerfile, pipeline de CI, scripts de build, manifesto de dependências e registro do artefato. |
| **Testar** | Plano de testes, matriz de testes, casos de teste, cobertura, qualidade e vulnerabilidades. |
| **Liberar** | Changelog, release notes, tag, plano de release, aprovação e roteiro de rollback. |
| **Implantar** | IaC, manifestos, Helm charts, pipeline de deploy, diagrama de arquitetura e inventário de ambientes. |
| **Operar** | Runbook, playbook, backups, continuidade, recuperação de desastre, SLA/SLO/SLI e incidentes. |
| **Monitorar** | Dashboards, métricas, logs, traces, alertas, matriz de monitoramento e post-mortems. |

## 12. Exemplo de fluxo completo

Imagine que o time precise criar uma tela de cadastro de usuários.

1. **Planejar:** definir o problema, os campos necessários, os critérios de aceite e a métrica de sucesso.
2. **Codificar:** criar a branch, implementar a tela e a API, escrever testes e abrir um pull request.
3. **Construir:** a pipeline instala dependências, executa o build e cria uma imagem de container.
4. **Testar:** testes unitários, integração, segurança e fluxo completo são executados.
5. **Liberar:** a versão recebe uma tag, release notes e um plano de rollback.
6. **Implantar:** a nova imagem é publicada primeiro em homologação e depois em produção.
7. **Operar:** o time acompanha a aplicação, backups, capacidade e erros.
8. **Monitorar:** dashboards mostram conversões, erros, latência e abandono do cadastro. Esses dados alimentam o próximo planejamento.

## 13. Segurança ao longo de todo o ciclo

Segurança não deve ficar apenas na última etapa. Ela deve estar presente em todo o ciclo:

- **Planejar:** identificar riscos e requisitos de segurança;
- **Codificar:** revisar código e evitar segredos no repositório;
- **Construir:** analisar dependências e imagens de container;
- **Testar:** executar SAST, DAST e testes de dependências;
- **Liberar:** revisar vulnerabilidades e aprovações;
- **Implantar:** aplicar menor privilégio e configurações seguras;
- **Operar:** corrigir vulnerabilidades, gerenciar acessos e realizar backups;
- **Monitorar:** detectar comportamentos suspeitos e responder a incidentes.

Esse conjunto de práticas é frequentemente associado ao conceito de **DevSecOps**.

## 14. Indicadores úteis para acompanhar o fluxo

Além das métricas da aplicação, o time pode acompanhar indicadores de entrega, conhecidos como métricas DORA:

- frequência de implantação;
- tempo de entrega de uma alteração;
- taxa de falha de mudanças;
- tempo médio para restaurar o serviço.

Esses indicadores não devem ser usados para punir pessoas. Eles ajudam a encontrar gargalos no processo e orientar melhorias.

Também podem ser acompanhados:

- tempo de execução das pipelines;
- quantidade de alterações pendentes;
- cobertura de testes;
- quantidade de vulnerabilidades abertas;
- disponibilidade do serviço;
- custo da infraestrutura;
- satisfação dos usuários.

## 15. Checklist inicial para quem está aprendendo

### Planejar

- [ ] O problema está descrito?
- [ ] O usuário está identificado?
- [ ] O escopo inicial está claro?
- [ ] Existem critérios de aceite?

### Codificar

- [ ] O código está em controle de versão?
- [ ] A alteração está em uma branch apropriada?
- [ ] Não há segredos no repositório?
- [ ] Existe revisão por pull request?

### Construir e testar

- [ ] O projeto pode ser construído automaticamente?
- [ ] Existem testes automatizados?
- [ ] A pipeline falha quando uma validação importante falha?
- [ ] O artefato possui uma versão identificável?

### Liberar e implantar

- [ ] A versão possui changelog ou release notes?
- [ ] Existe um plano de rollback?
- [ ] A infraestrutura está documentada ou declarada como código?
- [ ] A implantação pode ser repetida?

### Operar e monitorar

- [ ] Existem backups e restaurações testadas?
- [ ] Há métricas, logs e alertas úteis?
- [ ] Existe um runbook para problemas comuns?
- [ ] O time sabe como responder a um incidente?

## 16. Conclusão

O ciclo DevOps conecta planejamento, desenvolvimento, entrega e operação em um processo contínuo de aprendizado.

As oito etapas não devem ser tratadas como departamentos isolados. O resultado melhora quando:

- Produto explica o problema e o valor esperado;
- Desenvolvimento cria código sustentável;
- Qualidade ajuda a prevenir falhas;
- Segurança participa desde o início;
- Operações contribuem para uma execução confiável;
- Dados de monitoramento orientam as próximas decisões.

O objetivo final não é apenas publicar software rapidamente. É entregar valor com segurança, qualidade, previsibilidade e capacidade de aprender com o uso real.

## Referência

Este tutorial foi elaborado com base no conteúdo do arquivo `devops_graphics.md`, que apresenta o ciclo DevOps, suas oito etapas, documentações e práticas relacionadas a MVP, PRD, CI/CD, IaC, observabilidade e operação.
