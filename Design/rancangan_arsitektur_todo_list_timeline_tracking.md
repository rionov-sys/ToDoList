# System Architecture & Technical Specification: Todo List with Timeline Tracking

---

## 1. Tech Stack (Flutter Mobile & Backend)

### Mobile Client (Flutter)
- **Framework:** Flutter SDK (3.2x+, Dart 3.x)
- **State Management:** `flutter_bloc` / `bloc` (Production standard, predictable state machine, separation of concerns).
- **Dependency Injection:** `get_it` + `injectable` (Decoupled architecture and easy unit/mock testing).
- **Local Persistence & Cache (Offline-First):** `isar` or `drift` (High performance local database for caching tasks & offline queue) + `flutter_secure_storage` (Tokens, keys).
- **Networking:** `dio` (Interceptors for JWT refresh, logging, retry, base URL config).
- **Date & Calendar Utility:** `table_calendar`, `intl`.
- **Background Tasks & Push Notifications:** `flutter_local_notifications` + `workmanager` / `firebase_messaging`.

### Backend & Cloud Infrastructure (Production Ready)
- **Backend Runtime:** Node.js (NestJS / TypeScript) or Go (Golang with Gin/Fiber) — *direkomendasikan NestJS untuk Clean Architecture modular*.
- **Primary Database:** PostgreSQL 15+ (Relational integrity untuk user, task dependencies, recurrence, timeline).
- **Cache & Session Management:** Redis (Token blacklisting, fast rate-limiting, user cache).
- **Authentication:** JWT (Short-lived Access Token: 15m, Secure Refresh Token: 7d).
- **Cloud/Hosting:** Docker containerized, deployed on AWS (ECS/EKS or App Runner) / GCP Cloud Run.

---

## 2. Data Models & Database Schema

### A. Entity-Relationship Design (PostgreSQL / Relational)

#### Table: `users`
| Column | Type | Constraints | Description |
|---|---|---|---|
| `id` | UUID | PRIMARY KEY, DEFAULT gen_random_uuid() | Unique User ID |
| `email` | VARCHAR(255) | UNIQUE, NOT NULL, INDEX | Email login |
| `password_hash` | VARCHAR(255) | NOT NULL | Argon2 / Bcrypt hash |
| `name` | VARCHAR(100) | NOT NULL | Display name |
| `avatar_url` | TEXT | NULL | Profile image URL |
| `timezone` | VARCHAR(50) | DEFAULT 'Asia/Jakarta' | Timezone untuk reminder |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Timestamp |
| `updated_at` | TIMESTAMPTZ | DEFAULT NOW() | Timestamp |

#### Table: `task_categories` (Optional Tagging / Board)
| Column | Type | Constraints | Description |
|---|---|---|---|
| `id` | UUID | PRIMARY KEY | Category ID |
| `user_id` | UUID | FK -> `users.id` ON DELETE CASCADE | Pemilik kategori |
| `name` | VARCHAR(50) | NOT NULL | Nama kategori (e.g. Work, Study) |
| `color_hex` | VARCHAR(9) | DEFAULT '#4F46E5' | Warna label UI |

#### Table: `tasks`
| Column | Type | Constraints | Description |
|---|---|---|---|
| `id` | UUID | PRIMARY KEY | Task ID |
| `user_id` | UUID | FK -> `users.id` ON DELETE CASCADE | Pemilik task |
| `category_id` | UUID | FK -> `task_categories.id` ON DELETE SET NULL | Kategori task |
| `title` | VARCHAR(255) | NOT NULL | Judul tugas |
| `description` | TEXT | NULL | Catatan/detail pengerjaan |
| `status` | ENUM | ('TODO', 'IN_PROGRESS', 'COMPLETED', 'BLOCKED') | Status lifecycle |
| `priority` | ENUM | ('LOW', 'MEDIUM', 'HIGH', 'URGENT') | Level prioritas |
| `progress_percentage` | INT | DEFAULT 0, CHECK (0-100) | Tracking progress timeline |
| `start_time` | TIMESTAMPTZ | NOT NULL | Jadwal mulai pengerjaan |
| `due_time` | TIMESTAMPTZ | NOT NULL | Deadline/target penyelesaian |
| `actual_completed_at` | TIMESTAMPTZ | NULL | Timestamp aktual selesai |
| `is_recurring` | BOOLEAN | DEFAULT FALSE | Apakah berulang |
| `recurrence_rule` | VARCHAR(100)| NULL | Format RRULE (e.g. FREQ=DAILY) |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Timestamp |
| `updated_at` | TIMESTAMPTZ | DEFAULT NOW() | Timestamp |

#### Table: `task_timeline_logs` (Untuk Tracking Historis Timeline)
| Column | Type | Constraints | Description |
|---|---|---|---|
| `id` | UUID | PRIMARY KEY | Log ID |
| `task_id` | UUID | FK -> `tasks.id` ON DELETE CASCADE | Referensi task |
| `old_status` | VARCHAR(50) | NULL | Status sebelumnya |
| `new_status` | VARCHAR(50) | NOT NULL | Status baru |
| `progress_delta` | INT | NOT NULL | Perubahan persentase |
| `note` | TEXT | NULL | Catatan progres |
| `recorded_at` | TIMESTAMPTZ | DEFAULT NOW() | Waktu pencatatan log |

---

## 3. API Contract & Backend Flow

### Auth Endpoints
- `POST /api/v1/auth/register`
  - Body: `{ email, password, name }`
  - Response: `{ user: { id, email, name }, token: { accessToken, refreshToken } }`
- `POST /api/v1/auth/login`
  - Body: `{ email, password }`
  - Response: `{ user, token: { accessToken, refreshToken } }`
- `POST /api/v1/auth/refresh`
  - Body: `{ refreshToken }`
  - Response: `{ accessToken, refreshToken }`

### Task & Timeline Endpoints
- `GET /api/v1/tasks`
  - Query Params: `?status=IN_PROGRESS&startDate=2025-05-01&endDate=2025-05-31&categoryId=...`
  - Response: `{ data: [Task], pagination: { page, limit, total } }`
- `POST /api/v1/tasks`
  - Body: `{ title, description, categoryId, priority, startTime, dueTime }`
  - Response: `{ data: Task }`
- `GET /api/v1/tasks/:id`
  - Response: `{ data: Task, logs: [TimelineLog] }`
- `PATCH /api/v1/tasks/:id/progress`
  - Body: `{ progressPercentage: 75, status: "IN_PROGRESS", note: "Selesai modul auth" }`
  - Response: `{ data: Task }`
- `DELETE /api/v1/tasks/:id`

### Calendar Feed Endpoints
- `GET /api/v1/calendar/summary`
  - Query Params: `?month=2025-05&timezone=Asia/Jakarta`
  - Response: 
    ```json
    {
      "2025-05-12": { "totalTasks": 4, "completedTasks": 2, "overdueTasks": 0 },
      "2025-05-13": { "totalTasks": 1, "completedTasks": 0, "overdueTasks": 1 }
    }
    ```
- `GET /api/v1/calendar/day-view`
  - Query Params: `?date=2025-05-12`
  - Response: `{ date: "2025-05-12", tasks: [Task] }`

---

## 4. Flutter Clean Architecture & Folder Structure (VS Code Ready)

Struktur folder mengadopsi **Clean Architecture (Feature-First)** yang terbukti scalable, modular, dan memisahkan business logic dari presentation:

```text
lib/
├── main.dart                       # Entry point aplikasi
├── app/                            # Global app setup (App widget, router, theme)
│   ├── app.dart
│   ├── routes/
│   │   └── app_router.dart         # GoRouter configuration
│   └── theme/
│       ├── app_colors.dart
│       ├── app_typography.dart
│       └── app_theme.dart
│
├── core/                           # Reusable core modules & foundations
│   ├── constants/                  # App-wide constants (Storage keys, endpoints)
│   ├── errors/                     # Failure, Exception & Error Handler classes
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/                    # Dio client, Interceptors, SSL Pinning
│   │   ├── api_client.dart
│   │   └── auth_interceptor.dart
│   ├── database/                   # Local database (Isar/Drift) config & schema
│   │   └── local_database.dart
│   ├── utils/                      # Date formatters, validators, extensions
│   └── di/                         # Dependency Injection setup
│       ├── injection.dart
│       └── injection.config.dart   # Auto-generated by injectable
│
├── features/                       # Modular business domains (Feature-First)
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/        # Remote & Local Auth Data Sources
│   │   │   ├── models/             # DTO & JSON Serialization
│   │   │   └── repositories/       # Repository Implementation
│   │   ├── domain/
│   │   │   ├── entities/           # Pure Dart User Entity
│   │   │   ├── repositories/       # Domain Repository Interfaces
│   │   │   └── usecases/           # LoginUseCase, RegisterUseCase
│   │   └── presentation/
│   │       ├── bloc/               # AuthBloc, AuthEvent, AuthState
│   │       ├── screens/            # LoginScreen, RegisterScreen
│   │       └── widgets/            # AuthTextField, SocialButton
│   │
│   ├── tasks/
│   │   ├── data/
│   │   │   ├── datasources/        # TaskRemoteDataSource, TaskLocalDataSource
│   │   │   ├── models/             # TaskModel, TaskLogModel
│   │   │   └── repositories/       # TaskRepositoryImpl (offline-sync logic)
│   │   ├── domain/
│   │   │   ├── entities/           # Task, TimelineLog, TaskStatus
│   │   │   ├── repositories/       # TaskRepository contract
│   │   │   └── usecases/           # GetTasksUseCase, UpdateProgressUseCase
│   │   └── presentation/
│   │       ├── bloc/               # TaskBloc, TaskTimelineBloc
│   │       ├── screens/            # TaskListScreen, TaskDetailScreen, AddTaskScreen
│   │       └── widgets/            # TaskCard, TimelineProgressIndicator
│   │
│   └── calendar/
│       ├── data/
│       │   ├── datasources/        # CalendarDataSource
│       │   └── repositories/       # CalendarRepositoryImpl
│       ├── domain/
│       │   ├── entities/           # CalendarSummary, DailySchedule
│       │   └── usecases/           # GetCalendarSummaryUseCase
│       └── presentation/
│           ├── bloc/               # CalendarBloc
│           ├── screens/            # CalendarTimelineScreen
│           └── widgets/            # CalendarMonthView, DayAgendaList
│
└── shared/                         # Shared UI Components
    └── widgets/
        ├── app_button.dart
        ├── app_text_field.dart
        ├── loading_indicator.dart
        └── empty_state.dart
```

---

## 5. Production Dependencies (`pubspec.yaml`)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Architecture & State Management
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  get_it: ^7.7.0
  injectable: ^2.4.2

  # Routing
  go_router: ^14.0.0

  # Networking & Serialization
  dio: ^5.4.3+1
  json_annotation: ^4.9.0

  # Local Database & Storage (Offline-First)
  isar: ^3.1.0+1
  isar_flutter_libs: ^3.1.0+1
  flutter_secure_storage: ^9.2.2

  # Calendar, Dates & Timeline
  table_calendar: ^3.1.2
  intl: ^0.19.0

  # Notifications & Background Tracking
  flutter_local_notifications: ^17.1.2
  workmanager: ^0.5.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.9
  injectable_generator: ^2.6.1
  json_serializable: ^6.8.0
  isar_generator: ^3.1.0+1
  bloc_test: ^9.1.7
  mocktail: ^1.0.4
```

---

## 6. Production Scalability & Offline-First Strategy
1. **Repository Offline-First Cache Policy:**
   - Write: Simpan task ke local database (`Isar`) terlebih dahulu -> kirim ke API. Jika device offline, tandai `sync_status = PENDING_SYNC` dan daftarkan ke queue background sync (`workmanager`).
   - Read: Langsung render dari local cache untuk instant zero-latency UI -> trigger background refresh dari server.
2. **Conflict Resolution:** Menggunakan strategi `Last-Write-Wins` dengan comparing timestamp `updated_at`.
3. **Database Indexing:** Tambahkan index majemuk pada `(user_id, status)` dan `(user_id, start_time, due_time)` di PostgreSQL untuk eksekusi query kalender berkecepatan <10ms.
