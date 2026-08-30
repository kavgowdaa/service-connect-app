from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

providers = [
    {"id": 1, "name": "Ramesh Kumar", "service": "Plumbing", "price": 500, "rating": 4.8},
    {"id": 2, "name": "Suresh Electricals", "service": "Electrical", "price": 400, "rating": 4.7},
    {"id": 3, "name": "Neat & Clean Co", "service": "Cleaning", "price": 800, "rating": 4.9},
    {"id": 4, "name": "WoodWorks", "service": "Carpentry", "price": 600, "rating": 4.6},
]

bookings = []

@app.get("/")
def root():
    return {"message": "ServiceConnect API running"}

@app.get("/providers")
def get_providers(service: str = None):
    if service:
        return [p for p in providers if service.lower() in p["service"].lower() or service.lower() in p["name"].lower()]
    return providers

@app.post("/book/{provider_id}")
def book_service(provider_id: int):
    provider = next((p for p in providers if p["id"] == provider_id), None)
    if provider:
        bookings.append(provider)
        return {"message": "Booked", "provider": provider}
    return {"error": "Provider not found"}

@app.get("/bookings")
def get_bookings():
    return bookings
