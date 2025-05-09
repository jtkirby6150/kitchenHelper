from sqlalchemy import Column, Integer, String, Text, ARRAY
from backend.app.db.base import Base

class Recipe(Base):
    __tablename__ = 'recipes'

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    description = Column(Text)
    ingredients = Column(ARRAY(String))
    prep_time = Column(Integer)  # in minutes
    cook_time = Column(Integer)  # in minutes
    instructions = Column(Text)
    dietary_tags = Column(ARRAY(String))  # e.g., ['vegan', 'gluten-free']