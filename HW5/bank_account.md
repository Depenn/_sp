# Bank Account Simulation: Race Condition & Mutex

## Overview
This program simulates a bank account where multiple threads concurrently perform deposit and withdrawal operations. It demonstrates how a mutex prevents race conditions.

## How Race Condition Occurs
Without a mutex, multiple threads could read the balance, modify it, and write it back simultaneously. The "Read-Modify-Write" cycle is non-atomic, meaning one thread's update can be overwritten by another thread before it is saved.

## How Mutex Prevents It
The `pthread_mutex_t lock` ensures that only one thread can execute the critical section (balance modification) at a time. The sequence is:
1. **Lock:** `pthread_mutex_lock(&lock)` - Thread acquires exclusive access
2. **Critical Section:** `balance += 10.0; balance -= 10.0;` - Read-Modify-Write is atomic
3. **Unlock:** `pthread_mutex_unlock(&lock)` - Thread releases access, allowing others to proceed

## Compilation and Execution

### Compile
```bash
gcc -o bank_account bank_account.c -lpthread
```

### Run
```bash
./bank_account
```

### Expected Output
```
Starting balance: 0.00
Creating 4 threads with 100000 operations each...

Thread 1 completed 100000 deposit/withdrawal pairs.
Thread 2 completed 100000 deposit/withdrawal pairs.
Thread 3 completed 100000 deposit/withdrawal pairs.
Thread 4 completed 100000 deposit/withdrawal pairs.

Final balance: 0.00
Expected balance: 0.00
SUCCESS: Balance is correct. Mutex prevented race condition.
```
