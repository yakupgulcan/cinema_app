import sqlite3
import DB.backend_functions
from typing import Optional, Dict, List, Any
from datetime import datetime, timedelta

import os
basedir = os.path.abspath(os.path.dirname(__file__))
db_path = os.path.join(basedir, "cinema.db")

def connect_db():
    print(basedir)
    print("DB path in query : " + db_path)
    """Establishes and returns a connection to the cinema database."""
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row  # Enables accessing columns by name
    return conn


### GET OPERATIONS
def get_best_point_movies() -> List[Dict[str, Any]]:
    """
    Retrieves up to 5 movies with the highest averagePoint.
    Returns a list of dictionaries containing movie details including movieID, movieName, averagePoint.
    """
    conn = connect_db()
    cursor = conn.cursor()
    
    cursor.execute("""
        SELECT * FROM Movie
        WHERE averagePoint IS NOT NULL
        ORDER BY averagePoint DESC
        LIMIT 5
    """)
    
    movies = [dict(row) for row in cursor.fetchall()]
    conn.close()
    return movies

def get_most_rated_movies() -> List[Dict[str, Any]]:
    """
    Retrieves up to 5 movies with the highest number of ratings all-time.
    Returns a list of dictionaries containing movie details and rating_count.
    """
    conn = connect_db()
    cursor = conn.cursor()
    
    cursor.execute("""
        SELECT m.*, COUNT(r.ratingID) as rating_count
        FROM Movie m
        LEFT JOIN MovieRatings r ON m.movieID = r.movieID
        GROUP BY m.movieID
        ORDER BY rating_count DESC, m.movieName ASC
        LIMIT 5
    """)
    
    movies = [dict(row) for row in cursor.fetchall()]
    conn.close()
    return movies

def get_weekly_most_rated_movies() -> List[Dict[str, Any]]:
    """
    Retrieves up to 5 movies with the highest number of ratings in the last week.
    Returns a list of dictionaries containing movie details and rating_count.
    """
    conn = connect_db()
    cursor = conn.cursor()
    
    one_week_ago = (datetime.now() - timedelta(days=7)).strftime('%Y-%m-%d')
    
    cursor.execute("""
        SELECT m.*, COUNT(r.ratingID) as rating_count
        FROM Movie m
        LEFT JOIN MovieRatings r ON m.movieID = r.movieID
        WHERE r.ratingDate >= ?
        GROUP BY m.movieID
        ORDER BY rating_count DESC, m.movieName ASC
        LIMIT 5
    """, (one_week_ago,))
    
    movies = [dict(row) for row in cursor.fetchall()]
    conn.close()
    return movies

def get_weekly_best_points() -> List[Dict[str, Any]]:
    """
    Retrieves up to 5 movies with the highest average rating (total rating / number of ratings)
    in the last week.
    Returns a list of dictionaries containing movie details and weekly_average.
    """
    conn = connect_db()
    cursor = conn.cursor()
    
    one_week_ago = (datetime.now() - timedelta(days=7)).strftime('%Y-%m-%d')
    
    cursor.execute("""
        SELECT m.*, AVG(r.rating) as weekly_average
        FROM Movie m
        LEFT JOIN MovieRatings r ON m.movieID = r.movieID
        WHERE r.ratingDate >= ?
        GROUP BY m.movieID
        HAVING COUNT(r.ratingID) > 0
        ORDER BY weekly_average DESC, m.movieName ASC
        LIMIT 5
    """, (one_week_ago,))
    
    movies = [dict(row) for row in cursor.fetchall()]
    conn.close()
    return movies

def get_popular_movies() -> List[Dict[str, Any]]:
    """
    Retrieves up to 5 movies with the highest popularityPoint.
    Returns a list of dictionaries containing movie details including movieID, movieName, popularityPoint.
    """
    conn = connect_db()
    cursor = conn.cursor()
    
    cursor.execute("""
        SELECT * FROM Movie
        WHERE popularityPoint IS NOT NULL
        ORDER BY popularityPoint DESC
        LIMIT 5
    """)
    
    movies = [dict(row) for row in cursor.fetchall()]
    conn.close()
    return movies

def get_all_movies() -> List[Dict[str, Any]]:
    """
    Retrieves all movies from the Movie table.
    Returns a list of dictionaries containing movie details.
    """
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM Movie")
    movies = [dict(row) for row in cursor.fetchall()]
    conn.close()
    return movies

def get_movies_by_genre(genre: str) -> List[Dict[str, Any]]:
    """
    Retrieves movies that include the specified genre in their movieGenre field.
    The movieGenre field contains genres separated by commas (e.g., 'Klasik,Yeni,Korku').
    Args:
        genre: A single genre to filter movies by (e.g., 'Korku').
    Returns a list of dictionaries containing movie details.
    """
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM Movie WHERE movieGenre LIKE ?", (f'%{genre}%',))
    movies = [dict(row) for row in cursor.fetchall()]
    conn.close()
    return movies

def get_all_sessions() -> List[Dict[str, Any]]:
    """
    Retrieves all sessions from the Session table.
    Returns a list of dictionaries containing session details.
    """
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT s.*, m.movieName, h.hallName 
        FROM Session s
        JOIN Movie m ON s.movieID = m.movieID
        JOIN CinemaHall h ON s.hallID = h.hallID
    """)
    sessions = [dict(row) for row in cursor.fetchall()]
    conn.close()
    return sessions

def get_sessions_by_date(date: str) -> List[Dict[str, Any]]:
    """
    Retrieves sessions for a specific date.
    Args:
        date: The date in format 'YYYY-MM-DD'.
    Returns a list of dictionaries containing session details.
    """
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT s.*, m.movieName, h.hallName 
        FROM Session s
        JOIN Movie m ON s.movieID = m.movieID
        JOIN CinemaHall h ON s.hallID = h.hallID
        WHERE s.date = ?
    """, (date,))
    sessions = [dict(row) for row in cursor.fetchall()]
    conn.close()
    return sessions

def get_available_seats(hall_id: int, session_id: int) -> List[Dict[str, Any]]:
    """
    Retrieves available seats for a specific hall and session.
    Args:
        hall_id: The ID of the cinema hall.
        session_id: The ID of the session.
    Returns a list of dictionaries containing seat details.
    """
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT s.* 
        FROM Seat s
        LEFT JOIN Ticket t ON s.seatID = t.seatID AND t.sessionID = ?
        WHERE s.hallID = ? AND s.isAvailable = 1 AND t.ticketID IS NULL
    """, (session_id, hall_id))
    seats = [dict(row) for row in cursor.fetchall()]
    conn.close()
    return seats

def get_sessions_by_hall(hall_id: int) -> List[Dict[str, Any]]:
    """
    Retrieves all sessions for a specific hall.
    Args:
        hall_id: The ID of the cinema hall.
    Returns a list of dictionaries containing session details.
    """
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT s.*, m.movieName, h.hallName 
        FROM Session s
        JOIN Movie m ON s.movieID = m.movieID
        JOIN CinemaHall h ON s.hallID = h.hallID
        WHERE s.hallID = ?
    """, (hall_id,))
    sessions = [dict(row) for row in cursor.fetchall()]
    conn.close()
    return sessions

def get_sessions_of_movie(movie_id: int) -> List[Dict[str, Any]]:
    """
    Retrieves all sessions for a specific movie from the Session table.
    Args:
        movie_id: The ID of the movie.
    Returns a list of dictionaries containing session details.
    """
    conn = connect_db()
    cursor = conn.cursor()
    print("hello")
    cursor.execute("""
        SELECT s.*, m.movieName, h.hallName 
        FROM Session s
        JOIN Movie m ON s.movieID = m.movieID
        JOIN CinemaHall h ON s.hallID = h.hallID
        WHERE s.movieID = ?
    """, (movie_id,))
    sessions = [dict(row) for row in cursor.fetchall()]
    conn.close()
    return sessions

def get_customer(customer_id: int) -> Optional[Dict[str, Any]]:
    """
    Retrieves customer details by customerID.
    Args:
        customer_id: The ID of the customer.
    Returns a dictionary containing customer details or None if not found.
    """
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM Customer WHERE customerID = ?", (customer_id,))
    row = cursor.fetchone()
    conn.close()
    return dict(row) if row else None

def get_admin(admin_id: int) -> Optional[Dict[str, Any]]:
    """
    Retrieves admin details by adminID.
    Args:
        admin_id: The ID of the admin.
    Returns a dictionary containing admin details or None if not found.
    """
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM Admin WHERE adminID = ?", (admin_id,))
    row = cursor.fetchone()
    conn.close()
    return dict(row) if row else None

def get_movie(movie_id: int) -> Optional[Dict[str, Any]]:
    """
    Retrieves movie details by movieID.
    Args:
        movie_id: The ID of the movie.
    Returns a dictionary containing movie details or None if not found.
    """
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM Movie WHERE movieID = ?", (movie_id,))
    row = cursor.fetchone()
    conn.close()
    return dict(row) if row else None

def get_movie_rating(rating_id: int) -> Optional[Dict[str, Any]]:
    """
    Retrieves movie rating details by ratingID.
    Args:
        rating_id: The ID of the movie rating.
    Returns a dictionary containing movie rating details or None if not found.
    """
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM MovieRatings WHERE ratingID = ?", (rating_id,))
    row = cursor.fetchone()
    conn.close()
    return dict(row) if row else None


def get_concession(item_id: int) -> Optional[Dict[str, Any]]:
    """
    Retrieves cinema concession details by itemID.
    Args:
        item_id: The ID of the concession item.
    Returns a dictionary containing concession details or None if not found.
    """
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM CinemaConcessions WHERE itemID = ?", (item_id,))
    row = cursor.fetchone()
    conn.close()
    return dict(row) if row else None

def get_cinema_hall(hall_id: int) -> Optional[Dict[str, Any]]:
    """
    Retrieves cinema hall details by hallID.
    Args:
        hall_id: The ID of the cinema hall.
    Returns a dictionary containing cinema hall details or None if not found.
    """
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM CinemaHall WHERE hallID = ?", (hall_id,))
    row = cursor.fetchone()
    conn.close()
    return dict(row) if row else None

def get_seat(seat_id: int) -> Optional[Dict[str, Any]]:
    """
    Retrieves seat details by seatID.
    Args:
        seat_id: The ID of the seat.
    Returns a dictionary containing seat details or None if not found.
    """
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM Seat WHERE seatID = ?", (seat_id,))
    row = cursor.fetchone()
    conn.close()
    return dict(row) if row else None

def get_session(session_id: int) -> Optional[Dict[str, Any]]:
    """
    Retrieves session details by sessionID.
    Args:
        session_id: The ID of the session.
    Returns a dictionary containing session details or None if not found.
    """
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT s.*, m.movieName, h.hallName 
        FROM Session s
        JOIN Movie m ON s.movieID = m.movieID
        JOIN CinemaHall h ON s.hallID = h.hallID
        WHERE s.sessionID = ?
    """, (session_id,))
    row = cursor.fetchone()
    conn.close()
    return dict(row) if row else None

def get_ticket(ticket_id: int) -> Optional[Dict[str, Any]]:
    """
    Retrieves ticket details by ticketID.
    Args:
        ticket_id: The ID of the ticket.
    Returns a dictionary containing ticket details or None if not found.
    """
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM Ticket WHERE ticketID = ?", (ticket_id,))
    row = cursor.fetchone()
    conn.close()
    return dict(row) if row else None


def get_sessions_of_hall(hall_id: int) -> List[Dict[str, Any]]:
    """
    Retrieves all sessions for a specific cinema hall from the Session table.
    Args:
        hall_id: The ID of the cinema hall.
    Returns a list of dictionaries containing session details.
    """
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT s.*, m.movieName, h.hallName 
        FROM Session s
        JOIN Movie m ON s.movieID = m.movieID
        JOIN CinemaHall h ON s.hallID = h.hallID
        WHERE s.hallID = ?
    """, (hall_id,))
    sessions = [dict(row) for row in cursor.fetchall()]
    conn.close()
    return sessions

def get_session_seats(session_id: int) -> List[Dict[str, Any]]:
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute("""
            SELECT * FROM SessionSeat WHERE sessionID = ?
        """, (session_id,))
    seats = [dict(row) for row in cursor.fetchall()]
    conn.close()
    return seats



def get_all_halls() -> List[Dict[str, Any]]:
    """
    Retrieves all Halls from the CinemaHall table.
    Returns a list of dictionaries containing hall details.
    """
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM CinemaHall")
    halls = [dict(row) for row in cursor.fetchall()]
    conn.close()
    return halls


### ADD OPERATIONS

def add_movie(
    movie_name: str,
    duration: int,
    movie_genre: str,
    movie_type: str,
    description: str = None,
    director: str = None,
    popularity_point: Optional[float] = None,
    average_point: Optional[float] = None
) -> int:
    """
    Adds a new movie to the Movie table.
    Args:
        movie_name: Name of the movie.
        duration: Duration of the movie in minutes.
        movie_genre: Genres of the movie, comma-separated (e.g., 'Klasik,Yeni,Korku').
        movie_type: Type of the movie (e.g., '2D', '3D').
        description: Optional description of the movie.
        director: Optional director of the movie.
        popularity_point: Optional popularity score of the movie.
        average_point: Optional average rating of the movie.
    Returns the movieID of the newly inserted movie.
    """
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO Movie (movieName, description, director, duration, movieGenre, movieType, popularityPoint, averagePoint)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    """, (movie_name, description, director, duration, movie_genre, movie_type, popularity_point, average_point))
    movie_id = cursor.lastrowid
    conn.commit()
    conn.close()
    return movie_id

def add_ticket(customer_id: int, session_id: int, session_seat_id: int, price: float) -> int:
    """
    Adds a new ticket to the Ticket table.
    Args:
        customer_id: The ID of the customer purchasing the ticket.
        session_id: The ID of the session for the ticket.
        seat_id: The ID of the seat for the ticket.
        price: The price of the ticket.
    Returns the ticketID of the newly inserted ticket.
    """
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO Ticket (customerID, sessionID, sessionSeatID, price)
        VALUES (?, ?, ?, ?)
    """, (customer_id, session_id, session_seat_id, price))
    ticket_id = cursor.lastrowid

    cursor.execute("""
            UPDATE SessionSeat
            SET isAvailable = 0
            WHERE sessionSeatID = ?
        """, (session_seat_id,))
    conn.commit()
    conn.close()
    return ticket_id


def add_movie_rating(customer_id: int, movie_id: int, rating: float, rating_date: str) -> int:
    """
    Adds a new movie rating to the MovieRatings table.
    Args:
        customer_id: The ID of the customer giving the rating.
        movie_id: The ID of the movie being rated.
        rating: The rating score.
        rating_date: The date of the rating in 'YYYY-MM-DD' format.
    Returns the ratingID of the newly inserted rating.
    """
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO MovieRatings (customerID, movieID, rating, ratingDate)
        VALUES (?, ?, ?, ?)
    """, (customer_id, movie_id, rating, rating_date))
    rating_id = cursor.lastrowid
    conn.commit()
    conn.close()
    DB.backend_functions.update_movie_ratings()
    return rating_id


def add_customer(name: str, password: str, budget: Optional[float] = None) -> int:
    """
    Adds a new customer to the Customer table.
    Args:
        name: Name of the customer.
        password: Password of the customer.
        budget: Optional budget of the customer.
    Returns the customerID of the newly inserted customer.
    """
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO Customer (name, password, budget)
        VALUES (?, ?, ?)
    """, (name, password, budget))
    customer_id = cursor.lastrowid
    conn.commit()
    conn.close()
    return customer_id

def add_admin(name: str, password: str) -> int:
    """
    Adds a new admin to the Admin table.
    Args:
        name: Name of the admin.
        password: Password of the admin.
    Returns the adminID of the newly inserted admin.
    """
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO Admin (name, password)
        VALUES (?, ?)
    """, (name, password))
    admin_id = cursor.lastrowid
    conn.commit()
    conn.close()
    return admin_id

def add_concession(item_name: str, purchase_price: float, sale_price: float, stock_quantity: int) -> int:
    """
    Adds a new concession item to the CinemaConcessions table.
    Args:
        item_name: Name of the concession item.
        purchase_price: The purchase price of the concession item.
        sale_price: The sale price of the concession item.
        stock_quantity: The stock quantity of the concession item.
    Returns the itemID of the newly inserted concession item.
    """
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO CinemaConcessions (itemName, purchasePrice, salePrice, stockQuantity)
        VALUES (?, ?, ?, ?)
    """, (item_name, purchase_price, sale_price, stock_quantity))
    item_id = cursor.lastrowid
    conn.commit()
    conn.close()
    return item_id

def get_concession_by_name(item_name: str) -> dict | None:
    """
    Retrieves a concession item from the CinemaConcessions table by item name.
    Args:
        item_name: Name of the concession item to retrieve.
    Returns:
        A dictionary containing the concession item details (itemID, itemName, purchasePrice,
        salePrice, stockQuantity) if found, otherwise None.
    """
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT itemID, itemName, purchasePrice, salePrice, stockQuantity
        FROM CinemaConcessions
        WHERE itemName = ?
    """, (item_name,))
    result = cursor.fetchone()
    conn.close()
    return  dict(result)


def update_concession_stock(item_name: str, stock_quantity: int) -> int | None:
    """
    Updates the stock quantity of a concession item in the CinemaConcessions table.
    Args:
        item_name: Name of the concession item to update.
        stock_quantity: New stock quantity for the concession item.
    Returns:
        The itemID of the updated concession item, or None if no item is found.
    Raises:
        ValueError: If stock_quantity is negative.
    """
    if stock_quantity < 0:
        raise ValueError("stock_quantity cannot be negative")

    conn = connect_db()
    cursor = conn.cursor()

    # Güncelleme sorgusu
    cursor.execute("""
        UPDATE CinemaConcessions
        SET stockQuantity = ?
        WHERE itemName = ?
    """, (stock_quantity, item_name))

    # Etkilenen satır sayısını kontrol et
    if cursor.rowcount > 0:
        # Güncellenen kaydın itemID'sini al
        cursor.execute("SELECT itemID FROM CinemaConcessions WHERE itemName = ?", (item_name,))
        item_id = cursor.fetchone()[0]
        conn.commit()
        conn.close()
        return item_id

    # Eğer hiçbir kayıt güncellenmediyse
    conn.close()
    return None

def add_session(movie_id: int, hall_id: int, date: str, session_no: str, status: str) -> int:
    """
    Adds a new session to the Session table.
    Args:
        movie_id: The ID of the movie for the session.
        hall_id: The ID of the cinema hall for the session.
        date: The date of the session in 'YYYY-MM-DD' format.
        session_no: The session number or identifier.
        status: The status of the session (e.g., 'Active', 'Cancelled').
    Returns the sessionID of the newly inserted session.
    """
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO Session (movieID, hallID, date, sessionNo, status)
        VALUES (?, ?, ?, ?, ?)
    """, (movie_id, hall_id, date, session_no, status))
    session_id = cursor.lastrowid

    conn.commit()
    conn.close()
    add_session_seats_to_session(session_id, hall_id)
    return session_id

def add_seat(hall_id: int, seat_number: int, is_available: int = 1) -> int:
    """
    Adds a new seat to the Seat table.
    Args:
        hall_id: The ID of the cinema hall the seat belongs to.
        seat_number: The number of the seat.
        is_available: Availability status of the seat (1 for available, 0 for unavailable, default 1).
    Returns the seatID of the newly inserted seat.
    """
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO Seat (hallID, seatNumber, isAvailable)
        VALUES (?, ?, ?)
    """, (hall_id, seat_number, is_available))
    seat_id = cursor.lastrowid
    conn.commit()
    conn.close()
    return seat_id

def add_cinema_hall(hall_name: str, capacity: int, hall_type: Optional[str] = None) -> int:
    """
    Adds a new cinema hall to the CinemaHall table.
    Args:
        hall_name: Name of the cinema hall.
        capacity: The seating capacity of the hall.
        hall_type: Optional type of the hall (e.g., 'Standard', 'IMAX').
    Returns the hallID of the newly inserted cinema hall.
    """
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO CinemaHall (hallName, capacity, hallType)
        VALUES (?, ?, ?)
    """, (hall_name, capacity, hall_type))
    hall_id = cursor.lastrowid
    conn.commit()
    conn.close()
    add_seats_by_capacity(hall_id, capacity)
    return hall_id

def add_seats_by_capacity(hall_id: int, capacity: int) -> List[int]:
    """
    Adds seats numbered from 1 to the specified capacity for a given cinema hall.
    Args:
        hall_id: The ID of the cinema hall to add seats for.
        capacity: The number of seats to add (numbered from 1 to capacity).
    Returns a list of seatIDs for the newly inserted seats.
    """
    conn = connect_db()
    cursor = conn.cursor()
    seat_ids = []
    for seat_number in range(1, capacity + 1):
        cursor.execute("""
            INSERT INTO Seat (hallID, seatNumber)
            VALUES (?, ?)
        """, (hall_id, seat_number))
        seat_ids.append(cursor.lastrowid)
    conn.commit()
    conn.close()
    return seat_ids


def add_session_seats_to_session(sessionId: int, hallId: int) -> int:
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM Seat WHERE hallID = ?", (hallId,))
    seats = cursor.fetchall()
    for seat in seats:
        cursor.execute("""
            INSERT INTO SessionSeat (sessionID, seatID, isAvailable)
            VALUES (?, ?, 1)
        """, (sessionId, dict(seat)['seatID']))
    sessionSeatId = cursor.lastrowid
    conn.commit()
    conn.close()
    return sessionSeatId

### UPDATE OPERATIONS
def update_concession(item_id: int, 
                      item_name: Optional[str] = None, 
                      purchase_price: Optional[float] = None, 
                      sale_price: Optional[float] = None, 
                      stock_quantity: Optional[int] = None) -> bool:
    """
    Updates an existing concession item in the CinemaConcessions table.
    Args:
        item_id: The ID of the concession item to update.
        item_name: Optional new name of the concession item.
        purchase_price: Optional new purchase price.
        sale_price: Optional new sale price.
        stock_quantity: Optional new stock quantity.
    Returns True if the concession was updated, False if not found or no updates provided.
    """
    conn = connect_db()
    cursor = conn.cursor()
    updates = []
    params = []
    if item_name is not None:
        updates.append("itemName = ?")
        params.append(item_name)
    if purchase_price is not None:
        updates.append("purchasePrice = ?")
        params.append(purchase_price)
    if sale_price is not None:
        updates.append("salePrice = ?")
        params.append(sale_price)
    if stock_quantity is not None:
        updates.append("stockQuantity = ?")
        params.append(stock_quantity)
    if not updates:
        conn.close()
        return False
    params.append(item_id)
    query = f"UPDATE CinemaConcessions SET {', '.join(updates)} WHERE itemID = ?"
    cursor.execute(query, params)
    updated = cursor.rowcount > 0
    conn.commit()
    conn.close()
    return updated



def update_customer(customer_id: int, 
                    name: Optional[str] = None, 
                    password: Optional[str] = None, 
                    budget: Optional[float] = None) -> bool:
    """
    Updates an existing customer in the Customer table.
    Args:
        customer_id: The ID of the customer to update.
        name: Optional new name of the customer.
        password: Optional new password.
        budget: Optional new budget.
    Returns True if the customer was updated, False if not found or no updates provided.
    """
    conn = sqlite3.connect(db_path)  # Assuming connection to cinema.db
    cursor = conn.cursor()
    
    updates = []
    params = []
    
    if name is not None:
        updates.append("name = ?")
        params.append(name)
    if password is not None:
        updates.append("password = ?")
        params.append(password)
    if budget is not None:
        updates.append("budget = ?")
        params.append(budget)
    
    if not updates:
        conn.close()
        return False
    
    params.append(customer_id)
    query = f"UPDATE Customer SET {', '.join(updates)} WHERE customerID = ?"
    
    cursor.execute(query, params)
    updated = cursor.rowcount > 0
    
    conn.commit()
    conn.close()
    
    return updated


### DELETE OPERATIONS

def delete_customer(customer_id: int) -> bool:
    """
    Deletes a customer from the Customer table by customerID.
    Args:
        customer_id: The ID of the customer to delete.
    Returns True if the customer was deleted, False if not found.
    """
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM Customer WHERE customerID = ?", (customer_id,))
    deleted = cursor.rowcount > 0
    conn.commit()
    conn.close()
    return deleted

def delete_movie(movie_id: int) -> bool:
    """
    Deletes a movie from the Movie table by movieID.
    Args:
        movie_id: The ID of the movie to delete.
    Returns True if the movie was deleted, False if not found.
    """
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM Movie WHERE movieID = ?", (movie_id,))
    deleted = cursor.rowcount > 0
    conn.commit()
    conn.close()
    return deleted


def delete_session(session_id: int) -> bool:
    """
    Deletes a session from the Session table by customerID.
    Args:
        session_id: The ID of the customer to delete.
    Returns True if the session was deleted, False if not found.
    """
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM Session WHERE sessionID = ?", (session_id,))
    deleted = cursor.rowcount > 0
    conn.commit()
    conn.close()
    return deleted



