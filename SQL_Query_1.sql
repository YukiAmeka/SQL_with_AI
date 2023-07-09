WITH SalesData AS (
    -- Extract fiscal year, fiscal month, calculate the revenue and quantity for each sale
    SELECT 
        si.[Stock Item] AS ProductName,
        d.[Fiscal Year] AS Year,
        (d.[Fiscal Month Number] - 1) / 3 + 1 AS Quarter, -- calculate quarter based on fiscal month number
        SUM(s.[Quantity]) AS SalesQuantity,
        SUM(s.[Total Excluding Tax]) AS SalesRevenue -- revenue calculation based on total excluding tax
    FROM 
        [Fact].[Sale] s
    JOIN
        [Dimension].[Stock Item] si ON s.[Stock Item Key] = si.[Stock Item Key]
    JOIN
        [Dimension].[Date] d ON s.[Invoice Date Key] = d.[Date]
    GROUP BY 
        si.[Stock Item], 
        d.[Fiscal Year], 
        (d.[Fiscal Month Number] - 1) / 3 + 1 -- grouping by quarter calculated based on fiscal month number
),
RankingData AS (
    -- Rank the products by sales revenue within each quarter and year
    SELECT 
        ProductName, 
        SalesQuantity, 
        SalesRevenue, 
        Quarter, 
        Year,
        RANK() OVER (
            PARTITION BY Quarter, Year 
            ORDER BY SalesRevenue DESC
        ) AS RevenueRank
    FROM 
        SalesData
)
-- Finally, filter the top 10 products for each quarter and year
SELECT 
    ProductName, 
    SalesQuantity, 
    SalesRevenue, 
    Quarter, 
    Year
FROM 
    RankingData
WHERE 
    RevenueRank <= 10
ORDER BY 
    Year, 
    Quarter, 
    RevenueRank;