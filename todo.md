# TODO & Feature Gap Analysis: KerjaKita
Berdasarkan perbandingan antara **Product Requirements Document (PRD v1.0)** dan **Codebase Workspace (`D:\project\flutter\kita_kerja`)**.

---

## 📊 Status Ringkasan Implementasi

| Modul PRD | Status Saat Ini | Catatan Gap Utama |
| :--- | :---: | :--- |
| **6.1 Autentikasi** | 🟢 Selesai (Tahap 1) | Remember Me persisten di local storage; Fitur Ganti Password & Update Profil DB aktif |
| **6.2 Dashboard** | 🟢 Sebagian Besar | KPI dan visualisasi siap; aksi lanjutan rebalancing beban kerja ada di Tahap 3 |
| **6.3 Karyawan** | 🟢 Selesai Penuh | CRUD lengkap, Modal Profil Detail, dan Relasi Supervisor (`employee_supervisors`) aktif |
| **6.4 Kehadiran** | 🟢 Selesai (Tahap 1) | Clock-in/out, Koreksi Presensi Admin, dan Pengajuan Izin/Sakit aktif |
| **6.5 Pekerjaan** | 🟡 Sebagian | CRUD & status makro aktif; Riwayat progres persentase (`task_progress`) di Tahap 2 |
| **6.6 Beban Kerja** | 🟡 Sebagian | Rumus & alert dashboard aktif; Snapshot periodik (`workload_records`) di Tahap 3 |
| **6.7 Gaji (Payroll)** | 🔴 Parsial Ringan | Hanya tabel & slip personal read-only; Generate gaji & kalkulasi lembur di Tahap 2 |
| **6.8 Data Master** | 🟢 Selesai (Tahap 1) | 5 entitas master CRUD selesai; terintegrasi rapi di dalam Tab Menu Pengaturan |
| **Struktur Navigasi** | 🟢 Selesai (Tahap 1) | 5 menu utama sesuai PRD (Dashboard, Karyawan, Kehadiran, Pekerjaan, Pengaturan) |
| **Audit Logs** | 🔴 Belum Ada | Tabel `audit_logs` belum digunakan untuk pencatatan riwayat aktivitas (Tahap 3) |

---

## 📌 Checklist Fitur yang Belum Diimplementasi

### Modul 1: Autentikasi & Keamanan Akun (PRD Sec 4, 5, 6.1, 13)
- [x] **Persistensi "Ingat Saya" (Remember Me)**
  - Integrasi local storage (`shared_preferences`) untuk menyimpan sesi email login agar pengguna tidak perlu input ulang saat aplikasi dibuka kembali.
- [x] **Fitur Ganti Kata Sandi (Keamanan Akun)**
  - Halaman / form ganti kata sandi di Menu Pengaturan dengan validasi password lama, password baru, dan konfirmasi password.
  - Method `changePassword` di `AuthRepository` & `AuthController`.
- [x] **Sinkronisasi Pembaruan Profil ke Database**
  - Form pada `SettingsScreen` (Profil) mengeksekusi update langsung ke tabel `users` dan `employees` di MySQL.

---

### Modul 2: Struktur Navigasi & Modul Pengaturan (PRD Sec 4 & 12)
- [x] **Restrukturisasi Sidebar Utama**
  - Mengubah susunan sidebar menjadi 5 menu utama sesuai spesifikasi PRD:
    1. Dashboard
    2. Karyawan
    3. Kehadiran
    4. Pekerjaan
    5. Pengaturan
- [x] **Halaman / Sub-menu Pengaturan (Settings Hub)**
  - Menggabungkan pengelolaan sistem ke dalam satu hub `SettingsScreen`:
    - Tab 1: **Profil Akun** (Info user & form ubah profil)
    - Tab 2: **Data Master** (Hanya terlihat oleh Admin — Jabatan, Departemen, Kategori, Jenis Gaji, Jadwal Kerja)
    - Tab 3: **Keamanan & Sandi** (Ganti kata sandi & info status sesi)

---

### Modul 3: Manajemen Karyawan & Relasi Supervisor (PRD Sec 3, 5, 6.3 & Tabel 9)
- [x] **Modal / Halaman Detail Lengkap Karyawan (View Profile Detail)**
  - Modal profil lengkap karyawan dengan Neo-brutalism design mencakup avatar, NIK, jabatan, departemen, jadwal kerja, sistem gaji, email, telepon, dan tanggal bergabung.
- [x] **Implementasi Relasi Tim Supervisor (`employee_supervisors`)** *(Tahap 2)*
  - CRUD pemetaan relasi manager/supervisor dengan staf bawahan di tabel `employee_supervisors`.
  - Dropdown pemilihan atasan/supervisor langsung pada `KaryawanFormScreen`.
  - Filter otomatis data Karyawan, Kehadiran, dan Pekerjaan bagi role Manager agar hanya menampilkan tim binaannya sesuai data di `employee_supervisors`.

---

### Modul 4: Manajemen Kehadiran & Presensi (PRD Sec 6.4 & Tabel 10)
- [x] **Fitur Koreksi Kehadiran oleh Admin (Attendance Correction)**
  - UI modal bagi Admin/Manager untuk mengoreksi data presensi (jam masuk, jam pulang, status kehadiran, dan catatan alasan koreksi).
  - Method `correctAttendance` pada `AttendanceRepository` & `AttendanceController` dengan kalkulasi ulang durasi jam kerja dan lembur.
- [x] **Pencatatan & Pengajuan Izin / Sakit / Cuti (Leave & Sick Management)**
  - Modal form pengajuan izin/sakit/cuti dengan input tanggal, pilihan tipe (`sick`/`leave`), dan alasan.
  - Method `submitAbsenceRequest` pada `AttendanceRepository` & `AttendanceController`.
- [ ] **Kalkulasi Jam Kerja & Lembur Berdasarkan `work_schedules`** *(Tahap 2)*
  - Menghitung durasi kerja dan lembur secara dinamis mengacu pada jam masuk/pulang serta toleransi di tabel `work_schedules` (bukan hardcoded 480 menit / 8 jam).

---

### Modul 5: Manajemen Pekerjaan & Riwayat Progres (PRD Sec 6.5 & Tabel 12)
- [ ] **Pencatatan Riwayat Progres Pekerjaan (`task_progress`)** *(Tahap 2)*
  - Model `TaskProgressModel` dan integrasi ke tabel `task_progress`.
  - Input persentase progres aktual (0% – 100%) oleh karyawan saat mengerjakan tugas.
  - Form penambahan catatan/log progres singkat (misal: "Selesai merapikan layout, lanjut styling tombol").
- [ ] **Timeline / Log Riwayat Progres Tugas** *(Tahap 2)*
  - Tampilan riwayat/catatan perkembangan pekerjaan yang dapat ditinjau oleh Admin & Manager sebelum mengubah status tugas menjadi `completed`.

---

### Modul 6: Beban Kerja & Evaluasi Tim (PRD Sec 6.6 & Tabel 13)
- [ ] **Penyimpanan Snapshot Beban Kerja Periodik (`workload_records`)** *(Tahap 3)*
  - Otomasi / fungsi penarikan snapshot beban kerja per periode (mingguan / bulanan) yang tersimpan permanen di tabel `workload_records`.
- [ ] **Aksi Penyeimbangan Beban Kerja (Quick Task Balancing)** *(Tahap 3)*
  - Tombol aksi cepat dari kartu peringatan beban kerja (Overload Alert > 100%) di Dashboard untuk langsung memindahkan atau membagi pekerjaan ke karyawan lain yang beban kerjanya masih di bawah kapasitas (`underload`/`normal`).

---

### Modul 7: Pengelolaan Kompensasi & Payroll / Gaji (PRD Sec 6.7 & Tabel 14)
- [ ] **Fitur Generate Payroll Bulanan Otomatis** *(Tahap 2)*
  - Tombol / aksi bagi Admin untuk melakukan "Generate Gaji Periode Ini" (membuat draft record di tabel `salaries` untuk semua karyawan aktif pada bulan & tahun berjalan).
- [ ] **Form Input / Edit Rincian Gaji** *(Tahap 2)*
  - Modal/layar bagi Admin untuk mengubah nilai `basic_salary`, `bonus_amount`, `deduction_amount`, dan catatan gaji karyawan sebelum disetujui.
- [ ] **Kalkulasi Otomatis Uang Lembur** *(Tahap 2)*
  - Perhitungan otomatis nilai `overtime_amount` berdasarkan akumulasi `overtime_minutes` dari tabel `attendances` pada periode bulan yang bersangkutan dikalikan tarif lembur.
- [ ] **Cetak / Ekspor Slip Gaji** *(Tahap 3)*
  - Tombol cetak atau unduh dokumen slip gaji dalam format bersih / PDF untuk kebutuhan karyawan.

---

### Modul 8: Data Master & Integritas Relasi (PRD Sec 6.8 & 9)
- [ ] **Validasi Proteksi Hapus Data Master (Soft-Delete Guard)** *(Tahap 3)*
  - Validasi pencegahan hapus permanen jika data master (Jabatan, Departemen, Kategori, Jadwal, Jenis Gaji) masih direferensikan oleh karyawan atau pekerjaan aktif.
  - Dialog konfirmasi otomatis menyarankan ubah status menjadi `inactive` daripada penghapusan permanen (sesuai aturan bisnis PRD).

---

### Modul 9: Audit Trail & Riwayat Sistem (PRD Sec 6.8, 11 & Tabel 15)
- [ ] **Pencatatan Aktivitas ke Tabel `audit_logs`** *(Tahap 3)*
  - Service `AuditLogService` untuk mencatat aktivitas penting secara otomatis:
    - Login & logout pengguna.
    - Penambahan / perubahan / deaktivasi karyawan.
    - Perubahan status dan nominal gaji.
    - Koreksi kehadiran dan penghapusan tugas.

---

## 🎯 Rencana Urutan Pengerjaan

### ✅ Tahap 1: Prioritas Tinggi (MVP Core & Usability) - SELESAI
1. **Restrukturisasi Navigasi**: Masukkan Data Master ke dalam menu Pengaturan, rapikan sidebar menjadi 5 menu utama sesuai PRD.
2. **Keamanan Akun & Update Profil**: Ganti kata sandi, persistensi Remember Me (`shared_preferences`), dan sinkronisasi update profil ke database MySQL.
3. **Koreksi Kehadiran & Pengajuan Izin**: Fitur koreksi presensi oleh Admin dan modal pengajuan sakit/izin/cuti.
4. **Detail Karyawan**: Modal detail komprehensif profil karyawan lengkap.

### ⏳ Tahap 2: Prioritas Sedang (Transaksional & Kolaborasi Tim)
5. **Progres Pekerjaan (`task_progress`)**: Input persentase progres dan riwayat catatan log tugas.
6. **Payroll Penuh (`salaries`)**: Generate gaji bulanan, input bonus/potongan, dan kalkulasi lembur dari presensi.
7. ~~**Relasi Supervisor (`employee_supervisors`)**: Penetapan tim binaan manager dan filter presensi/tugas tim.~~ *(Selesai)*
8. **Kalkulasi Jam Kerja Dinamis**: Sesuai toleransi `work_schedules`.

### ⏳ Tahap 3: Prioritas Pelengkap (Stabilitas & Compliance)
9. **Snapshot Beban Kerja (`workload_records`)** & Aksi Rebalance Tugas langsung dari alert dashboard.
10. **Ekspor / Cetak Slip Gaji**.
11. **Audit Logs (`audit_logs`)** & Validasi proteksi hapus data master.
