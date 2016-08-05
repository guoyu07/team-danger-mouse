from flask import Flask, request
from flask.ext.cors import CORS
import json
import pusher

app = Flask(__name__)
CORS(app)

pusher_client = pusher.Pusher(
    app_id='233024',
    key='30bde1096db2be8e7f53',
    secret='f97bdb6a86e395f59110',
)

@app.route("/dangermouse/auth", methods=["POST"])
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
