from datetime import datetime
from sqlalchemy import Column, Integer, String, DateTime, Text, Boolean, ForeignKey, Index
from sqlalchemy.orm import relationship
from app.database import Base

class Outfit(Base):
    __tablename__ = "outfits"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    title = Column(String(150), nullable=False)
    description = Column(Text, nullable=True)
    is_favorite = Column(Boolean, default=False, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    user = relationship("User", back_populates="outfits")
    items = relationship("OutfitItem", back_populates="outfit", cascade="all, delete-orphan")
    tryon_sessions = relationship("TryonSession", back_populates="outfit")


class OutfitItem(Base):
    __tablename__ = "outfit_items"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    outfit_id = Column(Integer, ForeignKey("outfits.id", ondelete="CASCADE"), nullable=False, index=True)
    garment_id = Column(Integer, ForeignKey("garments.id", ondelete="RESTRICT"), nullable=False, index=True)
    slot_type = Column(String(50), nullable=False) # upper, lower, full_body, footwear, wrist, eyewear, head, neck, accessory
    sort_order = Column(Integer, default=0, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    outfit = relationship("Outfit", back_populates="items")
    garment = relationship("Garment", back_populates="outfit_items")
