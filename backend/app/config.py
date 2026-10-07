from pydantic_settings import BaseSettings
from typing import Optional, List
import os
from pathlib import Path

# Base directory for the backend (absolute path)
BACKEND_DIR = Path(__file__).resolve().parent.parent

class Settings(BaseSettings):
    PROJECT_NAME: str = "AI Virtual Dress Try-On Backend"
    API_V1_STR: str = "/api/v1"
    SECRET_KEY: str = "default_development_secret_key_change_in_production"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 # 24 hours

    # MySQL Configuration
    MYSQL_HOST: str = "localhost"
    MYSQL_PORT: int = 3306
    MYSQL_DATABASE: str = "virtual_tryon"
    MYSQL_USER: str = "root"
    MYSQL_PASSWORD: str = ""

    # Absolute Uploads Configuration
    UPLOAD_DIR: str = str(BACKEND_DIR / "uploads")
    MAX_FILE_SIZE_MB: int = 10
    ALLOWED_IMAGE_EXTENSIONS: List[str] = [".jpg", ".jpeg", ".png"]

    @property
    def DATABASE_URL(self) -> str:
        # URL encode or formatted pymysql connection string
        return f"mysql+pymysql://{self.MYSQL_USER}:{self.MYSQL_PASSWORD}@{self.MYSQL_HOST}:{self.MYSQL_PORT}/{self.MYSQL_DATABASE}?charset=utf8mb4"

    class Config:
        env_file = str(BACKEND_DIR / ".env")
        extra = "ignore"

settings = Settings()
