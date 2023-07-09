WITH SalesWithQuarterYear AS (
    -- Determine the fiscal quarter and fiscal year for each sale, and aggregate quantity and revenue
    SELECT 
		S.[Stock Item Key] AS ProductId,
        SI.[Stock Item] AS ProductName, 
        SUM(S.[Total Excluding Tax]) AS TotalRevenue, 
        SUM(S.[Quantity]) AS TotalQuantity, 
        D.[Fiscal Year] AS FiscalYear,
        CEILING(D.[Fiscal Month Number] / 3.0) AS FiscalQuarter
    FROM 
        [Fact].[Sale] S
    JOIN 
        [Dimension].[Date] D ON S.[Invoice Date Key] = D.[Date]
    JOIN 
        [Dimension].[Stock Item] SI ON S.[Stock Item Key] = SI.[Stock Item Key]
    GROUP BY 
        S.[Stock Item Key], SI.[Stock Item], D.[Fiscal Year], CEILING(D.[Fiscal Month Number] / 3.0)
),

SalesGrowth AS (
    -- Calculate the growth rate from the previous quarter and year
    SELECT 
        SWQY.ProductName, 
        ((SWQY.TotalRevenue - LAG(SWQY.TotalRevenue, 1) OVER (PARTITION BY SWQY.ProductId ORDER BY SWQY.FiscalYear, SWQY.FiscalQuarter)) / NULLIF(LAG(SWQY.TotalRevenue, 1) OVER (PARTITION BY SWQY.ProductId ORDER BY SWQY.FiscalYear, SWQY.FiscalQuarter), 0)) * 100 AS GrowthRevenueRate,
        ((SWQY.TotalQuantity - LAG(SWQY.TotalQuantity, 1) OVER (PARTITION BY SWQY.ProductId ORDER BY SWQY.FiscalYear, SWQY.FiscalQuarter)) / NULLIF(LAG(SWQY.TotalQuantity, 1) OVER (PARTITION BY SWQY.ProductId ORDER BY SWQY.FiscalYear, SWQY.FiscalQuarter), 0)) * 100 AS GrowthQuantityRate,
        SWQY.FiscalYear AS CurrentYear, 
        SWQY.FiscalQuarter AS CurrentQuarter,
        LAG(SWQY.FiscalYear, 1) OVER (PARTITION BY SWQY.ProductId ORDER BY SWQY.FiscalYear, SWQY.FiscalQuarter) AS PreviousYear,
        LAG(SWQY.FiscalQuarter, 1) OVER (PARTITION BY SWQY.ProductId ORDER BY SWQY.FiscalYear, SWQY.FiscalQuarter) AS PreviousQuarter
    FROM 
        SalesWithQuarterYear SWQY
)

-- Get the results with the desired column ordering
SELECT 
    ProductName,
    GrowthRevenueRate,
    GrowthQuantityRate,
    CurrentQuarter,
    CurrentYear,
    PreviousQuarter,
    PreviousYear
FROM 
    SalesGrowth
ORDER BY 
    ProductName, CurrentYear, CurrentQuarter;