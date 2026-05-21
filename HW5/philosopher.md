# Dining Philosophers: Deadlock & Solution

## The Deadlock Version (`philosopher_deadlock.c`)

### Why It Deadlocks
In this version, every philosopher follows the same rule: pick up the **left fork** first, then the **right fork**. When all 5 philosophers become hungry simultaneously:

1. Philosopher 1 grabs Fork 1 (left)
2. Philosopher 2 grabs Fork 2 (left)
3. Philosopher 3 grabs Fork 3 (left)
4. Philosopher 4 grabs Fork 4 (left)
5. Philosopher 5 grabs Fork 5 (left)

Now every philosopher holds one fork and waits for the other. This satisfies all four **Coffman Conditions** for deadlock:
- **Mutual Exclusion:** Forks cannot be shared
- **Hold and Wait:** Each philosopher holds one fork while waiting for another
- **No Preemption:** Forks cannot be forcibly taken
- **Circular Wait:** Philosopher 1 waits for Fork 2 (held by Phil 2), who waits for Fork 3, etc., forming a cycle

### Demonstration
The program introduces a small delay between picking up left and right forks. After 3 seconds, it detects that all threads are stuck and forcibly cancels them.

---

## The Solution Version (`philosopher_solution.c`)

### How Deadlock Is Resolved
The solution breaks the **Circular Wait** condition by changing the lock acquisition order for **one philosopher** (Philosopher 5):

- Philosophers 1-4: pick up **LEFT** fork first, then **RIGHT**
- Philosopher 5: picks up **RIGHT** fork first, then **LEFT**

This means Philosopher 5 competes for the same first fork as Philosopher 4. One of them will acquire it, and the other will block — preventing the circular chain. At least one philosopher can always eat.

### Alternative Solutions
Other common approaches include:
- **Limit diners:** Allow at most N-1 philosophers to sit (using a semaphore)
- **Timeout with retry:** Use `pthread_mutex_trylock` and back off on failure
- **Arbitrator:** Use a central mutex to control access to forks

---

## Compilation and Execution

### Compile
```bash
gcc -o philosopher_deadlock philosopher_deadlock.c -lpthread
gcc -o philosopher_solution philosopher_solution.c -lpthread
```

### Run
```bash
./philosopher_deadlock    # Will deadlock after ~3 seconds
./philosopher_solution    # Runs to completion, no deadlock
```
