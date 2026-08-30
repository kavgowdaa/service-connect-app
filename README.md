# ServiceConnect - Local Service Booking App 🔧

> Find trusted plumbers, electricians & cleaners near you in Mangaluru / Bangalore - Inspired by Urban Company.

**Live Demo:** Flutter App + FastAPI Backend
**Built for:** AGREMATE-style multi-role apps (Tenant / Landlord / Guard)

---

### 📸 Screenshots

| Home | Provider Detail | Booking |
| :---: | :---: | :---: |
| Home Screen with Services | WoodWorks Detail with Map Card (1.2km) | Booking Flow |

> Add your 2 screenshots in `screenshots/` folder and link them here

---

### 🚀 What I Built (V2 - Aug 30)

**Premium UI (Flutter):**
- ✅ Provider detail page with shadow container, map location card, rating (4.8★)
- ✅ Sticky bottom price bar - "₹450/hour • Book Now" like Urban Company
- ✅ Service description tailored for Tenant/Landlord/PG use-case
- ✅ Smooth scroll, responsive layout

**Backend (FastAPI):**
- `GET /providers` - List all service providers
- `POST /book` - Book a service
- Runs at `127.0.0.1:8000`

**Tech Stack:**
- **Flutter** & Dart - Frontend
- **REST API** - FastAPI + JSON
- **State Management** - Provider (Migrating to Riverpod)
- **Firebase** - Auth & Firestore (Integration in progress)
- **Google Maps SDK** - Location & Distance (UI ready, SDK next)
- **Architecture** - MVVM + Multi-role inspired

---

### 🛠️ How to Run

**Backend:**
```bash
cd service-connect-backend
uvicorn main:app --reload
# API at http://127.0.0.1:8000/docs
