from datetime import datetime
from pydantic import BaseModel, Field
from typing import Optional, List
from app.schemas.garment import GarmentResponse
from app.schemas.user import PersonProfileResponse
from app.schemas.outfit import OutfitResponse

class TryonSessionCreate(BaseModel):
    garment_id: Optional[int] = None
    outfit_id: Optional[int] = None
    person_profile_id: Optional[int] = None
    session_type: Optional[str] = "single" # single, outfit

class TryonItemResponse(BaseModel):
    id: int
    session_id: int
    garment_id: Optional[int] = None
    slot_type: Optional[str] = None
    created_at: datetime
    garment: Optional[GarmentResponse] = None

    class Config:
        from_attributes = True

class TryonResultResponse(BaseModel):
    id: int
    session_id: int
    result_image_path: str
    result_image_url: Optional[str] = None
    generation_time_ms: Optional[int] = None
    created_at: datetime

    class Config:
        from_attributes = True

class TryonSessionResponse(BaseModel):
    id: int
    user_id: int
    garment_id: Optional[int] = None
    person_profile_id: Optional[int] = None
    outfit_id: Optional[int] = None
    person_image_path: Optional[str] = None
    person_image_url: Optional[str] = None
    result_image_path: Optional[str] = None
    result_image_url: Optional[str] = None
    session_type: str
    status: str
    error_message: Optional[str] = None
    message: Optional[str] = None
    created_at: datetime
    updated_at: datetime
    
    # Associated rich models
    garment: Optional[GarmentResponse] = None
    person_profile: Optional[PersonProfileResponse] = None
    outfit: Optional[OutfitResponse] = None
    items: List[TryonItemResponse] = []
    results: List[TryonResultResponse] = []

    class Config:
        from_attributes = True
