from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form, status, Request
from sqlalchemy.orm import Session
from typing import List, Optional
from app.database import get_db
from app.models.user import User
from app.models.garment import Garment
from app.schemas.garment import GarmentResponse
from app.utils.security import get_current_user
from app.services.image_service import ImageService

router = APIRouter(prefix="/garments", tags=["Garments"])

def format_garment_response(garment: Garment, request: Request) -> GarmentResponse:
    base_url = str(request.base_url).rstrip("/")
    return GarmentResponse(
        id=garment.id,
        user_id=garment.user_id,
        name=garment.name,
        category=garment.category,
        image_path=garment.image_path,
        image_url=f"{base_url}/{garment.image_path}",
        created_at=garment.created_at,
        updated_at=garment.updated_at
    )

@router.post("/upload", response_model=GarmentResponse, status_code=status.HTTP_201_CREATED)
async def upload_garment(
    request: Request,
    name: str = Form(...),
    category: Optional[str] = Form("general"),
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # Validate and save image locally
    saved_rel_path = await ImageService.validate_and_save_image(file, subfolder="garments")

    try:
        # Save garment record in MySQL
        garment = Garment(
            user_id=current_user.id,
            name=name.strip(),
            category=category.strip() if category else "general",
            image_path=saved_rel_path
        )
        db.add(garment)
        db.commit()
        db.refresh(garment)
        return format_garment_response(garment, request)
    except Exception as e:
        # If database save fails, clean up the orphaned image file
        ImageService.delete_file(saved_rel_path)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Database error occurred while saving garment metadata: {str(e)}"
        )

@router.get("", response_model=List[GarmentResponse])
def list_garments(
    request: Request,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    garments = db.query(Garment).filter(Garment.user_id == current_user.id).order_by(Garment.created_at.desc()).all()
    return [format_garment_response(g, request) for g in garments]

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
    return format_garment_response(garment, request)

@router.delete("/{garment_id}", status_code=status.HTTP_200_OK)
def delete_garment(
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

    image_path = garment.image_path
    db.delete(garment)
    db.commit()

    # Remove physical file from uploads
    ImageService.delete_file(image_path)
    return {"message": "Garment deleted successfully", "id": garment_id}
