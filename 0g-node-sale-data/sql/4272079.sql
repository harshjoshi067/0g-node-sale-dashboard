WITH hourly_sales AS (
    SELECT
        DATE_TRUNC('hour', t.block_time) AS sale_hour,
        SUM(t.nodes_purchased) AS nodes_sold,
        SUM(t.USD_amount) AS amount_credited
    FROM query_4271957 AS t
    WHERE t.tier IS NOT NULL AND t.tier != 0  -- Exclude tier 0 if needed
    GROUP BY DATE_TRUNC('hour', t.block_time)
)
SELECT
    sale_hour,
    nodes_sold,
    amount_credited,
    -- Cumulative sum of nodes sold by hour
    SUM(nodes_sold) OVER (ORDER BY sale_hour ASC) AS cumulative_nodes_sold_by_hour,
    -- Cumulative amount credited by hour
    SUM(amount_credited) OVER (ORDER BY sale_hour ASC) AS cumulative_amount_credited
FROM hourly_sales
ORDER BY sale_hour ASC;
