import json
import requests
from db import db, User, Course, UserToCourse
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
  db.session.add(Course(course_name='CS', course_num=2112))
  db.session.add(Course(course_name='CHEM', course_num=2090))
  db.session.add(Course(course_name='MATH', course_num=1920))
  db.session.add(User(
    net_id='asz33',
    name='alanna',
    year=2022,
    major='cs',
    bio='hi'
  ))
  db.session.add(User(
    net_id='lae66',
    name='luis',
    year=2022,
    major='mechanical engineering',
    bio='i am from belgium'
  ))
  db.session.add(UserToCourse(
    user_id=1,
    is_tutor=False,
    course_id=1
  ))
  db.session.commit()
  # subjects = requests.get('https://classes.cornell.edu/api/2.0/config/subjects.json?roster=FA18').json().get('data', '').get('subjects', '')
  # subject_list = []
  # for s in subjects:
  #     subject_list.append(s.get('value', ''))
  # course_list = []
  # for s in subject_list:
  #     courses = requests.get('https://classes.cornell.edu/api/2.0/search/classes.json?roster=FA18&subject='+str(s)).json().get('data', '').get('classes', '')
  #     for c in courses:
  #         db.session.add(Course(course_name=c.get('subject', ''), course_num=c.get('catalogNbr', '')))
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
  user = User.query.filter_by(net_id=post_body.get('net_id')).first()
  if user is not None:
    return json.dumps({'success': False, 'error': 'User already exists!' }), 404
  user = User(
      net_id=post_body.get('net_id'), 
      name=post_body.get('name', ''), 
      year=post_body.get('year', ''), 
      major=post_body.get('major', ''), 
      bio=post_body.get('bio', '')
  )
  db.session.add(user)
  db.session.commit()
  return json.dumps({'success': True, 'data': user.serialize()}), 201

@app.route('/api/user/add-course/', methods=['POST'])
def add_course_to_user():
  post_body = json.loads(request.data)
  keys = ['net_id', 'is_tutor', 'course_name', 'course_num']
  for k in keys:
    if k not in post_body:
      return json.dumps({'success': False, 'error': 
          'Missing necessary parameter to add a course to a user!'}), 404
  user = User.query.filter_by(net_id=post_body.get('net_id')).first()
  if user is None:
    return json.dumps({'success': False, 'error': 'Invalid user!'}), 404
  course = Course.query.filter_by(
      course_name=post_body.get('course_name'), 
      course_num=post_body.get('course_num')
  ).first()
  if course is None:
    return json.dumps({'success': False, 'error': 'Invalid course!'}), 404
  user_to_course = UserToCourse(
    is_tutor=post_body.get('is_tutor', ''),
    user_id=user.id,
    course_id=course.id
  )
  db.session.add(user_to_course)
  db.session.commit()
  print('QUERY ALL', [q.serialize() for q in UserToCourse.query.all()])
  result = {
    'net_id': user.net_id,
    'is_tutor': user_to_course.is_tutor,
    'course_name': course.course_name,
    'course_num': course.course_num
  }
  return json.dumps({'success': True, 'data': result }), 200

@app.route('/api/user/delete-course/', methods=['POST'])
def delete_course_from_user():
  post_body = json.loads(request.data)
  keys = ['net_id', 'course_name', 'course_num']
  for k in keys:
    if k not in post_body:
      return json.dumps({'success': False, 'error': 
          'Missing necessary parameter to delete a course!'}), 404
  user = User.query.filter_by(net_id=post_body.get('net_id')).first()
  if user is None:
    return json.dumps({'success': False, 'error': 'Invalid user!'}), 404
  course = Course.query.filter_by(
      course_name=post_body.get('course_name'), 
      course_num=post_body.get('course_num')
  ).first()
  if course is None:
    return json.dumps({'success': False, 'error': 'Invalid course!'}), 404
  user_to_course = UserToCourse.query.filter_by(
      user_id=user.id,
      course_id=course.id
  ).first()
  if user_to_course is None:
    return json.dumps({'success': False, 'error': 'Course has not been added to user yet!'}), 404
  db.session.delete(user_to_course)
  db.session.commit()
  result = {
    'net_id': user.net_id,
    'course_name': course.course_name,
    'course_num': course.course_num
  }
  return json.dumps({'success': True, 'data': result }), 200
  
@app.route('/api/courses/', methods=['GET'])
def get_all_courses():
  courses = Course.query.all()
  result = []
  for course in courses:
    result.append(course.serialize())
  return json.dumps({'success': True, 'data': result}), 200

if __name__ == '__main__':
  app.run(host='0.0.0.0', port=5000, debug=True)
