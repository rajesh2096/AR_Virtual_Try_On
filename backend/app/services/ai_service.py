from typing import Optional
from app.models.tryon import TryonSession

class AIService:
    """
    Interface/Stub for Future Virtual Try-On AI Model Pipeline.
    
    Planned Architecture:
    - Input: Person full body image path + Garment image path
    - Processing: Local PyTorch/ONNX or worker queue pipeline for cloth warping, human pose estimation, and diffusion/GAN generation.
    - Output: Resulting try-on image saved to disk and recorded in MySQL.
    """

    @classmethod
    async def process_tryon(cls, session_id: int, person_image_path: str, garment_image_path: str) -> Optional[str]:
        """
        AI Try-On model integration will be attached here in Phase 2.
        For Phase 1 foundation: returns None and leaves session in 'pending' status.
        """
        # Phase 1: No fake image generated.
        return None
