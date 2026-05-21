# Summary of Process and File Concepts in Linux

This document summarizes the fundamental concepts related to process management and file operations in the Linux operating system, based on materials from the ccc114b/cccocw GitHub repository. The concepts discussed include `fork`, `execvp`, `open`, `close`, `read`, `write`, `dup2`, as well as the standard file descriptors `stdin`, `stdout`, and `stderr`.

## 1. Process Management

### 1.1. `fork()`
The `fork()` function is used to create a child process that is a duplicate of the parent process that called it. After `fork()` is called, both processes (parent and child) will continue execution from the same point. The difference lies in the return value of `fork()`:
*   In the parent process, `fork()` returns the process ID (PID) of the child process.
*   In the child process, `fork()` returns 0.
*   If `fork()` fails, it returns -1.

The child process inherits a copy of the memory address space, open file descriptors, and other attributes from the parent process. However, this memory address space is typically implemented with a *copy-on-write* mechanism, meaning a physical copy is only made when one of the processes attempts to modify that memory.

### 1.2. `execvp()`
The `execvp()` function (and other `exec` family functions) is used to replace the program image of the currently running process with a new program. This means that after `execvp()` is successfully called, the old program code will be terminated and replaced by the new program code specified. The process's PID does not change; only the executed program changes.

The basic syntax of `execvp()` is `int execvp(const char *file, char *const argv[]);` where `file` is the name of the program to be executed, and `argv` is an array of strings containing the command-line arguments for the new program.

### 1.3. Relationship between `fork()` and `execvp()`
`fork()` and `execvp()` are often used together to create a new process that runs a different program. The flow is as follows:
1.  The parent process calls `fork()` to create a child process.
2.  The child process (which has a PID of 0 from `fork()`) then calls `execvp()` to load and execute the new program. The parent process can wait for the child process to complete using `wait()` or `waitpid()`.

## 2. File Descriptors (stdin, stdout, stderr)

The Linux/UNIX operating system uses *file descriptors* (FDs) as numerical identifiers to access files or I/O devices. By default, every process has three standard file descriptors open when it starts:
*   **0 (STDIN_FILENO)**: Standard input, typically connected to the keyboard.
*   **1 (STDOUT_FILENO)**: Standard output, typically connected to the console screen.
*   **2 (STDERR_FILENO)**: Standard error, also typically connected to the console screen for error messages.

## 3. Basic File Operations

### 3.1. `open()`
The `open()` function is used to open an existing file or create a new one. It returns an integer file descriptor that will be used for subsequent I/O operations on that file. If `open()` is successful, it will return the smallest unused file descriptor (usually starting from 3, as 0, 1, 2 are already in use).

### 3.2. `close()`
The `close()` function is used to close an open file descriptor. This releases system resources associated with the file and makes the file descriptor available for reuse by `open()` or `dup()`.

### 3.3. `read()`
The `read()` function is used to read data from a file or I/O device identified by a file descriptor. Its syntax is `ssize_t read(int fd, void *buf, size_t count);`, where `fd` is the file descriptor, `buf` is the buffer where the data will be stored, and `count` is the maximum number of bytes to read.

### 3.4. `write()`
The `write()` function is used to write data to a file or I/O device identified by a file descriptor. Its syntax is `ssize_t write(int fd, const void *buf, size_t count);`, where `fd` is the file descriptor, `buf` is the buffer containing the data to be written, and `count` is the number of bytes to write.

## 4. File Descriptor Manipulation (`dup2()`)

The `dup2()` function is used to duplicate a file descriptor. Specifically, `dup2(oldfd, newfd)` will make `newfd` point to the same file or device as `oldfd`. If `newfd` is already open, it will be closed first before being duplicated. This is very useful for I/O redirection, for example, redirecting `stdout` to a file instead of the console.

Example usage of `dup2()`:
```c
// Redirect stdout (file descriptor 1) to new_file_descriptor
dup2(new_file_descriptor, 1);
```

## Conclusion

The concepts of `fork`, `execvp`, `open`, `close`, `read`, `write`, and `dup2` are fundamental in Linux system programming. Understanding how processes are created, programs are executed, and I/O is managed through file descriptors is crucial for developing efficient and robust system applications, including custom shells and programs that interact with files and other processes.
