#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

#define NUM_THREADS 4
#define NUM_OPERATIONS 100000

double balance = 0.0;
pthread_mutex_t lock;

void *transaction(void *arg) {
    int thread_id = *((int *)arg);
    for (int i = 0; i < NUM_OPERATIONS; i++) {
        pthread_mutex_lock(&lock);
        balance += 10.0;
        balance -= 10.0;
        pthread_mutex_unlock(&lock);
    }
    printf("Thread %d completed %d deposit/withdrawal pairs.\n", thread_id, NUM_OPERATIONS);
    return NULL;
}

int main() {
    pthread_t threads[NUM_THREADS];
    int thread_ids[NUM_THREADS];
    pthread_mutex_init(&lock, NULL);

    printf("Starting balance: %.2f\n", balance);
    printf("Creating %d threads with %d operations each...\n\n", NUM_THREADS, NUM_OPERATIONS);

    for (int i = 0; i < NUM_THREADS; i++) {
        thread_ids[i] = i + 1;
        pthread_create(&threads[i], NULL, transaction, &thread_ids[i]);
    }

    for (int i = 0; i < NUM_THREADS; i++) {
        pthread_join(threads[i], NULL);
    }

    printf("\nFinal balance: %.2f\n", balance);
    printf("Expected balance: 0.00\n");

    if (balance == 0.0) {
        printf("SUCCESS: Balance is correct. Mutex prevented race condition.\n");
    } else {
        printf("FAILURE: Balance is incorrect. Race condition occurred.\n");
    }

    pthread_mutex_destroy(&lock);
    return 0;
}
