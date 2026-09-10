import psycopg2
import matplotlib.pyplot as plt
from pathlib import Path


# ============================================================
# CONFIGURAÇÃO
# ============================================================

conexao = psycopg2.connect(
    host="127.0.0.1",
    port=5432,
    database="dw_pata_amiga",
    user="postgres",
    password="Caroline"
)

pasta_graficos = Path(__file__).resolve().parent


# ============================================================
# P1 - TEMPO MÉDIO POR PORTE
# ============================================================

sql_p1 = """
SELECT
    dl.porte,
    ROUND(AVG(fp.dias_integracao_separacao), 2),
    ROUND(AVG(fp.dias_separacao_nota), 2),
    ROUND(AVG(fp.dias_nota_despacho), 2),
    ROUND(AVG(fp.dias_despacho_entrega), 2),
    ROUND(AVG(fp.dias_total_ate_entrega), 2)
FROM fato_pedido fp
LEFT JOIN dim_loja dl
    ON fp.sk_loja = dl.sk_loja
WHERE fp.dias_total_ate_entrega IS NOT NULL
GROUP BY dl.porte
ORDER BY dl.porte;
"""

cursor = conexao.cursor()
cursor.execute(sql_p1)
dados = cursor.fetchall()

portes = [linha[0] for linha in dados]
tempo_total = [float(linha[5]) for linha in dados]

plt.figure(figsize=(9, 5))
plt.bar(portes, tempo_total)
plt.title("P1 - Tempo Médio do Pedido até a Entrega")
plt.xlabel("Porte da loja")
plt.ylabel("Dias")
plt.xticks(rotation=20)
plt.tight_layout()
plt.savefig(
    pasta_graficos / "P1_tempo_medio_por_porte.png",
    dpi=300,
    bbox_inches="tight"
)
plt.close()


# ============================================================
# P2 - FATURAMENTO POR CATEGORIA
# ============================================================

sql_p2 = """
SELECT
    dc.nome_categoria,
    SUM(fp.vl_liquido) AS faturamento_categoria
FROM fato_pedido fp
LEFT JOIN dim_categoria dc
    ON fp.sk_categoria = dc.sk_categoria
WHERE fp.vl_liquido IS NOT NULL
GROUP BY dc.nome_categoria
ORDER BY faturamento_categoria DESC;
"""

cursor.execute(sql_p2)
dados = cursor.fetchall()

categorias = [linha[0] for linha in dados]
faturamento = [float(linha[1]) for linha in dados]

plt.figure(figsize=(10, 6))
plt.bar(categorias, faturamento)
plt.title("P2 - Faturamento por Categoria")
plt.xlabel("Categoria")
plt.ylabel("Faturamento (R$)")
plt.xticks(rotation=35, ha="right")
plt.tight_layout()
plt.savefig(
    pasta_graficos / "P2_faturamento_por_categoria.png",
    dpi=300,
    bbox_inches="tight"
)
plt.close()


# ============================================================
# P3 - FATURAMENTO POR CANAL
# ============================================================

sql_p3 = """
SELECT
    canal_pedido,
    SUM(vl_liquido) AS faturamento_canal
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
"""

cursor.execute(sql_p3)
dados = cursor.fetchall()

canais = [linha[0] for linha in dados]
faturamento = [float(linha[1]) for linha in dados]

plt.figure(figsize=(9, 5))
plt.bar(canais, faturamento)
plt.title("P3 - Faturamento por Canal")
plt.xlabel("Canal")
plt.ylabel("Faturamento (R$)")
plt.xticks(rotation=20)
plt.tight_layout()
plt.savefig(
    pasta_graficos / "P3_faturamento_por_canal.png",
    dpi=300,
    bbox_inches="tight"
)
plt.close()


# ============================================================
# P4 - FATURAMENTO RATEADO POR PRAÇA
# ============================================================

sql_p4 = """
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
"""

cursor.execute(sql_p4)
dados = cursor.fetchall()

pracas = [linha[0] for linha in dados]
faturamento = [float(linha[1]) for linha in dados]

plt.figure(figsize=(11, 6))
plt.barh(pracas[::-1], faturamento[::-1])
plt.title("P4 - Faturamento Rateado por Praça")
plt.xlabel("Faturamento (R$)")
plt.ylabel("Praça")
plt.tight_layout()
plt.savefig(
    pasta_graficos / "P4_faturamento_por_praca.png",
    dpi=300,
    bbox_inches="tight"
)
plt.close()


# ============================================================
# P5 - ITENS VENDIDOS POR MIL HABITANTES
# RANKING DAS LOJAS COM MAIOR INTENSIDADE DE VENDAS
# ============================================================

sql_p5 = """
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
"""

cursor.execute(sql_p5)
dados = cursor.fetchall()


# ------------------------------------------------------------
# Seleciona as 10 lojas com maior índice
# ------------------------------------------------------------

dados_top10 = dados[:10]

cidades = [linha[2] for linha in dados_top10]
itens_mil = [float(linha[4]) for linha in dados_top10]
tempo_entrega = [float(linha[5]) for linha in dados_top10]


# ------------------------------------------------------------
# Inverte a ordem para a maior barra ficar no topo
# ------------------------------------------------------------

cidades = cidades[::-1]
itens_mil = itens_mil[::-1]
tempo_entrega = tempo_entrega[::-1]


# ------------------------------------------------------------
# Criação do gráfico
# ------------------------------------------------------------

plt.figure(figsize=(13, 8))

barras = plt.barh(
    cidades,
    itens_mil,
    height=0.65
)


# ------------------------------------------------------------
# Título
# ------------------------------------------------------------

plt.title(
    "P5 - Intensidade de Vendas e Tempo Médio de Entrega",
    fontsize=16,
    pad=15
)


# ------------------------------------------------------------
# Eixo X
# ------------------------------------------------------------

plt.xlabel(
    "Itens vendidos por mil habitantes",
    fontsize=12
)


# Não precisamos de "Cidade" no eixo Y
plt.ylabel("")


# ------------------------------------------------------------
# Tamanho das cidades
# ------------------------------------------------------------

plt.yticks(
    fontsize=10
)


# ------------------------------------------------------------
# Valores das barras
# ------------------------------------------------------------

for barra, dias in zip(barras, tempo_entrega):

    largura = barra.get_width()

    plt.text(
        largura + 0.25,
        barra.get_y() + barra.get_height() / 2,
        f"{largura:.2f} itens/mil  |  {dias:.2f} dias",
        va="center",
        fontsize=10
    )


# ------------------------------------------------------------
# Grade
# ------------------------------------------------------------

plt.grid(
    axis="x",
    alpha=0.25
)


# ------------------------------------------------------------
# Espaço para os textos
# ------------------------------------------------------------

plt.xlim(
    0,
    max(itens_mil) + 6
)


# ------------------------------------------------------------
# Ajuste final
# ------------------------------------------------------------

plt.tight_layout()


# ------------------------------------------------------------
# Salvamento
# ------------------------------------------------------------

plt.savefig(
    pasta_graficos / "P5_itens_por_mil_habitantes.png",
    dpi=300,
    bbox_inches="tight"
)

plt.close()