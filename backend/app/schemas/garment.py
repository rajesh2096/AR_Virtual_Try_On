from datetime import datetime
from pydantic import BaseModel, Field
from typing import Optional
from app.schemas.category import SubcategoryResponse

class GarmentBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=150)
    category: Optional[str] = Field("general", max_length=50) # Legacy
    subcategory_id: Optional[int] = None
    brand: Optional[str] = None
    primary_color: Optional[str] = None
    size: Optional[str] = None
    style: Optional[str] = None
    description: Optional[str] = None

class GarmentCreate(GarmentBase):
    pass

class GarmentUpdate(BaseModel):
    name: Optional[str] = None
    subcategory_id: Optional[int] = None
    category: Optional[str] = None
    brand: Optional[str] = None
    primary_color: Optional[str] = None
    size: Optional[str] = None
    style: Optional[str] = None
    description: Optional[str] = None
    is_archived: Optional[bool] = None

class GarmentResponse(GarmentBase):
    id: int
    user_id: int
    image_path: str
    image_url: Optional[str] = None
    is_favorite: Optional[bool] = False
    is_archived: bool = False
    created_at: datetime
    updated_at: datetime
    subcategory: Optional[SubcategoryResponse] = None

    class Config:
        from_attributes = True

class FavoriteResponse(BaseModel):
    id: int
    user_id: int
    garment_id: int
    created_at: datetime
    garment: Optional[GarmentResponse] = None

    class Config:
        from_attributes = True
