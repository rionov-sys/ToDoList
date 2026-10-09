# Chronos - Todo List with Timeline Tracking & Kinetic Focus OS

Aplikasi mobile Task Management & Timeline Tracking modern berbasis **Flutter 3.x / Dart 3.x** dengan pendekatan **Clean Architecture**, **Material Design 3**, dan **Offline-First Resilience**.

---

## 📱 Daftar Layar (Screens Implemented)

1. **Layar Utama (`MainScreen`)**:
   - Navigation Bar bawah dengan notch melengkung untuk Floating Action Button (FAB).
   - Top Header bar dengan branding Chronos, live badge status, dan avatar pengguna.
   - Navigasi antar 5 modul: Tugas, Timeline, Fokus, Kalender, dan Profil.

2. **Layar Autentikasi (`LoginScreen`)**:
   - Segmented Pill Switch ("Masuk" vs "Daftar").
   - Validasi email dan password dengan indikator verifikasi.
   - Tombol Masuk Cepat Mode Offline (Demo Data) untuk pengujian instan.
   - Feedback responsif via animated snackbar dan loading spinner.

3. **Layar Daftar Tugas (`TaskListScreen`)**:
   - Header tanggal dinamis dan momentum harian.
   - **Bento Momentum Card**: Ring progres circular (57%), status On Track, dan 3 metrik (Berjalan, Urgent, Selesai).
   - Search bar real-time dan horizontal category chips filter (Semua, Work, Study, Personal).
   - Kartu tugas dengan border strip prioritas vertikal, checkbox checklist, subtasks count, dan dismissible swipe.

4. **Layar Buat Tugas (`CreateTaskScreen`)**:
   - Input judul tugas dan deskripsi lengkap.
   - Pemilihan kategori dengan badge warna.
   - Pemilihan prioritas: `LOW`, `MEDIUM`, `HIGH`, `URGENT`.
   - Date & Time pickers untuk waktu mulai (`startTime`) dan tenggat waktu (`dueTime`).
   - Dynamic Subtasks builder (tambah dan hapus subtugas).
   - Slider persentase progres awal.

5. **Layar Detail Tugas & Log Timeline (`TaskDetailScreen`)**:
   - Status selector interaktif (`TODO`, `IN_PROGRESS`, `COMPLETED`, `BLOCKED`).
   - Banner jadwal dan countdown deadline.
   - Slider progres dan tombol modal pencatatan log milestone timeline baru.
   - Checklist subtugas interaktif.
   - **Historis Timeline**: Riwayat perubahan status dan progres delta (`progressDelta`).
   - Integrasi tombol cepat **"Mulai Kinetic Focus"** langsung untuk tugas terkait.

6. **Layar Pelacakan Timeline (`TimelineTrackingScreen`)**:
   - Horizontal Weekly Calendar Ribbon (Sen, Sel, Rab, Kam, Jum, Sab, Min) dengan indikator titik tugas.
   - Filter waktu: "Semua", "Pagi", "Siang", "Sore", "Malam".
   - **56px Left Rail & Vertical Spine**: Jalur konektor timeline vertikal (`#E2E8F0`) dengan milestone nodes (Completed emerald, In Progress pulsing indigo halo, Todo ring).
   - Kartu tugas mengalir di sebelah rail dengan rentang jam (`09:00 - 11:30`) dan progress bar.

7. **Layar Kalender & Agenda (`CalendarScreen`)**:
   - Navigasi bulan (Maju/Mundur/Hari Ini).
   - Mode switcher: "Bulan", "Minggu", "Agenda".
   - Banner telemetri sinkronisasi Isar Local DB (Total Tugas, Selesai, Tertunda).
   - Grid kalender interaktif dengan dot indikator jumlah tugas pada tiap tanggal.
   - Agenda harian interaktif untuk tanggal yang dipilih dengan checkbox penyelesaian langsung.

8. **Layar Kinetic Focus OS (`KineticFocusScreen`)**:
   - Binding fokus ke tugas aktif yang sedang dikerjakan.
   - Mode Pomodoro: **Focus (25m)**, **Short Break (5m)**, **Long Break (15m)**.
   - **Kinetic Breathing & Pulsing Circular Timer Animation**: Animasi detak napas cincin halo, countdown digital mono-spaced tabular, dan progress fill.
   - Kontrol Start / Pause / Reset dan pemilih suara ambient (Hujan Deras, Kafe Kopi, White Noise).
   - Statistik fokus harian (Total waktu, Sesi selesai, Efisiensi).

9. **Layar Profil & Pengaturan Akun (`ProfileScreen`)**:
   - Kartu profil pengguna (Avatar inisial, badge Pro Plan, Zona waktu Asia/Jakarta).
   - Telemetri status sinkronisasi & database lokal Isar (Cache footprint, trigger manual sync).
   - Pengaturan notifikasi dan getaran haptic feedback.
   - Dialog konfirmasi keluar akun (Logout) dengan reset state.

---

## 🛠️ State Management & Integrasi Arsitektur

- **State Management:** `Provider` (`ChangeNotifier`) terstruktur dengan pemisahan domain:
  - `AuthProvider` (Sesi login, register, token JWT, logout).
  - `TaskProvider` (CRUD tugas, toggle status, filter kategori, search query, update progress).
  - `TimelineProvider` (Navigasi pita kalender mingguan & filter kronologis).
  - `CalendarProvider` (Navigasi bulan & agenda tanggal terpilih).
  - `FocusTimerProvider` (State machine pomodoro, countdown, telemetry sesi).
- **Networking:** `ApiClient` berbasis `Dio` dengan Base URL, connect/receive timeout, dan interceptor token JWT Bearer.
- **Offline-First Persistence:** `LocalStorageService` (`SharedPreferences` / Isar wrapper) untuk menyimpan tugas, token JWT, user profile, dan queue sinkronisasi offline.
- **Error Handling:** `SnackBarHelper` (Success, Error, Warning, Info) dengan margin mengambang (floating pill), icon visual, dan tombol aksi retry. Ditambah `EmptyStateView` saat data kosong atau hasil pencarian nihil.

---

## 💻 Panduan Perintah Terminal (CLI) di VS Code

Jalankan perintah berikut di terminal VS Code (**PowerShell** atau **Git Bash**) pada direktori proyek:

### 1. Inisialisasi Dependensi
```powershell
flutter pub get
```

### 2. Validasi Kode & Linting (Bebas Peringatan Deprecated)
```powershell
flutter analyze
```

### 3. Menjalankan Unit Test
```powershell
flutter test
```

### 4. Menjalankan Aplikasi Secara Lokal

#### A. Menjalankan di Chrome / Web Browser (Rekomendasi untuk verifikasi cepat di VS Code):
```powershell
flutter run -d chrome
```

#### B. Menjalankan di Windows Desktop:
```powershell
flutter run -d windows
```

#### C. Menjalankan di Android Emulator:
Cek daftar emulator yang tersedia di komputer Anda:
```powershell
flutter emulators
```
Jalankan salah satu emulator:
```powershell
flutter emulators --launch <EMULATOR_ID>
```
Lalu jalankan aplikasi:
```powershell
flutter run
```

---

## 🚀 Migrasi ke Android Studio

Setelah Anda menguji dan puas dengan jalannya aplikasi di VS Code:
1. Buka **Android Studio**.
2. Pilih menu **File > Open...** lalu arahkan ke folder ini:
   `d:\DATA PRIBADI RIO\PROJECT-VIBE CODING\PRODUCTION\ToDoList`
3. Android Studio akan mendeteksi Flutter project secara otomatis dan menjalankan `flutter pub get`.
4. Anda dapat memilih target device / Virtual Device Manager (AVD) di toolbar atas dan menekan tombol hijau **Run (`Shift + F10`)**.
