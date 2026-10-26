WITH promo_sales AS (
    SELECT 
        with_code AS promo_code,
        SUM(nodes_purchased) AS purchased_amt,
        SUM(CASE WHEN round = 'WL' THEN nodes_purchased ELSE 0 END) AS wl_amt,
        SUM(CASE WHEN round = 'Public' THEN nodes_purchased ELSE 0 END) AS public_amt,
        SUM(USD_amount) AS USD_amount,
        AVG(USD_amount / nodes_purchased) AS avgUSD_amount
    FROM query_4271957
    WHERE tierID != ''  -- Ensure tierID is not empty
    GROUP BY with_code
)
SELECT 
    promo_code,
    purchased_amt,
    wl_amt,
    public_amt,
    USD_amount,
    avgUSD_amount
FROM promo_sales
WHERE promo_code != ''
ORDER BY purchased_amt DESC;
