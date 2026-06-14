# Query Index

## 01_daily_transaction_volume.sql
Analyzes USDC daily transaction activity over time to evaluate network scale, growth, and stability. Includes daily transaction count, total transfer volume, and a 7-day moving average.

## 02_transaction_size_distribution.sql
Groups USDC transfers into transaction-size proxy segments: Retail, Small Business, Mid-Market, Institutional, and Large Institutional. These labels are based on transaction size buckets, not confirmed real-world identities.

## 03_savings_vs_bank_wire_fee.sql
Estimates potential savings by comparing average USDC gas-based transfer cost with a traditional bank wire fee assumption.

## 04_stress_period_classification.sql
Classifies days into Normal, Moderate Stress, and High Stress based on daily volume relative to the average and standard deviation over the last 365 days.

## 05_network_congestion_during_stress.sql
Analyzes daily USDC transaction count and estimated gas fees to evaluate whether network activity remains stable during higher-cost periods.

## 06_svb_crisis_case_study.sql
Reserved for the Silicon Valley Bank crisis case study query. Add the SQL once it is available from Dune.
