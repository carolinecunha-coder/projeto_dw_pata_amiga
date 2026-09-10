-- =====================================================================================
--  00-CONFERENCIA.SQL   -   RODE DEPOIS DE CADA ETAPA
--  Case: Pata Amiga  |  PostgreSQL 16
-- =====================================================================================
--  Arquivo de conferencia (nao faz parte da entrega).
--
--  Cada bloco tem o valor esperado ao lado. Rode o bloco correspondente logo
--  depois de cada arquivo. Se um numero nao bater, corrija antes de seguir: os
--  arquivos dependem uns dos outros.
--
--  A contagem de linhas da dim_categoria depende do banco: o PostgreSQL compara
--  byte a byte, entao separa 'Racao' de 'RACAO' e o DISTINCT devolve MAIS linhas
--  do que o MySQL. O teste que vale e o das 7 categorias PADRONIZADAS, nao o
--  numero de linhas.
-- =====================================================================================

-- =====================================================================================
--  DEPOIS DO 01 - A STAGING
-- =====================================================================================
SELECT 'stg_pedido'     AS tabela, COUNT(*) AS linhas, 4044 AS esperado FROM stg_pedido
UNION ALL SELECT 'stg_loja',       COUNT(*), 32 FROM stg_loja
UNION ALL SELECT 'stg_loja_praca', COUNT(*), 48 FROM stg_loja_praca;

-- Diagnostico da Tarefa 1. Estes numeros vao para o README.
SELECT 'grafias distintas de categoria (no PostgreSQL)' AS diagnostico,
       COUNT(DISTINCT "CategoriaProduto") AS valor, '37' AS esperado FROM stg_pedido
UNION ALL SELECT 'grafias distintas de nome de loja',
       COUNT(DISTINCT "Loja-Nome"), '(conte e descreva)' FROM stg_pedido
UNION ALL SELECT 'grafias distintas de HouveDesconto',
       COUNT(DISTINCT "HouveDesconto"), '(conte)' FROM stg_pedido
UNION ALL SELECT 'grafias distintas de CanalPedido',
       COUNT(DISTINCT "CanalPedido"), '(conte)' FROM stg_pedido
UNION ALL SELECT 'pedidos sem Cod Loja preenchido',
       SUM(CASE WHEN "Cod Loja" = '' THEN 1 ELSE 0 END), '1575  (~39%)' FROM stg_pedido
UNION ALL SELECT 'pedidos sem nome de loja (vao para a -1)',
       SUM(CASE WHEN "Loja-Nome" = '' THEN 1 ELSE 0 END), '3' FROM stg_pedido;

-- Os quatro marcos em branco = processo em aberto. Vao virar dias NULL.
SELECT 'Dt Separacao Estoque' AS marco,
       SUM(CASE WHEN "Dt Separacao Estoque" = '' THEN 1 ELSE 0 END) AS em_branco,
       1077 AS esperado FROM stg_pedido
UNION ALL SELECT 'DtNotaFiscal',
       SUM(CASE WHEN "DtNotaFiscal" = '' THEN 1 ELSE 0 END), 1338 FROM stg_pedido
UNION ALL SELECT 'Dt_Despacho_Transportadora',
       SUM(CASE WHEN "Dt_Despacho_Transportadora" = '' THEN 1 ELSE 0 END), 1665 FROM stg_pedido
UNION ALL SELECT 'DtEntregaCliente',
       SUM(CASE WHEN "DtEntregaCliente" = '' THEN 1 ELSE 0 END), 1953 FROM stg_pedido;

-- Conferencia da mascara de data. Rode antes de escrever a fato.
-- A data do pedido esta no formato americano ('MM/DD/YYYY'): esta contagem deve
-- dar 4044. A mascara brasileira ('DD/MM/YYYY') nao serve - e no PostgreSQL ela
-- nao devolve NULL: ela LANCA ERRO nas datas com mes maior que 12. O erro
-- aparece na hora, e e esse o aviso.
SELECT COUNT(*) AS mascara_americana_ok, '4044' AS esperado
FROM stg_pedido
WHERE TO_TIMESTAMP("DtHoraPedido", 'MM/DD/YYYY HH12:MI AM') IS NOT NULL;

-- =====================================================================================
--  DEPOIS DO 02 - O QUE VEIO PRONTO
-- =====================================================================================
SELECT 'dim_tempo' AS tabela, COUNT(*) AS linhas, '236  (235 dias + a -1)' AS esperado
FROM dim_tempo
UNION ALL SELECT 'dim_loja', COUNT(*), '33  (32 lojas + a -1)' FROM dim_loja;

-- As quatro tabelas ja existem e estao VAZIAS. Todas devem dar zero.
SELECT 'dim_categoria' AS tabela, COUNT(*) AS deve_estar_vazia FROM dim_categoria
UNION ALL SELECT 'dim_praca',         COUNT(*) FROM dim_praca
UNION ALL SELECT 'bridge_loja_praca', COUNT(*) FROM bridge_loja_praca
UNION ALL SELECT 'fato_pedido',       COUNT(*) FROM fato_pedido;

-- =====================================================================================
--  DEPOIS DO 03 - AS SUAS DIMENSOES
-- =====================================================================================
SELECT 'dim_categoria'     AS tabela, COUNT(*) AS linhas,
       '38 no PostgreSQL - varia por banco' AS esperado FROM dim_categoria
UNION ALL SELECT 'dim_praca',         COUNT(*), '13  (12 pracas + a -1)' FROM dim_praca
UNION ALL SELECT 'bridge_loja_praca', COUNT(*), '48' FROM bridge_loja_praca;

-- ESTE e o teste que vale nota, e ele NAO muda de banco para banco.
SELECT COUNT(DISTINCT nome_categoria) AS categorias_padronizadas,
       '8 = as 7 categorias + a linha -1' AS esperado FROM dim_categoria;

-- Se aparecer 'Nao Informado' numa linha que nao e a -1, algum WHEN do CASE nao
-- classificou a grafia. A consulta deve voltar VAZIA.
SELECT categoria_origem, nome_categoria FROM dim_categoria
WHERE nome_categoria = 'Nao Informado' AND sk_categoria <> -1;

-- Ordem do CASE, teste 1: "Racao Medicamentosa" deve ser Medicamento.
-- Se aparecer 'Racao' na segunda coluna, o CASE testou RA antes de MED.
SELECT categoria_origem, nome_categoria, 'Medicamento' AS esperado
FROM dim_categoria WHERE UPPER(categoria_origem) LIKE '%MEDICAMENTOSA%';


-- A ponte: o fator deve somar 1,00 em cada loja. A consulta deve voltar VAZIA.
SELECT cod_loja, ROUND(SUM(fator_publico), 4) AS soma_dos_fatores
FROM bridge_loja_praca GROUP BY cod_loja
HAVING ROUND(SUM(fator_publico), 4) <> 1;

-- As 32 lojas devem estar na ponte, e toda praca deve ter pelo menos uma loja.
SELECT 'lojas na ponte' AS teste, COUNT(DISTINCT cod_loja) AS valor, '32' AS esperado
FROM bridge_loja_praca
UNION ALL SELECT 'pracas na ponte', COUNT(DISTINCT sk_praca), '12' FROM bridge_loja_praca;

-- Toda dimensao precisa da linha -1. As duas devem aparecer aqui.
SELECT 'dim_categoria' AS dimensao, COUNT(*) AS tem_a_linha_menos_1
FROM dim_categoria WHERE sk_categoria = -1
UNION ALL SELECT 'dim_praca',       COUNT(*) FROM dim_praca       WHERE sk_praca = -1;

-- =====================================================================================
--  DEPOIS DO 04 - A FATO
-- =====================================================================================
SELECT COUNT(*) AS linhas, '4044' AS esperado FROM fato_pedido;
-- Mais que 4.044 indica JOIN duplicando; menos, JOIN descartando linha.

-- Nenhuma FK pode ser nula, e nenhuma pode apontar para chave inexistente.
SELECT 'FK nula' AS teste, COUNT(*) AS deve_ser_zero FROM fato_pedido
WHERE sk_loja IS NULL OR sk_categoria IS NULL
   OR sk_tempo_pedido IS NULL OR sk_tempo_entrega IS NULL
UNION ALL SELECT 'FK orfa (loja)', COUNT(*)
FROM fato_pedido f LEFT JOIN dim_loja d ON d.sk_loja = f.sk_loja
WHERE d.sk_loja IS NULL
UNION ALL SELECT 'FK orfa (categoria)', COUNT(*)
FROM fato_pedido f LEFT JOIN dim_categoria d ON d.sk_categoria = f.sk_categoria
WHERE d.sk_categoria IS NULL
UNION ALL SELECT 'FK orfa (tempo da entrega)', COUNT(*)
FROM fato_pedido f LEFT JOIN dim_tempo d ON d.sk_tempo = f.sk_tempo_entrega
WHERE d.sk_tempo IS NULL;

-- Estes valores nao sao zero, e estao corretos assim.
SELECT 'pedidos sem loja (na linha -1)' AS informativo, COUNT(*) AS valor,
       '3' AS esperado FROM fato_pedido WHERE sk_loja = -1
UNION ALL SELECT 'entregas ainda nao feitas (tempo na -1)', COUNT(*), '1953'
FROM fato_pedido WHERE sk_tempo_entrega = -1;

-- Ordem do CASE do canal (arquivo 04): o WhatsApp tem de aparecer na fato.
-- Se esta consulta voltar VAZIA, o CASE testou APP antes de WHATS e os pedidos
-- de WhatsApp foram parar dentro do App.
SELECT canal_pedido, COUNT(*) AS pedidos FROM fato_pedido
WHERE canal_pedido = 'WhatsApp' GROUP BY canal_pedido;

-- Periodo dos pedidos: deve ir de 01/09/2023 a 31/03/2024. Data minima ou
-- maxima fora disso indica mascara de data errada.
SELECT MIN(dt_pedido::date) AS primeiro_pedido, MAX(dt_pedido::date) AS ultimo_pedido,
       '2023-09-01 a 2024-03-31' AS esperado FROM fato_pedido;

-- Os dias nunca podem ser negativos: o processo e sequencial.
SELECT 'dias negativos' AS teste, COUNT(*) AS deve_ser_zero FROM fato_pedido
WHERE dias_integracao_separacao < 0 OR dias_separacao_nota < 0
   OR dias_nota_despacho < 0 OR dias_despacho_entrega < 0
   OR dias_total_ate_entrega < 0;

-- =====================================================================================
--  DEPOIS DO 05 - AS RESPOSTAS
-- =====================================================================================
-- Confira que a soma da tabela fecha com o total da fato. Se nao fechar, algum
-- JOIN esta descartando linha.
SELECT
    (SELECT ROUND(SUM(vl_liquido)) FROM fato_pedido)             AS total_na_fato,
    (SELECT ROUND(SUM(f.vl_liquido)) FROM fato_pedido f
       JOIN dim_categoria c ON c.sk_categoria = f.sk_categoria)  AS total_pela_P2;
-- As duas colunas devem dar o mesmo numero.

-- Rateio da P4: com o fator, a soma por praca mais os pedidos sem loja fecha
-- com o total da rede. A ultima coluna deve dar ZERO.
-- A diferenca e arredondada UMA vez (nao cada soma em separado): assim o
-- arredondamento nao deixa sobrar 1 ou 2 reais que na verdade fecham exato.
SELECT
    (SELECT ROUND(SUM(vl_liquido)) FROM fato_pedido) AS total_da_rede,
    (SELECT ROUND(SUM(f.vl_liquido * b.fator_publico))
       FROM fato_pedido f
       JOIN dim_loja l ON l.sk_loja = f.sk_loja
       JOIN bridge_loja_praca b ON b.cod_loja = l.cod_loja) AS soma_rateada,
    (SELECT ROUND(SUM(vl_liquido)) FROM fato_pedido WHERE sk_loja = -1) AS sem_loja,
    ROUND(
        (SELECT SUM(vl_liquido) FROM fato_pedido)
        - (SELECT SUM(f.vl_liquido * b.fator_publico)
             FROM fato_pedido f
             JOIN dim_loja l ON l.sk_loja = f.sk_loja
             JOIN bridge_loja_praca b ON b.cod_loja = l.cod_loja)
        - (SELECT SUM(vl_liquido) FROM fato_pedido WHERE sk_loja = -1)
    )                                                AS tem_de_dar_ZERO;
