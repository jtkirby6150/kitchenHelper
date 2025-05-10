from sqlalchemy import Column, Integer, String, Text, Float, ForeignKey, Boolean, DateTime
from sqlalchemy.orm import relationship, backref
from datetime import datetime
from .database import Base

# Recipe model
class Recipe(Base):
    __tablename__ = "recipes"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    description = Column(Text, nullable=True)
    ingredients = Column(Text, nullable=False)
    instructions = Column(Text, nullable=False)
    cuisine = Column(String, nullable=True)
    dietary_tags = Column(String, nullable=True)
    prep_time = Column(Float, nullable=True)
    cook_time = Column(Float, nullable=True)
    total_time = Column(Float, nullable=True)
    servings = Column(Integer, nullable=True)
    visibility = Column(String, default="private")  # "private", "pending", or "public"
    is_immutable = Column(Boolean, default=False)  # True if the recipe is public and immutable
    user_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    ratings = Column(Float, default=0.0)  # Average rating for the recipe

    # Relationships
    user = relationship("User", back_populates="recipes")
    comments = relationship("Comment", back_populates="recipe", cascade="all, delete-orphan")
    ratings_relationship = relationship("Rating", back_populates="recipe", cascade="all, delete-orphan")
    ratings = relationship("Rating", back_populates="recipe", cascade="all, delete-orphan")

# User model
class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, nullable=False)
    email = Column(String, unique=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    role = Column(String, default="user")  # "admin", "staff", or "user"

    # Relationships
    recipes = relationship("Recipe", back_populates="user")
    notifications = relationship("Notification", back_populates="user", cascade="all, delete-orphan")
    preferences = relationship("UserPreference", uselist=False, back_populates="user", cascade="all, delete-orphan")

# Notification model
class Notification(Base):
    __tablename__ = "notifications"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    message = Column(String, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    is_read = Column(Boolean, default=False)

    # Relationships
    user = relationship("User", back_populates="notifications")

# UserPreference model
class UserPreference(Base):
    __tablename__ = "user_preferences"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    notify_comments = Column(Boolean, default=True)
    notify_ratings = Column(Boolean, default=True)
    notify_recipe_approval = Column(Boolean, default=True)

    # Relationships
    user = relationship("User", back_populates="preferences")

# Comment model
class Comment(Base):
    __tablename__ = "comments"

    id = Column(Integer, primary_key=True, index=True)
    recipe_id = Column(Integer, ForeignKey("recipes.id"), nullable=False)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    content = Column(Text, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    # Relationships
    recipe = relationship("Recipe", back_populates="comments")
    user = relationship("User")

# Rating model
class Rating(Base):
    __tablename__ = "ratings"

    id = Column(Integer, primary_key=True, index=True)
    recipe_id = Column(Integer, ForeignKey("recipes.id"), nullable=False)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)  # Rating value (e.g., 1-5)
    rating = Column(Float, nullable=False)

    # Relationships
    recipe = relationship("Recipe", back_populates="ratings_relationship")
    user = relationship("User")