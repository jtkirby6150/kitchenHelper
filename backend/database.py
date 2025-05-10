import os
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Use the DATABASE_URL from the .env file
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://postgres:Brinnley01%21%40%23@localhost:5436/kitchenhelper")

# Create the SQLAlchemy engine
engine = create_engine(DATABASE_URL)

# Create a session factory
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Define the Base class for models
Base = declarative_base()
