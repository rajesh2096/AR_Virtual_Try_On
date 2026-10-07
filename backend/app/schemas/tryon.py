from datetime import datetime
from pydantic import BaseModel, Field
from typing import Optional
from app.schemas.garment import GarmentResponse

class TryonSessionCreate(BaseModel):
    garment_id: int

class TryonSessionResponse(BaseModel):
    id: int
    user_id: int
    garment_id: int
    person_image_path: str
    person_image_url: Optional[str] = None
    result_image_path: Optional[str] = None
    result_image_url: Optional[str] = None
    status: str
    created_at: datetime
    updated_at: datetime
    garment: Optional[GarmentResponse] = None
    message: Optional[str] = None

    class Config:
        from_attributes = True
