# Wide World Importers: revenue, customers and churn risk

- **Tools:** T-SQL · Microsoft SQL Server
- **Database:** [WideWorldImporters](https://learn.microsoft.com/en-us/sql/samples/wide-world-importers-what-is), Microsoft's sample database for a wholesale company (sales, purchasing, warehouse and application schemas)
- **File:** [`WideWorldImporters_Analysis.sql`](WideWorldImporters_Analysis.sql)

## Business question
How is the business growing, who are the customers that matter most, and where is the risk?

## The 10 questions

| # | Question | Main techniques |
|---|---|---|
| 1 | Yearly revenue, annualized by active months, and growth rate | CTEs, `LAG` |
| 2 | Top 5 customers by revenue in every quarter | `DENSE_RANK` with `PARTITION BY` |
| 3 | Top 10 products by total sales value | `TOP`, aggregation |
| 4 | Products ranked by nominal profit | `DENSE_RANK` |
| 5 | Each supplier with its product list | `STRING_AGG`, `CONCAT_WS` |
| 6 | Top 5 customers by spend, with geography | Multi-table joins |
| 7 | Monthly sales, yearly subtotals and running totals | `ROLLUP`, windowed `SUM` |
| 8 | Orders per month across 2013–2016 | `PIVOT` |
| 9 | Potential churn per customer | `LAG`, `DATEDIFF`, windowed `AVG` / `MAX` |
| 10 | Customer distribution by category | `CASE`, `COUNT(DISTINCT)`, windowed `SUM` |

## Key findings

- **Churn risk:** a customer is flagged as *Potential Churn* when the days since their last order are more than twice their average gap between orders.
- **Customer concentration:** in the Novelty Shop category, two chains (Wingtip Toys and Tailspin Toys) hold **459 of 663 stores (69%)**. Counting each chain as one customer, Novelty Shop is 22.43% of all customers. The company depends heavily on these two chains: losing either one would cut the customer base by tens of percent.
- **Fair growth comparison:** revenue is annualized by the number of active months, so partial years can be compared with full years.

## How to run
1. Restore the WideWorldImporters database in SQL Server ([download](https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0)).
2. Open the script in SQL Server Management Studio and run each question separately (they are divided by `GO`).
