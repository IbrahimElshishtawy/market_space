from locust import HttpUser, task, between
import random

class DealOneConsumerUser(HttpUser):
    wait_time = between(1, 3)

    @task(50)
    def browse_home_feed(self):
        self.client.get("/explore/feed", headers={"Accept-Language": "ar"})

    @task(30)
    def search_listings(self):
        categories = ["real-estate", "cars", "building-materials", "services", "fashion", "appliances-decor"]
        selected_cat = random.choice(categories)
        self.client.get(f"/search?category_slug={selected_cat}&limit=20")

    @task(15)
    def spatial_geo_search(self):
        # Coordinates around Cairo & Giza
        cairo_lat = 30.0444 + random.uniform(-0.05, 0.05)
        cairo_lng = 31.2357 + random.uniform(-0.05, 0.05)
        self.client.get(f"/search?lat={cairo_lat}&lng={cairo_lng}&radius_km=15&sort_by=nearest")

    @task(5)
    def get_categories_taxonomy(self):
        self.client.get("/categories")
