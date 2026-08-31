from fastapi import FastAPI, Query, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from datetime import date, time

from .database import Base, engine
from .routes import auth


# ============================================================
# DATABASE
# ============================================================

Base.metadata.create_all(bind=engine)


# ============================================================
# FASTAPI APP
# ============================================================

app = FastAPI(
    title="ServiceConnect API",
    description="Backend API for ServiceConnect",
    version="1.0.0",
)


# ============================================================
# CORS
# ============================================================

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ============================================================
# AUTH
# ============================================================

app.include_router(auth.router)


# ============================================================
# PROVIDERS
# ============================================================

providers = [
    {
        "id": 1,
        "name": "Ramesh Kumar",
        "service": "plumbing",
        "price": 500,
        "rating": 4.8,
        "description": "Expert plumber - 10 years exp",
    },
    {
        "id": 2,
        "name": "Suresh Electricals",
        "service": "electrical",
        "price": 400,
        "rating": 4.9,
        "description": "Licensed electrician",
    },
    {
        "id": 3,
        "name": "Sunshine Cleaning",
        "service": "cleaning",
        "price": 350,
        "rating": 4.7,
        "description": "Home & office cleaning",
    },
    {
        "id": 4,
        "name": "Anil Carpentry",
        "service": "carpentry",
        "price": 600,
        "rating": 4.6,
        "description": "Furniture & repair",
    },
]


# ============================================================
# BOOKING MODEL
# ============================================================

class BookingRequest(BaseModel):
    provider_id: int
    customer_name: str = "Customer"
    customer_email: str = ""
    service_date: str
    service_time: str
    address: str
    notes: str = ""


# ============================================================
# ROOT
# ============================================================

@app.get("/")
def root():
    return {
        "message": "ServiceConnect API is running",
        "status": "success",
    }


# ============================================================
# HEALTH
# ============================================================

@app.get("/health")
def health_check():
    return {
        "status": "healthy",
        "service": "ServiceConnect API",
    }


# ============================================================
# GET PROVIDERS
# ============================================================

@app.get("/providers")
def get_providers(
    service: str | None = Query(default=None)
):

    # No service selected
    if service is None:
        return providers

    # Clean service name
    requested_service = service.strip().lower()

    # All selected
    if requested_service == "" or requested_service == "all":
        return providers

    # Filter
    filtered_providers = []

    for provider in providers:

        provider_service = (
            provider["service"]
            .strip()
            .lower()
        )

        if provider_service == requested_service:
            filtered_providers.append(provider)

    return filtered_providers


# ============================================================
# GET SINGLE PROVIDER
# ============================================================

@app.get("/providers/{provider_id}")
def get_provider(provider_id: int):

    for provider in providers:

        if provider["id"] == provider_id:
            return provider

    raise HTTPException(
        status_code=404,
        detail="Provider not found",
    )


# ============================================================
# CREATE BOOKING
# ============================================================

@app.post("/book")
def create_booking(booking: BookingRequest):

    provider = None

    for item in providers:

        if item["id"] == booking.provider_id:
            provider = item
            break

    if provider is None:
        raise HTTPException(
            status_code=404,
            detail="Provider not found",
        )

    if not booking.address.strip():
        raise HTTPException(
            status_code=400,
            detail="Service address is required",
        )

    try:
        date.fromisoformat(
            booking.service_date
        )
    except ValueError:
        raise HTTPException(
            status_code=400,
            detail="Invalid service date",
        )

    try:
        time.fromisoformat(
            booking.service_time
        )
    except ValueError:
        raise HTTPException(
            status_code=400,
            detail="Invalid service time",
        )

    booking_id = 1000 + booking.provider_id

    return {
        "success": True,
        "message": "Booking confirmed successfully",

        "booking": {
            "booking_id": booking_id,

            "provider": {
                "id": provider["id"],
                "name": provider["name"],
                "service": provider["service"],
                "price": provider["price"],
            },

            "customer": {
                "name": booking.customer_name,
                "email": booking.customer_email,
            },

            "service_date": booking.service_date,
            "service_time": booking.service_time,
            "address": booking.address,
            "notes": booking.notes,
        },
    }


# ============================================================
# SIMPLE BOOK PROVIDER
# ============================================================

@app.post("/book/{provider_id}")
def book_provider(provider_id: int):

    provider = None

    for item in providers:

        if item["id"] == provider_id:
            provider = item
            break

    if provider is None:
        raise HTTPException(
            status_code=404,
            detail="Provider not found",
        )

    return {
        "success": True,
        "message": "Provider booking created",
        "provider": provider,
    }


# ============================================================
# GET SERVICES
# ============================================================

@app.get("/services")
def get_services():

    services = sorted(
        list(
            set(
                provider["service"]
                for provider in providers
            )
        )
    )

    return {
        "services": services
    }


# ============================================================
# API INFORMATION
# ============================================================

@app.get("/api/info")
def api_info():

    return {
        "name": "ServiceConnect",
        "version": "1.0.0",
        "backend": "FastAPI",

        "endpoints": {
            "providers": "/providers",
            "services": "/services",
            "booking": "/book",
            "health": "/health",
        },
    }
@app.get("/debug/providers")
def debug_providers():
    return {
        "file": __file__,
        "providers": providers,
    }