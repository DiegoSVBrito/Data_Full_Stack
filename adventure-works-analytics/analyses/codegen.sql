-- Análises de geração de código usando dbt-codegen
-- Execute essas queries para gerar automaticamente documentação e código

-- Gerar documentação YAML para um modelo específico
-- {{ codegen.generate_model_yaml(
--     model_names=['stg_sales__customer']
-- ) }}

-- Gerar source YAML para tabelas existentes
-- {{ codegen.generate_source(
--     schema_name='dev_diego_brito',
--     database_name='ted_dev',
--     generate_columns=true,
--     include_descriptions=true
-- ) }}

-- Gerar base model para uma tabela source
-- {{ codegen.generate_base_model(
--     source_name='adventure_works_dw',
--     table_name='dimcustomer'
-- ) }}

-- Gerar macro para pivotar dados
-- {{ codegen.generate_pivot_macro(
--     column_name='sales_channel',
--     agg='sum',
--     then_value='total_revenue'
-- ) }}