#include "types.h"   
#include "user.h"   // for uptime(), fork() and printf()
int cpu_load() {
    volatile int i, j, k;                  // volatile to prevent compiler optimization
    for (i = 0; i < 1000; i++) {
        for (j = 0; j < 100000; j++) {
            // CPU performs loops and waste the time 
            k = i + j;
        }
    }
    return k;
}
int main() {
    int pid1, pid2;
    int start = uptime();
    // fork the first child process and waste time
    pid1 = fork();
    if (pid1 == 0) {   // child process 1
        cpu_load();
        exit();
    }
    // fork the second child process and waste time
    pid2 = fork();
    if (pid2 == 0) {   // child process 2
        cpu_load();
        exit();
    }
    // wait for both child processes to finish before going back to parent process
    wait();
    wait();
    // print time elapsed
    int end = uptime();
    printf(1, "Time elapsed: %d\n", end - start);
    // exit the parent process
    exit();
}