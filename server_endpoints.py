import sqlite3
from flask import Flask, request, send_from_directory, jsonify
import os
from werkzeug.utils import secure_filename
import DB.query_database as db
import random
import time
import threading
import DB.backend_functions as bacF

app = Flask(__name__)
UPLOAD_FOLDER = 'DB/uploads'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}

DATABASE = "DB/cinema.db"
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

def get_db_connection():
    conn = sqlite3.connect(DATABASE)
    conn.row_factory = sqlite3.Row
    return conn

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@app.route('/upload_media', methods=['POST'])
def upload_media():
    if 'file' not in request.files:
        return {'error': 'Eksik veri'}, 400

    file = request.files['file']

    if file.filename == '':
        return {'error': 'Dosya seçilmedi'}, 400

    if file and allowed_file(file.filename):
        filename = secure_filename(file.filename)
        upload_path = app.config['UPLOAD_FOLDER']

        os.makedirs(upload_path, exist_ok=True)
        file.save(os.path.join(upload_path, filename))

        return {'message': 'Dosya başarıyla yüklendi'}, 201
    return {'error': 'Geçersiz dosya'}, 400


@app.route('/upload_movie', methods=['POST'])
def create_movie():
    data = request.get_json()

    # Required fields validation
    required_fields = ['movieName', 'duration', 'movieGenre', 'movieType', 'description', 'director']
    for field in required_fields:
        if field not in data:
            return jsonify({"error": f"Missing required field: {field}"}), 400

    # Type checking
    if not isinstance(data['duration'], int):
        return jsonify({"error": "Duration must be an integer"}), 400

    # Optional fields with type checking
    popularity_point = data.get('popularity_point')
    average_point = data.get('average_point')

    if popularity_point is not None and not isinstance(popularity_point, (int, float)):
        return jsonify({"error": "Popularity point must be a number"}), 400
    if average_point is not None and not isinstance(average_point, (int, float)):
        return jsonify({"error": "Average point must be a number"}), 400

    # Call add_movie function
    movie_id = db.add_movie(
        movie_name=data['movieName'],
        duration=data['duration'],
        movie_genre=data['movieGenre'],
        movie_type=data['movieType'],
        description=data.get('description'),
        director=data.get('director'),
        popularity_point=popularity_point,
        average_point=average_point
    )

    return jsonify({"message": "Movie added successfully", "movie_id": movie_id}), 201


@app.route('/sessions/<string:date>', methods=['GET'])
def getSessionsByDate(date):
    sessions = db.get_sessions_by_date(date)

    return jsonify(sessions)


@app.route('/sessions/<int:movieId>', methods=['GET'])
def get_sessions_by_movie(movieId):
    sessions = db.get_sessions_of_movie(movieId)

    return jsonify(sessions)


@app.route('/seats/<int:sessionId>', methods=['GET'])
def getSeatsBySession(sessionId):
    seats = db.get_session_seats(sessionId)

    return jsonify(seats)


@app.route('/AddSession', methods=['POST'])
def addSession():
    data = request.get_json()
    # Required fields validation
    required_fields = ['movieID', 'hallID', 'date', 'sessionNo']
    for field in required_fields:
        if field not in data:
            return jsonify({"error": f"Missing required field: {field}"}), 400

    # Call add_ticket function
    sessionID = db.add_session(
        movie_id=data['movieID'],
        hall_id=data['hallID'],
        date=data['date'],
        session_no=data['sessionNo'],
        status='Active'
    )

    return jsonify({"message": "Ticket created successfully", "sessionID": sessionID}), 201


@app.route('/session/<int:session_id>', methods=['GET', 'DELETE'])
def delete_session_endpoint(session_id):
    if(request.method == 'DELETE'):
        success = db.delete_session(session_id)
        if success:
            return jsonify({"message": f"Movie with ID {session_id} deleted successfully."}), 200
        else:
            return jsonify({"error": f"Movie with ID {session_id} not found."}), 404
    elif(request.method == 'GET'):
        movie = db.get_session(session_id)
        return jsonify(movie)


@app.route('/buy_ticket', methods=['POST'])
def buy_ticket():
    data = request.get_json()

    required_fields = ['customerID', 'sessionSeatID', 'sessionID']
    for field in required_fields:
        if field not in data:
            return jsonify({"error": f"Missing required field: {field}"}), 400

    # Call add_ticket function
    ticket_id = db.add_ticket(
        customer_id=data['customerID'],
        session_seat_id=data['sessionSeatID'],
        session_id=data['sessionID'],
        price=100
    )

    return jsonify({"message": "Ticket created successfully", "ticket_id": ticket_id}), 201


@app.route('/add_movie_rating', methods=['POST'])
def add_movie_rating_endpoint():
    try:
        # JSON verisini al
        data = request.get_json()

        # Gerekli alanları kontrol et
        required_fields = ['customer_id', 'movie_id', 'rating', 'rating_date']
        if not data or not all(field in data for field in required_fields):
            return jsonify({'error': 'Missing required fields'}), 400

        # Verileri al ve tipleri kontrol et
        customer_id = data['customer_id']
        movie_id = data['movie_id']
        rating = data['rating']
        rating_date = data['rating_date']

        if not isinstance(customer_id, int) or not isinstance(movie_id, int):
            return jsonify({'error': 'customer_id and movie_id must be integers'}), 400
        if not isinstance(rating, (int, float)) or not 0 <= rating <= 5:  # Örnek rating aralığı
            return jsonify({'error': 'rating must be a number between 0 and 5'}), 400
        if not isinstance(rating_date, str):
            return jsonify({'error': 'rating_date must be a string'}), 400

        # Fonksiyonu çağır
        result = db.add_movie_rating(customer_id, movie_id, float(rating), rating_date)

        # Başarılı yanıt
        return jsonify({'message': 'Rating added successfully', 'result_id': result}), 201

    except Exception as e:
        print(e)
        return jsonify({'error': str(e)}), 500


@app.route('/movies', methods=['GET'])
def get_movies():
    genre = request.args.get('genre')

    if genre:
        movies = db.get_movies_by_genre(genre)
    else:
        movies = db.get_all_movies()

    return jsonify(movies)


@app.route('/halls', methods=['GET'])
def get_halls():
    movies = db.get_all_halls()

    return jsonify(movies)


@app.route('/movies/<int:movie_id>', methods=['GET', 'DELETE'])
def delete_movie_endpoint(movie_id):
    if(request.method == 'DELETE'):
        success = db.delete_movie(movie_id)
        if success:
            return jsonify({"message": f"Movie with ID {movie_id} deleted successfully."}), 200
        else:
            return jsonify({"error": f"Movie with ID {movie_id} not found."}), 404
    elif(request.method == 'GET'):
        movie = db.get_movie(movie_id)
        return jsonify(movie)


@app.route('/users/<int:customer_id>', methods=['DELETE'])
def delete_customer_endpoint(customer_id):
    success = db.delete_customer(customer_id)
    if success:
        return jsonify({"message": "Your account deleted successfully."}), 200
    else:
        return jsonify({"error": "Account not found."}), 404

@app.route('/concession', methods=['GET', 'PUT'])
def get_concession():
    """
    Flask endpoint to retrieve a concession item by item_name.
    Query Parameter:
        item_name: Name of the concession item (required).
    Returns:
        JSON response with the concession item details or an error message.
    """
    item_name = request.args.get('item_name')

    if not item_name:
        return jsonify({"error": "item_name query parameter is required"}), 400

    item = db.get_concession_by_name(item_name)

    if item:
        if(request.method == 'GET'):
            return jsonify(item), 200
        else:
            item_count = request.args.get('item_count')
            if not item_count:
                return jsonify({"error": "count query parameter is required"}), 400
            db.update_concession_stock(item_name, int(item_count))
            return "Ok"
    return jsonify({"error": f"No concession item found with name: {item_name}"}), 404


@app.route('/signUp', methods=['POST'])
def add_customer_endpoint():
    """
    Flask endpoint to add a new customer.
    Request Body (JSON):
        name: Name of the customer (required).
        password: Password of the customer (required).
    Returns:
        JSON response with the customerID of the new customer or an error message.
    """
    try:
        data = request.get_json()
        if not data or 'name' not in data or 'password' not in data:
            return jsonify({"error": "name and password are required in JSON body"}), 400

        name = data['name']
        password = data['password']
        customer_id = db.add_customer(name, password)
        return jsonify({"customerID": customer_id, "message": "Customer added successfully"}), 201
    except ValueError as e:
        return jsonify({"error": str(e)}), 400
    except Exception as e:
        return jsonify({"error": f"Server error: {str(e)}"}), 500


@app.route('/signIn', methods=['POST'])
def sign_in_customer_endpoint():
    """
    Flask endpoint to add a new customer.
    Request Body (JSON):
        name: Name of the customer (required).
        password: Password of the customer (required).
    Returns:
        JSON response with the customerID of the new customer or an error message.
    """
    try:
        data = request.get_json()
        if not data or 'name' not in data or 'password' not in data:
            return jsonify({"error": "name and password are required in JSON body"}), 400

        name = data['name']
        password = data['password']
        (status, customer_id) = bacF.user_login(name, password)
        if status == 1:
            return jsonify({"status": status, "customerID": customer_id, "message": "Customer added successfully"}), 201
        elif status == 0:
            return jsonify({"status": status, "message": "Wrong name or password"}), 201
        elif status == 2:
            return jsonify({"status": status, "customerID": customer_id, "message": "Admin is here"}), 201
    except ValueError as e:
        return jsonify({"error": str(e)}), 400
    except Exception as e:
        return jsonify({"error": f"Server error: {str(e)}"}), 500


@app.route('/images/<id>')
def get_image(id):
    return send_from_directory(app.config['UPLOAD_FOLDER'], f'movie{id}.jpg')


@app.route('/movies/best-rated', methods=['GET'])
def get_best_rated_movies():
    """
    Endpoint to retrieve up to 5 movies with the highest averagePoint.
    Returns a JSON list of movie dictionaries.
    """
    movies = db.get_best_point_movies()
    return jsonify(movies), 200

@app.route('/movies/most-rated', methods=['GET'])
def get_most_rated_movies():
    """
    Endpoint to retrieve up to 5 movies with the highest number of ratings all-time.
    Returns a JSON list of movie dictionaries with rating_count.
    """
    movies = db.get_most_rated_movies()
    return jsonify(movies), 200

@app.route('/movies/weekly-most-rated', methods=['GET'])
def get_weekly_most_rated_movies():
    """
    Endpoint to retrieve up to 5 movies with the highest number of ratings in the last week.
    Returns a JSON list of movie dictionaries with rating_count.
    """
    movies = db.get_weekly_most_rated_movies()
    return jsonify(movies), 200

@app.route('/movies/weekly-best-rated', methods=['GET'])
def get_weekly_best_rated_movies():
    """
    Endpoint to retrieve up to 5 movies with the highest average rating in the last week.
    Returns a JSON list of movie dictionaries with weekly_average.
    """
    movies = db.get_weekly_best_points()
    return jsonify(movies), 200

@app.route('/movies/popular', methods=['GET'])
def get_popular_movies():
    """
    Endpoint to retrieve up to 5 movies with the highest popularityPoint.
    Returns a JSON list of movie dictionaries.
    """
    movies = db.get_popular_movies()
    return jsonify(movies), 200


def reduce_concession_stocks_periodically():
    """
    Runs in a separate thread to reduce stock quantities of all concession items
    by a random amount (10-50) every 5 hours.
    Uses the update_concession function to perform updates.
    """
    while True:
        try:
            # Connect to the database
            conn = sqlite3.connect("DB/cinema.db")
            cursor = conn.cursor()
            
            # Fetch all concession items
            cursor.execute("SELECT itemID, stockQuantity FROM CinemaConcessions")
            concessions = cursor.fetchall()
            
            for item_id, current_stock in concessions:
                if current_stock is None or current_stock <= 0:
                    continue  # Skip items with no stock
                
                # Generate random reduction (10 to 50)
                reduction = random.randint(10, min(50, current_stock))  # Don't reduce more than available
                
                # Calculate new stock
                new_stock = current_stock - reduction
                
                # Update using the provided update_concession function
                success = db.update_concession(
                    item_id=item_id,
                    stock_quantity=new_stock
                )
                
                if success:
                    print(f"Reduced stock for item {item_id} by {reduction}. New stock: {new_stock}")
                else:
                    print(f"Failed to update stock for item {item_id}")
            
            conn.close()
            
        except Exception as e:
            print(f"Error in reduce_concession_stocks_periodically: {e}")
        
        # Sleep for 5 hours (5 * 3600 seconds)
        time.sleep(5 * 3600)


@app.route('/sendAdmin')
def serve_index():
    return send_from_directory('DB/WEBS/adminWeb/', 'index.html')

# DB/adminWeb/ içindeki diğer statik dosyaları sunmak için
@app.route('/adminWeb/<path:filename>')
def serve_static(filename):
    return send_from_directory('DB/WEBS/adminWeb/', filename)


@app.route('/')
def serve_client():
    return send_from_directory('DB/WEBS/clientWeb/', 'index.html')

# DB/adminWeb/ içindeki diğer statik dosyaları sunmak için
@app.route('/clientWeb/<path:filename>')
def serve_clientFiles(filename):
    return send_from_directory('DB/WEBS/clientWeb/', filename)


def start_stock_reducer_thread():
    """
    Starts the concession stock reduction process in a separate daemon thread.
    """
    thread = threading.Thread(target=reduce_concession_stocks_periodically, daemon=True)
    thread.start()
    print("Concession stock reducer thread started.")

if __name__ == "__main__":
    start_stock_reducer_thread()
    app.run(debug=False)




