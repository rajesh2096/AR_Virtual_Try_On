from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import JSONResponse
import os
from app.config import settings
from app.database import engine, Base
from app.services.image_service import ImageService
from app.routers import auth, garments, tryon

# Ensure upload directory hierarchy exists
ImageService.ensure_upload_dirs()

# Initialize tables automatically if needed (for dev/local setup)
try:
    Base.metadata.create_all(bind=engine)
except Exception as e:
    print(f"Warning: Database tables could not be created automatically on startup: {e}")

app = FastAPI(
    title=settings.PROJECT_NAME,
    openapi_url=f"{settings.API_V1_STR}/openapi.json",
    docs_url="/docs",
    redoc_url="/redoc"
)

# CORS middleware for Flutter web/mobile communication
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount local filesystem uploads to serve images statically
if not os.path.exists(settings.UPLOAD_DIR):
    os.makedirs(settings.UPLOAD_DIR, exist_ok=True)

app.mount(f"/{settings.UPLOAD_DIR}", StaticFiles(directory=settings.UPLOAD_DIR), name="uploads")

# Include API Routers
app.include_router(auth.router, prefix=settings.API_V1_STR)
app.include_router(garments.router, prefix=settings.API_V1_STR)
app.include_router(tryon.router, prefix=settings.API_V1_STR)

@app.get(f"{settings.API_V1_STR}/health", tags=["Health"])
def health_check():
    return {
        "status": "healthy",
        "service": settings.PROJECT_NAME,
        "database_configured": bool(settings.MYSQL_DATABASE),
        "uploads_ready": os.path.exists(settings.UPLOAD_DIR)
    }

@app.get("/", tags=["Root"])
def root():
    return {
        "message": "Welcome to AI Virtual Dress Try-On API",
        "docs": "/docs",
        "health": f"{settings.API_V1_STR}/health"
    }
