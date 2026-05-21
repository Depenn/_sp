#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>

#define NUM_PHILOSOPHERS 5
#define THINK_TIME 1
#define EAT_TIME 1
#define DEADLOCK_TIMEOUT 3

pthread_mutex_t forks[NUM_PHILOSOPHERS];

void *philosopher_deadlock(void *arg) {
    int id = *((int *)arg);
    int left = id;
    int right = (id + 1) % NUM_PHILOSOPHERS;

    printf("Philosopher %d is thinking...\n", id + 1);
    sleep(THINK_TIME);

    printf("Philosopher %d is hungry, picking up left fork (%d)...\n", id + 1, left + 1);
    pthread_mutex_lock(&forks[left]);

    usleep(100000);

    printf("Philosopher %d is picking up right fork (%d)...\n", id + 1, right + 1);
    pthread_mutex_lock(&forks[right]);

    printf("Philosopher %d is eating...\n", id + 1);
    sleep(EAT_TIME);

    pthread_mutex_unlock(&forks[right]);
    pthread_mutex_unlock(&forks[left]);

    printf("Philosopher %d finished eating.\n", id + 1);
    return NULL;
}

int main() {
    pthread_t philosophers[NUM_PHILOSOPHERS];
    int ids[NUM_PHILOSOPHERS];

    for (int i = 0; i < NUM_PHILOSOPHERS; i++)
        pthread_mutex_init(&forks[i], NULL);

    printf("=== Dining Philosophers - DEADLOCK VERSION ===\n");
    printf("%d philosophers at the table.\n", NUM_PHILOSOPHERS);
    printf("Each philosopher picks up LEFT fork first, then RIGHT fork.\n");
    printf("If all pick up left fork simultaneously, DEADLOCK occurs.\n\n");

    for (int i = 0; i < NUM_PHILOSOPHERS; i++) {
        ids[i] = i;
        pthread_create(&philosophers[i], NULL, philosopher_deadlock, &ids[i]);
    }

    sleep(DEADLOCK_TIMEOUT);
    printf("\n*** After %d seconds: Program is stuck. Deadlock detected! ***\n", DEADLOCK_TIMEOUT);
    printf("*** All philosophers are holding one fork and waiting for another. ***\n");

    for (int i = 0; i < NUM_PHILOSOPHERS; i++)
        pthread_cancel(philosophers[i]);

    for (int i = 0; i < NUM_PHILOSOPHERS; i++)
        pthread_mutex_destroy(&forks[i]);

    printf("\nProgram terminated due to deadlock.\n");
    return 0;
}
