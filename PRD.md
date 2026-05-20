1. Kebutuhan Fungsional (Functional Requirements)
1.1 Autentikasi & Role Management

Sistem harus mendukung 3 role:

Mahasiswi (User)
Teknisi
Admin

Fitur:

Registrasi Mahasiswi
Login Mahasiswi
Login Teknisi
Login Admin
Logout
Validasi input (email, password, dll)
Role-based access control (RBAC)
1.2 Manajemen Profil
Mahasiswi
Melihat profil
Edit profil (nama, email, no HP, data motor)
Teknisi
Melihat profil
Edit profil (nama, spesialisasi, pengalaman)
Admin
Tidak wajib edit profil (opsional)
1.3 Data Sepeda Motor (User)
Tambah data motor:
Merk
Tipe
Tahun
Nomor polisi
Kilometer saat ini
Edit data motor
Hapus data motor
Relasi ke user
1.4 Monitoring oleh Teknisi
Teknisi dapat melihat daftar user
Teknisi dapat melihat detail motor user
Teknisi dapat:
Memberikan catatan monitoring
Memberikan rekomendasi servis
Memberikan status kondisi motor
1.5 Form Pengecekan Mingguan

Dibuat oleh Teknisi, diisi oleh User.

Teknisi:
Membuat form checklist (contoh):
Oli mesin
Rem
Ban
Lampu
Edit form
Hapus form
User:
Mengisi form mingguan
Submit hasil pengecekan
Sistem:
Menyimpan riwayat pengecekan
Teknisi dapat melihat hasil pengecekan
Teknisi dapat memberi feedback
1.6 Chat (User ↔ Teknisi)
Real-time chat (Supabase Realtime)
Fitur:
Kirim pesan teks
Timestamp
Status pesan (opsional)
Riwayat chat tersimpan
1.7 Edukasi (Postingan Teknisi)
Teknisi:
Create postingan edukasi
Edit postingan
Hapus postingan
User:
Melihat daftar postingan
Melihat detail postingan

Konten:

Judul
Deskripsi
Gambar (opsional)
1.8 Notifikasi (Opsional tapi direkomendasikan)
Pengingat servis berkala
Notifikasi pesan masuk
Notifikasi form baru
1.9 Admin Dashboard
Admin dapat:
Melihat statistik:
Jumlah user
Jumlah teknisi
Jumlah aktivitas
Kelola User:
Lihat data user
Edit user
Hapus user
Kelola Teknisi:
Edit
Hapus
2. Kebutuhan Non-Fungsional (Non-Functional Requirements)
2.1 Platform
Mobile app (Android)
Dibangun menggunakan Flutter
2.2 State Management
Menggunakan Provider
Struktur:
AuthProvider
UserProvider
ChatProvider
MonitoringProvider
2.3 Database & Backend

Menggunakan Supabase (MCP):

Authentication (Supabase Auth)
Database PostgreSQL
Realtime (untuk chat)
Storage (untuk gambar edukasi)
2.4 Keamanan
Password terenkripsi
Role-based access
Validasi input
Proteksi API dengan Supabase policies
2.5 Performa
Loading data cepat
Pagination untuk list data
Lazy loading untuk chat & postingan
2.6 UI/UX
Clean & modern (Material Design / minimalis)
Responsive
Mudah digunakan oleh mahasiswa
3. Kebutuhan Data (Database Requirements - Supabase)

Tabel utama:

Users
id
name
email
role (user/teknisi/admin)
phone
Motor
id
user_id
merk
tipe
tahun
no_polisi
kilometer
Monitoring
id
user_id
teknisi_id
catatan
rekomendasi
status
created_at
Form_Checklist
id
teknisi_id
judul
deskripsi
Checklist_Items
id
form_id
item_name
Checklist_Results
id
user_id
form_id
jawaban
created_at
Chat
id
sender_id
receiver_id
message
created_at
Edukasi
id
teknisi_id
judul
deskripsi
image_url
created_at
4. Arsitektur Sistem
Frontend (Flutter)
UI Layer
Provider (State Management)
Service Layer (API Supabase)
Backend (Supabase)
Auth
PostgreSQL DB
Realtime
Storage
5. Use Case Utama (Ringkas)
User registrasi → login → tambah data motor
Teknisi monitoring → beri saran
User isi form mingguan
Teknisi evaluasi
User chat dengan teknisi
Teknisi upload edukasi
Admin kelola user
6. Kebutuhan Integrasi
Supabase Auth API
Supabase Realtime API
Supabase Storage API