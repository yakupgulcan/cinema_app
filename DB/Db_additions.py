#import query_database as db
import sqlite3

#print(db.add_admin("ykp", "celali"))

def delete_movie() -> bool:
   
    conn = sqlite3.connect("Kodlar/DB/cinema.db")
    cursor = conn.cursor()
    cursor.execute("DELETE FROM Movie WHERE movieID = ?", (9,))
    deleted = cursor.rowcount > 0
    conn.commit()
    conn.close()
    return deleted


print(delete_movie())

##### Concession Add
# print(db.add_concession("Patlamış Mısır", 43, 50, 300))
# print(db.add_concession("Kola", 15.2, 20, 100))
# print(db.add_concession("Gözlük", 123, 150, 300))

# conn = sqlite3.connect("cinema.db")
# cursor = conn.cursor()
#
# cursor.execute("""
# DROP TABLE CinemaConcessions
# """)
#
# conn.commit()
# conn.close()


# print(db.add_cinema_hall("Hall2", 100, "2D"))
# print(db.add_cinema_hall("Hall3", 100, "2D"))
# print(db.add_cinema_hall("Hall4", 100, "2D"))
# print(db.add_cinema_hall("Hall5", 100, "2D"))
# print(db.add_cinema_hall("Hall6", 100, "2D"))
# print(db.add_cinema_hall("Hall7", 100, "2D"))
# print(db.add_cinema_hall("Hall8", 100, "3D"))
# print(db.add_cinema_hall("Hall9", 100, "3D"))
# print(db.add_cinema_hall("Hall10", 100, "3D")

##### Cinema Hall Management
# print(db.add_cinema_hall("Hall1", 100, "2D"))
# print(db.add_cinema_hall("Hall2", 100, "2D"))
# print(db.add_cinema_hall("Hall3", 100, "2D"))
# print(db.add_cinema_hall("Hall4", 100, "2D"))
# print(db.add_cinema_hall("Hall5", 100, "2D"))
# print(db.add_cinema_hall("Hall6", 100, "2D"))
# print(db.add_cinema_hall("Hall7", 100, "2D"))
# print(db.add_cinema_hall("Hall8", 100, "3D"))
# print(db.add_cinema_hall("Hall9", 100, "3D"))
# print(db.add_cinema_hall("Hall10", 100, "3D")


# conn = sqlite3.connect("cinema.db")
# cursor = conn.cursor()

# cursor.execute("""
# DELETE FROM CinemaHall
# """)

# conn.commit()
# conn.close()


##### Seat Management
# conn = db.connect_db()
# cursor = conn.cursor()
# cursor.execute("SELECT * FROM Seat")
# row = [dict(row) for row in cursor.fetchall()]
# print(row)
# conn.close()

# conn = sqlite3.connect("cinema.db")
# cursor = conn.cursor()
#
# cursor.execute("""
# DELETE FROM seat
# """)
#



# cursor.execute("""
# DROP TABLE seat
# """)

# conn.commit()
# conn.close()

##### Session Management
# print(db.add_session(1, 1, "2025-05-07", "0", "Active"))
# print(db.add_session(1, 3, "2025-05-07", "0", "Active"))

# conn = sqlite3.connect("cinema.db")
# cursor = conn.cursor()

# cursor.execute("SELECT * FROM SessionSeat")
# row = [dict(row) for row in cursor.fetchall()]
# for i in row:
#     print(i)
# conn.close()

# cursor.execute("""
# DROP TABLE Session
# """)

# cursor.execute("""
# DROP TABLE SessionSeat
# """)

# conn.commit()
# conn.close()

##### Ticket Management

# conn = sqlite3.connect("cinema.db")
# cursor = conn.cursor()
#
# cursor.execute("SELECT * FROM SessionSeat")
# row = [dict(row) for row in cursor.fetchall()]
# for i in row:
#     print(i)
# conn.close()

# cursor.execute("""
# DROP TABLE Ticket
# """)

# conn.commit()
# conn.close()



# conn = sqlite3.connect("cinema.db")
# cursor = conn.cursor()
#
# cursor.execute("""
# DROP TABLE Admin
# """)
#
# conn.commit()
# conn.close()