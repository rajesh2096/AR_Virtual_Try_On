from sqlalchemy.orm import Session
from app.models.category import Category, Subcategory

TAXONOMY_SEED_DATA = [
    {
        "name": "Clothing",
        "slug": "clothing",
        "super_type": "clothing",
        "icon_name": "checkroom",
        "sort_order": 1,
        "subcategories": [
            {"name": "T-Shirts", "slug": "t-shirts", "layer_type": "upper", "sort_order": 1},
            {"name": "Shirts", "slug": "shirts", "layer_type": "upper", "sort_order": 2},
            {"name": "Tops & Blouses", "slug": "tops", "layer_type": "upper", "sort_order": 3},
            {"name": "Jackets & Coats", "slug": "jackets", "layer_type": "upper", "sort_order": 4},
            {"name": "Kurtis & Tunics", "slug": "kurtis", "layer_type": "upper", "sort_order": 5},
            {"name": "Dresses", "slug": "dresses", "layer_type": "full_body", "sort_order": 6},
            {"name": "Sarees", "slug": "sarees", "layer_type": "full_body", "sort_order": 7},
            {"name": "Gowns", "slug": "gowns", "layer_type": "full_body", "sort_order": 8},
            {"name": "Jeans", "slug": "jeans", "layer_type": "lower", "sort_order": 9},
            {"name": "Pants & Trousers", "slug": "pants", "layer_type": "lower", "sort_order": 10},
            {"name": "Skirts", "slug": "skirts", "layer_type": "lower", "sort_order": 11},
            {"name": "Shorts", "slug": "shorts", "layer_type": "lower", "sort_order": 12},
        ]
    },
    {
        "name": "Footwear",
        "slug": "footwear",
        "super_type": "footwear",
        "icon_name": "hiking",
        "sort_order": 2,
        "subcategories": [
            {"name": "Shoes", "slug": "shoes", "layer_type": "footwear", "sort_order": 1},
            {"name": "Sneakers", "slug": "sneakers", "layer_type": "footwear", "sort_order": 2},
            {"name": "Sandals & Slides", "slug": "sandals", "layer_type": "footwear", "sort_order": 3},
            {"name": "Heels", "slug": "heels", "layer_type": "footwear", "sort_order": 4},
        ]
    },
    {
        "name": "Accessories & Jewelry",
        "slug": "accessories",
        "super_type": "accessory",
        "icon_name": "watch",
        "sort_order": 3,
        "subcategories": [
            {"name": "Watches", "slug": "watches", "layer_type": "wrist", "sort_order": 1},
            {"name": "Bracelets", "slug": "bracelets", "layer_type": "wrist", "sort_order": 2},
            {"name": "Necklaces", "slug": "necklaces", "layer_type": "neck", "sort_order": 3},
            {"name": "Bags & Purses", "slug": "bags", "layer_type": "accessory", "sort_order": 4},
        ]
    },
    {
        "name": "Headwear & Eyewear",
        "slug": "headwear-eyewear",
        "super_type": "headwear",
        "icon_name": "visibility",
        "sort_order": 4,
        "subcategories": [
            {"name": "Sunglasses", "slug": "sunglasses", "layer_type": "eyewear", "sort_order": 1},
            {"name": "Caps & Hats", "slug": "caps", "layer_type": "head", "sort_order": 2},
        ]
    }
]

def seed_category_taxonomy(db: Session):
    """
    Idempotent database seeding for categories and subcategories.
    Safe to execute multiple times on startup without creating duplicate entries.
    """
    for cat_data in TAXONOMY_SEED_DATA:
        category = db.query(Category).filter(Category.slug == cat_data["slug"]).first()
        if not category:
            category = Category(
                name=cat_data["name"],
                slug=cat_data["slug"],
                super_type=cat_data["super_type"],
                icon_name=cat_data.get("icon_name"),
                sort_order=cat_data.get("sort_order", 0),
                is_active=True
            )
            db.add(category)
            db.commit()
            db.refresh(category)
        else:
            # Update attributes if needed
            category.name = cat_data["name"]
            category.super_type = cat_data["super_type"]
            category.icon_name = cat_data.get("icon_name")
            category.sort_order = cat_data.get("sort_order", 0)
            db.commit()

        # Seed subcategories
        for sub_data in cat_data.get("subcategories", []):
            sub = db.query(Subcategory).filter(Subcategory.slug == sub_data["slug"]).first()
            if not sub:
                sub = Subcategory(
                    category_id=category.id,
                    name=sub_data["name"],
                    slug=sub_data["slug"],
                    layer_type=sub_data["layer_type"],
                    sort_order=sub_data.get("sort_order", 0),
                    is_active=True
                )
                db.add(sub)
                db.commit()
            else:
                sub.category_id = category.id
                sub.name = sub_data["name"]
                sub.layer_type = sub_data["layer_type"]
                sub.sort_order = sub_data.get("sort_order", 0)
                db.commit()
