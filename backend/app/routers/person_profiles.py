from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form, status, Request
from sqlalchemy.orm import Session
from typing import List, Optional
from app.database import get_db
from app.models.user import User, PersonProfile
from app.schemas.user import PersonProfileResponse, PersonProfileUpdate
from app.utils.security import get_current_user
from app.services.image_service import ImageService

router = APIRouter(prefix="/person-models", tags=["Person Profile Model Vault"])

def format_person_profile_response(profile: PersonProfile, request: Request) -> PersonProfileResponse:
    base_url = str(request.base_url).rstrip("/")
    return PersonProfileResponse(
        id=profile.id,
        user_id=profile.user_id,
        title=profile.title,
        image_path=profile.image_path,
        image_url=f"{base_url}/{profile.image_path}",
        is_default=profile.is_default,
        created_at=profile.created_at,
        updated_at=profile.updated_at
    )

@router.get("", response_model=List[PersonProfileResponse])
def list_person_profiles(
    request: Request,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    profiles = db.query(PersonProfile).filter(
        PersonProfile.user_id == current_user.id
    ).order_by(PersonProfile.is_default.desc(), PersonProfile.created_at.desc()).all()
    return [format_person_profile_response(p, request) for p in profiles]

@router.post("/upload", response_model=PersonProfileResponse, status_code=status.HTTP_201_CREATED)
async def upload_person_profile(
    request: Request,
    title: Optional[str] = Form("My Standing Photo"),
    is_default: Optional[bool] = Form(False),
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    saved_rel_path = await ImageService.validate_and_save_image(file, subfolder="person_profiles")

    try:
        # Check if user has any existing person profiles; if none, make this default automatically
        existing_count = db.query(PersonProfile).filter(PersonProfile.user_id == current_user.id).count()
        make_default = is_default or (existing_count == 0)

        if make_default:
            # Unset existing defaults
            db.query(PersonProfile).filter(PersonProfile.user_id == current_user.id).update({"is_default": False})

        profile = PersonProfile(
            user_id=current_user.id,
            title=(title or "My Standing Photo").strip(),
            image_path=saved_rel_path,
            is_default=make_default
        )
        db.add(profile)
        db.commit()
        db.refresh(profile)
        return format_person_profile_response(profile, request)
    except Exception as e:
        ImageService.delete_file(saved_rel_path)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Database error while saving person profile: {str(e)}"
        )

@router.get("/{profile_id}", response_model=PersonProfileResponse)
def get_person_profile(
    profile_id: int,
    request: Request,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    profile = db.query(PersonProfile).filter(
        PersonProfile.id == profile_id,
        PersonProfile.user_id == current_user.id
    ).first()

    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Person profile model not found"
        )
    return format_person_profile_response(profile, request)

@router.put("/{profile_id}", response_model=PersonProfileResponse)
def update_person_profile(
    profile_id: int,
    update_in: PersonProfileUpdate,
    request: Request,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    profile = db.query(PersonProfile).filter(
        PersonProfile.id == profile_id,
        PersonProfile.user_id == current_user.id
    ).first()

    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Person profile model not found"
        )

    if update_in.is_default is True:
        db.query(PersonProfile).filter(PersonProfile.user_id == current_user.id).update({"is_default": False})
        profile.is_default = True

    if update_in.title is not None:
        profile.title = update_in.title.strip()

    db.commit()
    db.refresh(profile)
    return format_person_profile_response(profile, request)

@router.put("/{profile_id}/default", response_model=PersonProfileResponse)
def set_default_person_profile(
    profile_id: int,
    request: Request,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    profile = db.query(PersonProfile).filter(
        PersonProfile.id == profile_id,
        PersonProfile.user_id == current_user.id
    ).first()

    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Person profile model not found"
        )

    db.query(PersonProfile).filter(PersonProfile.user_id == current_user.id).update({"is_default": False})
    profile.is_default = True
    db.commit()
    db.refresh(profile)
    return format_person_profile_response(profile, request)

@router.delete("/{profile_id}", status_code=status.HTTP_200_OK)
def delete_person_profile(
    profile_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    profile = db.query(PersonProfile).filter(
        PersonProfile.id == profile_id,
        PersonProfile.user_id == current_user.id
    ).first()

    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Person profile model not found"
        )

    was_default = profile.is_default
    image_path = profile.image_path

    db.delete(profile)
    db.commit()

    # If deleted profile was default, assign the next available profile as default
    if was_default:
        next_profile = db.query(PersonProfile).filter(PersonProfile.user_id == current_user.id).order_by(PersonProfile.created_at.desc()).first()
        if next_profile:
            next_profile.is_default = True
            db.commit()

    # Note: Keep file or delete if not referenced in historical results
    ImageService.delete_file(image_path)
    return {"message": "Person profile deleted successfully", "id": profile_id}
