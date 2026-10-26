WITH extracted AS (
  SELECT
    t.block_time AS block_time,
    t.tx_hash AS transaction_hash,
    t."from" AS buyer,
    t.input AS input_data,
    -- Extract the function selector
    VARBINARY_SUBSTRING(t.input, 1, 4) AS function_selector,
    -- Common parameters for both functions
    VARBINARY_TO_UINT256(VARBINARY_SUBSTRING(t.input, 5, 32)) AS offset_tierId,
    VARBINARY_TO_UINT256(VARBINARY_SUBSTRING(t.input, 37, 32)) AS nodes_purchased,
    -- Extract offset to _code if function with code is used
    CASE
      WHEN VARBINARY_SUBSTRING(t.input, 1, 4) = 0xe00c58fb THEN
        VARBINARY_TO_UINT256(VARBINARY_SUBSTRING(t.input, 133, 32))
      ELSE NULL
    END AS offset_code
  FROM arbitrum.traces AS t
  JOIN arbitrum.transactions AS tx ON t.tx_hash = tx.hash
  WHERE
    tx.success = true  -- Include only successful transactions
    AND t."to" = 0x23d73C47AddC85dcDCE321736b12078fafD88640  -- Contract address for Arbitrum
    AND (
      VARBINARY_STARTS_WITH(t.input, 0xfc85d45b)  -- Function selector for `whitelistedPurchaseInTier`
      OR VARBINARY_STARTS_WITH(t.input, 0xe00c58fb)  -- Function selector for `whitelistedPurchaseInTierWithCode`
    )
),
tierid_extracted AS (
  SELECT
    *,
    -- Safely extract `tierID`
    CASE
      WHEN offset_tierId IS NOT NULL
           AND CAST(offset_tierId + 37 AS BIGINT) <= LENGTH(input_data)
    THEN FROM_UTF8(
      VARBINARY_SUBSTRING(
        input_data,
        CAST(offset_tierId + 37 AS BIGINT),
        LEAST(
          CAST(
            VARBINARY_TO_UINT256(
              VARBINARY_SUBSTRING(
                input_data,
                CAST(offset_tierId + 5 AS BIGINT),
                32
              )
            ) AS BIGINT
          ),
          LENGTH(input_data) - (CAST(offset_tierId + 37 AS BIGINT) - 1)
        )
      )
    )
    ELSE NULL
  END AS tierID
  FROM extracted
),
code_extracted AS (
  SELECT
    *,
    -- Extract promo code if function selector is for `whitelistedPurchaseInTierWithCode`
    CASE
      WHEN VARBINARY_SUBSTRING(input_data, 1, 4) = 0xe00c58fb THEN
        FROM_UTF8(
          VARBINARY_RTRIM(
            VARBINARY_SUBSTRING(
              input_data,
              VARBINARY_LENGTH(input_data) - 32 + 1,
              32
            )
          )
        )
      ELSE NULL
    END AS with_code,
    -- Determine if a promo code was used
    CASE
      WHEN offset_code IS NOT NULL THEN 'yes'
      ELSE 'no'
    END AS use_code
  FROM tierid_extracted
),
total_price_extracted AS (
  SELECT
    t.tx_hash AS transaction_hash,
    -- Extract total_price and adjust for token decimals
    VARBINARY_TO_UINT256(
      VARBINARY_SUBSTRING(t.input, 69, 32)
    ) / 1e6 AS total_price
  FROM arbitrum.traces AS t
  JOIN arbitrum.transactions AS tx ON t.tx_hash = tx.hash
  WHERE
    tx.success = true  -- Include only successful transactions
    AND t."from" = 0x23d73C47AddC85dcDCE321736b12078fafD88640  -- Contract address for Arbitrum
    AND VARBINARY_STARTS_WITH(t.input, 0x23b872dd)  -- Function selector for `transferFrom`
),
final_data AS (
  SELECT
    ce.*,
    q.tier,
    q.round,
    q.currency,
    q.blockchain,
    tp.total_price
  FROM code_extracted ce
  LEFT JOIN query_4271949 q ON ce.tierID = q.tierID
  LEFT JOIN total_price_extracted tp ON ce.transaction_hash = tp.transaction_hash
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
  -- Calculate unit_price, handling division by zero
  ROUND((total_price / NULLIF(nodes_purchased, 0)), 2) AS unit_price,
  use_code,
  with_code
FROM final_data a
WHERE a.block_time >= TIMESTAMP '2024-11-10'
ORDER BY
  block_time DESC;
