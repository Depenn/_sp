# Producer-Consumer Problem

## Overview
This program implements the classic Producer-Consumer problem using a bounded shared buffer. Multiple producer threads generate items and place them in the buffer, while multiple consumer threads remove and process those items.

## Synchronization Logic

Three synchronization primitives are used:

### 1. Mutex (`pthread_mutex_t mutex`)
- Protects the shared buffer from concurrent access
- Ensures only one thread (producer or consumer) can modify `in`/`out` indices at a time
- Prevents race conditions on the buffer itself

### 2. Empty Semaphore (`sem_t empty`)
- Initialized to `BUFFER_SIZE` (5)
- Tracks available empty slots in the buffer
- Producers call `sem_wait(&empty)` before inserting — blocks if buffer is full
- Consumers call `sem_post(&empty)` after removing — signals an empty slot

### 3. Full Semaphore (`sem_t full`)
- Initialized to `0`
- Tracks items available in the buffer
- Consumers call `sem_wait(&full)` before removing — blocks if buffer is empty
- Producers call `sem_post(&full)` after inserting — signals an item is available

## Data Flow
1. Producer waits for an empty slot (`sem_wait(&empty)`)
2. Producer locks the buffer mutex
3. Producer inserts item and advances `in` index (circular buffer)
4. Producer unlocks mutex and signals an item is available (`sem_post(&full)`)
5. Consumer waits for an item (`sem_wait(&full)`)
6. Consumer locks the buffer mutex
7. Consumer removes item and advances `out` index
8. Consumer unlocks mutex and signals an empty slot (`sem_post(&empty)`)

## Compilation and Execution

### Compile
```bash
gcc -o producer_consumer producer_consumer.c -lpthread
```

### Run
```bash
./producer_consumer
```
