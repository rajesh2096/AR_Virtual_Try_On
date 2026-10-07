from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
import os
from pathlib import Path
from app.config import settings, BACKEND_DIR
from app.database import engine, Base, SessionLocal
from app.services.image_service import ImageService
from app.services.taxonomy_seed import seed_category_taxonomy

# Import all updated routers
from app.routers import auth, profile, person_profiles, categories, garments, favorites, outfits, tryon

# Ensure upload directory hierarchy exists
ImageService.ensure_upload_dirs()

# Initialize tables & run idempotent seed
try:
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    try:
        seed_category_taxonomy(db)
    finally:
        db.close()
except Exception as e:
    print(f"Warning: Database initialization or taxonomy seeding notice: {e}")

app = FastAPI(
    title=settings.PROJECT_NAME,
    openapi_url="/api/v1/openapi.json",
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

# Mount local uploads directory for image serving
upload_path = Path(settings.UPLOAD_DIR)
upload_path.mkdir(parents=True, exist_ok=True)
app.mount("/uploads", StaticFiles(directory=str(upload_path)), name="uploads")

# --- Register Modern v1 API Routers (/api/v1/...) ---
app.include_router(auth.router, prefix="/api/v1")
app.include_router(profile.router, prefix="/api/v1")
app.include_router(person_profiles.router, prefix="/api/v1")
app.include_router(categories.router, prefix="/api/v1")
app.include_router(garments.router, prefix="/api/v1")
app.include_router(favorites.router, prefix="/api/v1")
app.include_router(outfits.router, prefix="/api/v1")
app.include_router(tryon.router, prefix="/api/v1")

# --- Register Backward Compatibility Routers (/api/...) for Flutter Phase 1 ---
app.include_router(auth.router, prefix="/api")
app.include_router(garments.router, prefix="/api")
app.include_router(tryon.router, prefix="/api")

@app.get("/api/v1/health", tags=["Health"])
@app.get("/api/health", tags=["Health"])
def health_check():
    return {
        "status": "healthy",
        "service": settings.PROJECT_NAME,
        "database_configured": bool(settings.MYSQL_DATABASE),
        "uploads_ready": upload_path.exists(),
        "api_versions": ["/api/v1", "/api"]
    }

@app.get("/", tags=["Root"])
def root():
    return {
        "message": "Welcome to AI Virtual Dress Try-On API",
        "docs": "/docs",
        "v1_base": "/api/v1",
        "health": "/api/v1/health"
    }
