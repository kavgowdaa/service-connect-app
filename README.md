# 🔧 ServiceConnect

A modern Flutter service-booking application that connects customers with trusted local service professionals.

ServiceConnect provides a complete end-to-end booking experience — from authentication and discovering service providers to booking services, viewing bookings, and managing them.

## 📱 Features

### 🔐 Authentication
- User Login and Registration
- Firebase Authentication
- Secure authentication flow

### 🏠 Service Discovery
- Browse available service categories
- Search service providers
- Filter providers by service
- Provider ratings and pricing
- Detailed provider information

### 📅 Service Booking
- Select service date
- Select service time
- Enter service address
- Confirm bookings
- Backend validation through REST APIs

### 📋 My Bookings
- View all booked services
- Display provider and booking details
- View booking date and time
- Delete bookings

### 📍 Google Maps
- Open provider location using Google Maps
- Automatically zoom closer to the selected provider
- Location-based service experience

## 🛠️ Tech Stack

### Frontend
- Flutter
- Dart
- Riverpod
- Material UI

### Backend
- FastAPI
- Python
- REST APIs
- SQLite

### Services & APIs
- Firebase Authentication
- Google Maps SDK
- HTTP REST API integration

## 🏗️ Application Flow

```text
Login / Register
       ↓
Home Screen
       ↓
Browse Services
       ↓
Search / Filter Providers
       ↓
Provider Details
       ↓
Google Maps Location
       ↓
Book Service
       ↓
Select Date & Time
       ↓
Enter Address
       ↓
Booking Confirmation
       ↓
My Bookings
       ↓
Delete Booking

📂 Project Structure
service_connect/
│
├── lib/
│   ├── screens/
│   │   ├── login_screen.dart
│   │   ├── home_screen.dart
│   │   ├── provider_details_screen.dart
│   │   ├── booking_screen.dart
│   │   └── my_bookings_screen.dart
│   │
│   ├── services/
│   │   └── api_service.dart
│   │
│   ├── firebase_options.dart
│   └── main.dart
│
├── service-connect-backend/
│   ├── main.py
│   └── serviceconnect.db
│
├── android/
├── ios/
├── web/
├── windows/
│
├── pubspec.yaml
└── README.md
🚀 Getting Started
Prerequisites

Make sure you have installed:

Flutter SDK
Dart SDK
Python
Android Studio
Android Emulator or physical Android device
1. Clone the repository
git clone https://github.com/kavgowdaa/service-connect-app.git
cd service-connect-app
2. Install Flutter dependencies
flutter pub get
3. Start the FastAPI backend

Navigate to the backend:
cd service-connect-backend

Install dependencies:
pip install fastapi uvicorn

Start the server:
uvicorn main:app --reload

The API will run at:
http://127.0.0.1:8000
4. Run the Flutter application

From the Flutter project directory:
flutter run

🔌 API Integration
The Flutter application communicates with the FastAPI backend using REST APIs.

Example workflow:

Flutter App
     ↓
ApiService
     ↓
HTTP REST API
     ↓
FastAPI Backend
     ↓
SQLite Database
🧪 Testing

Run Flutter static analysis:
flutter analyze
Run the application:
flutter run

🎯 Project Highlights
Complete service-booking workflow
Clean Flutter UI
Riverpod state management
Firebase authentication
REST API integration
FastAPI backend
SQLite database
Google Maps integration
Provider search and filtering
Booking management
Date and time validation
Cross-platform Flutter structure

👩‍💻 Developer
Kavya Gowda
Computer Science Engineering
Flutter • Dart • Firebase • REST APIs • FastAPI • Python

📄 License
This project is developed for learning, portfolio, and demonstration purposes.

