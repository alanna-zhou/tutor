import json
import requests
from db import db, User, Course, UserToCourse, Match
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

# @app.before_first_request
def insert_initial_values(*args, **kwargs):
  # db.session.add(Course(course_subject='CS', course_num=2112, course_name='Object-Oriented Programming and Data Structures'))
  # db.session.add(Course(course_subject='CHEM', course_num=2090, course_name='General Chemistry'))
  # db.session.add(Course(course_subject='MATH', course_num=1920, course_name='Multivariable Calculus'))
  db.session.add(User(
    net_id='asz33',
    name='Alanna Zhou',
    year=2022,
    major='Computer Science',
    bio='I like fried bananas.'
  ))
  db.session.add(User(
    net_id='lae66',
    name='Luis Enriquez',
    year=2022,
    major='Mechanical Engineering',
    bio='I like crude memes.'
  ))
  db.session.add(User(
    net_id='slh268',
    name='Sarah Huang',
    year=2022,
    major='Chemical Engineering',
    bio='Yeetaki Mushroomz!'
  ))
  db.session.commit()
  subjects = requests.get('https://classes.cornell.edu/api/2.0/config/subjects.json?roster=FA18').json().get('data', '').get('subjects', '')
  subject_list = []
  for s in subjects:
      subject_list.append(s.get('value', ''))
  course_list = []
  for s in subject_list:
      courses = requests.get('https://classes.cornell.edu/api/2.0/search/classes.json?roster=FA18&subject='+str(s)).json().get('data', '').get('classes', '')
      for c in courses:
          db.session.add(Course(course_subject=c.get('subject', ''), course_num=c.get('catalogNbr', ''), course_name=c.get('titleLong', '')))
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
  return json.dumps({'success': True, 'data': user.serialize()}), 200

@app.route('/api/user/<string:net_id>/', methods=['POST'])
def edit_user(net_id):
  print('ENTERING EDIT USER')
  user = User.query.filter_by(net_id=net_id).first()
  if user is None:
    return json.dumps({'success': False, 'error': 'User does not exist!'}), 404
  post_body = json.loads(request.data)
  print("POST BODY", post_body)
  for value in post_body:
    print("VALUE", value)
    setattr(user, value, post_body.get(value))
  user = User.query.filter_by(net_id=net_id).first()
  return json.dumps({'success': True, 'data': user.serialize()}), 200


@app.route('/api/user/<string:net_id>/', methods=['GET'])
def get_user(net_id):
  user = User.query.filter_by(net_id=net_id).first()
  if user is None:
    return json.dumps({'success': False, 'error': 'User does not exist!'}), 404
  return json.dumps({'success': True, 'data': user.serialize()}), 200

@app.route('/api/user/add-course/', methods=['POST'])
def add_course_to_user():
  post_body = json.loads(request.data)
  keys = ['net_id', 'is_tutor', 'course_subject', 'course_num']
  for k in keys:
    if k not in post_body:
      return json.dumps({'success': False, 'error': 
          'Missing necessary parameter to add a course to a user!'}), 404
  user = User.query.filter_by(net_id=post_body.get('net_id')).first()
  if user is None:
    return json.dumps({'success': False, 'error': 'Invalid user!'}), 404
  course = Course.query.filter_by(
      course_subject=post_body.get('course_subject'),
      course_num=post_body.get('course_num'),
  ).first()
  if course is None:
    return json.dumps({'success': False, 'error': 'Invalid course!'}), 404
  user_to_course = UserToCourse.query.filter_by(user_id=user.id, course_id=course.id).one_or_none()
  if user_to_course is not None:
    return json.dumps({'success': False, 'error': 'Course already added to user!'}), 404
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
    'course_subject': course.course_subject,
    'course_num': course.course_num,
    'course_name': course.course_name
  }
  return json.dumps({'success': True, 'data': result }), 200

@app.route('/api/user/delete-course/', methods=['POST'])
def delete_course_from_user():
  post_body = json.loads(request.data)
  keys = ['net_id', 'course_subject', 'course_num']
  for k in keys:
    if k not in post_body:
      return json.dumps({'success': False, 'error': 
          'Missing necessary parameter to delete a course!'}), 404
  user = User.query.filter_by(net_id=post_body.get('net_id')).first()
  if user is None:
    return json.dumps({'success': False, 'error': 'Invalid user!'}), 404
  course = Course.query.filter_by(
      course_subject=post_body.get('course_subject'), 
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
    'course_subject': course.course_subject,
    'course_num': course.course_num,
    'course_name': course.course_name
  }
  return json.dumps({'success': True, 'data': result }), 200
  
@app.route('/api/courses/', methods=['GET'])
def get_all_courses():
  courses = Course.query.all()
  result = []
  for course in courses:
    result.append(course.serialize())
  return json.dumps({'success': True, 'data': result}), 200

@app.route('/api/user/<string:net_id>/courses/', methods=['GET'])
def get_user_courses(net_id):
  user = User.query.filter_by(net_id=net_id).first()
  if user is None:
    return json.dumps({'success': False, 'error': 'Invalid user!'}), 404
  user_to_course = UserToCourse.query.filter_by(user_id=user.id)
  if user_to_course is None:
    return json.dumps({'success': False, 'error': 'Course not added to user yet!'}), 404
  courses = []
  for uc in user_to_course:
    courses.append(Course.query.filter_by(id=uc.course_id).first().serialize())
  return json.dumps({'success': True, 'data': courses}), 200

@app.route('/api/tutor/<string:net_id>/courses/', methods=['GET'])
def get_tutor_courses(net_id):
  user = User.query.filter_by(net_id=net_id).first()
  if user is None:
    return json.dumps({'success': False, 'error': 'Invalid user!'}), 404
  user_to_course = UserToCourse.query.filter_by(user_id=user.id, is_tutor=True)
  if user_to_course is None:
    return json.dumps({'success': False, 'error': 'Course not added to user yet!'}), 404
  courses = []
  for uc in user_to_course:
    courses.append(Course.query.filter_by(id=uc.course_id).first().serialize())
  return json.dumps({'success': True, 'data': courses}), 200

@app.route('/api/tutee/<string:net_id>/courses/', methods=['GET'])
def get_tutee_courses(net_id):
  user = User.query.filter_by(net_id=net_id).first()
  if user is None:
    return json.dumps({'success': False, 'error': 'Invalid user!'}), 404
  user_to_course = UserToCourse.query.filter_by(user_id=user.id, is_tutor=False)
  if user_to_course is None:
    return json.dumps({'success': False, 'error': 'Course not added to user yet!'}), 404
  courses = []
  for uc in user_to_course:
    courses.append(Course.query.filter_by(id=uc.course_id).first().serialize())
  return json.dumps({'success': True, 'data': courses}), 200

@app.route('/api/course/<string:course_subject>/<string:course_num>/tutors/', methods=['GET'])
def get_course_tutors(course_subject, course_num):
  course = Course.query.filter_by(course_subject=course_subject, course_num=course_num).first()
  if course is None:
    return json.dumps({'success': False, 'error': 'Course does not exist!'}), 404
  user_to_courses = UserToCourse.query.filter_by(course_id=course.id, is_tutor=True)
  if user_to_courses is None:
    return json.dumps({'success': False, 'error': 'No tutors for this course yet!'}), 404
  tutors = []
  for uc in user_to_courses:
    tutor = User.query.filter_by(id=uc.user_id).first()
    if is_valid_tutor:
      tutors.append(tutor.net_id)
  return json.dumps({'success': True, 'data': tutors}), 200

@app.route('/api/course/<string:course_subject>/<string:course_num>/tutees/', methods=['GET'])
def get_course_tutees(course_subject, course_num):
  course = Course.query.filter_by(course_subject=course_subject, course_num=course_num).first()
  if course is None:
    return json.dumps({'success': False, 'error': 'Course does not exist!'}), 404
  user_to_courses = UserToCourse.query.filter_by(course_id=course.id, is_tutor=False)
  if user_to_courses is None:
    return json.dumps({'success': False, 'error': 'No tutees for this course yet!'}), 404
  tutees = []
  for uc in user_to_courses:
    tutee = User.query.filter_by(id=uc.user_id).first()
    if is_valid_tutee:
      tutees.append(tutee.net_id)
  return json.dumps({'success': True, 'data': tutees}), 200

@app.route('/api/match/', methods=['POST'])
def match_users():
  post_body = json.loads(request.data)
  keys = ['tutor_net_id', 'tutee_net_id', 'course_subject', 'course_num']
  for k in keys:
    if k not in post_body:
      return json.dumps({'success': False, 'error': 
          'Missing necessary parameter to match a tutor and tutee!'}), 404
  course = Course.query.filter_by(course_subject=post_body.get('course_subject'), 
      course_num=post_body.get('course_num')).first()
  if course is None:
    return json.dumps({'success': False, 'error': 'Invalid course!'}), 404
  tutor = User.query.filter_by(net_id=post_body.get('tutor_net_id')).first()
  if not is_valid_tutor(tutor, course):
    return json.dumps({'success': False, 'error': 'User is not a valid or available tutor!'}), 404
  tutee = User.query.filter_by(net_id=post_body.get('tutee_net_id')).first()
  if not is_valid_tutee(tutee, course):
    return json.dumps({'success': False, 'error': 'User is not a valid or available tutee!'}), 404
  match = Match.query.filter_by(tutor_id=tutor.id, tutee_id=tutee.id, course_id=course.id).first()
  if match is not None:
    return json.dumps({'success': False, 'error': 'Match has already been made!'}), 404
  match = Match(
    tutor_id=tutor.id,
    tutee_id=tutee.id,
    course_id=course.id
  )
  db.session.add(match)
  db.session.commit()
  result = {
    'tutor_net_id': tutor.net_id,
    'tutee_net_id': tutee.net_id,
    'course_subject': course.course_subject,
    'course_num': course.course_num,
    'course_name': course.course_name
  }
  return json.dumps({'success': True, 'data': result}), 200

def is_valid_tutor(tutor, course):
  is_tutor = UserToCourse.query.filter_by(user_id=tutor.id, course_id=course.id, is_tutor=True).first()
  match = Match.query.filter_by(tutor_id=tutor.id, course_id=course.id).first()
  return is_tutor is not None and match is None

def is_valid_tutee(tutee, course):
  is_tutee = UserToCourse.query.filter_by(user_id=tutee.id, course_id=course.id, is_tutor=False).first()
  match = Match.query.filter_by(tutee_id=tutee.id, course_id=course.id).first()
  return is_tutee is not None and match is None

if __name__ == '__main__':
  app.run(host='0.0.0.0', port=5000, debug=True)
