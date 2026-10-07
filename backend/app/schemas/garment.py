from datetime import datetime
from pydantic import BaseModel, Field
from typing import Optional

class GarmentBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=150)
    category: Optional[str] = Field("general", max_length=50)

class GarmentCreate(GarmentBase):
    pass

class GarmentResponse(GarmentBase):
    id: int
    user_id: int
    image_path: str
    image_url: Optional[str] = None
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
