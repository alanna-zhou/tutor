import json
import requests
from db import db, User
from flask import Flask, request

db_filename = "data.db"
app = Flask(__name__)

app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///%s' % db_filename
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['SQLALCHEMY_ECHO'] = True

db.init_app(app)
with app.app_context():
  db.create_all()

@app.route('/api/user/', methods=['POST'])
def create_user():
  post_body = json.loads(request.data)
  if 'net_id' not in post_body:
    return json.dumps({'success': False, 'error': 'Needs net id'}), 404
  user = User(net_id=post_body.get('net_id'), name=post_body.get('name', ''), 
      year=post_body.get('year', ''), major=post_body.get('major', ''), 
      bio=post_body.get('bio', '')
  )
  db.session.add(user)
  db.session.commit()
  return json.dumps({'success': True, 'data': user.serialize()}), 201

@app.route('/api/courses/', methods=['GET'])
def get_all_courses():
  r = requests.get('https://classes.cornell.edu/api/2.0/search/classes.json?roster=SP19&subject=CS')
  jsonfile = r.json()
  data = jsonfile.get('data', '')
  classes = data.get('classes', '')
  list = []
  for c in classes:
    list.append({'subject': c.get('subject', ''), 'number': c.get('catalogNbr')})
  return json.dumps(list)

if __name__ == '__main__':
  app.run(host='0.0.0.0', port=5000, debug=True)
