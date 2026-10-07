from fastapi import APIRouter, Depends, HTTPException, status, Request
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.models.user import User
from app.models.garment import Garment, Favorite
from app.schemas.garment import FavoriteResponse, GarmentResponse
from app.schemas.category import SubcategoryResponse
from app.utils.security import get_current_user

router = APIRouter(prefix="/favorites", tags=["Favorites"])

def format_favorite_response(fav: Favorite, request: Request) -> FavoriteResponse:
    base_url = str(request.base_url).rstrip("/")
    garment_resp = None
    if fav.garment:
        sub_resp = None
        if fav.garment.subcategory:
            sub_resp = SubcategoryResponse.model_validate(fav.garment.subcategory)
        garment_resp = GarmentResponse(
            id=fav.garment.id,
            user_id=fav.garment.user_id,
            name=fav.garment.name,
            category=fav.garment.category,
            subcategory_id=fav.garment.subcategory_id,
            brand=fav.garment.brand,
            primary_color=fav.garment.primary_color,
            size=fav.garment.size,
            style=fav.garment.style,
            description=fav.garment.description,
            image_path=fav.garment.image_path,
            image_url=f"{base_url}/{fav.garment.image_path}",
            is_favorite=True,
            is_archived=fav.garment.is_archived,
            created_at=fav.garment.created_at,
            updated_at=fav.garment.updated_at,
            subcategory=sub_resp
        )
    return FavoriteResponse(
        id=fav.id,
        user_id=fav.user_id,
        garment_id=fav.garment_id,
        created_at=fav.created_at,
        garment=garment_resp
    )

@router.get("", response_model=List[FavoriteResponse])
def list_favorites(
    request: Request,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    favs = db.query(Favorite).filter(Favorite.user_id == current_user.id).order_by(Favorite.created_at.desc()).all()
    return [format_favorite_response(f, request) for f in favs]

@router.post("/{garment_id}", response_model=FavoriteResponse, status_code=status.HTTP_201_CREATED)
def add_favorite(
    garment_id: int,
    request: Request,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # Verify garment ownership
    garment = db.query(Garment).filter(
        Garment.id == garment_id,
        Garment.user_id == current_user.id
    ).first()

    if not garment:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Garment not found or does not belong to user"
        )

    existing = db.query(Favorite).filter(
        Favorite.user_id == current_user.id,
        Favorite.garment_id == garment_id
    ).first()

    if existing:
        return format_favorite_response(existing, request)

    fav = Favorite(user_id=current_user.id, garment_id=garment_id)
    db.add(fav)
    db.commit()
    db.refresh(fav)
    return format_favorite_response(fav, request)

@router.delete("/{garment_id}", status_code=status.HTTP_200_OK)
def remove_favorite(
    garment_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    fav = db.query(Favorite).filter(
        Favorite.user_id == current_user.id,
        Favorite.garment_id == garment_id
    ).first()

    if not fav:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Favorite entry not found"
        )

    db.delete(fav)
    db.commit()
    return {"message": "Removed from favorites", "garment_id": garment_id}
