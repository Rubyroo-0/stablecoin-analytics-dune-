-- Query 01: USDC Daily Transaction Volume Trends
-- Dashboard: USDC Treasury Analysis for Fortune 500 Operations
-- Business question: Is the USDC network large enough and stable enough for enterprise treasury operations?
-- Chart: Viz 1 - Daily Processing Capacity / Volume
-- Technical focus: Daily aggregation, volume trend, 7-day moving average.
-- Note: This was part of a group academic Dune dashboard project. Original dashboard/query authorship remains visible in the Dune workspace.

WITH daily_data AS (
    SELECT 
        DATE_TRUNC('day', evt_block_time) AS date,
        COUNT(*) AS tx_count,
        SUM(value / 1000000) AS volume_usd
    FROM erc20_ethereum.evt_Transfer
    WHERE 
        contract_address = 0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48
        AND evt_block_time >= DATE '2024-05-01'
        AND value > 0
    GROUP BY 1
)

SELECT 
    date,
    tx_count,
    volume_usd,
    AVG(volume_usd) OVER (
        ORDER BY date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS ma_7day
FROM daily_data
ORDER BY date DESC;
