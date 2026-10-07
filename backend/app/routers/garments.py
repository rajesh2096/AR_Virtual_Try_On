from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form, status, Request, Query
from sqlalchemy.orm import Session
from sqlalchemy import or_
from typing import List, Optional
from app.database import get_db
from app.models.user import User
from app.models.garment import Garment, Favorite
from app.models.category import Subcategory
from app.schemas.garment import GarmentResponse, GarmentUpdate, FavoriteResponse
from app.schemas.category import SubcategoryResponse
from app.utils.security import get_current_user
from app.services.image_service import ImageService

router = APIRouter(prefix="/garments", tags=["Garments / Wardrobe"])

def format_garment_response(garment: Garment, request: Request, is_favorite: bool = False) -> GarmentResponse:
    base_url = str(request.base_url).rstrip("/")
    sub_resp = None
    if garment.subcategory:
        sub_resp = SubcategoryResponse.model_validate(garment.subcategory)
    return GarmentResponse(
        id=garment.id,
        user_id=garment.user_id,
        name=garment.name,
        category=garment.category,
        subcategory_id=garment.subcategory_id,
        brand=garment.brand,
        primary_color=garment.primary_color,
        size=garment.size,
        style=garment.style,
        description=garment.description,
        image_path=garment.image_path,
        image_url=f"{base_url}/{garment.image_path}",
        is_favorite=is_favorite,
        is_archived=garment.is_archived,
        created_at=garment.created_at,
        updated_at=garment.updated_at,
        subcategory=sub_resp
    )

@router.post("/upload", response_model=GarmentResponse, status_code=status.HTTP_201_CREATED)
async def upload_garment(
    request: Request,
    name: str = Form(...),
    category: Optional[str] = Form("general"),
    subcategory_id: Optional[int] = Form(None),
    brand: Optional[str] = Form(None),
    primary_color: Optional[str] = Form(None),
    size: Optional[str] = Form(None),
    style: Optional[str] = Form(None),
    description: Optional[str] = Form(None),
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # Validate subcategory if provided
    if subcategory_id:
        sub = db.query(Subcategory).filter(Subcategory.id == subcategory_id).first()
        if not sub:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Subcategory ID {subcategory_id} does not exist"
            )
        if not category or category == "general":
            category = sub.name

    saved_rel_path = await ImageService.validate_and_save_image(file, subfolder="garments")

    try:
        garment = Garment(
            user_id=current_user.id,
            name=name.strip(),
            category=category.strip() if category else "general",
            subcategory_id=subcategory_id,
            brand=brand.strip() if brand else None,
            primary_color=primary_color.strip() if primary_color else None,
            size=size.strip() if size else None,
            style=style.strip() if style else None,
            description=description.strip() if description else None,
            image_path=saved_rel_path,
            is_archived=False
        )
        db.add(garment)
        db.commit()
        db.refresh(garment)
        return format_garment_response(garment, request, is_favorite=False)
    except Exception as e:
        ImageService.delete_file(saved_rel_path)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Database error occurred while saving garment metadata: {str(e)}"
        )

@router.get("", response_model=List[GarmentResponse])
def list_garments(
    request: Request,
    subcategory_id: Optional[int] = Query(None),
    category_slug: Optional[str] = Query(None),
    search: Optional[str] = Query(None),
    primary_color: Optional[str] = Query(None),
    include_archived: bool = Query(False),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    query = db.query(Garment).filter(Garment.user_id == current_user.id)

    if not include_archived:
        query = query.filter(Garment.is_archived == False)

    if subcategory_id:
        query = query.filter(Garment.subcategory_id == subcategory_id)

    if search:
        s = f"%{search.strip()}%"
        query = query.filter(or_(Garment.name.ilike(s), Garment.brand.ilike(s), Garment.category.ilike(s)))

    if primary_color:
        query = query.filter(Garment.primary_color.ilike(f"%{primary_color.strip()}%"))

    garments = query.order_by(Garment.created_at.desc()).all()

    # Get set of favorite garment IDs for the user
    fav_ids = set(
        r[0] for r in db.query(Favorite.garment_id).filter(Favorite.user_id == current_user.id).all()
    )

    return [format_garment_response(g, request, is_favorite=(g.id in fav_ids)) for g in garments]

@router.get("/{garment_id}", response_model=GarmentResponse)
def get_garment(
    garment_id: int,
    request: Request,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    garment = db.query(Garment).filter(
        Garment.id == garment_id,
        Garment.user_id == current_user.id
    ).first()

    if not garment:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Garment not found"
        )
    
    is_fav = db.query(Favorite).filter(
        Favorite.user_id == current_user.id,
        Favorite.garment_id == garment.id
    ).first() is not None

    return format_garment_response(garment, request, is_favorite=is_fav)

@router.put("/{garment_id}", response_model=GarmentResponse)
def update_garment(
    garment_id: int,
    garment_in: GarmentUpdate,
    request: Request,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    garment = db.query(Garment).filter(
        Garment.id == garment_id,
        Garment.user_id == current_user.id
    ).first()

    if not garment:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Garment not found"
        )

    update_data = garment_in.model_dump(exclude_unset=True)
    for field, val in update_data.items():
        setattr(garment, field, val)

    db.commit()
    db.refresh(garment)

    is_fav = db.query(Favorite).filter(
        Favorite.user_id == current_user.id,
        Favorite.garment_id == garment.id
    ).first() is not None

    return format_garment_response(garment, request, is_favorite=is_fav)

@router.delete("/{garment_id}", status_code=status.HTTP_200_OK)
def delete_or_archive_garment(
    garment_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    garment = db.query(Garment).filter(
        Garment.id == garment_id,
        Garment.user_id == current_user.id
    ).first()

    if not garment:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Garment not found"
        )

    # Soft-archive garment so historical tryon records remain intact
    garment.is_archived = True
    db.commit()

    return {"message": "Garment removed from active wardrobe", "id": garment_id}
