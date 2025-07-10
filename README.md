# Data Full Stack - Portfolio de Projetos de Dados

Portfólio completo de projetos end-to-end usando SQL, Python, dbt, Databricks e Snowflake. Inclui extração API/DW, modelagem de dados, pipelines ETL e dashboards. Construído para uso real, versionado com Git e focado em workflows analíticos limpos e escaláveis.

## 📁 Estrutura dos Projetos

### Adventure Works Analytics
**Localização:** `adventure-works-analytics/`

Pipeline completo de analytics do Adventure Works implementando arquitetura medalhão (Bronze → Silver → Gold) com dbt, incluindo:

- **5 Dimensões Analíticas Avançadas:**
  - `dim_customers_enhanced`: Análise de Customer Lifetime Value (CLV) com segmentação VIP/Premium/Regular/Basic
  - `dim_products_performance`: Análise do ciclo de vida de produtos (Crescimento/Maturidade/Declínio/Descontinuado)
  - `dim_territories_performance`: Análise ROI territorial com rankings de eficiência
  - `dim_channels_performance`: Análise de performance de canais (Online/Reseller)
  - `dim_product_associations`: Market basket analysis com métricas lift/confidence/support

- **Arquitetura Completa:**
  - Staging models (Bronze): Limpeza e padronização de dados brutos
  - Intermediate models (Silver): Lógica de negócio e joins
  - Marts (Gold): Modelos prontos para análise de negócio

- **Recursos Técnicos:**
  - 45+ testes automatizados validados no Databricks
  - CI/CD pipelines com GitHub Actions
  - Orquestração com Apache Airflow
  - Documentação completa em português
  - Configuração Docker para deploy

**Tecnologias:** dbt, SQL, Databricks, Delta Lake, Apache Airflow, Docker, GitHub Actions

## 🚀 Como Usar

### Adventure Works Analytics

```bash
# Navegar para o projeto
cd adventure-works-analytics/

# Instalar dependências dbt
dbt deps

# Executar modelos
dbt run

# Executar testes
dbt test

# Gerar documentação
dbt docs generate && dbt docs serve
```

## 📊 Resultados de Negócio

### Adventure Works Analytics
- **Customer Analytics**: Segmentação de clientes por CLV permitindo estratégias direcionadas
- **Product Analytics**: Identificação de produtos em declínio para otimização de catálogo
- **Territory Analytics**: Rankings de ROI por território para otimização de vendas
- **Channel Analytics**: Comparação de performance Online vs Reseller
- **Market Basket**: Análise de associação de produtos para cross-selling

## 🏗️ Histórico de Migração

Este repositório consolida projetos de dados que anteriormente estavam em repositórios separados:
- Projeto Adventure Works Analytics migrado em Julho 2025
- Estrutura reorganizada para portfolio unificado
- Documentação padronizada em português
- CI/CD pipelines atualizados

## 📝 Próximos Projetos

- [ ] Projeto Snowflake Data Warehouse
- [ ] Pipeline Python ETL com Apache Spark
- [ ] Dashboard Tableau/Power BI
- [ ] ML Pipeline para Customer Churn

---

**Autor:** Diego Brito  
**Data:** Julho 2025  
**Tecnologias:** SQL, Python, dbt, Databricks, Snowflake, Apache Airflow, Docker, GitHub Actions
