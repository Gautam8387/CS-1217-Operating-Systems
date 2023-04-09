#include "pstat.h"
// Definig the maxpriority and max budget
#define MAXPRIORITY 2
#define DEFAULT_BUDGET 5
#define TICKS_TO_PROMOTE 20
#define MAXTICKET   15

// Per-CPU state
struct cpu {
  uchar apicid;                // Local APIC ID.
  struct context *scheduler;   // swtch() here to enter scheduler
  struct taskstate ts;         // Used by x86 to find stack for interrupt
  struct segdesc gdt[NSEGS];   // x86 global descriptor table
  volatile uint started;       // Has the CPU started?
  int ncli;                    // Depth of pushcli nesting.
  int intena;                  // Were interrupts enabled before pushcli?
  struct proc *proc;           // The process running on this cpu or null
};

extern struct cpu cpus[NCPU];
extern int ncpu;

//PAGEBREAK: 17
// Saved registers for kernel context switches.
// Don't need to save all the segment registers (%cs, etc),
// because they are constant across kernel contexts.
// Don't need to save %eax, %ecx, %edx, because the
// x86 convention is that the caller has saved them.
// Contexts are stored at the bottom of the stack they
// describe; the stack pointer is the address of the context.
// The layout of the context matches the layout of the stack in swtch.S
// at the "Switch stacks" comment. Switch doesn't save eip explicitly,
// but it is on the stack and allocproc() manipulates it.
struct context {
  uint edi;
  uint esi;
  uint ebx;
  uint ebp;
  uint eip;
};

enum procstate { UNUSED, EMBRYO, SLEEPING, RUNNABLE, RUNNING, ZOMBIE };
// These states are used to manage the process. 
// UNUSED is the initial state of the process. By initial state, we mean that the process is not used.
// EMBRYO is the state of the process when it is being created. Creation of the process is done by the fork() system call. In creation, the values of the process are copied from the parent process.
// SLEEPING is the state of the process when it is waiting for an event to occur. Sleep() system call is used to put the process in the sleeping state.
// RUNNABLE is the state of the process when it is ready to run. It can start executing as soon as the CPU is free.
// RUNNING is the state of the process when it is running. The process is in the running state when the CPU is executing the process.
// ZOMBIE is the state of the process when it is terminated. The process is in the zombie state when it has finished executing and is waiting to be reaped by its parent process. A process can also be a zombie if it has been killed by a signal or has no parent process.


// Per-process state
struct proc {
  uint sz;                     // Size of process memory (bytes)
  pde_t* pgdir;                // Page table
  char *kstack;                // Bottom of kernel stack for this process
  enum procstate state;        // Process state
  int pid;                     // Process ID
  struct proc *parent;         // Parent process
  struct trapframe *tf;        // Trap frame for current syscall
  struct context *context;     // swtch() here to run process
  void *chan;                  // If non-zero, sleeping on chan
  int killed;                  // If non-zero, have been killed
  struct file *ofile[NOFILE];  // Open files
  struct inode *cwd;           // Current directory
  char name[16];               // Process name (debugging)
  // MLFQ Scheduling
  int priority;                // Process priority
  int budget;                  // Process budget
  int original_priority;       // Process original priority, keep track of if process state changes
  // Lottery Scheduling
  int tickets;                 // Process tickets
  int inuse;                   // Process in use
  int ticks;                   // Process ticks
};

// Process memory is laid out contiguously, low addresses first:
//   text
//   original data and bss
//   fixed-size stack
//   expandable heap
