# amazon-books-sql-analysis
This project explores a dataset of Amazon’s Top 500 bestselling books using SQL Server. The goal is to uncover insights around pricing, ratings, popularity, authorship performance, and outliers in book performance.  The analysis focuses on identifying whether pricing impacts ratings, what drives popularity, and which books behave as outliers

**1. What is the overall quality of books on Amazon?**
Global average rating calculated
Rating distribution analysed

Insight: Most books are highly rated, suggesting selection bias in bestseller listings.

**2. Do higher priced books have better ratings?**
Price segmented using quartiles
Average rating compared across price segments

Insight: Price shows weak correlation with rating, suggesting higher price does not guarantee better quality.

**3. Who are the top performing authors?**
Average rating per author
Top 10 authors identified
Top 3 books per author ranked using window functions

Insight: While certain authors perform consistently well, the analysis of average ratings alone is not sufficient to conclude dominance across the dataset.

**4. What drives popularity?**
Relationship between rating and number of reviews
Distribution of review counts analysed

Insight: Popularity (reviews) does not strongly correlate with rating quality.

****5. Outlier Detection ****

Two models were used:

Quartile-based segmentation (price vs rating)
Z-score based anomaly detection (ratings + reviews)

**Identified categories:**

Hidden Gems (high rating, low reviews)
Controversial Books (low rating, high reviews)
Premium Winners (high price, high rating)
Overpriced Poor Value (high price, low rating)
****Techniques Used**
SQL CTEs
Window Functions (RANK, PARTITION BY)
Percentile analysis (PERCENTILE_CONT)
Aggregations (AVG, COUNT)
Statistical modelling (Z-scores)
CASE-based segmentation
**Key Insights**
- Price is not a strong predictor of rating
- Popularity (reviews) does not guarantee quality
- Hidden gems exist among low-reviewed books
- Certain authors consistently outperform others
- Clear evidence of overexposed low-rated books
**Tools Used**
- SQL Server (T-SQL)
- Kaggle dataset
- Analytical modelling using CTEs and window functions
