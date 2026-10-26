WITH whitelist_sales AS (
    SELECT
        tier,
        tierID,
        SUM(nodes_purchased) AS purchased_amt,  -- Total nodes purchased
        SUM(CASE WHEN use_code = 'yes' THEN nodes_purchased ELSE 0 END) AS with_promo,  -- Nodes purchased with promo code
        SUM(CASE WHEN use_code = 'no' THEN nodes_purchased ELSE 0 END) AS without_promo,  -- Nodes purchased without promo code
        SUM(USD_amount) AS USD_amount,  -- Total ETH spent
        AVG(USD_amount / nodes_purchased) AS Avg_USD_amount  -- Average ETH spent per node
    FROM query_4271957
    WHERE round = 'Public'  -- Filter for Whitelist round
    GROUP BY tier, tierID  -- Group by both tier and tierID
)
SELECT
    tier,
    tierID,
    purchased_amt,
    with_promo,
    without_promo,
    USD_amount,
    Avg_USD_amount
FROM whitelist_sales
WHERE CAST(tierID AS VARCHAR) NOT IN ('PrivateTier1Whitelist', 'PrivateTier2Whitelist', 'PrivateTier3Whitelist', 'PrivateTier5WhitelistNEW')
ORDER BY tier ASC;
