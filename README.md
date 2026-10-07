# AI Virtual Dress Try-On (Phase 1 Foundation)

A modern, cross-platform (Android-first, iOS-compatible) Virtual Dress Try-On system built with **Flutter** on the mobile client, and **FastAPI** + **MySQL** on the backend with local image storage.

---

## 🏗 System Architecture

```
[ Flutter Mobile App ] (Android / iOS)
         │
         │ REST API (JSON / Multipart Upload)
         ▼
[ FastAPI Backend ] (Port 8000)
    ├── Auth & Security (JWT, bcrypt)
    ├── Garment & Session Routers
    ├── Image Validation & Local File System Storage (/uploads)
    └── MySQL Database (Users, Garments, Try-On Metadata)
         │
         ▼
[ Future AI Virtual Try-On Pipeline (Phase 2) ]
```

---

## 📋 Prerequisites

Ensure you have installed:
1. **Python 3.10+** (Tested on Python 3.14 / 3.11 / 3.12)
2. **MySQL Server 8.0+** or MariaDB running locally (Port `3306`)
3. **Flutter SDK 3.x+** with Android SDK / Android Studio
4. **Android Emulator** or physical Android device (with USB debugging enabled)

---

## 🗄️ 1. MySQL Database Creation

1. Open your MySQL client / shell:
```bash
mysql -u root -p
```
2. Run the database initialization script:
```sql
CREATE DATABASE IF NOT EXISTS virtual_tryon CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```
*(Optional: You can also execute the full schema directly from [backend/schema.sql](file:///c:/Users/Admin/Downloads/YZ/backend/schema.sql)).*

---

## ⚙️ 2. Backend Setup & Configuration

### Step A: Configure Environment Variables
1. Navigate to the `backend/` folder:
```bash
cd backend
```
2. Copy `.env.example` to `.env`:
```bash
copy .env.example .env
```
3. Update `.env` with your local MySQL credentials:
```ini
PROJECT_NAME="AI Virtual Dress Try-On Backend"
API_V1_STR="/api"
SECRET_KEY="your_secure_random_key_here"
ACCESS_TOKEN_EXPIRE_MINUTES=1440

MYSQL_HOST=localhost
MYSQL_PORT=3306
MYSQL_DATABASE=virtual_tryon
MYSQL_USER=root
MYSQL_PASSWORD=your_actual_mysql_password

UPLOAD_DIR=uploads
MAX_FILE_SIZE_MB=10
```

### Step B: Python Virtual Environment & Dependencies
```bash
# Create virtual environment (if not already created)
python -m venv .venv

# Activate virtual environment:
# Windows PowerShell:
.venv\Scripts\Activate.ps1
# Windows CMD:
.venv\Scripts\activate.bat
# Linux / macOS:
source .venv/bin/activate

# Install required dependencies
pip install -r requirements.txt
```

### Step C: Run FastAPI Server
```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```
- **Backend API Base**: `http://127.0.0.1:8000`
- **Interactive Swagger Docs**: `http://127.0.0.1:8000/docs`
- **Health Check Endpoint**: `http://127.0.0.1:8000/api/health`

---

## 📱 3. Flutter Mobile App Setup

The Flutter application is architected to be single-codebase cross-platform (Android-first and iOS-ready).

### Connecting to the Local Backend:
- **Android Emulator**: Uses `http://10.0.2.2:8000` (built-in default).
- **Physical Android Device**: Needs your computer's local Wi-Fi IP (e.g. `http://192.168.1.50:8000`).
- **iOS Simulator / Desktop**: Uses `http://127.0.0.1:8000`.

> **Dynamic Server Setting**: You can switch the server URL at runtime directly inside the app from the Login screen or Profile screen!

### Step A: Fetch Dependencies
```bash
cd mobile
flutter pub get
```

### Step B: Run Application
```bash
# Run on connected Android Emulator or Physical Device
flutter run
```

---

## 📡 4. Phase 1 API Endpoints

### Health:
- `GET /api/health` — Check server status & database readiness

### Authentication:
- `POST /api/auth/register` — Register new user account (returns JWT token)
- `POST /api/auth/login` — Login with email & password (returns JWT token)
- `GET /api/auth/me` — Get current logged-in user profile

### Garments (Wardrobe):
- `POST /api/garments/upload` — Upload garment image (multipart form data: `name`, `category`, `file`)
- `GET /api/garments` — Retrieve user's uploaded garments list
- `GET /api/garments/{id}` — Get single garment details
- `DELETE /api/garments/{id}` — Delete garment and remove local file

### Try-On Sessions:
- `POST /api/tryon/create` — Upload person photo (`person_image`) + `garment_id` to start a session
- `GET /api/tryon/history` — Get user's try-on history
- `GET /api/tryon/{id}` — Get specific session details

---

## 🔒 Security & Image Validation
- **Secure File Storage**: Files are saved with cryptographically unique UUIDs under local `uploads/` directory to prevent path traversal attacks.
- **MIME & Image Verification**: Validates image types (`.jpg`, `.jpeg`, `.png`) and uses Pillow to verify image data integrity.
- **JWT & Password Hashing**: Passwords stored using `bcrypt` and authenticated using JWT Bearer tokens.
- **Zero Cloud GPU / Zero S3 lock-in**: Zero external cloud dependency for local development.

---

## 🚀 Phase 2 & Future Roadmap

1. **Phase 2 (AI Model Pipeline Integration)**:
   - Integrate human pose estimation (OpenPose / DensePose)
   - Garment warping and segmentation
   - Diffusion / GAN virtual try-on model inference pipeline inside `app/services/ai_service.py`
2. **Phase 3 (Real-Time AR)**:
   - ARCore / ARKit real-time camera tracking and live garment projection.
