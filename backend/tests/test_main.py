from fastapi.testclient import TestClient
from ..main import app

client = TestClient(app)

def test_read_root():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "Welcome to KitchenHelper API"}

def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}

def test_create_recipe():
    response = client.post("/recipes", json={
        "name": "Test Recipe",
        "ingredients": "Test Ingredients",
        "instructions": "Test Instructions",
        "cuisine": "Test Cuisine",
        "dietary_tags": "Test Tags"
    })
    assert response.status_code == 200
    assert response.json()["name"] == "Test Recipe"

def test_register_user():
    response = client.post("/register", json={
        "username": "testuser",
        "email": "test@example.com",
        "password": "password123"
    })
    assert response.status_code == 200
    assert response.json() == {"message": "User registered successfully"}

def test_login_user():
    response = client.post("/token", data={
        "username": "testuser",
        "password": "password123"
    })
    assert response.status_code == 200
    assert "access_token" in response.json()
