-- Query 04: Stress Period Classification
-- Dashboard: USDC Treasury Analysis for Fortune 500 Operations
-- Business question: How often does USDC activity operate under normal versus stress conditions?
-- Chart: Stress Analysis 1 - Stress vs Normal
-- Technical focus: Daily metrics, average/stddev thresholds, stress classification.
-- Important note: The duplicated SQL block from the original paste was removed here.
-- Note: This was part of a group academic Dune dashboard project. Original dashboard/query authorship remains visible in the Dune workspace.

WITH daily_metrics AS (
    SELECT 
        DATE_TRUNC('day', evt_block_time) AS date,
        COUNT(*) AS tx_count,
        SUM(value / 1e6) AS volume_usd,
        COUNT(DISTINCT "from") AS unique_senders
    FROM erc20_ethereum.evt_Transfer
    WHERE 
        contract_address = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
        AND evt_block_time >= CURRENT_DATE - INTERVAL '365' DAY
    GROUP BY 1
),

volume_stats AS (
    SELECT 
        AVG(volume_usd) AS avg_volume,
        STDDEV(volume_usd) AS stddev_volume
    FROM daily_metrics
),

stress_classification AS (
    SELECT 
        d.date,
        d.tx_count,
        d.volume_usd,
        d.unique_senders,
        v.avg_volume,
        v.stddev_volume,
        CASE 
            WHEN d.volume_usd > v.avg_volume + 2 * v.stddev_volume
                THEN 'High Stress'
            WHEN d.volume_usd > v.avg_volume + v.stddev_volume
                THEN 'Moderate Stress'
            ELSE 'Normal'
        END AS stress_level
    FROM daily_metrics AS d
    CROSS JOIN volume_stats AS v
)

SELECT 
    stress_level,
    COUNT(*) AS days_count,
    AVG(tx_count) AS avg_daily_transactions,
    AVG(volume_usd) AS avg_daily_volume_usd,
    MAX(volume_usd) AS max_daily_volume_usd
FROM stress_classification
GROUP BY stress_level
ORDER BY 
    CASE stress_level
        WHEN 'High Stress' THEN 1
        WHEN 'Moderate Stress' THEN 2
        ELSE 3
    END;
