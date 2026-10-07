from datetime import datetime
from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from app.database import Base

class TryonSession(Base):
    __tablename__ = "tryon_sessions"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    garment_id = Column(Integer, ForeignKey("garments.id", ondelete="CASCADE"), nullable=False, index=True)
    person_image_path = Column(String(500), nullable=False)
    result_image_path = Column(String(500), nullable=True)
    status = Column(String(50), nullable=False, default="pending")  # pending, processing, completed, failed
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    user = relationship("User", back_populates="tryon_sessions")
    garment = relationship("Garment", back_populates="tryon_sessions")
