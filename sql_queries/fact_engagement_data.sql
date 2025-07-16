SELECT * FROM dbo.engagement_data

-- Clean and normalize the engagement_data table
SELECT EngagementID, ContentID, CampaignID, ProductID,
	UPPER(REPLACE(ContentType, 'Socialmedia', 'Social Media')) as ContentType, -- Normalize formatting in ContentType column
	LEFT(ViewsClicksCombined, CHARINDEX('-', ViewsClicksCombined) - 1) AS Views, --Extract views from ViewsClicksCombined column
	RIGHT(ViewsClicksCombined, LEN(ViewsClicksCombined) - CHARINDEX('-', ViewsClicksCombined)) AS Clicks, --Extract clicks from ViewsClicksCombined columns
	Likes,
	FORMAT(CONVERT(DATE, EngagementDate), 'MM.dd.yyyy') AS EngagementDate
FROM dbo.engagement_data
WHERE ContentType != 'Newsletter';
