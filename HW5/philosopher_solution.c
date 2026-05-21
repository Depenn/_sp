#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>

#define NUM_PHILOSOPHERS 5
#define THINK_TIME 1
#define EAT_TIME 1

pthread_mutex_t forks[NUM_PHILOSOPHERS];

void *philosopher_solution(void *arg) {
    int id = *((int *)arg);
    int left, right;

    if (id == NUM_PHILOSOPHERS - 1) {
        left = (id + 1) % NUM_PHILOSOPHERS;
        right = id;
    } else {
        left = id;
        right = (id + 1) % NUM_PHILOSOPHERS;
    }

    for (int meal = 0; meal < 3; meal++) {
        printf("Philosopher %d is thinking... (meal %d)\n", id + 1, meal + 1);
        sleep(THINK_TIME);

        printf("Philosopher %d picks up fork %d, then fork %d...\n", id + 1, left + 1, right + 1);
        pthread_mutex_lock(&forks[left]);
        pthread_mutex_lock(&forks[right]);

        printf("Philosopher %d is eating... (meal %d)\n", id + 1, meal + 1);
        sleep(EAT_TIME);

        pthread_mutex_unlock(&forks[right]);
        pthread_mutex_unlock(&forks[left]);

        printf("Philosopher %d finished meal %d.\n", id + 1, meal + 1);
    }
    return NULL;
}

int main() {
    pthread_t philosophers[NUM_PHILOSOPHERS];
    int ids[NUM_PHILOSOPHERS];

    for (int i = 0; i < NUM_PHILOSOPHERS; i++)
        pthread_mutex_init(&forks[i], NULL);

    printf("=== Dining Philosophers - SOLUTION VERSION ===\n");
    printf("%d philosophers at the table.\n", NUM_PHILOSOPHERS);
    printf("Philosophers 1-4 pick up LEFT fork first, then RIGHT.\n");
    printf("Philosopher 5 picks up RIGHT fork first, then LEFT.\n");
    printf("This breaks the circular wait condition and prevents deadlock.\n\n");

    for (int i = 0; i < NUM_PHILOSOPHERS; i++) {
        ids[i] = i;
        pthread_create(&philosophers[i], NULL, philosopher_solution, &ids[i]);
    }

    for (int i = 0; i < NUM_PHILOSOPHERS; i++)
        pthread_join(philosophers[i], NULL);

    printf("\nAll philosophers finished eating. No deadlock!\n");

    for (int i = 0; i < NUM_PHILOSOPHERS; i++)
        pthread_mutex_destroy(&forks[i]);

    return 0;
}
