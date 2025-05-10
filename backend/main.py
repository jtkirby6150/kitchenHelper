from .database import SessionLocal, engine
from fastapi import FastAPI, HTTPException, Depends
from fastapi.responses import JSONResponse, RedirectResponse
from fastapi.exceptions import RequestValidationError
from sqlalchemy.orm import Session
from .models import Base, Recipe, User, UserPreference, Notification, Rating
from .schemas import RecipeCreate, RecipeResponse, UserPreferenceUpdate, UserPreferenceResponse, NotificationResponse
from fastapi_limiter import FastAPILimiter
from fastapi_limiter.depends import RateLimiter
from fastapi.middleware.cors import CORSMiddleware
from fastapi_pagination import Page, add_pagination
from fastapi_pagination.utils import disable_installed_extensions_check
from fastapi_pagination.ext.sqlalchemy import paginate  # Use the SQLAlchemy extension for pagination
from typing import List, Optional
import redis
import logging
import os
from dotenv import load_dotenv
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from datetime import datetime
from .auth import verify_password, get_password_hash, create_access_token
from contextlib import asynccontextmanager
from pydantic import BaseModel, EmailStr
import uvicorn
import jwt

# Load environment variables from .env file
load_dotenv()

# Verify the DATABASE_URL is loaded
print("DATABASE_URL:", os.getenv("DATABASE_URL"))

# Initialize FastAPI app
app = FastAPI(
    title="KitchenHelper API",
    description="API for managing recipes in the KitchenHelper application.",
    version="1.0.0",
    contact={
        "name": "James Kirby",
        "email": "james.t.kirby@gmail.com",
    },
)

# Initialize the database
Base.metadata.create_all(bind=engine)

# Configure logging
logging.basicConfig(level=logging.INFO)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Replace "*" with specific origins for better security
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Dependency to get the database session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Lifespan event handler for initializing Redis
@asynccontextmanager
async def lifespan(app: FastAPI):
    redis_client = redis.Redis(host="localhost", port=6379, decode_responses=True)
    await FastAPILimiter.init(redis_client)
    yield

# Exception handler for validation errors
@app.exception_handler(RequestValidationError)
def validation_exception_handler(request, exc):
    return JSONResponse(
        status_code=422,
        content={"detail": exc.errors(), "body": exc.body},
    )

# Middleware to log requests
@app.middleware("http")
async def add_custom_headers(request, call_next):
    try:
        response = await call_next(request)
        return response
    except Exception as exc:
        return JSONResponse(
            status_code=500,
            content={"detail": "An internal server error occurred."},
        )

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    payload = jwt.decode(token, os.getenv("SECRET_KEY"), algorithms=[os.getenv("ALGORITHM")])
    username = payload.get("sub")
    if username is None:
        raise HTTPException(status_code=401, detail="Invalid authentication credentials")
    user = db.query(User).filter(User.username == username).first()
    if user is None:
        raise HTTPException(status_code=401, detail="User not found")
    return user

@app.post("/token")
def login_for_access_token(
    form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)
):
    user = db.query(User).filter(User.username == form_data.username).first()
    if not user or not verify_password(form_data.password, user.hashed_password):
        raise HTTPException(status_code=401, detail="Invalid username or password")
    access_token = create_access_token(data={"sub": user.username})
    return {"access_token": access_token, "token_type": "bearer"}

# Define a Pydantic model for user registration
class RegisterUserRequest(BaseModel):
    username: str
    email: EmailStr
    password: str

@app.post("/register")
def register_user(request: RegisterUserRequest, db: Session = Depends(get_db)):
    logging.info(f"Register endpoint called with data: {request}")
    existing_user = db.query(User).filter((User.username == request.username) | (User.email == request.email)).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="Username or email already exists")
    hashed_password = get_password_hash(request.password)
    new_user = User(username=request.username, email=request.email, hashed_password=hashed_password)
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return {"message": "User registered successfully"}

@app.get("/protected-route")
async def protected_route(token: str = Depends(oauth2_scheme)):
    return {"message": "You are authenticated!"}

@app.get("/")
def read_root():
    return {"message": "Welcome to the KitchenHelper API!"}

@app.get("/health-check")
def health_check():
    return {"status": "ok"}

@app.get("/recipes", response_model=Page[RecipeResponse])
def get_recipes(
    name: Optional[str] = None,
    cuisine: Optional[str] = None,
    dietary_tags: Optional[str] = None,
    max_prep_time: Optional[float] = None,
    max_cook_time: Optional[float] = None,
    db: Session = Depends(get_db)
):
    try:
        logging.info(f"Fetching recipes with filters: name={name}, cuisine={cuisine}, dietary_tags={dietary_tags}, max_prep_time={max_prep_time}, max_cook_time={max_cook_time}")
        query = db.query(Recipe).filter(Recipe.visibility == "public")
        logging.info("Base query created.")
        if name:
            query = query.filter(Recipe.name.ilike(f"%{name}%"))
            logging.info(f"Filtered by name: {name}")
        if cuisine:
            query = query.filter(Recipe.cuisine.ilike(f"%{cuisine}%"))
            logging.info(f"Filtered by cuisine: {cuisine}")
        if dietary_tags:
            query = query.filter(Recipe.dietary_tags.ilike(f"%{dietary_tags}%"))
            logging.info(f"Filtered by dietary tags: {dietary_tags}")
        if max_prep_time:
            query = query.filter(Recipe.prep_time <= max_prep_time)
            logging.info(f"Filtered by max prep time: {max_prep_time}")
        if max_cook_time:
            query = query.filter(Recipe.cook_time <= max_cook_time)
            logging.info(f"Filtered by max cook time: {max_cook_time}")
        
        # Use the SQLAlchemy-specific paginate function
        return paginate(db, query)
    except Exception as e:
        logging.error(f"Error fetching recipes: {e}")
        raise HTTPException(status_code=500, detail="Internal server error")

add_pagination(app)  # Add pagination support

@app.get("/login")
def redirect_to_docs():
    return RedirectResponse(url="/docs")

if __name__ == "__main__":
    uvicorn.run("backend.main:app", host="127.0.0.1", port=8000, reload=True)