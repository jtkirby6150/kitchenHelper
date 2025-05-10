from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from fastapi_pagination import add_pagination
from fastapi_limiter import FastAPILimiter
from contextlib import asynccontextmanager
import redis
import logging
import os
from dotenv import load_dotenv
from .routers import recipes, users, admin, notifications
from .database import Base, engine

# Load environment variables
load_dotenv()

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

# Include routers
app.include_router(recipes.router, prefix="/recipes", tags=["Recipes"])
app.include_router(users.router, prefix="/users", tags=["Users"])
app.include_router(admin.router, prefix="/admin", tags=["Admin"])
app.include_router(notifications.router, prefix="/notifications", tags=["Notifications"])

# Add pagination support
add_pagination(app)

# Root endpoint
@app.get("/")
def read_root():
    return {"message": "Welcome to the KitchenHelper API!"}

# Health check endpoint
@app.get("/health-check")
def health_check():
    return {"status": "ok"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("backend.main:app", host="127.0.0.1", port=8000, reload=True)