-- =====================================================================================
-- 03-DIMENSOES.SQL
-- Case: Pata Amiga | PostgreSQL 16
-- =====================================================================================


-- =====================================================================================
-- DIM_CATEGORIA
-- Grao: uma grafia da origem
-- =====================================================================================

-- Linha especial para dados nao informados.
INSERT INTO dim_categoria
    (sk_categoria, categoria_origem, nome_categoria, grupo_categoria)
VALUES
    (-1, 'Nao Informado', 'Nao Informado', 'Nao Informado');


-- Carrega as grafias originais da staging e padroniza a categoria.
INSERT INTO dim_categoria
    (categoria_origem, nome_categoria, grupo_categoria)
SELECT DISTINCT
    "CategoriaProduto",

    CASE
        WHEN TRANSLATE(
                 UPPER(TRIM("CategoriaProduto")),
                 'ÁÀÃÂÄÉÈÊËÍÌÎÏÓÒÕÔÖÚÙÛÜÇ',
                 'AAAAAEEEEIIIIOOOOOUUUUC'
             ) LIKE '%MED%'
            THEN 'Medicamento'

        WHEN TRANSLATE(
                 UPPER(TRIM("CategoriaProduto")),
                 'ÁÀÃÂÄÉÈÊËÍÌÎÏÓÒÕÔÖÚÙÛÜÇ',
                 'AAAAAEEEEIIIIOOOOOUUUUC'
             ) LIKE '%PETISC%'
            THEN 'Petisco'

        WHEN TRANSLATE(
                 UPPER(TRIM("CategoriaProduto")),
                 'ÁÀÃÂÄÉÈÊËÍÌÎÏÓÒÕÔÖÚÙÛÜÇ',
                 'AAAAAEEEEIIIIOOOOOUUUUC'
             ) LIKE '%RA%'
            THEN 'Racao'

        WHEN TRANSLATE(
                 UPPER(TRIM("CategoriaProduto")),
                 'ÁÀÃÂÄÉÈÊËÍÌÎÏÓÒÕÔÖÚÙÛÜÇ',
                 'AAAAAEEEEIIIIOOOOOUUUUC'
             ) LIKE '%HIG%'
            THEN 'Higiene'

        WHEN TRANSLATE(
                 UPPER(TRIM("CategoriaProduto")),
                 'ÁÀÃÂÄÉÈÊËÍÌÎÏÓÒÕÔÖÚÙÛÜÇ',
                 'AAAAAEEEEIIIIOOOOOUUUUC'
             ) LIKE '%BRINQ%'
            THEN 'Brinquedo'

        WHEN TRANSLATE(
                 UPPER(TRIM("CategoriaProduto")),
                 'ÁÀÃÂÄÉÈÊËÍÌÎÏÓÒÕÔÖÚÙÛÜÇ',
                 'AAAAAEEEEIIIIOOOOOUUUUC'
             ) LIKE '%ACESS%'
            THEN 'Acessorio'

        WHEN TRANSLATE(
                 UPPER(TRIM("CategoriaProduto")),
                 'ÁÀÃÂÄÉÈÊËÍÌÎÏÓÒÕÔÖÚÙÛÜÇ',
                 'AAAAAEEEEIIIIOOOOOUUUUC'
             ) LIKE '%SERV%'
            THEN 'Servico'

        ELSE 'Nao Informado'
    END,

    CASE
        WHEN TRANSLATE(
                 UPPER(TRIM("CategoriaProduto")),
                 'ÁÀÃÂÄÉÈÊËÍÌÎÏÓÒÕÔÖÚÙÛÜÇ',
                 'AAAAAEEEEIIIIOOOOOUUUUC'
             ) LIKE '%MED%'
            THEN 'Saude e Higiene'

        WHEN TRANSLATE(
                 UPPER(TRIM("CategoriaProduto")),
                 'ÁÀÃÂÄÉÈÊËÍÌÎÏÓÒÕÔÖÚÙÛÜÇ',
                 'AAAAAEEEEIIIIOOOOOUUUUC'
             ) LIKE '%PETISC%'
            THEN 'Alimentacao'

        WHEN TRANSLATE(
                 UPPER(TRIM("CategoriaProduto")),
                 'ÁÀÃÂÄÉÈÊËÍÌÎÏÓÒÕÔÖÚÙÛÜÇ',
                 'AAAAAEEEEIIIIOOOOOUUUUC'
             ) LIKE '%RA%'
            THEN 'Alimentacao'

        WHEN TRANSLATE(
                 UPPER(TRIM("CategoriaProduto")),
                 'ÁÀÃÂÄÉÈÊËÍÌÎÏÓÒÕÔÖÚÙÛÜÇ',
                 'AAAAAEEEEIIIIOOOOOUUUUC'
             ) LIKE '%HIG%'
            THEN 'Saude e Higiene'

        WHEN TRANSLATE(
                 UPPER(TRIM("CategoriaProduto")),
                 'ÁÀÃÂÄÉÈÊËÍÌÎÏÓÒÕÔÖÚÙÛÜÇ',
                 'AAAAAEEEEIIIIOOOOOUUUUC'
             ) LIKE '%BRINQ%'
            THEN 'Bem-estar'

        WHEN TRANSLATE(
                 UPPER(TRIM("CategoriaProduto")),
                 'ÁÀÃÂÄÉÈÊËÍÌÎÏÓÒÕÔÖÚÙÛÜÇ',
                 'AAAAAEEEEIIIIOOOOOUUUUC'
             ) LIKE '%ACESS%'
            THEN 'Bem-estar'

        WHEN TRANSLATE(
                 UPPER(TRIM("CategoriaProduto")),
                 'ÁÀÃÂÄÉÈÊËÍÌÎÏÓÒÕÔÖÚÙÛÜÇ',
                 'AAAAAEEEEIIIIOOOOOUUUUC'
             ) LIKE '%SERV%'
            THEN 'Bem-estar'

        ELSE 'Nao Informado'
    END

FROM stg_pedido;

-- =====================================================================================
-- DIM_PRACA
-- Grao: uma praca de atendimento
-- =====================================================================================

-- Linha especial para dados nao informados.
INSERT INTO dim_praca
    (sk_praca, cod_praca, nome_praca, regional, domicilios_com_pet)
VALUES
    (-1, 'N/I', 'Nao Informado', 'Nao Informado', 0);


-- Carrega uma linha por praca.
INSERT INTO dim_praca
    (cod_praca, nome_praca, regional, domicilios_com_pet)
SELECT DISTINCT
    "CodPraca",
    "NomePraca",
    "Regional",
    CAST(CAST("DomiciliosComPet" AS DECIMAL) AS INT)
FROM stg_loja_praca;

-- =====================================================================================
-- BRIDGE_LOJA_PRACA
-- Grao: uma relacao entre uma loja e uma praca
-- =====================================================================================

-- Carrega a relacao loja x praca e o fator de rateio do publico.
INSERT INTO bridge_loja_praca
    (cod_loja, sk_praca, fator_publico)
SELECT
    "CodLoja",
    dp.sk_praca,
    CAST("PercentualPublico" AS DECIMAL(6,4))
FROM stg_loja_praca slp
JOIN dim_praca dp
    ON dp.cod_praca = slp."CodPraca";