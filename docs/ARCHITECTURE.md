# ARCHITECTURE

## Backend (FastAPI)
- `app/api/v1/`: Feature-specific routers (auth, users, transactions, analytics, budgets, goals).
- `app/services/`: Business logic and data aggregation (SQL-heavy for analytics).
- `app/models/`: SQLAlchemy models (User, Transaction, Budget, Goal).
- `app/schemas/`: Pydantic validation schemas.
- `app/core/`: Settings, Security, Exceptions.
- `app/database/`: Async session management and base models.

## Frontend (Flutter)
- Feature-first structure: `lib/features/<feature>/` (presentation, domain, data).
- `core/network/`: ApiClient with Dio interceptors (auth token injection & auto-refresh).
- `shared/providers/`: Global Riverpod providers (Auth, Theme).
- State Management: `flutter_riverpod` (StateNotifier/FutureProvider).
- Navigation: `go_router` with Auth Guards.
