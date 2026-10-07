from datetime import datetime
from pydantic import BaseModel, Field
from typing import Optional, List

class SubcategoryBase(BaseModel):
    name: str
    slug: str
    layer_type: str
    sort_order: int = 0
    is_active: bool = True

class SubcategoryResponse(SubcategoryBase):
    id: int
    category_id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class CategoryBase(BaseModel):
    name: str
    slug: str
    super_type: str
    icon_name: Optional[str] = None
    sort_order: int = 0
    is_active: bool = True

class CategoryResponse(CategoryBase):
    id: int
    created_at: datetime
    updated_at: datetime
    subcategories: List[SubcategoryResponse] = []

    class Config:
        from_attributes = True
