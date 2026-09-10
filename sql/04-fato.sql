-- Active: 127.0.0.1 | dw_pata_amiga

-- =====================================================================================
-- PROJETO DW PATA AMIGA
-- Tarefa 4 - Construção da Fato
-- =====================================================================================

-- fato_pedido
-- Grão: 1 linha = 1 pedido
-- Origem: stg_pedido
-- Dimensões utilizadas: dim_tempo, dim_loja e dim_categoria

-- =====================================================================================
-- CARGA DA FATO_PEDIDO
-- =====================================================================================

INSERT INTO fato_pedido (
    numero_pedido,
    sk_tempo_pedido,
    sk_tempo_entrega,
    sk_loja,
    sk_categoria,
    houve_desconto,
    canal_pedido,
    dt_pedido,
    qt_itens,
    vl_liquido,
    dias_integracao_separacao,
    dias_separacao_nota,
    dias_nota_despacho,
    dias_despacho_entrega,
    dias_total_ate_entrega
)

SELECT

    -- -----------------------------------------------------------------------------
    -- Número do pedido
    -- -----------------------------------------------------------------------------

    sp."NumeroPedido" AS numero_pedido,

    -- -----------------------------------------------------------------------------
    -- Chave da dimensão tempo - data do pedido
    -- -----------------------------------------------------------------------------

    TO_CHAR(
        TO_TIMESTAMP(
            sp."DtHoraPedido",
            'MM/DD/YYYY HH12:MI AM'
        )::DATE,
        'YYYYMMDD'
    )::INT AS sk_tempo_pedido,

    -- -----------------------------------------------------------------------------
    -- Chave da dimensão tempo - data da entrega
    -- Se não houver entrega, utiliza -1
    -- -----------------------------------------------------------------------------

    CASE
        WHEN TRIM(sp."DtEntregaCliente") IN ('', '-') THEN -1
        ELSE
            TO_CHAR(
                sp."DtEntregaCliente"::DATE,
                'YYYYMMDD'
            )::INT
    END AS sk_tempo_entrega,

    -- -----------------------------------------------------------------------------
    -- Chave da dimensão loja
    -- Se a loja não for encontrada, utiliza -1
    -- -----------------------------------------------------------------------------

    COALESCE(
        dl.sk_loja,
        -1
    ) AS sk_loja,

    -- -----------------------------------------------------------------------------
    -- Chave da dimensão categoria
    -- Se a categoria não for encontrada, utiliza -1
    -- -----------------------------------------------------------------------------

    COALESCE(
        dc.sk_categoria,
        -1
    ) AS sk_categoria,

    -- -----------------------------------------------------------------------------
    -- Padronização de indicador de desconto
    -- -----------------------------------------------------------------------------

    CASE
        WHEN UPPER(TRIM(sp."HouveDesconto")) IN
             ('S', 'SIM', '1', 'X', 'TRUE', 'V')
            THEN 'Sim'

        WHEN UPPER(TRIM(sp."HouveDesconto")) IN
             ('N', 'NAO', '0', 'FALSE', 'F')
            THEN 'Nao'

        ELSE 'Nao Informado'
    END AS houve_desconto,

    -- -----------------------------------------------------------------------------
    -- Padronização do canal do pedido
    -- WHATS deve ser testado antes de APP
    -- -----------------------------------------------------------------------------

    CASE
        WHEN UPPER(TRIM(sp."CanalPedido")) LIKE '%WHATS%'
            THEN 'WhatsApp'

        WHEN UPPER(TRIM(sp."CanalPedido")) LIKE '%APP%'
            THEN 'App'

        WHEN UPPER(TRIM(sp."CanalPedido")) LIKE '%SITE%'
            THEN 'Site'

        WHEN UPPER(TRIM(sp."CanalPedido")) LIKE '%LOJA%'
            THEN 'Loja Fisica'

        WHEN UPPER(TRIM(sp."CanalPedido")) LIKE '%TEL%'
            THEN 'Telefone'

        ELSE 'Nao Informado'
    END AS canal_pedido,

    -- -----------------------------------------------------------------------------
    -- Data e hora do pedido
    -- -----------------------------------------------------------------------------

    TO_TIMESTAMP(
        sp."DtHoraPedido",
        'MM/DD/YYYY HH12:MI AM'
    ) AS dt_pedido,

    -- -----------------------------------------------------------------------------
    -- Quantidade de itens
    -- -----------------------------------------------------------------------------

    CASE
        WHEN TRIM(sp."QTD.Itens") IN ('', '-')
            THEN NULL
        ELSE
            CAST(
                REPLACE(
                    REPLACE(
                        sp."QTD.Itens",
                        '.',
                        ''
                    ),
                    ' ',
                    ''
                ) AS INT
            )
    END AS qt_itens,

    -- -----------------------------------------------------------------------------
    -- Valor líquido
    -- -----------------------------------------------------------------------------

    CASE
        WHEN TRIM(
            REPLACE(
                sp."ValorLiquidoPedido(R$)",
                'R$',
                ''
            )
        ) IN ('', '-')
            THEN NULL

        WHEN sp."ValorLiquidoPedido(R$)" LIKE '%,%'
            THEN CAST(
                REPLACE(
                    REPLACE(
                        REPLACE(
                            REPLACE(
                                sp."ValorLiquidoPedido(R$)",
                                'R$',
                                ''
                            ),
                            ' ',
                            ''
                        ),
                        '.',
                        ''
                    ),
                    ',',
                    '.'
                ) AS DECIMAL(15,2)
            )

        ELSE
            CAST(
                REPLACE(
                    REPLACE(
                        sp."ValorLiquidoPedido(R$)",
                        'R$',
                        ''
                    ),
                    ' ',
                    ''
                ) AS DECIMAL(15,2)
            )
    END AS vl_liquido,

    -- -----------------------------------------------------------------------------
    -- Prazo: integração ERP → separação do estoque
    -- -----------------------------------------------------------------------------

    CASE
        WHEN TRIM(sp."Dt Separacao Estoque") IN ('', '-')
            THEN NULL
        ELSE
            sp."Dt Separacao Estoque"::DATE
            - TO_TIMESTAMP(
                sp."DtHoraIntegracaoERP",
                'MM/DD/YYYY HH12:MI AM'
              )::DATE
    END AS dias_integracao_separacao,

    -- -----------------------------------------------------------------------------
    -- Prazo: separação do estoque → nota fiscal
    -- -----------------------------------------------------------------------------

    CASE
        WHEN TRIM(sp."DtNotaFiscal") IN ('', '-')
            THEN NULL
        ELSE
            sp."DtNotaFiscal"::DATE
            - sp."Dt Separacao Estoque"::DATE
    END AS dias_separacao_nota,

    -- -----------------------------------------------------------------------------
    -- Prazo: nota fiscal → despacho da transportadora
    -- -----------------------------------------------------------------------------

    CASE
        WHEN TRIM(sp."Dt_Despacho_Transportadora") IN ('', '-')
            THEN NULL
        ELSE
            sp."Dt_Despacho_Transportadora"::DATE
            - sp."DtNotaFiscal"::DATE
    END AS dias_nota_despacho,

    -- -----------------------------------------------------------------------------
    -- Prazo: despacho → entrega ao cliente
    -- -----------------------------------------------------------------------------

    CASE
        WHEN TRIM(sp."DtEntregaCliente") IN ('', '-')
            THEN NULL
        ELSE
            sp."DtEntregaCliente"::DATE
            - sp."Dt_Despacho_Transportadora"::DATE
    END AS dias_despacho_entrega,

    -- -----------------------------------------------------------------------------
    -- Prazo total: integração ERP → entrega ao cliente
    -- -----------------------------------------------------------------------------

    CASE
        WHEN TRIM(sp."DtEntregaCliente") IN ('', '-')
            THEN NULL
        ELSE
            sp."DtEntregaCliente"::DATE
            - TO_TIMESTAMP(
                sp."DtHoraIntegracaoERP",
                'MM/DD/YYYY HH12:MI AM'
              )::DATE
    END AS dias_total_ate_entrega

-- =====================================================================================
-- ORIGEM DOS PEDIDOS
-- =====================================================================================

FROM stg_pedido sp

-- =====================================================================================
-- DIMENSÃO LOJA
-- Limpeza e padronização do nome da loja para localizar a SK correspondente
-- =====================================================================================

LEFT JOIN dim_loja dl
    ON dl.chave_loja =
       UPPER(
           TRANSLATE(
               REGEXP_REPLACE(
                   TRIM(
                       REPLACE(
                           REPLACE(
                               REPLACE(
                                   REPLACE(
                                       UPPER(sp."Loja-Nome"),
                                       '/SC',
                                       ''
                                   ),
                                   'PATA AMIGA BLUMENAL CENTRO',
                                   'PATA AMIGA BLUMENAU CENTRO'
                               ),
                               'PATA AMIGA FLORIPA NORTE',
                               'PATA AMIGA FLORIANOPOLIS NORTE'
                           ),
                           'PATA AMIGA JGUA DO SUL',
                           'PATA AMIGA JARAGUA DO SUL'
                       )
                   ),
                   '\s+',
                   ' ',
                   'g'
               ),
               'ÁÀÃÂÄÉÈÊËÍÌÎÏÓÒÕÔÖÚÙÛÜÇáàãâäéèêëíìîïóòõôöúùûüç',
               'AAAAAEEEEIIIIOOOOOUUUUCAAAAAEEEEIIIIOOOOOUUUUC'
           )
       )

-- =====================================================================================
-- DIMENSÃO CATEGORIA
-- Localiza a categoria pela grafia original registrada na staging
-- =====================================================================================

LEFT JOIN dim_categoria dc
    ON dc.categoria_origem = sp."CategoriaProduto";

