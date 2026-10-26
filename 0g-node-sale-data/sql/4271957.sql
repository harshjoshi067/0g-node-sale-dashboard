WITH USDC_data AS (
    SELECT *
    FROM query_4271885
),
USDC_wallet AS (
    SELECT *
    FROM query_4272174
),
combined_data AS (
    SELECT *
    FROM USDC_data
    UNION ALL
    SELECT *
    FROM USDC_wallet   
)
SELECT
    blockchain,
    block_time,
    transaction_hash,
    buyer,
    round,
    tier,
    tierID,
    currency,
    nodes_purchased,
    total_price,
    unit_price,
    CASE
        WHEN currency = 'USDC' THEN total_price
        WHEN currency = 'wETH' THEN total_price * 3130
        ELSE NULL
    END AS USD_amount,
    CASE
        WHEN currency = 'USDC' THEN unit_price
        WHEN currency = 'wETH' THEN unit_price * 3130
        ELSE NULL
    END AS USD_per_unit,
    use_code,
    with_code
FROM combined_data
WHERE (
        -- Apply filters only for the specific transaction hash
        transaction_hash = 0x9cba79be5d6c44728614025bc0c2093375fbc17245d5735ce2365c7dc88bc352
        AND tierID IN ('PrivateTier7WLlaunchpad', 'PrivateTier8WLlaunchpad', 'PrivateTier6WLlaunchpad')
        AND unit_price IN (369, 423, 322)
    )
    OR transaction_hash != 0x9cba79be5d6c44728614025bc0c2093375fbc17245d5735ce2365c7dc88bc352
ORDER BY block_time DESC;
