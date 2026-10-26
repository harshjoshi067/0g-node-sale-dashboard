WITH hours AS (
    SELECT
        sale_hour
    FROM UNNEST(
        sequence(
            TIMESTAMP '2024-11-11 11:00:00',
            CAST(NOW() AS timestamp),
            INTERVAL '1' HOUR
        )
    ) AS t(sale_hour)
),
tiers AS (
    SELECT tier
    FROM UNNEST(
        SEQUENCE(1, 36)
    ) AS t(tier)
),
hourly_tiers AS (
    SELECT
        h.sale_hour,
        t.tier
    FROM hours h
    CROSS JOIN tiers t
),
sales_per_hour_tier AS (
    SELECT
        DATE_TRUNC('hour', t.block_time) AS sale_hour,
        t.tier,
        SUM(t.nodes_purchased) AS nodes_sold
    FROM query_4271957 AS t
    WHERE
        t.tier BETWEEN 1 AND 36
        AND t.block_time >= TIMESTAMP '2024-11-11 11:00:00'
    GROUP BY
        DATE_TRUNC('hour', t.block_time),
        t.tier
),
hourly_sales AS (
    SELECT
        ht.sale_hour,
        ht.tier,
        COALESCE(s.nodes_sold, 0) AS nodes_sold
    FROM hourly_tiers ht
    LEFT JOIN sales_per_hour_tier s
        ON ht.sale_hour = s.sale_hour AND ht.tier = s.tier
),
cumulative_sales AS (
    SELECT
        sale_hour,
        tier,
        nodes_sold,
        SUM(nodes_sold) OVER (
            PARTITION BY tier
            ORDER BY sale_hour ASC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_nodes_sold_by_tier
    FROM hourly_sales
)
SELECT
    sale_hour,
    tier,
    nodes_sold,
    cumulative_nodes_sold_by_tier
FROM cumulative_sales
ORDER BY
    sale_hour ASC,
    tier ASC;
