# Adventure Works Analytics - dbt Project

Este projeto implementa um pipeline de dados completo para análise de vendas da Adventure Works, utilizando dbt (Data Build Tool) para transformação e modelagem de dados no Databricks.

## Visão Geral

O projeto segue a arquitetura medallion com três camadas principais:
- **Staging**: Limpeza e padronização dos dados brutos
- **Intermediate**: Lógica de negócio e enriquecimento
- **Marts**: Tabelas de fatos e dimensões para consumo final

## Estrutura do Projeto

```
dbt_project/
├── models/
│   ├── staging/           # Modelos de staging com prefixo stg_
│   │   ├── products/      # Dados de produtos
│   │   ├── sales/         # Dados de vendas
│   │   └── staging.yml    # Documentação dos modelos staging
│   ├── intermediate/      # Modelos intermediários com prefixo int_
│   │   ├── int_sales__enriched.sql
│   │   └── intermediate.yml
│   ├── marts/            # Modelos finais com prefixo fact_/dim_
│   │   ├── sales/        # Fatos de vendas
│   │   └── marts.yml     # Documentação dos modelos marts
│   └── sources/          # Definição das fontes de dados
│       └── sources.yml
├── tests/                # Testes singulares
├── orchestration/        # Configuração de orquestração
│   ├── dags/            # DAGs do Airflow
│   ├── Dockerfile       # Container para orquestração
│   └── docker-compose.yml
├── dbt_project.yml      # Configuração do projeto
└── README.md           # Esta documentação
```

## Configuração do Ambiente

### Pré-requisitos

- Python 3.10+
- Docker e Docker Compose
- Acesso ao Databricks
- Git

### Instalação

1. **Clone o repositório:**
```bash
git clone <repository-url>
cd adventure-works-analytics/dbt_project
```

2. **Crie um ambiente virtual:**
```bash
python -m venv venv
source venv/bin/activate  # Linux/Mac
# ou
venv\Scripts\activate     # Windows
```

3. **Instale as dependências:**
```bash
pip install dbt-databricks==1.6.9
```

4. **Configure o perfil do dbt:**
Crie/edite o arquivo `~/.dbt/profiles.yml`:
```yaml
adventure_works_analytics:
  target: dev
  outputs:
    dev:
      type: databricks
      host: your-databricks-host.cloud.databricks.com
      http_path: /sql/1.0/warehouses/your_warehouse_id
      token: your-databricks-token
      catalog: ted_dev
      schema: dev_diego_brito
      threads: 4
```

## Executando o Pipeline

### Desenvolvimento Local

1. **Limpeza e instalação de dependências:**
```bash
dbt clean
dbt deps
```

2. **Execução por camadas:**
```bash
# Staging
dbt run --select staging
dbt test --select staging

# Intermediate
dbt run --select intermediate
dbt test --select intermediate

# Marts
dbt run --select marts
dbt test --select marts
```

3. **Execução completa:**
```bash
dbt run
dbt test
```

4. **Geração de documentação:**
```bash
dbt docs generate
dbt docs serve
```

### Orquestração com Docker

1. **Navegue para o diretório de orquestração:**
```bash
cd orchestration
```

2. **Configure as variáveis de ambiente:**
```bash
cp .env.example .env
# Edite o arquivo .env com suas credenciais
```

3. **Inicie os serviços:**
```bash
docker-compose up -d
```

4. **Acesse o Airflow:**
- URL: http://localhost:8080
- Usuário: admin
- Senha: admin

5. **Ative a DAG:**
- No Airflow UI, ative a DAG `adventure_works_analytics_pipeline`
- A DAG roda diariamente às 6:00 AM UTC

## Modelos de Dados

### Staging Layer

- **stg_sales__customer**: Dados de clientes com classificações B2B/B2C
- **stg_sales__order_header_dw**: Cabeçalhos de pedidos com métricas temporais
- **stg_sales__order_detail_dw**: Detalhes de pedidos com categorizações
- **stg_sales__territory**: Territórios com agrupamentos regionais
- **stg_products__product**: Produtos com status e preços
- **stg_products__category**: Categorias de produtos

### Intermediate Layer

- **int_sales__enriched**: Visão completa de vendas com todas as dimensões

### Marts Layer

- **fact_sales_transactions**: Fato transacional de vendas
- **fact_sales_monthly_agg**: Agregações mensais por território e canal
- **fact_territorial_performance**: Performance territorial por trimestre

## Testes de Qualidade

### Testes Genéricos
- **unique**: Chaves primárias únicas
- **not_null**: Campos obrigatórios
- **relationships**: Integridade referencial
- **accepted_values**: Valores aceitos em enums

### Testes Singulares
- **assert_positive_line_totals**: Garantir totais de linha positivos
- **assert_order_dates_not_future**: Garantir datas não futuras

## Estrutura de Dados

### Fontes
- **adventure_works_dw**: Dados do data warehouse
- **adventure_works_api**: Dados da API para validação

### Dimensões Temporais
- Ano, mês, trimestre extraídos das datas
- Categorizações de performance temporal

### Métricas de Negócio
- Receita total e média
- Volume de pedidos e clientes únicos
- Segmentação B2B/B2C
- Performance por canal (Online/Offline)

## Monitoramento e Alertas

- **Testes automáticos**: Executados a cada execução
- **Alertas por email**: Configurados no Airflow
- **Logs detalhados**: Disponíveis no Airflow UI
- **Retry automático**: 2 tentativas com 5 minutos de intervalo

## Desenvolvimento

### Adicionando Novos Modelos

1. **Staging**: Adicione em `models/staging/` com prefixo `stg_`
2. **Intermediate**: Adicione em `models/intermediate/` com prefixo `int_`
3. **Marts**: Adicione em `models/marts/` com prefixo `fact_` ou `dim_`

### Convenções de Código

- Use CTEs para organização
- Comentários em português
- Indentação consistente
- Nomes descritivos em snake_case

### Testes

- Adicione testes genéricos no YAML
- Crie testes singulares para lógica específica
- Teste todos os novos modelos

## Troubleshooting

### Problemas Comuns

1. **Erro de conexão Databricks**: Verifique token e host
2. **Modelos não encontrados**: Execute `dbt deps`
3. **Testes falhando**: Verifique qualidade dos dados fonte
4. **Docker issues**: Verifique docker-compose logs

### Logs e Debugging

```bash
# Logs do dbt
dbt run --debug

# Logs do Docker
docker-compose logs -f

# Verificar conexão
dbt debug
```

## Contribuição

1. Crie uma branch para sua feature
2. Faça commits descritivos
3. Execute todos os testes
4. Crie um pull request

## Dependências

- **dbt-databricks**: 1.6.9
- **apache-airflow**: 2.7.1
- **Docker**: Latest
- **Python**: 3.10+

## Suporte

Para dúvidas e suporte:
- Documentação dbt: Acesse via `dbt docs serve`
- Issues do projeto: GitHub Issues
- Contato: analytics-team@aw.com

