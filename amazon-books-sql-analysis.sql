
SELECT * FROM Amazon_BestSelling_Books_500

--Global Average Rating--
SELECT  ROUND(AVG(Rating),2) AS average_rating FROM Amazon_BestSelling_Books_500; 
    
--Find Authors Whose Average Rating Is Above The Global Average
WITH global_avg AS (
    SELECT AVG(Rating) AS Global_Average_Rating
    FROM Amazon_BestSelling_Books_500
),
author_avg AS (
    SELECT 
        Author, 
        AVG(Rating) AS Average_Rating
    FROM Amazon_BestSelling_Books_500
    GROUP BY Author
)

SELECT 
    Author,
    ROUND(Average_Rating, 2) AS Average_Rating
FROM author_avg
WHERE Average_Rating >= (SELECT Global_Average_Rating FROM global_avg);
--Ratings Distribution--
SELECT ROUND(Rating, 1) AS Rating, ROUND(COUNT(Rating),1) AS Frequency FROM Amazon_BestSelling_Books_500
GROUP BY Rating;
--Price vs Ratings Analysis--

--Price/Rating--
SELECT ROUND(Price_USD,2) AS Price_USD, ROUND(Rating,2) AS Rating FROM Amazon_BestSelling_Books_500
ORDER BY Price_USD, Rating; 
--Quartiles--
SELECT 
    DISTINCT ROUND((PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Price_USD) OVER ()),2) AS Q1,
    ROUND((PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Price_USD) OVER ()),2) AS Q2,
    ROUND((PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Price_USD) OVER ()),2) AS Q3
FROM Amazon_BestSelling_Books_500;
--Averages Per Price Category--
WITH CTE AS (
    SELECT 
        CASE
            WHEN Price_USD >= 21.93 THEN 'Premium'
            WHEN Price_USD BETWEEN 11.21 AND 21.92 THEN 'Mid'
            ELSE 'Budget'
        END AS Price_Range,
        
        Price_USD,
        Rating
    FROM Amazon_BestSelling_Books_500
)

SELECT 
    Price_Range,
    ROUND(AVG(Price_USD), 2) AS Average_Price,
    ROUND(AVG(Rating), 2) AS Average_Rating
FROM CTE
GROUP BY Price_Range
ORDER BY CASE
    WHEN Price_Range = 'Premium' THEN 1
    WHEN Price_Range = 'Mid' THEN 2
    WHEN Price_Range = 'Budget' THEN 3
    END;
--OUTLIER FOR PRICING/RATINGS --
WITH stats AS (
    SELECT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Price_USD) OVER () AS price_q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Price_USD) OVER () AS price_q3,
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Rating) OVER () AS rating_q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Rating) OVER () AS rating_q3
    FROM Amazon_BestSelling_Books_500
),

data AS (
    SELECT 
        a.Title,
        a.Author,
        a.Price_USD,
        a.Rating,
        s.price_q1,
        s.price_q3,
        s.rating_q1,
        s.rating_q3
    FROM Amazon_BestSelling_Books_500 a
    CROSS JOIN stats s
),

classified AS (
    SELECT
        Title,
        Author,
        ROUND(Price_USD,2) AS Price_USD,
        Rating,

        CASE
            WHEN Price_USD <= price_q1 AND Rating >= rating_q3 THEN 'Hidden Gem'
            WHEN Price_USD >= price_q3 AND Rating <= rating_q1 THEN 'Overpriced / Poor Value'
            WHEN Price_USD >= price_q3 AND Rating >= rating_q3 THEN 'Premium Winner'
            WHEN Price_USD <= price_q1 AND Rating <= rating_q1 THEN 'Low Value'
            ELSE 'Normal'
        END AS Book_Category

    FROM data
)

SELECT *
FROM classified
WHERE Book_Category <> 'Normal'
ORDER BY Book_Category, Rating DESC;

-- TOP PREFORMING AUTHORS --
SELECT TOP 10 Author, ROUND(AVG(Rating),1) AS Average_rating FROM Amazon_BestSelling_Books_500
GROUP BY Author  
ORDER BY Average_rating DESC;
--TOP 3 Books PER AUTHOR
WITH cte AS ( SELECT 
    Author, Title, ROUND(Rating,1) AS Rating,
    RANK() OVER (PARTITION BY Author ORDER BY Rating DESC ) AS Top_3_Books
FROM Amazon_BestSelling_Books_500)

SELECT * FROM cte
WHERE Top_3_Books <=3;
-- What Drives Popularity?--

SELECT 
DISTINCT ROUND((PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Reviews) OVER ()),2) AS Q1,
    ROUND((PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Reviews) OVER ()),2) AS Q2,
    ROUND((PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Reviews) OVER ()),2) AS Q3
    FROM Amazon_BestSelling_Books_500

SELECT Reviews, ROUND(Rating,1) Rating FROM Amazon_BestSelling_Books_500
ORDER BY Reviews DESC , Rating DESC;

--OUTLIERS---
WITH stats AS (
    SELECT 
        AVG(Rating) AS avg_rating,
        AVG(Reviews) AS avg_reviews,
        STDEV(Rating) AS std_rating,
        STDEV(Reviews) AS std_reviews
    FROM Amazon_BestSelling_Books_500
),

scored AS (
    SELECT 
        a.Title,
        a.Author,
        a.Rating,
        a.Reviews,

        (a.Rating - s.avg_rating) / NULLIF(s.std_rating, 0) AS rating_z,
        (a.Reviews - s.avg_reviews) / NULLIF(s.std_reviews, 0) AS review_z

    FROM Amazon_BestSelling_Books_500 a
    CROSS JOIN stats s
),

labelled AS (
    SELECT *,
        CASE 
            WHEN rating_z >= 1 AND review_z <= -0.5 THEN 'Hidden Gem'
            WHEN rating_z <= -1 AND review_z >= 0.5 THEN 'Controversial'
        END AS Book_Type
    FROM scored
)

SELECT *
FROM labelled
WHERE Book_Type IS NOT NULL
ORDER BY 
    CASE Book_Type
        WHEN 'Hidden Gem' THEN 1
        WHEN 'Controversial' THEN 2
    END,
    rating_z DESC;
