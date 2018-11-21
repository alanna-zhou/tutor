from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

class User(db.Model):
    __tablename__ = 'user'
    id = db.Column(db.Integer, primary_key=True)
    net_id = db.Column(db.String, nullable=False)
    name = db.Column(db.String, nullable=False)
    year = db.Column(db.String, nullable=False)
    major = db.Column(db.String, nullable=False)
    bio = db.Column(db.String, nullable=False)
    user_to_course = db.relationship('UserToCourse', cascade='delete')

    def __init__(self, **kwargs):
      self.net_id = kwargs.get('net_id')
      self.name = kwargs.get('name')
      self.year = kwargs.get('year')
      self.major = kwargs.get('major')
      self.bio = kwargs.get('bio')

    def serialize(self):
      return {
          'net_id': self.net_id,
          'name': self.name,
          'year': self.year,
          'major': self.major,
          'bio': self.bio,
      }

class Course(db.Model):
    __tablename__ = 'course'
    id = db.Column(db.Integer, primary_key=True)
    course_name = db.Column(db.String, nullable=False)
    course_num = db.Column(db.Integer, nullable=False)

    def __init__(self, **kwargs):
      self.course_name = kwargs.get('course_name')
      self.course_num = kwargs.get('course_num')
    
    def serialize(self):
      return {
          'course_name': self.course_name,
          'course_num': self.course_num
      }
    
class UserToCourse(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    is_tutor = db.Column(db.Boolean, nullable=False)
    course_id = db.Column(db.Integer, db.ForeignKey('course.id'), nullable=False)
    
    def __init__(self, **kwargs):
      self.user_id = kwargs.get('user_id')
      self.is_tutor = kwargs.get('is_tutor', False)
      self.course_id = kwargs.get('course_id')
    
    def serialize(self):
      return {
          'user_id': self.user_id,
          'is_tutor': self.is_tutor,
          'course_id': self.course_id
      }



        