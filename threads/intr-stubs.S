#include "threads/loader.h"

/* 주요 인터럽트 진입점.

   내부 또는 외부 인터럽트는 intrNN_stub 루틴 중 하나에서 시작됩니다. 이 루틴은
   `struct intr_frame' 프레임_포인터, error_code 및 vec_no 멤버를 스택에 푸시
   한 다음 여기로 점프합니다.

   나머지 `struct intr_frame' 멤버를 스택에 저장하고 커널이 필요로 하는 대로 일부 
   레지스터를 설정한 다음 실제로 인터럽트를 처리하는 intr_handler()를 호출합니다.
*/
.section .text
.func intr_entry
intr_entry:
	/* Save caller's registers. */
	subq $16,%rsp
	movw %ds,8(%rsp)
	movw %es,0(%rsp)
	subq $120,%rsp
	movq %rax,112(%rsp)
	movq %rbx,104(%rsp)
	movq %rcx,96(%rsp)
	movq %rdx,88(%rsp)
	movq %rbp,80(%rsp)
	movq %rdi,72(%rsp)
	movq %rsi,64(%rsp)
	movq %r8,56(%rsp)
	movq %r9,48(%rsp)
	movq %r10,40(%rsp)
	movq %r11,32(%rsp)
	movq %r12,24(%rsp)
	movq %r13,16(%rsp)
	movq %r14,8(%rsp)
	movq %r15,0(%rsp)
	cld			/* String instructions go upward. */
	movq $SEL_KDSEG, %rax
	movw %ax, %ds
	movw %ax, %es
	movw %ax, %ss
	movw %ax, %fs
	movw %ax, %gs
	movq %rsp,%rdi
	call intr_handler
	movq 0(%rsp), %r15
	movq 8(%rsp), %r14
	movq 16(%rsp), %r13
	movq 24(%rsp), %r12
	movq 32(%rsp), %r11
	movq 40(%rsp), %r10
	movq 48(%rsp), %r9
	movq 56(%rsp), %r8
	movq 64(%rsp), %rsi
	movq 72(%rsp), %rdi
	movq 80(%rsp), %rbp
	movq 88(%rsp), %rdx
	movq 96(%rsp), %rcx
	movq 104(%rsp), %rbx
	movq 112(%rsp), %rax
	addq $120, %rsp
	movw 8(%rsp), %ds
	movw (%rsp), %es
	addq $32, %rsp
	iretq
.endfunc

/* Interrupt stubs.

   이는 `intr00_stub'부터 `intrff_stub'까지 명명된 256개의 코드 조각을 정의하며,
   각 조각은 해당 인터럽트 벡터의 진입점으로 사용됩니다. 또한 함수 포인터 배열인 
   `intr_stubs'의 올바른 위치에 이러한 각 함수의 주소를 넣습니다.

   대부분의 stub은 다음을 수행합니다.

        1. 스택(`struct intr_frame'의 프레임 포인터)에 %ebp를 푸시합니다.

        2. 스택에 0(error_code)을 푸시합니다.

        3. 스택에 인터럽트 번호(vec_no)를 푸시합니다.

   CPU는 몇 번의 인터럽트 동안 스택에 추가 "오류 코드"를 푸시합니다. %ebp가 오류
   코드가 있는 위치에 있기를 원하기 때문에 다른 경로를 따릅니다.

        1. 오류 코드의 복사본을 스택에 푸시합니다.

        2. 오류 코드의 원본을 %ebp로 대체합니다.

        3. 인터럽트 번호를 스택에 푸시합니다. */

/* 이는 0 오류 코드를 푸시하는 일반적인 경우에 위에서 설명한 1단계와 2단계를 구현
   합니다. */
#define zero pushq $0;

/* 이는 CPU가 이미 오류 코드를 푸시한 경우 위에 설명된 1단계와 2단계를 구현합니다. 
*/
#define REAL

.section .data
.globl intr_stubs
intr_stubs:

/* 인터럽트 벡터 NUMBER에 대한 stub을 내보냅니다. TYPE은 0 오류 코드를 푸시하는 경우
   '0'이고, CPU가 오류 코드를 푸시하는 경우 'REAL'입니다. */
#define STUB(NUMBER, TYPE)                      \
.section .text;                                  \
.globl intr##NUMBER##_stub;                     \
.func intr##NUMBER##_stub;			\
intr##NUMBER##_stub:                            \
	TYPE;                                   \
	push $0x##NUMBER;                       \
	jmp intr_entry;                         \
.endfunc; \
.section .data; \
.quad intr##NUMBER##_stub;

/* All the stubs. */
STUB(00, zero) STUB(01, zero) STUB(02, zero) STUB(03, zero)
STUB(04, zero) STUB(05, zero) STUB(06, zero) STUB(07, zero)
STUB(08, REAL) STUB(09, zero) STUB(0a, REAL) STUB(0b, REAL)
STUB(0c, zero) STUB(0d, REAL) STUB(0e, REAL) STUB(0f, zero)

STUB(10, zero) STUB(11, REAL) STUB(12, zero) STUB(13, zero)
STUB(14, zero) STUB(15, zero) STUB(16, zero) STUB(17, zero)
STUB(18, REAL) STUB(19, zero) STUB(1a, REAL) STUB(1b, REAL)
STUB(1c, zero) STUB(1d, REAL) STUB(1e, REAL) STUB(1f, zero)

STUB(20, zero) STUB(21, zero) STUB(22, zero) STUB(23, zero)
STUB(24, zero) STUB(25, zero) STUB(26, zero) STUB(27, zero)
STUB(28, zero) STUB(29, zero) STUB(2a, zero) STUB(2b, zero)
STUB(2c, zero) STUB(2d, zero) STUB(2e, zero) STUB(2f, zero)

STUB(30, zero) STUB(31, zero) STUB(32, zero) STUB(33, zero)
STUB(34, zero) STUB(35, zero) STUB(36, zero) STUB(37, zero)
STUB(38, zero) STUB(39, zero) STUB(3a, zero) STUB(3b, zero)
STUB(3c, zero) STUB(3d, zero) STUB(3e, zero) STUB(3f, zero)

STUB(40, zero) STUB(41, zero) STUB(42, zero) STUB(43, zero)
STUB(44, zero) STUB(45, zero) STUB(46, zero) STUB(47, zero)
STUB(48, zero) STUB(49, zero) STUB(4a, zero) STUB(4b, zero)
STUB(4c, zero) STUB(4d, zero) STUB(4e, zero) STUB(4f, zero)

STUB(50, zero) STUB(51, zero) STUB(52, zero) STUB(53, zero)
STUB(54, zero) STUB(55, zero) STUB(56, zero) STUB(57, zero)
STUB(58, zero) STUB(59, zero) STUB(5a, zero) STUB(5b, zero)
STUB(5c, zero) STUB(5d, zero) STUB(5e, zero) STUB(5f, zero)

STUB(60, zero) STUB(61, zero) STUB(62, zero) STUB(63, zero)
STUB(64, zero) STUB(65, zero) STUB(66, zero) STUB(67, zero)
STUB(68, zero) STUB(69, zero) STUB(6a, zero) STUB(6b, zero)
STUB(6c, zero) STUB(6d, zero) STUB(6e, zero) STUB(6f, zero)

STUB(70, zero) STUB(71, zero) STUB(72, zero) STUB(73, zero)
STUB(74, zero) STUB(75, zero) STUB(76, zero) STUB(77, zero)
STUB(78, zero) STUB(79, zero) STUB(7a, zero) STUB(7b, zero)
STUB(7c, zero) STUB(7d, zero) STUB(7e, zero) STUB(7f, zero)

STUB(80, zero) STUB(81, zero) STUB(82, zero) STUB(83, zero)
STUB(84, zero) STUB(85, zero) STUB(86, zero) STUB(87, zero)
STUB(88, zero) STUB(89, zero) STUB(8a, zero) STUB(8b, zero)
STUB(8c, zero) STUB(8d, zero) STUB(8e, zero) STUB(8f, zero)

STUB(90, zero) STUB(91, zero) STUB(92, zero) STUB(93, zero)
STUB(94, zero) STUB(95, zero) STUB(96, zero) STUB(97, zero)
STUB(98, zero) STUB(99, zero) STUB(9a, zero) STUB(9b, zero)
STUB(9c, zero) STUB(9d, zero) STUB(9e, zero) STUB(9f, zero)

STUB(a0, zero) STUB(a1, zero) STUB(a2, zero) STUB(a3, zero)
STUB(a4, zero) STUB(a5, zero) STUB(a6, zero) STUB(a7, zero)
STUB(a8, zero) STUB(a9, zero) STUB(aa, zero) STUB(ab, zero)
STUB(ac, zero) STUB(ad, zero) STUB(ae, zero) STUB(af, zero)

STUB(b0, zero) STUB(b1, zero) STUB(b2, zero) STUB(b3, zero)
STUB(b4, zero) STUB(b5, zero) STUB(b6, zero) STUB(b7, zero)
STUB(b8, zero) STUB(b9, zero) STUB(ba, zero) STUB(bb, zero)
STUB(bc, zero) STUB(bd, zero) STUB(be, zero) STUB(bf, zero)

STUB(c0, zero) STUB(c1, zero) STUB(c2, zero) STUB(c3, zero)
STUB(c4, zero) STUB(c5, zero) STUB(c6, zero) STUB(c7, zero)
STUB(c8, zero) STUB(c9, zero) STUB(ca, zero) STUB(cb, zero)
STUB(cc, zero) STUB(cd, zero) STUB(ce, zero) STUB(cf, zero)

STUB(d0, zero) STUB(d1, zero) STUB(d2, zero) STUB(d3, zero)
STUB(d4, zero) STUB(d5, zero) STUB(d6, zero) STUB(d7, zero)
STUB(d8, zero) STUB(d9, zero) STUB(da, zero) STUB(db, zero)
STUB(dc, zero) STUB(dd, zero) STUB(de, zero) STUB(df, zero)

STUB(e0, zero) STUB(e1, zero) STUB(e2, zero) STUB(e3, zero)
STUB(e4, zero) STUB(e5, zero) STUB(e6, zero) STUB(e7, zero)
STUB(e8, zero) STUB(e9, zero) STUB(ea, zero) STUB(eb, zero)
STUB(ec, zero) STUB(ed, zero) STUB(ee, zero) STUB(ef, zero)

STUB(f0, zero) STUB(f1, zero) STUB(f2, zero) STUB(f3, zero)
STUB(f4, zero) STUB(f5, zero) STUB(f6, zero) STUB(f7, zero)
STUB(f8, zero) STUB(f9, zero) STUB(fa, zero) STUB(fb, zero)
STUB(fc, zero) STUB(fd, zero) STUB(fe, zero) STUB(ff, zero)
