# 🔧 ServiceConnect

### Flutter Service Booking Application | Flutter • Dart • Riverpod • Firebase • REST APIs • FastAPI • Google Maps

ServiceConnect is a modern **Flutter-based service booking application** that connects customers with local service professionals.

The project demonstrates an end-to-end mobile application workflow including **authentication, service discovery, provider search and filtering, provider details, location-based navigation, service booking, and booking management**.

The application uses **Flutter and Dart** for the mobile frontend, **Riverpod** for state management, **Firebase Authentication** for user authentication, and a **FastAPI REST backend** with SQLite for booking data.

---

## 📱 Features

### 🔐 Authentication

* User login and registration
* Firebase Authentication integration
* Authentication-aware application flow
* Clean and user-friendly authentication UI

### 🏠 Service Discovery

* Browse available service categories
* Search service providers
* Filter providers by service type
* Display provider ratings and pricing
* View provider descriptions and details
* Modern card-based service provider interface

### 👨‍🔧 Provider Details

* Dedicated provider details screen
* Provider service information
* Pricing and rating information
* Provider location access
* Navigation from provider details to booking

### 📍 Google Maps Integration

* Open provider locations using Google Maps
* Location-based service experience
* Automatically zoom closer to the selected provider
* Provider location interaction from the application

### 📅 Service Booking

Users can complete a service booking by:

1. Selecting a service provider
2. Selecting a service date
3. Selecting a service time
4. Entering the service address
5. Confirming the booking

The Flutter application communicates with the backend through REST APIs, with backend-side validation for booking information.

### 📋 My Bookings

* View previously created bookings
* Display provider information
* Display booking date and time
* Display service address
* Manage existing bookings
* Delete bookings

---

# 🏗️ Application Architecture

```text
                    ┌─────────────────────┐
                    │    Flutter App      │
                    │     Dart / UI       │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │      Riverpod       │
                    │  State Management   │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │     ApiService      │
                    │  HTTP REST Client   │
                    └──────────┬──────────┘
                               │
                               │ REST API
                               ▼
                    ┌─────────────────────┐
                    │   FastAPI Backend   │
                    │       Python        │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │   SQLite Database   │
                    └─────────────────────┘
```

---

# 🔄 Application Flow

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
Confirm Booking
       ↓
My Bookings
       ↓
Delete Booking
```

---

# 🛠️ Tech Stack

## Frontend

| Technology      | Usage                                         |
| --------------- | --------------------------------------------- |
| **Flutter**     | Cross-platform mobile application development |
| **Dart**        | Application programming language              |
| **Riverpod**    | State management                              |
| **Material UI** | Application interface                         |
| **HTTP**        | REST API communication                        |

## Backend

| Technology  | Usage                |
| ----------- | -------------------- |
| **FastAPI** | REST API backend     |
| **Python**  | Backend development  |
| **SQLite**  | Booking data storage |
| **Uvicorn** | ASGI server          |

## Integrations

| Technology                  | Usage                                |
| --------------------------- | ------------------------------------ |
| **Firebase Authentication** | User authentication                  |
| **Google Maps**             | Provider location and map experience |
| **REST APIs**               | Frontend-backend communication       |

---

# 📂 Project Structure

```text
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
├── test/
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

---

# 🔌 REST API Integration

The Flutter frontend communicates with the FastAPI backend through a dedicated `ApiService`.

```text
Flutter UI
    ↓
ApiService
    ↓
HTTP Request
    ↓
FastAPI
    ↓
SQLite
```

The backend handles service provider and booking operations while the Flutter application handles the user interface and interaction flow.

### API Operations Demonstrated

* Fetch service providers
* Filter providers by service
* Create service bookings
* Retrieve booking information
* Delete bookings
* Backend validation
* Error handling

---

# 📅 Booking Validation

The booking flow includes validation for:

* Service provider selection
* Service date
* Service time
* Service address
* Backend request formatting

The application formats service time for backend API compatibility using the expected `HH:MM` format.

---

# 🗺️ Location Experience

Google Maps is integrated into the provider experience to make service discovery more realistic.

Users can open the provider's location and the map is automatically positioned closer to the selected provider.

This provides a more practical location-based service-booking experience rather than a purely static provider listing.

---

# 🧪 Testing & Code Quality

Flutter static analysis was used during development.

Run:

```bash
flutter analyze
```

Run the application:

```bash
flutter run
```

The project was tested on an Android physical device during development.

---

# 🚀 Getting Started

## Prerequisites

Install the following:

* Flutter SDK
* Dart SDK
* Python
* Android Studio
* Android SDK
* Android emulator or physical Android device
* Firebase project
* Google Maps API configuration

---

## 1. Clone the Repository

```bash
git clone https://github.com/kavgowdaa/service-connect-app.git

cd service-connect-app
```

---

## 2. Install Flutter Dependencies

```bash
flutter pub get
```

---

## 3. Configure Firebase

Firebase configuration is required for authentication.

If setting up the project from scratch, configure Firebase for the Flutter application using FlutterFire.

```bash
flutterfire configure
```

Then verify the Firebase configuration for your target platform.

---

## 4. Configure Google Maps

Configure the Google Maps API key for the target platform and enable the required Maps SDK.

Do not commit unrestricted or sensitive API credentials to the repository.

---

## 5. Start the FastAPI Backend

Navigate to the backend:

```bash
cd service-connect-backend
```

Install the backend dependencies:

```bash
pip install fastapi uvicorn
```

Start the backend:

```bash
uvicorn main:app --reload
```

The backend runs locally at:

```text
http://127.0.0.1:8000
```

---

## 6. Run the Flutter Application

Return to the Flutter project directory:

```bash
cd ..
```

Then run:

```bash
flutter run
```

---

# 💡 Key Engineering Highlights

This project demonstrates practical Flutter development concepts including:

* Cross-platform Flutter application development
* Dart programming
* Stateful and reusable UI components
* Riverpod state management
* Firebase Authentication
* REST API integration
* HTTP request handling
* JSON data handling
* FastAPI backend integration
* SQLite data persistence
* Search and filtering
* Form handling
* Date and time selection
* Backend validation
* Google Maps integration
* Location-based UI
* Navigation between multiple screens
* CRUD-style booking operations
* Error handling and debugging
* Git and GitHub version control

---

# 🎯 Why ServiceConnect?

ServiceConnect was developed as a practical mobile application rather than a collection of isolated screens.

The project focuses on building a realistic user journey:

```text
Authenticate
     ↓
Discover
     ↓
Search
     ↓
Explore Provider
     ↓
View Location
     ↓
Book
     ↓
Manage Booking
```

This demonstrates how Flutter can be used to build a complete application that communicates with backend services and external integrations.

---

# 📸 Application Screens

The application includes screens for:

* 🔐 Login / Registration
* 🏠 Home / Service Discovery
* 👨‍🔧 Provider Details
* 📍 Provider Location
* 📅 Service Booking
* 📋 My Bookings

> Screenshots can be added here to showcase the application's UI and booking workflow.

---

# 🌱 Future Improvements

Possible future enhancements include:

* Provider-side application
* Booking status updates
* Push notifications
* Real-time booking updates
* Provider availability management
* User profile management
* Reviews and ratings
* Payment integration
* Improved automated testing
* Production deployment

---

# 👩‍💻 Developer

**Kavya Gowda**

Computer Science Engineering

**Technologies:**
Flutter • Dart • Riverpod • Firebase • REST APIs • FastAPI • Python • SQLite • Google Maps • Git • GitHub

---

# 📄 License

This project was developed for **learning, portfolio, and software development demonstration purposes**.
