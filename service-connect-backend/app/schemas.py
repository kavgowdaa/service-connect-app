from pydantic import BaseModel


class BookingRequest(BaseModel):
    provider_id: int
    customer_name: str = "Customer"
    customer_email: str = ""
    service_date: str
    service_time: str
    address: str
    notes: str = ""


class BookingResponse(BaseModel):
    success: bool
    message: str
    booking: dict