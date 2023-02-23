#include "types.h"
#include "x86.h"
#include "defs.h"
#include "date.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
  return fork();
}

int
sys_exit(void)
{
  exit();
  return 0;  // not reached
}

int
sys_wait(void)
{
  return wait();
}

int
sys_kill(void)
{
  int pid;

  if(argint(0, &pid) < 0)
    return -1;
  return kill(pid);
}

int
sys_getpid(void)
{
  return myproc()->pid;
}

int
sys_sbrk(void)
{
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  addr = myproc()->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
}

int
sys_sleep(void)
{
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

// Edit Starts Here
// defined the implementation of date syscall in sysproc.c
int
sys_date(void)
{
  struct rtcdate *r;
  /*
The if statement checks if the incoming pointer to syscall is valid or not. The argptr takes input
(through file descriptor 0, which is stdin) and checks if it lies within memory space. If not, it exits
the syscall with a return code of -1. argptr is defined in syscall.c
  */
  if(argptr(0, (void*)&r, sizeof(*r)) < 0)
    return -1;
  cmostime(r);
  return 0;
}
// Edit Ends Here

/*
The sysproc.c includes system calls that are implemented in relation to management of processes. 
The trapframe discusses in exercise 1 always looks for a definition of a systemcall function in sysproc.c when it encounters a syscall.
*/