	.file	"init.c"
	.stabs	"kern/init.c",100,0,2,.Ltext0
	.text
.Ltext0:
	.stabs	"gcc2_compiled.",60,0,0,0
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC0:
	.string	"entering test_backtrace %d\n"
.LC1:
	.string	"leaving test_backtrace %d\n"
	.text
	.p2align 4
	.stabs	"test_backtrace:F(0,1)=(0,1)",36,0,0,test_backtrace
	.stabs	"void:t(0,1)",128,0,0,0
	.stabs	"x:P(0,2)=r(0,2);-2147483648;2147483647;",64,0,0,6
	.stabs	"int:t(0,2)",128,0,0,0
	.globl	test_backtrace
	.type	test_backtrace, @function
test_backtrace:
	.stabn	68,0,13,.LM0-.LFBB1
.LM0:
.LFBB1:
.LFB0:
	.cfi_startproc
	endbr64
	pushq	%r15
	.cfi_def_cfa_offset 16
	.cfi_offset 15, -16
	.stabn	68,0,14,.LM1-.LFBB1
.LM1:
	movl	%edi, %esi
	xorl	%eax, %eax
	.stabn	68,0,13,.LM2-.LFBB1
.LM2:
	pushq	%r14
	.cfi_def_cfa_offset 24
	.cfi_offset 14, -24
	pushq	%r13
	.cfi_def_cfa_offset 32
	.cfi_offset 13, -32
	pushq	%r12
	.cfi_def_cfa_offset 40
	.cfi_offset 12, -40
	.stabn	68,0,14,.LM3-.LFBB1
.LM3:
	leaq	.LC0(%rip), %r12
	.stabn	68,0,13,.LM4-.LFBB1
.LM4:
	pushq	%rbp
	.cfi_def_cfa_offset 48
	.cfi_offset 6, -48
	movl	%edi, %ebp
	.stabn	68,0,14,.LM5-.LFBB1
.LM5:
	movq	%r12, %rdi
	.stabn	68,0,13,.LM6-.LFBB1
.LM6:
	pushq	%rbx
	.cfi_def_cfa_offset 56
	.cfi_offset 3, -56
	subq	$8, %rsp
	.cfi_def_cfa_offset 64
	.stabn	68,0,14,.LM7-.LFBB1
.LM7:
	call	cprintf@PLT
	.stabn	68,0,15,.LM8-.LFBB1
.LM8:
	testl	%ebp, %ebp
	jle	.L2
	.stabn	68,0,16,.LM9-.LFBB1
.LM9:
	leal	-1(%rbp), %r13d
.LBB10:
.LBB11:
	.stabn	68,0,14,.LM10-.LFBB1
.LM10:
	xorl	%eax, %eax
	movq	%r12, %rdi
	movl	%r13d, %esi
	call	cprintf@PLT
	.stabn	68,0,15,.LM11-.LFBB1
.LM11:
	testl	%r13d, %r13d
	je	.L3
	.stabn	68,0,16,.LM12-.LFBB1
.LM12:
	leal	-2(%rbp), %r14d
.LBB12:
.LBB13:
	.stabn	68,0,14,.LM13-.LFBB1
.LM13:
	xorl	%eax, %eax
	movq	%r12, %rdi
	movl	%r14d, %esi
	call	cprintf@PLT
	.stabn	68,0,15,.LM14-.LFBB1
.LM14:
	testl	%r14d, %r14d
	je	.L4
	.stabn	68,0,16,.LM15-.LFBB1
.LM15:
	leal	-3(%rbp), %r15d
.LBB14:
.LBB15:
	.stabn	68,0,14,.LM16-.LFBB1
.LM16:
	xorl	%eax, %eax
	movq	%r12, %rdi
	movl	%r15d, %esi
	call	cprintf@PLT
	.stabn	68,0,15,.LM17-.LFBB1
.LM17:
	testl	%r15d, %r15d
	je	.L5
	.stabn	68,0,16,.LM18-.LFBB1
.LM18:
	leal	-4(%rbp), %ebx
.LBB16:
.LBB17:
	.stabn	68,0,14,.LM19-.LFBB1
.LM19:
	xorl	%eax, %eax
	movq	%r12, %rdi
	movl	%ebx, %esi
	call	cprintf@PLT
	.stabn	68,0,15,.LM20-.LFBB1
.LM20:
	testl	%ebx, %ebx
	je	.L6
	.stabn	68,0,16,.LM21-.LFBB1
.LM21:
	leal	-5(%rbp), %edi
	call	test_backtrace
.L7:
	.stabn	68,0,19,.LM22-.LFBB1
.LM22:
	leaq	.LC1(%rip), %r12
	movl	%ebx, %esi
	xorl	%eax, %eax
	movq	%r12, %rdi
	call	cprintf@PLT
.L8:
.LBE17:
.LBE16:
	movl	%r15d, %esi
	movq	%r12, %rdi
	xorl	%eax, %eax
	call	cprintf@PLT
.L9:
.LBE15:
.LBE14:
	movl	%r14d, %esi
	movq	%r12, %rdi
	xorl	%eax, %eax
	call	cprintf@PLT
	.stabn	68,0,20,.LM23-.LFBB1
.LM23:
	jmp	.L10
	.p2align 4,,10
	.p2align 3
.L3:
.LBE13:
.LBE12:
	.stabn	68,0,18,.LM24-.LFBB1
.LM24:
	xorl	%edx, %edx
	xorl	%esi, %esi
	leaq	.LC1(%rip), %r12
	xorl	%edi, %edi
	call	mon_backtrace@PLT
.L10:
	.stabn	68,0,19,.LM25-.LFBB1
.LM25:
	movl	%r13d, %esi
	movq	%r12, %rdi
	xorl	%eax, %eax
	call	cprintf@PLT
.L11:
.LBE11:
.LBE10:
	.stabn	68,0,20,.LM26-.LFBB1
.LM26:
	addq	$8, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 56
	.stabn	68,0,19,.LM27-.LFBB1
.LM27:
	movl	%ebp, %esi
	movq	%r12, %rdi
	xorl	%eax, %eax
	.stabn	68,0,20,.LM28-.LFBB1
.LM28:
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%rbp
	.cfi_def_cfa_offset 40
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r13
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	.stabn	68,0,19,.LM29-.LFBB1
.LM29:
	jmp	cprintf@PLT
	.p2align 4,,10
	.p2align 3
.L2:
	.cfi_restore_state
	.stabn	68,0,18,.LM30-.LFBB1
.LM30:
	xorl	%edx, %edx
	xorl	%esi, %esi
	leaq	.LC1(%rip), %r12
	xorl	%edi, %edi
	call	mon_backtrace@PLT
	jmp	.L11
	.p2align 4,,10
	.p2align 3
.L5:
.LBB27:
.LBB26:
.LBB25:
.LBB24:
.LBB22:
.LBB20:
	xorl	%edx, %edx
	xorl	%esi, %esi
	leaq	.LC1(%rip), %r12
	xorl	%edi, %edi
	call	mon_backtrace@PLT
	jmp	.L8
	.p2align 4,,10
	.p2align 3
.L4:
.LBE20:
.LBE22:
	xorl	%edx, %edx
	xorl	%esi, %esi
	leaq	.LC1(%rip), %r12
	xorl	%edi, %edi
	call	mon_backtrace@PLT
	jmp	.L9
	.p2align 4,,10
	.p2align 3
.L6:
.LBB23:
.LBB21:
.LBB19:
.LBB18:
	xorl	%edx, %edx
	xorl	%esi, %esi
	xorl	%edi, %edi
	call	mon_backtrace@PLT
	jmp	.L7
.LBE18:
.LBE19:
.LBE21:
.LBE23:
.LBE24:
.LBE25:
.LBE26:
.LBE27:
	.cfi_endproc
.LFE0:
	.size	test_backtrace, .-test_backtrace
.Lscope1:
	.section	.rodata.str1.1
.LC2:
	.string	"6828 decimal is %o octal!\n"
	.text
	.p2align 4
	.stabs	"i386_init:F(0,1)",36,0,0,i386_init
	.globl	i386_init
	.type	i386_init, @function
i386_init:
	.stabn	68,0,24,.LM31-.LFBB2
.LM31:
.LFBB2:
.LFB1:
	.cfi_startproc
	endbr64
	pushq	%rax
	.cfi_def_cfa_offset 16
	popq	%rax
	.cfi_def_cfa_offset 8
	.stabn	68,0,30,.LM32-.LFBB2
.LM32:
	leaq	edata(%rip), %rdi
	.stabn	68,0,30,.LM33-.LFBB2
.LM33:
	leaq	end(%rip), %rdx
	xorl	%esi, %esi
	subl	%edi, %edx
	.stabn	68,0,24,.LM34-.LFBB2
.LM34:
	subq	$8, %rsp
	.cfi_def_cfa_offset 16
	.stabn	68,0,30,.LM35-.LFBB2
.LM35:
	call	memset@PLT
	.stabn	68,0,34,.LM36-.LFBB2
.LM36:
	call	cons_init@PLT
	.stabn	68,0,36,.LM37-.LFBB2
.LM37:
	leaq	.LC2(%rip), %rdi
	movl	$6828, %esi
	xorl	%eax, %eax
	call	cprintf@PLT
	.stabn	68,0,45,.LM38-.LFBB2
.LM38:
	movl	$5, %edi
	call	test_backtrace
	.p2align 4,,10
	.p2align 3
.L15:
	.stabn	68,0,49,.LM39-.LFBB2
.LM39:
	xorl	%edi, %edi
	call	monitor@PLT
	jmp	.L15
	.cfi_endproc
.LFE1:
	.size	i386_init, .-i386_init
.Lscope2:
	.section	.rodata.str1.1
.LC3:
	.string	"kernel panic at %s:%d: "
.LC4:
	.string	"\n"
	.text
	.p2align 4
	.stabs	"_panic:F(0,1)",36,0,0,_panic
	.stabs	"file:P(0,3)=*(0,4)=r(0,4);0;127;",64,0,0,5
	.stabs	"line:P(0,2)",64,0,0,4
	.stabs	"fmt:P(0,3)",64,0,0,6
	.stabs	"char:t(0,4)",128,0,0,0
	.globl	_panic
	.type	_panic, @function
_panic:
	.stabn	68,0,65,.LM40-.LFBB3
.LM40:
.LFBB3:
.LFB2:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rdx, %rbp
	subq	$208, %rsp
	.cfi_def_cfa_offset 224
	movq	%rcx, 56(%rsp)
	movq	%r8, 64(%rsp)
	movq	%r9, 72(%rsp)
	testb	%al, %al
	je	.L18
	movaps	%xmm0, 80(%rsp)
	movaps	%xmm1, 96(%rsp)
	movaps	%xmm2, 112(%rsp)
	movaps	%xmm3, 128(%rsp)
	movaps	%xmm4, 144(%rsp)
	movaps	%xmm5, 160(%rsp)
	movaps	%xmm6, 176(%rsp)
	movaps	%xmm7, 192(%rsp)
.L18:
	.stabn	68,0,65,.LM41-.LFBB3
.LM41:
	movq	%fs:40, %rax
	movq	%rax, 24(%rsp)
	xorl	%eax, %eax
	.stabn	68,0,68,.LM42-.LFBB3
.LM42:
	cmpq	$0, panicstr(%rip)
	je	.L23
	.p2align 4,,10
	.p2align 3
.L20:
	.stabn	68,0,84,.LM43-.LFBB3
.LM43:
	xorl	%edi, %edi
	call	monitor@PLT
	jmp	.L20
.L23:
	.stabn	68,0,70,.LM44-.LFBB3
.LM44:
	movq	%rbp, panicstr(%rip)
	.stabn	68,0,73,.LM45-.LFBB3
.LM45:
#APP
# 73 "kern/init.c" 1
	cli; cld
# 0 "" 2
	.stabn	68,0,75,.LM46-.LFBB3
.LM46:
#NO_APP
	leaq	224(%rsp), %rax
	.stabn	68,0,76,.LM47-.LFBB3
.LM47:
	movl	%esi, %edx
	movq	%rdi, %rsi
	.stabn	68,0,75,.LM48-.LFBB3
.LM48:
	movl	$24, (%rsp)
	movq	%rax, 8(%rsp)
	leaq	32(%rsp), %rax
	.stabn	68,0,76,.LM49-.LFBB3
.LM49:
	leaq	.LC3(%rip), %rdi
	.stabn	68,0,75,.LM50-.LFBB3
.LM50:
	movq	%rax, 16(%rsp)
	.stabn	68,0,76,.LM51-.LFBB3
.LM51:
	xorl	%eax, %eax
	.stabn	68,0,75,.LM52-.LFBB3
.LM52:
	movl	$48, 4(%rsp)
	.stabn	68,0,76,.LM53-.LFBB3
.LM53:
	call	cprintf@PLT
	.stabn	68,0,77,.LM54-.LFBB3
.LM54:
	movq	%rbp, %rdi
	movq	%rsp, %rsi
	call	vcprintf@PLT
	.stabn	68,0,78,.LM55-.LFBB3
.LM55:
	leaq	.LC4(%rip), %rdi
	xorl	%eax, %eax
	call	cprintf@PLT
	jmp	.L20
	.cfi_endproc
.LFE2:
	.size	_panic, .-_panic
	.stabs	"ap:(0,5)=(0,6)=(0,7)=ar(0,8)=r(0,8);0;-1;;0;0;(0,9)=xs__va_list_tag:",128,0,0,0
	.stabs	"va_list:t(0,5)",128,0,0,0
	.stabs	"__builtin_va_list:t(0,6)",128,0,0,0
	.stabs	"__va_list_tag:t(0,9)=s24gp_offset:(0,10)=r(0,10);0;4294967295;,0,32;fp_offset:(0,10),32,32;overflow_arg_area:(0,11)=*(0,1),64,64;reg_save_area:(0,11),128,64;;",128,0,0,0
	.stabs	"unsigned int:t(0,10)",128,0,0,0
	.stabn	192,0,0,.LFBB3-.LFBB3
	.stabn	224,0,0,.Lscope3-.LFBB3
.Lscope3:
	.section	.rodata.str1.1
.LC5:
	.string	"kernel warning at %s:%d: "
	.text
	.p2align 4
	.stabs	"_warn:F(0,1)",36,0,0,_warn
	.stabs	"file:P(0,3)",64,0,0,10
	.stabs	"line:P(0,2)",64,0,0,11
	.stabs	"fmt:P(0,3)",64,0,0,6
	.globl	_warn
	.type	_warn, @function
_warn:
	.stabn	68,0,90,.LM56-.LFBB4
.LM56:
.LFBB4:
.LFB3:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rdi, %r10
	movl	%esi, %r11d
	movq	%rdx, %rbp
	subq	$208, %rsp
	.cfi_def_cfa_offset 224
	movq	%rcx, 56(%rsp)
	movq	%r8, 64(%rsp)
	movq	%r9, 72(%rsp)
	testb	%al, %al
	je	.L25
	movaps	%xmm0, 80(%rsp)
	movaps	%xmm1, 96(%rsp)
	movaps	%xmm2, 112(%rsp)
	movaps	%xmm3, 128(%rsp)
	movaps	%xmm4, 144(%rsp)
	movaps	%xmm5, 160(%rsp)
	movaps	%xmm6, 176(%rsp)
	movaps	%xmm7, 192(%rsp)
.L25:
	.stabn	68,0,90,.LM57-.LFBB4
.LM57:
	movq	%fs:40, %rax
	movq	%rax, 24(%rsp)
	xorl	%eax, %eax
	.stabn	68,0,93,.LM58-.LFBB4
.LM58:
	leaq	224(%rsp), %rax
	.stabn	68,0,94,.LM59-.LFBB4
.LM59:
	movq	%r10, %rsi
	movl	%r11d, %edx
	.stabn	68,0,93,.LM60-.LFBB4
.LM60:
	movq	%rax, 8(%rsp)
	leaq	32(%rsp), %rax
	.stabn	68,0,94,.LM61-.LFBB4
.LM61:
	leaq	.LC5(%rip), %rdi
	.stabn	68,0,93,.LM62-.LFBB4
.LM62:
	movq	%rax, 16(%rsp)
	.stabn	68,0,94,.LM63-.LFBB4
.LM63:
	xorl	%eax, %eax
	.stabn	68,0,93,.LM64-.LFBB4
.LM64:
	movl	$24, (%rsp)
	movl	$48, 4(%rsp)
	.stabn	68,0,94,.LM65-.LFBB4
.LM65:
	call	cprintf@PLT
	.stabn	68,0,95,.LM66-.LFBB4
.LM66:
	movq	%rbp, %rdi
	movq	%rsp, %rsi
	call	vcprintf@PLT
	.stabn	68,0,96,.LM67-.LFBB4
.LM67:
	xorl	%eax, %eax
	leaq	.LC4(%rip), %rdi
	call	cprintf@PLT
	.stabn	68,0,98,.LM68-.LFBB4
.LM68:
	movq	24(%rsp), %rax
	subq	%fs:40, %rax
	jne	.L28
	addq	$208, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	ret
.L28:
	.cfi_restore_state
	call	__stack_chk_fail@PLT
	.cfi_endproc
.LFE3:
	.size	_warn, .-_warn
	.stabs	"ap:(0,5)",128,0,0,0
	.stabn	192,0,0,.LFBB4-.LFBB4
	.stabn	224,0,0,.Lscope4-.LFBB4
.Lscope4:
	.globl	panicstr
	.bss
	.align 8
	.type	panicstr, @object
	.size	panicstr, 8
panicstr:
	.zero	8
	.stabs	"panicstr:G(0,3)",32,0,0,0
	.text
	.stabs	"",100,0,0,.Letext0
.Letext0:
	.ident	"GCC: (Ubuntu 11.3.0-1ubuntu1~22.04) 11.3.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	1f - 0f
	.long	4f - 1f
	.long	5
0:
	.string	"GNU"
1:
	.align 8
	.long	0xc0000002
	.long	3f - 2f
2:
	.long	0x3
3:
	.align 8
4:
