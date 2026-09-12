-- ============================================================
-- PATA AMIGA — ANÁLISES SQL
-- Perguntas de negócio P1 a P5
-- ============================================================


-- ============================================================
-- P1 — Onde está o gargalo da entrega?
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

-- RESULTADO DA CONSULTA:
--
-- Os valores abaixo representam TEMPO MÉDIO, EM DIAS, para os
-- pedidos com entrega completa, agrupados pelo PORTE DA LOJA.
--
-- Grande:
--   1,96 dias = tempo médio entre integração e separação.
--   0,64 dias = tempo médio entre separação e emissão da nota.
--   3,32 dias = tempo médio entre emissão da nota e despacho.
--   2,01 dias = tempo médio entre despacho e entrega ao cliente.
--   7,93 dias = tempo total médio entre integração e entrega ao cliente.
--
-- Média:
--   1,98 dias = tempo médio entre integração e separação.
--   0,63 dias = tempo médio entre separação e emissão da nota.
--   3,33 dias = tempo médio entre emissão da nota e despacho.
--   2,03 dias = tempo médio entre despacho e entrega ao cliente.
--   7,95 dias = tempo total médio entre integração e entrega ao cliente.
--
-- Pequena:
--   3,07 dias = tempo médio entre integração e separação.
--   0,72 dias = tempo médio entre separação e emissão da nota.
--   8,52 dias = tempo médio entre emissão da nota e despacho.
--   2,86 dias = tempo médio entre despacho e entrega ao cliente.
--   15,16 dias = tempo total médio entre integração e entrega ao cliente.
--
-- GRÁFICO NO GITHUB:
-- https://github.com/carolinecunha-coder/projeto_dw_pata_amiga/blob/main/graficos/P1_tempo_medio_por_porte.png
--
-- ANÁLISE / RESPOSTA:
-- A etapa que apresenta o maior tempo médio e, portanto, caracteriza
-- o principal gargalo observado é a etapa entre a emissão da nota
-- e o despacho do pedido.
--
-- Nas lojas de porte Grande, essa etapa leva em média 3,32 dias.
-- Nas lojas de porte Médio, leva em média 3,33 dias.
-- Nas lojas de porte Pequeno, leva em média 8,52 dias.
--
-- O maior impacto aparece nas lojas de porte Pequeno: além de a etapa
-- Nota → Despacho ser muito mais longa, o tempo total médio até a
-- entrega chega a 15,16 dias, contra 7,93 dias nas lojas Grandes e
-- 7,95 dias nas lojas Médias.
--
-- Portanto, os dados indicam que o processo Nota → Despacho é o
-- principal ponto de atenção, especialmente nas lojas de pequeno porte.
-- A análise mostra associação entre porte e tempo observado, mas não
-- permite afirmar que o porte seja a causa do atraso.


-- ============================================================
-- P2 — Qual categoria concentra o faturamento?
-- ============================================================

SELECT
    dc.nome_categoria AS categoria,
    ROUND(SUM(fp.vl_liquido), 2) AS faturamento,
    ROUND(
        100.0 * SUM(fp.vl_liquido)
        / SUM(SUM(fp.vl_liquido)) OVER (),
        2
    ) AS percentual_faturamento
FROM fato_pedido fp
JOIN dim_categoria dc
    ON fp.sk_categoria = dc.sk_categoria
WHERE fp.vl_liquido IS NOT NULL
GROUP BY dc.nome_categoria
ORDER BY faturamento DESC;


SELECT
    dl.porte,
    dc.nome_categoria AS categoria,
    ROUND(SUM(fp.vl_liquido), 2) AS faturamento
FROM fato_pedido fp
JOIN dim_loja dl
    ON fp.sk_loja = dl.sk_loja
JOIN dim_categoria dc
    ON fp.sk_categoria = dc.sk_categoria
WHERE fp.vl_liquido IS NOT NULL
GROUP BY
    dl.porte,
    dc.nome_categoria
ORDER BY
    dl.porte,
    faturamento DESC;

-- RESULTADO DA CONSULTA:
--
-- Os valores representam FATURAMENTO LÍQUIDO por categoria e a
-- participação de cada categoria no faturamento total analisado.
--
-- Racao:
--   R$ 1.076.202,55 = faturamento líquido da categoria Racao.
--   60,01% = participação da Racao no faturamento total.
--
-- Medicamento:
--   R$ 305.904,03 = faturamento líquido da categoria Medicamento.
--   17,06% = participação no faturamento total.
--
-- Petisco:
--   R$ 128.590,16 = faturamento líquido da categoria Petisco.
--   7,17% = participação no faturamento total.
--
-- Servico:
--   R$ 94.001,37 = faturamento líquido da categoria Servico.
--   5,24% = participação no faturamento total.
--
-- Higiene:
--   R$ 92.314,45 = faturamento líquido da categoria Higiene.
--   5,15% = participação no faturamento total.
--
-- Acessorio:
--   R$ 64.661,39 = faturamento líquido da categoria Acessorio.
--   3,61% = participação no faturamento total.
--
-- Brinquedo:
--   R$ 31.634,56 = faturamento líquido da categoria Brinquedo.
--   1,76% = participação no faturamento total.
--
-- A categoria Racao também foi a campeã de faturamento nos três
-- portes de loja:
--   Grande: R$ 468.186,60 de faturamento com Racao.
--   Media:  R$ 443.131,62 de faturamento com Racao.
--   Pequena: R$ 164.197,55 de faturamento com Racao.
--
-- GRÁFICO NO GITHUB:
-- https://github.com/carolinecunha-coder/projeto_dw_pata_amiga/blob/main/graficos/P2_faturamento_por_categoria.png
--
-- ANÁLISE / RESPOSTA:
-- A categoria Racao concentra a maior parcela do faturamento:
-- R$ 1.076.202,55, equivalente a 60,01% do faturamento analisado.
--
-- Além de liderar no total, Racao também é a categoria com maior
-- faturamento nos três portes de loja: Grande, Media e Pequena.
--
-- Isso demonstra forte concentração do faturamento nessa categoria.
-- Entretanto, faturamento não representa margem de lucro. Portanto,
-- os dados permitem afirmar que Racao é a principal categoria em
-- faturamento, mas não permitem afirmar que seja a categoria mais
-- lucrativa sem dados de margem ou custo.


-- ============================================================
-- P3 — Desconto aumenta o ticket médio?
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


SELECT
    canal_pedido,
    ROUND(SUM(vl_liquido), 2) AS faturamento,
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
ORDER BY faturamento DESC;

-- RESULTADO DA CONSULTA:
--
-- Os valores de ticket médio representam o VALOR LÍQUIDO MÉDIO
-- de cada pedido, separado por canal e pela existência de desconto.
--
-- App:
--   R$ 170,48 = ticket médio dos pedidos sem desconto.
--   R$ 488,04 = ticket médio dos pedidos com desconto.
--
-- Site:
--   R$ 189,48 = ticket médio dos pedidos sem desconto.
--   R$ 501,92 = ticket médio dos pedidos com desconto.
--
-- Loja Fisica:
--   R$ 196,78 = ticket médio dos pedidos sem desconto.
--   R$ 494,04 = ticket médio dos pedidos com desconto.
--
-- Telefone:
--   R$ 195,46 = ticket médio dos pedidos sem desconto.
--   R$ 514,02 = ticket médio dos pedidos com desconto.
--
-- WhatsApp:
--   R$ 173,88 = ticket médio dos pedidos sem desconto.
--   R$ 514,33 = ticket médio dos pedidos com desconto.
--
-- A participação no faturamento por canal representa a parcela do
-- faturamento total dos cinco canais analisados:
--   App:         R$ 552.134,43 — 32,95%
--   Site:        R$ 450.569,37 — 26,89%
--   Loja Fisica: R$ 360.677,22 — 21,53%
--   WhatsApp:    R$ 188.678,63 — 11,26%
--   Telefone:    R$ 123.419,29 — 7,37%
--
-- GRÁFICO NO GITHUB:
-- https://github.com/carolinecunha-coder/projeto_dw_pata_amiga/blob/main/graficos/P3_faturamento_por_canal.png
--
-- ANÁLISE / RESPOSTA:
-- Em todos os cinco canais analisados, o ticket médio dos pedidos
-- com desconto é maior que o ticket médio dos pedidos sem desconto.
--
-- A maior diferença observada ocorre no WhatsApp:
-- R$ 514,33 com desconto contra R$ 173,88 sem desconto.
--
-- O Telefone apresenta R$ 514,02 com desconto contra R$ 195,46
-- sem desconto. No Site, são R$ 501,92 contra R$ 189,48.
-- No App, R$ 488,04 contra R$ 170,48. Na Loja Fisica,
-- R$ 494,04 contra R$ 196,78.
--
-- Quanto à participação no faturamento, o App representa 32,95%
-- e é o canal com maior participação entre os cinco analisados.
--
-- Portanto, existe associação entre pedidos com desconto e tickets
-- médios maiores nesta base. Isso não permite concluir que o desconto
-- causou o aumento do ticket, pois outras características dos pedidos
-- podem explicar parte dessa diferença.


-- ============================================================
-- P4 — Como o faturamento se distribui por praça?
-- ============================================================

SELECT
    dp.nome_praca,
    ROUND(
        SUM(fp.vl_liquido * blp.fator_publico),
        2
    ) AS faturamento_alocado
FROM fato_pedido fp
JOIN dim_loja dl
    ON fp.sk_loja = dl.sk_loja
JOIN bridge_loja_praca blp
    ON dl.cod_loja = blp.cod_loja
JOIN dim_praca dp
    ON blp.sk_praca = dp.sk_praca
WHERE fp.vl_liquido IS NOT NULL
GROUP BY dp.nome_praca
ORDER BY faturamento_alocado DESC;


SELECT
    dp.nome_praca,
    dp.domicilios_com_pet,
    ROUND(
        SUM(fp.vl_liquido * blp.fator_publico),
        2
    ) AS faturamento_alocado
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
ORDER BY faturamento_alocado DESC;

-- RESULTADO DA CONSULTA:
--
-- Os valores representam FATURAMENTO ALOCADO POR PRAÇA.
-- O faturamento de cada pedido é distribuído entre as praças de sua
-- loja utilizando o fator_publico da bridge_loja_praca.
--
-- Vale do Itajai:       R$ 633.746,09
-- Grande Florianopolis: R$ 283.546,75
-- Norte Industrial:     R$ 175.431,90
-- Litoral Sul:           R$ 137.051,20
-- Litoral Norte:         R$ 128.872,75
-- Extremo Oeste:          R$ 98.359,18
-- Carbonifera:            R$ 88.707,42
-- Serra Catarinense:      R$ 80.477,64
-- Meio-Oeste:             R$ 58.955,63
-- Foz do Itajai:          R$ 46.749,72
-- Planalto Norte:         R$ 31.100,84
-- Planalto Serrano:       R$ 29.323,10
--
-- RECONCILIAÇÃO:
-- R$ 1.793.308,51 = faturamento total da rede no período analisado.
-- R$ 1.792.322,21 = faturamento que foi possível alocar às praças.
-- R$ 986,30 = diferença entre os dois valores.
-- Essa diferença corresponde aos 3 pedidos sem loja identificada,
-- que não podem ser associados a uma praça.
--
-- Domicilios_com_pet representa a quantidade de domicílios com pet
-- informada para cada praça na dimensão de praça.
--
-- GRÁFICO NO GITHUB:
-- https://github.com/carolinecunha-coder/projeto_dw_pata_amiga/blob/main/graficos/P4_faturamento_por_praca.png
--
-- ANÁLISE / RESPOSTA:
-- A praça Vale do Itajai apresenta o maior faturamento alocado,
-- com R$ 633.746,09.
--
-- O segundo maior faturamento alocado é o da Grande Florianopolis,
-- com R$ 283.546,75, seguida pelo Norte Industrial, com
-- R$ 175.431,90.
--
-- A alocação não corresponde simplesmente ao faturamento bruto de
-- uma loja: o valor é distribuído entre as praças conforme o
-- fator_publico definido na bridge_loja_praca.
--
-- A reconciliação mostra que o faturamento alocado é R$ 1.792.322,21,
-- enquanto o faturamento total da rede é R$ 1.793.308,51. A diferença
-- de R$ 986,30 ocorre porque existem 3 pedidos sem loja identificada.
--
-- Portanto, Vale do Itajai é a praça com maior faturamento alocado
-- na análise. A distribuição por praça deve ser interpretada como
-- uma estimativa baseada nos fatores públicos definidos para a
-- relação loja × praça.


-- ============================================================
-- P5 — Onde existe oportunidade para uma nova loja?
-- ============================================================

SELECT
    dl.cidade,
    dl.porte,
    dl.faixa_franquia,
    dl.populacao_cidade,
    SUM(fp.qt_itens) AS total_itens,
    ROUND(
        1000.0 * SUM(fp.qt_itens)
        / NULLIF(dl.populacao_cidade, 0),
        2
    ) AS itens_por_mil_habitantes,
    ROUND(AVG(fp.dias_total_ate_entrega), 2) AS media_dias_entrega
FROM fato_pedido fp
JOIN dim_loja dl
    ON fp.sk_loja = dl.sk_loja
WHERE fp.qt_itens IS NOT NULL
  AND dl.populacao_cidade IS NOT NULL
  AND dl.populacao_cidade > 0
GROUP BY
    dl.cidade,
    dl.porte,
    dl.faixa_franquia,
    dl.populacao_cidade
ORDER BY itens_por_mil_habitantes DESC;


SELECT
    dl.faixa_franquia,
    ROUND(SUM(fp.vl_liquido), 2) AS faturamento
FROM fato_pedido fp
JOIN dim_loja dl
    ON fp.sk_loja = dl.sk_loja
WHERE fp.vl_liquido IS NOT NULL
GROUP BY dl.faixa_franquia
ORDER BY faturamento DESC;


SELECT
    COUNT(*) FILTER (WHERE fp.sk_loja = -1) AS pedidos_sem_loja,
    COUNT(*) FILTER (WHERE fp.dias_total_ate_entrega IS NULL) AS entregas_incompletas,
    COUNT(*) FILTER (WHERE fp.qt_itens IS NULL) AS itens_nao_informados,
    COUNT(*) FILTER (WHERE fp.vl_liquido IS NULL) AS valores_nao_informados
FROM fato_pedido fp;

-- RESULTADO DA CONSULTA:
--
-- A métrica itens_por_mil_habitantes significa a quantidade total
-- de itens vendidos por mil habitantes da cidade, calculada a partir
-- da população_cidade.
--
-- PRINCIPAL RESULTADO:
-- Rio dos Cedros apresenta 23,58 itens por mil habitantes.
-- A média de entrega observada para os pedidos completos da cidade
-- é de 14,24 dias.
--
-- FATURAMENTO POR FAIXA DE FRANQUIA ATUAL:
-- Ouro: R$ 1.011.264,38 = faturamento associado às lojas que,
-- no cadastro atual, estão classificadas como Ouro.
-- Diamante: R$ 382.209,74 = faturamento associado às lojas atualmente
-- classificadas como Diamante.
-- Prata: R$ 314.812,03 = faturamento associado às lojas atualmente
-- classificadas como Prata.
-- Bronze: R$ 84.036,06 = faturamento associado às lojas atualmente
-- classificadas como Bronze.
-- Nao Informado: R$ 986,30 = faturamento dos pedidos sem loja
-- identificada.
--
-- COMPLETUDE DOS DADOS:
-- 3 pedidos = pedidos sem loja identificada.
-- 1.953 pedidos = pedidos sem data final de entrega, portanto com
-- entrega incompleta para o cálculo do tempo total.
-- 257 registros = pedidos em que a quantidade de itens não foi
-- informada.
-- 121 registros = pedidos em que o valor líquido não foi informado.
--
-- GRÁFICO NO GITHUB:
-- https://github.com/carolinecunha-coder/projeto_dw_pata_amiga/blob/main/graficos/P5_itens_por_mil_habitantes.png
--
-- ANÁLISE / RESPOSTA:
-- Rio dos Cedros é a recomendação para uma possível nova loja porque
-- apresenta 23,58 itens por mil habitantes, indicador utilizado para
-- representar a intensidade de demanda observada em relação à população.
--
-- O tempo médio de entrega associado à cidade é de 14,24 dias. Esse
-- resultado deve ser considerado junto com o indicador de demanda:
-- uma oportunidade comercial pode existir, mas o tempo de entrega
-- também representa um ponto de atenção operacional.
--
-- A análise de faturamento por faixa de franquia utiliza a
-- faixa_franquia atualmente registrada na dimensão de loja. Portanto,
-- não é possível afirmar que determinada loja pertencia historicamente
-- à faixa Ouro, Diamante, Prata ou Bronze durante todo o período
-- analisado. O resultado representa a situação atual do cadastro.
--
-- Também existem limitações de qualidade dos dados: 3 pedidos não
-- possuem loja identificada; 1.953 pedidos possuem entrega incompleta;
-- 257 pedidos não informam a quantidade de itens; e 121 não informam
-- o valor líquido.
--
-- Assim, Rio dos Cedros é uma indicação baseada nos indicadores
-- disponíveis, e não uma decisão definitiva de abertura de loja.


-- ============================================================
-- FIM — 05-analises.sql
-- ============================================================
