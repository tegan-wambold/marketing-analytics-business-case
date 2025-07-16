SELECT * FROM dbo.products

-- Categorize products based on price
SELECT 
	ProductID, ProductName, Price, -- No need to include category as there is only 1 cat so it is redundant
	
	CASE
		WHEN Price < 50 THEN 'Low'
		WHEN Price BETWEEN 50 AND 200 THEN 'Medium'
		ELSE 'High'
	END AS PriceCategory

FROM dbo.products