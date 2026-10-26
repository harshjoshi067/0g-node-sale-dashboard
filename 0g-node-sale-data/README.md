# 0G Foundation node sale data

Source: https://dune.com/node_data/0g-foundation-node-sale
Retrieved: 2026-10-26T20:17:01.371Z

## Coverage

Exported all rows from 10 working queries covering 27 of 28 dashboard visualizations.
16,075 rows across separate result sets. These overlap: they are not 16,075 unique transactions.
CSV exports are in csv/. JSON responses with column types, execution IDs and row counts are in results/.
The main transaction table is csv/4271957.csv (6,105 rows).
Each export was checked against Dune's total row count. No samples, filters or column projections were used.

## Query file guide

| Query | Data | Rows |
| --- | --- | ---: |
| 4271957 | Raw sale records | 6105 |
| 4272013 | Dashboard summary | 1 |
| 4272070 | Purchases by wallet | 4079 |
| 4272053 | Sales and availability by tier | 16 |
| 4272031 | Whitelist sales by tier ID | 17 |
| 4275719 | Public sales by tier ID | 16 |
| 4272028 | Promo-code summary | 573 |
| 4272762 | Individual promo-code sale records | 4598 |
| 4272079 | Hourly and cumulative sales | 665 |
| 4282954 | Historical Coinlist/Mocalist snapshots | 5 |

## Dashboard summary

- Nodes including fixed Coinlist and presale inputs: 96,681.
- USD amount including those fixed inputs: $34,319,790.25.
- Reserved nodes: 78,819.
- Raw sale record count: 6,105.
- Whitelist nodes in raw records: 59,582.
- Public nodes in raw records: 18,618.
- Dashboard buyer measure: 8,483. This adds 4,079 distinct raw-data buyers to 1,747 Coinlist and 2,657 presale buyers. It is not deduplicated across those channels.

Powered by [Dune summary query](https://dune.com/queries/4272013).

## Remaining gap

Query 4275699 (cumulative hourly sales by tier), used by visualization 7186851, has a known failed execution: "result of sequence function must not have more than 10000 entries".
Its hourly sequence begins 2024-11-11 and continues to NOW(), exceeding that limit.
It was not rerun or modified. The raw sale data needed for an independent reconstruction is included, but no reconstructed rows are presented as original Dune results.

## Source interpretation

These are freshly executed exports of historical sale data, not a claim of current ongoing sales.
The raw and summary SQL use a fixed 3130 USD/wETH conversion. Coinlist and presale inputs in the summary are fixed literals.
CSV exports preserve source text values, but spreadsheet apps may auto-format addresses, large integers or dates when opened. Use JSON for type and null information.
static-inputs.json contains the earlier SQL-literal recovery, including all 32 tier configurations. It is labelled separately from query result exports.
SQL for all 11 dashboard queries and three direct dependencies is in sql/.
Dashboard and visualization metadata, plus widget-to-file mappings, are included.
Dune reported approximately 315.798 credits used out of 4,000 at completion.

