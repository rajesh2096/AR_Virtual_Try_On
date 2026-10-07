from datetime import datetime
from sqlalchemy import Column, Integer, String, DateTime, Text, Boolean, Float, ForeignKey, JSON
from sqlalchemy.orm import relationship
from app.database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    name = Column(String(100), nullable=False)
    email = Column(String(150), unique=True, index=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    # 1-to-1 User Profile
    profile = relationship("UserProfile", back_populates="user", uselist=False, cascade="all, delete-orphan")
    
    # 1-to-many Relationships
    person_profiles = relationship("PersonProfile", back_populates="user", cascade="all, delete-orphan")
    garments = relationship("Garment", back_populates="user", cascade="all, delete-orphan")
    favorites = relationship("Favorite", back_populates="user", cascade="all, delete-orphan")
    outfits = relationship("Outfit", back_populates="user", cascade="all, delete-orphan")
    tryon_sessions = relationship("TryonSession", back_populates="user", cascade="all, delete-orphan")


class UserProfile(Base):
    __tablename__ = "user_profiles"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), unique=True, nullable=False, index=True)
    full_name = Column(String(150), nullable=False)
    phone = Column(String(30), nullable=True)
    date_of_birth = Column(String(20), nullable=True)
    gender = Column(String(30), nullable=True) # male, female, unisex, other
    height_cm = Column(Float, nullable=True)
    weight_kg = Column(Float, nullable=True)
    preferred_size = Column(String(20), nullable=True) # XS, S, M, L, XL, XXL, etc.
    shoe_size = Column(String(20), nullable=True)
    favorite_colors = Column(JSON, nullable=True) # List of color strings
    favorite_styles = Column(JSON, nullable=True) # List of style strings
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    user = relationship("User", back_populates="profile")


class PersonProfile(Base):
    __tablename__ = "person_profiles"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    title = Column(String(150), nullable=False, default="My Model Photo")
    image_path = Column(String(500), nullable=False)
    is_default = Column(Boolean, default=False, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    user = relationship("User", back_populates="person_profiles")
    tryon_sessions = relationship("TryonSession", back_populates="person_profile")
