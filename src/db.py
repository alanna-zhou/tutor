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

    def __init__(self, **kwargs):
      self.net_id = kwargs.get('net_id', '')
      self.name = kwargs.get('name', '')
      self.year = kwargs.get('year', '')
      self.major = kwargs.get('major', '')
      self.bio = kwargs.get('bio', '')

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
      self.course_name = kwargs.get('course_name', '')
      self.course_num = kwargs.get('course_num', '')
    
    def serialize(self):
      return {
          'course_name': self.course_name,
          'course_num': self.course_num
      }

    

# https://dzone.com/articles/how-to-initialize-database-with-default-values-in


        