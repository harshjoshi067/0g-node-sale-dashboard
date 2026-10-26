WITH tt_coinlist (sold, node_buyer, node_amount) AS (
    VALUES
        (2052590.25, 1747, 9927)
),
tt_presale_investors (sold, node_buyer, node_amount) AS (
    VALUES
        (2600000, 2657, 8554)
),
main_summary AS (
    SELECT
        COUNT(transaction_hash) AS tx_count,
        SUM(nodes_purchased) AS node_count,
        SUM(CASE WHEN currency = 'USDC' THEN total_price END) AS USDC_amount,
        SUM(CASE WHEN currency = 'wETH' THEN total_price END) AS WETH_amount,
        
        -- Calculate total USD amount
        SUM(
            CASE
                WHEN currency = 'USDC' THEN total_price
                WHEN currency = 'wETH' THEN total_price * 3130
                ELSE 0
            END
        ) AS total_usd_amount,
        
        -- Calculate total WL and Public node counts
        COALESCE(SUM(CASE WHEN round = 'WL' THEN nodes_purchased END), 0) AS wl_node_count,
        COALESCE(SUM(CASE WHEN round = 'Public' THEN nodes_purchased END), 0) AS public_node_count,
        
        -- Calculate total WL amount
        SUM(
            CASE
                WHEN round = 'WL' AND currency = 'USDC' THEN total_price
                WHEN round = 'WL' AND currency = 'wETH' THEN total_price * 3130
                ELSE 0
            END
        ) AS total_wl_amount,

        -- Calculate total Public amount
        SUM(
            CASE
                WHEN round = 'Public' AND currency = 'USDC' THEN total_price
                WHEN round = 'Public' AND currency = 'wETH' THEN total_price * 3130
                ELSE 0
            END
        ) AS total_public_amount,
        
        COUNT(DISTINCT buyer) AS unique_buyer
    FROM query_4271957
)
SELECT
    -- Existing columns
    tx_count,
    node_count 
      + tt.node_amount 
      + pre.node_amount AS total_node_count,
    175500 - (node_count + tt.node_amount + pre.node_amount) AS node_reserved,

    USDC_amount,
    WETH_amount,
    total_usd_amount 
      + tt.sold 
      + pre.sold AS total_usd_amount,

    wl_node_count,
    public_node_count,
    total_wl_amount,
    total_public_amount,

    unique_buyer 
      + tt.node_buyer
      + pre.node_buyer AS unique_buyer,

    -- Coinlist columns
    tt.node_amount AS coinlist_node_amount,
    tt.sold        AS coinlist_sold,
    tt.node_buyer  AS coinlist_node_buyer,

    -- Pre-sale columns
    pre.node_amount AS presale_node_amount,
    pre.sold        AS presale_sold,
    pre.node_buyer  AS presale_node_buyer

FROM main_summary
CROSS JOIN tt_coinlist tt
CROSS JOIN tt_presale_investors pre;
