from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form, status, Request
from sqlalchemy.orm import Session
from typing import List, Optional
from app.database import get_db
from app.models.user import User
from app.models.garment import Garment
from app.models.tryon import TryonSession
from app.schemas.tryon import TryonSessionResponse
from app.schemas.garment import GarmentResponse
from app.utils.security import get_current_user
from app.services.image_service import ImageService
from app.services.ai_service import AIService

router = APIRouter(prefix="/tryon", tags=["Try-On Sessions"])

def format_session_response(session: TryonSession, request: Request, custom_msg: Optional[str] = None) -> TryonSessionResponse:
    base_url = str(request.base_url).rstrip("/")
    garment_resp = None
    if session.garment:
        garment_resp = GarmentResponse(
            id=session.garment.id,
            user_id=session.garment.user_id,
            name=session.garment.name,
            category=session.garment.category,
            image_path=session.garment.image_path,
            image_url=f"{base_url}/{session.garment.image_path}",
            created_at=session.garment.created_at,
            updated_at=session.garment.updated_at
        )

    return TryonSessionResponse(
        id=session.id,
        user_id=session.user_id,
        garment_id=session.garment_id,
        person_image_path=session.person_image_path,
        person_image_url=f"{base_url}/{session.person_image_path}",
        result_image_path=session.result_image_path,
        result_image_url=f"{base_url}/{session.result_image_path}" if session.result_image_path else None,
        status=session.status,
        created_at=session.created_at,
        updated_at=session.updated_at,
        garment=garment_resp,
        message=custom_msg or "AI Model processing queue is ready for Phase 2 integration."
    )

@router.post("/create", response_model=TryonSessionResponse, status_code=status.HTTP_201_CREATED)
async def create_tryon_session(
    request: Request,
    garment_id: int = Form(...),
    person_image: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # Verify garment exists and belongs to user
    garment = db.query(Garment).filter(
        Garment.id == garment_id,
        Garment.user_id == current_user.id
    ).first()

    if not garment:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Specified garment was not found or does not belong to you"
        )

    # Save person image
    person_image_rel_path = await ImageService.validate_and_save_image(person_image, subfolder="users")

    try:
        session = TryonSession(
            user_id=current_user.id,
            garment_id=garment.id,
            person_image_path=person_image_rel_path,
            status="pending"
        )
        db.add(session)
        db.commit()
        db.refresh(session)

        # AI Service stub hook (does nothing in Phase 1 per requirements)
        await AIService.process_tryon(
            session_id=session.id,
            person_image_path=person_image_rel_path,
            garment_image_path=garment.image_path
        )

        return format_session_response(
            session,
            request,
            custom_msg="Session created successfully. AI Virtual Try-On inference pipeline scheduled (Phase 2)."
        )
    except Exception as e:
        ImageService.delete_file(person_image_rel_path)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create try-on session: {str(e)}"
        )

@router.get("/history", response_model=List[TryonSessionResponse])
def get_tryon_history(
    request: Request,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    sessions = db.query(TryonSession).filter(
        TryonSession.user_id == current_user.id
    ).order_by(TryonSession.created_at.desc()).all()

    return [format_session_response(s, request) for s in sessions]

@router.get("/{session_id}", response_model=TryonSessionResponse)
def get_tryon_session(
    session_id: int,
    request: Request,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    session = db.query(TryonSession).filter(
        TryonSession.id == session_id,
        TryonSession.user_id == current_user.id
    ).first()

    if not session:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Try-on session not found"
        )
    return format_session_response(session, request)
