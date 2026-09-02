from sqlalchemy import Column, Integer, String, Text

from .database import Base


class Booking(Base):
    __tablename__ = "bookings"

    id = Column(Integer, primary_key=True, index=True)

    provider_id = Column(Integer, nullable=False)

    customer_name = Column(
        String(100),
        nullable=False,
    )

    customer_email = Column(
        String(255),
        nullable=False,
        index=True,
    )

    service_date = Column(
        String(20),
        nullable=False,
    )

    service_time = Column(
        String(20),
        nullable=False,
    )

    address = Column(
        Text,
        nullable=False,
    )

    notes = Column(
        Text,
        nullable=True,
    )

    status = Column(
        String(30),
        nullable=False,
        default="confirmed",
    )