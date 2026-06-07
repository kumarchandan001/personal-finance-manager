# FINTELIA

AI-powered behavioral personal finance management ecosystem.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.115+-009688?logo=fastapi)](https://fastapi.tiangolo.com)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16+-336791?logo=postgresql)](https://www.postgresql.org)
[![Gemini](https://img.shields.io/badge/Gemini_AI-Integrated-4285F4?logo=google)](https://ai.google.dev)

---

## Overview

FINTELIA combines transaction tracking, budgeting, goals, analytics, subscription monitoring, and AI coaching in one mobile-first platform.

### Core Capabilities

Smart expense tracking with automatic categorization.
AI financial assistant for personalized money management.
Budget creation and real-time spending monitoring.
Spending pattern and behavioral finance analysis.
Impulse purchase detection and financial insights.
Predictive analytics for future expenses and cash flow.
Goal planning with savings progress tracking.
Subscription and recurring payment monitoring.
Financial health score with intelligent recommendations.
Interactive dashboard with reports, charts, and alerts.

---

## Project Structure

```text
personal finance management/
|-- fintelia/                  # Flutter application
|   |-- lib/
|   |-- assets/
|   |-- android/
|   |-- web/
|   `-- pubspec.yaml
|-- backend/                   # FastAPI backend
|   |-- app/
|   |-- alembic/
|   |-- main.py
|   `-- requirements.txt
|-- docs/
|-- docker-compose.yml
`-- README.md
```

---

## Tech Stack

- Frontend: Flutter, Dart, Riverpod, GoRouter
- Backend: FastAPI, Python 3.11+, SQLAlchemy 2.0
- Database: PostgreSQL
- Authentication: Firebase Auth
- AI: Google Gemini API

---

## Getting Started

### Prerequisites

- Flutter SDK 3.x
- Dart SDK 3.x
- Python 3.11+
- PostgreSQL 16+

### Frontend Setup

```bash
cd fintelia
flutter pub get
flutter run
```

### Backend Setup

```bash
cd backend
python -m venv venv
```

Windows:

```bash
venv\Scripts\activate
pip install -r requirements.txt
copy .env.example .env
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

macOS/Linux:

```bash
source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### Environment Variables

Set values in `backend/.env` (copied from `backend/.env.example`):

```env
DATABASE_URL=postgresql+asyncpg://user:password@localhost:5432/fintelia_db
SECRET_KEY=your-secret-key
FIREBASE_PROJECT_ID=your-firebase-project
GEMINI_API_KEY=your-gemini-api-key
```

---

## Development Status

- Foundation and architecture setup: complete
- Core finance modules: complete
- AI and analytics modules: complete
- Behavioral and advanced modules: complete

---

## License

Proprietary. All rights reserved.
