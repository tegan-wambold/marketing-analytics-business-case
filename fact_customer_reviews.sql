SELECT * FROM dbo.customer_reviews

-- Clean whitespace in the ReviewText column and create a view of the table to use in python
--CREATE VIEW fact_customer_reviews AS --was needed for python script
SELECT
	ReviewID, CustomerID, ProductID, ReviewDate, Rating,
	REPLACE(ReviewText, '  ', ' ') AS ReviewText -- Cleans up any double spacing in the ReviewText column
FROM dbo.customer_reviews