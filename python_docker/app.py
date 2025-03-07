from flask import Flask
from redis import Redis
import os
import socket

# Connect to Redis
redis = Redis(host="redis", port=6379)

app = Flask(__name__)

@app.route("/")
def hello():
    try:
        visits = redis.incr("counter")
    except RedisError:
        visits = "<i>cannot connect to Redis, counter disabled</i>"
    html = "<h3>Hello {name}!</h3>" \
           "<b>Hostname:</b> {hostname}<br/>" 
    return "<h3>Hello {}!</h3><b>Hostname:</b> {}<br/><b>Visits:</b> {}".format( os.getenv("NAME", "world"), socket.gethostname(), visits )
if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8000, debug=True)
