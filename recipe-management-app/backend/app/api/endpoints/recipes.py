from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.schemas.recipe import RecipeCreate, RecipeUpdate, Recipe
from app.services.recipe_service import RecipeService

router = APIRouter()
recipe_service = RecipeService()

@router.post("/", response_model=Recipe)
def create_recipe(recipe: RecipeCreate, db: Session = Depends(get_db)):
    return recipe_service.create_recipe(db=db, recipe=recipe)

@router.get("/{recipe_id}", response_model=Recipe)
def read_recipe(recipe_id: int, db: Session = Depends(get_db)):
    recipe = recipe_service.get_recipe(db=db, recipe_id=recipe_id)
    if recipe is None:
        raise HTTPException(status_code=404, detail="Recipe not found")
    return recipe

@router.put("/{recipe_id}", response_model=Recipe)
def update_recipe(recipe_id: int, recipe: RecipeUpdate, db: Session = Depends(get_db)):
    updated_recipe = recipe_service.update_recipe(db=db, recipe_id=recipe_id, recipe=recipe)
    if updated_recipe is None:
        raise HTTPException(status_code=404, detail="Recipe not found")
    return updated_recipe

@router.delete("/{recipe_id}", response_model=dict)
def delete_recipe(recipe_id: int, db: Session = Depends(get_db)):
    success = recipe_service.delete_recipe(db=db, recipe_id=recipe_id)
    if not success:
        raise HTTPException(status_code=404, detail="Recipe not found")
    return {"detail": "Recipe deleted successfully"}

@router.get("/", response_model=list[Recipe])
def list_recipes(skip: int = 0, limit: int = 10, db: Session = Depends(get_db)):
    return recipe_service.get_recipes(db=db, skip=skip, limit=limit)