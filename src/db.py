from flask_sqlalchemy import SQLAlchemy
from sqlalchemy.orm import relationship
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
    course_subject = db.Column(db.String, nullable=False)
    course_num = db.Column(db.Integer, nullable=False)
    course_name = db.Column(db.String, nullable=False)
    user_to_course = db.relationship('UserToCourse', cascade='delete')

    def __init__(self, **kwargs):
      self.course_subject = kwargs.get('course_subject')
      self.course_num = kwargs.get('course_num')
      self.course_name = kwargs.get('course_name')

    
    def serialize(self):
      return {
          'course_subject': self.course_subject,
          'course_num': self.course_num,
          'course_name': self.course_name,
      }
    
class UserToCourse(db.Model):
    __tablename__ = 'usertocourse'
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

class Match(db.Model):
    __tablename__ = 'match'
    id = db.Column(db.Integer, primary_key=True)
    tutor_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    tutee_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    tutor = db.relationship("User", foreign_keys=[tutor_id])
    tutee = db.relationship("User", foreign_keys=[tutee_id])
    course_id = db.Column(db.Integer, db.ForeignKey('course.id'), nullable=False)

    # company_id = Column(Integer, ForeignKey('company.id'), nullable=False)
    # stakeholder_id = Column(Integer, ForeignKey('company.id'), nullable=False)
    # company = relationship("Company", foreign_keys=[company_id])
    # stakeholder = relationship("Company", foreign_keys=[stakeholder_id])
 
    def __init__(self, **kwargs):
      self.tutor_id = kwargs.get('tutor_id')
      self.tutee_id = kwargs.get('tutee_id')
      self.course_id = kwargs.get('course_id')
    
    def serialize(self):
      return {
          'tutor_id': self.tutor_id,
          'tutee_id': self.tutee_id,
          'course_id': self.course_id
      }
        