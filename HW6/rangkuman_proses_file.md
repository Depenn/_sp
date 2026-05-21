# Rangkuman Konsep Proses dan File di Linux

Dokumen ini merangkum konsep-konsep dasar terkait manajemen proses dan operasi file di sistem operasi Linux, berdasarkan materi dari repositori GitHub ccc114b/cccocw. Konsep-konsep yang dibahas meliputi `fork`, `execvp`, `open`, `close`, `read`, `write`, `dup2`, serta standar file descriptor `stdin`, `stdout`, dan `stderr`.

## 1. Manajemen Proses

### 1.1. `fork()`
Fungsi `fork()` digunakan untuk membuat proses anak (child process) yang merupakan duplikat dari proses induk (parent process) yang memanggilnya. Setelah `fork()` dipanggil, kedua proses (induk dan anak) akan melanjutkan eksekusi dari titik yang sama. Perbedaannya adalah nilai kembalian dari `fork()`:
*   Pada proses induk, `fork()` mengembalikan ID proses (PID) dari proses anak.
*   Pada proses anak, `fork()` mengembalikan nilai 0.
*   Jika `fork()` gagal, ia mengembalikan -1.

Proses anak mewarisi salinan ruang alamat memori, file descriptor yang terbuka, dan atribut lainnya dari proses induk. Namun, ruang alamat memori ini biasanya diimplementasikan dengan mekanisme *copy-on-write*, yang berarti salinan fisik hanya dibuat ketika salah satu proses mencoba memodifikasi memori tersebut.

### 1.2. `execvp()`
Fungsi `execvp()` (dan keluarga fungsi `exec` lainnya) digunakan untuk mengganti citra program (program image) dari proses yang sedang berjalan dengan program baru. Ini berarti bahwa setelah `execvp()` berhasil dipanggil, kode program yang lama akan dihentikan dan digantikan oleh kode program baru yang ditentukan. PID proses tidak berubah, hanya program yang dieksekusi yang berganti.

Sintaks dasar `execvp()` adalah `int execvp(const char *file, char *const argv[]);` di mana `file` adalah nama program yang akan dieksekusi, dan `argv` adalah array string yang berisi argumen baris perintah untuk program baru tersebut.

### 1.3. Hubungan `fork()` dan `execvp()`
`fork()` dan `execvp()` sering digunakan bersamaan untuk membuat proses baru yang menjalankan program yang berbeda. Alurnya adalah sebagai berikut:
1.  Proses induk memanggil `fork()` untuk membuat proses anak.
2.  Proses anak (yang memiliki PID 0 dari `fork()`) kemudian memanggil `execvp()` untuk memuat dan menjalankan program baru. Proses induk dapat menunggu proses anak selesai menggunakan `wait()` atau `waitpid()`.

## 2. File Descriptors (stdin, stdout, stderr)

Sistem operasi Linux/UNIX menggunakan *file descriptor* (FD) sebagai identifikasi numerik untuk mengakses file atau perangkat I/O. Secara default, setiap proses memiliki tiga file descriptor standar yang terbuka saat dimulai:
*   **0 (STDIN_FILENO)**: Input standar, biasanya terhubung ke keyboard.
*   **1 (STDOUT_FILENO)**: Output standar, biasanya terhubung ke layar konsol.
*   **2 (STDERR_FILENO)**: Error standar, juga biasanya terhubung ke layar konsol untuk pesan kesalahan.

## 3. Operasi File Dasar

### 3.1. `open()`
Fungsi `open()` digunakan untuk membuka file atau membuat file baru. Ia mengembalikan file descriptor integer yang akan digunakan untuk operasi I/O selanjutnya pada file tersebut. Jika `open()` berhasil, ia akan mengembalikan file descriptor terkecil yang tidak terpakai (biasanya dimulai dari 3, karena 0, 1, 2 sudah digunakan).

### 3.2. `close()`
Fungsi `close()` digunakan untuk menutup file descriptor yang terbuka. Ini melepaskan sumber daya sistem yang terkait dengan file tersebut dan membuat file descriptor tersedia untuk digunakan kembali oleh `open()` atau `dup()`.

### 3.3. `read()`
Fungsi `read()` digunakan untuk membaca data dari file atau perangkat I/O yang diidentifikasi oleh file descriptor. Sintaksnya adalah `ssize_t read(int fd, void *buf, size_t count);`, di mana `fd` adalah file descriptor, `buf` adalah buffer tempat data akan disimpan, dan `count` adalah jumlah byte maksimum yang akan dibaca.

### 3.4. `write()`
Fungsi `write()` digunakan untuk menulis data ke file atau perangkat I/O yang diidentifikasi oleh file descriptor. Sintaksnya adalah `ssize_t write(int fd, const void *buf, size_t count);`, di mana `fd` adalah file descriptor, `buf` adalah buffer yang berisi data yang akan ditulis, dan `count` adalah jumlah byte yang akan ditulis.

## 4. Manipulasi File Descriptor (`dup2()`)

Fungsi `dup2()` digunakan untuk menduplikasi file descriptor. Secara spesifik, `dup2(oldfd, newfd)` akan membuat `newfd` menunjuk ke file atau perangkat yang sama dengan `oldfd`. Jika `newfd` sudah terbuka, ia akan ditutup terlebih dahulu sebelum diduplikasi. Ini sangat berguna untuk pengalihan I/O (I/O redirection), misalnya, mengalihkan `stdout` ke file alih-alih ke konsol.

Contoh penggunaan `dup2()`:
```c
// Mengalihkan stdout (file descriptor 1) ke file_descriptor_baru
dup2(file_descriptor_baru, 1);
```

## Kesimpulan

Konsep `fork`, `execvp`, `open`, `close`, `read`, `write`, dan `dup2` adalah fundamental dalam pemrograman sistem Linux. Memahami bagaimana proses dibuat, program dieksekusi, dan I/O dikelola melalui file descriptor sangat penting untuk mengembangkan aplikasi sistem yang efisien dan kuat, termasuk shell kustom dan program yang berinteraksi dengan file dan proses lain.
