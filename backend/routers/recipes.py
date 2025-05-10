from fastapi import APIRouter

router = APIRouter()

@router.get("/")
def get_recipes():
    return {"message": "Recipes endpoint is working!"}
