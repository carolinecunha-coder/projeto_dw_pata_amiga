-- ============================================================
-- P1 - TEMPO MÉDIO DO PEDIDO ATÉ A ENTREGA
-- ============================================================

SELECT
    dl.porte,
    ROUND(AVG(fp.dias_integracao_separacao), 2) AS media_integracao_separacao,
    ROUND(AVG(fp.dias_separacao_nota), 2) AS media_separacao_nota,
    ROUND(AVG(fp.dias_nota_despacho), 2) AS media_nota_despacho,
    ROUND(AVG(fp.dias_despacho_entrega), 2) AS media_despacho_entrega,
    ROUND(AVG(fp.dias_total_ate_entrega), 2) AS media_total_ate_entrega
FROM fato_pedido fp
LEFT JOIN dim_loja dl
    ON fp.sk_loja = dl.sk_loja
WHERE fp.dias_total_ate_entrega IS NOT NULL
GROUP BY dl.porte
ORDER BY dl.porte;


-- ============================================================
-- P2 - FATURAMENTO POR CATEGORIA
-- Percentual de participação no faturamento total da rede
-- ============================================================

SELECT
    dc.nome_categoria,
    SUM(fp.vl_liquido) AS faturamento_categoria,
    ROUND(
        100.0 * SUM(fp.vl_liquido)
        / SUM(SUM(fp.vl_liquido)) OVER (),
        2
    ) AS percentual_faturamento
FROM fato_pedido fp
LEFT JOIN dim_categoria dc
    ON fp.sk_categoria = dc.sk_categoria
WHERE fp.vl_liquido IS NOT NULL
GROUP BY dc.nome_categoria
ORDER BY faturamento_categoria DESC;


-- ============================================================
-- P2 - CATEGORIA CAMPEÃ POR PORTE DA LOJA
-- ============================================================

SELECT
    porte,
    nome_categoria,
    faturamento_categoria
FROM (
    SELECT
        dl.porte,
        dc.nome_categoria,
        SUM(fp.vl_liquido) AS faturamento_categoria,
        RANK() OVER (
            PARTITION BY dl.porte
            ORDER BY SUM(fp.vl_liquido) DESC
        ) AS posicao
    FROM fato_pedido fp
    LEFT JOIN dim_loja dl
        ON fp.sk_loja = dl.sk_loja
    LEFT JOIN dim_categoria dc
        ON fp.sk_categoria = dc.sk_categoria
    WHERE fp.vl_liquido IS NOT NULL
      AND dl.porte IN ('Grande', 'Media', 'Pequena')
      AND dc.nome_categoria <> 'Nao Informado'
    GROUP BY
        dl.porte,
        dc.nome_categoria
) AS ranking
WHERE posicao = 1
ORDER BY porte;

-- ============================================================
-- P3 - TICKET MÉDIO COM E SEM DESCONTO POR CANAL
-- ============================================================

SELECT
    canal_pedido,
    houve_desconto,
    COUNT(*) AS quantidade_pedidos,
    ROUND(AVG(vl_liquido), 2) AS ticket_medio
FROM fato_pedido
WHERE canal_pedido IN (
    'App',
    'Site',
    'Loja Fisica',
    'Telefone',
    'WhatsApp'
)
AND vl_liquido IS NOT NULL
GROUP BY
    canal_pedido,
    houve_desconto
ORDER BY
    canal_pedido,
    houve_desconto;


-- ============================================================
-- P3 - PARTICIPAÇÃO DO FATURAMENTO POR CANAL
-- ============================================================

SELECT
    canal_pedido,
    SUM(vl_liquido) AS faturamento_canal,
    ROUND(
        100.0 * SUM(vl_liquido)
        / SUM(SUM(vl_liquido)) OVER (),
        2
    ) AS percentual_faturamento
FROM fato_pedido
WHERE canal_pedido IN (
    'App',
    'Site',
    'Loja Fisica',
    'Telefone',
    'WhatsApp'
)
AND vl_liquido IS NOT NULL
GROUP BY canal_pedido
ORDER BY faturamento_canal DESC;


-- ============================================================
-- P4 - FATURAMENTO RATEADO POR PRAÇA
-- Rateio pelo percentual do público
-- ============================================================

SELECT
    dp.nome_praca,
    ROUND(
        SUM(fp.vl_liquido * blp.fator_publico),
        2
    ) AS faturamento_rateado
FROM fato_pedido fp
JOIN dim_loja dl
    ON fp.sk_loja = dl.sk_loja
JOIN bridge_loja_praca blp
    ON dl.cod_loja = blp.cod_loja
JOIN dim_praca dp
    ON blp.sk_praca = dp.sk_praca
WHERE fp.vl_liquido IS NOT NULL
GROUP BY dp.nome_praca
ORDER BY faturamento_rateado DESC;


-- ============================================================
-- P4 - FATURAMENTO RATEADO POR DOMICÍLIO COM PET
-- ============================================================

SELECT
    dp.nome_praca,
    dp.domicilios_com_pet,
    ROUND(
        SUM(fp.vl_liquido * blp.fator_publico),
        2
    ) AS faturamento_rateado,
    ROUND(
        SUM(fp.vl_liquido * blp.fator_publico)
        / NULLIF(dp.domicilios_com_pet, 0),
        2
    ) AS faturamento_por_domicilio_pet
FROM fato_pedido fp
JOIN dim_loja dl
    ON fp.sk_loja = dl.sk_loja
JOIN bridge_loja_praca blp
    ON dl.cod_loja = blp.cod_loja
JOIN dim_praca dp
    ON blp.sk_praca = dp.sk_praca
WHERE fp.vl_liquido IS NOT NULL
GROUP BY
    dp.nome_praca,
    dp.domicilios_com_pet
ORDER BY faturamento_por_domicilio_pet DESC;


-- ============================================================
-- P5 - ITENS VENDIDOS POR MIL HABITANTES
-- CRUZAMENTO COM TEMPO MÉDIO DE ENTREGA
-- ============================================================

SELECT
    dl.cod_loja,
    dl.nome_loja,
    dl.cidade,
    dl.porte,
    ROUND(
        1000.0 * SUM(fp.qt_itens)
        / NULLIF(dl.populacao_cidade, 0),
        2
    ) AS itens_por_mil_habitantes,
    ROUND(
        AVG(fp.dias_total_ate_entrega),
        2
    ) AS tempo_medio_entrega
FROM fato_pedido fp
JOIN dim_loja dl
    ON fp.sk_loja = dl.sk_loja
WHERE fp.qt_itens IS NOT NULL
  AND dl.populacao_cidade IS NOT NULL
  AND dl.populacao_cidade > 0
  AND fp.dias_total_ate_entrega IS NOT NULL
  AND dl.cod_loja <> 'N/I'
GROUP BY
    dl.cod_loja,
    dl.nome_loja,
    dl.cidade,
    dl.porte,
    dl.populacao_cidade
ORDER BY itens_por_mil_habitantes DESC;