from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, EmailStr


router = APIRouter(
    prefix="/auth",
    tags=["Authentication"],
)


users = {
    "test@gmail.com": {
        "name": "Test User",
        "email": "test@gmail.com",
        "password": "123456",
    }
}


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class RegisterRequest(BaseModel):
    name: str
    email: EmailStr
    password: str


class ForgotPasswordRequest(BaseModel):
    email: EmailStr


@router.post("/register")
def register(request: RegisterRequest):

    email = str(request.email).lower().strip()

    if email in users:
        raise HTTPException(
            status_code=400,
            detail="Account already exists",
        )

    users[email] = {
        "name": request.name.strip(),
        "email": email,
        "password": request.password,
    }

    return {
        "success": True,
        "message": "Registration successful",
        "user": {
            "name": users[email]["name"],
            "email": users[email]["email"],
        },
    }


@router.post("/login")
def login(request: LoginRequest):

    email = str(request.email).lower().strip()

    if email not in users:
        raise HTTPException(
            status_code=404,
            detail="No account found with this email",
        )

    if users[email]["password"] != request.password:
        raise HTTPException(
            status_code=401,
            detail="Invalid password",
        )

    return {
        "success": True,
        "message": "Login successful",
        "user": {
            "name": users[email]["name"],
            "email": users[email]["email"],
        },
    }


@router.post("/forgot-password")
def forgot_password(request: ForgotPasswordRequest):

    email = str(request.email).lower().strip()

    if email not in users:
        raise HTTPException(
            status_code=404,
            detail="No account found with this email",
        )

    return {
        "success": True,
        "message": "Password reset link sent successfully",
        "email": email,
    }


@router.get("/users")
def get_users():

    return {
        "count": len(users),
        "users": [
            {
                "name": user["name"],
                "email": user["email"],
            }
            for user in users.values()
        ],
    }