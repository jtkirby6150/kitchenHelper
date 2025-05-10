from typing import Optional, List
from pydantic import BaseModel, Field
from datetime import datetime

class RecipeBase(BaseModel):
    name: str
    description: Optional[str]
    ingredients: str
    instructions: str
    cuisine: Optional[str]
    dietary_tags: Optional[str]
    prep_instructions: Optional[str]
    servings: Optional[int]
    prep_time: Optional[float]
    cook_time: Optional[float]
    total_time: Optional[float]

class RecipeCreate(RecipeBase):
    category_id: Optional[int]

class RecipeResponse(BaseModel):
    id: int
    name: str
    ingredients: str
    instructions: str
    cuisine: Optional[str]
    dietary_tags: Optional[str]
    prep_time: Optional[float]
    cook_time: Optional[float]
    visibility: str

    class Config:
        orm_mode = True

class NotificationResponse(BaseModel):
    id: int
    message: str
    created_at: datetime
    is_read: bool

    class Config:
        from_attributes = True  # Updated for Pydantic v2

class UserPreferenceResponse(BaseModel):
    notify_comments: bool
    notify_ratings: bool
    notify_recipe_approval: bool

    class Config:
        from_attributes = True  # Updated for Pydantic v2

class UserPreferenceUpdate(BaseModel):
    notify_comments: bool
    notify_ratings: bool
    notify_recipe_approval: bool
