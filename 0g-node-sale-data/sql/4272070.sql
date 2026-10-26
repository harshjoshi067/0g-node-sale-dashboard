WITH wallet_sales AS (
    SELECT 
        buyer,
        SUM(nodes_purchased) AS purchased_amt,
        SUM(CASE WHEN use_code = 'yes' THEN nodes_purchased ELSE 0 END) AS with_promo,
        SUM(CASE WHEN use_code = 'no' THEN nodes_purchased ELSE 0 END) AS without_promo,
        SUM(CASE WHEN round = 'WL' THEN nodes_purchased ELSE 0 END) AS wl_amt,
        SUM(CASE WHEN round = 'Public' THEN nodes_purchased ELSE 0 END) AS public_amt,
        SUM(USD_amount) AS USD_amount,
        AVG(USD_amount / nodes_purchased) AS avgUSD_amount
    FROM query_4271957
    WHERE tierID != ''  -- Ensure tierID is not empty
    GROUP BY buyer
)
SELECT 
    buyer,
    purchased_amt,
    with_promo,
    without_promo,
    wl_amt,
    public_amt,
    USD_amount,
    avgUSD_amount
FROM wallet_sales
ORDER BY purchased_amt DESC;
