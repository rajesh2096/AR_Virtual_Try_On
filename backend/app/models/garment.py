from datetime import datetime
from sqlalchemy import Column, Integer, String, DateTime, Text, Boolean, ForeignKey, Index
from sqlalchemy.orm import relationship
from app.database import Base

class Garment(Base):
    __tablename__ = "garments"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    subcategory_id = Column(Integer, ForeignKey("subcategories.id", ondelete="SET NULL"), nullable=True, index=True)
    name = Column(String(150), nullable=False)
    image_path = Column(String(500), nullable=False)
    category = Column(String(50), nullable=True, default="general") # Legacy field preserved for backward compatibility
    brand = Column(String(100), nullable=True)
    primary_color = Column(String(50), nullable=True)
    size = Column(String(20), nullable=True)
    style = Column(String(50), nullable=True)
    description = Column(Text, nullable=True)
    is_archived = Column(Boolean, default=False, nullable=False, index=True)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    # Relationships
    user = relationship("User", back_populates="garments")
    subcategory = relationship("Subcategory", back_populates="garments")
    favorites = relationship("Favorite", back_populates="garment", cascade="all, delete-orphan")
    outfit_items = relationship("OutfitItem", back_populates="garment")
    tryon_items = relationship("TryonItem", back_populates="garment")
    tryon_sessions = relationship("TryonSession", back_populates="garment")

    # Useful compound index for fast filtered searches
    __table_args__ = (
        Index("idx_user_archived_created", "user_id", "is_archived", "created_at"),
    )


class Favorite(Base):
    __tablename__ = "favorites"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    garment_id = Column(Integer, ForeignKey("garments.id", ondelete="CASCADE"), nullable=False, index=True)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    user = relationship("User", back_populates="favorites")
    garment = relationship("Garment", back_populates="favorites")

    __table_args__ = (
        Index("idx_user_garment_unique", "user_id", "garment_id", unique=True),
    )
