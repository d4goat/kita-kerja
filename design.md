# KerjaKita — Design Guidelines
> Professional Neo-Brutalism untuk aplikasi desktop manajemen tenaga kerja UMKM

**Tema:** terang (kertas krem) · **Target layar:** desktop 1366×768 dan 1440×900 · **Bahasa UI:** Bahasa Indonesia

Dokumen ini adalah turunan langsung dari `prd.md`. Setiap komponen, state, dan layout di bawah ini ada karena dibutuhkan oleh sebuah fitur di PRD (rujukan bagian PRD ditulis dalam tanda kurung, mis. *PRD 6.4*).

Dokumen sebelumnya (Slush — sticker pastel, pita 3D, pill, tanpa shadow, tanpa gradien) **dibuang seluruhnya** karena bertentangan dengan Neobrutalism dan dengan kebutuhan aplikasi data-padat. Tidak ada elemen Slush yang dipertahankan kecuali struktur token dan bentuk dokumen.

---

## 0. Aturan Mutlak (tidak ada pengecualian)

1. **Neobrutalism.** Border tebal solid, hard shadow (offset X/Y solid, **blur = 0**), sudut siku (radius 0), layout asimetris yang tegas.
2. **Hanya 6 warna.** Tidak ada gradien, warna pastel, warna abu-abu, putih, opacity/alpha, atau shadow transparan. Tidak ada turunan warna untuk hover, disabled, atau focus. Daftar lengkap ada di bagian 1.
3. **Ikon monokromatik solid.** Satu warna saja, selalu warna kontras terhadap latar tempat ikon berada (bagian 3).
4. **Konsistensi absolut.** Komponen yang sudah didefinisikan tidak boleh diubah warnanya untuk state lain. State berbeda dibedakan lewat **transform, shadow, label, bentuk ikon, atau pola fill yang sudah ada di tabel status** — bukan lewat warna baru.
5. **Status tidak boleh hanya warna** (PRD 11 — Accessibility). Setiap status wajib punya: warna fill + ikon solid + label teks.

---

## 1. Tokens — Warna

Enam warna, bersumber dari PRD bagian 12. Ini satu-satunya warna yang boleh muncul di seluruh UI.

| Nama | Hex | Token | Peran |
|------|-----|-------|-------|
| Neo Black | `#111111` | `--color-neo-black` | Semua teks di atas fill terang, semua border, semua hard shadow, fill header tabel, fill status "nonaktif/final", ikon di atas fill terang |
| Neo Cream | `#F5F1E8` | `--color-neo-cream` | Kanvas halaman, permukaan kartu/tabel/input/modal, fill tombol netral, teks & ikon di atas fill gelap (biru/hitam) |
| Neo Blue | `#315CFF` | `--color-neo-blue` | Aksi utama (primary), item navigasi aktif, status "sedang berjalan", progress bar |
| Neo Yellow | `#F5C542` | `--color-neo-yellow` | Aksi sekunder, peringatan/perhatian/menunggu, avatar, state hover navigasi |
| Neo Green | `#35C759` | `--color-neo-green` | Sukses, hadir, selesai, aktif, beban normal |
| Neo Red | `#FF5A5F` | `--color-neo-red` | Bahaya, hapus/nonaktifkan, error validasi, beban melebihi kapasitas |

**Tidak ada warna putih.** Krem adalah satu-satunya permukaan terang; pemisahan antar-elemen dilakukan oleh border 3px dan hard shadow, bukan oleh perbedaan terang-gelap.

### Matriks pasangan teks/ikon (WAJIB diikuti)

Rasio kontras dihitung WCAG 2.x.

| Latar (fill) | Warna teks & ikon | Rasio | Keterangan |
|--------------|-------------------|-------|------------|
| Neo Cream | Neo Black | 16,75 : 1 | Default |
| Neo Yellow | Neo Black | 11,64 : 1 | |
| Neo Green | Neo Black | 8,51 : 1 | |
| Neo Red | Neo Black | 6,19 : 1 | |
| Neo Black | Neo Cream | 16,75 : 1 | |
| Neo Blue | **Neo Cream** | 4,54 : 1 | Lolos AA teks normal |

> **Larangan keras:** teks/ikon **hitam di atas biru** (3,69 : 1) gagal AA untuk teks normal, jadi tidak dipakai. Teks/ikon **krem/biru di atas kuning, hijau, atau merah** (≤ 2,71 : 1) dilarang. Biru, kuning, hijau, dan merah tidak boleh saling ditumpuk sebagai teks-di-atas-fill; di antara mereka selalu ada border hitam.

### Peta makna warna (satu warna = satu makna, di seluruh aplikasi)

| Warna | Makna |
|-------|-------|
| Biru | Aksi utama · sedang berjalan · terpilih/aktif di navigasi |
| Kuning | Aksi sekunder · perhatian · menunggu/ditinjau · sedang |
| Hijau | Berhasil · hadir · selesai · aktif · normal |
| Merah | Bahaya · gagal · overload · tidak hadir · urgent/tinggi |
| Hitam (fill) | Nonaktif · final · urgent · header tabel · area ringkasan (gaji bersih) |
| Krem (fill) | Netral · belum mulai · draft · rendah |

---

## 2. Tokens — Tipografi

Font dipilih tanpa menambah warna. Keduanya gratis (Google Fonts).

| Peran | Font | Bobot | Catatan |
|-------|------|-------|---------|
| Heading, angka KPI, tombol absen | **Space Grotesk** | 700 | Fallback: `Archivo Black`, `ui-sans-serif`, `system-ui` |
| UI, body, tabel, form, label | **Inter** | 500 / 600 / 700 | Aktifkan `font-feature-settings: "tnum" on` untuk semua angka (jam, durasi, rupiah, persen) agar kolom rata |

### Skala tipe (desktop)

| Token | Ukuran / Line-height | Font · Bobot | Dipakai untuk |
|-------|----------------------|--------------|---------------|
| `--text-kpi` | 48 / 48 | Space Grotesk 700 | Angka KPI, persen beban kerja besar, jam live di widget absen |
| `--text-h1` | 32 / 36 | Space Grotesk 700 | Judul halaman |
| `--text-h2` | 24 / 28 | Space Grotesk 700 | Judul bagian/kartu |
| `--text-h3` | 18 / 24 | Space Grotesk 700 | Judul sub-bagian, judul modal |
| `--text-body` | 14 / 20 | Inter 500 | Teks isi, sel tabel, input |
| `--text-body-strong` | 14 / 20 | Inter 700 | Nama karyawan, judul pekerjaan di tabel |
| `--text-label` | 12 / 16 | Inter 700, UPPERCASE, `letter-spacing: 0.04em` | Label field, header kolom, label KPI, badge |
| `--text-caption` | 12 / 16 | Inter 500 | Bantuan field, metadata, timestamp |

Teks minimum 12px. Tidak ada teks di bawah itu.

### Format data (PRD 11 — Consistency)

| Data | Format | Contoh |
|------|--------|--------|
| Tanggal | `DD MMM YYYY` | `16 Nov 2026` |
| Waktu | `HH:mm` 24 jam | `08:05` |
| Durasi | `Xj Ym` | `8j 30m` |
| Lembur | `+Xj Ym` | `+1j 15m` |
| Rupiah | `Rp` + titik ribuan, rata kanan | `Rp 4.500.000` |
| Persen | koma desimal | `112,5%` |
| Jam estimasi | angka + `j` | `9j` |

---

## 3. Ikonografi — Solid & Monokromatik

- **Set ikon:** Phosphor Icons **weight Fill** (atau set solid setara, mis. Material Symbols Filled). Dilarang: ikon outline/stroke, duotone, ikon berwarna, emoji.
- **Satu warna per ikon**, mengikuti `currentColor`, ditentukan oleh latar tempatnya berada:

| Latar ikon | Warna ikon |
|------------|-----------|
| Neo Cream, Neo Yellow, Neo Green, Neo Red | **Neo Black** |
| Neo Blue, Neo Black | **Neo Cream** |

- **Ukuran:** 16px (di dalam badge & tombol kecil), 20px (default, tombol, nav, input), 24px (KPI, empty state kecil), 40px (empty state besar).
- Ikon **tidak pernah berdiri sendiri sebagai penanda makna** — selalu berpasangan dengan label teks, kecuali tombol ikon yang wajib punya `aria-label` dan tooltip.
- **Kontainer ikon (KPI):** kotak 40×40, border 3px, fill sesuai makna, ikon 24px berkontras (aturan di atas).
- Ikon tidak boleh diberi shadow, outline, atau fill ganda.

### Glosarium ikon yang dibutuhkan fitur PRD

| Fungsi | Ikon (Fill) | Fungsi | Ikon (Fill) |
|--------|-------------|--------|-------------|
| Dashboard | `squares-four` | Tambah | `plus` |
| Karyawan | `users` | Ubah | `pencil-simple` |
| Kehadiran | `calendar-check` | Lihat detail | `eye` |
| Pekerjaan | `kanban` / `list-checks` | Nonaktifkan | `prohibit` |
| Pengaturan | `gear-six` | Hapus (hanya data tak terpakai) | `trash` |
| Masuk Kerja | `sign-in` | Cari | `magnifying-glass` |
| Pulang Kerja | `sign-out` | Filter | `funnel` |
| Beban kerja | `gauge` | Tutup | `x` |
| Gaji | `money` | Peringatan | `warning` |
| Lembur | `clock-clockwise` | Kunci / read-only | `lock-simple` |
| Profil | `user-circle` | Tampil/sembunyi sandi | `eye` / `eye-slash` |
| Keamanan | `shield-check` | Logout | `sign-out` |

---

## 4. Tokens — Bentuk, Border, Shadow, Spasi

### Border
| Token | Nilai | Dipakai untuk |
|-------|-------|---------------|
| `--border-w` | `3px solid #111111` | Semua komponen: tombol, kartu, input, tabel (kerangka luar), modal, badge, tab, sidebar |
| `--border-w-sm` | `2px solid #111111` | Hanya pemisah di dalam komponen: garis antar-baris tabel, pemisah item dropdown, pemisah baris slip gaji |

### Radius
**`0px` untuk semua elemen.** Pengecualian tunggal dan final: radio button (lingkaran, konvensi fungsional) dan indikator titik status 8×8. Avatar **persegi**. Tidak ada pill, tidak ada sudut membulat.

### Hard Shadow
Hanya warna `#111111`, blur 0, tanpa alpha.

| Token | Nilai | Dipakai untuk |
|-------|-------|---------------|
| `--shadow-sm` | `2px 2px 0 0 #111111` | Badge, tag, avatar, kontainer ikon KPI |
| `--shadow-md` | `4px 4px 0 0 #111111` | Tombol, kartu, input fokus, tabel, dropdown, tab |
| `--shadow-lg` | `6px 6px 0 0 #111111` | Tombol hover, drawer |
| `--shadow-xl` | `8px 8px 0 0 #111111` | Modal, toast |
| `--shadow-none` | `none` | State pressed, disabled, read-only |

Shadow **tidak pernah** berubah warna. Shadow tidak diberikan pada sidebar, topbar, dan elemen di dalam tabel selain tombol.

### Spasi (basis 4px)
`4 · 8 · 12 · 16 · 20 · 24 · 32 · 40 · 48 · 64`

| Konteks | Nilai |
|---------|-------|
| Padding kartu | 24px |
| Padding sel tabel | 12px vertikal · 16px horizontal |
| Jarak antar-field form | 20px |
| Jarak antar-kartu/grid | 24px |
| Padding area konten | 32px |
| Jarak antar-tombol sebaris | 12px |

---

## 5. Layout Aplikasi (App Shell)

```
┌────────────┬──────────────────────────────────────────────────────┐
│            │  TOPBAR 72px — Judul halaman   [Role] [Avatar ▾]      │
│  SIDEBAR   ├──────────────────────────────────────────────────────┤
│  240px     │                                                      │
│            │   KONTEN  (padding 32, grid 12 kolom, gap 24)        │
│  Logo      │                                                      │
│  5 menu    │                                                      │
└────────────┴──────────────────────────────────────────────────────┘
```

- **Lebar efektif konten:** 1062px @1366, 1136px @1440 (setelah sidebar & padding). Konten fluid; tidak ada max-width di bawah itu. Di atas 1440px, konten tidak melebar lebih dari 1136px dan rata kiri (asimetris, bukan di tengah).
- **Tinggi:** halaman tidak boleh memerlukan scroll horizontal. Area konten scroll vertikal; sidebar dan topbar tetap (`position: sticky`).
- **Asimetri tegas:** rasio kolom selalu timpang dan konsisten — **8/4** (Dashboard, Pekerjaan+panel), **4/8** (detail Karyawan: profil kiri sempit, tab kanan lebar), **7/5** (Login/Register). Judul halaman selalu rata kiri.
- **Sedikit kartu** (PRD 12): daftar data memakai **tabel berbingkai tunggal**, bukan tumpukan kartu. Kartu hanya untuk: KPI, ringkasan beban kerja, widget absen, slip gaji, kartu profil. Kartu tidak boleh bersarang di dalam kartu.

### 5.1 Sidebar
- Lebar 240px, fill Neo Cream, border-kanan `--border-w`. Logo "KerjaKita" di atas (Space Grotesk 700, 24px) di dalam kotak hitam dengan teks krem.
- **Hanya 5 item** (PRD 4 & 12): Dashboard · Karyawan · Kehadiran · Pekerjaan · Pengaturan. Tidak ada item lain, tidak ada sub-menu di sidebar.
- Item: tinggi 48px, ikon 20px + label Inter 700 14px, border `--border-w`, jarak antar-item 8px.
  - **Default:** fill krem, teks/ikon hitam.
  - **Hover:** fill Neo Yellow, teks/ikon hitam, `--shadow-md` + `translate(-2px,-2px)`.
  - **Aktif:** fill Neo Blue, teks/ikon **krem**, `--shadow-md`.
- Item yang tidak berhak diakses role tertentu **tidak dirender** (bukan disabled). Semua role melihat kelima item; isi halamannya yang disaring (lihat bagian 12).

### 5.2 Topbar
- Tinggi 72px, fill krem, border-bawah `--border-w`.
- Kiri: judul halaman (`--text-h1`) + breadcrumb 12px untuk halaman detail.
- Kanan: **Chip Role** (fill hitam, teks krem, label caps: `ADMIN / OWNER`, `MANAGER`, `KARYAWAN`) + **Avatar** 40×40 persegi (fill kuning, inisial hitam, `--shadow-sm`).
- **Profil dan Logout hanya lewat avatar** (PRD 12). Klik avatar → Dropdown Menu berisi: *Profil* (ikon `user-circle`), pemisah 2px, *Logout* (ikon `sign-out`).

---

## 6. Komponen Inti

### 6.1 Tombol

Satu definisi per varian. State **tidak mengubah warna**.

| Varian | Fill | Teks & ikon | Dipakai untuk |
|--------|------|-------------|---------------|
| **Primary** | Neo Blue | Neo Cream | Aksi utama satu per area: Simpan, Tambah Karyawan, Buat Pekerjaan, Login |
| **Secondary** | Neo Yellow | Neo Black | Aksi kedua: Ubah, Tinjau, Pulang Kerja, Ekspor |
| **Neutral** | Neo Cream | Neo Black | Batal, Kembali, Filter, tombol ikon |
| **Success** | Neo Green | Neo Black | **Hanya**: Masuk Kerja, Tandai Selesai |
| **Danger** | Neo Red | Neo Black | Nonaktifkan, Hapus, Logout konfirmasi |

Spesifikasi: border `--border-w`, `--shadow-md`, radius 0, Inter 700 14px, `letter-spacing: 0.02em`, padding `0 20px`, ikon 20px di kiri label dengan jarak 8px.

| Ukuran | Tinggi |
|--------|--------|
| sm | 36px |
| md (default) | 44px |
| lg | 56px |
| xl (tombol absen) | 88px, Space Grotesk 700 24px |

**State (berlaku sama untuk semua varian):**

| State | Perubahan |
|-------|-----------|
| Default | `--shadow-md` |
| Hover | `transform: translate(-2px,-2px)` + `--shadow-lg` |
| Active/pressed | `transform: translate(4px,4px)` + `--shadow-none` |
| Focus-visible | `outline: 3px solid #111111; outline-offset: 3px` + `--shadow-lg` |
| Disabled | `--shadow-none`, `cursor: not-allowed`, ikon `lock-simple` menggantikan ikon asli, fill & teks tetap sesuai varian (tidak ada abu-abu/opacity) |
| Loading | Label diganti "Memproses…" + spinner blok (6.14); `pointer-events: none` |

Maksimal **satu tombol Primary** per area (halaman, modal, atau form).

### 6.2 Tombol Ikon
40×40, varian Neutral, border `--border-w`, `--shadow-sm`, ikon 20px hitam. Wajib `aria-label` + tooltip. State sama seperti 6.1 (shadow sm→md saat hover).

### 6.3 Field Form

Label di atas field: `--text-label`, hitam. Tanda wajib: `*` di samping label. Teks bantuan `--text-caption` di bawah field.

| Tipe | Spesifikasi |
|------|-------------|
| Text / Email / Telepon / Angka / Tanggal / Waktu | Tinggi 44px, fill krem, border `--border-w`, padding `0 12px`, Inter 500 14px. Placeholder = teks hitam biasa dengan contoh data (bukan abu-abu). |
| Password | Sama + tombol ikon `eye`/`eye-slash` di dalam, sisi kanan, dibatasi border-kiri 2px. |
| Textarea | Min 96px, resize vertikal saja. |
| Select | Sama dengan text + ikon `caret-down` solid di kanan; daftar opsi = Dropdown Menu (6.9). |
| Checkbox | Kotak 24×24, border `--border-w`, fill krem; checked = fill hitam + ikon `check` krem. Dipakai: **Ingat Saya**. |
| Radio | Lingkaran 24×24, border `--border-w`; selected = titik hitam 10px. |
| Toggle Switch | 56×28, border `--border-w`; **ON = fill Neo Green**, kenop hitam di kanan, label "Aktif"; **OFF = fill krem**, kenop hitam di kiri, label "Nonaktif". Label selalu tampil di samping (bukan hanya warna). Dipakai di Data Master & status karyawan. |

**State field:**

| State | Perubahan |
|-------|-----------|
| Default | `--shadow-none` |
| Focus | `--shadow-md` + `translate(-2px,-2px)`; tidak ada perubahan warna border |
| Error | Border tetap hitam; di bawah field muncul **Pesan Error**: fill Neo Red, teks hitam, ikon `warning` hitam, border `--border-w-sm`. Field diberi `--shadow-md` dan ikon `warning` di dalam sisi kanan. |
| Read-only (role View saja) | `--shadow-none`, ikon `lock-simple` 16px di kanan, kursor default |
| Disabled | Sama dengan read-only + `cursor: not-allowed` |

### 6.4 Badge Status

Bentuk universal: tinggi 28px, padding `0 10px`, border `--border-w-sm`, `--shadow-sm`, `--text-label` (caps), ikon solid 16px di kiri label. **Fill + ikon + label bersama-sama** membedakan status.

#### Status Pekerjaan (PRD 6.5, 9)
| Label | Fill | Ikon | Warna ikon/teks |
|-------|------|------|-----------------|
| BELUM MULAI | Neo Cream | `hourglass` | Hitam |
| SEDANG DIKERJAKAN | Neo Blue | `play` | **Krem** |
| DITINJAU | Neo Yellow | `eye` | Hitam |
| SELESAI | Neo Green | `check` | Hitam |

#### Prioritas Pekerjaan
| Label | Fill | Ikon | Warna ikon/teks |
|-------|------|------|-----------------|
| RENDAH | Neo Cream | `caret-down` | Hitam |
| SEDANG | Neo Yellow | `equals` | Hitam |
| TINGGI | Neo Red | `caret-up` | Hitam |
| URGENT | Neo Black | `caret-double-up` | **Krem** |

#### Status Kehadiran (PRD 6.4)
| Label | Fill | Ikon | Warna ikon/teks |
|-------|------|------|-----------------|
| HADIR | Neo Green | `check` | Hitam |
| TERLAMBAT | Neo Yellow | `clock` | Hitam |
| TIDAK HADIR | Neo Red | `x` | Hitam |
| IZIN / CUTI | Neo Blue | `calendar-blank` | **Krem** |
| SAKIT | Neo Cream | `first-aid` | Hitam |

#### Status Beban Kerja (PRD 6.6)
| Label | Fill | Ikon | Warna ikon/teks |
|-------|------|------|-----------------|
| KURANG | Neo Cream | `caret-down` | Hitam |
| NORMAL | Neo Green | `check` | Hitam |
| TINGGI | Neo Yellow | `warning` | Hitam |
| OVERLOAD | Neo Red | `warning-octagon` | Hitam |

#### Status Gaji (PRD 6.7)
| Label | Fill | Ikon | Warna ikon/teks |
|-------|------|------|-----------------|
| DRAFT | Neo Cream | `pencil-simple` | Hitam |
| DIPROSES | Neo Yellow | `gear-six` | Hitam |
| DIBAYAR | Neo Green | `check` | Hitam |

#### Status Akun/Data (Karyawan, Data Master, Akun)
| Label | Fill | Ikon | Warna ikon/teks |
|-------|------|------|-----------------|
| AKTIF | Neo Green | `check` | Hitam |
| NONAKTIF | Neo Black | `prohibit` | **Krem** |

### 6.5 Tag Kategori
Untuk Kategori Pekerjaan, Jabatan, Departemen, Jadwal Kerja. Tinggi 24px, fill krem, border `--border-w-sm`, Inter 700 12px, tanpa ikon, tanpa shadow. Bukan status — tidak pernah diwarnai.

### 6.6 Avatar
Persegi 40×40 (sm 32, lg 96), fill Neo Yellow, border `--border-w`, `--shadow-sm`, inisial 2 huruf Space Grotesk 700 hitam. **Satu warna untuk semua pengguna** (tidak ada warna acak).

### 6.7 Tabel (daftar data)

Dipakai: Karyawan, Kehadiran, Pekerjaan (mode daftar), Beban Kerja, Gaji, Data Master (5 tabel), Log Aktivitas.

- **Bingkai tunggal:** border `--border-w` di sekeliling, `--shadow-md`, fill krem.
- **Header:** fill Neo Black, teks krem, `--text-label`. Kolom yang bisa diurutkan menampilkan ikon `caret-up-down` krem; kolom aktif `caret-up`/`caret-down`.
- **Baris:** tinggi min 56px, pemisah `--border-w-sm`, teks `--text-body`. Kolom utama (nama/judul) memakai `--text-body-strong`.
- **Hover baris:** `box-shadow: inset 8px 0 0 0 #111111` (bilah hitam di kiri). Fill baris tidak berubah (badge berwarna tetap terbaca).
- **Rata:** teks kiri; **angka, durasi, rupiah, persen: kanan** dengan `tnum`.
- **Kolom aksi** terakhir, rata kanan: tombol ikon sm (Lihat, Ubah, Nonaktifkan) sesuai hak akses (bagian 12).
- **Bar alat di atas tabel:** field pencarian (lebar 320px) + tombol Filter + tombol Primary di kanan ("Tambah …"). Chip filter aktif = Tag krem dengan ikon `x`.
- **Pagination** di bawah, rata kanan: kotak 40×40 border `--border-w`; halaman aktif = fill hitam + teks krem; tombol sebelumnya/berikutnya = ikon `caret-left`/`caret-right`. Teks "Menampilkan 1–10 dari 24" di kiri (`--text-caption`).
- Maksimal 8 kolom terlihat di 1366px; kolom sekunder pindah ke Drawer detail.

### 6.8 Tab
Dipakai: tab di halaman Pengaturan, tab detail Karyawan, tab Pekerjaan (Daftar · Papan · Beban Kerja), tab Data Master.
- Kotak berderet menempel, tinggi 44px, border `--border-w`, Inter 700 14px.
- **Tidak aktif:** fill krem, teks hitam. **Hover:** `translate(-2px,-2px)` + `--shadow-sm`. **Aktif:** fill Neo Black, teks krem, tanpa shadow.
- Tab yang tidak boleh diakses role **tidak dirender**.

### 6.9 Dropdown Menu
Fill krem, border `--border-w`, `--shadow-md`, lebar min 200px. Item tinggi 44px, padding `0 16px`, pemisah `--border-w-sm`. Hover item: bilah hitam inset 8px di kiri. Item terpilih: ikon `check` hitam di kanan. Item berbahaya (Logout) tetap krem — tidak diwarnai merah.

### 6.10 Modal & Dialog Konfirmasi
- **Tidak ada backdrop gelap/transparan** (opacity dilarang). Halaman di belakang menjadi inert (tidak bisa diklik) dan modal tampil di tengah dengan `--shadow-xl`.
- Lebar: 480px (konfirmasi), 640px (form). Fill krem, border `--border-w`.
- Header: judul `--text-h3` + tombol ikon `x` di kanan, pemisah `--border-w-sm`. Footer: tombol rata kanan — Batal (Neutral) lalu aksi (Primary, atau Danger untuk nonaktifkan/hapus).
- **Dialog konfirmasi destruktif** memuat ikon `warning` hitam di kotak kuning 40×40 dan kalimat konsekuensi yang spesifik (lihat 10.3).

### 6.11 Drawer (panel samping)
Lebar 480px, menempel di kanan, border-kiri `--border-w`, `--shadow-lg`, fill krem, tinggi penuh. Dipakai untuk: detail Pekerjaan, Tinjau Kehadiran, detail baris Data Master. Header sama seperti modal.

### 6.12 Alert Inline (Banner)
Blok lebar penuh, border `--border-w`, `--shadow-md`, padding 16px, ikon 24px kiri + teks `--text-body-strong` + (opsional) tombol sm di kanan.

| Jenis | Fill | Ikon | Dipakai |
|-------|------|------|---------|
| Sukses | Neo Green | `check-circle` | Konfirmasi tersimpan |
| Peringatan | Neo Yellow | `warning` | Informasi perlu perhatian |
| Bahaya | Neo Red | `warning-octagon` | Beban melebihi kapasitas; error sistem |
| Info | Neo Black (teks & ikon krem) | `info` | Informasi netral, mis. "Data ini hanya dapat dilihat" |

### 6.13 Toast
Pojok kanan atas, di bawah topbar, lebar 360px, struktur = Alert Inline (6.12) tanpa tombol, `--shadow-xl`, tombol `x`. Muncul dengan `translateX` 120ms `steps(4)`; otomatis hilang setelah 5 detik; error tidak otomatis hilang.

### 6.14 Loading, Empty, Error

- **Spinner:** tiga kotak hitam 10×10 yang menyala berurutan (animasi `steps`, tanpa rotasi halus, tanpa gradien), diikuti teks "Memuat…".
- **Skeleton:** blok berbingkai `--border-w-sm`, fill krem, dengan satu batang hitam 12px sebagai "teks"; berkedip dengan `steps(2)` antara tampil/sembunyi batang hitam. Tidak ada shimmer.
- **Empty state:** kotak berbingkai di tengah area; ikon solid 40px hitam di kotak kuning 72×72 dengan `--shadow-md`; judul `--text-h3`; satu kalimat; satu tombol Primary bila role berhak. Contoh: "Belum ada pekerjaan — Buat pekerjaan pertama."
- **Error state halaman:** pola sama dengan Empty; ikon `warning-octagon` di kotak merah; tombol "Coba Lagi" (Secondary).

---

## 7. Komponen Domain (khusus fitur PRD)

### 7.1 Kartu KPI (PRD 6.2)
Fill krem, border `--border-w`, `--shadow-md`, padding 24px. Isi: `--text-label` (nama KPI) → `--text-kpi` (angka) → `--text-caption` (konteks) ; kontainer ikon 40×40 di kanan atas.

| KPI | Fill kontainer ikon | Ikon |
|-----|---------------------|------|
| Total Karyawan | Neo Black (ikon krem) | `users` |
| Hadir Hari Ini | Neo Green | `calendar-check` |
| Pekerjaan Aktif | Neo Blue (ikon krem) | `kanban` |
| Lembur | Neo Yellow | `clock-clockwise` |

Empat KPI sebaris (grid 4 × 3 kolom). Tidak ada grafik dekoratif, tidak ada sparkline.

### 7.2 Banner Peringatan Beban Kerja (PRD 6.2, 6.6)
Alert **Bahaya** (merah) di puncak Dashboard bila ada karyawan dengan beban > 100%: ikon `warning-octagon`, teks "2 karyawan melebihi kapasitas kerja", tombol Neutral sm "Lihat Beban Kerja". Hilang bila tidak ada pelanggaran.

### 7.3 Meter Beban Kerja (PRD 6.6)
Satu baris per karyawan: Avatar sm · nama · **bar** · persen · badge status.

- **Bar:** tinggi 24px, border `--border-w`, fill track krem. Isi **Neo Blue** dari 0 sampai min(beban, 100%).
- **Penanda kapasitas 100%:** garis vertikal hitam 3px yang selalu berada di ujung kanan track.
- **Beban > 100%:** bar tidak keluar dari track; sebagai gantinya, **segmen kelebihan** berwarna **Neo Red** menempati ujung kanan track (dibatasi border hitam 3px dari segmen biru), dan badge menjadi OVERLOAD. Persen ditulis tebal (`112,5%`).
- Teks pendamping `--text-caption`: `Ditugaskan 9j / Kapasitas 8j` (contoh PRD).
- Bar tidak mengandalkan warna: persen angka + badge status selalu tampil.

### 7.4 Widget Absen (PRD 6.4)
Hanya untuk role Karyawan (di Dashboard pribadi dan di halaman Kehadiran). Satu kartu fill krem, `--shadow-lg`, asimetris 7/5:

- Kiri: jam live `--text-kpi` (`08:05`), tanggal, nama jadwal kerja & jamnya ("Shift Pagi 08:00–16:00").
- Kanan: satu tombol **xl** yang berganti sesuai state:

| State | Tampilan |
|-------|----------|
| Belum masuk | Tombol xl **Success**, ikon `sign-in`: "MASUK KERJA" |
| Sudah masuk, belum pulang | Tombol xl **Secondary** (kuning), ikon `sign-out`: "PULANG KERJA"; di atasnya Badge status kehadiran & "Masuk 08:05 · Berjalan 3j 12m" |
| Sudah pulang | Tombol xl disabled (aturan 6.1) berlabel "SELESAI HARI INI" + ringkasan "Durasi 8j 30m · Lembur +0j 30m" |

Tidak ada konfirmasi modal untuk Masuk Kerja; Pulang Kerja memakai konfirmasi ringan (dialog 480px) bila durasi kurang dari jam kerja jadwal.

### 7.5 Kartu Pekerjaan & Papan (PRD 6.5)
**Mode Papan** (tab "Papan"): empat kolom sesuai alur **Belum Mulai → Sedang Dikerjakan → Ditinjau → Selesai**.
- Header kolom: fill hitam, teks krem, judul + jumlah (`3`) dalam kotak krem; di antara header, ikon `arrow-right` hitam sebagai penanda alur.
- **Kartu pekerjaan** (di dalam kolom, satu level, bukan kartu bersarang): fill krem, border `--border-w`, `--shadow-md`, padding 16px. Urutan: judul (`--text-body-strong`, maks 2 baris) → Tag kategori + Badge prioritas → baris metadata (ikon `user` avatar sm · `Estimasi 9j` · `Deadline 20 Nov 2026`) → progress bar kecil.
- **Deadline terlewat:** teks deadline ditulis tebal + ikon `warning` hitam di kotak merah 20×20; bukan hanya warna.
- Hover kartu: `translate(-2px,-2px)` + `--shadow-lg`. Klik → Drawer detail (7.6).

**Mode Daftar** (tab "Daftar"): Tabel 6.7 dengan kolom Judul · Kategori · Prioritas · Penanggung Jawab · Estimasi · Deadline · Status.

### 7.6 Drawer Detail Pekerjaan
- Judul + Badge Status + Badge Prioritas.
- **Stepper Status:** 4 kotak 44px berderet bernomor, dihubungkan garis hitam 3px; langkah selesai = fill hitam + ikon `check` krem; langkah sekarang = fill **Neo Blue** + teks krem; langkah berikutnya = fill krem.
- Detail: deskripsi, kategori, penanggung jawab, estimasi vs aktual jam, deadline, tanggal mulai.
- **Progress:** bar (fill biru, track krem, border `--border-w`) + `65%`.
- **Riwayat Progres (timeline):** daftar vertikal dengan garis hitam 3px di kiri dan kotak penanda 16×16 (fill sesuai warna status), tiap entri: Badge status, persen, catatan, waktu, nama pencatat.
- **Aksi sesuai role:** Karyawan → "Perbarui Progres" (Primary) membuka form kecil: status, persen, catatan. Admin/Manager → "Ubah" (Secondary), "Tandai Selesai" (Success). UI hanya merender tombol transisi yang diizinkan backend.

### 7.7 Kartu Slip Gaji (PRD 6.7)
Kartu tunggal, fill krem, `--shadow-md`. Baris komponen dengan pemisah `--border-w-sm`, label kiri, nilai rupiah kanan (`tnum`):

```
Gaji Pokok          Rp 4.500.000
Lembur              Rp         0
Bonus               Rp   250.000
Potongan          − Rp    50.000
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[ GAJI BERSIH       Rp 4.700.000 ]   ← blok fill Neo Black, teks krem, Space Grotesk 700 32px
```

Header kartu: periode ("September 2026") + Badge status gaji. Potongan ditulis dengan tanda `−` (bukan hanya warna).

### 7.8 Tampilan Data Terbatas / Tersembunyi (hak akses)
- **Masked** (Manager melihat gaji yang tidak relevan): nilai diganti blok hitam 120×20 dengan ikon `lock-simple` krem 16px di tengah dan `aria-label="Data tidak tersedia untuk role Anda"`.
- **Read-only:** lihat 6.3.
- **Halaman terlarang (403):** empty state dengan ikon `lock-simple` di kotak merah, judul "Akses Ditolak", kalimat "Halaman ini di luar cakupan role Anda.", tombol Neutral "Kembali ke Dashboard".

### 7.9 Date Picker & Rentang Tanggal (filter Kehadiran/Beban Kerja)
Field tanggal + popover kalender (gaya Dropdown Menu 6.9, lebar 320px). Grid hari kotak 40×40, border `--border-w-sm`. Hari ini = fill Neo Yellow; hari terpilih/rentang = fill Neo Blue + teks krem. Hari di luar bulan tidak dirender. Tombol navigasi bulan = tombol ikon.

---

## 8. Halaman & Layout per Fitur

Setiap halaman punya judul `--text-h1` rata kiri di topbar dan satu tombol Primary maksimal.

### 8.1 Autentikasi (PRD 6.1)
Layar tanpa sidebar/topbar, split asimetris **7/5**:
- **Kiri (7/12):** panel fill **Neo Blue**, border-kanan `--border-w`. Wordmark "KERJAKITA" Space Grotesk 700 96px teks **krem**, rata kiri bawah; satu kalimat tagline Inter 700 18px krem; satu blok geometris solid (persegi kuning 160×160 dengan border & `--shadow-xl`) dipakai sekali sebagai aksen. Tidak ada ilustrasi lain.
- **Kanan (5/12):** latar krem, kartu form di tengah vertikal, lebar 420px, `--shadow-lg`.
  - **Login:** field Email, Kata Sandi (dengan toggle tampil), Checkbox **Ingat Saya**, tautan **Lupa Kata Sandi?** (teks hitam bergaris bawah 3px, Inter 700), tombol Primary lebar penuh "LOGIN", pemisah, tautan "Belum punya akun? Register".
  - **Register:** Nama, Email, Telepon, Kata Sandi, Konfirmasi Kata Sandi, tombol Primary "DAFTAR".
  - **Lupa Kata Sandi:** satu field Email + tombol Primary "KIRIM TAUTAN" + tautan kembali ke Login. Setelah terkirim: Alert Sukses di atas form.
- **Error login** (kredensial salah): Alert Bahaya di atas form. **Akun nonaktif** (PRD 9): Alert Bahaya dengan teks "Akun Anda nonaktif. Hubungi Admin." — tombol login tetap aktif.
- Setelah login: pengarahan ke Dashboard sesuai role (tidak ada layar pemilihan role).

### 8.2 Dashboard (PRD 6.2) — grid 8/4
Urutan dari atas:
1. (Kondisional) Banner Peringatan Beban Kerja (7.2).
2. Baris **4 Kartu KPI** (7.1).
3. Baris kedua: kolom **8/12** + kolom **4/12**.

| Role | Kolom 8/12 | Kolom 4/12 |
|------|-----------|-----------|
| **Admin / Owner** (keseluruhan usaha) | Tabel "Pekerjaan Deadline Terdekat" (5 baris) · Meter Beban Kerja semua karyawan (maks 6, tombol "Lihat semua") | Tabel kecil "Kehadiran Hari Ini" (karyawan + Badge status) |
| **Manager / Supervisor** (tim) | Sama, disaring tim sendiri; judul bagian diberi akhiran "— Tim" | Kehadiran tim hari ini |
| **Karyawan** (pribadi) | **Widget Absen** (7.4) di puncak · Tabel "Pekerjaan Saya" (5 baris) | Satu Meter Beban Kerja pribadi · Ringkasan kehadiran bulan ini (jumlah per status) |

KPI per role: Admin = seluruh usaha; Manager = tim; Karyawan = angka pribadi (Pekerjaan Aktif, Jam Lembur Bulan Ini, Hadir Bulan Ini, Beban Kerja %) — pola kartu sama persis.

### 8.3 Karyawan (PRD 6.3)

**Daftar (Admin penuh, Manager tim, Karyawan → langsung ke detail dirinya):**
- Tabel 6.7: Karyawan (Avatar + nama + kode `EMP003`) · Jabatan · Departemen · Jadwal Kerja · Tanggal Bergabung · Status · Aksi.
- Filter: Departemen, Jabatan, Status. Tombol Primary "Tambah Karyawan" (hanya Admin). Aksi baris: Lihat; Ubah & Nonaktifkan (hanya Admin).

**Detail (asimetris 4/8):**
- Kiri 4/12: **Kartu Profil** — Avatar lg 96, nama (`--text-h2`), Badge Status, jabatan/departemen sebagai Tag, email, telepon, tanggal bergabung, jadwal kerja, jenis gaji, atasan/supervisor.
- Kanan 8/12: **Tab** — *Ringkasan · Kehadiran · Pekerjaan · Beban Kerja · Gaji*. Gaji hanya muncul untuk role yang berhak (bagian 12). Tab Kehadiran/Pekerjaan memakai tabel yang sama dengan halaman induknya, disaring per karyawan; tab Beban Kerja memakai Meter 7.3 per periode; tab Gaji memakai Kartu Slip Gaji 7.7 + tabel riwayat periode.

**Form Tambah/Ubah Karyawan (Modal 640px atau halaman penuh):** dua kolom field (grid 6/6) — Kode Karyawan, Nama Lengkap*, Email*, Telepon, Jabatan* (select), Departemen* (select), Jenis Gaji* (select), Jadwal Kerja* (select), Tanggal Bergabung* (date), Status (toggle Aktif/Nonaktif), Atasan/Supervisor (select). Select hanya menampilkan data master **aktif**. Footer: Batal (Neutral) + Simpan (Primary).

### 8.4 Kehadiran (PRD 6.4)

| Role | Layout |
|------|--------|
| **Karyawan** | Widget Absen (7.4) di atas (lebar 7/12 kiri, ringkasan bulan ini 5/12 kanan); di bawahnya tabel **Riwayat Saya** |
| **Manager** | Bar filter (rentang tanggal, karyawan tim, status) + tabel tim; tombol sm "Tinjau" per baris membuka Drawer Tinjau |
| **Admin** | Sama + tombol sm "Koreksi" (Secondary) per baris → Modal Koreksi |

- **Kolom tabel:** Tanggal · Karyawan (dilewatkan untuk role Karyawan) · Masuk · Keluar · Durasi · Lembur · Status (Badge Kehadiran) · Aksi.
- **Modal Koreksi (Admin):** field Tanggal (read-only), Jam Masuk, Jam Keluar, Status (select), Catatan (textarea). Pesan di atas modal: Alert Info "Koreksi tercatat di Log Aktivitas." Durasi dan lembur dihitung ulang otomatis dan ditampilkan read-only sesuai Jadwal Kerja.
- **Drawer Tinjau (Manager):** semua data baris read-only + catatan.

### 8.5 Pekerjaan (PRD 6.5, 6.6)

Tab tingkat halaman: **Daftar · Papan · Beban Kerja**.
- Bar atas: pencarian, filter (Kategori, Prioritas, Status, Penanggung Jawab, Deadline), tombol Primary "Buat Pekerjaan" (Admin/Manager).
- **Daftar** & **Papan:** lihat 7.5. **Beban Kerja:** tabel/meter 7.3 dengan pemilih Periode (rentang tanggal 7.9) dan ringkasan 3 angka di atas (jumlah Normal/Tinggi/Overload sebagai tiga Kartu KPI sejajar, fill ikon sesuai badge). Karyawan hanya melihat satu meter miliknya.
- **Form Buat/Ubah Pekerjaan (Modal 640px):** Judul*, Deskripsi, Kategori* (master aktif), Prioritas* (radio 4 pilihan berbadge), Penanggung Jawab* (select karyawan; karyawan nonaktif tidak muncul — PRD 9), Estimasi Jam*, Tanggal Mulai, Deadline* (wajib — PRD 9). Setelah memilih penanggung jawab, di bawah field tampil **Pratinjau Beban**: Meter 7.3 mini yang menunjukkan beban setelah penugasan; bila > 100% → Alert Peringatan kuning inline "Penugasan ini membuat beban Rina menjadi 112,5%." (tidak memblokir penyimpanan).

### 8.6 Gaji (PRD 6.7)
Tidak punya menu sendiri (sidebar dibatasi 5 item). Gaji tampil di:
- **Tab "Gaji"** pada detail Karyawan (Admin penuh; Manager sesuai kebutuhan; Karyawan hanya miliknya) — Kartu Slip Gaji 7.7 + tabel riwayat (Periode · Gaji Pokok · Lembur · Bonus · Potongan · **Gaji Bersih** · Status).
- **Ringkasan di Dashboard Karyawan** (gaji bersih periode terakhir + Badge status).
- Admin: bar filter periode (bulan, tahun) dan Select Status pada tab; tombol Secondary "Ubah" per baris membuka form: Gaji Pokok, Lembur, Bonus, Potongan (field angka dengan prefiks "Rp"), Status, Catatan; **Gaji Bersih dihitung otomatis dan read-only** dalam blok hitam.

### 8.7 Pengaturan (PRD 4, 6.8)
Halaman tunggal dengan **Tab: Profil · Data Master · Keamanan** (Data Master hanya dirender untuk Admin dan Manager; Karyawan melihat Profil & Keamanan).

- **Profil:** asimetris 4/8 — kiri Avatar lg + nama + Chip Role; kanan form (Nama, Email, Telepon). Footer form: Simpan (Primary).
- **Keamanan:** form Kata Sandi Saat Ini, Kata Sandi Baru, Konfirmasi (dengan toggle tampil) + tombol Primary "Ubah Kata Sandi"; blok info "Login terakhir: 16 Nov 2026 08:01" (`--text-caption`). Admin melihat tambahan **Log Aktivitas** (tabel 6.7: Waktu · Pengguna · Aksi · Tabel · Deskripsi; opsional sesuai skema `audit_logs`).
- **Data Master:** sub-tab berderet (Tab 6.8, gaya sama) — **Jabatan · Departemen · Kategori Pekerjaan · Jenis Gaji · Jadwal Kerja**.
  - Setiap sub-tab = satu Tabel 6.7: Nama · Deskripsi · **Dipakai** (angka, mis. "6 karyawan") · Status (Toggle 6.3) · Aksi (Ubah).
  - Tombol Primary "Tambah …" (Admin). **Manager = read-only**: tidak ada tombol Tambah/Ubah, toggle ber-state read-only, Alert Info di atas tabel: "Anda hanya dapat melihat Data Master."
  - **Jadwal Kerja** menambah kolom Jam Mulai · Jam Selesai · Istirahat · Jam Kerja; form: Nama, Jam Mulai, Jam Selesai, Istirahat (menit), **Jam Kerja (dihitung otomatis, read-only)**, Status.
  - **Aturan non-hapus (PRD 6.8, 9):** untuk data yang sudah dipakai, tombol Hapus **tidak dirender**; yang ada hanya Toggle Aktif/Nonaktif. Bila Admin mengubah ke Nonaktif, tampil dialog konfirmasi (10.3). Tombol Hapus (ikon `trash`, Danger) hanya muncul untuk data dengan `Dipakai = 0`.

---

## 9. Hak Akses → Pola UI (PRD 5)

| Fitur | Admin / Owner | Manager / Supervisor | Karyawan |
|-------|---------------|----------------------|----------|
| Dashboard | Kartu & data penuh | Data tim | Data pribadi + Widget Absen |
| Karyawan | Tambah/Ubah/Nonaktifkan/Lihat semua | Daftar & detail tim, tanpa tombol aksi | Langsung ke detail diri sendiri |
| Kehadiran | Lihat semua + Koreksi | Lihat tim + Tinjau | Riwayat sendiri + Widget Absen |
| Pekerjaan | Buat/Ubah/Tugaskan semua | Buat/Ubah/Tugaskan (tim) | Hanya pekerjaan sendiri + Perbarui Progres |
| Beban Kerja | Semua karyawan | Tim | Satu meter pribadi |
| Gaji | Penuh (lihat/ubah) | Hanya data yang dibutuhkan; sisanya Masked (7.8) | Hanya milik sendiri |
| Data Master | Penuh | Read-only | Tab **tidak dirender** |
| Profil | Milik sendiri | Milik sendiri | Milik sendiri |
| Keamanan | Penuh + Log Aktivitas | Akun sendiri | Akun sendiri |

**Prinsip:** elemen di luar hak **tidak dirender** (tab, tombol aksi, kolom). Data yang berhak dilihat tapi tidak berhak diubah dirender **read-only**. Data sensitif yang berhak sebagian dirender **masked**. Mengakses URL di luar cakupan → halaman 403 (7.8).

---

## 10. Perilaku Interaksi & Pesan

### 10.1 Gerak
Hanya `transform` dan `box-shadow`, durasi 100ms, `steps(3)`; tanpa easing halus, tanpa blur, tanpa fade berbasis opacity. Satu-satunya gerak otomatis: toast masuk, kedip skeleton, spinner blok.

### 10.2 Validasi
- Validasi saat *blur* dan saat *submit*. Field wajib kosong → pesan error "[Nama field] wajib diisi."
- Aturan bisnis PRD 9 ditampilkan sebagai error inline: "Pekerjaan harus memiliki penanggung jawab dan deadline", "Karyawan nonaktif tidak dapat menerima pekerjaan baru", "Clock-out hanya dapat dilakukan setelah clock-in".

### 10.3 Dialog Konfirmasi (teks baku)
| Aksi | Judul | Isi | Tombol |
|------|-------|-----|--------|
| Nonaktifkan karyawan | Nonaktifkan karyawan? | "Dewi tidak dapat menerima pekerjaan baru dan akunnya tidak dapat login. Data lama tetap tersimpan." | Batal · **Nonaktifkan** (Danger) |
| Nonaktifkan data master | Nonaktifkan "Kasir"? | "6 karyawan memakai data ini. Data tidak dihapus dan tetap muncul di riwayat." | Batal · **Nonaktifkan** (Danger) |
| Hapus data master (Dipakai = 0) | Hapus "Gudang"? | "Data belum dipakai dan akan dihapus permanen." | Batal · **Hapus** (Danger) |
| Pulang Kerja lebih awal | Pulang lebih awal? | "Durasi kerja Anda 6j 10m, kurang dari jadwal 8j." | Batal · **Pulang Kerja** (Secondary) |
| Logout | Keluar dari aplikasi? | "Sesi Anda akan diakhiri." | Batal · **Logout** (Danger) |

### 10.4 Toast (teks baku)
Sukses: "Karyawan berhasil disimpan." · "Progres diperbarui." · "Masuk kerja tercatat pukul 08:05." Error: "Gagal menyimpan. Periksa koneksi lalu coba lagi."

---

## 11. Data Contoh (sedikit & realistis — PRD 12)

Maksimal 5–8 baris per tabel. Gunakan nama dan angka Indonesia yang wajar; konsisten dengan seed database.

| Contoh | Nilai |
|--------|-------|
| Karyawan | EMP003 Sari Wulandari · Kasir · Penjualan · Shift Pagi · 12 Jan 2025 · AKTIF |
| Jadwal | Shift Pagi 08:00–16:00 · istirahat 60m · 8j |
| Pekerjaan | "Perbaiki bug halaman login" · Teknis · TINGGI · estimasi 9j · deadline 20 Nov 2026 · SEDANG DIKERJAKAN |
| Beban | 180j / 160j = **112,5%** · OVERLOAD |
| Gaji | Pokok Rp 4.500.000 · Lembur Rp 0 · Bonus Rp 250.000 · Potongan Rp 50.000 · **Bersih Rp 4.700.000** · DIPROSES |
| Kehadiran | 16 Nov 2026 · 08:05 – 16:35 · 8j 30m · +0j 30m · HADIR |

---

## 12. Aksesibilitas (PRD 11)

- Kontras teks/ikon mengikuti matriks bagian 1 (semua ≥ 4,5 : 1 untuk teks normal).
- **Status tidak hanya warna:** fill + ikon + label (bagian 6.4); beban kerja = persen + badge + segmen kelebihan; deadline terlewat = ikon + teks tebal; potongan = tanda `−`; masked = ikon kunci.
- **Fokus keyboard** selalu terlihat (outline hitam 3px + offset 3px) di semua elemen interaktif; urutan tab mengikuti urutan visual; modal & drawer menjebak fokus dan menutup dengan `Esc`.
- Target klik minimal 36px; ikon-saja wajib `aria-label`.
- Teks minimum 12px; tidak ada teks di atas gambar/pola.
- Jangan mengandalkan hover untuk informasi penting (tooltip hanya melengkapi label).

---

## 13. Do & Don't

### Do
- Gunakan hanya enam warna pada bagian 1, dengan pasangan teks/ikon dari matriks kontras.
- Beri **semua** elemen interaktif dan wadah border 3px solid `#111111` + hard shadow offset tanpa blur.
- Pakai radius 0 di mana-mana (kecuali radio & titik status).
- Gunakan ikon Fill satu warna yang kontras terhadap latarnya.
- Bedakan state hanya dengan `transform`, `box-shadow`, label, dan ikon.
- Pertahankan sidebar 5 item; letakkan Gaji dan Beban Kerja sebagai tab/panel di dalam Karyawan, Pekerjaan, dan Dashboard.
- Pakai tabel berbingkai tunggal untuk daftar data; kartu hanya untuk KPI, widget absen, slip gaji, profil.
- Tampilkan status dengan fill + ikon + label.
- Nonaktifkan, jangan hapus, data master yang sudah dipakai.

### Don't
- Jangan menambah warna: tidak ada putih, abu-abu, pastel, gradien, opacity, atau shadow transparan/berwarna.
- Jangan memakai ikon outline, duotone, berwarna, atau emoji.
- Jangan memakai teks hitam di atas biru, atau teks krem/biru di atas kuning, hijau, atau merah.
- Jangan membuat varian warna turunan untuk hover/disabled/focus (mis. "biru lebih gelap").
- Jangan memakai backdrop gelap/transparan di belakang modal.
- Jangan membuat sudut membulat, pill, atau shadow ber-blur.
- Jangan menaruh kartu di dalam kartu, atau menumpuk banyak kartu untuk menampilkan daftar.
- Jangan menambah item sidebar di luar lima menu PRD, dan jangan menaruh Profil/Logout di sidebar.
- Jangan memakai glassmorphism, neon, ilustrasi dekoratif, atau animasi halus.
- Jangan merender tombol/tab/kolom yang tidak berhak diakses role — dan jangan menggantinya dengan versi abu-abu.

---

## 14. Quick Start

### CSS Custom Properties

```css
:root {
  /* Warna — satu-satunya 6 warna yang diizinkan */
  --color-neo-black:  #111111;
  --color-neo-cream:  #F5F1E8;
  --color-neo-blue:   #315CFF;
  --color-neo-yellow: #F5C542;
  --color-neo-green:  #35C759;
  --color-neo-red:    #FF5A5F;

  /* Font */
  --font-display: 'Space Grotesk', 'Archivo Black', ui-sans-serif, system-ui, sans-serif;
  --font-ui: 'Inter', ui-sans-serif, system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif;

  /* Skala tipe */
  --text-kpi: 48px;   --leading-kpi: 48px;
  --text-h1: 32px;    --leading-h1: 36px;
  --text-h2: 24px;    --leading-h2: 28px;
  --text-h3: 18px;    --leading-h3: 24px;
  --text-body: 14px;  --leading-body: 20px;
  --text-label: 12px; --leading-label: 16px;
  --text-caption: 12px; --leading-caption: 16px;

  /* Border */
  --border-w: 3px solid var(--color-neo-black);
  --border-w-sm: 2px solid var(--color-neo-black);

  /* Radius */
  --radius: 0px;

  /* Hard shadow — blur 0, warna solid */
  --shadow-sm: 2px 2px 0 0 var(--color-neo-black);
  --shadow-md: 4px 4px 0 0 var(--color-neo-black);
  --shadow-lg: 6px 6px 0 0 var(--color-neo-black);
  --shadow-xl: 8px 8px 0 0 var(--color-neo-black);
  --shadow-none: none;

  /* Spasi */
  --spacing-4: 4px;   --spacing-8: 8px;   --spacing-12: 12px;
  --spacing-16: 16px; --spacing-20: 20px; --spacing-24: 24px;
  --spacing-32: 32px; --spacing-40: 40px; --spacing-48: 48px;
  --spacing-64: 64px;

  /* Layout */
  --sidebar-w: 240px;
  --topbar-h: 72px;
  --content-padding: 32px;
  --grid-gap: 24px;
  --card-padding: 24px;
  --drawer-w: 480px;
}

body {
  background: var(--color-neo-cream);
  color: var(--color-neo-black);
  font: 500 var(--text-body)/var(--leading-body) var(--font-ui);
  font-feature-settings: "tnum" on;
}
```

### Tailwind v4

```css
@theme {
  --color-neo-black:  #111111;
  --color-neo-cream:  #F5F1E8;
  --color-neo-blue:   #315CFF;
  --color-neo-yellow: #F5C542;
  --color-neo-green:  #35C759;
  --color-neo-red:    #FF5A5F;

  --font-display: 'Space Grotesk', 'Archivo Black', ui-sans-serif, system-ui, sans-serif;
  --font-ui: 'Inter', ui-sans-serif, system-ui, sans-serif;

  --shadow-neo-sm: 2px 2px 0 0 #111111;
  --shadow-neo-md: 4px 4px 0 0 #111111;
  --shadow-neo-lg: 6px 6px 0 0 #111111;
  --shadow-neo-xl: 8px 8px 0 0 #111111;

  --radius-*: initial;   /* radius 0 di seluruh aplikasi */
}
```

### Contoh Komponen

```css
.btn {
  display: inline-flex; align-items: center; gap: 8px;
  height: 44px; padding: 0 20px;
  border: var(--border-w); border-radius: 0;
  font: 700 14px/1 var(--font-ui); letter-spacing: .02em;
  box-shadow: var(--shadow-md);
  transition: transform 100ms steps(3), box-shadow 100ms steps(3);
}
.btn:hover   { transform: translate(-2px,-2px); box-shadow: var(--shadow-lg); }
.btn:active  { transform: translate(4px,4px);   box-shadow: none; }
.btn:focus-visible { outline: 3px solid var(--color-neo-black); outline-offset: 3px; }
.btn:disabled { box-shadow: none; cursor: not-allowed; }

.btn--primary   { background: var(--color-neo-blue);   color: var(--color-neo-cream); }
.btn--secondary { background: var(--color-neo-yellow); color: var(--color-neo-black); }
.btn--neutral   { background: var(--color-neo-cream);  color: var(--color-neo-black); }
.btn--success   { background: var(--color-neo-green);  color: var(--color-neo-black); }
.btn--danger    { background: var(--color-neo-red);    color: var(--color-neo-black); }
.btn svg        { width: 20px; height: 20px; fill: currentColor; } /* ikon solid, warna = teks tombol */

.badge {
  display: inline-flex; align-items: center; gap: 6px; height: 28px; padding: 0 10px;
  border: var(--border-w-sm); box-shadow: var(--shadow-sm);
  font: 700 12px/16px var(--font-ui); text-transform: uppercase; letter-spacing: .04em;
}
.badge--done    { background: var(--color-neo-green);  color: var(--color-neo-black); }
.badge--running { background: var(--color-neo-blue);   color: var(--color-neo-cream); }
.badge--review  { background: var(--color-neo-yellow); color: var(--color-neo-black); }
.badge--danger  { background: var(--color-neo-red);    color: var(--color-neo-black); }
.badge--idle    { background: var(--color-neo-cream);  color: var(--color-neo-black); }
.badge--off     { background: var(--color-neo-black);  color: var(--color-neo-cream); }
```

---

## 15. Catatan Keputusan Desain (celah di PRD yang harus Anda putuskan)

Keputusan di bawah diambil agar desain tetap utuh; konfirmasi atau ganti sebelum implementasi.

1. **Beban Kerja dan Gaji tidak punya menu sidebar** di PRD (sidebar dikunci 5 item). Dokumen ini menaruhnya sebagai tab di Pekerjaan/Karyawan dan ringkasan di Dashboard. Bila PRD ingin menu sendiri, aturan sidebar 5 item harus diubah.
2. **Warna biru vs hitam di atas biru:** PRD tidak menyebut warna teks di atas primary `#315CFF`. Dokumen ini menetapkan **krem** (4,54 : 1), bukan hitam (3,69 : 1, gagal AA).
3. **Tanpa warna putih/abu-abu:** karena larangan menambah warna, kartu dan kanvas sama-sama krem; pemisahan oleh border + shadow. Disabled = tanpa shadow + ikon kunci (bukan abu-abu).
4. **Tanpa backdrop modal:** overlay gelap butuh transparansi (dilarang). Pengganti: halaman inert + shadow `8px`.
5. **Ambang status beban kerja tidak didefinisikan PRD.** PRD hanya bilang "di atas kapasitas = peringatan", sementara data contoh SQL menandai 112,5% sebagai `high`, bukan `overload`. UI dirancang: banner peringatan merah muncul untuk **setiap beban > 100%**, badge mengikuti field `status` dari backend. Tentukan ambang `underload/normal/high/overload` secara eksplisit.
6. **Siapa yang boleh memindahkan Ditinjau → Selesai** tidak dijelaskan PRD. UI hanya merender tombol transisi yang dikembalikan backend.
7. **Satu warna avatar untuk semua pengguna** (kuning) demi konsistensi; warna acak per pengguna dianggap warna turunan.
8. **Shadow "ringan" di PRD 12 vs "hard shadow" di aturan desain:** diselesaikan dengan offset kecil (2–8px) dan hanya warna `#111111`.
