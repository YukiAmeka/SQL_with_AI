-- CTE for total sales revenue and quantity per quarter per year
WITH totalSales AS (
  SELECT
    SUM(FS.[Total Excluding Tax]) AS TotalRevenue,
    SUM(FS.[Quantity]) AS TotalQuantity,
    D.[Fiscal Year] AS Year,
    (D.[Fiscal Month Number] - 1) / 3 + 1 AS Quarter
  FROM [Fact].[Sale] FS
  JOIN [Dimension].[Date] D ON FS.[Invoice Date Key] = D.[Date]
  GROUP BY D.[Fiscal Year], (D.[Fiscal Month Number] - 1) / 3 + 1
),

-- CTE for customer sales revenue and quantity per quarter per year
customerSales AS (
  SELECT
    C.[Customer Key],
    C.[Customer] AS CustomerName,
    SUM(FS.[Total Excluding Tax]) AS CustomerRevenue,
    SUM(FS.[Quantity]) AS CustomerQuantity,
    D.[Fiscal Year] AS Year,
    (D.[Fiscal Month Number] - 1) / 3 + 1 AS Quarter
  FROM [Fact].[Sale] FS
  JOIN [Dimension].[Date] D ON FS.[Invoice Date Key] = D.[Date]
  JOIN [Dimension].[Customer] C ON FS.[Customer Key] = C.[Customer Key]
  GROUP BY C.[Customer Key], C.[Customer], D.[Fiscal Year], (D.[Fiscal Month Number] - 1) / 3 + 1
)

-- Main query to calculate percentages and join results
SELECT
  CS.[CustomerName],
  (CS.CustomerRevenue / TS.TotalRevenue) * 100 AS [TotalRevenuePercentage],
  CAST(CS.CustomerQuantity AS DECIMAL) / CAST(TS.TotalQuantity AS DECIMAL) * 100 AS [TotalQuantityPercentage],
  CS.[Quarter],
  CS.[Year]
FROM customerSales CS
JOIN totalSales TS ON CS.Quarter = TS.Quarter AND CS.Year = TS.Year
ORDER BY CS.[Year], CS.[Quarter], CS.[CustomerName];