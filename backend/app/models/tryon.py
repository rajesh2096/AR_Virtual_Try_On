from datetime import datetime
from sqlalchemy import Column, Integer, String, DateTime, Text, ForeignKey, Index
from sqlalchemy.orm import relationship
from app.database import Base

class TryonSession(Base):
    __tablename__ = "tryon_sessions"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    garment_id = Column(Integer, ForeignKey("garments.id", ondelete="SET NULL"), nullable=True, index=True) # Preserved for backward compatibility
    person_profile_id = Column(Integer, ForeignKey("person_profiles.id", ondelete="SET NULL"), nullable=True, index=True)
    outfit_id = Column(Integer, ForeignKey("outfits.id", ondelete="SET NULL"), nullable=True, index=True)
    
    # Image paths preserved for backward compatibility
    person_image_path = Column(String(500), nullable=True)
    result_image_path = Column(String(500), nullable=True)
    
    session_type = Column(String(50), nullable=False, default="single") # single, outfit
    status = Column(String(50), nullable=False, default="pending") # pending, processing, completed, failed
    error_message = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    # Relationships
    user = relationship("User", back_populates="tryon_sessions")
    garment = relationship("Garment", back_populates="tryon_sessions")
    person_profile = relationship("PersonProfile", back_populates="tryon_sessions")
    outfit = relationship("Outfit", back_populates="tryon_sessions")
    items = relationship("TryonItem", back_populates="session", cascade="all, delete-orphan")
    results = relationship("TryonResult", back_populates="session", cascade="all, delete-orphan")


class TryonItem(Base):
    __tablename__ = "tryon_items"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    session_id = Column(Integer, ForeignKey("tryon_sessions.id", ondelete="CASCADE"), nullable=False, index=True)
    garment_id = Column(Integer, ForeignKey("garments.id", ondelete="SET NULL"), nullable=True, index=True)
    slot_type = Column(String(50), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    session = relationship("TryonSession", back_populates="items")
    garment = relationship("Garment", back_populates="tryon_items")


class TryonResult(Base):
    __tablename__ = "tryon_results"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    session_id = Column(Integer, ForeignKey("tryon_sessions.id", ondelete="CASCADE"), nullable=False, index=True)
    result_image_path = Column(String(500), nullable=False)
    generation_time_ms = Column(Integer, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    session = relationship("TryonSession", back_populates="results")
