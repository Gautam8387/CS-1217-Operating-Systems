
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 20 11 00       	mov    $0x112000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 68 00 00 00       	call   f01000a6 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	e8 72 01 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f010004a:	81 c3 be 12 01 00    	add    $0x112be,%ebx
f0100050:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("entering test_backtrace %d\n", x);
f0100053:	83 ec 08             	sub    $0x8,%esp
f0100056:	56                   	push   %esi
f0100057:	8d 83 38 08 ff ff    	lea    -0xf7c8(%ebx),%eax
f010005d:	50                   	push   %eax
f010005e:	e8 a2 0a 00 00       	call   f0100b05 <cprintf>
	if (x > 0)
f0100063:	83 c4 10             	add    $0x10,%esp
f0100066:	85 f6                	test   %esi,%esi
f0100068:	7e 29                	jle    f0100093 <test_backtrace+0x53>
		test_backtrace(x-1);
f010006a:	83 ec 0c             	sub    $0xc,%esp
f010006d:	8d 46 ff             	lea    -0x1(%esi),%eax
f0100070:	50                   	push   %eax
f0100071:	e8 ca ff ff ff       	call   f0100040 <test_backtrace>
f0100076:	83 c4 10             	add    $0x10,%esp
	else
		mon_backtrace(0, 0, 0);
	cprintf("leaving test_backtrace %d\n", x);
f0100079:	83 ec 08             	sub    $0x8,%esp
f010007c:	56                   	push   %esi
f010007d:	8d 83 54 08 ff ff    	lea    -0xf7ac(%ebx),%eax
f0100083:	50                   	push   %eax
f0100084:	e8 7c 0a 00 00       	call   f0100b05 <cprintf>
}
f0100089:	83 c4 10             	add    $0x10,%esp
f010008c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010008f:	5b                   	pop    %ebx
f0100090:	5e                   	pop    %esi
f0100091:	5d                   	pop    %ebp
f0100092:	c3                   	ret    
		mon_backtrace(0, 0, 0);
f0100093:	83 ec 04             	sub    $0x4,%esp
f0100096:	6a 00                	push   $0x0
f0100098:	6a 00                	push   $0x0
f010009a:	6a 00                	push   $0x0
f010009c:	e8 ed 07 00 00       	call   f010088e <mon_backtrace>
f01000a1:	83 c4 10             	add    $0x10,%esp
f01000a4:	eb d3                	jmp    f0100079 <test_backtrace+0x39>

f01000a6 <i386_init>:

void
i386_init(void)
{
f01000a6:	55                   	push   %ebp
f01000a7:	89 e5                	mov    %esp,%ebp
f01000a9:	53                   	push   %ebx
f01000aa:	83 ec 08             	sub    $0x8,%esp
f01000ad:	e8 0a 01 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f01000b2:	81 c3 56 12 01 00    	add    $0x11256,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000b8:	c7 c2 60 30 11 f0    	mov    $0xf0113060,%edx
f01000be:	c7 c0 c0 36 11 f0    	mov    $0xf01136c0,%eax
f01000c4:	29 d0                	sub    %edx,%eax
f01000c6:	50                   	push   %eax
f01000c7:	6a 00                	push   $0x0
f01000c9:	52                   	push   %edx
f01000ca:	e8 3b 16 00 00       	call   f010170a <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000cf:	e8 3e 05 00 00       	call   f0100612 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000d4:	83 c4 08             	add    $0x8,%esp
f01000d7:	68 ac 1a 00 00       	push   $0x1aac
f01000dc:	8d 83 6f 08 ff ff    	lea    -0xf791(%ebx),%eax
f01000e2:	50                   	push   %eax
f01000e3:	e8 1d 0a 00 00       	call   f0100b05 <cprintf>
	//
	// cprintf("x=%d y=%d", 3 );
	//

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000e8:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000ef:	e8 4c ff ff ff       	call   f0100040 <test_backtrace>
f01000f4:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000f7:	83 ec 0c             	sub    $0xc,%esp
f01000fa:	6a 00                	push   $0x0
f01000fc:	e8 4b 08 00 00       	call   f010094c <monitor>
f0100101:	83 c4 10             	add    $0x10,%esp
f0100104:	eb f1                	jmp    f01000f7 <i386_init+0x51>

f0100106 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100106:	55                   	push   %ebp
f0100107:	89 e5                	mov    %esp,%ebp
f0100109:	56                   	push   %esi
f010010a:	53                   	push   %ebx
f010010b:	e8 ac 00 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100110:	81 c3 f8 11 01 00    	add    $0x111f8,%ebx
	va_list ap;

	if (panicstr)
f0100116:	83 bb 58 1d 00 00 00 	cmpl   $0x0,0x1d58(%ebx)
f010011d:	74 0f                	je     f010012e <_panic+0x28>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010011f:	83 ec 0c             	sub    $0xc,%esp
f0100122:	6a 00                	push   $0x0
f0100124:	e8 23 08 00 00       	call   f010094c <monitor>
f0100129:	83 c4 10             	add    $0x10,%esp
f010012c:	eb f1                	jmp    f010011f <_panic+0x19>
	panicstr = fmt;
f010012e:	8b 45 10             	mov    0x10(%ebp),%eax
f0100131:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
	asm volatile("cli; cld");
f0100137:	fa                   	cli    
f0100138:	fc                   	cld    
	va_start(ap, fmt);
f0100139:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f010013c:	83 ec 04             	sub    $0x4,%esp
f010013f:	ff 75 0c             	push   0xc(%ebp)
f0100142:	ff 75 08             	push   0x8(%ebp)
f0100145:	8d 83 8a 08 ff ff    	lea    -0xf776(%ebx),%eax
f010014b:	50                   	push   %eax
f010014c:	e8 b4 09 00 00       	call   f0100b05 <cprintf>
	vcprintf(fmt, ap);
f0100151:	83 c4 08             	add    $0x8,%esp
f0100154:	56                   	push   %esi
f0100155:	ff 75 10             	push   0x10(%ebp)
f0100158:	e8 71 09 00 00       	call   f0100ace <vcprintf>
	cprintf("\n");
f010015d:	8d 83 c6 08 ff ff    	lea    -0xf73a(%ebx),%eax
f0100163:	89 04 24             	mov    %eax,(%esp)
f0100166:	e8 9a 09 00 00       	call   f0100b05 <cprintf>
f010016b:	83 c4 10             	add    $0x10,%esp
f010016e:	eb af                	jmp    f010011f <_panic+0x19>

f0100170 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100170:	55                   	push   %ebp
f0100171:	89 e5                	mov    %esp,%ebp
f0100173:	56                   	push   %esi
f0100174:	53                   	push   %ebx
f0100175:	e8 42 00 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f010017a:	81 c3 8e 11 01 00    	add    $0x1118e,%ebx
	va_list ap;

	va_start(ap, fmt);
f0100180:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f0100183:	83 ec 04             	sub    $0x4,%esp
f0100186:	ff 75 0c             	push   0xc(%ebp)
f0100189:	ff 75 08             	push   0x8(%ebp)
f010018c:	8d 83 a2 08 ff ff    	lea    -0xf75e(%ebx),%eax
f0100192:	50                   	push   %eax
f0100193:	e8 6d 09 00 00       	call   f0100b05 <cprintf>
	vcprintf(fmt, ap);
f0100198:	83 c4 08             	add    $0x8,%esp
f010019b:	56                   	push   %esi
f010019c:	ff 75 10             	push   0x10(%ebp)
f010019f:	e8 2a 09 00 00       	call   f0100ace <vcprintf>
	cprintf("\n");
f01001a4:	8d 83 c6 08 ff ff    	lea    -0xf73a(%ebx),%eax
f01001aa:	89 04 24             	mov    %eax,(%esp)
f01001ad:	e8 53 09 00 00       	call   f0100b05 <cprintf>
	va_end(ap);
}
f01001b2:	83 c4 10             	add    $0x10,%esp
f01001b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01001b8:	5b                   	pop    %ebx
f01001b9:	5e                   	pop    %esi
f01001ba:	5d                   	pop    %ebp
f01001bb:	c3                   	ret    

f01001bc <__x86.get_pc_thunk.bx>:
f01001bc:	8b 1c 24             	mov    (%esp),%ebx
f01001bf:	c3                   	ret    

f01001c0 <serial_proc_data>:

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001c0:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001c5:	ec                   	in     (%dx),%al
static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001c6:	a8 01                	test   $0x1,%al
f01001c8:	74 0a                	je     f01001d4 <serial_proc_data+0x14>
f01001ca:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001cf:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001d0:	0f b6 c0             	movzbl %al,%eax
f01001d3:	c3                   	ret    
		return -1;
f01001d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f01001d9:	c3                   	ret    

f01001da <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001da:	55                   	push   %ebp
f01001db:	89 e5                	mov    %esp,%ebp
f01001dd:	57                   	push   %edi
f01001de:	56                   	push   %esi
f01001df:	53                   	push   %ebx
f01001e0:	83 ec 1c             	sub    $0x1c,%esp
f01001e3:	e8 6a 05 00 00       	call   f0100752 <__x86.get_pc_thunk.si>
f01001e8:	81 c6 20 11 01 00    	add    $0x11120,%esi
f01001ee:	89 c7                	mov    %eax,%edi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f01001f0:	8d 1d 98 1d 00 00    	lea    0x1d98,%ebx
f01001f6:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f01001f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01001fc:	89 7d e4             	mov    %edi,-0x1c(%ebp)
	while ((c = (*proc)()) != -1) {
f01001ff:	eb 25                	jmp    f0100226 <cons_intr+0x4c>
		cons.buf[cons.wpos++] = c;
f0100201:	8b 8c 1e 04 02 00 00 	mov    0x204(%esi,%ebx,1),%ecx
f0100208:	8d 51 01             	lea    0x1(%ecx),%edx
f010020b:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010020e:	88 04 0f             	mov    %al,(%edi,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f0100211:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f0100217:	b8 00 00 00 00       	mov    $0x0,%eax
f010021c:	0f 44 d0             	cmove  %eax,%edx
f010021f:	89 94 1e 04 02 00 00 	mov    %edx,0x204(%esi,%ebx,1)
	while ((c = (*proc)()) != -1) {
f0100226:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100229:	ff d0                	call   *%eax
f010022b:	83 f8 ff             	cmp    $0xffffffff,%eax
f010022e:	74 06                	je     f0100236 <cons_intr+0x5c>
		if (c == 0)
f0100230:	85 c0                	test   %eax,%eax
f0100232:	75 cd                	jne    f0100201 <cons_intr+0x27>
f0100234:	eb f0                	jmp    f0100226 <cons_intr+0x4c>
	}
}
f0100236:	83 c4 1c             	add    $0x1c,%esp
f0100239:	5b                   	pop    %ebx
f010023a:	5e                   	pop    %esi
f010023b:	5f                   	pop    %edi
f010023c:	5d                   	pop    %ebp
f010023d:	c3                   	ret    

f010023e <kbd_proc_data>:
{
f010023e:	55                   	push   %ebp
f010023f:	89 e5                	mov    %esp,%ebp
f0100241:	56                   	push   %esi
f0100242:	53                   	push   %ebx
f0100243:	e8 74 ff ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100248:	81 c3 c0 10 01 00    	add    $0x110c0,%ebx
f010024e:	ba 64 00 00 00       	mov    $0x64,%edx
f0100253:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f0100254:	a8 01                	test   $0x1,%al
f0100256:	0f 84 f7 00 00 00    	je     f0100353 <kbd_proc_data+0x115>
	if (stat & KBS_TERR)
f010025c:	a8 20                	test   $0x20,%al
f010025e:	0f 85 f6 00 00 00    	jne    f010035a <kbd_proc_data+0x11c>
f0100264:	ba 60 00 00 00       	mov    $0x60,%edx
f0100269:	ec                   	in     (%dx),%al
f010026a:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f010026c:	3c e0                	cmp    $0xe0,%al
f010026e:	74 64                	je     f01002d4 <kbd_proc_data+0x96>
	} else if (data & 0x80) {
f0100270:	84 c0                	test   %al,%al
f0100272:	78 75                	js     f01002e9 <kbd_proc_data+0xab>
	} else if (shift & E0ESC) {
f0100274:	8b 8b 78 1d 00 00    	mov    0x1d78(%ebx),%ecx
f010027a:	f6 c1 40             	test   $0x40,%cl
f010027d:	74 0e                	je     f010028d <kbd_proc_data+0x4f>
		data |= 0x80;
f010027f:	83 c8 80             	or     $0xffffff80,%eax
f0100282:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100284:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100287:	89 8b 78 1d 00 00    	mov    %ecx,0x1d78(%ebx)
	shift |= shiftcode[data];
f010028d:	0f b6 d2             	movzbl %dl,%edx
f0100290:	0f b6 84 13 f8 09 ff 	movzbl -0xf608(%ebx,%edx,1),%eax
f0100297:	ff 
f0100298:	0b 83 78 1d 00 00    	or     0x1d78(%ebx),%eax
	shift ^= togglecode[data];
f010029e:	0f b6 8c 13 f8 08 ff 	movzbl -0xf708(%ebx,%edx,1),%ecx
f01002a5:	ff 
f01002a6:	31 c8                	xor    %ecx,%eax
f01002a8:	89 83 78 1d 00 00    	mov    %eax,0x1d78(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f01002ae:	89 c1                	mov    %eax,%ecx
f01002b0:	83 e1 03             	and    $0x3,%ecx
f01002b3:	8b 8c 8b f8 1c 00 00 	mov    0x1cf8(%ebx,%ecx,4),%ecx
f01002ba:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01002be:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f01002c1:	a8 08                	test   $0x8,%al
f01002c3:	74 61                	je     f0100326 <kbd_proc_data+0xe8>
		if ('a' <= c && c <= 'z')
f01002c5:	89 f2                	mov    %esi,%edx
f01002c7:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f01002ca:	83 f9 19             	cmp    $0x19,%ecx
f01002cd:	77 4b                	ja     f010031a <kbd_proc_data+0xdc>
			c += 'A' - 'a';
f01002cf:	83 ee 20             	sub    $0x20,%esi
f01002d2:	eb 0c                	jmp    f01002e0 <kbd_proc_data+0xa2>
		shift |= E0ESC;
f01002d4:	83 8b 78 1d 00 00 40 	orl    $0x40,0x1d78(%ebx)
		return 0;
f01002db:	be 00 00 00 00       	mov    $0x0,%esi
}
f01002e0:	89 f0                	mov    %esi,%eax
f01002e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01002e5:	5b                   	pop    %ebx
f01002e6:	5e                   	pop    %esi
f01002e7:	5d                   	pop    %ebp
f01002e8:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f01002e9:	8b 8b 78 1d 00 00    	mov    0x1d78(%ebx),%ecx
f01002ef:	83 e0 7f             	and    $0x7f,%eax
f01002f2:	f6 c1 40             	test   $0x40,%cl
f01002f5:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01002f8:	0f b6 d2             	movzbl %dl,%edx
f01002fb:	0f b6 84 13 f8 09 ff 	movzbl -0xf608(%ebx,%edx,1),%eax
f0100302:	ff 
f0100303:	83 c8 40             	or     $0x40,%eax
f0100306:	0f b6 c0             	movzbl %al,%eax
f0100309:	f7 d0                	not    %eax
f010030b:	21 c8                	and    %ecx,%eax
f010030d:	89 83 78 1d 00 00    	mov    %eax,0x1d78(%ebx)
		return 0;
f0100313:	be 00 00 00 00       	mov    $0x0,%esi
f0100318:	eb c6                	jmp    f01002e0 <kbd_proc_data+0xa2>
		else if ('A' <= c && c <= 'Z')
f010031a:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f010031d:	8d 4e 20             	lea    0x20(%esi),%ecx
f0100320:	83 fa 1a             	cmp    $0x1a,%edx
f0100323:	0f 42 f1             	cmovb  %ecx,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100326:	f7 d0                	not    %eax
f0100328:	a8 06                	test   $0x6,%al
f010032a:	75 b4                	jne    f01002e0 <kbd_proc_data+0xa2>
f010032c:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f0100332:	75 ac                	jne    f01002e0 <kbd_proc_data+0xa2>
		cprintf("Rebooting!\n");
f0100334:	83 ec 0c             	sub    $0xc,%esp
f0100337:	8d 83 bc 08 ff ff    	lea    -0xf744(%ebx),%eax
f010033d:	50                   	push   %eax
f010033e:	e8 c2 07 00 00       	call   f0100b05 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100343:	b8 03 00 00 00       	mov    $0x3,%eax
f0100348:	ba 92 00 00 00       	mov    $0x92,%edx
f010034d:	ee                   	out    %al,(%dx)
}
f010034e:	83 c4 10             	add    $0x10,%esp
f0100351:	eb 8d                	jmp    f01002e0 <kbd_proc_data+0xa2>
		return -1;
f0100353:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100358:	eb 86                	jmp    f01002e0 <kbd_proc_data+0xa2>
		return -1;
f010035a:	be ff ff ff ff       	mov    $0xffffffff,%esi
f010035f:	e9 7c ff ff ff       	jmp    f01002e0 <kbd_proc_data+0xa2>

f0100364 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100364:	55                   	push   %ebp
f0100365:	89 e5                	mov    %esp,%ebp
f0100367:	57                   	push   %edi
f0100368:	56                   	push   %esi
f0100369:	53                   	push   %ebx
f010036a:	83 ec 1c             	sub    $0x1c,%esp
f010036d:	e8 4a fe ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100372:	81 c3 96 0f 01 00    	add    $0x10f96,%ebx
f0100378:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (i = 0;
f010037b:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100380:	bf fd 03 00 00       	mov    $0x3fd,%edi
f0100385:	b9 84 00 00 00       	mov    $0x84,%ecx
f010038a:	89 fa                	mov    %edi,%edx
f010038c:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010038d:	a8 20                	test   $0x20,%al
f010038f:	75 13                	jne    f01003a4 <cons_putc+0x40>
f0100391:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f0100397:	7f 0b                	jg     f01003a4 <cons_putc+0x40>
f0100399:	89 ca                	mov    %ecx,%edx
f010039b:	ec                   	in     (%dx),%al
f010039c:	ec                   	in     (%dx),%al
f010039d:	ec                   	in     (%dx),%al
f010039e:	ec                   	in     (%dx),%al
	     i++)
f010039f:	83 c6 01             	add    $0x1,%esi
f01003a2:	eb e6                	jmp    f010038a <cons_putc+0x26>
	outb(COM1 + COM_TX, c);
f01003a4:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f01003a8:	88 45 e3             	mov    %al,-0x1d(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003ab:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003b0:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003b1:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003b6:	bf 79 03 00 00       	mov    $0x379,%edi
f01003bb:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003c0:	89 fa                	mov    %edi,%edx
f01003c2:	ec                   	in     (%dx),%al
f01003c3:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003c9:	7f 0f                	jg     f01003da <cons_putc+0x76>
f01003cb:	84 c0                	test   %al,%al
f01003cd:	78 0b                	js     f01003da <cons_putc+0x76>
f01003cf:	89 ca                	mov    %ecx,%edx
f01003d1:	ec                   	in     (%dx),%al
f01003d2:	ec                   	in     (%dx),%al
f01003d3:	ec                   	in     (%dx),%al
f01003d4:	ec                   	in     (%dx),%al
f01003d5:	83 c6 01             	add    $0x1,%esi
f01003d8:	eb e6                	jmp    f01003c0 <cons_putc+0x5c>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003da:	ba 78 03 00 00       	mov    $0x378,%edx
f01003df:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f01003e3:	ee                   	out    %al,(%dx)
f01003e4:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01003e9:	b8 0d 00 00 00       	mov    $0xd,%eax
f01003ee:	ee                   	out    %al,(%dx)
f01003ef:	b8 08 00 00 00       	mov    $0x8,%eax
f01003f4:	ee                   	out    %al,(%dx)
		c |= 0x0700;
f01003f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01003f8:	89 f8                	mov    %edi,%eax
f01003fa:	80 cc 07             	or     $0x7,%ah
f01003fd:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f0100403:	0f 45 c7             	cmovne %edi,%eax
f0100406:	89 c7                	mov    %eax,%edi
f0100408:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	switch (c & 0xff) {
f010040b:	0f b6 c0             	movzbl %al,%eax
f010040e:	89 f9                	mov    %edi,%ecx
f0100410:	80 f9 0a             	cmp    $0xa,%cl
f0100413:	0f 84 e4 00 00 00    	je     f01004fd <cons_putc+0x199>
f0100419:	83 f8 0a             	cmp    $0xa,%eax
f010041c:	7f 46                	jg     f0100464 <cons_putc+0x100>
f010041e:	83 f8 08             	cmp    $0x8,%eax
f0100421:	0f 84 a8 00 00 00    	je     f01004cf <cons_putc+0x16b>
f0100427:	83 f8 09             	cmp    $0x9,%eax
f010042a:	0f 85 da 00 00 00    	jne    f010050a <cons_putc+0x1a6>
		cons_putc(' ');
f0100430:	b8 20 00 00 00       	mov    $0x20,%eax
f0100435:	e8 2a ff ff ff       	call   f0100364 <cons_putc>
		cons_putc(' ');
f010043a:	b8 20 00 00 00       	mov    $0x20,%eax
f010043f:	e8 20 ff ff ff       	call   f0100364 <cons_putc>
		cons_putc(' ');
f0100444:	b8 20 00 00 00       	mov    $0x20,%eax
f0100449:	e8 16 ff ff ff       	call   f0100364 <cons_putc>
		cons_putc(' ');
f010044e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100453:	e8 0c ff ff ff       	call   f0100364 <cons_putc>
		cons_putc(' ');
f0100458:	b8 20 00 00 00       	mov    $0x20,%eax
f010045d:	e8 02 ff ff ff       	call   f0100364 <cons_putc>
		break;
f0100462:	eb 26                	jmp    f010048a <cons_putc+0x126>
	switch (c & 0xff) {
f0100464:	83 f8 0d             	cmp    $0xd,%eax
f0100467:	0f 85 9d 00 00 00    	jne    f010050a <cons_putc+0x1a6>
		crt_pos -= (crt_pos % CRT_COLS);
f010046d:	0f b7 83 a0 1f 00 00 	movzwl 0x1fa0(%ebx),%eax
f0100474:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f010047a:	c1 e8 16             	shr    $0x16,%eax
f010047d:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100480:	c1 e0 04             	shl    $0x4,%eax
f0100483:	66 89 83 a0 1f 00 00 	mov    %ax,0x1fa0(%ebx)
	if (crt_pos >= CRT_SIZE) {
f010048a:	66 81 bb a0 1f 00 00 	cmpw   $0x7cf,0x1fa0(%ebx)
f0100491:	cf 07 
f0100493:	0f 87 98 00 00 00    	ja     f0100531 <cons_putc+0x1cd>
	outb(addr_6845, 14);
f0100499:	8b 8b a8 1f 00 00    	mov    0x1fa8(%ebx),%ecx
f010049f:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004a4:	89 ca                	mov    %ecx,%edx
f01004a6:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004a7:	0f b7 9b a0 1f 00 00 	movzwl 0x1fa0(%ebx),%ebx
f01004ae:	8d 71 01             	lea    0x1(%ecx),%esi
f01004b1:	89 d8                	mov    %ebx,%eax
f01004b3:	66 c1 e8 08          	shr    $0x8,%ax
f01004b7:	89 f2                	mov    %esi,%edx
f01004b9:	ee                   	out    %al,(%dx)
f01004ba:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004bf:	89 ca                	mov    %ecx,%edx
f01004c1:	ee                   	out    %al,(%dx)
f01004c2:	89 d8                	mov    %ebx,%eax
f01004c4:	89 f2                	mov    %esi,%edx
f01004c6:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004ca:	5b                   	pop    %ebx
f01004cb:	5e                   	pop    %esi
f01004cc:	5f                   	pop    %edi
f01004cd:	5d                   	pop    %ebp
f01004ce:	c3                   	ret    
		if (crt_pos > 0) {
f01004cf:	0f b7 83 a0 1f 00 00 	movzwl 0x1fa0(%ebx),%eax
f01004d6:	66 85 c0             	test   %ax,%ax
f01004d9:	74 be                	je     f0100499 <cons_putc+0x135>
			crt_pos--;
f01004db:	83 e8 01             	sub    $0x1,%eax
f01004de:	66 89 83 a0 1f 00 00 	mov    %ax,0x1fa0(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004e5:	0f b7 c0             	movzwl %ax,%eax
f01004e8:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
f01004ec:	b2 00                	mov    $0x0,%dl
f01004ee:	83 ca 20             	or     $0x20,%edx
f01004f1:	8b 8b a4 1f 00 00    	mov    0x1fa4(%ebx),%ecx
f01004f7:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f01004fb:	eb 8d                	jmp    f010048a <cons_putc+0x126>
		crt_pos += CRT_COLS;
f01004fd:	66 83 83 a0 1f 00 00 	addw   $0x50,0x1fa0(%ebx)
f0100504:	50 
f0100505:	e9 63 ff ff ff       	jmp    f010046d <cons_putc+0x109>
		crt_buf[crt_pos++] = c;		/* write the character */
f010050a:	0f b7 83 a0 1f 00 00 	movzwl 0x1fa0(%ebx),%eax
f0100511:	8d 50 01             	lea    0x1(%eax),%edx
f0100514:	66 89 93 a0 1f 00 00 	mov    %dx,0x1fa0(%ebx)
f010051b:	0f b7 c0             	movzwl %ax,%eax
f010051e:	8b 93 a4 1f 00 00    	mov    0x1fa4(%ebx),%edx
f0100524:	0f b7 7d e4          	movzwl -0x1c(%ebp),%edi
f0100528:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
f010052c:	e9 59 ff ff ff       	jmp    f010048a <cons_putc+0x126>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100531:	8b 83 a4 1f 00 00    	mov    0x1fa4(%ebx),%eax
f0100537:	83 ec 04             	sub    $0x4,%esp
f010053a:	68 00 0f 00 00       	push   $0xf00
f010053f:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100545:	52                   	push   %edx
f0100546:	50                   	push   %eax
f0100547:	e8 04 12 00 00       	call   f0101750 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f010054c:	8b 93 a4 1f 00 00    	mov    0x1fa4(%ebx),%edx
f0100552:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100558:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010055e:	83 c4 10             	add    $0x10,%esp
f0100561:	66 c7 00 20 07       	movw   $0x720,(%eax)
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100566:	83 c0 02             	add    $0x2,%eax
f0100569:	39 d0                	cmp    %edx,%eax
f010056b:	75 f4                	jne    f0100561 <cons_putc+0x1fd>
		crt_pos -= CRT_COLS;
f010056d:	66 83 ab a0 1f 00 00 	subw   $0x50,0x1fa0(%ebx)
f0100574:	50 
f0100575:	e9 1f ff ff ff       	jmp    f0100499 <cons_putc+0x135>

f010057a <serial_intr>:
{
f010057a:	e8 cf 01 00 00       	call   f010074e <__x86.get_pc_thunk.ax>
f010057f:	05 89 0d 01 00       	add    $0x10d89,%eax
	if (serial_exists)
f0100584:	80 b8 ac 1f 00 00 00 	cmpb   $0x0,0x1fac(%eax)
f010058b:	75 01                	jne    f010058e <serial_intr+0x14>
f010058d:	c3                   	ret    
{
f010058e:	55                   	push   %ebp
f010058f:	89 e5                	mov    %esp,%ebp
f0100591:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f0100594:	8d 80 b8 ee fe ff    	lea    -0x11148(%eax),%eax
f010059a:	e8 3b fc ff ff       	call   f01001da <cons_intr>
}
f010059f:	c9                   	leave  
f01005a0:	c3                   	ret    

f01005a1 <kbd_intr>:
{
f01005a1:	55                   	push   %ebp
f01005a2:	89 e5                	mov    %esp,%ebp
f01005a4:	83 ec 08             	sub    $0x8,%esp
f01005a7:	e8 a2 01 00 00       	call   f010074e <__x86.get_pc_thunk.ax>
f01005ac:	05 5c 0d 01 00       	add    $0x10d5c,%eax
	cons_intr(kbd_proc_data);
f01005b1:	8d 80 36 ef fe ff    	lea    -0x110ca(%eax),%eax
f01005b7:	e8 1e fc ff ff       	call   f01001da <cons_intr>
}
f01005bc:	c9                   	leave  
f01005bd:	c3                   	ret    

f01005be <cons_getc>:
{
f01005be:	55                   	push   %ebp
f01005bf:	89 e5                	mov    %esp,%ebp
f01005c1:	53                   	push   %ebx
f01005c2:	83 ec 04             	sub    $0x4,%esp
f01005c5:	e8 f2 fb ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01005ca:	81 c3 3e 0d 01 00    	add    $0x10d3e,%ebx
	serial_intr();
f01005d0:	e8 a5 ff ff ff       	call   f010057a <serial_intr>
	kbd_intr();
f01005d5:	e8 c7 ff ff ff       	call   f01005a1 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01005da:	8b 83 98 1f 00 00    	mov    0x1f98(%ebx),%eax
	return 0;
f01005e0:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f01005e5:	3b 83 9c 1f 00 00    	cmp    0x1f9c(%ebx),%eax
f01005eb:	74 1e                	je     f010060b <cons_getc+0x4d>
		c = cons.buf[cons.rpos++];
f01005ed:	8d 48 01             	lea    0x1(%eax),%ecx
f01005f0:	0f b6 94 03 98 1d 00 	movzbl 0x1d98(%ebx,%eax,1),%edx
f01005f7:	00 
			cons.rpos = 0;
f01005f8:	3d ff 01 00 00       	cmp    $0x1ff,%eax
f01005fd:	b8 00 00 00 00       	mov    $0x0,%eax
f0100602:	0f 45 c1             	cmovne %ecx,%eax
f0100605:	89 83 98 1f 00 00    	mov    %eax,0x1f98(%ebx)
}
f010060b:	89 d0                	mov    %edx,%eax
f010060d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100610:	c9                   	leave  
f0100611:	c3                   	ret    

f0100612 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100612:	55                   	push   %ebp
f0100613:	89 e5                	mov    %esp,%ebp
f0100615:	57                   	push   %edi
f0100616:	56                   	push   %esi
f0100617:	53                   	push   %ebx
f0100618:	83 ec 1c             	sub    $0x1c,%esp
f010061b:	e8 9c fb ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100620:	81 c3 e8 0c 01 00    	add    $0x10ce8,%ebx
	was = *cp;
f0100626:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010062d:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100634:	5a a5 
	if (*cp != 0xA55A) {
f0100636:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010063d:	b9 b4 03 00 00       	mov    $0x3b4,%ecx
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100642:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
	if (*cp != 0xA55A) {
f0100647:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010064b:	0f 84 ac 00 00 00    	je     f01006fd <cons_init+0xeb>
		addr_6845 = MONO_BASE;
f0100651:	89 8b a8 1f 00 00    	mov    %ecx,0x1fa8(%ebx)
f0100657:	b8 0e 00 00 00       	mov    $0xe,%eax
f010065c:	89 ca                	mov    %ecx,%edx
f010065e:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010065f:	8d 71 01             	lea    0x1(%ecx),%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100662:	89 f2                	mov    %esi,%edx
f0100664:	ec                   	in     (%dx),%al
f0100665:	0f b6 c0             	movzbl %al,%eax
f0100668:	c1 e0 08             	shl    $0x8,%eax
f010066b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010066e:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100673:	89 ca                	mov    %ecx,%edx
f0100675:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100676:	89 f2                	mov    %esi,%edx
f0100678:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f0100679:	89 bb a4 1f 00 00    	mov    %edi,0x1fa4(%ebx)
	pos |= inb(addr_6845 + 1);
f010067f:	0f b6 c0             	movzbl %al,%eax
f0100682:	0b 45 e4             	or     -0x1c(%ebp),%eax
	crt_pos = pos;
f0100685:	66 89 83 a0 1f 00 00 	mov    %ax,0x1fa0(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010068c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100691:	89 c8                	mov    %ecx,%eax
f0100693:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100698:	ee                   	out    %al,(%dx)
f0100699:	bf fb 03 00 00       	mov    $0x3fb,%edi
f010069e:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006a3:	89 fa                	mov    %edi,%edx
f01006a5:	ee                   	out    %al,(%dx)
f01006a6:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006ab:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006b0:	ee                   	out    %al,(%dx)
f01006b1:	be f9 03 00 00       	mov    $0x3f9,%esi
f01006b6:	89 c8                	mov    %ecx,%eax
f01006b8:	89 f2                	mov    %esi,%edx
f01006ba:	ee                   	out    %al,(%dx)
f01006bb:	b8 03 00 00 00       	mov    $0x3,%eax
f01006c0:	89 fa                	mov    %edi,%edx
f01006c2:	ee                   	out    %al,(%dx)
f01006c3:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01006c8:	89 c8                	mov    %ecx,%eax
f01006ca:	ee                   	out    %al,(%dx)
f01006cb:	b8 01 00 00 00       	mov    $0x1,%eax
f01006d0:	89 f2                	mov    %esi,%edx
f01006d2:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006d3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01006d8:	ec                   	in     (%dx),%al
f01006d9:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01006db:	3c ff                	cmp    $0xff,%al
f01006dd:	0f 95 83 ac 1f 00 00 	setne  0x1fac(%ebx)
f01006e4:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01006e9:	ec                   	in     (%dx),%al
f01006ea:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006ef:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01006f0:	80 f9 ff             	cmp    $0xff,%cl
f01006f3:	74 1e                	je     f0100713 <cons_init+0x101>
		cprintf("Serial port does not exist!\n");
}
f01006f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01006f8:	5b                   	pop    %ebx
f01006f9:	5e                   	pop    %esi
f01006fa:	5f                   	pop    %edi
f01006fb:	5d                   	pop    %ebp
f01006fc:	c3                   	ret    
		*cp = was;
f01006fd:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
f0100704:	b9 d4 03 00 00       	mov    $0x3d4,%ecx
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100709:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
f010070e:	e9 3e ff ff ff       	jmp    f0100651 <cons_init+0x3f>
		cprintf("Serial port does not exist!\n");
f0100713:	83 ec 0c             	sub    $0xc,%esp
f0100716:	8d 83 c8 08 ff ff    	lea    -0xf738(%ebx),%eax
f010071c:	50                   	push   %eax
f010071d:	e8 e3 03 00 00       	call   f0100b05 <cprintf>
f0100722:	83 c4 10             	add    $0x10,%esp
}
f0100725:	eb ce                	jmp    f01006f5 <cons_init+0xe3>

f0100727 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100727:	55                   	push   %ebp
f0100728:	89 e5                	mov    %esp,%ebp
f010072a:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010072d:	8b 45 08             	mov    0x8(%ebp),%eax
f0100730:	e8 2f fc ff ff       	call   f0100364 <cons_putc>
}
f0100735:	c9                   	leave  
f0100736:	c3                   	ret    

f0100737 <getchar>:

int
getchar(void)
{
f0100737:	55                   	push   %ebp
f0100738:	89 e5                	mov    %esp,%ebp
f010073a:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010073d:	e8 7c fe ff ff       	call   f01005be <cons_getc>
f0100742:	85 c0                	test   %eax,%eax
f0100744:	74 f7                	je     f010073d <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100746:	c9                   	leave  
f0100747:	c3                   	ret    

f0100748 <iscons>:
int
iscons(int fdnum)
{
	// used by readline
	return 1;
}
f0100748:	b8 01 00 00 00       	mov    $0x1,%eax
f010074d:	c3                   	ret    

f010074e <__x86.get_pc_thunk.ax>:
f010074e:	8b 04 24             	mov    (%esp),%eax
f0100751:	c3                   	ret    

f0100752 <__x86.get_pc_thunk.si>:
f0100752:	8b 34 24             	mov    (%esp),%esi
f0100755:	c3                   	ret    

f0100756 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100756:	55                   	push   %ebp
f0100757:	89 e5                	mov    %esp,%ebp
f0100759:	56                   	push   %esi
f010075a:	53                   	push   %ebx
f010075b:	e8 5c fa ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100760:	81 c3 a8 0b 01 00    	add    $0x10ba8,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100766:	83 ec 04             	sub    $0x4,%esp
f0100769:	8d 83 f8 0a ff ff    	lea    -0xf508(%ebx),%eax
f010076f:	50                   	push   %eax
f0100770:	8d 83 16 0b ff ff    	lea    -0xf4ea(%ebx),%eax
f0100776:	50                   	push   %eax
f0100777:	8d b3 1b 0b ff ff    	lea    -0xf4e5(%ebx),%esi
f010077d:	56                   	push   %esi
f010077e:	e8 82 03 00 00       	call   f0100b05 <cprintf>
f0100783:	83 c4 0c             	add    $0xc,%esp
f0100786:	8d 83 c4 0b ff ff    	lea    -0xf43c(%ebx),%eax
f010078c:	50                   	push   %eax
f010078d:	8d 83 24 0b ff ff    	lea    -0xf4dc(%ebx),%eax
f0100793:	50                   	push   %eax
f0100794:	56                   	push   %esi
f0100795:	e8 6b 03 00 00       	call   f0100b05 <cprintf>
f010079a:	83 c4 0c             	add    $0xc,%esp
f010079d:	8d 83 2d 0b ff ff    	lea    -0xf4d3(%ebx),%eax
f01007a3:	50                   	push   %eax
f01007a4:	8d 83 3f 0b ff ff    	lea    -0xf4c1(%ebx),%eax
f01007aa:	50                   	push   %eax
f01007ab:	56                   	push   %esi
f01007ac:	e8 54 03 00 00       	call   f0100b05 <cprintf>
	return 0;
}
f01007b1:	b8 00 00 00 00       	mov    $0x0,%eax
f01007b6:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01007b9:	5b                   	pop    %ebx
f01007ba:	5e                   	pop    %esi
f01007bb:	5d                   	pop    %ebp
f01007bc:	c3                   	ret    

f01007bd <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007bd:	55                   	push   %ebp
f01007be:	89 e5                	mov    %esp,%ebp
f01007c0:	57                   	push   %edi
f01007c1:	56                   	push   %esi
f01007c2:	53                   	push   %ebx
f01007c3:	83 ec 18             	sub    $0x18,%esp
f01007c6:	e8 f1 f9 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01007cb:	81 c3 3d 0b 01 00    	add    $0x10b3d,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007d1:	8d 83 49 0b ff ff    	lea    -0xf4b7(%ebx),%eax
f01007d7:	50                   	push   %eax
f01007d8:	e8 28 03 00 00       	call   f0100b05 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007dd:	83 c4 08             	add    $0x8,%esp
f01007e0:	ff b3 f8 ff ff ff    	push   -0x8(%ebx)
f01007e6:	8d 83 ec 0b ff ff    	lea    -0xf414(%ebx),%eax
f01007ec:	50                   	push   %eax
f01007ed:	e8 13 03 00 00       	call   f0100b05 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007f2:	83 c4 0c             	add    $0xc,%esp
f01007f5:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f01007fb:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f0100801:	50                   	push   %eax
f0100802:	57                   	push   %edi
f0100803:	8d 83 14 0c ff ff    	lea    -0xf3ec(%ebx),%eax
f0100809:	50                   	push   %eax
f010080a:	e8 f6 02 00 00       	call   f0100b05 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010080f:	83 c4 0c             	add    $0xc,%esp
f0100812:	c7 c0 31 1b 10 f0    	mov    $0xf0101b31,%eax
f0100818:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010081e:	52                   	push   %edx
f010081f:	50                   	push   %eax
f0100820:	8d 83 38 0c ff ff    	lea    -0xf3c8(%ebx),%eax
f0100826:	50                   	push   %eax
f0100827:	e8 d9 02 00 00       	call   f0100b05 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010082c:	83 c4 0c             	add    $0xc,%esp
f010082f:	c7 c0 60 30 11 f0    	mov    $0xf0113060,%eax
f0100835:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010083b:	52                   	push   %edx
f010083c:	50                   	push   %eax
f010083d:	8d 83 5c 0c ff ff    	lea    -0xf3a4(%ebx),%eax
f0100843:	50                   	push   %eax
f0100844:	e8 bc 02 00 00       	call   f0100b05 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100849:	83 c4 0c             	add    $0xc,%esp
f010084c:	c7 c6 c0 36 11 f0    	mov    $0xf01136c0,%esi
f0100852:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0100858:	50                   	push   %eax
f0100859:	56                   	push   %esi
f010085a:	8d 83 80 0c ff ff    	lea    -0xf380(%ebx),%eax
f0100860:	50                   	push   %eax
f0100861:	e8 9f 02 00 00       	call   f0100b05 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100866:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100869:	29 fe                	sub    %edi,%esi
f010086b:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100871:	c1 fe 0a             	sar    $0xa,%esi
f0100874:	56                   	push   %esi
f0100875:	8d 83 a4 0c ff ff    	lea    -0xf35c(%ebx),%eax
f010087b:	50                   	push   %eax
f010087c:	e8 84 02 00 00       	call   f0100b05 <cprintf>
	return 0;
}
f0100881:	b8 00 00 00 00       	mov    $0x0,%eax
f0100886:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100889:	5b                   	pop    %ebx
f010088a:	5e                   	pop    %esi
f010088b:	5f                   	pop    %edi
f010088c:	5d                   	pop    %ebp
f010088d:	c3                   	ret    

f010088e <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010088e:	55                   	push   %ebp
f010088f:	89 e5                	mov    %esp,%ebp
f0100891:	57                   	push   %edi
f0100892:	56                   	push   %esi
f0100893:	53                   	push   %ebx
f0100894:	83 ec 48             	sub    $0x48,%esp
f0100897:	e8 20 f9 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010089c:	81 c3 6c 0a 01 00    	add    $0x10a6c,%ebx
// The function read_ebp() will be used in kern/monitor.c to get the value of ebp register which stores the base pointer of the current stack frame.
static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008a2:	89 ee                	mov    %ebp,%esi
	uint32_t ebp = read_ebp();
	// Q12 Edit: Create a structure to store the debug information
	struct Eipdebuginfo info;

	// In a stack first valye is the return address, second value is the base pointer of the previous stack frame (eip). The rest are the arguments or local variables stored in form of array. Now we have to iterate over the stack frames and print the values of the stack frame.
	cprintf("Stack backtrace:");
f01008a4:	8d 83 62 0b ff ff    	lea    -0xf49e(%ebx),%eax
f01008aa:	50                   	push   %eax
f01008ab:	e8 55 02 00 00       	call   f0100b05 <cprintf>
	while(ebp != 0){
f01008b0:	83 c4 10             	add    $0x10,%esp
		cprintf("\n");
f01008b3:	8d bb c6 08 ff ff    	lea    -0xf73a(%ebx),%edi
		// %08x is used to print the value in hexadecimal format with 8 digits.
		// Q11 Edit: Print Stack Information
		cprintf("ebp %08x eip %08x args %08x %08x %08x %08x %08x", ebp, *((uint32_t*)ebp + 1), *((uint32_t*)ebp + 2), *((uint32_t*)ebp + 3), *((uint32_t*)ebp + 4), *((uint32_t*)ebp + 5), *((uint32_t*)ebp + 6));
f01008b9:	8d 83 d0 0c ff ff    	lea    -0xf330(%ebx),%eax
f01008bf:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	while(ebp != 0){
f01008c2:	eb 68                	jmp    f010092c <mon_backtrace+0x9e>
		cprintf("\n");
f01008c4:	83 ec 0c             	sub    $0xc,%esp
f01008c7:	57                   	push   %edi
f01008c8:	e8 38 02 00 00       	call   f0100b05 <cprintf>
		cprintf("ebp %08x eip %08x args %08x %08x %08x %08x %08x", ebp, *((uint32_t*)ebp + 1), *((uint32_t*)ebp + 2), *((uint32_t*)ebp + 3), *((uint32_t*)ebp + 4), *((uint32_t*)ebp + 5), *((uint32_t*)ebp + 6));
f01008cd:	ff 76 18             	push   0x18(%esi)
f01008d0:	ff 76 14             	push   0x14(%esi)
f01008d3:	ff 76 10             	push   0x10(%esi)
f01008d6:	ff 76 0c             	push   0xc(%esi)
f01008d9:	ff 76 08             	push   0x8(%esi)
f01008dc:	ff 76 04             	push   0x4(%esi)
f01008df:	56                   	push   %esi
f01008e0:	ff 75 c4             	push   -0x3c(%ebp)
f01008e3:	e8 1d 02 00 00       	call   f0100b05 <cprintf>

		// Q12 Edit: Print Debug Information, send the eip value to the function as it is the address of the instruction that caused the call.
		debuginfo_eip(*((uint32_t*)ebp + 1), &info);
f01008e8:	83 c4 28             	add    $0x28,%esp
f01008eb:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01008ee:	50                   	push   %eax
f01008ef:	ff 76 04             	push   0x4(%esi)
f01008f2:	e8 17 03 00 00       	call   f0100c0e <debuginfo_eip>
		// Print the debug information
		cprintf("\n\t");
f01008f7:	8d 83 73 0b ff ff    	lea    -0xf48d(%ebx),%eax
f01008fd:	89 04 24             	mov    %eax,(%esp)
f0100900:	e8 00 02 00 00       	call   f0100b05 <cprintf>
		cprintf(" %s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, *((uint32_t*)ebp + 1) - info.eip_fn_addr);	
f0100905:	83 c4 08             	add    $0x8,%esp
f0100908:	8b 46 04             	mov    0x4(%esi),%eax
f010090b:	2b 45 e0             	sub    -0x20(%ebp),%eax
f010090e:	50                   	push   %eax
f010090f:	ff 75 d8             	push   -0x28(%ebp)
f0100912:	ff 75 dc             	push   -0x24(%ebp)
f0100915:	ff 75 d4             	push   -0x2c(%ebp)
f0100918:	ff 75 d0             	push   -0x30(%ebp)
f010091b:	8d 83 76 0b ff ff    	lea    -0xf48a(%ebx),%eax
f0100921:	50                   	push   %eax
f0100922:	e8 de 01 00 00       	call   f0100b05 <cprintf>

		// Update the base pointer to the previous stack frame
		ebp = *((uint32_t*)ebp);
f0100927:	8b 36                	mov    (%esi),%esi
f0100929:	83 c4 20             	add    $0x20,%esp
	while(ebp != 0){
f010092c:	85 f6                	test   %esi,%esi
f010092e:	75 94                	jne    f01008c4 <mon_backtrace+0x36>
	}
	cprintf("\n");
f0100930:	83 ec 0c             	sub    $0xc,%esp
f0100933:	8d 83 c6 08 ff ff    	lea    -0xf73a(%ebx),%eax
f0100939:	50                   	push   %eax
f010093a:	e8 c6 01 00 00       	call   f0100b05 <cprintf>
	return 0;
}
f010093f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100944:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100947:	5b                   	pop    %ebx
f0100948:	5e                   	pop    %esi
f0100949:	5f                   	pop    %edi
f010094a:	5d                   	pop    %ebp
f010094b:	c3                   	ret    

f010094c <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010094c:	55                   	push   %ebp
f010094d:	89 e5                	mov    %esp,%ebp
f010094f:	57                   	push   %edi
f0100950:	56                   	push   %esi
f0100951:	53                   	push   %ebx
f0100952:	83 ec 68             	sub    $0x68,%esp
f0100955:	e8 62 f8 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010095a:	81 c3 ae 09 01 00    	add    $0x109ae,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100960:	8d 83 00 0d ff ff    	lea    -0xf300(%ebx),%eax
f0100966:	50                   	push   %eax
f0100967:	e8 99 01 00 00       	call   f0100b05 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010096c:	8d 83 24 0d ff ff    	lea    -0xf2dc(%ebx),%eax
f0100972:	89 04 24             	mov    %eax,(%esp)
f0100975:	e8 8b 01 00 00       	call   f0100b05 <cprintf>
f010097a:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f010097d:	8d bb 8b 0b ff ff    	lea    -0xf475(%ebx),%edi
f0100983:	eb 4a                	jmp    f01009cf <monitor+0x83>
f0100985:	83 ec 08             	sub    $0x8,%esp
f0100988:	0f be c0             	movsbl %al,%eax
f010098b:	50                   	push   %eax
f010098c:	57                   	push   %edi
f010098d:	e8 39 0d 00 00       	call   f01016cb <strchr>
f0100992:	83 c4 10             	add    $0x10,%esp
f0100995:	85 c0                	test   %eax,%eax
f0100997:	74 08                	je     f01009a1 <monitor+0x55>
			*buf++ = 0;
f0100999:	c6 06 00             	movb   $0x0,(%esi)
f010099c:	8d 76 01             	lea    0x1(%esi),%esi
f010099f:	eb 76                	jmp    f0100a17 <monitor+0xcb>
		if (*buf == 0)
f01009a1:	80 3e 00             	cmpb   $0x0,(%esi)
f01009a4:	74 7c                	je     f0100a22 <monitor+0xd6>
		if (argc == MAXARGS-1) {
f01009a6:	83 7d a4 0f          	cmpl   $0xf,-0x5c(%ebp)
f01009aa:	74 0f                	je     f01009bb <monitor+0x6f>
		argv[argc++] = buf;
f01009ac:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f01009af:	8d 48 01             	lea    0x1(%eax),%ecx
f01009b2:	89 4d a4             	mov    %ecx,-0x5c(%ebp)
f01009b5:	89 74 85 a8          	mov    %esi,-0x58(%ebp,%eax,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f01009b9:	eb 41                	jmp    f01009fc <monitor+0xb0>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01009bb:	83 ec 08             	sub    $0x8,%esp
f01009be:	6a 10                	push   $0x10
f01009c0:	8d 83 90 0b ff ff    	lea    -0xf470(%ebx),%eax
f01009c6:	50                   	push   %eax
f01009c7:	e8 39 01 00 00       	call   f0100b05 <cprintf>
			return 0;
f01009cc:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f01009cf:	8d 83 87 0b ff ff    	lea    -0xf479(%ebx),%eax
f01009d5:	89 c6                	mov    %eax,%esi
f01009d7:	83 ec 0c             	sub    $0xc,%esp
f01009da:	56                   	push   %esi
f01009db:	e8 9a 0a 00 00       	call   f010147a <readline>
		if (buf != NULL)
f01009e0:	83 c4 10             	add    $0x10,%esp
f01009e3:	85 c0                	test   %eax,%eax
f01009e5:	74 f0                	je     f01009d7 <monitor+0x8b>
	argv[argc] = 0;
f01009e7:	89 c6                	mov    %eax,%esi
f01009e9:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f01009f0:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f01009f7:	eb 1e                	jmp    f0100a17 <monitor+0xcb>
			buf++;
f01009f9:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f01009fc:	0f b6 06             	movzbl (%esi),%eax
f01009ff:	84 c0                	test   %al,%al
f0100a01:	74 14                	je     f0100a17 <monitor+0xcb>
f0100a03:	83 ec 08             	sub    $0x8,%esp
f0100a06:	0f be c0             	movsbl %al,%eax
f0100a09:	50                   	push   %eax
f0100a0a:	57                   	push   %edi
f0100a0b:	e8 bb 0c 00 00       	call   f01016cb <strchr>
f0100a10:	83 c4 10             	add    $0x10,%esp
f0100a13:	85 c0                	test   %eax,%eax
f0100a15:	74 e2                	je     f01009f9 <monitor+0xad>
		while (*buf && strchr(WHITESPACE, *buf))
f0100a17:	0f b6 06             	movzbl (%esi),%eax
f0100a1a:	84 c0                	test   %al,%al
f0100a1c:	0f 85 63 ff ff ff    	jne    f0100985 <monitor+0x39>
	argv[argc] = 0;
f0100a22:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0100a25:	c7 44 85 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%eax,4)
f0100a2c:	00 
	if (argc == 0)
f0100a2d:	85 c0                	test   %eax,%eax
f0100a2f:	74 9e                	je     f01009cf <monitor+0x83>
f0100a31:	8d b3 18 1d 00 00    	lea    0x1d18(%ebx),%esi
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a37:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a3c:	89 7d a0             	mov    %edi,-0x60(%ebp)
f0100a3f:	89 c7                	mov    %eax,%edi
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a41:	83 ec 08             	sub    $0x8,%esp
f0100a44:	ff 36                	push   (%esi)
f0100a46:	ff 75 a8             	push   -0x58(%ebp)
f0100a49:	e8 1d 0c 00 00       	call   f010166b <strcmp>
f0100a4e:	83 c4 10             	add    $0x10,%esp
f0100a51:	85 c0                	test   %eax,%eax
f0100a53:	74 28                	je     f0100a7d <monitor+0x131>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a55:	83 c7 01             	add    $0x1,%edi
f0100a58:	83 c6 0c             	add    $0xc,%esi
f0100a5b:	83 ff 03             	cmp    $0x3,%edi
f0100a5e:	75 e1                	jne    f0100a41 <monitor+0xf5>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a60:	8b 7d a0             	mov    -0x60(%ebp),%edi
f0100a63:	83 ec 08             	sub    $0x8,%esp
f0100a66:	ff 75 a8             	push   -0x58(%ebp)
f0100a69:	8d 83 ad 0b ff ff    	lea    -0xf453(%ebx),%eax
f0100a6f:	50                   	push   %eax
f0100a70:	e8 90 00 00 00       	call   f0100b05 <cprintf>
	return 0;
f0100a75:	83 c4 10             	add    $0x10,%esp
f0100a78:	e9 52 ff ff ff       	jmp    f01009cf <monitor+0x83>
			return commands[i].func(argc, argv, tf);
f0100a7d:	89 f8                	mov    %edi,%eax
f0100a7f:	8b 7d a0             	mov    -0x60(%ebp),%edi
f0100a82:	83 ec 04             	sub    $0x4,%esp
f0100a85:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100a88:	ff 75 08             	push   0x8(%ebp)
f0100a8b:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a8e:	52                   	push   %edx
f0100a8f:	ff 75 a4             	push   -0x5c(%ebp)
f0100a92:	ff 94 83 20 1d 00 00 	call   *0x1d20(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100a99:	83 c4 10             	add    $0x10,%esp
f0100a9c:	85 c0                	test   %eax,%eax
f0100a9e:	0f 89 2b ff ff ff    	jns    f01009cf <monitor+0x83>
				break;
	}
}
f0100aa4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100aa7:	5b                   	pop    %ebx
f0100aa8:	5e                   	pop    %esi
f0100aa9:	5f                   	pop    %edi
f0100aaa:	5d                   	pop    %ebp
f0100aab:	c3                   	ret    

f0100aac <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100aac:	55                   	push   %ebp
f0100aad:	89 e5                	mov    %esp,%ebp
f0100aaf:	53                   	push   %ebx
f0100ab0:	83 ec 10             	sub    $0x10,%esp
f0100ab3:	e8 04 f7 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100ab8:	81 c3 50 08 01 00    	add    $0x10850,%ebx
	cputchar(ch);
f0100abe:	ff 75 08             	push   0x8(%ebp)
f0100ac1:	e8 61 fc ff ff       	call   f0100727 <cputchar>
	*cnt++;
}
f0100ac6:	83 c4 10             	add    $0x10,%esp
f0100ac9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100acc:	c9                   	leave  
f0100acd:	c3                   	ret    

f0100ace <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100ace:	55                   	push   %ebp
f0100acf:	89 e5                	mov    %esp,%ebp
f0100ad1:	53                   	push   %ebx
f0100ad2:	83 ec 14             	sub    $0x14,%esp
f0100ad5:	e8 e2 f6 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100ada:	81 c3 2e 08 01 00    	add    $0x1082e,%ebx
	int cnt = 0;
f0100ae0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100ae7:	ff 75 0c             	push   0xc(%ebp)
f0100aea:	ff 75 08             	push   0x8(%ebp)
f0100aed:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100af0:	50                   	push   %eax
f0100af1:	8d 83 a4 f7 fe ff    	lea    -0x1085c(%ebx),%eax
f0100af7:	50                   	push   %eax
f0100af8:	e8 5c 04 00 00       	call   f0100f59 <vprintfmt>
	return cnt;
}
f0100afd:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100b00:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100b03:	c9                   	leave  
f0100b04:	c3                   	ret    

f0100b05 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100b05:	55                   	push   %ebp
f0100b06:	89 e5                	mov    %esp,%ebp
f0100b08:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100b0b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100b0e:	50                   	push   %eax
f0100b0f:	ff 75 08             	push   0x8(%ebp)
f0100b12:	e8 b7 ff ff ff       	call   f0100ace <vcprintf>
	va_end(ap);

	return cnt;
}
f0100b17:	c9                   	leave  
f0100b18:	c3                   	ret    

f0100b19 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100b19:	55                   	push   %ebp
f0100b1a:	89 e5                	mov    %esp,%ebp
f0100b1c:	57                   	push   %edi
f0100b1d:	56                   	push   %esi
f0100b1e:	53                   	push   %ebx
f0100b1f:	83 ec 14             	sub    $0x14,%esp
f0100b22:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100b25:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100b28:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100b2b:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100b2e:	8b 1a                	mov    (%edx),%ebx
f0100b30:	8b 01                	mov    (%ecx),%eax
f0100b32:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100b35:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0100b3c:	eb 2f                	jmp    f0100b6d <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0100b3e:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0100b41:	39 c3                	cmp    %eax,%ebx
f0100b43:	7f 4e                	jg     f0100b93 <stab_binsearch+0x7a>
f0100b45:	0f b6 0a             	movzbl (%edx),%ecx
f0100b48:	83 ea 0c             	sub    $0xc,%edx
f0100b4b:	39 f1                	cmp    %esi,%ecx
f0100b4d:	75 ef                	jne    f0100b3e <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100b4f:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100b52:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100b55:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100b59:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100b5c:	73 3a                	jae    f0100b98 <stab_binsearch+0x7f>
			*region_left = m;
f0100b5e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100b61:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0100b63:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0100b66:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0100b6d:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100b70:	7f 53                	jg     f0100bc5 <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f0100b72:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100b75:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f0100b78:	89 d0                	mov    %edx,%eax
f0100b7a:	c1 e8 1f             	shr    $0x1f,%eax
f0100b7d:	01 d0                	add    %edx,%eax
f0100b7f:	89 c7                	mov    %eax,%edi
f0100b81:	d1 ff                	sar    %edi
f0100b83:	83 e0 fe             	and    $0xfffffffe,%eax
f0100b86:	01 f8                	add    %edi,%eax
f0100b88:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100b8b:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0100b8f:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0100b91:	eb ae                	jmp    f0100b41 <stab_binsearch+0x28>
			l = true_m + 1;
f0100b93:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0100b96:	eb d5                	jmp    f0100b6d <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0100b98:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100b9b:	76 14                	jbe    f0100bb1 <stab_binsearch+0x98>
			*region_right = m - 1;
f0100b9d:	83 e8 01             	sub    $0x1,%eax
f0100ba0:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100ba3:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100ba6:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0100ba8:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100baf:	eb bc                	jmp    f0100b6d <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100bb1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100bb4:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0100bb6:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100bba:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0100bbc:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100bc3:	eb a8                	jmp    f0100b6d <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0100bc5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100bc9:	75 15                	jne    f0100be0 <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f0100bcb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100bce:	8b 00                	mov    (%eax),%eax
f0100bd0:	83 e8 01             	sub    $0x1,%eax
f0100bd3:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100bd6:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0100bd8:	83 c4 14             	add    $0x14,%esp
f0100bdb:	5b                   	pop    %ebx
f0100bdc:	5e                   	pop    %esi
f0100bdd:	5f                   	pop    %edi
f0100bde:	5d                   	pop    %ebp
f0100bdf:	c3                   	ret    
		for (l = *region_right;
f0100be0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100be3:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100be5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100be8:	8b 0f                	mov    (%edi),%ecx
f0100bea:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100bed:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0100bf0:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0100bf4:	39 c1                	cmp    %eax,%ecx
f0100bf6:	7d 0f                	jge    f0100c07 <stab_binsearch+0xee>
f0100bf8:	0f b6 1a             	movzbl (%edx),%ebx
f0100bfb:	83 ea 0c             	sub    $0xc,%edx
f0100bfe:	39 f3                	cmp    %esi,%ebx
f0100c00:	74 05                	je     f0100c07 <stab_binsearch+0xee>
		     l--)
f0100c02:	83 e8 01             	sub    $0x1,%eax
f0100c05:	eb ed                	jmp    f0100bf4 <stab_binsearch+0xdb>
		*region_left = l;
f0100c07:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100c0a:	89 07                	mov    %eax,(%edi)
}
f0100c0c:	eb ca                	jmp    f0100bd8 <stab_binsearch+0xbf>

f0100c0e <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100c0e:	55                   	push   %ebp
f0100c0f:	89 e5                	mov    %esp,%ebp
f0100c11:	57                   	push   %edi
f0100c12:	56                   	push   %esi
f0100c13:	53                   	push   %ebx
f0100c14:	83 ec 3c             	sub    $0x3c,%esp
f0100c17:	e8 a0 f5 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100c1c:	81 c3 ec 06 01 00    	add    $0x106ec,%ebx
f0100c22:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100c25:	8d 83 49 0d ff ff    	lea    -0xf2b7(%ebx),%eax
f0100c2b:	89 06                	mov    %eax,(%esi)
	info->eip_line = 0;
f0100c2d:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0100c34:	89 46 08             	mov    %eax,0x8(%esi)
	info->eip_fn_namelen = 9;
f0100c37:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0100c3e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100c41:	89 46 10             	mov    %eax,0x10(%esi)
	info->eip_fn_narg = 0;
f0100c44:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100c4b:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f0100c50:	0f 86 3e 01 00 00    	jbe    f0100d94 <debuginfo_eip+0x186>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100c56:	c7 c0 55 5b 10 f0    	mov    $0xf0105b55,%eax
f0100c5c:	39 83 fc ff ff ff    	cmp    %eax,-0x4(%ebx)
f0100c62:	0f 86 d0 01 00 00    	jbe    f0100e38 <debuginfo_eip+0x22a>
f0100c68:	c7 c0 74 71 10 f0    	mov    $0xf0107174,%eax
f0100c6e:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0100c72:	0f 85 c7 01 00 00    	jne    f0100e3f <debuginfo_eip+0x231>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100c78:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100c7f:	c7 c0 6c 22 10 f0    	mov    $0xf010226c,%eax
f0100c85:	c7 c2 54 5b 10 f0    	mov    $0xf0105b54,%edx
f0100c8b:	29 c2                	sub    %eax,%edx
f0100c8d:	c1 fa 02             	sar    $0x2,%edx
f0100c90:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0100c96:	83 ea 01             	sub    $0x1,%edx
f0100c99:	89 55 e0             	mov    %edx,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100c9c:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100c9f:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100ca2:	83 ec 08             	sub    $0x8,%esp
f0100ca5:	ff 75 08             	push   0x8(%ebp)
f0100ca8:	6a 64                	push   $0x64
f0100caa:	e8 6a fe ff ff       	call   f0100b19 <stab_binsearch>
	if (lfile == 0)
f0100caf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100cb2:	83 c4 10             	add    $0x10,%esp
f0100cb5:	85 ff                	test   %edi,%edi
f0100cb7:	0f 84 89 01 00 00    	je     f0100e46 <debuginfo_eip+0x238>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100cbd:	89 7d dc             	mov    %edi,-0x24(%ebp)
	rfun = rfile;
f0100cc0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100cc3:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0100cc6:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100cc9:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100ccc:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100ccf:	83 ec 08             	sub    $0x8,%esp
f0100cd2:	ff 75 08             	push   0x8(%ebp)
f0100cd5:	6a 24                	push   $0x24
f0100cd7:	c7 c0 6c 22 10 f0    	mov    $0xf010226c,%eax
f0100cdd:	e8 37 fe ff ff       	call   f0100b19 <stab_binsearch>

	if (lfun <= rfun) {
f0100ce2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0100ce5:	89 4d bc             	mov    %ecx,-0x44(%ebp)
f0100ce8:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100ceb:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f0100cee:	83 c4 10             	add    $0x10,%esp
f0100cf1:	89 f8                	mov    %edi,%eax
f0100cf3:	39 d1                	cmp    %edx,%ecx
f0100cf5:	7f 39                	jg     f0100d30 <debuginfo_eip+0x122>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100cf7:	8d 04 49             	lea    (%ecx,%ecx,2),%eax
f0100cfa:	c7 c2 6c 22 10 f0    	mov    $0xf010226c,%edx
f0100d00:	8d 0c 82             	lea    (%edx,%eax,4),%ecx
f0100d03:	8b 11                	mov    (%ecx),%edx
f0100d05:	c7 c0 74 71 10 f0    	mov    $0xf0107174,%eax
f0100d0b:	81 e8 55 5b 10 f0    	sub    $0xf0105b55,%eax
f0100d11:	39 c2                	cmp    %eax,%edx
f0100d13:	73 09                	jae    f0100d1e <debuginfo_eip+0x110>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100d15:	81 c2 55 5b 10 f0    	add    $0xf0105b55,%edx
f0100d1b:	89 56 08             	mov    %edx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100d1e:	8b 41 08             	mov    0x8(%ecx),%eax
f0100d21:	89 46 10             	mov    %eax,0x10(%esi)
		addr -= info->eip_fn_addr;
f0100d24:	29 45 08             	sub    %eax,0x8(%ebp)
f0100d27:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0100d2a:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0100d2d:	89 4d c0             	mov    %ecx,-0x40(%ebp)
		// Search within the function definition for the line number.
		lline = lfun;
f0100d30:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100d33:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0100d36:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100d39:	83 ec 08             	sub    $0x8,%esp
f0100d3c:	6a 3a                	push   $0x3a
f0100d3e:	ff 76 08             	push   0x8(%esi)
f0100d41:	e8 a8 09 00 00       	call   f01016ee <strfind>
f0100d46:	2b 46 08             	sub    0x8(%esi),%eax
f0100d49:	89 46 0c             	mov    %eax,0xc(%esi)
	// Your code here.

	// Already searched within that file's stabs for the function definition
	// Now, search within the function definition for the line number. 
	// Here we use the N_SLINE stab type.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100d4c:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100d4f:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100d52:	83 c4 08             	add    $0x8,%esp
f0100d55:	ff 75 08             	push   0x8(%ebp)
f0100d58:	6a 44                	push   $0x44
f0100d5a:	c7 c0 6c 22 10 f0    	mov    $0xf010226c,%eax
f0100d60:	e8 b4 fd ff ff       	call   f0100b19 <stab_binsearch>
	if (lline <= rline)
f0100d65:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100d68:	83 c4 10             	add    $0x10,%esp
f0100d6b:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0100d6e:	0f 8f d9 00 00 00    	jg     f0100e4d <debuginfo_eip+0x23f>
		info->eip_line = stabs[lline].n_desc;
f0100d74:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0100d77:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0100d7a:	c7 c0 6c 22 10 f0    	mov    $0xf010226c,%eax
f0100d80:	0f b7 54 88 06       	movzwl 0x6(%eax,%ecx,4),%edx
f0100d85:	89 56 04             	mov    %edx,0x4(%esi)
f0100d88:	8d 44 88 04          	lea    0x4(%eax,%ecx,4),%eax
f0100d8c:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0100d8f:	89 75 0c             	mov    %esi,0xc(%ebp)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100d92:	eb 1e                	jmp    f0100db2 <debuginfo_eip+0x1a4>
  	        panic("User address");
f0100d94:	83 ec 04             	sub    $0x4,%esp
f0100d97:	8d 83 53 0d ff ff    	lea    -0xf2ad(%ebx),%eax
f0100d9d:	50                   	push   %eax
f0100d9e:	6a 7f                	push   $0x7f
f0100da0:	8d 83 60 0d ff ff    	lea    -0xf2a0(%ebx),%eax
f0100da6:	50                   	push   %eax
f0100da7:	e8 5a f3 ff ff       	call   f0100106 <_panic>
f0100dac:	83 ea 01             	sub    $0x1,%edx
f0100daf:	83 e8 0c             	sub    $0xc,%eax
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100db2:	39 d7                	cmp    %edx,%edi
f0100db4:	7f 3c                	jg     f0100df2 <debuginfo_eip+0x1e4>
	       && stabs[lline].n_type != N_SOL
f0100db6:	0f b6 08             	movzbl (%eax),%ecx
f0100db9:	80 f9 84             	cmp    $0x84,%cl
f0100dbc:	74 0b                	je     f0100dc9 <debuginfo_eip+0x1bb>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100dbe:	80 f9 64             	cmp    $0x64,%cl
f0100dc1:	75 e9                	jne    f0100dac <debuginfo_eip+0x19e>
f0100dc3:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0100dc7:	74 e3                	je     f0100dac <debuginfo_eip+0x19e>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100dc9:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100dcc:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0100dcf:	c7 c0 6c 22 10 f0    	mov    $0xf010226c,%eax
f0100dd5:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0100dd8:	c7 c0 74 71 10 f0    	mov    $0xf0107174,%eax
f0100dde:	81 e8 55 5b 10 f0    	sub    $0xf0105b55,%eax
f0100de4:	39 c2                	cmp    %eax,%edx
f0100de6:	73 0d                	jae    f0100df5 <debuginfo_eip+0x1e7>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100de8:	81 c2 55 5b 10 f0    	add    $0xf0105b55,%edx
f0100dee:	89 16                	mov    %edx,(%esi)
f0100df0:	eb 03                	jmp    f0100df5 <debuginfo_eip+0x1e7>
f0100df2:	8b 75 0c             	mov    0xc(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100df5:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0100dfa:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0100dfd:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0100e00:	39 cf                	cmp    %ecx,%edi
f0100e02:	7d 55                	jge    f0100e59 <debuginfo_eip+0x24b>
		for (lline = lfun + 1;
f0100e04:	83 c7 01             	add    $0x1,%edi
f0100e07:	89 f8                	mov    %edi,%eax
f0100e09:	8d 0c 7f             	lea    (%edi,%edi,2),%ecx
f0100e0c:	c7 c2 6c 22 10 f0    	mov    $0xf010226c,%edx
f0100e12:	8d 54 8a 04          	lea    0x4(%edx,%ecx,4),%edx
f0100e16:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100e19:	eb 04                	jmp    f0100e1f <debuginfo_eip+0x211>
			info->eip_fn_narg++;
f0100e1b:	83 46 14 01          	addl   $0x1,0x14(%esi)
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100e1f:	39 c3                	cmp    %eax,%ebx
f0100e21:	7e 31                	jle    f0100e54 <debuginfo_eip+0x246>
f0100e23:	0f b6 0a             	movzbl (%edx),%ecx
f0100e26:	83 c0 01             	add    $0x1,%eax
f0100e29:	83 c2 0c             	add    $0xc,%edx
f0100e2c:	80 f9 a0             	cmp    $0xa0,%cl
f0100e2f:	74 ea                	je     f0100e1b <debuginfo_eip+0x20d>
	return 0;
f0100e31:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e36:	eb 21                	jmp    f0100e59 <debuginfo_eip+0x24b>
		return -1;
f0100e38:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e3d:	eb 1a                	jmp    f0100e59 <debuginfo_eip+0x24b>
f0100e3f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e44:	eb 13                	jmp    f0100e59 <debuginfo_eip+0x24b>
		return -1;
f0100e46:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e4b:	eb 0c                	jmp    f0100e59 <debuginfo_eip+0x24b>
		return -1;
f0100e4d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e52:	eb 05                	jmp    f0100e59 <debuginfo_eip+0x24b>
	return 0;
f0100e54:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100e59:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e5c:	5b                   	pop    %ebx
f0100e5d:	5e                   	pop    %esi
f0100e5e:	5f                   	pop    %edi
f0100e5f:	5d                   	pop    %ebp
f0100e60:	c3                   	ret    

f0100e61 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100e61:	55                   	push   %ebp
f0100e62:	89 e5                	mov    %esp,%ebp
f0100e64:	57                   	push   %edi
f0100e65:	56                   	push   %esi
f0100e66:	53                   	push   %ebx
f0100e67:	83 ec 2c             	sub    $0x2c,%esp
f0100e6a:	e8 07 06 00 00       	call   f0101476 <__x86.get_pc_thunk.cx>
f0100e6f:	81 c1 99 04 01 00    	add    $0x10499,%ecx
f0100e75:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100e78:	89 c7                	mov    %eax,%edi
f0100e7a:	89 d6                	mov    %edx,%esi
f0100e7c:	8b 45 08             	mov    0x8(%ebp),%eax
f0100e7f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100e82:	89 d1                	mov    %edx,%ecx
f0100e84:	89 c2                	mov    %eax,%edx
f0100e86:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100e89:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0100e8c:	8b 45 10             	mov    0x10(%ebp),%eax
f0100e8f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100e92:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100e95:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0100e9c:	39 c2                	cmp    %eax,%edx
f0100e9e:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f0100ea1:	72 41                	jb     f0100ee4 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100ea3:	83 ec 0c             	sub    $0xc,%esp
f0100ea6:	ff 75 18             	push   0x18(%ebp)
f0100ea9:	83 eb 01             	sub    $0x1,%ebx
f0100eac:	53                   	push   %ebx
f0100ead:	50                   	push   %eax
f0100eae:	83 ec 08             	sub    $0x8,%esp
f0100eb1:	ff 75 e4             	push   -0x1c(%ebp)
f0100eb4:	ff 75 e0             	push   -0x20(%ebp)
f0100eb7:	ff 75 d4             	push   -0x2c(%ebp)
f0100eba:	ff 75 d0             	push   -0x30(%ebp)
f0100ebd:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100ec0:	e8 3b 0a 00 00       	call   f0101900 <__udivdi3>
f0100ec5:	83 c4 18             	add    $0x18,%esp
f0100ec8:	52                   	push   %edx
f0100ec9:	50                   	push   %eax
f0100eca:	89 f2                	mov    %esi,%edx
f0100ecc:	89 f8                	mov    %edi,%eax
f0100ece:	e8 8e ff ff ff       	call   f0100e61 <printnum>
f0100ed3:	83 c4 20             	add    $0x20,%esp
f0100ed6:	eb 13                	jmp    f0100eeb <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100ed8:	83 ec 08             	sub    $0x8,%esp
f0100edb:	56                   	push   %esi
f0100edc:	ff 75 18             	push   0x18(%ebp)
f0100edf:	ff d7                	call   *%edi
f0100ee1:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0100ee4:	83 eb 01             	sub    $0x1,%ebx
f0100ee7:	85 db                	test   %ebx,%ebx
f0100ee9:	7f ed                	jg     f0100ed8 <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100eeb:	83 ec 08             	sub    $0x8,%esp
f0100eee:	56                   	push   %esi
f0100eef:	83 ec 04             	sub    $0x4,%esp
f0100ef2:	ff 75 e4             	push   -0x1c(%ebp)
f0100ef5:	ff 75 e0             	push   -0x20(%ebp)
f0100ef8:	ff 75 d4             	push   -0x2c(%ebp)
f0100efb:	ff 75 d0             	push   -0x30(%ebp)
f0100efe:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100f01:	e8 1a 0b 00 00       	call   f0101a20 <__umoddi3>
f0100f06:	83 c4 14             	add    $0x14,%esp
f0100f09:	0f be 84 03 6e 0d ff 	movsbl -0xf292(%ebx,%eax,1),%eax
f0100f10:	ff 
f0100f11:	50                   	push   %eax
f0100f12:	ff d7                	call   *%edi
}
f0100f14:	83 c4 10             	add    $0x10,%esp
f0100f17:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f1a:	5b                   	pop    %ebx
f0100f1b:	5e                   	pop    %esi
f0100f1c:	5f                   	pop    %edi
f0100f1d:	5d                   	pop    %ebp
f0100f1e:	c3                   	ret    

f0100f1f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100f1f:	55                   	push   %ebp
f0100f20:	89 e5                	mov    %esp,%ebp
f0100f22:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100f25:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100f29:	8b 10                	mov    (%eax),%edx
f0100f2b:	3b 50 04             	cmp    0x4(%eax),%edx
f0100f2e:	73 0a                	jae    f0100f3a <sprintputch+0x1b>
		*b->buf++ = ch;
f0100f30:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100f33:	89 08                	mov    %ecx,(%eax)
f0100f35:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f38:	88 02                	mov    %al,(%edx)
}
f0100f3a:	5d                   	pop    %ebp
f0100f3b:	c3                   	ret    

f0100f3c <printfmt>:
{
f0100f3c:	55                   	push   %ebp
f0100f3d:	89 e5                	mov    %esp,%ebp
f0100f3f:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0100f42:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100f45:	50                   	push   %eax
f0100f46:	ff 75 10             	push   0x10(%ebp)
f0100f49:	ff 75 0c             	push   0xc(%ebp)
f0100f4c:	ff 75 08             	push   0x8(%ebp)
f0100f4f:	e8 05 00 00 00       	call   f0100f59 <vprintfmt>
}
f0100f54:	83 c4 10             	add    $0x10,%esp
f0100f57:	c9                   	leave  
f0100f58:	c3                   	ret    

f0100f59 <vprintfmt>:
{
f0100f59:	55                   	push   %ebp
f0100f5a:	89 e5                	mov    %esp,%ebp
f0100f5c:	57                   	push   %edi
f0100f5d:	56                   	push   %esi
f0100f5e:	53                   	push   %ebx
f0100f5f:	83 ec 3c             	sub    $0x3c,%esp
f0100f62:	e8 e7 f7 ff ff       	call   f010074e <__x86.get_pc_thunk.ax>
f0100f67:	05 a1 03 01 00       	add    $0x103a1,%eax
f0100f6c:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100f6f:	8b 75 08             	mov    0x8(%ebp),%esi
f0100f72:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0100f75:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100f78:	8d 80 3c 1d 00 00    	lea    0x1d3c(%eax),%eax
f0100f7e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100f81:	eb 0a                	jmp    f0100f8d <vprintfmt+0x34>
			putch(ch, putdat);
f0100f83:	83 ec 08             	sub    $0x8,%esp
f0100f86:	57                   	push   %edi
f0100f87:	50                   	push   %eax
f0100f88:	ff d6                	call   *%esi
f0100f8a:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100f8d:	83 c3 01             	add    $0x1,%ebx
f0100f90:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f0100f94:	83 f8 25             	cmp    $0x25,%eax
f0100f97:	74 0c                	je     f0100fa5 <vprintfmt+0x4c>
			if (ch == '\0')
f0100f99:	85 c0                	test   %eax,%eax
f0100f9b:	75 e6                	jne    f0100f83 <vprintfmt+0x2a>
}
f0100f9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100fa0:	5b                   	pop    %ebx
f0100fa1:	5e                   	pop    %esi
f0100fa2:	5f                   	pop    %edi
f0100fa3:	5d                   	pop    %ebp
f0100fa4:	c3                   	ret    
		padc = ' ';
f0100fa5:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
f0100fa9:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
f0100fb0:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f0100fb7:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
f0100fbe:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100fc3:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0100fc6:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100fc9:	8d 43 01             	lea    0x1(%ebx),%eax
f0100fcc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100fcf:	0f b6 13             	movzbl (%ebx),%edx
f0100fd2:	8d 42 dd             	lea    -0x23(%edx),%eax
f0100fd5:	3c 55                	cmp    $0x55,%al
f0100fd7:	0f 87 fd 03 00 00    	ja     f01013da <.L20>
f0100fdd:	0f b6 c0             	movzbl %al,%eax
f0100fe0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100fe3:	89 ce                	mov    %ecx,%esi
f0100fe5:	03 b4 81 fc 0d ff ff 	add    -0xf204(%ecx,%eax,4),%esi
f0100fec:	ff e6                	jmp    *%esi

f0100fee <.L68>:
f0100fee:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
f0100ff1:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
f0100ff5:	eb d2                	jmp    f0100fc9 <vprintfmt+0x70>

f0100ff7 <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
f0100ff7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100ffa:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
f0100ffe:	eb c9                	jmp    f0100fc9 <vprintfmt+0x70>

f0101000 <.L31>:
f0101000:	0f b6 d2             	movzbl %dl,%edx
f0101003:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
f0101006:	b8 00 00 00 00       	mov    $0x0,%eax
f010100b:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
f010100e:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0101011:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0101015:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
f0101018:	8d 4a d0             	lea    -0x30(%edx),%ecx
f010101b:	83 f9 09             	cmp    $0x9,%ecx
f010101e:	77 58                	ja     f0101078 <.L36+0xf>
			for (precision = 0; ; ++fmt) {
f0101020:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
f0101023:	eb e9                	jmp    f010100e <.L31+0xe>

f0101025 <.L34>:
			precision = va_arg(ap, int);
f0101025:	8b 45 14             	mov    0x14(%ebp),%eax
f0101028:	8b 00                	mov    (%eax),%eax
f010102a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010102d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101030:	8d 40 04             	lea    0x4(%eax),%eax
f0101033:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0101036:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
f0101039:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f010103d:	79 8a                	jns    f0100fc9 <vprintfmt+0x70>
				width = precision, precision = -1;
f010103f:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101042:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101045:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f010104c:	e9 78 ff ff ff       	jmp    f0100fc9 <vprintfmt+0x70>

f0101051 <.L33>:
f0101051:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101054:	85 d2                	test   %edx,%edx
f0101056:	b8 00 00 00 00       	mov    $0x0,%eax
f010105b:	0f 49 c2             	cmovns %edx,%eax
f010105e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0101061:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f0101064:	e9 60 ff ff ff       	jmp    f0100fc9 <vprintfmt+0x70>

f0101069 <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
f0101069:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
f010106c:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
f0101073:	e9 51 ff ff ff       	jmp    f0100fc9 <vprintfmt+0x70>
f0101078:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010107b:	89 75 08             	mov    %esi,0x8(%ebp)
f010107e:	eb b9                	jmp    f0101039 <.L34+0x14>

f0101080 <.L27>:
			lflag++;
f0101080:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0101084:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f0101087:	e9 3d ff ff ff       	jmp    f0100fc9 <vprintfmt+0x70>

f010108c <.L30>:
			putch(va_arg(ap, int), putdat);
f010108c:	8b 75 08             	mov    0x8(%ebp),%esi
f010108f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101092:	8d 58 04             	lea    0x4(%eax),%ebx
f0101095:	83 ec 08             	sub    $0x8,%esp
f0101098:	57                   	push   %edi
f0101099:	ff 30                	push   (%eax)
f010109b:	ff d6                	call   *%esi
			break;
f010109d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f01010a0:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
f01010a3:	e9 c8 02 00 00       	jmp    f0101370 <.L25+0x45>

f01010a8 <.L28>:
			err = va_arg(ap, int);
f01010a8:	8b 75 08             	mov    0x8(%ebp),%esi
f01010ab:	8b 45 14             	mov    0x14(%ebp),%eax
f01010ae:	8d 58 04             	lea    0x4(%eax),%ebx
f01010b1:	8b 10                	mov    (%eax),%edx
f01010b3:	89 d0                	mov    %edx,%eax
f01010b5:	f7 d8                	neg    %eax
f01010b7:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01010ba:	83 f8 06             	cmp    $0x6,%eax
f01010bd:	7f 27                	jg     f01010e6 <.L28+0x3e>
f01010bf:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f01010c2:	8b 14 82             	mov    (%edx,%eax,4),%edx
f01010c5:	85 d2                	test   %edx,%edx
f01010c7:	74 1d                	je     f01010e6 <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
f01010c9:	52                   	push   %edx
f01010ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01010cd:	8d 80 8f 0d ff ff    	lea    -0xf271(%eax),%eax
f01010d3:	50                   	push   %eax
f01010d4:	57                   	push   %edi
f01010d5:	56                   	push   %esi
f01010d6:	e8 61 fe ff ff       	call   f0100f3c <printfmt>
f01010db:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01010de:	89 5d 14             	mov    %ebx,0x14(%ebp)
f01010e1:	e9 8a 02 00 00       	jmp    f0101370 <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
f01010e6:	50                   	push   %eax
f01010e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01010ea:	8d 80 86 0d ff ff    	lea    -0xf27a(%eax),%eax
f01010f0:	50                   	push   %eax
f01010f1:	57                   	push   %edi
f01010f2:	56                   	push   %esi
f01010f3:	e8 44 fe ff ff       	call   f0100f3c <printfmt>
f01010f8:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01010fb:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f01010fe:	e9 6d 02 00 00       	jmp    f0101370 <.L25+0x45>

f0101103 <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
f0101103:	8b 75 08             	mov    0x8(%ebp),%esi
f0101106:	8b 45 14             	mov    0x14(%ebp),%eax
f0101109:	83 c0 04             	add    $0x4,%eax
f010110c:	89 45 c0             	mov    %eax,-0x40(%ebp)
f010110f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101112:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f0101114:	85 d2                	test   %edx,%edx
f0101116:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101119:	8d 80 7f 0d ff ff    	lea    -0xf281(%eax),%eax
f010111f:	0f 45 c2             	cmovne %edx,%eax
f0101122:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
f0101125:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0101129:	7e 06                	jle    f0101131 <.L24+0x2e>
f010112b:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
f010112f:	75 0d                	jne    f010113e <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
f0101131:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0101134:	89 c3                	mov    %eax,%ebx
f0101136:	03 45 d4             	add    -0x2c(%ebp),%eax
f0101139:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010113c:	eb 58                	jmp    f0101196 <.L24+0x93>
f010113e:	83 ec 08             	sub    $0x8,%esp
f0101141:	ff 75 d8             	push   -0x28(%ebp)
f0101144:	ff 75 c8             	push   -0x38(%ebp)
f0101147:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010114a:	e8 48 04 00 00       	call   f0101597 <strnlen>
f010114f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101152:	29 c2                	sub    %eax,%edx
f0101154:	89 55 bc             	mov    %edx,-0x44(%ebp)
f0101157:	83 c4 10             	add    $0x10,%esp
f010115a:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
f010115c:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f0101160:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0101163:	eb 0f                	jmp    f0101174 <.L24+0x71>
					putch(padc, putdat);
f0101165:	83 ec 08             	sub    $0x8,%esp
f0101168:	57                   	push   %edi
f0101169:	ff 75 d4             	push   -0x2c(%ebp)
f010116c:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f010116e:	83 eb 01             	sub    $0x1,%ebx
f0101171:	83 c4 10             	add    $0x10,%esp
f0101174:	85 db                	test   %ebx,%ebx
f0101176:	7f ed                	jg     f0101165 <.L24+0x62>
f0101178:	8b 55 bc             	mov    -0x44(%ebp),%edx
f010117b:	85 d2                	test   %edx,%edx
f010117d:	b8 00 00 00 00       	mov    $0x0,%eax
f0101182:	0f 49 c2             	cmovns %edx,%eax
f0101185:	29 c2                	sub    %eax,%edx
f0101187:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010118a:	eb a5                	jmp    f0101131 <.L24+0x2e>
					putch(ch, putdat);
f010118c:	83 ec 08             	sub    $0x8,%esp
f010118f:	57                   	push   %edi
f0101190:	52                   	push   %edx
f0101191:	ff d6                	call   *%esi
f0101193:	83 c4 10             	add    $0x10,%esp
f0101196:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101199:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010119b:	83 c3 01             	add    $0x1,%ebx
f010119e:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f01011a2:	0f be d0             	movsbl %al,%edx
f01011a5:	85 d2                	test   %edx,%edx
f01011a7:	74 4b                	je     f01011f4 <.L24+0xf1>
f01011a9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01011ad:	78 06                	js     f01011b5 <.L24+0xb2>
f01011af:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f01011b3:	78 1e                	js     f01011d3 <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
f01011b5:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f01011b9:	74 d1                	je     f010118c <.L24+0x89>
f01011bb:	0f be c0             	movsbl %al,%eax
f01011be:	83 e8 20             	sub    $0x20,%eax
f01011c1:	83 f8 5e             	cmp    $0x5e,%eax
f01011c4:	76 c6                	jbe    f010118c <.L24+0x89>
					putch('?', putdat);
f01011c6:	83 ec 08             	sub    $0x8,%esp
f01011c9:	57                   	push   %edi
f01011ca:	6a 3f                	push   $0x3f
f01011cc:	ff d6                	call   *%esi
f01011ce:	83 c4 10             	add    $0x10,%esp
f01011d1:	eb c3                	jmp    f0101196 <.L24+0x93>
f01011d3:	89 cb                	mov    %ecx,%ebx
f01011d5:	eb 0e                	jmp    f01011e5 <.L24+0xe2>
				putch(' ', putdat);
f01011d7:	83 ec 08             	sub    $0x8,%esp
f01011da:	57                   	push   %edi
f01011db:	6a 20                	push   $0x20
f01011dd:	ff d6                	call   *%esi
			for (; width > 0; width--)
f01011df:	83 eb 01             	sub    $0x1,%ebx
f01011e2:	83 c4 10             	add    $0x10,%esp
f01011e5:	85 db                	test   %ebx,%ebx
f01011e7:	7f ee                	jg     f01011d7 <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
f01011e9:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01011ec:	89 45 14             	mov    %eax,0x14(%ebp)
f01011ef:	e9 7c 01 00 00       	jmp    f0101370 <.L25+0x45>
f01011f4:	89 cb                	mov    %ecx,%ebx
f01011f6:	eb ed                	jmp    f01011e5 <.L24+0xe2>

f01011f8 <.L29>:
	if (lflag >= 2)
f01011f8:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01011fb:	8b 75 08             	mov    0x8(%ebp),%esi
f01011fe:	83 f9 01             	cmp    $0x1,%ecx
f0101201:	7f 1b                	jg     f010121e <.L29+0x26>
	else if (lflag)
f0101203:	85 c9                	test   %ecx,%ecx
f0101205:	74 63                	je     f010126a <.L29+0x72>
		return va_arg(*ap, long);
f0101207:	8b 45 14             	mov    0x14(%ebp),%eax
f010120a:	8b 00                	mov    (%eax),%eax
f010120c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010120f:	99                   	cltd   
f0101210:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101213:	8b 45 14             	mov    0x14(%ebp),%eax
f0101216:	8d 40 04             	lea    0x4(%eax),%eax
f0101219:	89 45 14             	mov    %eax,0x14(%ebp)
f010121c:	eb 17                	jmp    f0101235 <.L29+0x3d>
		return va_arg(*ap, long long);
f010121e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101221:	8b 50 04             	mov    0x4(%eax),%edx
f0101224:	8b 00                	mov    (%eax),%eax
f0101226:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101229:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010122c:	8b 45 14             	mov    0x14(%ebp),%eax
f010122f:	8d 40 08             	lea    0x8(%eax),%eax
f0101232:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0101235:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0101238:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
f010123b:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
f0101240:	85 db                	test   %ebx,%ebx
f0101242:	0f 89 0e 01 00 00    	jns    f0101356 <.L25+0x2b>
				putch('-', putdat);
f0101248:	83 ec 08             	sub    $0x8,%esp
f010124b:	57                   	push   %edi
f010124c:	6a 2d                	push   $0x2d
f010124e:	ff d6                	call   *%esi
				num = -(long long) num;
f0101250:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0101253:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0101256:	f7 d9                	neg    %ecx
f0101258:	83 d3 00             	adc    $0x0,%ebx
f010125b:	f7 db                	neg    %ebx
f010125d:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0101260:	ba 0a 00 00 00       	mov    $0xa,%edx
f0101265:	e9 ec 00 00 00       	jmp    f0101356 <.L25+0x2b>
		return va_arg(*ap, int);
f010126a:	8b 45 14             	mov    0x14(%ebp),%eax
f010126d:	8b 00                	mov    (%eax),%eax
f010126f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101272:	99                   	cltd   
f0101273:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101276:	8b 45 14             	mov    0x14(%ebp),%eax
f0101279:	8d 40 04             	lea    0x4(%eax),%eax
f010127c:	89 45 14             	mov    %eax,0x14(%ebp)
f010127f:	eb b4                	jmp    f0101235 <.L29+0x3d>

f0101281 <.L23>:
	if (lflag >= 2)
f0101281:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101284:	8b 75 08             	mov    0x8(%ebp),%esi
f0101287:	83 f9 01             	cmp    $0x1,%ecx
f010128a:	7f 1e                	jg     f01012aa <.L23+0x29>
	else if (lflag)
f010128c:	85 c9                	test   %ecx,%ecx
f010128e:	74 32                	je     f01012c2 <.L23+0x41>
		return va_arg(*ap, unsigned long);
f0101290:	8b 45 14             	mov    0x14(%ebp),%eax
f0101293:	8b 08                	mov    (%eax),%ecx
f0101295:	bb 00 00 00 00       	mov    $0x0,%ebx
f010129a:	8d 40 04             	lea    0x4(%eax),%eax
f010129d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01012a0:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
f01012a5:	e9 ac 00 00 00       	jmp    f0101356 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f01012aa:	8b 45 14             	mov    0x14(%ebp),%eax
f01012ad:	8b 08                	mov    (%eax),%ecx
f01012af:	8b 58 04             	mov    0x4(%eax),%ebx
f01012b2:	8d 40 08             	lea    0x8(%eax),%eax
f01012b5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01012b8:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
f01012bd:	e9 94 00 00 00       	jmp    f0101356 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f01012c2:	8b 45 14             	mov    0x14(%ebp),%eax
f01012c5:	8b 08                	mov    (%eax),%ecx
f01012c7:	bb 00 00 00 00       	mov    $0x0,%ebx
f01012cc:	8d 40 04             	lea    0x4(%eax),%eax
f01012cf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01012d2:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
f01012d7:	eb 7d                	jmp    f0101356 <.L25+0x2b>

f01012d9 <.L26>:
	if (lflag >= 2)
f01012d9:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01012dc:	8b 75 08             	mov    0x8(%ebp),%esi
f01012df:	83 f9 01             	cmp    $0x1,%ecx
f01012e2:	7f 1b                	jg     f01012ff <.L26+0x26>
	else if (lflag)
f01012e4:	85 c9                	test   %ecx,%ecx
f01012e6:	74 2c                	je     f0101314 <.L26+0x3b>
		return va_arg(*ap, unsigned long);
f01012e8:	8b 45 14             	mov    0x14(%ebp),%eax
f01012eb:	8b 08                	mov    (%eax),%ecx
f01012ed:	bb 00 00 00 00       	mov    $0x0,%ebx
f01012f2:	8d 40 04             	lea    0x4(%eax),%eax
f01012f5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01012f8:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned long);
f01012fd:	eb 57                	jmp    f0101356 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f01012ff:	8b 45 14             	mov    0x14(%ebp),%eax
f0101302:	8b 08                	mov    (%eax),%ecx
f0101304:	8b 58 04             	mov    0x4(%eax),%ebx
f0101307:	8d 40 08             	lea    0x8(%eax),%eax
f010130a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010130d:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned long long);
f0101312:	eb 42                	jmp    f0101356 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0101314:	8b 45 14             	mov    0x14(%ebp),%eax
f0101317:	8b 08                	mov    (%eax),%ecx
f0101319:	bb 00 00 00 00       	mov    $0x0,%ebx
f010131e:	8d 40 04             	lea    0x4(%eax),%eax
f0101321:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0101324:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned int);
f0101329:	eb 2b                	jmp    f0101356 <.L25+0x2b>

f010132b <.L25>:
			putch('0', putdat);
f010132b:	8b 75 08             	mov    0x8(%ebp),%esi
f010132e:	83 ec 08             	sub    $0x8,%esp
f0101331:	57                   	push   %edi
f0101332:	6a 30                	push   $0x30
f0101334:	ff d6                	call   *%esi
			putch('x', putdat);
f0101336:	83 c4 08             	add    $0x8,%esp
f0101339:	57                   	push   %edi
f010133a:	6a 78                	push   $0x78
f010133c:	ff d6                	call   *%esi
			num = (unsigned long long)
f010133e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101341:	8b 08                	mov    (%eax),%ecx
f0101343:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
f0101348:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f010134b:	8d 40 04             	lea    0x4(%eax),%eax
f010134e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101351:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
f0101356:	83 ec 0c             	sub    $0xc,%esp
f0101359:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f010135d:	50                   	push   %eax
f010135e:	ff 75 d4             	push   -0x2c(%ebp)
f0101361:	52                   	push   %edx
f0101362:	53                   	push   %ebx
f0101363:	51                   	push   %ecx
f0101364:	89 fa                	mov    %edi,%edx
f0101366:	89 f0                	mov    %esi,%eax
f0101368:	e8 f4 fa ff ff       	call   f0100e61 <printnum>
			break;
f010136d:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f0101370:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0101373:	e9 15 fc ff ff       	jmp    f0100f8d <vprintfmt+0x34>

f0101378 <.L21>:
	if (lflag >= 2)
f0101378:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010137b:	8b 75 08             	mov    0x8(%ebp),%esi
f010137e:	83 f9 01             	cmp    $0x1,%ecx
f0101381:	7f 1b                	jg     f010139e <.L21+0x26>
	else if (lflag)
f0101383:	85 c9                	test   %ecx,%ecx
f0101385:	74 2c                	je     f01013b3 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
f0101387:	8b 45 14             	mov    0x14(%ebp),%eax
f010138a:	8b 08                	mov    (%eax),%ecx
f010138c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101391:	8d 40 04             	lea    0x4(%eax),%eax
f0101394:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101397:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
f010139c:	eb b8                	jmp    f0101356 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f010139e:	8b 45 14             	mov    0x14(%ebp),%eax
f01013a1:	8b 08                	mov    (%eax),%ecx
f01013a3:	8b 58 04             	mov    0x4(%eax),%ebx
f01013a6:	8d 40 08             	lea    0x8(%eax),%eax
f01013a9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01013ac:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
f01013b1:	eb a3                	jmp    f0101356 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f01013b3:	8b 45 14             	mov    0x14(%ebp),%eax
f01013b6:	8b 08                	mov    (%eax),%ecx
f01013b8:	bb 00 00 00 00       	mov    $0x0,%ebx
f01013bd:	8d 40 04             	lea    0x4(%eax),%eax
f01013c0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01013c3:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
f01013c8:	eb 8c                	jmp    f0101356 <.L25+0x2b>

f01013ca <.L35>:
			putch(ch, putdat);
f01013ca:	8b 75 08             	mov    0x8(%ebp),%esi
f01013cd:	83 ec 08             	sub    $0x8,%esp
f01013d0:	57                   	push   %edi
f01013d1:	6a 25                	push   $0x25
f01013d3:	ff d6                	call   *%esi
			break;
f01013d5:	83 c4 10             	add    $0x10,%esp
f01013d8:	eb 96                	jmp    f0101370 <.L25+0x45>

f01013da <.L20>:
			putch('%', putdat);
f01013da:	8b 75 08             	mov    0x8(%ebp),%esi
f01013dd:	83 ec 08             	sub    $0x8,%esp
f01013e0:	57                   	push   %edi
f01013e1:	6a 25                	push   $0x25
f01013e3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01013e5:	83 c4 10             	add    $0x10,%esp
f01013e8:	89 d8                	mov    %ebx,%eax
f01013ea:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f01013ee:	74 05                	je     f01013f5 <.L20+0x1b>
f01013f0:	83 e8 01             	sub    $0x1,%eax
f01013f3:	eb f5                	jmp    f01013ea <.L20+0x10>
f01013f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01013f8:	e9 73 ff ff ff       	jmp    f0101370 <.L25+0x45>

f01013fd <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01013fd:	55                   	push   %ebp
f01013fe:	89 e5                	mov    %esp,%ebp
f0101400:	53                   	push   %ebx
f0101401:	83 ec 14             	sub    $0x14,%esp
f0101404:	e8 b3 ed ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0101409:	81 c3 ff fe 00 00    	add    $0xfeff,%ebx
f010140f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101412:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101415:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101418:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010141c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010141f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0101426:	85 c0                	test   %eax,%eax
f0101428:	74 2b                	je     f0101455 <vsnprintf+0x58>
f010142a:	85 d2                	test   %edx,%edx
f010142c:	7e 27                	jle    f0101455 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010142e:	ff 75 14             	push   0x14(%ebp)
f0101431:	ff 75 10             	push   0x10(%ebp)
f0101434:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101437:	50                   	push   %eax
f0101438:	8d 83 17 fc fe ff    	lea    -0x103e9(%ebx),%eax
f010143e:	50                   	push   %eax
f010143f:	e8 15 fb ff ff       	call   f0100f59 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0101444:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101447:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010144a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010144d:	83 c4 10             	add    $0x10,%esp
}
f0101450:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101453:	c9                   	leave  
f0101454:	c3                   	ret    
		return -E_INVAL;
f0101455:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010145a:	eb f4                	jmp    f0101450 <vsnprintf+0x53>

f010145c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010145c:	55                   	push   %ebp
f010145d:	89 e5                	mov    %esp,%ebp
f010145f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0101462:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0101465:	50                   	push   %eax
f0101466:	ff 75 10             	push   0x10(%ebp)
f0101469:	ff 75 0c             	push   0xc(%ebp)
f010146c:	ff 75 08             	push   0x8(%ebp)
f010146f:	e8 89 ff ff ff       	call   f01013fd <vsnprintf>
	va_end(ap);

	return rc;
}
f0101474:	c9                   	leave  
f0101475:	c3                   	ret    

f0101476 <__x86.get_pc_thunk.cx>:
f0101476:	8b 0c 24             	mov    (%esp),%ecx
f0101479:	c3                   	ret    

f010147a <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f010147a:	55                   	push   %ebp
f010147b:	89 e5                	mov    %esp,%ebp
f010147d:	57                   	push   %edi
f010147e:	56                   	push   %esi
f010147f:	53                   	push   %ebx
f0101480:	83 ec 1c             	sub    $0x1c,%esp
f0101483:	e8 34 ed ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0101488:	81 c3 80 fe 00 00    	add    $0xfe80,%ebx
f010148e:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0101491:	85 c0                	test   %eax,%eax
f0101493:	74 13                	je     f01014a8 <readline+0x2e>
		cprintf("%s", prompt);
f0101495:	83 ec 08             	sub    $0x8,%esp
f0101498:	50                   	push   %eax
f0101499:	8d 83 8f 0d ff ff    	lea    -0xf271(%ebx),%eax
f010149f:	50                   	push   %eax
f01014a0:	e8 60 f6 ff ff       	call   f0100b05 <cprintf>
f01014a5:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01014a8:	83 ec 0c             	sub    $0xc,%esp
f01014ab:	6a 00                	push   $0x0
f01014ad:	e8 96 f2 ff ff       	call   f0100748 <iscons>
f01014b2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01014b5:	83 c4 10             	add    $0x10,%esp
	i = 0;
f01014b8:	bf 00 00 00 00       	mov    $0x0,%edi
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
			if (echoing)
				cputchar(c);
			buf[i++] = c;
f01014bd:	8d 83 b8 1f 00 00    	lea    0x1fb8(%ebx),%eax
f01014c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01014c6:	eb 45                	jmp    f010150d <readline+0x93>
			cprintf("read error: %e\n", c);
f01014c8:	83 ec 08             	sub    $0x8,%esp
f01014cb:	50                   	push   %eax
f01014cc:	8d 83 54 0f ff ff    	lea    -0xf0ac(%ebx),%eax
f01014d2:	50                   	push   %eax
f01014d3:	e8 2d f6 ff ff       	call   f0100b05 <cprintf>
			return NULL;
f01014d8:	83 c4 10             	add    $0x10,%esp
f01014db:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f01014e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01014e3:	5b                   	pop    %ebx
f01014e4:	5e                   	pop    %esi
f01014e5:	5f                   	pop    %edi
f01014e6:	5d                   	pop    %ebp
f01014e7:	c3                   	ret    
			if (echoing)
f01014e8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01014ec:	75 05                	jne    f01014f3 <readline+0x79>
			i--;
f01014ee:	83 ef 01             	sub    $0x1,%edi
f01014f1:	eb 1a                	jmp    f010150d <readline+0x93>
				cputchar('\b');
f01014f3:	83 ec 0c             	sub    $0xc,%esp
f01014f6:	6a 08                	push   $0x8
f01014f8:	e8 2a f2 ff ff       	call   f0100727 <cputchar>
f01014fd:	83 c4 10             	add    $0x10,%esp
f0101500:	eb ec                	jmp    f01014ee <readline+0x74>
			buf[i++] = c;
f0101502:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0101505:	89 f0                	mov    %esi,%eax
f0101507:	88 04 39             	mov    %al,(%ecx,%edi,1)
f010150a:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f010150d:	e8 25 f2 ff ff       	call   f0100737 <getchar>
f0101512:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f0101514:	85 c0                	test   %eax,%eax
f0101516:	78 b0                	js     f01014c8 <readline+0x4e>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101518:	83 f8 08             	cmp    $0x8,%eax
f010151b:	0f 94 c0             	sete   %al
f010151e:	83 fe 7f             	cmp    $0x7f,%esi
f0101521:	0f 94 c2             	sete   %dl
f0101524:	08 d0                	or     %dl,%al
f0101526:	74 04                	je     f010152c <readline+0xb2>
f0101528:	85 ff                	test   %edi,%edi
f010152a:	7f bc                	jg     f01014e8 <readline+0x6e>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010152c:	83 fe 1f             	cmp    $0x1f,%esi
f010152f:	7e 1c                	jle    f010154d <readline+0xd3>
f0101531:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f0101537:	7f 14                	jg     f010154d <readline+0xd3>
			if (echoing)
f0101539:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010153d:	74 c3                	je     f0101502 <readline+0x88>
				cputchar(c);
f010153f:	83 ec 0c             	sub    $0xc,%esp
f0101542:	56                   	push   %esi
f0101543:	e8 df f1 ff ff       	call   f0100727 <cputchar>
f0101548:	83 c4 10             	add    $0x10,%esp
f010154b:	eb b5                	jmp    f0101502 <readline+0x88>
		} else if (c == '\n' || c == '\r') {
f010154d:	83 fe 0a             	cmp    $0xa,%esi
f0101550:	74 05                	je     f0101557 <readline+0xdd>
f0101552:	83 fe 0d             	cmp    $0xd,%esi
f0101555:	75 b6                	jne    f010150d <readline+0x93>
			if (echoing)
f0101557:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010155b:	75 13                	jne    f0101570 <readline+0xf6>
			buf[i] = 0;
f010155d:	c6 84 3b b8 1f 00 00 	movb   $0x0,0x1fb8(%ebx,%edi,1)
f0101564:	00 
			return buf;
f0101565:	8d 83 b8 1f 00 00    	lea    0x1fb8(%ebx),%eax
f010156b:	e9 70 ff ff ff       	jmp    f01014e0 <readline+0x66>
				cputchar('\n');
f0101570:	83 ec 0c             	sub    $0xc,%esp
f0101573:	6a 0a                	push   $0xa
f0101575:	e8 ad f1 ff ff       	call   f0100727 <cputchar>
f010157a:	83 c4 10             	add    $0x10,%esp
f010157d:	eb de                	jmp    f010155d <readline+0xe3>

f010157f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010157f:	55                   	push   %ebp
f0101580:	89 e5                	mov    %esp,%ebp
f0101582:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101585:	b8 00 00 00 00       	mov    $0x0,%eax
f010158a:	eb 03                	jmp    f010158f <strlen+0x10>
		n++;
f010158c:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f010158f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101593:	75 f7                	jne    f010158c <strlen+0xd>
	return n;
}
f0101595:	5d                   	pop    %ebp
f0101596:	c3                   	ret    

f0101597 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101597:	55                   	push   %ebp
f0101598:	89 e5                	mov    %esp,%ebp
f010159a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010159d:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01015a0:	b8 00 00 00 00       	mov    $0x0,%eax
f01015a5:	eb 03                	jmp    f01015aa <strnlen+0x13>
		n++;
f01015a7:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01015aa:	39 d0                	cmp    %edx,%eax
f01015ac:	74 08                	je     f01015b6 <strnlen+0x1f>
f01015ae:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01015b2:	75 f3                	jne    f01015a7 <strnlen+0x10>
f01015b4:	89 c2                	mov    %eax,%edx
	return n;
}
f01015b6:	89 d0                	mov    %edx,%eax
f01015b8:	5d                   	pop    %ebp
f01015b9:	c3                   	ret    

f01015ba <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01015ba:	55                   	push   %ebp
f01015bb:	89 e5                	mov    %esp,%ebp
f01015bd:	53                   	push   %ebx
f01015be:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01015c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01015c4:	b8 00 00 00 00       	mov    $0x0,%eax
f01015c9:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f01015cd:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f01015d0:	83 c0 01             	add    $0x1,%eax
f01015d3:	84 d2                	test   %dl,%dl
f01015d5:	75 f2                	jne    f01015c9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f01015d7:	89 c8                	mov    %ecx,%eax
f01015d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01015dc:	c9                   	leave  
f01015dd:	c3                   	ret    

f01015de <strcat>:

char *
strcat(char *dst, const char *src)
{
f01015de:	55                   	push   %ebp
f01015df:	89 e5                	mov    %esp,%ebp
f01015e1:	53                   	push   %ebx
f01015e2:	83 ec 10             	sub    $0x10,%esp
f01015e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01015e8:	53                   	push   %ebx
f01015e9:	e8 91 ff ff ff       	call   f010157f <strlen>
f01015ee:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f01015f1:	ff 75 0c             	push   0xc(%ebp)
f01015f4:	01 d8                	add    %ebx,%eax
f01015f6:	50                   	push   %eax
f01015f7:	e8 be ff ff ff       	call   f01015ba <strcpy>
	return dst;
}
f01015fc:	89 d8                	mov    %ebx,%eax
f01015fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101601:	c9                   	leave  
f0101602:	c3                   	ret    

f0101603 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101603:	55                   	push   %ebp
f0101604:	89 e5                	mov    %esp,%ebp
f0101606:	56                   	push   %esi
f0101607:	53                   	push   %ebx
f0101608:	8b 75 08             	mov    0x8(%ebp),%esi
f010160b:	8b 55 0c             	mov    0xc(%ebp),%edx
f010160e:	89 f3                	mov    %esi,%ebx
f0101610:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101613:	89 f0                	mov    %esi,%eax
f0101615:	eb 0f                	jmp    f0101626 <strncpy+0x23>
		*dst++ = *src;
f0101617:	83 c0 01             	add    $0x1,%eax
f010161a:	0f b6 0a             	movzbl (%edx),%ecx
f010161d:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101620:	80 f9 01             	cmp    $0x1,%cl
f0101623:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
f0101626:	39 d8                	cmp    %ebx,%eax
f0101628:	75 ed                	jne    f0101617 <strncpy+0x14>
	}
	return ret;
}
f010162a:	89 f0                	mov    %esi,%eax
f010162c:	5b                   	pop    %ebx
f010162d:	5e                   	pop    %esi
f010162e:	5d                   	pop    %ebp
f010162f:	c3                   	ret    

f0101630 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101630:	55                   	push   %ebp
f0101631:	89 e5                	mov    %esp,%ebp
f0101633:	56                   	push   %esi
f0101634:	53                   	push   %ebx
f0101635:	8b 75 08             	mov    0x8(%ebp),%esi
f0101638:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010163b:	8b 55 10             	mov    0x10(%ebp),%edx
f010163e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101640:	85 d2                	test   %edx,%edx
f0101642:	74 21                	je     f0101665 <strlcpy+0x35>
f0101644:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0101648:	89 f2                	mov    %esi,%edx
f010164a:	eb 09                	jmp    f0101655 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010164c:	83 c1 01             	add    $0x1,%ecx
f010164f:	83 c2 01             	add    $0x1,%edx
f0101652:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
f0101655:	39 c2                	cmp    %eax,%edx
f0101657:	74 09                	je     f0101662 <strlcpy+0x32>
f0101659:	0f b6 19             	movzbl (%ecx),%ebx
f010165c:	84 db                	test   %bl,%bl
f010165e:	75 ec                	jne    f010164c <strlcpy+0x1c>
f0101660:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f0101662:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0101665:	29 f0                	sub    %esi,%eax
}
f0101667:	5b                   	pop    %ebx
f0101668:	5e                   	pop    %esi
f0101669:	5d                   	pop    %ebp
f010166a:	c3                   	ret    

f010166b <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010166b:	55                   	push   %ebp
f010166c:	89 e5                	mov    %esp,%ebp
f010166e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101671:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0101674:	eb 06                	jmp    f010167c <strcmp+0x11>
		p++, q++;
f0101676:	83 c1 01             	add    $0x1,%ecx
f0101679:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f010167c:	0f b6 01             	movzbl (%ecx),%eax
f010167f:	84 c0                	test   %al,%al
f0101681:	74 04                	je     f0101687 <strcmp+0x1c>
f0101683:	3a 02                	cmp    (%edx),%al
f0101685:	74 ef                	je     f0101676 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0101687:	0f b6 c0             	movzbl %al,%eax
f010168a:	0f b6 12             	movzbl (%edx),%edx
f010168d:	29 d0                	sub    %edx,%eax
}
f010168f:	5d                   	pop    %ebp
f0101690:	c3                   	ret    

f0101691 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101691:	55                   	push   %ebp
f0101692:	89 e5                	mov    %esp,%ebp
f0101694:	53                   	push   %ebx
f0101695:	8b 45 08             	mov    0x8(%ebp),%eax
f0101698:	8b 55 0c             	mov    0xc(%ebp),%edx
f010169b:	89 c3                	mov    %eax,%ebx
f010169d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01016a0:	eb 06                	jmp    f01016a8 <strncmp+0x17>
		n--, p++, q++;
f01016a2:	83 c0 01             	add    $0x1,%eax
f01016a5:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f01016a8:	39 d8                	cmp    %ebx,%eax
f01016aa:	74 18                	je     f01016c4 <strncmp+0x33>
f01016ac:	0f b6 08             	movzbl (%eax),%ecx
f01016af:	84 c9                	test   %cl,%cl
f01016b1:	74 04                	je     f01016b7 <strncmp+0x26>
f01016b3:	3a 0a                	cmp    (%edx),%cl
f01016b5:	74 eb                	je     f01016a2 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01016b7:	0f b6 00             	movzbl (%eax),%eax
f01016ba:	0f b6 12             	movzbl (%edx),%edx
f01016bd:	29 d0                	sub    %edx,%eax
}
f01016bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01016c2:	c9                   	leave  
f01016c3:	c3                   	ret    
		return 0;
f01016c4:	b8 00 00 00 00       	mov    $0x0,%eax
f01016c9:	eb f4                	jmp    f01016bf <strncmp+0x2e>

f01016cb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01016cb:	55                   	push   %ebp
f01016cc:	89 e5                	mov    %esp,%ebp
f01016ce:	8b 45 08             	mov    0x8(%ebp),%eax
f01016d1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01016d5:	eb 03                	jmp    f01016da <strchr+0xf>
f01016d7:	83 c0 01             	add    $0x1,%eax
f01016da:	0f b6 10             	movzbl (%eax),%edx
f01016dd:	84 d2                	test   %dl,%dl
f01016df:	74 06                	je     f01016e7 <strchr+0x1c>
		if (*s == c)
f01016e1:	38 ca                	cmp    %cl,%dl
f01016e3:	75 f2                	jne    f01016d7 <strchr+0xc>
f01016e5:	eb 05                	jmp    f01016ec <strchr+0x21>
			return (char *) s;
	return 0;
f01016e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01016ec:	5d                   	pop    %ebp
f01016ed:	c3                   	ret    

f01016ee <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01016ee:	55                   	push   %ebp
f01016ef:	89 e5                	mov    %esp,%ebp
f01016f1:	8b 45 08             	mov    0x8(%ebp),%eax
f01016f4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01016f8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01016fb:	38 ca                	cmp    %cl,%dl
f01016fd:	74 09                	je     f0101708 <strfind+0x1a>
f01016ff:	84 d2                	test   %dl,%dl
f0101701:	74 05                	je     f0101708 <strfind+0x1a>
	for (; *s; s++)
f0101703:	83 c0 01             	add    $0x1,%eax
f0101706:	eb f0                	jmp    f01016f8 <strfind+0xa>
			break;
	return (char *) s;
}
f0101708:	5d                   	pop    %ebp
f0101709:	c3                   	ret    

f010170a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010170a:	55                   	push   %ebp
f010170b:	89 e5                	mov    %esp,%ebp
f010170d:	57                   	push   %edi
f010170e:	56                   	push   %esi
f010170f:	53                   	push   %ebx
f0101710:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101713:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0101716:	85 c9                	test   %ecx,%ecx
f0101718:	74 2f                	je     f0101749 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010171a:	89 f8                	mov    %edi,%eax
f010171c:	09 c8                	or     %ecx,%eax
f010171e:	a8 03                	test   $0x3,%al
f0101720:	75 21                	jne    f0101743 <memset+0x39>
		c &= 0xFF;
f0101722:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0101726:	89 d0                	mov    %edx,%eax
f0101728:	c1 e0 08             	shl    $0x8,%eax
f010172b:	89 d3                	mov    %edx,%ebx
f010172d:	c1 e3 18             	shl    $0x18,%ebx
f0101730:	89 d6                	mov    %edx,%esi
f0101732:	c1 e6 10             	shl    $0x10,%esi
f0101735:	09 f3                	or     %esi,%ebx
f0101737:	09 da                	or     %ebx,%edx
f0101739:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010173b:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f010173e:	fc                   	cld    
f010173f:	f3 ab                	rep stos %eax,%es:(%edi)
f0101741:	eb 06                	jmp    f0101749 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101743:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101746:	fc                   	cld    
f0101747:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0101749:	89 f8                	mov    %edi,%eax
f010174b:	5b                   	pop    %ebx
f010174c:	5e                   	pop    %esi
f010174d:	5f                   	pop    %edi
f010174e:	5d                   	pop    %ebp
f010174f:	c3                   	ret    

f0101750 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101750:	55                   	push   %ebp
f0101751:	89 e5                	mov    %esp,%ebp
f0101753:	57                   	push   %edi
f0101754:	56                   	push   %esi
f0101755:	8b 45 08             	mov    0x8(%ebp),%eax
f0101758:	8b 75 0c             	mov    0xc(%ebp),%esi
f010175b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010175e:	39 c6                	cmp    %eax,%esi
f0101760:	73 32                	jae    f0101794 <memmove+0x44>
f0101762:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0101765:	39 c2                	cmp    %eax,%edx
f0101767:	76 2b                	jbe    f0101794 <memmove+0x44>
		s += n;
		d += n;
f0101769:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010176c:	89 d6                	mov    %edx,%esi
f010176e:	09 fe                	or     %edi,%esi
f0101770:	09 ce                	or     %ecx,%esi
f0101772:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0101778:	75 0e                	jne    f0101788 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f010177a:	83 ef 04             	sub    $0x4,%edi
f010177d:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101780:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0101783:	fd                   	std    
f0101784:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101786:	eb 09                	jmp    f0101791 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0101788:	83 ef 01             	sub    $0x1,%edi
f010178b:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f010178e:	fd                   	std    
f010178f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0101791:	fc                   	cld    
f0101792:	eb 1a                	jmp    f01017ae <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101794:	89 f2                	mov    %esi,%edx
f0101796:	09 c2                	or     %eax,%edx
f0101798:	09 ca                	or     %ecx,%edx
f010179a:	f6 c2 03             	test   $0x3,%dl
f010179d:	75 0a                	jne    f01017a9 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010179f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f01017a2:	89 c7                	mov    %eax,%edi
f01017a4:	fc                   	cld    
f01017a5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01017a7:	eb 05                	jmp    f01017ae <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
f01017a9:	89 c7                	mov    %eax,%edi
f01017ab:	fc                   	cld    
f01017ac:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01017ae:	5e                   	pop    %esi
f01017af:	5f                   	pop    %edi
f01017b0:	5d                   	pop    %ebp
f01017b1:	c3                   	ret    

f01017b2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01017b2:	55                   	push   %ebp
f01017b3:	89 e5                	mov    %esp,%ebp
f01017b5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01017b8:	ff 75 10             	push   0x10(%ebp)
f01017bb:	ff 75 0c             	push   0xc(%ebp)
f01017be:	ff 75 08             	push   0x8(%ebp)
f01017c1:	e8 8a ff ff ff       	call   f0101750 <memmove>
}
f01017c6:	c9                   	leave  
f01017c7:	c3                   	ret    

f01017c8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01017c8:	55                   	push   %ebp
f01017c9:	89 e5                	mov    %esp,%ebp
f01017cb:	56                   	push   %esi
f01017cc:	53                   	push   %ebx
f01017cd:	8b 45 08             	mov    0x8(%ebp),%eax
f01017d0:	8b 55 0c             	mov    0xc(%ebp),%edx
f01017d3:	89 c6                	mov    %eax,%esi
f01017d5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01017d8:	eb 06                	jmp    f01017e0 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f01017da:	83 c0 01             	add    $0x1,%eax
f01017dd:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
f01017e0:	39 f0                	cmp    %esi,%eax
f01017e2:	74 14                	je     f01017f8 <memcmp+0x30>
		if (*s1 != *s2)
f01017e4:	0f b6 08             	movzbl (%eax),%ecx
f01017e7:	0f b6 1a             	movzbl (%edx),%ebx
f01017ea:	38 d9                	cmp    %bl,%cl
f01017ec:	74 ec                	je     f01017da <memcmp+0x12>
			return (int) *s1 - (int) *s2;
f01017ee:	0f b6 c1             	movzbl %cl,%eax
f01017f1:	0f b6 db             	movzbl %bl,%ebx
f01017f4:	29 d8                	sub    %ebx,%eax
f01017f6:	eb 05                	jmp    f01017fd <memcmp+0x35>
	}

	return 0;
f01017f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01017fd:	5b                   	pop    %ebx
f01017fe:	5e                   	pop    %esi
f01017ff:	5d                   	pop    %ebp
f0101800:	c3                   	ret    

f0101801 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101801:	55                   	push   %ebp
f0101802:	89 e5                	mov    %esp,%ebp
f0101804:	8b 45 08             	mov    0x8(%ebp),%eax
f0101807:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f010180a:	89 c2                	mov    %eax,%edx
f010180c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010180f:	eb 03                	jmp    f0101814 <memfind+0x13>
f0101811:	83 c0 01             	add    $0x1,%eax
f0101814:	39 d0                	cmp    %edx,%eax
f0101816:	73 04                	jae    f010181c <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101818:	38 08                	cmp    %cl,(%eax)
f010181a:	75 f5                	jne    f0101811 <memfind+0x10>
			break;
	return (void *) s;
}
f010181c:	5d                   	pop    %ebp
f010181d:	c3                   	ret    

f010181e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010181e:	55                   	push   %ebp
f010181f:	89 e5                	mov    %esp,%ebp
f0101821:	57                   	push   %edi
f0101822:	56                   	push   %esi
f0101823:	53                   	push   %ebx
f0101824:	8b 55 08             	mov    0x8(%ebp),%edx
f0101827:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010182a:	eb 03                	jmp    f010182f <strtol+0x11>
		s++;
f010182c:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
f010182f:	0f b6 02             	movzbl (%edx),%eax
f0101832:	3c 20                	cmp    $0x20,%al
f0101834:	74 f6                	je     f010182c <strtol+0xe>
f0101836:	3c 09                	cmp    $0x9,%al
f0101838:	74 f2                	je     f010182c <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f010183a:	3c 2b                	cmp    $0x2b,%al
f010183c:	74 2a                	je     f0101868 <strtol+0x4a>
	int neg = 0;
f010183e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0101843:	3c 2d                	cmp    $0x2d,%al
f0101845:	74 2b                	je     f0101872 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101847:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010184d:	75 0f                	jne    f010185e <strtol+0x40>
f010184f:	80 3a 30             	cmpb   $0x30,(%edx)
f0101852:	74 28                	je     f010187c <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0101854:	85 db                	test   %ebx,%ebx
f0101856:	b8 0a 00 00 00       	mov    $0xa,%eax
f010185b:	0f 44 d8             	cmove  %eax,%ebx
f010185e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101863:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0101866:	eb 46                	jmp    f01018ae <strtol+0x90>
		s++;
f0101868:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
f010186b:	bf 00 00 00 00       	mov    $0x0,%edi
f0101870:	eb d5                	jmp    f0101847 <strtol+0x29>
		s++, neg = 1;
f0101872:	83 c2 01             	add    $0x1,%edx
f0101875:	bf 01 00 00 00       	mov    $0x1,%edi
f010187a:	eb cb                	jmp    f0101847 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010187c:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0101880:	74 0e                	je     f0101890 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
f0101882:	85 db                	test   %ebx,%ebx
f0101884:	75 d8                	jne    f010185e <strtol+0x40>
		s++, base = 8;
f0101886:	83 c2 01             	add    $0x1,%edx
f0101889:	bb 08 00 00 00       	mov    $0x8,%ebx
f010188e:	eb ce                	jmp    f010185e <strtol+0x40>
		s += 2, base = 16;
f0101890:	83 c2 02             	add    $0x2,%edx
f0101893:	bb 10 00 00 00       	mov    $0x10,%ebx
f0101898:	eb c4                	jmp    f010185e <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f010189a:	0f be c0             	movsbl %al,%eax
f010189d:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01018a0:	3b 45 10             	cmp    0x10(%ebp),%eax
f01018a3:	7d 3a                	jge    f01018df <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f01018a5:	83 c2 01             	add    $0x1,%edx
f01018a8:	0f af 4d 10          	imul   0x10(%ebp),%ecx
f01018ac:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
f01018ae:	0f b6 02             	movzbl (%edx),%eax
f01018b1:	8d 70 d0             	lea    -0x30(%eax),%esi
f01018b4:	89 f3                	mov    %esi,%ebx
f01018b6:	80 fb 09             	cmp    $0x9,%bl
f01018b9:	76 df                	jbe    f010189a <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
f01018bb:	8d 70 9f             	lea    -0x61(%eax),%esi
f01018be:	89 f3                	mov    %esi,%ebx
f01018c0:	80 fb 19             	cmp    $0x19,%bl
f01018c3:	77 08                	ja     f01018cd <strtol+0xaf>
			dig = *s - 'a' + 10;
f01018c5:	0f be c0             	movsbl %al,%eax
f01018c8:	83 e8 57             	sub    $0x57,%eax
f01018cb:	eb d3                	jmp    f01018a0 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
f01018cd:	8d 70 bf             	lea    -0x41(%eax),%esi
f01018d0:	89 f3                	mov    %esi,%ebx
f01018d2:	80 fb 19             	cmp    $0x19,%bl
f01018d5:	77 08                	ja     f01018df <strtol+0xc1>
			dig = *s - 'A' + 10;
f01018d7:	0f be c0             	movsbl %al,%eax
f01018da:	83 e8 37             	sub    $0x37,%eax
f01018dd:	eb c1                	jmp    f01018a0 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
f01018df:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01018e3:	74 05                	je     f01018ea <strtol+0xcc>
		*endptr = (char *) s;
f01018e5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01018e8:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
f01018ea:	89 c8                	mov    %ecx,%eax
f01018ec:	f7 d8                	neg    %eax
f01018ee:	85 ff                	test   %edi,%edi
f01018f0:	0f 45 c8             	cmovne %eax,%ecx
}
f01018f3:	89 c8                	mov    %ecx,%eax
f01018f5:	5b                   	pop    %ebx
f01018f6:	5e                   	pop    %esi
f01018f7:	5f                   	pop    %edi
f01018f8:	5d                   	pop    %ebp
f01018f9:	c3                   	ret    
f01018fa:	66 90                	xchg   %ax,%ax
f01018fc:	66 90                	xchg   %ax,%ax
f01018fe:	66 90                	xchg   %ax,%ax

f0101900 <__udivdi3>:
f0101900:	f3 0f 1e fb          	endbr32 
f0101904:	55                   	push   %ebp
f0101905:	57                   	push   %edi
f0101906:	56                   	push   %esi
f0101907:	53                   	push   %ebx
f0101908:	83 ec 1c             	sub    $0x1c,%esp
f010190b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f010190f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0101913:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101917:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f010191b:	85 c0                	test   %eax,%eax
f010191d:	75 19                	jne    f0101938 <__udivdi3+0x38>
f010191f:	39 f3                	cmp    %esi,%ebx
f0101921:	76 4d                	jbe    f0101970 <__udivdi3+0x70>
f0101923:	31 ff                	xor    %edi,%edi
f0101925:	89 e8                	mov    %ebp,%eax
f0101927:	89 f2                	mov    %esi,%edx
f0101929:	f7 f3                	div    %ebx
f010192b:	89 fa                	mov    %edi,%edx
f010192d:	83 c4 1c             	add    $0x1c,%esp
f0101930:	5b                   	pop    %ebx
f0101931:	5e                   	pop    %esi
f0101932:	5f                   	pop    %edi
f0101933:	5d                   	pop    %ebp
f0101934:	c3                   	ret    
f0101935:	8d 76 00             	lea    0x0(%esi),%esi
f0101938:	39 f0                	cmp    %esi,%eax
f010193a:	76 14                	jbe    f0101950 <__udivdi3+0x50>
f010193c:	31 ff                	xor    %edi,%edi
f010193e:	31 c0                	xor    %eax,%eax
f0101940:	89 fa                	mov    %edi,%edx
f0101942:	83 c4 1c             	add    $0x1c,%esp
f0101945:	5b                   	pop    %ebx
f0101946:	5e                   	pop    %esi
f0101947:	5f                   	pop    %edi
f0101948:	5d                   	pop    %ebp
f0101949:	c3                   	ret    
f010194a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101950:	0f bd f8             	bsr    %eax,%edi
f0101953:	83 f7 1f             	xor    $0x1f,%edi
f0101956:	75 48                	jne    f01019a0 <__udivdi3+0xa0>
f0101958:	39 f0                	cmp    %esi,%eax
f010195a:	72 06                	jb     f0101962 <__udivdi3+0x62>
f010195c:	31 c0                	xor    %eax,%eax
f010195e:	39 eb                	cmp    %ebp,%ebx
f0101960:	77 de                	ja     f0101940 <__udivdi3+0x40>
f0101962:	b8 01 00 00 00       	mov    $0x1,%eax
f0101967:	eb d7                	jmp    f0101940 <__udivdi3+0x40>
f0101969:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101970:	89 d9                	mov    %ebx,%ecx
f0101972:	85 db                	test   %ebx,%ebx
f0101974:	75 0b                	jne    f0101981 <__udivdi3+0x81>
f0101976:	b8 01 00 00 00       	mov    $0x1,%eax
f010197b:	31 d2                	xor    %edx,%edx
f010197d:	f7 f3                	div    %ebx
f010197f:	89 c1                	mov    %eax,%ecx
f0101981:	31 d2                	xor    %edx,%edx
f0101983:	89 f0                	mov    %esi,%eax
f0101985:	f7 f1                	div    %ecx
f0101987:	89 c6                	mov    %eax,%esi
f0101989:	89 e8                	mov    %ebp,%eax
f010198b:	89 f7                	mov    %esi,%edi
f010198d:	f7 f1                	div    %ecx
f010198f:	89 fa                	mov    %edi,%edx
f0101991:	83 c4 1c             	add    $0x1c,%esp
f0101994:	5b                   	pop    %ebx
f0101995:	5e                   	pop    %esi
f0101996:	5f                   	pop    %edi
f0101997:	5d                   	pop    %ebp
f0101998:	c3                   	ret    
f0101999:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01019a0:	89 f9                	mov    %edi,%ecx
f01019a2:	ba 20 00 00 00       	mov    $0x20,%edx
f01019a7:	29 fa                	sub    %edi,%edx
f01019a9:	d3 e0                	shl    %cl,%eax
f01019ab:	89 44 24 08          	mov    %eax,0x8(%esp)
f01019af:	89 d1                	mov    %edx,%ecx
f01019b1:	89 d8                	mov    %ebx,%eax
f01019b3:	d3 e8                	shr    %cl,%eax
f01019b5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01019b9:	09 c1                	or     %eax,%ecx
f01019bb:	89 f0                	mov    %esi,%eax
f01019bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01019c1:	89 f9                	mov    %edi,%ecx
f01019c3:	d3 e3                	shl    %cl,%ebx
f01019c5:	89 d1                	mov    %edx,%ecx
f01019c7:	d3 e8                	shr    %cl,%eax
f01019c9:	89 f9                	mov    %edi,%ecx
f01019cb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01019cf:	89 eb                	mov    %ebp,%ebx
f01019d1:	d3 e6                	shl    %cl,%esi
f01019d3:	89 d1                	mov    %edx,%ecx
f01019d5:	d3 eb                	shr    %cl,%ebx
f01019d7:	09 f3                	or     %esi,%ebx
f01019d9:	89 c6                	mov    %eax,%esi
f01019db:	89 f2                	mov    %esi,%edx
f01019dd:	89 d8                	mov    %ebx,%eax
f01019df:	f7 74 24 08          	divl   0x8(%esp)
f01019e3:	89 d6                	mov    %edx,%esi
f01019e5:	89 c3                	mov    %eax,%ebx
f01019e7:	f7 64 24 0c          	mull   0xc(%esp)
f01019eb:	39 d6                	cmp    %edx,%esi
f01019ed:	72 19                	jb     f0101a08 <__udivdi3+0x108>
f01019ef:	89 f9                	mov    %edi,%ecx
f01019f1:	d3 e5                	shl    %cl,%ebp
f01019f3:	39 c5                	cmp    %eax,%ebp
f01019f5:	73 04                	jae    f01019fb <__udivdi3+0xfb>
f01019f7:	39 d6                	cmp    %edx,%esi
f01019f9:	74 0d                	je     f0101a08 <__udivdi3+0x108>
f01019fb:	89 d8                	mov    %ebx,%eax
f01019fd:	31 ff                	xor    %edi,%edi
f01019ff:	e9 3c ff ff ff       	jmp    f0101940 <__udivdi3+0x40>
f0101a04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101a08:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0101a0b:	31 ff                	xor    %edi,%edi
f0101a0d:	e9 2e ff ff ff       	jmp    f0101940 <__udivdi3+0x40>
f0101a12:	66 90                	xchg   %ax,%ax
f0101a14:	66 90                	xchg   %ax,%ax
f0101a16:	66 90                	xchg   %ax,%ax
f0101a18:	66 90                	xchg   %ax,%ax
f0101a1a:	66 90                	xchg   %ax,%ax
f0101a1c:	66 90                	xchg   %ax,%ax
f0101a1e:	66 90                	xchg   %ax,%ax

f0101a20 <__umoddi3>:
f0101a20:	f3 0f 1e fb          	endbr32 
f0101a24:	55                   	push   %ebp
f0101a25:	57                   	push   %edi
f0101a26:	56                   	push   %esi
f0101a27:	53                   	push   %ebx
f0101a28:	83 ec 1c             	sub    $0x1c,%esp
f0101a2b:	8b 74 24 30          	mov    0x30(%esp),%esi
f0101a2f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0101a33:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
f0101a37:	8b 6c 24 38          	mov    0x38(%esp),%ebp
f0101a3b:	89 f0                	mov    %esi,%eax
f0101a3d:	89 da                	mov    %ebx,%edx
f0101a3f:	85 ff                	test   %edi,%edi
f0101a41:	75 15                	jne    f0101a58 <__umoddi3+0x38>
f0101a43:	39 dd                	cmp    %ebx,%ebp
f0101a45:	76 39                	jbe    f0101a80 <__umoddi3+0x60>
f0101a47:	f7 f5                	div    %ebp
f0101a49:	89 d0                	mov    %edx,%eax
f0101a4b:	31 d2                	xor    %edx,%edx
f0101a4d:	83 c4 1c             	add    $0x1c,%esp
f0101a50:	5b                   	pop    %ebx
f0101a51:	5e                   	pop    %esi
f0101a52:	5f                   	pop    %edi
f0101a53:	5d                   	pop    %ebp
f0101a54:	c3                   	ret    
f0101a55:	8d 76 00             	lea    0x0(%esi),%esi
f0101a58:	39 df                	cmp    %ebx,%edi
f0101a5a:	77 f1                	ja     f0101a4d <__umoddi3+0x2d>
f0101a5c:	0f bd cf             	bsr    %edi,%ecx
f0101a5f:	83 f1 1f             	xor    $0x1f,%ecx
f0101a62:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0101a66:	75 40                	jne    f0101aa8 <__umoddi3+0x88>
f0101a68:	39 df                	cmp    %ebx,%edi
f0101a6a:	72 04                	jb     f0101a70 <__umoddi3+0x50>
f0101a6c:	39 f5                	cmp    %esi,%ebp
f0101a6e:	77 dd                	ja     f0101a4d <__umoddi3+0x2d>
f0101a70:	89 da                	mov    %ebx,%edx
f0101a72:	89 f0                	mov    %esi,%eax
f0101a74:	29 e8                	sub    %ebp,%eax
f0101a76:	19 fa                	sbb    %edi,%edx
f0101a78:	eb d3                	jmp    f0101a4d <__umoddi3+0x2d>
f0101a7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101a80:	89 e9                	mov    %ebp,%ecx
f0101a82:	85 ed                	test   %ebp,%ebp
f0101a84:	75 0b                	jne    f0101a91 <__umoddi3+0x71>
f0101a86:	b8 01 00 00 00       	mov    $0x1,%eax
f0101a8b:	31 d2                	xor    %edx,%edx
f0101a8d:	f7 f5                	div    %ebp
f0101a8f:	89 c1                	mov    %eax,%ecx
f0101a91:	89 d8                	mov    %ebx,%eax
f0101a93:	31 d2                	xor    %edx,%edx
f0101a95:	f7 f1                	div    %ecx
f0101a97:	89 f0                	mov    %esi,%eax
f0101a99:	f7 f1                	div    %ecx
f0101a9b:	89 d0                	mov    %edx,%eax
f0101a9d:	31 d2                	xor    %edx,%edx
f0101a9f:	eb ac                	jmp    f0101a4d <__umoddi3+0x2d>
f0101aa1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101aa8:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101aac:	ba 20 00 00 00       	mov    $0x20,%edx
f0101ab1:	29 c2                	sub    %eax,%edx
f0101ab3:	89 c1                	mov    %eax,%ecx
f0101ab5:	89 e8                	mov    %ebp,%eax
f0101ab7:	d3 e7                	shl    %cl,%edi
f0101ab9:	89 d1                	mov    %edx,%ecx
f0101abb:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101abf:	d3 e8                	shr    %cl,%eax
f0101ac1:	89 c1                	mov    %eax,%ecx
f0101ac3:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101ac7:	09 f9                	or     %edi,%ecx
f0101ac9:	89 df                	mov    %ebx,%edi
f0101acb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101acf:	89 c1                	mov    %eax,%ecx
f0101ad1:	d3 e5                	shl    %cl,%ebp
f0101ad3:	89 d1                	mov    %edx,%ecx
f0101ad5:	d3 ef                	shr    %cl,%edi
f0101ad7:	89 c1                	mov    %eax,%ecx
f0101ad9:	89 f0                	mov    %esi,%eax
f0101adb:	d3 e3                	shl    %cl,%ebx
f0101add:	89 d1                	mov    %edx,%ecx
f0101adf:	89 fa                	mov    %edi,%edx
f0101ae1:	d3 e8                	shr    %cl,%eax
f0101ae3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101ae8:	09 d8                	or     %ebx,%eax
f0101aea:	f7 74 24 08          	divl   0x8(%esp)
f0101aee:	89 d3                	mov    %edx,%ebx
f0101af0:	d3 e6                	shl    %cl,%esi
f0101af2:	f7 e5                	mul    %ebp
f0101af4:	89 c7                	mov    %eax,%edi
f0101af6:	89 d1                	mov    %edx,%ecx
f0101af8:	39 d3                	cmp    %edx,%ebx
f0101afa:	72 06                	jb     f0101b02 <__umoddi3+0xe2>
f0101afc:	75 0e                	jne    f0101b0c <__umoddi3+0xec>
f0101afe:	39 c6                	cmp    %eax,%esi
f0101b00:	73 0a                	jae    f0101b0c <__umoddi3+0xec>
f0101b02:	29 e8                	sub    %ebp,%eax
f0101b04:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0101b08:	89 d1                	mov    %edx,%ecx
f0101b0a:	89 c7                	mov    %eax,%edi
f0101b0c:	89 f5                	mov    %esi,%ebp
f0101b0e:	8b 74 24 04          	mov    0x4(%esp),%esi
f0101b12:	29 fd                	sub    %edi,%ebp
f0101b14:	19 cb                	sbb    %ecx,%ebx
f0101b16:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f0101b1b:	89 d8                	mov    %ebx,%eax
f0101b1d:	d3 e0                	shl    %cl,%eax
f0101b1f:	89 f1                	mov    %esi,%ecx
f0101b21:	d3 ed                	shr    %cl,%ebp
f0101b23:	d3 eb                	shr    %cl,%ebx
f0101b25:	09 e8                	or     %ebp,%eax
f0101b27:	89 da                	mov    %ebx,%edx
f0101b29:	83 c4 1c             	add    $0x1c,%esp
f0101b2c:	5b                   	pop    %ebx
f0101b2d:	5e                   	pop    %esi
f0101b2e:	5f                   	pop    %edi
f0101b2f:	5d                   	pop    %ebp
f0101b30:	c3                   	ret    
