from datetime import datetime
from pydantic import BaseModel, Field
from typing import Optional, List
from app.schemas.garment import GarmentResponse

class OutfitItemCreate(BaseModel):
    garment_id: int
    slot_type: str # upper, lower, full_body, footwear, wrist, eyewear, head, neck, accessory
    sort_order: Optional[int] = 0

class OutfitItemResponse(BaseModel):
    id: int
    outfit_id: int
    garment_id: int
    slot_type: str
    sort_order: int
    created_at: datetime
    garment: Optional[GarmentResponse] = None

    class Config:
        from_attributes = True

class OutfitCreate(BaseModel):
    title: str = Field(..., min_length=1, max_length=150)
    description: Optional[str] = None
    is_favorite: Optional[bool] = False
    items: List[OutfitItemCreate] = []

class OutfitUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    is_favorite: Optional[bool] = None
    items: Optional[List[OutfitItemCreate]] = None

class OutfitResponse(BaseModel):
    id: int
    user_id: int
    title: str
    description: Optional[str] = None
    is_favorite: bool
    created_at: datetime
    updated_at: datetime
    items: List[OutfitItemResponse] = []

    class Config:
        from_attributes = True
