#include "types.h"   
#include "user.h"       // for uptime(), fork() and printf()
int main() {
    int i, j;
    int start = uptime();
    // create 15 child processes to put the IO load on the cpu
    for (i = 0; i < 15; i++) {
        if (fork() == 0) {   // child process
            for (j = 0; j < 100000; j++) {
                // do nothing
            }
            exit();
        }
    }
    // wait for all child processes to finish
    for (i = 0; i < 15; i++) {
        wait();
    }
    // Print time elapsed
    int end = uptime();
    printf(1, "Time elapsed: %d\n", end - start);
    // exit the parent process
    exit();
}