from datetime import date, time

from fastapi import FastAPI, HTTPException, Query, Depends
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session

from .database import Base, engine, get_db
from .models import Booking
from .schemas import BookingRequest


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
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ============================================================
# AUTH
# ============================================================

from .routes import auth

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
    service: str | None = Query(default=None),
):
    if service is None:
        return providers

    requested_service = service.strip().lower()

    if requested_service == "" or requested_service == "all":
        return providers

    return [
        provider
        for provider in providers
        if provider["service"].strip().lower() == requested_service
    ]


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
def create_booking(
    booking: BookingRequest,
    db: Session = Depends(get_db),
):

    # --------------------------------------------------------
    # FIND PROVIDER
    # --------------------------------------------------------

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

    # --------------------------------------------------------
    # VALIDATE ADDRESS
    # --------------------------------------------------------

    if not booking.address.strip():
        raise HTTPException(
            status_code=400,
            detail="Service address is required",
        )

    # --------------------------------------------------------
    # VALIDATE DATE
    # --------------------------------------------------------

    try:
        date.fromisoformat(
            booking.service_date
        )
    except ValueError:
        raise HTTPException(
            status_code=400,
            detail="Invalid service date. Use YYYY-MM-DD.",
        )

    # --------------------------------------------------------
    # VALIDATE TIME
    # --------------------------------------------------------

    try:
        time.fromisoformat(
            booking.service_time
        )
    except ValueError:
        raise HTTPException(
            status_code=400,
            detail="Invalid service time. Use HH:MM.",
        )

    # --------------------------------------------------------
    # CREATE DATABASE BOOKING
    # --------------------------------------------------------

    new_booking = Booking(
        provider_id=booking.provider_id,
        customer_name=booking.customer_name.strip(),
        customer_email=booking.customer_email.strip().lower(),
        service_date=booking.service_date,
        service_time=booking.service_time,
        address=booking.address.strip(),
        notes=booking.notes.strip(),
        status="confirmed",
    )

    db.add(new_booking)

    db.commit()

    db.refresh(new_booking)

    # --------------------------------------------------------
    # RESPONSE
    # --------------------------------------------------------

    return {
        "success": True,
        "message": "Booking confirmed successfully",
        "booking": {
            "booking_id": new_booking.id,
            "provider": {
                "id": provider["id"],
                "name": provider["name"],
                "service": provider["service"],
                "price": provider["price"],
            },
            "customer": {
                "name": new_booking.customer_name,
                "email": new_booking.customer_email,
            },
            "service_date": new_booking.service_date,
            "service_time": new_booking.service_time,
            "address": new_booking.address,
            "notes": new_booking.notes,
            "status": new_booking.status,
        },
    }


# ============================================================
# GET USER BOOKINGS
# ============================================================

@app.get("/bookings/{customer_email}")
def get_customer_bookings(
    customer_email: str,
    db: Session = Depends(get_db),
):

    bookings = (
        db.query(Booking)
        .filter(
            Booking.customer_email
            == customer_email.strip().lower()
        )
        .order_by(Booking.id.desc())
        .all()
    )

    result = []

    for booking in bookings:

        provider = next(
            (
                item
                for item in providers
                if item["id"] == booking.provider_id
            ),
            None,
        )

        result.append(
            {
                "booking_id": booking.id,
                "provider": provider,
                "customer_name": booking.customer_name,
                "customer_email": booking.customer_email,
                "service_date": booking.service_date,
                "service_time": booking.service_time,
                "address": booking.address,
                "notes": booking.notes,
                "status": booking.status,
            }
        )

    return {
        "success": True,
        "count": len(result),
        "bookings": result,
    }


# ============================================================
# GET SINGLE BOOKING
# ============================================================

@app.get("/booking/{booking_id}")
def get_booking(
    booking_id: int,
    db: Session = Depends(get_db),
):

    booking = (
        db.query(Booking)
        .filter(Booking.id == booking_id)
        .first()
    )

    if booking is None:
        raise HTTPException(
            status_code=404,
            detail="Booking not found",
        )

    provider = next(
        (
            item
            for item in providers
            if item["id"] == booking.provider_id
        ),
        None,
    )

    return {
        "success": True,
        "booking": {
            "booking_id": booking.id,
            "provider": provider,
            "customer_name": booking.customer_name,
            "customer_email": booking.customer_email,
            "service_date": booking.service_date,
            "service_time": booking.service_time,
            "address": booking.address,
            "notes": booking.notes,
            "status": booking.status,
        },
    }


# ============================================================
# DELETE BOOKING
# ============================================================

@app.delete("/booking/{booking_id}")
def delete_booking(
    booking_id: int,
    db: Session = Depends(get_db),
):

    booking = (
        db.query(Booking)
        .filter(Booking.id == booking_id)
        .first()
    )

    if booking is None:
        raise HTTPException(
            status_code=404,
            detail="Booking not found",
        )

    db.delete(booking)

    db.commit()

    return {
        "success": True,
        "message": "Booking deleted successfully",
    }


# ============================================================
# SIMPLE BOOK PROVIDER
# ============================================================

@app.post("/book/{provider_id}")
def book_provider(provider_id: int):

    for provider in providers:
        if provider["id"] == provider_id:
            return {
                "success": True,
                "message": "Provider booking created",
                "provider": provider,
            }

    raise HTTPException(
        status_code=404,
        detail="Provider not found",
    )


# ============================================================
# GET SERVICES
# ============================================================

@app.get("/services")
def get_services():

    services = sorted(
        {
            provider["service"]
            for provider in providers
        }
    )

    return {
        "services": services,
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
        "database": "SQLite",
        "backend_framework": "FastAPI + SQLAlchemy",
        "endpoints": {
            "providers": "/providers",
            "provider": "/providers/{provider_id}",
            "services": "/services",
            "booking": "/book",
            "bookings": "/bookings/{customer_email}",
            "booking_details": "/booking/{booking_id}",
            "delete_booking": "/booking/{booking_id}",
            "health": "/health",
            "login": "/auth/login",
            "register": "/auth/register",
            "forgot_password": "/auth/forgot-password",
        },
    }


# ============================================================
# DEBUG PROVIDERS
# ============================================================

@app.get("/debug/providers")
def debug_providers():

    return {
        "file": __file__,
        "providers": providers,
    }