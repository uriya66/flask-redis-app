from flask import Flask, render_template
import redis  # Imports the redis library that allows access to the Redis service

app = Flask(__name__)

@app.route('/')
def index():
    try:
        r = redis.Redis(host='redis', port=6379)  # Connects to the Redis server by the container name on the standard port
        r.set('message', 'Hello from Flask via Redis!')  # Stores a key named 'message' with a value
        msg = r.get('message').decode('utf-8')  # Retrieves the value and converts it to plain text
        return render_template('index.html', message=msg)
    except Exception as e:
        return f'<h1>Redis Error: {str(e)}</h1>'

if __name__ == "__main__":   # If the file is run (and not imported)
    app.run(host='0.0.0.0', port=8088)      # Run Flask on all addresses (allows access from outside)
