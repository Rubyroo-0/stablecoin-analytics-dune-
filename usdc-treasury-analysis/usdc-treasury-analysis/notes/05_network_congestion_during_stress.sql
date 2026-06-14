-- Query 05: Network Congestion During Stress
-- Dashboard: USDC Treasury Analysis for Fortune 500 Operations
-- Business question: Does USDC transaction activity remain stable when network costs increase?
-- Chart: Stress Analysis 2 - Network Congestion During Stress
-- Technical focus: Transaction count, average gas fee, p90 gas fee, ETH/USD price join.
-- Note: This was part of a group academic Dune dashboard project. Original dashboard/query authorship remains visible in the Dune workspace.

WITH daily_activity AS (
    SELECT
        DATE_TRUNC('day', t.evt_block_time) AS date,
        COUNT(*) AS usdc_tx_count,
        AVG(
            TRY_CAST(tx.gas_price AS DOUBLE) * TRY_CAST(tx.gas_used AS DOUBLE) / 1e18
        ) AS avg_gas_eth,
        APPROX_PERCENTILE(
            TRY_CAST(tx.gas_price AS DOUBLE) * TRY_CAST(tx.gas_used AS DOUBLE) / 1e18,
            0.9
        ) AS p90_gas_eth
    FROM erc20_ethereum.evt_Transfer AS t
    INNER JOIN ethereum.transactions AS tx
        ON t.evt_tx_hash = tx.hash
        AND t.evt_block_time = tx.block_time
    WHERE
        t.contract_address = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
        AND t.evt_block_time >= CURRENT_DATE - INTERVAL '180' DAY
        AND tx.gas_price IS NOT NULL
        AND tx.gas_used IS NOT NULL
    GROUP BY 1
),

eth_prices AS (
    SELECT
        DATE_TRUNC('day', minute) AS date,
        AVG(price) AS eth_price_usd
    FROM prices.usd
    WHERE
        symbol = 'ETH'
        AND minute >= CURRENT_DATE - INTERVAL '180' DAY
    GROUP BY 1
)

SELECT
    a.date,
    a.usdc_tx_count,
    a.avg_gas_eth * e.eth_price_usd AS avg_fee_usd,
    a.p90_gas_eth * e.eth_price_usd AS p90_fee_usd,
    CASE
        WHEN a.avg_gas_eth * e.eth_price_usd > 10
            THEN 'High Cost Period'
        ELSE 'Normal Cost'
    END AS cost_period
FROM daily_activity AS a
INNER JOIN eth_prices AS e
    ON a.date = e.date
ORDER BY a.date;
