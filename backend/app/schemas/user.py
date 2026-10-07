from datetime import datetime
from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List

class UserBase(BaseModel):
    name: str = Field(..., min_length=2, max_length=100)
    email: EmailStr

class UserCreate(UserBase):
    password: str = Field(..., min_length=6, max_length=100)

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class UserProfileBase(BaseModel):
    full_name: Optional[str] = None
    phone: Optional[str] = None
    date_of_birth: Optional[str] = None
    gender: Optional[str] = None
    height_cm: Optional[float] = None
    weight_kg: Optional[float] = None
    preferred_size: Optional[str] = None
    shoe_size: Optional[str] = None
    favorite_colors: Optional[List[str]] = None
    favorite_styles: Optional[List[str]] = None

class UserProfileUpdate(UserProfileBase):
    pass

class UserProfileResponse(UserProfileBase):
    id: int
    user_id: int
    full_name: str
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class UserResponse(UserBase):
    id: int
    created_at: datetime
    updated_at: datetime
    profile: Optional[UserProfileResponse] = None

    class Config:
        from_attributes = True

class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserResponse

class PersonProfileCreate(BaseModel):
    title: Optional[str] = "My Model Photo"
    is_default: Optional[bool] = False

class PersonProfileUpdate(BaseModel):
    title: Optional[str] = None
    is_default: Optional[bool] = None

class PersonProfileResponse(BaseModel):
    id: int
    user_id: int
    title: str
    image_path: str
    image_url: Optional[str] = None
    is_default: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
