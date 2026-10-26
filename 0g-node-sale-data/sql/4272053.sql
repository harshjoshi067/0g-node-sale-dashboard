WITH tier_sales AS (
    SELECT
        t.tier,        
        COALESCE(SUM(t.nodes_purchased), 0) AS sold,  -- Total nodes sold
        COALESCE(SUM(CASE WHEN t.round = 'WL' THEN t.nodes_purchased ELSE 0 END), 0) AS wl_sold,  -- Nodes sold in WL round
        COALESCE(SUM(CASE WHEN t.round = 'Public' THEN t.nodes_purchased ELSE 0 END), 0) AS public_sold,  -- Nodes sold in Public round
        COALESCE(SUM(t.USD_amount), 0) AS USD_amount,  -- Total USD spent for the sales
        COALESCE(SUM(CASE WHEN t.round = 'WL' THEN t.USD_amount ELSE 0 END), 0) AS wl_USD_amount,  -- USD amount for WL sales
        COALESCE(SUM(CASE WHEN t.round = 'Public' THEN t.USD_amount ELSE 0 END), 0) AS public_USD_amount  -- USD amount for Public sales
    FROM query_4271957 AS t
    WHERE t.tier IS NOT NULL
    GROUP BY t.tier
)
SELECT
    ts.tier,
    tp.tot_cnt AS max_nodes,           -- Maximum number of nodes per tier
    ts.sold,                            -- Total nodes sold
    -- Safe subtraction logic for nodes_left
    CASE
        WHEN ts.sold > tp.tot_cnt THEN 0  -- Set to 0 if sold exceeds max_nodes
        ELSE tp.tot_cnt - ts.sold         -- Otherwise, calculate normally
    END AS nodes_left,
    tp.wl_cnt AS max_wl, 
    ts.wl_sold,
    -- Adjust WL sold percentage to show 100% when oversold
    CASE
        WHEN ts.wl_sold >= tp.wl_cnt THEN 1.0  -- Show 100% if WL sold >= max WL
        ELSE ts.wl_sold * 1.0 / NULLIF(tp.wl_cnt, 0)  -- Otherwise, calculate percentage
    END AS wl_sold_pct,  -- Percentage of WL nodes sold
    tp.public_cnt AS max_public,  
    ts.public_sold,
    COALESCE(ts.public_sold * 1.0 / NULLIF(tp.public_cnt, 0), 0) AS public_sold_pct,  -- Percentage of Public nodes sold
    CASE
        WHEN ts.sold >= tp.tot_cnt THEN 1.0  -- 100% if sold exceeds or equals max_nodes
        ELSE ts.sold * 1.0 / NULLIF(tp.tot_cnt, 0)  -- Otherwise, calculate percentage
    END AS sold_pct,                       -- Percentage of nodes sold
    ts.wl_USD_amount,                  
    ts.public_USD_amount, 
    ts.USD_amount               
FROM tier_sales AS ts
JOIN query_4272050 AS tp ON ts.tier = tp.tier  -- Join with the tier data to get max counts
ORDER BY ts.tier ASC;
