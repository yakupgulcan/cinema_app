import sqlite3

conn = sqlite3.connect("cinema.db")
cursor = conn.cursor()

# Admin ekle
cursor.execute("INSERT OR IGNORE INTO Admin (adminID, name) VALUES (?, ?)", (1, 'Ahmet Yılmaz'))

# Customer ekle
cursor.execute("INSERT OR IGNORE INTO Customer (customerID, name, budget) VALUES (?, ?, ?)", (1, 'Ali Veli', 120.0))
cursor.execute("INSERT OR IGNORE INTO Customer (customerID, name, budget) VALUES (?, ?, ?)", (2, 'Ayşe Demir', 200.0))

# Movie ekle
cursor.execute("""
INSERT OR IGNORE INTO Movie 
(movieID, movieName, duration, movieGenre, movieType, averagePoint)
VALUES (?, ?, ?, ?, ?, ?)
""", (1, 'Görevimiz Tehlike', 120, 'Aksiyon', '2D', 8.5))

cursor.execute("""
INSERT OR IGNORE INTO Movie 
(movieID, movieName, duration, movieGenre, movieType, averagePoint)
VALUES (?, ?, ?, ?, ?, ?)
""", (2, 'Yüzüklerin Efendisi: Yüzük Kardeşliği', 178, 'Fantastik', '3D', 8.5))

cursor.execute("""
INSERT OR IGNORE INTO Movie 
(movieID, movieName, duration, movieGenre, movieType, averagePoint)
VALUES (?, ?, ?, ?, ?, ?)
""", (3, 'Başlangıç', 148, 'Bilim Kurgu', '2D', 8.8))

cursor.execute("""
INSERT OR IGNORE INTO Movie 
(movieID, movieName, duration, movieGenre, movieType, averagePoint)
VALUES (?, ?, ?, ?, ?, ?)
""", (4, 'Parazit', 132, 'Dram', '2D', 8.6))

cursor.execute("""
INSERT OR IGNORE INTO Movie 
(movieID, movieName, duration, movieGenre, movieType, averagePoint)
VALUES (?, ?, ?, ?, ?, ?)
""", (5, 'Örümcek-Adam: Eve Dönüş Yok', 150, 'Aksiyon', '3D', 8.3))

# Inventory
cursor.execute("""
INSERT INTO Inventory (movieID, adminID, numberOfMovies)
VALUES (?, ?, ?)
""", (1, 1, 50))

# CinemaConcessions
cursor.execute("""
INSERT OR IGNORE INTO CinemaConcessions 
(itemID, purchasePrice, salePrice, stockQuantity, customerID, adminID)
VALUES (?, ?, ?, ?, ?, ?)
""", (1, 2.5, 5.0, 100, 1, 1))

# CinemaHall
# cursor.execute("""
# INSERT OR IGNORE INTO CinemaHall
# (hallID, hallName, capacity, hallType, adminID)
# VALUES (?, ?, ?, ?, ?)
# """, (1, 'Salon 1', 50, 'IMAX', 1))

# Seat (örnek 5 koltuk)
# for seat_num in range(1, 6):
#     cursor.execute("""
#     INSERT OR IGNORE INTO Seat
#     (seatID, seatType, hallID, seatNumber, isAvailable)
#     VALUES (?, ?, ?, ?, ?)
#     """, (seat_num, 'Standart', 1, seat_num, 1))

# Session
# cursor.execute("""
# INSERT OR IGNORE INTO Session
# (sessionID, movieID, hallID, adminID, date, status)
# VALUES (?, ?, ?, ?, ?, ?)
# """, (1, 1, 1, 1, '2025-05-05 18:00', 'available'))

# Ticket
# cursor.execute("""
# INSERT INTO Ticket
# (customerID, sessionID, seatID, price)
# VALUES (?, ?, ?, ?)
# """, (1, 1, 1, 25.0))

# Koltuğu rezerve işaretle
# cursor.execute("UPDATE Seat SET isAvailable = ? WHERE seatID = ?", (0, 1))

conn.commit()
conn.close()
print("Güvenli şekilde veriler eklendi.")
