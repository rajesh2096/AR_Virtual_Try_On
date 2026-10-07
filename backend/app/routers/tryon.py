from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form, status, Request
from sqlalchemy.orm import Session
from typing import List, Optional
from app.database import get_db
from app.models.user import User, PersonProfile
from app.models.garment import Garment
from app.models.outfit import Outfit
from app.models.tryon import TryonSession, TryonItem, TryonResult
from app.schemas.tryon import TryonSessionResponse, TryonItemResponse, TryonResultResponse
from app.schemas.garment import GarmentResponse
from app.schemas.user import PersonProfileResponse
from app.schemas.outfit import OutfitResponse, OutfitItemResponse
from app.utils.security import get_current_user
from app.services.image_service import ImageService
from app.services.ai_service import AIService

router = APIRouter(prefix="/tryon", tags=["Try-On Sessions"])

def format_session_response(session: TryonSession, request: Request, custom_msg: Optional[str] = None) -> TryonSessionResponse:
    base_url = str(request.base_url).rstrip("/")
    
    # 1. Garment response
    garment_resp = None
    if session.garment:
        garment_resp = GarmentResponse(
            id=session.garment.id,
            user_id=session.garment.user_id,
            name=session.garment.name,
            category=session.garment.category,
            subcategory_id=session.garment.subcategory_id,
            brand=session.garment.brand,
            primary_color=session.garment.primary_color,
            size=session.garment.size,
            style=session.garment.style,
            description=session.garment.description,
            image_path=session.garment.image_path,
            image_url=f"{base_url}/{session.garment.image_path}",
            is_archived=session.garment.is_archived,
            created_at=session.garment.created_at,
            updated_at=session.garment.updated_at
        )

    # 2. Person Profile response
    person_profile_resp = None
    if session.person_profile:
        person_profile_resp = PersonProfileResponse(
            id=session.person_profile.id,
            user_id=session.person_profile.user_id,
            title=session.person_profile.title,
            image_path=session.person_profile.image_path,
            image_url=f"{base_url}/{session.person_profile.image_path}",
            is_default=session.person_profile.is_default,
            created_at=session.person_profile.created_at,
            updated_at=session.person_profile.updated_at
        )

    # 3. Outfit response
    outfit_resp = None
    if session.outfit:
        outfit_resp = OutfitResponse(
            id=session.outfit.id,
            user_id=session.outfit.user_id,
            title=session.outfit.title,
            description=session.outfit.description,
            is_favorite=session.outfit.is_favorite,
            created_at=session.outfit.created_at,
            updated_at=session.outfit.updated_at,
            items=[]
        )

    # 4. Tryon Items
    items_resp = []
    for it in session.items:
        g_item_resp = None
        if it.garment:
            g_item_resp = GarmentResponse(
                id=it.garment.id,
                user_id=it.garment.user_id,
                name=it.garment.name,
                category=it.garment.category,
                subcategory_id=it.garment.subcategory_id,
                brand=it.garment.brand,
                primary_color=it.garment.primary_color,
                size=it.garment.size,
                style=it.garment.style,
                description=it.garment.description,
                image_path=it.garment.image_path,
                image_url=f"{base_url}/{it.garment.image_path}",
                is_archived=it.garment.is_archived,
                created_at=it.garment.created_at,
                updated_at=it.garment.updated_at
            )
        items_resp.append(TryonItemResponse(
            id=it.id,
            session_id=it.session_id,
            garment_id=it.garment_id,
            slot_type=it.slot_type,
            created_at=it.created_at,
            garment=g_item_resp
        ))

    # 5. Results
    results_resp = [
        TryonResultResponse(
            id=r.id,
            session_id=r.session_id,
            result_image_path=r.result_image_path,
            result_image_url=f"{base_url}/{r.result_image_path}",
            generation_time_ms=r.generation_time_ms,
            created_at=r.created_at
        )
        for r in session.results
    ]

    p_img_url = f"{base_url}/{session.person_image_path}" if session.person_image_path else (person_profile_resp.image_url if person_profile_resp else None)
    r_img_url = f"{base_url}/{session.result_image_path}" if session.result_image_path else (results_resp[0].result_image_url if results_resp else None)

    return TryonSessionResponse(
        id=session.id,
        user_id=session.user_id,
        garment_id=session.garment_id,
        person_profile_id=session.person_profile_id,
        outfit_id=session.outfit_id,
        person_image_path=session.person_image_path,
        person_image_url=p_img_url,
        result_image_path=session.result_image_path,
        result_image_url=r_img_url,
        session_type=session.session_type,
        status=session.status,
        error_message=session.error_message,
        created_at=session.created_at,
        updated_at=session.updated_at,
        garment=garment_resp,
        person_profile=person_profile_resp,
        outfit=outfit_resp,
        items=items_resp,
        results=results_resp,
        message=custom_msg or "AI Virtual Try-On pipeline ready for model integration."
    )

@router.post("/create", response_model=TryonSessionResponse, status_code=status.HTTP_201_CREATED)
async def create_tryon_session(
    request: Request,
    garment_id: Optional[int] = Form(None),
    outfit_id: Optional[int] = Form(None),
    person_profile_id: Optional[int] = Form(None),
    person_image: Optional[UploadFile] = File(None),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    if not garment_id and not outfit_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Either garment_id or outfit_id must be provided"
        )

    if not person_image and not person_profile_id:
        # Check if user has a default person profile
        default_profile = db.query(PersonProfile).filter(
            PersonProfile.user_id == current_user.id,
            PersonProfile.is_default == True
        ).first()
        if default_profile:
            person_profile_id = default_profile.id
        else:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Please provide a person_image or choose a saved person_profile_id"
            )

    # Validate garment ownership if single mode
    garment = None
    if garment_id:
        garment = db.query(Garment).filter(
            Garment.id == garment_id,
            Garment.user_id == current_user.id
        ).first()
        if not garment:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Specified garment not found or does not belong to you"
            )

    # Validate outfit ownership if outfit mode
    outfit = None
    if outfit_id:
        outfit = db.query(Outfit).filter(
            Outfit.id == outfit_id,
            Outfit.user_id == current_user.id
        ).first()
        if not outfit:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Specified outfit not found or does not belong to you"
            )

    # Validate person profile if selected
    person_profile = None
    if person_profile_id:
        person_profile = db.query(PersonProfile).filter(
            PersonProfile.id == person_profile_id,
            PersonProfile.user_id == current_user.id
        ).first()
        if not person_profile:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Specified person profile model not found"
            )

    # Handle person image upload if uploaded directly
    person_image_rel_path = None
    if person_image:
        person_image_rel_path = await ImageService.validate_and_save_image(person_image, subfolder="users")
    elif person_profile:
        person_image_rel_path = person_profile.image_path

    try:
        session = TryonSession(
            user_id=current_user.id,
            garment_id=garment_id,
            outfit_id=outfit_id,
            person_profile_id=person_profile_id,
            person_image_path=person_image_rel_path,
            session_type="outfit" if outfit_id else "single",
            status="pending"
        )
        db.add(session)
        db.commit()
        db.refresh(session)

        # Attach single garment as item
        if garment_id:
            item = TryonItem(
                session_id=session.id,
                garment_id=garment_id,
                slot_type="single"
            )
            db.add(item)
            db.commit()

        # Attach outfit garments as items
        if outfit and outfit.items:
            for oi in outfit.items:
                item = TryonItem(
                    session_id=session.id,
                    garment_id=oi.garment_id,
                    slot_type=oi.slot_type
                )
                db.add(item)
            db.commit()

        db.refresh(session)

        return format_session_response(
            session,
            request,
            custom_msg="Try-On session created successfully."
        )
    except Exception as e:
        if person_image and person_image_rel_path:
            ImageService.delete_file(person_image_rel_path)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to initialize try-on session: {str(e)}"
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
