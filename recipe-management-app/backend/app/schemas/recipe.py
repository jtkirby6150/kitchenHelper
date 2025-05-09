from pydantic import BaseModel
from typing import List, Optional

class RecipeBase(BaseModel):
    title: str
    description: str
    ingredients: List[str]
    prep_time: Optional[int] = None
    cook_time: Optional[int] = None
    instructions: str
    dietary_tags: List[str] = []

class RecipeCreate(RecipeBase):
    pass

class RecipeUpdate(RecipeBase):
    pass

class Recipe(RecipeBase):
    id: int

    class Config:
        orm_mode = True