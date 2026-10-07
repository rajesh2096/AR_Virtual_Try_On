from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.user import User, UserProfile
from app.schemas.user import UserCreate, UserLogin, UserResponse, Token, UserProfileResponse
from app.utils.security import get_password_hash, verify_password, create_access_token, get_current_user

router = APIRouter(prefix="/auth", tags=["Authentication"])

def build_user_response(user: User) -> UserResponse:
    profile_resp = None
    if user.profile:
        profile_resp = UserProfileResponse.model_validate(user.profile)
    return UserResponse(
        id=user.id,
        name=user.name,
        email=user.email,
        created_at=user.created_at,
        updated_at=user.updated_at,
        profile=profile_resp
    )

@router.post("/register", response_model=Token, status_code=status.HTTP_201_CREATED)
def register_user(user_in: UserCreate, db: Session = Depends(get_db)):
    # Check if user already exists
    existing_user = db.query(User).filter(User.email == user_in.email).first()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="A user with this email address already exists"
        )
    
    # Hash password & create user
    hashed_password = get_password_hash(user_in.password)
    user = User(
        name=user_in.name.strip(),
        email=user_in.email.strip().lower(),
        password_hash=hashed_password
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    # Automatically create initial empty user profile
    profile = UserProfile(
        user_id=user.id,
        full_name=user.name
    )
    db.add(profile)
    db.commit()
    db.refresh(user)

    # Generate JWT token
    access_token = create_access_token(subject=user.id)
    return Token(
        access_token=access_token,
        token_type="bearer",
        user=build_user_response(user)
    )

@router.post("/login", response_model=Token)
def login_user(login_in: UserLogin, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == login_in.email.strip().lower()).first()
    if not user or not verify_password(login_in.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    access_token = create_access_token(subject=user.id)
    return Token(
        access_token=access_token,
        token_type="bearer",
        user=build_user_response(user)
    )

@router.get("/me", response_model=UserResponse)
def get_current_logged_in_user(current_user: User = Depends(get_current_user)):
    return build_user_response(current_user)
