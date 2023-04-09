#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "x86.h"
#include "proc.h"
#include "spinlock.h"

// Define three levels of priority for MLFQ Scheduler
struct proc *mlfq_queue[MAXPRIORITY+1][2*NPROC];
// top queue has highest priority
int mlfq_queue_size[MAXPRIORITY+1] = {-1,-1,-1};

struct {
  struct spinlock lock;
  struct proc proc[NPROC];
  // timer variables
  uint PromoteAtTime;
  
} ptable;

static struct proc *initproc;

int nextpid = 1;
extern void forkret(void);
extern void trapret(void);

static void wakeup1(void *chan);

void
pinit(void)
{
  initlock(&ptable.lock, "ptable");
}

// Must be called with interrupts disabled
int
cpuid() {
  return mycpu()-cpus;
}

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
  int apicid, i;
  
  if(readeflags()&FL_IF)
    panic("mycpu called with interrupts enabled\n");

  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
    if (cpus[i].apicid == apicid)    // return the address of the cpu structure.
      return &cpus[i];
  }
  panic("unknown apicid\n");
}

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
  struct cpu *c;
  struct proc *p;
  pushcli();
  c = mycpu();
  p = c->proc;
  popcli();
  return p;
}

//PAGEBREAK: 32
// Look in the process table for an UNUSED proc.
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
  // p->priority = MAXPRIORITY;
  // p->original_priority = MAXPRIORITY;
  // p->budget = DEFAULT_BUDGET;
  // mlfq_queue_size[MAXPRIORITY]++;
  // mlfq_queue[MAXPRIORITY][mlfq_queue_size[MAXPRIORITY]] = p;

  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
  p->pid = nextpid++;
  // set MAXPRIORITY and DEFAULT_BUDGET
  // p->priority = MAXPRIORITY;
  // p->original_priority = MAXPRIORITY;
  // p->budget = DEFAULT_BUDGET;
  // // New process created is inserted at the end (tail) of the queue
  // mlfq_queue_size[MAXPRIORITY]++;
  // mlfq_queue[MAXPRIORITY][mlfq_queue_size[MAXPRIORITY]] = p;

  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
  p->tf = (struct trapframe*)sp;

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
  *(uint*)sp = (uint)trapret;

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
  p->context->eip = (uint)forkret;

  return p;
}

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
  
  initproc = p;
  if((p->pgdir = setupkvm()) == 0)
    panic("userinit: out of memory?");
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
  p->sz = PGSIZE;
  memset(p->tf, 0, sizeof(*p->tf));
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
  p->tf->es = p->tf->ds;
  p->tf->ss = p->tf->ds;
  p->tf->eflags = FL_IF;
  p->tf->esp = PGSIZE;
  p->tf->eip = 0;  // beginning of initcode.S

  safestrcpy(p->name, "initcode", sizeof(p->name));
  p->cwd = namei("/");

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);

  p->state = RUNNABLE;
  // set promotion time
  ptable.PromoteAtTime = ticks + TICKS_TO_PROMOTE;

  release(&ptable.lock);
}

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  uint sz;
  struct proc *curproc = myproc();

  sz = curproc->sz;
  if(n > 0){
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
      return -1;
  } else if(n < 0){
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
      return -1;
  }
  curproc->sz = sz;
  switchuvm(curproc);
  return 0;
}

// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();

  // Allocate process.
  if((np = allocproc()) == 0){
    return -1;
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
    kfree(np->kstack);
    np->kstack = 0;
    np->state = UNUSED;
    return -1;
  }
  np->sz = curproc->sz;
  np->parent = curproc;
  *np->tf = *curproc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
    if(curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));

  pid = np->pid;

  acquire(&ptable.lock);

  np->state = RUNNABLE;
  // set the priority of the child process to highest priority
  np->priority = MAXPRIORITY;
  np->original_priority = MAXPRIORITY;
  // // set the budget of the child process to default budget
  np->budget = DEFAULT_BUDGET;
  // // New process created is inserted at the end (tail) of the queue
  mlfq_queue_size[MAXPRIORITY]++;
  mlfq_queue[MAXPRIORITY][mlfq_queue_size[MAXPRIORITY]] = np;
  // cprintf("MAXPRIORITY queue size: %d\n",mlfq_queue_size[MAXPRIORITY]);

  release(&ptable.lock);

  return pid;
}

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
  struct proc *curproc = myproc();
  struct proc *p;
  int fd;

  if(curproc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
    if(curproc->ofile[fd]){
      fileclose(curproc->ofile[fd]);
      curproc->ofile[fd] = 0;
    }
  }

  begin_op();
  iput(curproc->cwd);
  end_op();
  curproc->cwd = 0;

  acquire(&ptable.lock);

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->parent == curproc){
      p->parent = initproc;
      if(p->state == ZOMBIE)
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
  // MLFQ: Remove the process from the queue
  // for(int i = 0; i < mlfq_queue_size[curproc->priority]; i++){
  //   if(mlfq_queue[curproc->priority][i] == curproc){
  //     for(int j = i; j < mlfq_queue_size[curproc->priority]-1; j++){
  //       mlfq_queue[curproc->priority][j] = mlfq_queue[curproc->priority][j+1];
  //     }
  //     mlfq_queue_size[curproc->priority]--;
  //     break;
  //   }
  // }

  sched();
  panic("zombie exit");
}

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
  
  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != curproc)
        continue;
      havekids = 1;
      if(p->state == ZOMBIE){
        // Found one.
        pid = p->pid;
        kfree(p->kstack);
        p->kstack = 0;
        freevm(p->pgdir);
        p->pid = 0;
        p->parent = 0;
        p->name[0] = 0;
        p->killed = 0;
        p->state = UNUSED;
        release(&ptable.lock);
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
      release(&ptable.lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-slee
  }
}
// Uptime function will help calculate the budget of the process
// Not required anymore
/*
int
uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}
*/

//PAGEBREAK: 42
// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
  struct proc *p;
  struct cpu *c = mycpu();
  c->proc = 0;
  
  for(;;){
    // Enable interrupts on this processor.
    sti();      // STI — Set Interrupt Flag.
    if(holding(&ptable.lock))
      release(&ptable.lock);

    acquire(&ptable.lock);      
    
    /****       Periodic Priority Adjustment: Part 3        *****/
    if(ticks >= ptable.PromoteAtTime){
      //cprintf("Promotion Time");
      for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
        // if(p->state == ZOMBIE){
        //   continue;
        // }
        if(p->state != ZOMBIE && p->priority < MAXPRIORITY){
          // delete the process from the queue at that priority level
          for(int i = 0; i <= mlfq_queue_size[p->priority]; i++){
            if(mlfq_queue[p->priority][i] == p){
              for(int j = i; j < mlfq_queue_size[p->priority]; j++){
                mlfq_queue[p->priority][j] = mlfq_queue[p->priority][j+1];
              }
              mlfq_queue_size[p->priority]--;
              break;
            }
          }
          // p->priority++;
          setpriority(p->pid, p->priority + 1);
          // p->priority= p->priority + 1;
          // p->original_priority = p->priority;
          p->budget = DEFAULT_BUDGET;
          // // send it to the end of the next priority queue
          mlfq_queue_size[p->priority]++;
          mlfq_queue[p->priority][mlfq_queue_size[p->priority]] = p;
        }
      }
      ptable.PromoteAtTime = ticks + TICKS_TO_PROMOTE;
    }
    // /****       MLFQ Scheduler        *****/
    for(int i = MAXPRIORITY; i >= 0; i--){
      if(mlfq_queue_size[i] < 0){
        // cprintf("Empty queue at level: %d\n",i);
        continue;
      }
      // cprintf("Selected level: %d, with size: %d\n", i, mlfq_queue_size[i]);
      while(mlfq_queue_size[i]>=0){
        // cprintf("Selected level: %d, with size: %d\n", i, mlfq_queue_size[i]);
        int check = 0;
        for(int k=0; k <= mlfq_queue_size[i]; k++){
          // cprintf("State of process: %d, at level: %d, is: %d\n", k, i, mlfq_queue[i][k]->state);
          if(mlfq_queue[i][k]->state != RUNNABLE && k==mlfq_queue_size[i]){
              // cprintf("NOT RUNNABLE Process\n");
              break;
          }
          if(mlfq_queue[i][k]->state != RUNNABLE){
            // cprintf("NOT RUNNABLE\n");
            continue;
          }
          // cprintf("RUNNABLE at level: %d and number: %d\n", i,k);
          p = mlfq_queue[i][k];
          // remove the process from the queue
          for(int temp = k; temp < mlfq_queue_size[i]; temp++){
            mlfq_queue[i][temp] = mlfq_queue[i][temp+1];
          }
          // cprintf("q size: %d\n", mlfq_queue_size[i]);
          mlfq_queue_size[i]--;
          check = 1;
          // cprintf("q size: %d\n", mlfq_queue_size[i]);
          //cprintf("check before run\n");

          // Note the start time of the process
          //cprintf("process name: %s", p->name);
          int start_time = ticks; //uptime();
          c->proc = p;
          //cprintf("check\n");
          switchuvm(p);
          p->state = RUNNING;
          swtch(&(c->scheduler), p->context);
          switchkvm();
          c->proc = 0;
          int end_time = ticks; //uptime();
        //cprintf("check after run\n");
          // Update the budget of the process
          p->budget = p->budget - (end_time - start_time);
          //cprintf("budget: %d\n", p->budget);
          
          if(p->budget<=0){
            //cprintf("DEMOTED\n");
            //process already removed from current queue
            // demote priority and place it at the tail of the new quque
            if(p->priority > 0){
              // p->priority--;
              // p->budget = DEFAULT_BUDGET;
              setpriority(p->pid, p->priority - 1);
              p->original_priority = p->priority;
              mlfq_queue_size[p->priority]++;
              mlfq_queue[p->priority][mlfq_queue_size[p->priority]] = p;
            }
            else{
              // if priority is 0 then send to the end of the queue
              mlfq_queue_size[p->priority]++;
              mlfq_queue[p->priority][mlfq_queue_size[p->priority]] = p;
            }
          }
          else{
            //if process id still RUNNABLE then put it at the end of the queue
            // if(p->state == RUNNABLE){
            //cprintf("At the tail\n");
            mlfq_queue_size[p->priority]++;
            mlfq_queue[p->priority][mlfq_queue_size[p->priority]] = p;
          // }
          }
        }
        if(check==0){
          break;
        }
      }
    }
    release(&ptable.lock);
  }
}

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state. Saves and restores
// intena because intena is a property of this
// kernel thread, not this CPU. It should
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
  int intena;
  struct proc *p = myproc();

  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  if(mycpu()->ncli != 1)
    panic("sched locks");
  if(p->state == RUNNING)
    panic("sched running");
  if(readeflags()&FL_IF)
    panic("sched interruptible");
  intena = mycpu()->intena;
  swtch(&p->context, mycpu()->scheduler);
  mycpu()->intena = intena;
}

// Give up the CPU for one scheduling round.
void
yield(void)
{
  acquire(&ptable.lock);  //DOC: yieldlock
  myproc()->state = RUNNABLE;
  sched();
  release(&ptable.lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);

  if (first) {
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
    iinit(ROOTDEV);
    initlog(ROOTDEV);
  }

  // Return to "caller", actually trapret (see allocproc).
}

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  struct proc *p = myproc();
  
  if(p == 0)
    panic("sleep");

  if(lk == 0)
    panic("sleep without lk");

  // Must acquire ptable.lock in order to
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
    acquire(&ptable.lock);  //DOC: sleeplock1
    release(lk);
  }
  // Go to sleep.
  p->chan = chan;
  p->state = SLEEPING;

  sched();

  // Tidy up.
  p->chan = 0;

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
    release(&ptable.lock);
    acquire(lk);
  }
}

//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == SLEEPING && p->chan == chan){
      p->state = RUNNABLE;
      // find if already in priority queue
      int check = 0;
      for(int i = 0; i < mlfq_queue_size[p->priority]; i++){
        if(mlfq_queue[p->priority][i] == p){
          check = 1;
          break;
        }
      }
      if(check == 0){
        mlfq_queue_size[p->priority]++;
        mlfq_queue[p->priority][mlfq_queue_size[p->priority]] = p;
      }

      // p->budget = DEFAULT_BUDGET;

      // add new process at the tail 
      // mlfq_queue_size[p->original_priority]++;
      // for(int i = mlfq_queue_size[p->original_priority]; i >= 0 && mlfq_queue_size[p->original_priority] < NPROC; i--){
      //   mlfq_queue[p->original_priority][i+1] = mlfq_queue[p->original_priority][i];
      // }
      // mlfq_queue[p->original_priority][mlfq_queue_size[p->original_priority]] = p;
      // mlfq_queue[p->original_priority][mlfq_queue_size[p->original_priority]] = p;
      // mlfq_queue_size[p->original_priority]++;
      // for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
      //   if(p->state == SLEEPING && p->chan == chan)
      //     p->state = RUNNABLE;
    }
  }
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
  acquire(&ptable.lock);
  wakeup1(chan);
  release(&ptable.lock);
}

// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
  return -1;
}

//PAGEBREAK: 36.
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
  static char *states[] = {
  [UNUSED]    "unused",
  [EMBRYO]    "embryo",
  [SLEEPING]  "sleep ",
  [RUNNABLE]  "runble",
  [RUNNING]   "run   ",
  [ZOMBIE]    "zombie"
  };
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
// New system calls
// int setpriority(int pid, int priority)
int
setpriority(int pid, int priority)
{
  struct proc *p;
  int returnCode = -1;     // returnCode 0 if success, -1 if fail
  
  // check if priority is valid
  if(priority < 0 || priority > MAXPRIORITY){
    cprintf("Invalid priority value detected");
    return returnCode;
  }
  
  // acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
      p->priority = priority;
      p->budget = DEFAULT_BUDGET;
      returnCode = 0;
      break;
    }
  }
  // release(&ptable.lock);
  
  // check if pid is valid
  if(returnCode == -1){
    cprintf("Invalid pid value detected");
  }
  
  return returnCode;
}

// int getpriority(int pid)
int
getpriority(int pid)
{
  struct proc *p;
  int priority = -1;
  // acquire the lock on the process table
  // acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    // Check for UNUSED state
    if(p->pid == pid && p->state == UNUSED){
      cprintf("Process with pid %d is in UNUSED state", pid);
      return priority;
    }
    if(p->pid == pid && p->state != UNUSED){
      priority = p->priority;
      break;
    }
  }
  // release(&ptable.lock);
  
  // check if pid is valid
  if(priority == -1){
    cprintf("Invalid pid value detected");
  }
  return priority;
}

// End of new system calls

// Lottery Scheduler
// Start of new functions
int
settickets(int numTickets)
{
  struct proc *p = myproc();
  int returnCode = -1;     // returnCode 0 if success, -1 if fail
  
  // check if numTickets is valid
  if(numTickets < 0){
    cprintf("Invalid numTickets value detected");
    return returnCode;
  }
  
  acquire(&ptable.lock);
  p->tickets = numTickets;
  returnCode = 0;
  release(&ptable.lock);
  
  return returnCode;
}
int
getpinfo(struct pstat *procstate){
    acquire(&ptable.lock);
    int returnCode = -1;    // returnCode 0 if success, -1 if fail
    if(procstate == 0){
        cprintf("Invalid procstate value detected");
        return returnCode;
    }
    int i = 0;
    struct proc *p;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
        if(p->state != UNUSED){
            procstate->pid[i] = p->pid;
            procstate->tickets[i] = p->tickets;
            procstate->ticks[i] = p->ticks;
            procstate->inuse[i] = p->inuse;
            i++;
        }
    }
    returnCode = 0;
    release(&ptable.lock);
    return returnCode;
}