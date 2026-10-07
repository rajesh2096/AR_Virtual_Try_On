from datetime import datetime
from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from app.database import Base

class Garment(Base):
    __tablename__ = "garments"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    name = Column(String(150), nullable=False)
    image_path = Column(String(500), nullable=False)
    category = Column(String(50), nullable=True, default="general")
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    user = relationship("User", back_populates="garments")
    tryon_sessions = relationship("TryonSession", back_populates="garment", cascade="all, delete-orphan")
