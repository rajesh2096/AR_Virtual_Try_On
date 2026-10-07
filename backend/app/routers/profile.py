from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.user import User, UserProfile
from app.schemas.user import UserProfileUpdate, UserProfileResponse
from app.utils.security import get_current_user

router = APIRouter(prefix="/profile", tags=["User Profile"])

@router.get("", response_model=UserProfileResponse)
def get_user_profile(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    profile = db.query(UserProfile).filter(UserProfile.user_id == current_user.id).first()
    if not profile:
        # Create default profile if missing
        profile = UserProfile(user_id=current_user.id, full_name=current_user.name)
        db.add(profile)
        db.commit()
        db.refresh(profile)
    return profile

@router.put("", response_model=UserProfileResponse)
def update_user_profile(
    profile_in: UserProfileUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    profile = db.query(UserProfile).filter(UserProfile.user_id == current_user.id).first()
    if not profile:
        profile = UserProfile(user_id=current_user.id, full_name=current_user.name)
        db.add(profile)

    update_data = profile_in.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(profile, field, value)

    # Keep User.name in sync if full_name is updated
    if profile_in.full_name:
        current_user.name = profile_in.full_name
        db.add(current_user)

    db.commit()
    db.refresh(profile)
    return profile
