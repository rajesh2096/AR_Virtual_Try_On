import os
import uuid
import aiofiles
from PIL import Image
import io
import mimetypes
from pathlib import Path
from fastapi import UploadFile, HTTPException, status
from app.config import settings, BACKEND_DIR

class ImageService:
    ALLOWED_EXTENSIONS = {".jpg", ".jpeg", ".png"}
    ALLOWED_MIME_TYPES = {"image/jpeg", "image/png", "image/jpg"}
    MAX_FILE_SIZE_BYTES = settings.MAX_FILE_SIZE_MB * 1024 * 1024
    VALID_SUBFOLDERS = {"users", "garments", "tryon_results", "person_profiles"}

    @classmethod
    def ensure_upload_dirs(cls):
        base_dir = Path(settings.UPLOAD_DIR)
        for sub in cls.VALID_SUBFOLDERS:
            (base_dir / sub).mkdir(parents=True, exist_ok=True)

    @classmethod
    async def validate_and_save_image(cls, file: UploadFile, subfolder: str) -> str:
        cls.ensure_upload_dirs()

        # Check subfolder security against path traversal
        if subfolder not in cls.VALID_SUBFOLDERS:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Invalid target upload category. Allowed: {', '.join(cls.VALID_SUBFOLDERS)}"
            )

        # 1. Validate file extension
        filename = file.filename or ""
        ext = os.path.splitext(filename)[1].lower()
        if ext not in cls.ALLOWED_EXTENSIONS:
            # Try guessing extension if missing or generic
            if not ext and file.content_type:
                guessed_ext = mimetypes.guess_extension(file.content_type)
                if guessed_ext in cls.ALLOWED_EXTENSIONS:
                    ext = guessed_ext
            if ext not in cls.ALLOWED_EXTENSIONS:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Invalid file extension: '{ext}'. Allowed extensions are: {', '.join(cls.ALLOWED_EXTENSIONS)}"
                )

        # 2. Read content and validate size
        contents = await file.read()
        if len(contents) > cls.MAX_FILE_SIZE_BYTES:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"File exceeds maximum allowed size of {settings.MAX_FILE_SIZE_MB}MB"
            )
        if len(contents) == 0:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Empty file uploaded"
            )

        # 3. Verify actual image format using Pillow directly (ground truth)
        try:
            image = Image.open(io.BytesIO(contents))
            image.verify()
            image_format = (image.format or "").upper()
            if image_format not in {"JPEG", "JPG", "PNG"}:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Unsupported image format: '{image_format}'. Must be JPEG or PNG"
                )
        except HTTPException:
            raise
        except Exception:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="The uploaded file is not a valid or corrupted image"
            )

        # 4. Generate secure unique filename
        unique_filename = f"{uuid.uuid4().hex}{ext}"
        relative_path = f"uploads/{subfolder}/{unique_filename}"
        full_path = (BACKEND_DIR / relative_path).resolve()

        # Check path traversal
        upload_root = Path(settings.UPLOAD_DIR).resolve()
        if not str(full_path).startswith(str(upload_root)):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid file path resolution"
            )

        # 5. Save image to disk asynchronously
        async with aiofiles.open(full_path, "wb") as f:
            await f.write(contents)

        return relative_path

    @classmethod
    def delete_file(cls, relative_path: str):
        if not relative_path:
            return
        upload_root = Path(settings.UPLOAD_DIR).resolve()
        full_path = (BACKEND_DIR / relative_path).resolve()
        if str(full_path).startswith(str(upload_root)) and full_path.exists():
            try:
                full_path.unlink()
            except OSError:
                pass
