import pandas as pd
import pyodbc
import nltk
from nltk.sentiment.vader import SentimentIntensityAnalyzer
import os

# nltk.download('vader_lexicon')

def fetch_data_from_sql():
    '''Fetches data from a specific SQL server instance and database, and returns the data as a pandas dataframe.'''
    
    conn_str = (
        'Driver={SQL Server};'
        'Server=TEGANS_LENOVO\\SQLEXPRESS;'
        'Database=PortfolioProject_MarketingAnalytics;'
        'Trusted_Connection=yes;'
    )
    
    # Establish connection to the database
    conn = pyodbc.connect(conn_str)
    
    # Define the SQL query to fetch customer reviews data
    query = 'SELECT ReviewID, CustomerID, ProductID, ReviewDate, Rating, ReviewText FROM fact_customer_reviews'
    
    # Run query and fetch data into dataframe
    df = pd.read_sql(query, conn)
    
    return df

# Fetch customer reviews data from SQL
customer_reviews_df = fetch_data_from_sql()

# Intialize VADER sentiment intensity analysis
sia = SentimentIntensityAnalyzer()

def calculate_sentiment(review):
    '''Takes in review text and calculates the compound (normalized) sentiment score.'''
    
    sentiment = sia.polarity_scores(review)
    
    return sentiment['compound']

def categorize_sentiment(score, rating):
    '''Use both the text sentiment score and the numerical rating to determine sentiment category.'''
    
    if score > 0.05:  # Positive sentiment score
        if rating >= 4:
            return 'Positive'  # High rating and positive sentiment
        elif rating == 3:
            return 'Mixed Positive'  # Neutral rating but positive sentiment
        else:
            return 'Mixed Negative'  # Low rating but positive sentiment
    elif score < -0.05:  # Negative sentiment score
        if rating <= 2:
            return 'Negative'  # Low rating and negative sentiment
        elif rating == 3:
            return 'Mixed Negative'  # Neutral rating but negative sentiment
        else:
            return 'Mixed Positive'  # High rating but negative sentiment
    else:  # Neutral sentiment score
        if rating >= 4:
            return 'Positive'  # High rating with neutral sentiment
        elif rating <= 2:
            return 'Negative'  # Low rating with neutral sentiment
        else:
            return 'Neutral'  # Neutral rating and neutral sentiment

def sentiment_bucket(score):
    '''Intakes sentiment scores and buckets into a text range.'''
    if score >= 0.5:
        return '0.5 to 1.0'  # Strongly positive sentiment
    elif 0.0 <= score < 0.5:
        return '0.0 to 0.49'  # Mildly positive sentiment
    elif -0.5 <= score < 0.0:
        return '-0.49 to 0.0'  # Mildly negative sentiment
    else:
        return '-1.0 to -0.5'  # Strongly negative sentiment
    
# Calculate sentiment scores and add as SentimentScore column
customer_reviews_df['SentimentScore'] = customer_reviews_df['ReviewText'].apply(calculate_sentiment)

# Categorize sentiment scores with rating and add as SentimentCategory column
customer_reviews_df['SentimentCategory'] = customer_reviews_df.apply(
                                        lambda row: categorize_sentiment(row['SentimentScore'], row['Rating']), axis=1)

# Bin sentiment scores and add as SentimentBucket column
customer_reviews_df['SentimentBucket'] = customer_reviews_df['SentimentScore'].apply(sentiment_bucket)

# Save the new customer reviews dataframe with sentiment analysis included as a CSV file
script_dir = os.path.dirname(os.path.abspath(__file__))
output_path = os.path.join(script_dir, 'fact_customer_reviews_with_sentiment.csv')

customer_reviews_df.to_csv(output_path, index=False)

print('run complete')