from fastapi import APIRouter, Depends, HTTPException, status, Request
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.models.user import User
from app.models.garment import Garment
from app.models.outfit import Outfit, OutfitItem
from app.schemas.outfit import OutfitCreate, OutfitUpdate, OutfitResponse, OutfitItemResponse
from app.schemas.garment import GarmentResponse
from app.utils.security import get_current_user

router = APIRouter(prefix="/outfits", tags=["Outfits / Mix & Match"])

def format_outfit_response(outfit: Outfit, request: Request) -> OutfitResponse:
    base_url = str(request.base_url).rstrip("/")
    items_resp = []
    for item in outfit.items:
        g_resp = None
        if item.garment:
            g_resp = GarmentResponse(
                id=item.garment.id,
                user_id=item.garment.user_id,
                name=item.garment.name,
                category=item.garment.category,
                subcategory_id=item.garment.subcategory_id,
                brand=item.garment.brand,
                primary_color=item.garment.primary_color,
                size=item.garment.size,
                style=item.garment.style,
                description=item.garment.description,
                image_path=item.garment.image_path,
                image_url=f"{base_url}/{item.garment.image_path}",
                is_archived=item.garment.is_archived,
                created_at=item.garment.created_at,
                updated_at=item.garment.updated_at
            )
        items_resp.append(OutfitItemResponse(
            id=item.id,
            outfit_id=item.outfit_id,
            garment_id=item.garment_id,
            slot_type=item.slot_type,
            sort_order=item.sort_order,
            created_at=item.created_at,
            garment=g_resp
        ))
    
    return OutfitResponse(
        id=outfit.id,
        user_id=outfit.user_id,
        title=outfit.title,
        description=outfit.description,
        is_favorite=outfit.is_favorite,
        created_at=outfit.created_at,
        updated_at=outfit.updated_at,
        items=items_resp
    )

@router.get("", response_model=List[OutfitResponse])
def list_outfits(
    request: Request,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    outfits = db.query(Outfit).filter(Outfit.user_id == current_user.id).order_by(Outfit.created_at.desc()).all()
    return [format_outfit_response(o, request) for o in outfits]

@router.post("/create", response_model=OutfitResponse, status_code=status.HTTP_201_CREATED)
def create_outfit(
    outfit_in: OutfitCreate,
    request: Request,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # Validate all garment IDs belong to current user
    if outfit_in.items:
        garment_ids = [item.garment_id for item in outfit_in.items]
        user_garments_count = db.query(Garment).filter(
            Garment.id.in_(garment_ids),
            Garment.user_id == current_user.id
        ).count()
        if user_garments_count != len(set(garment_ids)):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="One or more selected garments do not exist or do not belong to you"
            )

    outfit = Outfit(
        user_id=current_user.id,
        title=outfit_in.title.strip(),
        description=outfit_in.description.strip() if outfit_in.description else None,
        is_favorite=outfit_in.is_favorite or False
    )
    db.add(outfit)
    db.commit()
    db.refresh(outfit)

    # Add items
    for idx, item_in in enumerate(outfit_in.items):
        item = OutfitItem(
            outfit_id=outfit.id,
            garment_id=item_in.garment_id,
            slot_type=item_in.slot_type,
            sort_order=item_in.sort_order if item_in.sort_order is not None else idx
        )
        db.add(item)
    db.commit()
    db.refresh(outfit)

    return format_outfit_response(outfit, request)

@router.get("/{outfit_id}", response_model=OutfitResponse)
def get_outfit(
    outfit_id: int,
    request: Request,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    outfit = db.query(Outfit).filter(
        Outfit.id == outfit_id,
        Outfit.user_id == current_user.id
    ).first()

    if not outfit:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Outfit not found"
        )
    return format_outfit_response(outfit, request)

@router.put("/{outfit_id}", response_model=OutfitResponse)
def update_outfit(
    outfit_id: int,
    outfit_in: OutfitUpdate,
    request: Request,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    outfit = db.query(Outfit).filter(
        Outfit.id == outfit_id,
        Outfit.user_id == current_user.id
    ).first()

    if not outfit:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Outfit not found"
        )

    if outfit_in.title is not None:
        outfit.title = outfit_in.title.strip()
    if outfit_in.description is not None:
        outfit.description = outfit_in.description.strip()
    if outfit_in.is_favorite is not None:
        outfit.is_favorite = outfit_in.is_favorite

    if outfit_in.items is not None:
        # Validate items
        garment_ids = [item.garment_id for item in outfit_in.items]
        if garment_ids:
            user_garments_count = db.query(Garment).filter(
                Garment.id.in_(garment_ids),
                Garment.user_id == current_user.id
            ).count()
            if user_garments_count != len(set(garment_ids)):
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="One or more selected garments do not belong to you"
                )

        # Clear existing items and replace
        db.query(OutfitItem).filter(OutfitItem.outfit_id == outfit.id).delete()
        for idx, item_in in enumerate(outfit_in.items):
            item = OutfitItem(
                outfit_id=outfit.id,
                garment_id=item_in.garment_id,
                slot_type=item_in.slot_type,
                sort_order=item_in.sort_order if item_in.sort_order is not None else idx
            )
            db.add(item)

    db.commit()
    db.refresh(outfit)
    return format_outfit_response(outfit, request)

@router.delete("/{outfit_id}", status_code=status.HTTP_200_OK)
def delete_outfit(
    outfit_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    outfit = db.query(Outfit).filter(
        Outfit.id == outfit_id,
        Outfit.user_id == current_user.id
    ).first()

    if not outfit:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Outfit not found"
        )

    db.delete(outfit)
    db.commit()
    return {"message": "Outfit deleted successfully", "id": outfit_id}
