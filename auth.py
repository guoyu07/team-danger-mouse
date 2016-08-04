from flask import Flask, request
from flask.ext.cors import CORS
import json
import pusher

app = Flask(__name__)
CORS(app)

pusher_client = pusher.Pusher(
    app_id='232560',
    key='cfbbdd53d88cd46a7deb',
    secret='b4430e80c82bc1b8b729',
)

@app.route("/dangermouse/", methods=["POST"])
def pusher_auth():
  auth = pusher_client.authenticate(
    channel=request.form['channel_name'],
    socket_id=request.form['socket_id'],
    custom_data={
      'user_id': request.form.get('socket_id'),
      'user_info': {}
    }
  )
  print(auth)
  return json.dumps(auth)

if __name__ == "__main__":
  app.run()
