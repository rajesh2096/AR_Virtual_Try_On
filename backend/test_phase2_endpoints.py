import pytest
import io
from PIL import Image
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def create_test_image_bytes():
    file = io.BytesIO()
    image = Image.new("RGB", (100, 100), color=(120, 80, 200))
    image.save(file, format="JPEG")
    file.seek(0)
    return file

def test_health_check():
    res = client.get("/api/v1/health")
    assert res.status_code == 200
    assert res.json()["status"] == "healthy"
    
    # Check legacy health route
    legacy_res = client.get("/api/health")
    assert legacy_res.status_code == 200

def test_categories_taxonomy():
    res = client.get("/api/v1/categories")
    assert res.status_code == 200
    data = res.json()
    assert len(data) >= 4
    clothing = next((c for c in data if c["slug"] == "clothing"), None)
    assert clothing is not None
    assert len(clothing["subcategories"]) >= 10

def test_auth_and_profile_flow():
    email = "phase2_tester@gmail.com"
    pwd = "TestPassword@123"

    # Register
    reg_res = client.post("/api/v1/auth/register", json={
        "name": "Phase 2 User",
        "email": email,
        "password": pwd
    })
    
    token = None
    if reg_res.status_code == 201:
        token = reg_res.json()["access_token"]
    else:
        login_res = client.post("/api/v1/auth/login", json={
            "email": email,
            "password": pwd
        })
        assert login_res.status_code == 200
        token = login_res.json()["access_token"]

    headers = {"Authorization": f"Bearer {token}"}

    # Profile Get & Update
    p_get = client.get("/api/v1/profile", headers=headers)
    assert p_get.status_code == 200

    p_update = client.put("/api/v1/profile", headers=headers, json={
        "gender": "female",
        "height_cm": 168.5,
        "preferred_size": "M",
        "favorite_colors": ["Emerald Green", "Black"]
    })
    assert p_update.status_code == 200
    assert p_update.json()["height_cm"] == 168.5

    # Person Profile Upload
    img_bytes = create_test_image_bytes()
    pp_res = client.post(
        "/api/v1/person-models/upload",
        headers=headers,
        data={"title": "Studio Standing Pose", "is_default": "true"},
        files={"file": ("model.jpg", img_bytes, "image/jpeg")}
    )
    assert pp_res.status_code == 201
    pp_id = pp_res.json()["id"]

    # Garment Upload with subcategory
    img_bytes2 = create_test_image_bytes()
    g_res = client.post(
        "/api/v1/garments/upload",
        headers=headers,
        data={
            "name": "Silk Floral Saree",
            "category": "Sarees",
            "brand": "Heritage Silk",
            "primary_color": "Maroon"
        },
        files={"file": ("saree.jpg", img_bytes2, "image/jpeg")}
    )
    assert g_res.status_code == 201
    g_id = g_res.json()["id"]

    # Favorites toggle
    fav_add = client.post(f"/api/v1/favorites/{g_id}", headers=headers)
    assert fav_add.status_code == 201

    fav_list = client.get("/api/v1/favorites", headers=headers)
    assert fav_list.status_code == 200
    assert len(fav_list.json()) >= 1

    # Outfit Create
    outfit_res = client.post("/api/v1/outfits/create", headers=headers, json={
        "title": "Evening Party Look",
        "items": [{"garment_id": g_id, "slot_type": "full_body"}]
    })
    assert outfit_res.status_code == 201
    outfit_id = outfit_res.json()["id"]

    # Tryon Session with person profile and outfit
    tryon_res = client.post(
        "/api/v1/tryon/create",
        headers=headers,
        data={"outfit_id": str(outfit_id), "person_profile_id": str(pp_id)}
    )
    assert tryon_res.status_code == 201
    assert tryon_res.json()["status"] == "pending"
