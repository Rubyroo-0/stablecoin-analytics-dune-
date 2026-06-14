-- Query 03: Savings vs Bank Wire Fee
-- Dashboard: USDC Treasury Analysis for Fortune 500 Operations
-- Business question: Could USDC transfers reduce transaction costs compared with traditional bank wire fees?
-- Chart: Savings vs Bank Wire Fee (Full History)
-- Technical focus: Gas fee estimation, ETH/USD price join, daily cost comparison.
-- Assumption: Traditional bank wire fee is set to $35 per transaction/day benchmark in this query.
-- Note: This was part of a group academic Dune dashboard project. Original dashboard/query authorship remains visible in the Dune workspace.

WITH usdc AS (
    SELECT
        DATE_TRUNC('day', hour_key) AS day,
        AVG(avg_usd_fee) AS avg_usdc_fee
    FROM (
        WITH raw AS (
            SELECT
                DATE_TRUNC('hour', t.evt_block_time) AS hour_key,
                (
                    TRY_CAST(tx.gas_used AS DOUBLE) * TRY_CAST(tx.gas_price AS DOUBLE)
                ) / 1e18 AS gas_cost_eth
            FROM erc20_ethereum.evt_Transfer AS t
            JOIN ethereum.transactions AS tx
                ON t.evt_tx_hash = tx.hash
            WHERE
                t.contract_address = FROM_HEX('a0b86991c6218b36c1d19d4a2e9eb0ce3606eb48')
        ),

        hourly AS (
            SELECT
                hour_key,
                AVG(gas_cost_eth) AS avg_eth_fee
            FROM raw
            GROUP BY hour_key
        ),

        hourly_with_usd AS (
            SELECT
                h.hour_key,
                h.avg_eth_fee * p.price AS avg_usd_fee
            FROM hourly AS h
            LEFT JOIN prices.usd AS p
                ON h.hour_key = DATE_TRUNC('hour', p.minute)
                AND p.symbol = 'ETH'
        )

        SELECT *
        FROM hourly_with_usd
    ) AS x
    WHERE avg_usd_fee IS NOT NULL
    GROUP BY 1
),

bank AS (
    SELECT
        DATE_TRUNC('day', day_sequence) AS day,
        35 AS bank_fee
    FROM UNNEST(
        SEQUENCE(
            TRY_CAST('2018-10-01' AS DATE),
            CURRENT_DATE,
            INTERVAL '1' DAY
        )
    ) AS t(day_sequence)
)

SELECT
    u.day,
    u.avg_usdc_fee,
    b.bank_fee,
    (b.bank_fee - u.avg_usdc_fee) AS savings_vs_bank
FROM usdc AS u
JOIN bank AS b
    ON u.day = b.day
ORDER BY u.day;
