import sqlite3

conn = sqlite3.connect("cinema.db")
cursor = conn.cursor()

# Customer
cursor.execute("""
CREATE TABLE IF NOT EXISTS Customer (
    customerID INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    password TEXT NOT NULL,
    budget REAL
)
""")

# Admin
cursor.execute("""
CREATE TABLE IF NOT EXISTS Admin (
    adminID INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    password TEXT NOT NULL
)
""")

# Movie
cursor.execute("""
CREATE TABLE IF NOT EXISTS Movie (
    movieID INTEGER PRIMARY KEY AUTOINCREMENT,
    movieName TEXT NOT NULL,
    description TEXT,
    director TEXT,
    duration INTEGER,
    movieGenre TEXT,
    movieType TEXT,
    popularityPoint REAL,
    averagePoint REAL
)
""")

# MovieRatings
cursor.execute("""
CREATE TABLE IF NOT EXISTS MovieRatings (
    ratingID INTEGER PRIMARY KEY AUTOINCREMENT,
    customerID INTEGER, 
    movieID INTEGER, 
    rating REAL, 
    ratingDate TEXT,
    FOREIGN KEY (customerID) REFERENCES Customer(customerID) ON DELETE CASCADE,
    FOREIGN KEY (movieID) REFERENCES Movie(movieID) ON DELETE CASCADE
)
""")


# CinemaConcessions
cursor.execute("""
CREATE TABLE IF NOT EXISTS CinemaConcessions (
    itemID INTEGER PRIMARY KEY AUTOINCREMENT,
    itemName TEXT, 
    purchasePrice REAL,
    salePrice REAL,
    stockQuantity INTEGER
)
""")

# CinemaHall 
cursor.execute("""
CREATE TABLE IF NOT EXISTS CinemaHall (
    hallID INTEGER PRIMARY KEY AUTOINCREMENT,
    hallName TEXT,
    capacity INTEGER,
    hallType TEXT
)
""")

# Seat
cursor.execute("""
CREATE TABLE IF NOT EXISTS Seat (
    seatID INTEGER PRIMARY KEY AUTOINCREMENT,
    hallID INTEGER,
    seatNumber INTEGER,
    FOREIGN KEY (hallID) REFERENCES CinemaHall(hallID) ON DELETE CASCADE
)
""")

# Session 
cursor.execute("""
CREATE TABLE IF NOT EXISTS Session (
    sessionID INTEGER PRIMARY KEY AUTOINCREMENT,
    movieID INTEGER,
    hallID INTEGER,
    date TEXT,
    sessionNo TEXT,
    status TEXT,
    FOREIGN KEY (movieID) REFERENCES Movie(movieID) ON DELETE CASCADE,
    FOREIGN KEY (hallID) REFERENCES CinemaHall(hallID)
)
""")

# Ticket 
cursor.execute("""
CREATE TABLE IF NOT EXISTS Ticket (
    ticketID INTEGER PRIMARY KEY AUTOINCREMENT,
    customerID INTEGER,
    sessionID INTEGER,
    sessionSeatID INTEGER,
    price REAL,
    FOREIGN KEY (customerID) REFERENCES Customer(customerID) ON DELETE CASCADE,
    FOREIGN KEY (sessionID) REFERENCES Session(sessionID) ON DELETE CASCADE,
    FOREIGN KEY (sessionSeatID) REFERENCES SessionSeat(sessionSeatID)
)
""")

#SessionSeat
cursor.execute("""
CREATE TABLE IF NOT EXISTS SessionSeat (
    sessionSeatID INTEGER PRIMARY KEY AUTOINCREMENT,
    sessionID INTEGER,
    seatID INTEGER,
    isAvailable INTEGER DEFAULT 1,
    FOREIGN KEY (sessionID) REFERENCES Session(sessionID) ON DELETE CASCADE,
    FOREIGN KEY (seatID) REFERENCES seat(seatID) ON DELETE CASCADE
)
""")

# Commit changes and close connection
conn.commit()
conn.close()