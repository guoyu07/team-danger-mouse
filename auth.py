from flask import Flask, request
import json
import pusher

app = Flask(__name__)

pusher_client = pusher.Pusher(
    app_id='232560',
    key='cfbbdd53d88cd46a7deb',
    secret='b4430e80c82bc1b8b729',
)

@app.route("/dangermouse/", methods=["POST"])
def pusher_auth():
  auth = pusher_client.authenticate(
    channel=request.form['channel_name'],
    socket_id=request.form['socket_id']
  )
  return json.dumps(auth)
