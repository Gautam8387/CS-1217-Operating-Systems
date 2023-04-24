// Simple command-line kernel monitor useful for
// controlling the kernel and exploring the system interactively.

#include <inc/stdio.h>
#include <inc/string.h>
#include <inc/memlayout.h>
#include <inc/assert.h>
#include <inc/x86.h>

#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/kdebug.h>
#include <kern/pmap.h>

#define CMDBUF_SIZE	80	// enough for one VGA text line


struct Command {
	const char *name;
	const char *desc;
	// return -1 to force monitor to exit
	int (*func)(int argc, char** argv, struct Trapframe* tf);
};

static struct Command commands[] = {
	{ "help", "Display this list of commands", mon_help },
	{ "kerninfo", "Display information about the kernel", mon_kerninfo },
	{ "backtrace", "Display stack backtrace", mon_backtrace },
	{"showmappings", "Show mappings between two addresses", mon_showmappings },
	{"setperm", "Explicitly set, clear, or change the permissions of an addresses", mon_setperm },
	{"dump", "Dump the contents of a range of memory given either a virtual or physical address range", mon_dump},
};

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;
	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
	// From LAB 1
	// Edit: Get the current base stack pointer (ebp)
	uint32_t ebp = read_ebp();
	// Edit: Create a structure to store the debug information
	struct Eipdebuginfo info;
	// In a stack first valye is the return address, second value is the base pointer of the previous stack frame (eip). The rest are the arguments or local variables stored in form of array. Now we have to iterate over the stack frames and print the values of the stack frame.
	cprintf("Stack backtrace:");
	while(ebp != 0){
		cprintf("\n");
		// %08x is used to print the value in hexadecimal format with 8 digits.
		//Edit: Print Stack Information
		cprintf("ebp %08x eip %08x args %08x %08x %08x %08x %08x", ebp, *((uint32_t*)ebp + 1), *((uint32_t*)ebp + 2), *((uint32_t*)ebp + 3), *((uint32_t*)ebp + 4), *((uint32_t*)ebp + 5), *((uint32_t*)ebp + 6));
		//Edit: Print Debug Information, send the eip value to the function as it is the address of the instruction that caused the call.
		debuginfo_eip(*((uint32_t*)ebp + 1), &info);
		// Print the debug information
		cprintf("\n\t");
		cprintf(" %s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, *((uint32_t*)ebp + 1) - info.eip_fn_addr);	
		// Update the base pointer to the previous stack frame
		ebp = *((uint32_t*)ebp);
	}
	cprintf("\n");
	return 0;
}

int
mon_showmappings(int argc, char **argv, struct Trapframe *tf)
{
	if(argc != 3){
		cprintf("Usage: showmappings <start_address> <end_address>\n");
		return 0;
	}
	long start = strtol(argv[1], NULL, 16);
	long end = strtol(argv[2], NULL, 16);
	// Check if end address is greater than start address
	if(end < start){
		cprintf("Warning: End Address Should be Greater Than Start Address\n");
		// swap the values
		long temp = start;
		start = end;
		end = temp;
	}
	cprintf("Virtual Address\t\tPhysical Address\t\tPermissions\n");
	// Iterate over the virtual addresses
	for(long i = start; i <= end; i += PGSIZE){
		pte_t *pte = pgdir_walk(kern_pgdir, (void*)i, 0);
		if(pte == NULL){
			cprintf("%08x\t\tUnmapped\t\t-\n", i);
			continue;
		}
		// Get the physical address
		long physical_address = PTE_ADDR(*pte);
		// Get the permissions
		// char permissions[4];
		// permissions[0] = (*pte & PTE_U) ? 'U' : '-';
		// permissions[1] = (*pte & PTE_W) ? 'W' : '-';
		// permissions[2] = (*pte & PTE_P) ? 'P' : '-';
		// permissions[3] = '\0';
		char permissions[10][4];
		permissions[0][0] = (*pte & PTE_U) ? 'U' : '-';
		permissions[0][1] = '\0';
		permissions[1][0] = (*pte & PTE_W) ? 'W' : '-';
		permissions[1][1] = '\0';
		permissions[2][0] = (*pte & PTE_P) ? 'P' : '-';
		permissions[2][1] = '\0';
		permissions[3][0] = (*pte & PTE_PWT) ? 'P' : '-';
		permissions[3][1] = (*pte & PTE_PCD) ? 'C' : '-';
		permissions[3][2] = (*pte & PTE_PCD) ? 'D' : '-';
		permissions[3][3] = '\0';
		permissions[4][0] = (*pte & PTE_A) ? 'A' : '-';
		permissions[4][1] = '\0';
		permissions[5][0] = (*pte & PTE_D) ? 'D' : '-';
		permissions[5][1] = '\0';
		permissions[6][0] = (*pte & PTE_PS) ? 'P' : '-';
		permissions[6][1] = (*pte & PTE_PS) ? 'S' : '-';
		permissions[6][2] = '\0';
		permissions[7][0] = (*pte & PTE_G) ? 'G' : '-';
		permissions[7][1] = '\0';
		permissions[8][0] = '\0';
		permissions[9][0] = '\0';
		cprintf("%08x\t\t%08x\t\t", i, physical_address);
		for (int i = 0; i < 10; i++) {
		for (int j = 0; j < 4 && (permissions[i][j]!='\0'); j++) {
			cprintf("%c", permissions[i][j]);
		}
		cprintf(" ");
	}
	cprintf("\n");
	}
	cprintf("\n");
	return 0;
}

int
mon_setperm(int argc, char **argv, struct Trapframe *tf)
{
	if(argc != 3){
		cprintf("Usage: setperm <start_address> <Permission-bit>\n");
		return 0;
	}
	long start = strtol(argv[1], NULL, 16);
	long new_prem = strtol(argv[2], NULL, 16);
	// Check if new permission is valid
	if(new_prem > 0x100){
		cprintf("Invalid Permission\n");
		return 0;
	}
	// Get the PTE of the address
	pte_t *pte = pgdir_walk(kern_pgdir, (void*)start, 0);
	if(pte == NULL){
		cprintf("Warning: Address %08x is not mapped\n", start);
		return 0;
	}
	cprintf("Virtual Address: %08x\n", start);

	//Get old permissions to print
	char permissions[10][4];
	permissions[0][0] = (*pte & PTE_U) ? 'U' : '-';
	permissions[0][1] = '\0';
	permissions[1][0] = (*pte & PTE_W) ? 'W' : '-';
	permissions[1][1] = '\0';
	permissions[2][0] = (*pte & PTE_P) ? 'P' : '-';
	permissions[2][1] = '\0';
	permissions[3][0] = (*pte & PTE_PWT) ? 'P' : '-';
	permissions[3][1] = (*pte & PTE_PCD) ? 'C' : '-';
	permissions[3][2] = (*pte & PTE_PCD) ? 'D' : '-';
	permissions[3][3] = '\0';
	permissions[4][0] = (*pte & PTE_A) ? 'A' : '-';
	permissions[4][1] = '\0';
	permissions[5][0] = (*pte & PTE_D) ? 'D' : '-';
	permissions[5][1] = '\0';
	permissions[6][0] = (*pte & PTE_PS) ? 'P' : '-';
	permissions[6][1] = (*pte & PTE_PS) ? 'S' : '-';
	permissions[6][2] = '\0';
	permissions[7][0] = (*pte & PTE_G) ? 'G' : '-';
	permissions[7][1] = '\0';
	permissions[8][0] = '\0';
	permissions[9][0] = '\0';
	cprintf("Old Permissions:\n");
	for (int i = 0; i < 10; i++) {
		for (int j = 0; j < 4 && (permissions[i][j]!='\0'); j++) {
			cprintf("%c", permissions[i][j]);
		}
		cprintf(" ");
	}
	cprintf("\n");

	// Set the permissions
	*pte = *pte | new_prem;
	cprintf("Permissions Set Successful\n");

	// Get the new permissions
	permissions[0][0] = (*pte & PTE_U) ? 'U' : '-';
	permissions[0][1] = '\0';
	permissions[1][0] = (*pte & PTE_W) ? 'W' : '-';
	permissions[1][1] = '\0';
	permissions[2][0] = (*pte & PTE_P) ? 'P' : '-';
	permissions[2][1] = '\0';
	permissions[3][0] = (*pte & PTE_PWT) ? 'P' : '-';
	permissions[3][1] = (*pte & PTE_PCD) ? 'C' : '-';
	permissions[3][2] = (*pte & PTE_PCD) ? 'D' : '-';
	permissions[3][3] = '\0';
	permissions[4][0] = (*pte & PTE_A) ? 'A' : '-';
	permissions[4][1] = '\0';
	permissions[5][0] = (*pte & PTE_D) ? 'D' : '-';
	permissions[5][1] = '\0';
	permissions[6][0] = (*pte & PTE_PS) ? 'P' : '-';
	permissions[6][1] = (*pte & PTE_PS) ? 'S' : '-';
	permissions[6][2] = '\0';
	permissions[7][0] = (*pte & PTE_G) ? 'G' : '-';
	permissions[7][1] = '\0';
	permissions[8][0] = '\0';
	permissions[9][0] = '\0';
	cprintf("New Permissions:\n");
	for (int i = 0; i < 10; i++) {
		for (int j = 0; j < 4 && (permissions[i][j]!='\0'); j++) {
			cprintf("%c", permissions[i][j]);
		}
		cprintf(" ");
	}
	cprintf("\n");
	return 0;
}

int
mon_dump(int argc, char **argv, struct Trapframe *tf)
{
	if(argc != 4){
		cprintf("Usage: dump <virtual(V)/physical(P)> <start_address> <end_address>");
	return 0;
	}
	char addr_type = argv[1][0];
	uintptr_t start = strtol(argv[2], NULL, 16);
	uintptr_t end = strtol(argv[3], NULL, 16);
	physaddr_t p_start = start;
	physaddr_t p_end = end;
	if(start > end){
		cprintf("Warning: End Address Should be Greater Than Start Address\n");
		// swap the values
		uintptr_t temp = start;
		start = end;
		end = temp;
	}
	cprintf("Address:\t\tMemory Content:\n");
	for(; start<=end; start+=4){
		if(addr_type == 'V' || addr_type == 'v'){
			pte_t *pte = pgdir_walk(kern_pgdir, (void*)start, 0);
			if(pte == NULL||!(*pte & PTE_P)){
				cprintf("Warning: Address %08x is not mapped\n", start);
				start = ROUNDUP(start, PGSIZE);
				continue;
			}
			p_start = (physaddr_t)KADDR((PTE_ADDR(*pte) | PGOFF(start))); //PTE_ADDR(*pte) | PGOFF(start);
			p_end =  (physaddr_t)KADDR((PTE_ADDR(*pte) | PGOFF(end)));
			cprintf("%08x\t\t%08x\n", p_start, *(uint32_t*)p_start);
		}
		else if(addr_type == 'P' || addr_type == 'p'){
			cprintf("%08x\t\t%08x\n", start, *(uint32_t*)start);
		}
		else{
			cprintf("Warning: Invalid Address Type\n");
			return 0;
		}
	}
	return 0;
}


/***** Kernel monitor command interpreter *****/

#define WHITESPACE "\t\r\n "
#define MAXARGS 16

static int
runcmd(char *buf, struct Trapframe *tf)
{
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
		if (*buf == 0)
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
	}
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
	return 0;
}

void
monitor(struct Trapframe *tf)
{
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type 'help' for a list of commands.\n");


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
