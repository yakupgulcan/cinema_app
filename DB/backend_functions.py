import sqlite3
from typing import Dict, List
from datetime import datetime, timedelta

import os
basedir = os.path.abspath(os.path.dirname(__file__))
db_path = os.path.join(basedir,"cinema.db")

def connect_db():
    """Establishes and returns a connection to the cinema database."""
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row  # Enables accessing columns by name
    return conn

def update_movie_ratings():
    """
    Updates popularityPoint and averagePoint for all movies based on MovieRatings.
    - popularityPoint: (movie ratings in last week / total ratings in last week) * 
                       (sum of movie's ratings in last week / movie's rating count in last week)
    - averagePoint: Total sum of rating points / Total number of ratings for the movie
    """
    conn = connect_db()
    cursor = conn.cursor()
    
    # Get the date for one week ago
    one_week_ago = (datetime.now() - timedelta(days=7)).strftime('%Y-%m-%d')
    
    # Get total ratings in the last week
    cursor.execute("""
        SELECT COUNT(*) as total_weekly_ratings 
        FROM MovieRatings 
        WHERE ratingDate >= ?
    """, (one_week_ago,))
    total_weekly_ratings = cursor.fetchone()['total_weekly_ratings']
    
    # Get all movies
    cursor.execute("SELECT movieID FROM Movie")
    movies = cursor.fetchall()
    
    for movie in movies:
        movie_id = movie['movieID']
        
        # Calculate averagePoint (all-time average)
        cursor.execute("""
            SELECT COUNT(*) as rating_count, SUM(rating) as rating_sum
            FROM MovieRatings
            WHERE movieID = ?
        """, (movie_id,))
        result = cursor.fetchone()
        rating_count = result['rating_count']
        rating_sum = result['rating_sum'] or 0
        
        average_point = rating_sum / rating_count if rating_count > 0 else 0
        
        # Calculate popularityPoint (last week's data)
        cursor.execute("""
            SELECT COUNT(*) as weekly_rating_count, SUM(rating) as weekly_rating_sum
            FROM MovieRatings
            WHERE movieID = ? AND ratingDate >= ?
        """, (movie_id, one_week_ago))
        weekly_result = cursor.fetchone()
        weekly_rating_count = weekly_result['weekly_rating_count']
        weekly_rating_sum = weekly_result['weekly_rating_sum'] or 0
        
        # Calculate weekly average rating
        weekly_average = weekly_rating_sum / weekly_rating_count if weekly_rating_count > 0 else 0
        
        # Calculate popularityPoint
        # If no ratings in the last week, set popularityPoint to 0
        popularity_point = 0
        if total_weekly_ratings > 0 and weekly_rating_count > 0:
            rating_proportion = weekly_rating_count / total_weekly_ratings
            popularity_point = rating_proportion * weekly_average
        
        # Update the Movie table
        cursor.execute("""
            UPDATE Movie
            SET popularityPoint = ?, averagePoint = ?
            WHERE movieID = ?
        """, (popularity_point, average_point, movie_id))
    
    conn.commit()
    conn.close()


def user_login(name: str, password: str) -> tuple:
    """
    Checks user login and returns 0 for not found, 1 for customer, 2 for admin
    Args:
        name: Name of the user.
        password: Password of the user.
    Returns 0 for not found, 1 for customer, 2 for admin
    """
    
    conn = sqlite3.connect(db_path)  # Assuming connect_db() is meant to connect to cinema.db
    cursor = conn.cursor()
    
    # Check if the user is a customer
    cursor.execute("SELECT customerID FROM Customer WHERE name = ? AND password = ?", (name, password))
    customer_result = cursor.fetchone()
    
    if customer_result:
        conn.close()
        return (1, customer_result[0])  # Customer found
    
    # Check if the user is an admin
    cursor.execute("SELECT adminID FROM Admin WHERE name = ? AND password = ?", (name, password))
    admin_result = cursor.fetchone()
    
    if admin_result:
        conn.close()
        return (2, admin_result[0] )  # Admin found
    
    # No match found
    conn.close()
    return (0,0)  # Not found


