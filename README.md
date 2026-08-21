# ServiceConnect

A Flutter-based service booking application that helps users find service providers, view provider details, book services, manage bookings, and cancel bookings.

## 📱 Project Overview

**ServiceConnect** is a mobile/web service booking prototype developed using **Flutter and Dart**.

The application provides a simple platform where users can search for common services such as:

* Plumbing
* Electrical
* Cleaning
* Carpentry

Users can view available providers, check service prices, book a service, view their bookings, and cancel bookings.

## ✨ Features

* Splash screen
* User Login and Registration UI
* Service search
* Popular service categories
* Service provider listing
* Provider details
* REST API integration
* Book a service
* Booking confirmation
* My Bookings
* Cancel booking with confirmation
* Logout
* Responsive Flutter UI

## 🛠️ Tech Stack

* **Flutter**
* **Dart**
* **Material Design**
* **REST API**
* **HTTP**
* **JSON**
* **Android Studio**
* **Git & GitHub**

## 🔗 API Integration

The application currently uses **JSONPlaceholder** as a mock REST API to demonstrate API communication.

### GET Request

Provider data is retrieved using an HTTP GET request.

```text
GET https://jsonplaceholder.typicode.com/users
```

The JSON response is converted into `ServiceProvider` objects and filtered according to the selected service.

### POST Request

Booking information is sent using an HTTP POST request.

```text
POST https://jsonplaceholder.typicode.com/posts
```

The booking request contains:

* Provider name
* Service
* Price

> **Note:** JSONPlaceholder is used only for prototype/testing purposes. Booking data is currently maintained locally in memory. A production version would use a real backend and database for persistent storage.

## 🔄 Application Flow

```text
Splash Screen
      ↓
Login / Register
      ↓
Home Screen
      ↓
Search Service
      ↓
Service Providers
      ↓
Provider Details
      ↓
Book Service
      ↓
Booking Confirmation
      ↓
My Bookings
      ↓
Cancel Booking
```

## 📂 Project Structure

```text
service-connect-app/
│
├── android/
├── ios/
├── lib/
│   └── main.dart
├── linux/
├── macos/
├── web/
├── windows/
├── test/
│
├── pubspec.yaml
├── pubspec.lock
└── README.md
```

## 🚀 How to Run

### Prerequisites

Install:

* Flutter SDK
* Android Studio or VS Code
* Android SDK for Android development

### Steps

Clone the repository:

```bash
git clone https://github.com/kavgowdaa/service-connect-app.git
```

Navigate to the project:

```bash
cd service-connect-app
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

To run the application in Chrome:

```bash
flutter run -d chrome
```

## 🔮 Future Enhancements

For a production-ready version, the following features can be added:

* Real backend and database
* Secure user authentication
* Persistent booking storage
* Provider availability
* Booking status tracking
* Push notifications
* Location and map integration
* Online payment integration
* Provider-side application
* Improved validation and error handling

## 👩‍💻 Developer

**Kavya Gowda**

Computer Science & Engineering

GitHub: [@kavgowdaa](https://github.com/kavgowdaa)
