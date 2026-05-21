# HW5 — Concurrent Programming

Three classic OS concurrency problems solved in C with POSIX threads.

See the [main README](../README.md#hw5--concurrent-programming) for a detailed explanation of the problem, approach, implementation, and design decisions.

## Files

| File | Description |
|------|-------------|
| `philosopher_deadlock.c` | Dining Philosophers — demonstrates deadlock (all philosophers grab left fork first) |
| `philosopher_solution.c` | Dining Philosophers — breaks circular wait (philosopher 5 grabs right fork first) |
| `producer_consumer.c` | Producer-Consumer with bounded buffer using semaphores |
| `bank_account.c` | Bank account race condition resolved with a mutex |
| `* .md` | Per-problem documentation files |

## Quick Start

```bash
gcc -o philosopher_deadlock philosopher_deadlock.c -lpthread
./philosopher_deadlock

gcc -o philosopher_solution philosopher_solution.c -lpthread
./philosopher_solution

gcc -o producer_consumer producer_consumer.c -lpthread
./producer_consumer

gcc -o bank_account bank_account.c -lpthread
./bank_account
```
