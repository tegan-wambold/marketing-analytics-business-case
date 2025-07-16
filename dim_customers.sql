SELECT * FROM dbo.customers
SELECT * From dbo.geography

-- Join dim_customers with dim_geography to enrich customer data with geographic information
SELECT
	c.CustomerID,
	c.CustomerName,
	c.Email,
	c.Gender,
	c.Age,
	c.GeographyID,
	g.Country,
	g.City
FROM dbo.customers as C
RIGHT JOIN dbo.geography as g
ON c.GeographyID = g.GeographyID