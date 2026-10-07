# AI Virtual Dress Try-On - Backend Service

FastAPI-based REST API service for AI Virtual Try-On application.

## Quick Start

1. Copy `.env.example` to `.env` and configure your MySQL settings.
2. Initialize virtualenv and install requirements:
```bash
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
```
3. Run server:
```bash
uvicorn app.main:app --reload --port 8000
```
4. Access API docs at: `http://localhost:8000/docs`
