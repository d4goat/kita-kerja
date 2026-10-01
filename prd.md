**PRODUCT REQUIREMENTS DOCUMENT (PRD)  
KERJAKITA**  
Sistem Manajemen Tenaga Kerja untuk UMKM  
Versi 1.0

# 1\. Ringkasan Produk

KerjaKita adalah aplikasi manajemen tenaga kerja berbasis desktop untuk UMKM. Sistem memusatkan pengelolaan karyawan, kehadiran, pekerjaan, beban kerja, dan informasi gaji dalam satu sistem yang terstruktur.

Konsep utama: Data Master menjadi referensi untuk data Karyawan dan transaksi Pekerjaan/Kehadiran, kemudian data tersebut digunakan untuk menghitung beban kerja dan menyajikan informasi pada Dashboard.

# 2\. Tujuan Produk

- Memusatkan data tenaga kerja dalam satu sistem.
- Memudahkan pengelolaan dan pemantauan kehadiran.
- Membantu pembagian dan pemantauan pekerjaan.
- Memberikan gambaran beban kerja setiap karyawan.
- Menyediakan informasi gaji secara terstruktur.
- Menyediakan data untuk evaluasi pembagian pekerjaan dan kondisi kerja.

# 3\. Role Pengguna

- Admin / Owner — mengelola sistem, data karyawan, konfigurasi, transaksi, dan keseluruhan data usaha.
- Manager / Supervisor — mengawasi tim, pekerjaan, kehadiran, dan beban kerja dengan akses konfigurasi terbatas.
- Karyawan — menjalankan pekerjaan, mencatat kehadiran, memperbarui progres, dan melihat data miliknya sendiri.

# 4\. Struktur Navigasi

- Dashboard
- Karyawan
- Kehadiran
- Pekerjaan
- Pengaturan

Di dalam Pengaturan:

- Profil
- Data Master
- Keamanan

Data Master:

- Jabatan
- Departemen
- Kategori Pekerjaan
- Jenis Gaji
- Jadwal Kerja

# 5\. Hak Akses Role

| Fitur       | Admin / Owner | Manager / Supervisor  | Karyawan          |
| ----------- | ------------- | --------------------- | ----------------- |
| Dashboard   | Full          | View                  | View              |
| Karyawan    | Full          | View tim              | Data sendiri      |
| Kehadiran   | Full          | View/Review           | Data sendiri      |
| Pekerjaan   | Full          | Full                  | Pekerjaan sendiri |
| Beban Kerja | Full          | Full                  | Data sendiri      |
| Gaji        | Full          | View sesuai kebutuhan | Data sendiri      |
| Data Master | Full          | View                  | Tidak akses       |
| Profil      | Data sendiri  | Data sendiri          | Data sendiri      |
| Keamanan    | Full          | Akun sendiri          | Akun sendiri      |

# 6\. Functional Requirements

## 6.1 Autentikasi

- Pengguna wajib login sebelum mengakses aplikasi.
- Login menggunakan email dan kata sandi.
- Tersedia Register, Lupa Kata Sandi, Ingat Saya, dan Logout.
- Setelah login, pengguna diarahkan ke Dashboard sesuai role.

## 6.2 Dashboard

- Dashboard menampilkan informasi sesuai role.
- Admin melihat kondisi keseluruhan usaha.
- Manager melihat kondisi timnya.
- Karyawan melihat aktivitas pribadi.
- KPI dapat mencakup Total Karyawan, Hadir Hari Ini, Pekerjaan Aktif, dan Lembur.
- Dashboard dapat memberi peringatan ketika beban kerja melebihi kapasitas.

## 6.3 Karyawan

- Admin dapat menambah, mengubah, melihat detail, dan menonaktifkan karyawan.
- Manager dapat melihat karyawan dalam timnya.
- Karyawan hanya dapat mengakses profilnya sendiri.
- Data karyawan menggunakan referensi Jabatan, Departemen, Jenis Gaji, dan Jadwal Kerja.
- Field minimal: nama, email, telepon, jabatan, departemen, jenis gaji, jadwal kerja, tanggal bergabung, dan status.

## 6.4 Kehadiran

- Karyawan dapat Masuk Kerja dan Pulang Kerja.
- Sistem menyimpan tanggal, waktu masuk, waktu keluar, durasi kerja, dan lembur.
- Admin dapat melihat dan mengoreksi kehadiran.
- Manager dapat memantau kehadiran tim.
- Karyawan hanya melihat riwayatnya sendiri.
- Perhitungan jam kerja mengikuti Jadwal Kerja.

## 6.5 Pekerjaan

- Pekerjaan memiliki judul, deskripsi, kategori, prioritas, penanggung jawab, estimasi jam, deadline, dan status.
- Status: Belum Mulai → Sedang Dikerjakan → Ditinjau → Selesai.
- Admin/Manager dapat membuat dan menugaskan pekerjaan sesuai hak akses.
- Karyawan dapat melihat pekerjaan yang ditugaskan dan memperbarui progres.

## 6.6 Beban Kerja

- Beban kerja dihitung dari pekerjaan dibandingkan kapasitas kerja.
- Contoh: 9 jam pekerjaan / 8 jam kapasitas = 112,5%.
- Beban di atas kapasitas ditampilkan sebagai peringatan.
- Admin/Manager dapat menggunakan data untuk mengevaluasi pembagian pekerjaan.
- Karyawan dapat melihat ringkasan beban kerjanya.

## 6.7 Gaji

- Komponen dapat mencakup gaji pokok, lembur, bonus, potongan, dan gaji bersih.
- Admin memiliki akses penuh.
- Manager hanya melihat data yang dibutuhkan proses bisnis.
- Karyawan hanya melihat informasi gajinya sendiri.

## 6.8 Data Master

- Hanya Admin/Owner yang mengelola Data Master.
- Jabatan → digunakan Karyawan.
- Departemen → mengelompokkan Karyawan.
- Kategori Pekerjaan → digunakan Pekerjaan.
- Jenis Gaji → digunakan data kompensasi.
- Jadwal Kerja → menjadi acuan Kehadiran dan kapasitas kerja.
- Data master yang sudah digunakan sebaiknya dinonaktifkan, bukan dihapus permanen.

# 7\. Alur Kerja Utama Sistem

1. Login → pengguna masuk sesuai role.
2. Setup → Admin mengatur Data Master.
3. Karyawan → Admin memasukkan karyawan dan referensinya.
4. Pekerjaan → Admin/Manager membuat pekerjaan dan menentukan penanggung jawab.
5. Kehadiran → Karyawan melakukan clock-in dan clock-out.
6. Pelaksanaan → Karyawan mengerjakan tugas dan memperbarui status.
7. Beban Kerja → Sistem menghitung beban berdasarkan pekerjaan dan kapasitas.
8. Gaji → Sistem mengolah gaji pokok, lembur, bonus, dan potongan.
9. Monitoring → Admin/Manager memantau Dashboard, Kehadiran, Pekerjaan, dan Beban Kerja.
10. Evaluasi → Pengelola meninjau pembagian pekerjaan dan kondisi kerja.

# 8\. Alur Berdasarkan Role

## 8.1 Admin / Owner

1. Login
2. Melihat Dashboard
3. Mengatur Data Master
4. Mengelola Karyawan
5. Mengelola Pekerjaan
6. Memantau Kehadiran
7. Melihat Beban Kerja
8. Mengelola Gaji
9. Melakukan evaluasi
10. Logout

## 8.2 Manager / Supervisor

1. Login
2. Melihat Dashboard tim
3. Melihat karyawan dalam tim
4. Membuat/mengatur Pekerjaan
5. Memantau Kehadiran
6. Memantau Beban Kerja
7. Meninjau pekerjaan
8. Mengevaluasi pembagian pekerjaan
9. Logout

## 8.3 Karyawan

1. Login
2. Melihat Dashboard pribadi
3. Masuk Kerja
4. Melihat pekerjaan
5. Mengerjakan dan memperbarui status
6. Pulang Kerja
7. Melihat riwayat Kehadiran
8. Melihat Beban Kerja dan Gaji pribadi
9. Mengelola Profil/Keamanan
10. Logout

# 9\. Aturan Bisnis

| Aturan           | Ketentuan                                                              |
| ---------------- | ---------------------------------------------------------------------- |
| Akun             | Akun nonaktif tidak dapat login.                                       |
| Karyawan         | Karyawan nonaktif tidak dapat menerima pekerjaan baru.                 |
| Pekerjaan        | Pekerjaan harus memiliki penanggung jawab dan deadline.                |
| Status pekerjaan | Belum Mulai → Sedang Dikerjakan → Ditinjau → Selesai.                  |
| Kehadiran        | Clock-out dilakukan setelah clock-in sesuai aturan sistem.             |
| Beban kerja      | Beban kerja dibandingkan dengan kapasitas kerja pada periode tertentu. |
| Data Master      | Data yang sudah digunakan sebaiknya dinonaktifkan, bukan dihapus.      |
| Akses            | Pengguna tidak boleh mengakses data di luar cakupan role.              |

# 10\. Alur Data

Data Master → Karyawan → Pekerjaan + Kehadiran → Beban Kerja → Gaji → Dashboard / Evaluasi

Ini adalah hubungan proses bisnis, bukan urutan menu yang wajib dibuka. Pekerjaan dan Kehadiran berjalan paralel selama periode kerja.

# 11\. Non-Functional Requirements

- Usability: mudah dipahami pengguna UMKM dan menggunakan Bahasa Indonesia.
- Performance: operasi data umum harus responsif.
- Security: password disimpan aman dan akses dibatasi berdasarkan role.
- Reliability: transaksi Kehadiran dan Pekerjaan tersimpan konsisten.
- Maintainability: modul dan permission mudah dikembangkan.
- Consistency: format tanggal, waktu, status, dan UI konsisten.
- Accessibility: kontras memadai, teks terbaca, dan status tidak hanya dibedakan dengan warna.

# 12\. Ketentuan UI/UX

- Gaya: Professional Neo-Brutalism.
- Target: desktop 1366×768 atau 1440×900.
- Background #F5F1E8; teks/border #111111; primary #315CFF; secondary #F5C542; success #35C759; danger #FF5A5F.
- Gunakan border tegas, offset shadow ringan, tipografi bold, dan bentuk geometris sederhana.
- Hindari glassmorphism, neon, gradient berlebihan, dekorasi berlebihan, dan terlalu banyak card.
- Sidebar hanya: Dashboard, Karyawan, Kehadiran, Pekerjaan, Pengaturan.
- Profil dan Logout melalui avatar di kanan atas.
- Data Master berada di Pengaturan agar navigasi tidak padat.
- Gunakan data contoh yang sedikit dan realistis.

# 13\. Scope MVP

Termasuk:

- Autentikasi dan RBAC
- Dashboard per role
- CRUD/detail Karyawan
- Pencatatan Kehadiran
- Manajemen Pekerjaan
- Beban Kerja
- Informasi Gaji
- Data Master
- Profil, keamanan akun, dan logout

Pengembangan berikutnya:

- Integrasi fingerprint
- Integrasi pembayaran gaji
- Notifikasi WhatsApp/email
- Mobile app
- AI prediksi beban kerja
- Analitik lanjutan

# 14\. Keterkaitan dengan SDG 8

KerjaKita mendukung konteks SDG 8 melalui digitalisasi pengelolaan tenaga kerja, pencatatan kehadiran, pemantauan beban kerja, pengelolaan pekerjaan, dan transparansi informasi kompensasi. Sistem menyediakan data dan struktur proses yang dapat membantu pengelola memantau kondisi tenaga kerja dan memperbaiki proses kerja.

# 15\. Kriteria Keberhasilan MVP

- Tiga role dapat login dan hanya mengakses fitur yang diizinkan.
- Admin dapat menyiapkan Data Master dan Karyawan.
- Pekerjaan dapat dibuat, ditugaskan, dan dipantau.
- Karyawan dapat mencatat masuk dan pulang kerja.
- Jam kerja dan lembur dapat ditampilkan.
- Beban kerja dapat dihitung dan ditampilkan.
- Gaji dapat ditampilkan sesuai hak akses.
- Dashboard menampilkan ringkasan yang relevan per role.
- Relasi antar data menggunakan referensi yang konsisten.

# DB SQL QUERY

-- =========================================================
-- DATABASE KERJAKITA
-- Sistem Manajemen Tenaga Kerja UMKM
-- DBMS : MySQL 8.x
-- =========================================================

DROP DATABASE IF EXISTS kerjakita;
CREATE DATABASE kerjakita
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE kerjakita;

-- =========================================================
-- 1. ROLES
-- =========================================================

CREATE TABLE roles (
id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(50) NOT NULL UNIQUE,
description VARCHAR(255) NULL,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
ON UPDATE CURRENT_TIMESTAMP
);

-- =========================================================
-- 2. USERS
-- Akun untuk login ke sistem
-- =========================================================

CREATE TABLE users (
id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    role_id BIGINT UNSIGNED NOT NULL,

    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,

    phone VARCHAR(20) NULL,

    status ENUM('active', 'inactive') NOT NULL DEFAULT 'active',

    last_login_at DATETIME NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_users_role
        FOREIGN KEY (role_id)
        REFERENCES roles(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT

);

-- =========================================================
-- 3. DEPARTMENTS
-- Master Data: Departemen
-- =========================================================

CREATE TABLE departments (
id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(255) NULL,

    status ENUM('active', 'inactive') NOT NULL DEFAULT 'active',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP

);

-- =========================================================
-- 4. POSITIONS
-- Master Data: Jabatan
-- =========================================================

CREATE TABLE positions (
id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(255) NULL,

    status ENUM('active', 'inactive') NOT NULL DEFAULT 'active',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP

);

-- =========================================================
-- 5. JOB CATEGORIES
-- Master Data: Kategori Pekerjaan
-- =========================================================

CREATE TABLE job_categories (
id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(255) NULL,

    status ENUM('active', 'inactive') NOT NULL DEFAULT 'active',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP

);

-- =========================================================
-- 6. SALARY TYPES
-- Master Data: Jenis Gaji
-- =========================================================

CREATE TABLE salary_types (
id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(255) NULL,

    status ENUM('active', 'inactive') NOT NULL DEFAULT 'active',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP

);

-- =========================================================
-- 7. WORK SCHEDULES
-- Master Data: Jadwal Kerja
-- =========================================================

CREATE TABLE work_schedules (
id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    name VARCHAR(100) NOT NULL UNIQUE,

    start_time TIME NOT NULL,
    end_time TIME NOT NULL,

    break_minutes INT UNSIGNED NOT NULL DEFAULT 0,

    working_hours DECIMAL(5,2) NOT NULL,

    status ENUM('active', 'inactive') NOT NULL DEFAULT 'active',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP

);

-- =========================================================
-- 8. EMPLOYEES
-- Data utama karyawan
-- =========================================================

CREATE TABLE employees (
id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    user_id BIGINT UNSIGNED NULL,

    employee_code VARCHAR(30) NOT NULL UNIQUE,

    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(150) NULL,
    phone VARCHAR(20) NULL,

    position_id BIGINT UNSIGNED NOT NULL,
    department_id BIGINT UNSIGNED NOT NULL,
    salary_type_id BIGINT UNSIGNED NOT NULL,
    work_schedule_id BIGINT UNSIGNED NOT NULL,

    join_date DATE NOT NULL,

    status ENUM('active', 'inactive') NOT NULL DEFAULT 'active',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_employees_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    CONSTRAINT fk_employees_position
        FOREIGN KEY (position_id)
        REFERENCES positions(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_employees_department
        FOREIGN KEY (department_id)
        REFERENCES departments(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_employees_salary_type
        FOREIGN KEY (salary_type_id)
        REFERENCES salary_types(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_employees_work_schedule
        FOREIGN KEY (work_schedule_id)
        REFERENCES work_schedules(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT

);

-- =========================================================
-- 9. EMPLOYEE SUPERVISORS
-- Relasi Manager -> Karyawan
-- =========================================================

CREATE TABLE employee_supervisors (
id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    employee_id BIGINT UNSIGNED NOT NULL,
    supervisor_id BIGINT UNSIGNED NOT NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE KEY unique_employee_supervisor (
        employee_id,
        supervisor_id
    ),

    CONSTRAINT fk_employee_supervisor_employee
        FOREIGN KEY (employee_id)
        REFERENCES employees(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_employee_supervisor_supervisor
        FOREIGN KEY (supervisor_id)
        REFERENCES employees(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE

);

-- =========================================================
-- 10. ATTENDANCES
-- Kehadiran karyawan
-- =========================================================

CREATE TABLE attendances (
id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    employee_id BIGINT UNSIGNED NOT NULL,

    attendance_date DATE NOT NULL,

    clock_in DATETIME NULL,
    clock_out DATETIME NULL,

    working_minutes INT UNSIGNED NOT NULL DEFAULT 0,
    overtime_minutes INT UNSIGNED NOT NULL DEFAULT 0,

    status ENUM(
        'present',
        'late',
        'absent',
        'leave',
        'sick'
    ) NOT NULL DEFAULT 'present',

    notes VARCHAR(255) NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY unique_employee_attendance (
        employee_id,
        attendance_date
    ),

    CONSTRAINT fk_attendances_employee
        FOREIGN KEY (employee_id)
        REFERENCES employees(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE

);

-- =========================================================
-- 11. TASKS / PEKERJAAN
-- =========================================================

CREATE TABLE tasks (
id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    category_id BIGINT UNSIGNED NOT NULL,

    created_by BIGINT UNSIGNED NOT NULL,
    assigned_to BIGINT UNSIGNED NOT NULL,

    title VARCHAR(150) NOT NULL,
    description TEXT NULL,

    priority ENUM(
        'low',
        'medium',
        'high',
        'urgent'
    ) NOT NULL DEFAULT 'medium',

    status ENUM(
        'not_started',
        'in_progress',
        'review',
        'completed'
    ) NOT NULL DEFAULT 'not_started',

    estimated_hours DECIMAL(6,2) NOT NULL DEFAULT 0,
    actual_hours DECIMAL(6,2) NOT NULL DEFAULT 0,

    start_date DATE NULL,
    deadline DATE NOT NULL,
    completed_at DATETIME NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_tasks_category
        FOREIGN KEY (category_id)
        REFERENCES job_categories(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_tasks_created_by
        FOREIGN KEY (created_by)
        REFERENCES users(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_tasks_assigned_to
        FOREIGN KEY (assigned_to)
        REFERENCES employees(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT

);

-- =========================================================
-- 12. TASK PROGRESS
-- Riwayat progres pekerjaan
-- =========================================================

CREATE TABLE task_progress (
id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    task_id BIGINT UNSIGNED NOT NULL,
    employee_id BIGINT UNSIGNED NOT NULL,

    status ENUM(
        'not_started',
        'in_progress',
        'review',
        'completed'
    ) NOT NULL,

    progress_percentage TINYINT UNSIGNED NOT NULL DEFAULT 0,

    notes TEXT NULL,

    recorded_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_task_progress_task
        FOREIGN KEY (task_id)
        REFERENCES tasks(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_task_progress_employee
        FOREIGN KEY (employee_id)
        REFERENCES employees(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT chk_task_progress_percentage
        CHECK (progress_percentage <= 100)

);

-- =========================================================
-- 13. WORKLOAD RECORDS
-- Data snapshot beban kerja
-- =========================================================

CREATE TABLE workload_records (
id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    employee_id BIGINT UNSIGNED NOT NULL,

    period_start DATE NOT NULL,
    period_end DATE NOT NULL,

    capacity_hours DECIMAL(8,2) NOT NULL DEFAULT 0,
    assigned_hours DECIMAL(8,2) NOT NULL DEFAULT 0,
    actual_hours DECIMAL(8,2) NOT NULL DEFAULT 0,

    workload_percentage DECIMAL(6,2) NOT NULL DEFAULT 0,

    status ENUM(
        'underload',
        'normal',
        'high',
        'overload'
    ) NOT NULL DEFAULT 'normal',

    notes VARCHAR(255) NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY unique_employee_workload_period (
        employee_id,
        period_start,
        period_end
    ),

    CONSTRAINT fk_workload_employee
        FOREIGN KEY (employee_id)
        REFERENCES employees(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE

);

-- =========================================================
-- 14. SALARIES
-- Informasi gaji / payroll sederhana
-- =========================================================

CREATE TABLE salaries (
id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    employee_id BIGINT UNSIGNED NOT NULL,

    period_month TINYINT UNSIGNED NOT NULL,
    period_year SMALLINT UNSIGNED NOT NULL,

    basic_salary DECIMAL(15,2) NOT NULL DEFAULT 0,
    overtime_amount DECIMAL(15,2) NOT NULL DEFAULT 0,
    bonus_amount DECIMAL(15,2) NOT NULL DEFAULT 0,
    deduction_amount DECIMAL(15,2) NOT NULL DEFAULT 0,

    net_salary DECIMAL(15,2)
        GENERATED ALWAYS AS (
            basic_salary
            + overtime_amount
            + bonus_amount
            - deduction_amount
        ) STORED,

    status ENUM(
        'draft',
        'processed',
        'paid'
    ) NOT NULL DEFAULT 'draft',

    notes VARCHAR(255) NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY unique_employee_salary_period (
        employee_id,
        period_month,
        period_year
    ),

    CONSTRAINT fk_salaries_employee
        FOREIGN KEY (employee_id)
        REFERENCES employees(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT chk_salary_month
        CHECK (period_month BETWEEN 1 AND 12)

);

-- =========================================================
-- 15. AUDIT LOGS
-- Opsional tetapi berguna untuk mencatat aktivitas penting
-- =========================================================

CREATE TABLE audit_logs (
id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    user_id BIGINT UNSIGNED NULL,

    action VARCHAR(100) NOT NULL,
    table_name VARCHAR(100) NULL,
    record_id BIGINT UNSIGNED NULL,

    description TEXT NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_audit_logs_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL

);

-- =========================================================
-- INDEX
-- =========================================================

CREATE INDEX idx_employees_department
ON employees(department_id);

CREATE INDEX idx_employees_position
ON employees(position_id);

CREATE INDEX idx_attendances_date
ON attendances(attendance_date);

CREATE INDEX idx_attendances_employee_date
ON attendances(employee_id, attendance_date);

CREATE INDEX idx_tasks_assigned_to
ON tasks(assigned_to);

CREATE INDEX idx_tasks_status
ON tasks(status);

CREATE INDEX idx_tasks_deadline
ON tasks(deadline);

CREATE INDEX idx_workload_employee
ON workload_records(employee_id);

CREATE INDEX idx_salaries_period
ON salaries(period_year, period_month);

-- =========================================================
-- DEFAULT ROLE
-- =========================================================

INSERT INTO roles (name, description) VALUES
('admin', 'Pemilik atau administrator sistem'),
('manager', 'Manager atau supervisor tim'),
('employee', 'Karyawan');

-- =========================================================
-- CONTOH DATA MASTER
-- Data dibuat sedikit sesuai requirement UI
-- =========================================================

INSERT INTO departments (name, description) VALUES
('Operasional', 'Tim operasional perusahaan'),
('Pemasaran', 'Tim pemasaran dan promosi'),
('Teknologi', 'Tim teknologi dan pengembangan sistem');

INSERT INTO positions (name, description) VALUES
('Owner', 'Pemilik usaha'),
('Supervisor', 'Pengawas tim'),
('Staff', 'Staf pelaksana');

INSERT INTO job_categories (name, description) VALUES
('Operasional', 'Pekerjaan operasional harian'),
('Administrasi', 'Pekerjaan administrasi'),
('Teknologi', 'Pekerjaan yang berkaitan dengan teknologi');

INSERT INTO salary_types (name, description) VALUES
('Bulanan', 'Gaji berdasarkan periode bulanan'),
('Harian', 'Gaji berdasarkan hari kerja'),
('Kontrak', 'Gaji berdasarkan kontrak kerja');

INSERT INTO work_schedules (
name,
start_time,
end_time,
break_minutes,
working_hours
) VALUES
(
'Jam Kerja Normal',
'08:00:00',
'17:00:00',
60,
8.00
),
(
'Shift Pagi',
'07:00:00',
'15:00:00',
60,
7.00
);

-- =========================================================
-- SELESAI
-- =========================================================

## DB SQL QUERY FOR DATA

USE kerjakita;

START TRANSACTION;

-- =========================================================
-- 1. USERS
-- Password hash di bawah adalah bcrypt untuk plaintext: password
-- =========================================================
INSERT INTO users (role_id, name, email, password, phone, status)
VALUES
(
(SELECT id FROM roles WHERE name = 'admin'),
'Admin KerjaKita',
'admin@kerjakita.local',
'$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
'081234567890',
'active'
),
(
(SELECT id FROM roles WHERE name = 'manager'),
'Budi Manager',
'manager@kerjakita.local',
'$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
'081234567891',
'active'
),
(
(SELECT id FROM roles WHERE name = 'employee'),
'Citra Staff',
'citra@kerjakita.local',
'$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
'081234567892',
'active'
),
(
(SELECT id FROM roles WHERE name = 'employee'),
'Dedi Staff',
'dedi@kerjakita.local',
'$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
'081234567893',
'active'
),
(
(SELECT id FROM roles WHERE name = 'employee'),
'Eka Staff',
'eka@kerjakita.local',
'$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
'081234567894',
'active'
),
(
(SELECT id FROM roles WHERE name = 'employee'),
'Fajar Staff',
'fajar@kerjakita.local',
'$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
'081234567895',
'active'
);

-- =========================================================
-- 2. EMPLOYEES
-- =========================================================
INSERT INTO employees (
user_id,
employee_code,
full_name,
email,
phone,
position_id,
department_id,
salary_type_id,
work_schedule_id,
join_date,
status
)
VALUES
(
(SELECT id FROM users WHERE email = 'admin@kerjakita.local'),
'EMP001',
'Admin KerjaKita',
'admin@kerjakita.local',
'081234567890',
(SELECT id FROM positions WHERE name = 'Owner'),
(SELECT id FROM departments WHERE name = 'Operasional'),
(SELECT id FROM salary_types WHERE name = 'Bulanan'),
(SELECT id FROM work_schedules WHERE name = 'Jam Kerja Normal'),
'2024-01-01',
'active'
),
(
(SELECT id FROM users WHERE email = 'manager@kerjakita.local'),
'EMP002',
'Budi Manager',
'manager@kerjakita.local',
'081234567891',
(SELECT id FROM positions WHERE name = 'Supervisor'),
(SELECT id FROM departments WHERE name = 'Operasional'),
(SELECT id FROM salary_types WHERE name = 'Bulanan'),
(SELECT id FROM work_schedules WHERE name = 'Jam Kerja Normal'),
'2024-02-01',
'active'
),
(
(SELECT id FROM users WHERE email = 'citra@kerjakita.local'),
'EMP003',
'Citra Staff',
'citra@kerjakita.local',
'081234567892',
(SELECT id FROM positions WHERE name = 'Staff'),
(SELECT id FROM departments WHERE name = 'Operasional'),
(SELECT id FROM salary_types WHERE name = 'Bulanan'),
(SELECT id FROM work_schedules WHERE name = 'Jam Kerja Normal'),
'2024-03-01',
'active'
),
(
(SELECT id FROM users WHERE email = 'dedi@kerjakita.local'),
'EMP004',
'Dedi Staff',
'dedi@kerjakita.local',
'081234567893',
(SELECT id FROM positions WHERE name = 'Staff'),
(SELECT id FROM departments WHERE name = 'Pemasaran'),
(SELECT id FROM salary_types WHERE name = 'Bulanan'),
(SELECT id FROM work_schedules WHERE name = 'Shift Pagi'),
'2024-04-01',
'active'
),
(
(SELECT id FROM users WHERE email = 'eka@kerjakita.local'),
'EMP005',
'Eka Staff',
'eka@kerjakita.local',
'081234567894',
(SELECT id FROM positions WHERE name = 'Staff'),
(SELECT id FROM departments WHERE name = 'Teknologi'),
(SELECT id FROM salary_types WHERE name = 'Bulanan'),
(SELECT id FROM work_schedules WHERE name = 'Jam Kerja Normal'),
'2024-05-01',
'active'
),
(
(SELECT id FROM users WHERE email = 'fajar@kerjakita.local'),
'EMP006',
'Fajar Staff',
'fajar@kerjakita.local',
'081234567895',
(SELECT id FROM positions WHERE name = 'Staff'),
(SELECT id FROM departments WHERE name = 'Teknologi'),
(SELECT id FROM salary_types WHERE name = 'Kontrak'),
(SELECT id FROM work_schedules WHERE name = 'Jam Kerja Normal'),
'2024-06-01',
'active'
);

-- =========================================================
-- 3. EMPLOYEE SUPERVISORS
-- =========================================================
INSERT INTO employee_supervisors (employee_id, supervisor_id)
VALUES
(
(SELECT id FROM employees WHERE employee_code = 'EMP002'),
(SELECT id FROM employees WHERE employee_code = 'EMP001')
),
(
(SELECT id FROM employees WHERE employee_code = 'EMP003'),
(SELECT id FROM employees WHERE employee_code = 'EMP002')
),
(
(SELECT id FROM employees WHERE employee_code = 'EMP004'),
(SELECT id FROM employees WHERE employee_code = 'EMP002')
),
(
(SELECT id FROM employees WHERE employee_code = 'EMP005'),
(SELECT id FROM employees WHERE employee_code = 'EMP002')
),
(
(SELECT id FROM employees WHERE employee_code = 'EMP006'),
(SELECT id FROM employees WHERE employee_code = 'EMP002')
);

-- =========================================================
-- 4. ATTENDANCES
-- =========================================================
INSERT INTO attendances (
employee_id,
attendance_date,
clock_in,
clock_out,
working_minutes,
overtime_minutes,
status,
notes
)
VALUES
(
(SELECT id FROM employees WHERE employee_code = 'EMP003'),
'2026-09-01',
'2026-09-01 08:00:00',
'2026-09-01 17:00:00',
480,
0,
'present',
NULL
),
(
(SELECT id FROM employees WHERE employee_code = 'EMP003'),
'2026-09-02',
'2026-09-02 08:15:00',
'2026-09-02 17:00:00',
465,
0,
'late',
'Terlambat 15 menit'
),
(
(SELECT id FROM employees WHERE employee_code = 'EMP004'),
'2026-09-01',
'2026-09-01 07:00:00',
'2026-09-01 15:00:00',
420,
0,
'present',
NULL
),
(
(SELECT id FROM employees WHERE employee_code = 'EMP004'),
'2026-09-02',
NULL,
NULL,
0,
0,
'sick',
'Surat dokter'
),
(
(SELECT id FROM employees WHERE employee_code = 'EMP005'),
'2026-09-01',
'2026-09-01 08:05:00',
'2026-09-01 18:00:00',
535,
55,
'present',
'Lembur 55 menit'
),
(
(SELECT id FROM employees WHERE employee_code = 'EMP005'),
'2026-09-02',
'2026-09-02 08:00:00',
'2026-09-02 17:00:00',
480,
0,
'present',
NULL
),
(
(SELECT id FROM employees WHERE employee_code = 'EMP006'),
'2026-09-01',
NULL,
NULL,
0,
0,
'leave',
'Cuti tahunan'
),
(
(SELECT id FROM employees WHERE employee_code = 'EMP006'),
'2026-09-02',
'2026-09-02 08:00:00',
'2026-09-02 17:00:00',
480,
0,
'present',
NULL
);

-- =========================================================
-- 5. TASKS
-- =========================================================
INSERT INTO tasks (
category_id,
created_by,
assigned_to,
title,
description,
priority,
status,
estimated_hours,
actual_hours,
start_date,
deadline,
completed_at
)
VALUES
(
(SELECT id FROM job_categories WHERE name = 'Operasional'),
(SELECT id FROM users WHERE email = 'admin@kerjakita.local'),
(SELECT id FROM employees WHERE employee_code = 'EMP003'),
'Input data penjualan harian',
'Memasukkan data penjualan ke spreadsheet',
'high',
'in_progress',
8.00,
4.00,
'2026-09-01',
'2026-09-05',
NULL
),
(
(SELECT id FROM job_categories WHERE name = 'Administrasi'),
(SELECT id FROM users WHERE email = 'manager@kerjakita.local'),
(SELECT id FROM employees WHERE employee_code = 'EMP004'),
'Buat konten promosi Instagram',
'Membuat 3 desain konten untuk minggu ini',
'medium',
'review',
6.00,
6.00,
'2026-09-01',
'2026-09-03',
NULL
),
(
(SELECT id FROM job_categories WHERE name = 'Teknologi'),
(SELECT id FROM users WHERE email = 'manager@kerjakita.local'),
(SELECT id FROM employees WHERE employee_code = 'EMP005'),
'Perbaiki bug halaman login',
'Bug validasi email tidak muncul',
'urgent',
'completed',
10.00,
12.00,
'2026-08-28',
'2026-09-01',
'2026-09-01 16:30:00'
),
(
(SELECT id FROM job_categories WHERE name = 'Teknologi'),
(SELECT id FROM users WHERE email = 'admin@kerjakita.local'),
(SELECT id FROM employees WHERE employee_code = 'EMP006'),
'Setup backup database mingguan',
'Membuat script backup otomatis',
'high',
'not_started',
5.00,
0.00,
'2026-09-03',
'2026-09-07',
NULL
);

-- =========================================================
-- 6. TASK PROGRESS
-- =========================================================
INSERT INTO task_progress (
task_id,
employee_id,
status,
progress_percentage,
notes,
recorded_at
)
VALUES
(
(SELECT id FROM tasks WHERE title = 'Input data penjualan harian' LIMIT 1),
(SELECT id FROM employees WHERE employee_code = 'EMP003'),
'in_progress',
50,
'Data penjualan tanggal 1-2 sudah diinput',
'2026-09-02 10:00:00'
),
(
(SELECT id FROM tasks WHERE title = 'Buat konten promosi Instagram' LIMIT 1),
(SELECT id FROM employees WHERE employee_code = 'EMP004'),
'review',
100,
'Menunggu review manager',
'2026-09-02 14:00:00'
),
(
(SELECT id FROM tasks WHERE title = 'Perbaiki bug halaman login' LIMIT 1),
(SELECT id FROM employees WHERE employee_code = 'EMP005'),
'completed',
100,
'Bug sudah diperbaiki dan dites',
'2026-09-01 16:30:00'
),
(
(SELECT id FROM tasks WHERE title = 'Setup backup database mingguan' LIMIT 1),
(SELECT id FROM employees WHERE employee_code = 'EMP006'),
'not_started',
0,
'Belum mulai',
'2026-09-03 08:00:00'
);

-- =========================================================
-- 7. WORKLOAD RECORDS
-- =========================================================
INSERT INTO workload_records (
employee_id,
period_start,
period_end,
capacity_hours,
assigned_hours,
actual_hours,
workload_percentage,
status,
notes
)
VALUES
(
(SELECT id FROM employees WHERE employee_code = 'EMP003'),
'2026-09-01',
'2026-09-30',
160.00,
120.00,
80.00,
75.00,
'normal',
'Beban kerja normal'
),
(
(SELECT id FROM employees WHERE employee_code = 'EMP004'),
'2026-09-01',
'2026-09-30',
160.00,
180.00,
150.00,
112.50,
'high',
'Perlu penambahan tenaga'
),
(
(SELECT id FROM employees WHERE employee_code = 'EMP005'),
'2026-09-01',
'2026-09-30',
160.00,
140.00,
140.00,
87.50,
'normal',
'Sesuai kapasitas'
),
(
(SELECT id FROM employees WHERE employee_code = 'EMP006'),
'2026-09-01',
'2026-09-30',
160.00,
60.00,
20.00,
37.50,
'underload',
'Bisa ditambah tugas'
);

-- =========================================================
-- 8. SALARIES
-- net_salary otomatis dari generated column
-- =========================================================
INSERT INTO salaries (
employee_id,
period_month,
period_year,
basic_salary,
overtime_amount,
bonus_amount,
deduction_amount,
status,
notes
)
VALUES
(
(SELECT id FROM employees WHERE employee_code = 'EMP003'),
9,
2026,
4500000.00,
0.00,
250000.00,
50000.00,
'processed',
'Gaji September 2026'
),
(
(SELECT id FROM employees WHERE employee_code = 'EMP004'),
9,
2026,
4500000.00,
0.00,
100000.00,
0.00,
'draft',
'Menunggu approval'
),
(
(SELECT id FROM employees WHERE employee_code = 'EMP005'),
9,
2026,
5000000.00,
150000.00,
300000.00,
100000.00,
'paid',
'Sudah ditransfer'
),
(
(SELECT id FROM employees WHERE employee_code = 'EMP006'),
9,
2026,
4000000.00,
0.00,
0.00,
0.00,
'draft',
'Kontrak'
);

-- =========================================================
-- 9. AUDIT LOGS
-- =========================================================
INSERT INTO audit_logs (
user_id,
action,
table_name,
record_id,
description
)
VALUES
(
(SELECT id FROM users WHERE email = 'admin@kerjakita.local'),
'INSERT',
'users',
(SELECT id FROM users WHERE email = 'admin@kerjakita.local'),
'Menambahkan data admin dan dummy'
),
(
(SELECT id FROM users WHERE email = 'manager@kerjakita.local'),
'UPDATE',
'tasks',
(SELECT id FROM tasks WHERE title = 'Perbaiki bug halaman login' LIMIT 1),
'Mengubah status task menjadi completed'
);

COMMIT;
