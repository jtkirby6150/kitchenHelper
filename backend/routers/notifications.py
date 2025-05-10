from fastapi import APIRouter

router = APIRouter()

@router.get("/")
def get_notifications():
    return {"message": "Notifications endpoint is working!"}
