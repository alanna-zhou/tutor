import json
import requests
from db import db, User, Course
from flask import Flask, request
from sqlalchemy.event import listen
from sqlalchemy import event
from flask_sqlalchemy import SQLAlchemy


db_filename = "data.db"
app = Flask(__name__)

app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///%s' % db_filename
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['SQLALCHEMY_ECHO'] = True

db.init_app(app)
with app.app_context():
  db.create_all()

@app.before_first_request
def insert_initial_values(*args, **kwargs):
  subjects = requests.get('https://classes.cornell.edu/api/2.0/config/subjects.json?roster=FA18').json().get('data', '').get('subjects', '')
  subject_list = []
  for s in subjects:
      subject_list.append(s.get('value', ''))
  course_list = []
  for s in subject_list:
      courses = requests.get('https://classes.cornell.edu/api/2.0/search/classes.json?roster=FA18&subject='+str(s)).json().get('data', '').get('classes', '')
      for c in courses:
          db.session.add(Course(course_name=c.get('subject', ''), course_num=c.get('catalogNbr', '')))
  db.session.commit()

@app.route('/api/test/<int:course_id>/', methods=['GET'])
def test(course_id):
  course = Course.query.filter_by(id=course_id).first() 
  return json.dumps({'success': True, 'data': course.serialize()})

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

@app.route('/api/user/add-course/', methods=['POST'])
def add_course_to_user():
  post_body = json.loads(request.data)
  keys = ['net_id', 'tutor', 'course_name', 'course_num']
  for k in keys:
    if k not in post_body:
      return json.dumps({'success': False, 'error': 
          'Missing necessary parameter to add a course to a user!'}), 404
  
@app.route('/api/courses/', methods=['GET'])
def get_all_courses():
  courses = Course.query.all()
  result = []
  for course in courses:
    result.append(course.serialize())
  return json.dumps(result)

if __name__ == '__main__':
  app.run(host='0.0.0.0', port=5000, debug=True)
