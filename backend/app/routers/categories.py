from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.models.category import Category, Subcategory
from app.schemas.category import CategoryResponse, SubcategoryResponse

router = APIRouter(prefix="/categories", tags=["Category Taxonomy"])

@router.get("", response_model=List[CategoryResponse])
def get_categories_taxonomy(db: Session = Depends(get_db)):
    categories = db.query(Category).filter(
        Category.is_active == True
    ).order_by(Category.sort_order.asc()).all()
    return categories

@router.get("/{category_slug}", response_model=CategoryResponse)
def get_category_by_slug(category_slug: str, db: Session = Depends(get_db)):
    category = db.query(Category).filter(
        Category.slug == category_slug,
        Category.is_active == True
    ).first()
    if not category:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Category not found"
        )
    return category

@router.get("/{category_id}/subcategories", response_model=List[SubcategoryResponse])
def get_subcategories_by_category(category_id: int, db: Session = Depends(get_db)):
    subcategories = db.query(Subcategory).filter(
        Subcategory.category_id == category_id,
        Subcategory.is_active == True
    ).order_by(Subcategory.sort_order.asc()).all()
    return subcategories
