SELECT * FROM dbo.customer_journey;

-- CTE to identify duplicate records
WITH DuplicateRecords AS(
	SELECT
		JourneyID,
		CustomerID,
		ProductID,
		VisitDate,
		Stage,
		Action,
		Duration,
		-- Use ROW_NUMBER() to assign unique row number to each record with the given criteria
		ROW_NUMBER() OVER(
			PARTITION BY CustomerID, ProductID, VisitDate, Stage, Action
			ORDER BY JourneyID
		) AS row_num
	FROM dbo.customer_journey
)

-- View all rows from the CTE where row_num > 1 (duplicates)
SELECT * FROM DuplicateRecords
WHERE row_num > 1
ORDER BY JourneyID;

-- Outer query to select the final cleaned and standardied data
SELECT
	JourneyId, CustomerID, ProductID, VisitDate, Stage, Action,
	COALESCE(Duration, avg_duration) AS Duration -- Impute missing/null values in Duration column wth the average duration for the corresponding date (calculated in subquery below)
-- Subquery to process and clean the data
FROM(
	SELECT 
		JourneyId,
		CustomerId,
		ProductID,
		VisitDate,
		UPPER(Stage) AS Stage,
		Action,
		Duration,
		AVG(Duration) OVER (PARTITION BY VisitDate) as avg_duration, -- Calculate average duration for each date
		ROW_NUMBER() OVER(
			PARTITION BY CustomerID, ProductID, VisitDate, UPPER(Stage), Action
			ORDER BY JourneyID
		) AS row_num
	FROM dbo.customer_journey
) AS subquery
WHERE row_num = 1; -- Drop all duplicate rows