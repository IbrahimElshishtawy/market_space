import uuid

def sample_listing_payload(category_id: str = "cat-cars-uuid", area_id: str = "area-nasr-city-uuid"):
    return {
        "category_id": category_id,
        "area_id": area_id,
        "title": f"سيارة تجريبية للاختبار {uuid.uuid4().hex[:6]}",
        "description": "سيارة بحالة ممتازة لاختبار المنظومة البرمجية",
        "price": 450000.0,
        "listing_kind": "sale",
        "contact_channel": "in_app",
        "physical_lat": 30.0561,
        "physical_lng": 31.3301,
        "attributes": {
            "make": "Toyota",
            "year": 2021,
            "transmission": "automatic"
        }
    }
