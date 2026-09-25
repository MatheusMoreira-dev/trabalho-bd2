CREATE OR REPLACE VIEW vw_clientes_destaque AS

WITH gastos_mensais AS (
    SELECT
        p.customer_id AS id_cliente,
        DATE_FORMAT(p.payment_date, '%Y-%m') AS mes_referencia,
        SUM(p.amount) AS valor_total_pago
    FROM payment p
    GROUP BY
        p.customer_id,
        DATE_FORMAT(p.payment_date, '%Y-%m')
),

media_mensal AS (
    SELECT
        mes_referencia,
        AVG(valor_total_pago) AS media_clientes
    FROM gastos_mensais
    GROUP BY mes_referencia
),

comparacao AS (
    SELECT
        gm.id_cliente,
        gm.mes_referencia,
        gm.valor_total_pago,
        mm.media_clientes,

        ROUND(
            (gm.valor_total_pago / mm.media_clientes) * 100,
            2
        ) AS percentual_da_media

    FROM gastos_mensais gm

    INNER JOIN media_mensal mm
        ON gm.mes_referencia = mm.mes_referencia
),

priorizacao AS (
    SELECT
        id_cliente,
        mes_referencia,
        valor_total_pago,
        media_clientes,
        percentual_da_media,

        CASE
            WHEN percentual_da_media >= 150 THEN 1
            WHEN percentual_da_media >= 125 THEN 2
            WHEN percentual_da_media >= 100 THEN 3
            ELSE NULL
        END AS prioridade

    FROM comparacao
)

SELECT
    p.id_cliente,

    CONCAT(
        c.first_name,
        ' ',
        c.last_name
    ) AS nome_cliente,

    p.mes_referencia,

    ROUND(p.valor_total_pago, 2) AS valor_total_pago,

    ROUND(p.media_clientes, 2) AS media_clientes,

    p.percentual_da_media,

    p.prioridade,

    ROW_NUMBER() OVER (
        PARTITION BY p.mes_referencia
        ORDER BY
            p.prioridade ASC,
            p.percentual_da_media DESC,
            p.valor_total_pago DESC
    ) AS ranking

FROM priorizacao p

INNER JOIN customer c
    ON c.customer_id = p.id_cliente

WHERE p.prioridade IS NOT NULL;
