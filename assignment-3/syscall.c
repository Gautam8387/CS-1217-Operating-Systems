#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "x86.h"
#include "syscall.h"


// User code makes a system call with INT T_SYSCALL.
// System call number in %eax.
// Arguments on the stack, from the user call to the C
// library system call function. The saved user %esp points
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
  struct proc *curproc = myproc();

  if(addr >= curproc->sz || addr+4 > curproc->sz)
    return -1;
  *ip = *(int*)(addr);
  return 0;
}

// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
  char *s, *ep;
  struct proc *curproc = myproc();

  if(addr >= curproc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)curproc->sz;
  for(s = *pp; s < ep; s++){
    if(*s == 0)
      return s - *pp;
  }
  return -1;
}

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
}

// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
  int i;
  struct proc *curproc = myproc();
 
  if(argint(n, &i) < 0)
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
    return -1;
  *pp = (char*)i;
  return 0;
}

// Fetch the nth word-sized system call argument as a string pointer.
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
  int addr;
  if(argint(n, &addr) < 0)
    return -1;
  return fetchstr(addr, pp);
}

extern int sys_chdir(void);
extern int sys_close(void);
extern int sys_dup(void);
extern int sys_exec(void);
extern int sys_exit(void);
extern int sys_fork(void);
extern int sys_fstat(void);
extern int sys_getpid(void);
extern int sys_kill(void);
extern int sys_link(void);
extern int sys_mkdir(void);
extern int sys_mknod(void);
extern int sys_open(void);
extern int sys_pipe(void);
extern int sys_read(void);
extern int sys_sbrk(void);
extern int sys_sleep(void);
extern int sys_unlink(void);
extern int sys_wait(void);
extern int sys_write(void);
extern int sys_uptime(void);
extern int sys_date(void);
// Date edits

static int (*syscalls[])(void) = {
[SYS_fork]    sys_fork,
[SYS_exit]    sys_exit,
[SYS_wait]    sys_wait,
[SYS_pipe]    sys_pipe,
[SYS_read]    sys_read,
[SYS_kill]    sys_kill,
[SYS_exec]    sys_exec,
[SYS_fstat]   sys_fstat,
[SYS_chdir]   sys_chdir,
[SYS_dup]     sys_dup,
[SYS_getpid]  sys_getpid,
[SYS_sbrk]    sys_sbrk,
[SYS_sleep]   sys_sleep,
[SYS_uptime]  sys_uptime,
[SYS_open]    sys_open,
[SYS_write]   sys_write,
[SYS_mknod]   sys_mknod,
[SYS_unlink]  sys_unlink,
[SYS_link]    sys_link,
[SYS_mkdir]   sys_mkdir,
[SYS_close]   sys_close,
[SYS_date]    sys_date,
};

static const char *syscall_names[] = {
  [SYS_fork]    "fork",
  [SYS_exit]    "exit",
  [SYS_wait]    "wait",
  [SYS_pipe]    "pipe",
  [SYS_read]    "read",
  [SYS_kill]    "kill",
  [SYS_exec]    "exec",
  [SYS_fstat]   "fstat",
  [SYS_chdir]   "chdir",
  [SYS_dup]     "dup",
  [SYS_getpid]  "getpid",
  [SYS_sbrk]    "sbrk",
  [SYS_sleep]   "sleep",
  [SYS_uptime]  "uptime",
  [SYS_open]    "open",
  [SYS_write]   "write",
  [SYS_mknod]   "mknod",
  [SYS_unlink]  "unlink",
  [SYS_link]    "link",
  [SYS_mkdir]   "mkdir",
  [SYS_close]   "close",
  [SYS_date]   "date",
};

void
syscall(void)
{
  int num;
  struct proc *curproc = myproc();
    // myproc() returns the current process which is running
    // the proc structure contains the trapframe which contains the system call number
    // curproc: tells us about the process which includes the process id
    // trapframe: tf tells us about the state of the process (through registers) which includes the system call number
    // eax: tells us about the return value of the system call. It is a register in the trapframe
  num = curproc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    curproc->tf->eax = syscalls[num]();
    // Edit Starts Here
    switch(num){
      case SYS_fork:
        cprintf("%s -> %d\n", syscall_names[num], curproc->tf->eax);
        break;
      case SYS_exit:
        cprintf("%s -> %d\n", syscall_names[num], curproc->tf->eax);
        break;
      case SYS_wait:
        cprintf("%s -> %d\n", syscall_names[num], curproc->tf->eax);
        break;
      case SYS_pipe:  
        cprintf("%s -> %d\n", syscall_names[num], curproc->tf->eax);
        break;
      case SYS_read:
        cprintf("%s -> %d\n", syscall_names[num], curproc->tf->eax);
        break;
      case SYS_kill:
        cprintf("%s -> %d\n", syscall_names[num], curproc->tf->eax);
        break;
      case SYS_exec:
        cprintf("%s -> %d\n", syscall_names[num], curproc->tf->eax);
        break;
      case SYS_fstat:
        cprintf("%s -> %d\n", syscall_names[num], curproc->tf->eax);
        break;
      case SYS_chdir:
        cprintf("%s -> %d\n", syscall_names[num], curproc->tf->eax);
        break;
      case SYS_dup:
        cprintf("%s -> %d\n", syscall_names[num], curproc->tf->eax);
        break;
      case SYS_getpid:
        cprintf("%s -> %d\n", syscall_names[num], curproc->tf->eax);
        break;
      case SYS_sbrk:
        cprintf("%s -> %d\n", syscall_names[num], curproc->tf->eax);
        break;
      case SYS_sleep:
        cprintf("%s -> %d\n", syscall_names[num], curproc->tf->eax);
        break;
      case SYS_uptime:
        cprintf("%s -> %d\n", syscall_names[num], curproc->tf->eax);
        break;
      case SYS_open:
        cprintf("%s -> %d\n", syscall_names[num], curproc->tf->eax);
        break;
      case SYS_write:
        cprintf("%s -> %d\n", syscall_names[num], curproc->tf->eax);
        break;
      case SYS_mknod:
        cprintf("%s -> %d\n", syscall_names[num], curproc->tf->eax);
        break;
      case SYS_unlink:
        cprintf("%s -> %d\n", syscall_names[num], curproc->tf->eax);
        break;
      case SYS_link:
        cprintf("%s -> %d\n", syscall_names[num], curproc->tf->eax);
        break;
      case SYS_mkdir:
        cprintf("%s -> %d\n", syscall_names[num], curproc->tf->eax);
        break;
      case SYS_close:
        cprintf("%s -> %d\n", syscall_names[num], curproc->tf->eax);
        break;
      case SYS_date:
        cprintf("%s -> %d\n", syscall_names[num], curproc->tf->eax);
        break;
      default:
        cprintf("unknown sys call %d\n", num);
        break;
    }   
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
  }
}


// Old Approach:
/*
// void
// syscall(void)
// {
//   int num;
//   struct proc *curproc = myproc();

//   num = curproc->tf->eax;
//   if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
//     curproc->tf->eax = syscalls[num]();
//     // Edit Starts Here
//     switch(num){
//       case 1:
//         cprintf("fork -> %d\n", curproc->tf->eax);
//         break;
//       case 2:
//         cprintf("exit -> %d\n", curproc->tf->eax);
//         break;
//       case 3:
//         cprintf("wait -> %d\n", curproc->tf->eax);
//         break;
//       case 4:
//         cprintf("pipe -> %d\n", curproc->tf->eax);
//         break;  
//       case 5:
//         cprintf("read -> %d\n", curproc->tf->eax);
//         break;  
//       case 6:
//         cprintf("kill -> %d\n", curproc->tf->eax);
//         break;
//       case 7:
//         cprintf("exec -> %d\n", curproc->tf->eax);
//         break;
//       case 8:
//         cprintf("fstat -> %d\n", curproc->tf->eax);
//         break;
//       case 9:
//         cprintf("chdir -> %d\n", curproc->tf->eax);
//         break;
//       case 10:
//         cprintf("dup -> %d\n", curproc->tf->eax);
//         break;
//       case 11:
//         cprintf("getpid -> %d\n", curproc->tf->eax);
//         break;
//       case 12:
//         cprintf("sbrk -> %d\n", curproc->tf->eax);
//         break;
//       case 13:
//         cprintf("sleep -> %d\n", curproc->tf->eax);
//         break;
//       case 14:
//         cprintf("uptime -> %d\n", curproc->tf->eax);
//         break;
//       case 15:
//         cprintf("open -> %d\n", curproc->tf->eax);
//         break;
//       case 16:
//         cprintf("write -> %d\n", curproc->tf->eax);
//         break;
//       case 17:
//         cprintf("mknod -> %d\n", curproc->tf->eax);
//         break;
//       case 18:  
//         cprintf("unlink -> %d\n", curproc->tf->eax);
//         break;
//       case 19:
//         cprintf("link -> %d\n", curproc->tf->eax);
//         break;
//       case 20:
//         cprintf("mkdir -> %d\n", curproc->tf->eax);
//         break;
//       case 21:
//         cprintf("close -> %d\n", curproc->tf->eax);
//         break;
//       case 22:
//         cprintf("date -> %d\n", curproc->tf->eax);
//         break;
//       default:
//         cprintf("Unknown syscall -> %d\n", curproc->tf->eax);
//         break;
//     }
//     // Edit End Here
//   } else {
//     cprintf("%d %s: unknown sys call %d\n",
//             curproc->pid, curproc->name, num);
//     curproc->tf->eax = -1;
//   }
*/ 