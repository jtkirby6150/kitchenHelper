from fastapi import APIRouter

router = APIRouter()

from .endpoints import recipes

router.include_router(recipes.router, prefix="/recipes", tags=["recipes"])