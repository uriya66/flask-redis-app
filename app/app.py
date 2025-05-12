from flask import Flask, render_template
import redis  # Redis library
import mysql.connector  # MySQL connector

app = Flask(__name__)

@app.route('/')
def index():
    try:
        # Connect to Redis by service name and port
        r = redis.Redis(host='redis', port=6379)
        r.set('message', 'Hello from Flask via Redis!')
        redis_msg = r.get('message').decode('utf-8')
    except Exception as e:
        redis_msg = f"Redis Error: {str(e)}"

    try:
        # Connect to MySQL container by service name
        db = mysql.connector.connect(
            host="mysql",           # Docker service name (not localhost)
            user="app_user",        # User as defined in docker-compose
            password="app_pass123", # Password as defined in docker-compose
            database="app_db"       # Database name as defined
        )
        cursor = db.cursor()
        # Create table if not exists
        cursor.execute("CREATE TABLE IF NOT EXISTS visits (id INT AUTO_INCREMENT PRIMARY KEY, note VARCHAR(255))")
        # Insert new record
        cursor.execute("INSERT INTO visits (note) VALUES ('Hello from Flask via MySQL!')")
        db.commit()
        # Read all records
        cursor.execute("SELECT * FROM visits")
        rows = cursor.fetchall()
        mysql_msg = f"MySQL Records: {rows}"
    except Exception as e:
        mysql_msg = f"MySQL Error: {str(e)}"

    return f"""
        <h1>{redis_msg}</h1>
        <h2>{mysql_msg}</h2>
    """

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8088)  # Run Flask on all interfaces

