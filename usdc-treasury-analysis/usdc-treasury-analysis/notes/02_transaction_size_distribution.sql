-- Query 02: Transaction Size Distribution
-- Dashboard: USDC Treasury Analysis for Fortune 500 Operations
-- Business question: What transaction-size segments dominate USDC activity?
-- Chart: Transaction Size Distribution
-- Segment labels:
--   Retail: < $1K
--   Small Business: $1K - $10K
--   Mid-Market: $10K - $100K
--   Institutional: $100K - $1M
--   Large Institutional: > $1M
-- Important note: These are proxy segments based on transaction size buckets, not confirmed real-world user identities.
-- Note: This was part of a group academic Dune dashboard project. Original dashboard/query authorship remains visible in the Dune workspace.

WITH usdc_transfers AS (
    SELECT
        evt_block_time,
        TRY_CAST(value AS DOUBLE) / 1e6 AS usdc_amount,
        "from" AS sender,
        "to" AS receiver,
        evt_tx_hash
    FROM erc20_ethereum.evt_Transfer
    WHERE
        contract_address = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
        AND evt_block_time >= CURRENT_TIMESTAMP - INTERVAL '90' DAY
        AND value > 0
),

categorized_transfers AS (
    SELECT
        usdc_amount,
        CASE
            WHEN usdc_amount < 1000
                THEN '1. Retail (<$1K)'
            WHEN usdc_amount >= 1000 AND usdc_amount < 10000
                THEN '2. Small Business ($1K-$10K)'
            WHEN usdc_amount >= 10000 AND usdc_amount < 100000
                THEN '3. Mid-Market ($10K-$100K)'
            WHEN usdc_amount >= 100000 AND usdc_amount < 1000000
                THEN '4. Institutional ($100K-$1M)'
            ELSE '5. Large Institutional (>$1M)'
        END AS size_category
    FROM usdc_transfers
)

SELECT
    size_category,
    COUNT(*) AS transaction_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_transactions,
    ROUND(SUM(usdc_amount), 2) AS total_usd_value,
    ROUND(100.0 * SUM(usdc_amount) / SUM(SUM(usdc_amount)) OVER (), 2) AS pct_of_total_value,
    ROUND(APPROX_PERCENTILE(usdc_amount, 0.5), 2) AS median_size,
    ROUND(AVG(usdc_amount), 2) AS avg_size
FROM categorized_transfers
GROUP BY size_category
ORDER BY size_category;
