
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c, 
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096) "load address" stack0's memory address into register"sp" 
        la sp, stack0
    80000000:	00008117          	auipc	sp,0x8
    80000004:	87010113          	addi	sp,sp,-1936 # 80007870 <stack0>
        li a0, 1024*4
    80000008:	6505                	lui	a0,0x1
        csrr a1, mhartid
    8000000a:	f14025f3          	csrr	a1,mhartid
        addi a1, a1, 1
    8000000e:	0585                	addi	a1,a1,1
        mul a0, a0, a1
    80000010:	02b50533          	mul	a0,a0,a1
        add sp, sp, a0
    80000014:	912a                	add	sp,sp,a0
        # jump to start() in start.c
        call start
    80000016:	042000ef          	jal	80000058 <start>

000000008000001a <spin>:
spin:
        j spin
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e406                	sd	ra,8(sp)
    80000020:	e022                	sd	s0,0(sp)
    80000022:	0800                	addi	s0,sp,16
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r"(x));
    80000024:	30a027f3          	csrr	a5,0x30a
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | MENVCFG_STCE);
    80000028:	577d                	li	a4,-1
    8000002a:	177e                	slli	a4,a4,0x3f
    8000002c:	8fd9                	or	a5,a5,a4

static inline void
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r"(x));
    8000002e:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r"(x));
    80000032:	306027f3          	csrr	a5,mcounteren

  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000036:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r"(x));
    8000003a:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r"(x));
    8000003e:	c01027f3          	rdtime	a5

  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    80000042:	000f4737          	lui	a4,0xf4
    80000046:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    8000004a:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
    8000004c:	14d79073          	csrw	stimecmp,a5
}
    80000050:	60a2                	ld	ra,8(sp)
    80000052:	6402                	ld	s0,0(sp)
    80000054:	0141                	addi	sp,sp,16
    80000056:	8082                	ret

0000000080000058 <start>:
{
    80000058:	1141                	addi	sp,sp,-16
    8000005a:	e406                	sd	ra,8(sp)
    8000005c:	e022                	sd	s0,0(sp)
    8000005e:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r"(x));
    80000060:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000064:	7779                	lui	a4,0xffffe
    80000066:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffddc87>
    8000006a:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000006c:	6705                	lui	a4,0x1
    8000006e:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    80000072:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r"(x));
    80000074:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r"(x));
    80000078:	00001797          	auipc	a5,0x1
    8000007c:	e0878793          	addi	a5,a5,-504 # 80000e80 <main>
    80000080:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r"(x));
    80000084:	4781                	li	a5,0
    80000086:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r"(x));
    8000008a:	67c1                	lui	a5,0x10
    8000008c:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    8000008e:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r"(x));
    80000092:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r"(x));
    80000096:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    8000009a:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r"(x));
    8000009e:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r"(x));
    800000a2:	57fd                	li	a5,-1
    800000a4:	83a9                	srli	a5,a5,0xa
    800000a6:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r"(x));
    800000aa:	47bd                	li	a5,15
    800000ac:	3a079073          	csrw	pmpcfg0,a5
  asm volatile("csrr %0, 0x30a" : "=r"(x));
    800000b0:	30a027f3          	csrr	a5,0x30a
  w_menvcfg(r_menvcfg() | MENVCFG_ADUE);
    800000b4:	4705                	li	a4,1
    800000b6:	1776                	slli	a4,a4,0x3d
    800000b8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw 0x30a, %0" : : "r"(x));
    800000ba:	30a79073          	csrw	0x30a,a5
  timerinit();
    800000be:	f5fff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r"(x));
    800000c2:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c6:	2781                	sext.w	a5,a5
}

static inline void
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r"(x));
    800000c8:	823e                	mv	tp,a5
  asm volatile("mret");
    800000ca:	30200073          	mret
}
    800000ce:	60a2                	ld	ra,8(sp)
    800000d0:	6402                	ld	s0,0(sp)
    800000d2:	0141                	addi	sp,sp,16
    800000d4:	8082                	ret

00000000800000d6 <consolewrite>:
// user write() system calls to the console go here.
// uses sleep() and UART interrupts.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d6:	7119                	addi	sp,sp,-128
    800000d8:	fc86                	sd	ra,120(sp)
    800000da:	f8a2                	sd	s0,112(sp)
    800000dc:	f4a6                	sd	s1,104(sp)
    800000de:	0100                	addi	s0,sp,128
  char buf[32]; // move batches from user space to uart.
  int i = 0;

  while (i < n) {
    800000e0:	06c05b63          	blez	a2,80000156 <consolewrite+0x80>
    800000e4:	f0ca                	sd	s2,96(sp)
    800000e6:	ecce                	sd	s3,88(sp)
    800000e8:	e8d2                	sd	s4,80(sp)
    800000ea:	e4d6                	sd	s5,72(sp)
    800000ec:	e0da                	sd	s6,64(sp)
    800000ee:	fc5e                	sd	s7,56(sp)
    800000f0:	f862                	sd	s8,48(sp)
    800000f2:	f466                	sd	s9,40(sp)
    800000f4:	f06a                	sd	s10,32(sp)
    800000f6:	8b2a                	mv	s6,a0
    800000f8:	8bae                	mv	s7,a1
    800000fa:	8a32                	mv	s4,a2
  int i = 0;
    800000fc:	4481                	li	s1,0
    int nn = sizeof(buf);
    if (nn > n - i)
    800000fe:	02000c93          	li	s9,32
    80000102:	02000d13          	li	s10,32
      nn = n - i;
    if (either_copyin(buf, user_src, src + i, nn) == -1)
    80000106:	f8040a93          	addi	s5,s0,-128
    8000010a:	5c7d                	li	s8,-1
    8000010c:	a025                	j	80000134 <consolewrite+0x5e>
    if (nn > n - i)
    8000010e:	0009099b          	sext.w	s3,s2
    if (either_copyin(buf, user_src, src + i, nn) == -1)
    80000112:	86ce                	mv	a3,s3
    80000114:	01748633          	add	a2,s1,s7
    80000118:	85da                	mv	a1,s6
    8000011a:	8556                	mv	a0,s5
    8000011c:	15a020ef          	jal	80002276 <either_copyin>
    80000120:	03850d63          	beq	a0,s8,8000015a <consolewrite+0x84>
      break;
    uartwrite(buf, nn);
    80000124:	85ce                	mv	a1,s3
    80000126:	8556                	mv	a0,s5
    80000128:	7c8000ef          	jal	800008f0 <uartwrite>
    i += nn;
    8000012c:	009904bb          	addw	s1,s2,s1
  while (i < n) {
    80000130:	0144d963          	bge	s1,s4,80000142 <consolewrite+0x6c>
    if (nn > n - i)
    80000134:	409a07bb          	subw	a5,s4,s1
    80000138:	893e                	mv	s2,a5
    8000013a:	fcfcdae3          	bge	s9,a5,8000010e <consolewrite+0x38>
    8000013e:	896a                	mv	s2,s10
    80000140:	b7f9                	j	8000010e <consolewrite+0x38>
    80000142:	7906                	ld	s2,96(sp)
    80000144:	69e6                	ld	s3,88(sp)
    80000146:	6a46                	ld	s4,80(sp)
    80000148:	6aa6                	ld	s5,72(sp)
    8000014a:	6b06                	ld	s6,64(sp)
    8000014c:	7be2                	ld	s7,56(sp)
    8000014e:	7c42                	ld	s8,48(sp)
    80000150:	7ca2                	ld	s9,40(sp)
    80000152:	7d02                	ld	s10,32(sp)
    80000154:	a821                	j	8000016c <consolewrite+0x96>
  int i = 0;
    80000156:	4481                	li	s1,0
    80000158:	a811                	j	8000016c <consolewrite+0x96>
    8000015a:	7906                	ld	s2,96(sp)
    8000015c:	69e6                	ld	s3,88(sp)
    8000015e:	6a46                	ld	s4,80(sp)
    80000160:	6aa6                	ld	s5,72(sp)
    80000162:	6b06                	ld	s6,64(sp)
    80000164:	7be2                	ld	s7,56(sp)
    80000166:	7c42                	ld	s8,48(sp)
    80000168:	7ca2                	ld	s9,40(sp)
    8000016a:	7d02                	ld	s10,32(sp)
  }

  return i;
}
    8000016c:	8526                	mv	a0,s1
    8000016e:	70e6                	ld	ra,120(sp)
    80000170:	7446                	ld	s0,112(sp)
    80000172:	74a6                	ld	s1,104(sp)
    80000174:	6109                	addi	sp,sp,128
    80000176:	8082                	ret

0000000080000178 <consoleread>:
// user_dst indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000178:	711d                	addi	sp,sp,-96
    8000017a:	ec86                	sd	ra,88(sp)
    8000017c:	e8a2                	sd	s0,80(sp)
    8000017e:	e4a6                	sd	s1,72(sp)
    80000180:	e0ca                	sd	s2,64(sp)
    80000182:	fc4e                	sd	s3,56(sp)
    80000184:	f852                	sd	s4,48(sp)
    80000186:	f05a                	sd	s6,32(sp)
    80000188:	ec5e                	sd	s7,24(sp)
    8000018a:	1080                	addi	s0,sp,96
    8000018c:	8b2a                	mv	s6,a0
    8000018e:	8a2e                	mv	s4,a1
    80000190:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000192:	8bb2                	mv	s7,a2
  acquire(&cons.lock);
    80000194:	0000f517          	auipc	a0,0xf
    80000198:	6dc50513          	addi	a0,a0,1756 # 8000f870 <cons>
    8000019c:	27d000ef          	jal	80000c18 <acquire>
  while (n > 0) {
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while (cons.r == cons.w) {
    800001a0:	0000f497          	auipc	s1,0xf
    800001a4:	6d048493          	addi	s1,s1,1744 # 8000f870 <cons>
      if (killed(myproc())) {
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a8:	0000f917          	auipc	s2,0xf
    800001ac:	76090913          	addi	s2,s2,1888 # 8000f908 <cons+0x98>
  while (n > 0) {
    800001b0:	0b305b63          	blez	s3,80000266 <consoleread+0xee>
    while (cons.r == cons.w) {
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	0af71063          	bne	a4,a5,8000025c <consoleread+0xe4>
      if (killed(myproc())) {
    800001c0:	71e010ef          	jal	800018de <myproc>
    800001c4:	749010ef          	jal	8000210c <killed>
    800001c8:	e12d                	bnez	a0,8000022a <consoleread+0xb2>
      sleep(&cons.r, &cons.lock);
    800001ca:	85a6                	mv	a1,s1
    800001cc:	854a                	mv	a0,s2
    800001ce:	503010ef          	jal	80001ed0 <sleep>
    while (cons.r == cons.w) {
    800001d2:	0984a783          	lw	a5,152(s1)
    800001d6:	09c4a703          	lw	a4,156(s1)
    800001da:	fef703e3          	beq	a4,a5,800001c0 <consoleread+0x48>
    800001de:	f456                	sd	s5,40(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001e0:	0000f717          	auipc	a4,0xf
    800001e4:	69070713          	addi	a4,a4,1680 # 8000f870 <cons>
    800001e8:	0017869b          	addiw	a3,a5,1
    800001ec:	08d72c23          	sw	a3,152(a4)
    800001f0:	07f7f693          	andi	a3,a5,127
    800001f4:	9736                	add	a4,a4,a3
    800001f6:	01874703          	lbu	a4,24(a4)
    800001fa:	00070a9b          	sext.w	s5,a4

    if (c == C('D')) { // end-of-file
    800001fe:	4691                	li	a3,4
    80000200:	04da8663          	beq	s5,a3,8000024c <consoleread+0xd4>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    80000204:	fae407a3          	sb	a4,-81(s0)
    if (either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000208:	4685                	li	a3,1
    8000020a:	faf40613          	addi	a2,s0,-81
    8000020e:	85d2                	mv	a1,s4
    80000210:	855a                	mv	a0,s6
    80000212:	01a020ef          	jal	8000222c <either_copyout>
    80000216:	57fd                	li	a5,-1
    80000218:	04f50663          	beq	a0,a5,80000264 <consoleread+0xec>
      break;

    dst++;
    8000021c:	0a05                	addi	s4,s4,1
    --n;
    8000021e:	39fd                	addiw	s3,s3,-1

    if (c == '\n') {
    80000220:	47a9                	li	a5,10
    80000222:	04fa8b63          	beq	s5,a5,80000278 <consoleread+0x100>
    80000226:	7aa2                	ld	s5,40(sp)
    80000228:	b761                	j	800001b0 <consoleread+0x38>
        release(&cons.lock);
    8000022a:	0000f517          	auipc	a0,0xf
    8000022e:	64650513          	addi	a0,a0,1606 # 8000f870 <cons>
    80000232:	26b000ef          	jal	80000c9c <release>
        return -1;
    80000236:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000238:	60e6                	ld	ra,88(sp)
    8000023a:	6446                	ld	s0,80(sp)
    8000023c:	64a6                	ld	s1,72(sp)
    8000023e:	6906                	ld	s2,64(sp)
    80000240:	79e2                	ld	s3,56(sp)
    80000242:	7a42                	ld	s4,48(sp)
    80000244:	7b02                	ld	s6,32(sp)
    80000246:	6be2                	ld	s7,24(sp)
    80000248:	6125                	addi	sp,sp,96
    8000024a:	8082                	ret
      if (n < target) {
    8000024c:	0179fa63          	bgeu	s3,s7,80000260 <consoleread+0xe8>
        cons.r--;
    80000250:	0000f717          	auipc	a4,0xf
    80000254:	6af72c23          	sw	a5,1720(a4) # 8000f908 <cons+0x98>
    80000258:	7aa2                	ld	s5,40(sp)
    8000025a:	a031                	j	80000266 <consoleread+0xee>
    8000025c:	f456                	sd	s5,40(sp)
    8000025e:	b749                	j	800001e0 <consoleread+0x68>
    80000260:	7aa2                	ld	s5,40(sp)
    80000262:	a011                	j	80000266 <consoleread+0xee>
    80000264:	7aa2                	ld	s5,40(sp)
  release(&cons.lock);
    80000266:	0000f517          	auipc	a0,0xf
    8000026a:	60a50513          	addi	a0,a0,1546 # 8000f870 <cons>
    8000026e:	22f000ef          	jal	80000c9c <release>
  return target - n;
    80000272:	413b853b          	subw	a0,s7,s3
    80000276:	b7c9                	j	80000238 <consoleread+0xc0>
    80000278:	7aa2                	ld	s5,40(sp)
    8000027a:	b7f5                	j	80000266 <consoleread+0xee>

000000008000027c <consputc>:
{
    8000027c:	1141                	addi	sp,sp,-16
    8000027e:	e406                	sd	ra,8(sp)
    80000280:	e022                	sd	s0,0(sp)
    80000282:	0800                	addi	s0,sp,16
  if (c == BACKSPACE) {
    80000284:	10000793          	li	a5,256
    80000288:	00f50863          	beq	a0,a5,80000298 <consputc+0x1c>
    uartputc_sync(c);
    8000028c:	6f8000ef          	jal	80000984 <uartputc_sync>
}
    80000290:	60a2                	ld	ra,8(sp)
    80000292:	6402                	ld	s0,0(sp)
    80000294:	0141                	addi	sp,sp,16
    80000296:	8082                	ret
    uartputc_sync('\b');
    80000298:	4521                	li	a0,8
    8000029a:	6ea000ef          	jal	80000984 <uartputc_sync>
    uartputc_sync(' ');
    8000029e:	02000513          	li	a0,32
    800002a2:	6e2000ef          	jal	80000984 <uartputc_sync>
    uartputc_sync('\b');
    800002a6:	4521                	li	a0,8
    800002a8:	6dc000ef          	jal	80000984 <uartputc_sync>
    800002ac:	b7d5                	j	80000290 <consputc+0x14>

00000000800002ae <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002ae:	1101                	addi	sp,sp,-32
    800002b0:	ec06                	sd	ra,24(sp)
    800002b2:	e822                	sd	s0,16(sp)
    800002b4:	e426                	sd	s1,8(sp)
    800002b6:	1000                	addi	s0,sp,32
    800002b8:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002ba:	0000f517          	auipc	a0,0xf
    800002be:	5b650513          	addi	a0,a0,1462 # 8000f870 <cons>
    800002c2:	157000ef          	jal	80000c18 <acquire>

  switch (c) {
    800002c6:	47d5                	li	a5,21
    800002c8:	0af48163          	beq	s1,a5,8000036a <consoleintr+0xbc>
    800002cc:	0297c563          	blt	a5,s1,800002f6 <consoleintr+0x48>
    800002d0:	47a1                	li	a5,8
    800002d2:	0ef48663          	beq	s1,a5,800003be <consoleintr+0x110>
    800002d6:	47c1                	li	a5,16
    800002d8:	10f49763          	bne	s1,a5,800003e6 <consoleintr+0x138>
  case C('P'): // Print process list.
    procdump();
    800002dc:	7e5010ef          	jal	800022c0 <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    800002e0:	0000f517          	auipc	a0,0xf
    800002e4:	59050513          	addi	a0,a0,1424 # 8000f870 <cons>
    800002e8:	1b5000ef          	jal	80000c9c <release>
}
    800002ec:	60e2                	ld	ra,24(sp)
    800002ee:	6442                	ld	s0,16(sp)
    800002f0:	64a2                	ld	s1,8(sp)
    800002f2:	6105                	addi	sp,sp,32
    800002f4:	8082                	ret
  switch (c) {
    800002f6:	07f00793          	li	a5,127
    800002fa:	0cf48263          	beq	s1,a5,800003be <consoleintr+0x110>
    if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE) {
    800002fe:	0000f717          	auipc	a4,0xf
    80000302:	57270713          	addi	a4,a4,1394 # 8000f870 <cons>
    80000306:	0a072783          	lw	a5,160(a4)
    8000030a:	09872703          	lw	a4,152(a4)
    8000030e:	9f99                	subw	a5,a5,a4
    80000310:	07f00713          	li	a4,127
    80000314:	fcf766e3          	bltu	a4,a5,800002e0 <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    80000318:	47b5                	li	a5,13
    8000031a:	0cf48963          	beq	s1,a5,800003ec <consoleintr+0x13e>
      consputc(c);
    8000031e:	8526                	mv	a0,s1
    80000320:	f5dff0ef          	jal	8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000324:	0000f717          	auipc	a4,0xf
    80000328:	54c70713          	addi	a4,a4,1356 # 8000f870 <cons>
    8000032c:	0a072683          	lw	a3,160(a4)
    80000330:	0016879b          	addiw	a5,a3,1
    80000334:	863e                	mv	a2,a5
    80000336:	0af72023          	sw	a5,160(a4)
    8000033a:	07f6f693          	andi	a3,a3,127
    8000033e:	9736                	add	a4,a4,a3
    80000340:	00970c23          	sb	s1,24(a4)
      if (c == '\n' || c == C('D') || cons.e - cons.r == INPUT_BUF_SIZE) {
    80000344:	ff648713          	addi	a4,s1,-10
    80000348:	00173713          	seqz	a4,a4
    8000034c:	14f1                	addi	s1,s1,-4
    8000034e:	0014b493          	seqz	s1,s1
    80000352:	8f45                	or	a4,a4,s1
    80000354:	e361                	bnez	a4,80000414 <consoleintr+0x166>
    80000356:	0000f717          	auipc	a4,0xf
    8000035a:	5b272703          	lw	a4,1458(a4) # 8000f908 <cons+0x98>
    8000035e:	9f99                	subw	a5,a5,a4
    80000360:	08000713          	li	a4,128
    80000364:	f6e79ee3          	bne	a5,a4,800002e0 <consoleintr+0x32>
    80000368:	a075                	j	80000414 <consoleintr+0x166>
    8000036a:	e04a                	sd	s2,0(sp)
    while (cons.e != cons.w &&
    8000036c:	0000f717          	auipc	a4,0xf
    80000370:	50470713          	addi	a4,a4,1284 # 8000f870 <cons>
    80000374:	0a072783          	lw	a5,160(a4)
    80000378:	09c72703          	lw	a4,156(a4)
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n') {
    8000037c:	0000f497          	auipc	s1,0xf
    80000380:	4f448493          	addi	s1,s1,1268 # 8000f870 <cons>
    while (cons.e != cons.w &&
    80000384:	4929                	li	s2,10
    80000386:	02f70863          	beq	a4,a5,800003b6 <consoleintr+0x108>
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n') {
    8000038a:	37fd                	addiw	a5,a5,-1
    8000038c:	07f7f713          	andi	a4,a5,127
    80000390:	9726                	add	a4,a4,s1
    while (cons.e != cons.w &&
    80000392:	01874703          	lbu	a4,24(a4)
    80000396:	03270263          	beq	a4,s2,800003ba <consoleintr+0x10c>
      cons.e--;
    8000039a:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    8000039e:	10000513          	li	a0,256
    800003a2:	edbff0ef          	jal	8000027c <consputc>
    while (cons.e != cons.w &&
    800003a6:	0a04a783          	lw	a5,160(s1)
    800003aa:	09c4a703          	lw	a4,156(s1)
    800003ae:	fcf71ee3          	bne	a4,a5,8000038a <consoleintr+0xdc>
    800003b2:	6902                	ld	s2,0(sp)
    800003b4:	b735                	j	800002e0 <consoleintr+0x32>
    800003b6:	6902                	ld	s2,0(sp)
    800003b8:	b725                	j	800002e0 <consoleintr+0x32>
    800003ba:	6902                	ld	s2,0(sp)
    800003bc:	b715                	j	800002e0 <consoleintr+0x32>
    if (cons.e != cons.w) {
    800003be:	0000f717          	auipc	a4,0xf
    800003c2:	4b270713          	addi	a4,a4,1202 # 8000f870 <cons>
    800003c6:	0a072783          	lw	a5,160(a4)
    800003ca:	09c72703          	lw	a4,156(a4)
    800003ce:	f0f709e3          	beq	a4,a5,800002e0 <consoleintr+0x32>
      cons.e--;
    800003d2:	37fd                	addiw	a5,a5,-1
    800003d4:	0000f717          	auipc	a4,0xf
    800003d8:	52f72e23          	sw	a5,1340(a4) # 8000f910 <cons+0xa0>
      consputc(BACKSPACE);
    800003dc:	10000513          	li	a0,256
    800003e0:	e9dff0ef          	jal	8000027c <consputc>
    800003e4:	bdf5                	j	800002e0 <consoleintr+0x32>
    if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE) {
    800003e6:	ee048de3          	beqz	s1,800002e0 <consoleintr+0x32>
    800003ea:	bf11                	j	800002fe <consoleintr+0x50>
      consputc(c);
    800003ec:	4529                	li	a0,10
    800003ee:	e8fff0ef          	jal	8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003f2:	0000f797          	auipc	a5,0xf
    800003f6:	47e78793          	addi	a5,a5,1150 # 8000f870 <cons>
    800003fa:	0a07a703          	lw	a4,160(a5)
    800003fe:	0017069b          	addiw	a3,a4,1
    80000402:	8636                	mv	a2,a3
    80000404:	0ad7a023          	sw	a3,160(a5)
    80000408:	07f77713          	andi	a4,a4,127
    8000040c:	97ba                	add	a5,a5,a4
    8000040e:	4729                	li	a4,10
    80000410:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000414:	0000f797          	auipc	a5,0xf
    80000418:	4ec7ac23          	sw	a2,1272(a5) # 8000f90c <cons+0x9c>
        wakeup(&cons.r);
    8000041c:	0000f517          	auipc	a0,0xf
    80000420:	4ec50513          	addi	a0,a0,1260 # 8000f908 <cons+0x98>
    80000424:	2f9010ef          	jal	80001f1c <wakeup>
    80000428:	bd65                	j	800002e0 <consoleintr+0x32>

000000008000042a <consoleinit>:

void
consoleinit(void)
{
    8000042a:	1141                	addi	sp,sp,-16
    8000042c:	e406                	sd	ra,8(sp)
    8000042e:	e022                	sd	s0,0(sp)
    80000430:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000432:	00007597          	auipc	a1,0x7
    80000436:	bce58593          	addi	a1,a1,-1074 # 80007000 <etext>
    8000043a:	0000f517          	auipc	a0,0xf
    8000043e:	43650513          	addi	a0,a0,1078 # 8000f870 <cons>
    80000442:	756000ef          	jal	80000b98 <initlock>

  uartinit();
    80000446:	454000ef          	jal	8000089a <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000044a:	0001f797          	auipc	a5,0x1f
    8000044e:	59678793          	addi	a5,a5,1430 # 8001f9e0 <devsw>
    80000452:	00000717          	auipc	a4,0x0
    80000456:	d2670713          	addi	a4,a4,-730 # 80000178 <consoleread>
    8000045a:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000045c:	00000717          	auipc	a4,0x0
    80000460:	c7a70713          	addi	a4,a4,-902 # 800000d6 <consolewrite>
    80000464:	ef98                	sd	a4,24(a5)
}
    80000466:	60a2                	ld	ra,8(sp)
    80000468:	6402                	ld	s0,0(sp)
    8000046a:	0141                	addi	sp,sp,16
    8000046c:	8082                	ret

000000008000046e <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    8000046e:	7139                	addi	sp,sp,-64
    80000470:	fc06                	sd	ra,56(sp)
    80000472:	f822                	sd	s0,48(sp)
    80000474:	f04a                	sd	s2,32(sp)
    80000476:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if (sign && (sign = (xx < 0)))
    80000478:	c219                	beqz	a2,8000047e <printint+0x10>
    8000047a:	08054063          	bltz	a0,800004fa <printint+0x8c>
    x = -xx;
  else
    x = xx;
    8000047e:	4301                	li	t1,0

  i = 0;
    80000480:	fc840913          	addi	s2,s0,-56
    x = xx;
    80000484:	86ca                	mv	a3,s2
  i = 0;
    80000486:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    80000488:	00007817          	auipc	a6,0x7
    8000048c:	28880813          	addi	a6,a6,648 # 80007710 <digits>
    80000490:	88ba                	mv	a7,a4
    80000492:	0017061b          	addiw	a2,a4,1
    80000496:	8732                	mv	a4,a2
    80000498:	02b577b3          	remu	a5,a0,a1
    8000049c:	97c2                	add	a5,a5,a6
    8000049e:	0007c783          	lbu	a5,0(a5)
    800004a2:	00f68023          	sb	a5,0(a3)
  } while ((x /= base) != 0);
    800004a6:	87aa                	mv	a5,a0
    800004a8:	02b55533          	divu	a0,a0,a1
    800004ac:	0685                	addi	a3,a3,1
    800004ae:	feb7f1e3          	bgeu	a5,a1,80000490 <printint+0x22>

  if (sign)
    800004b2:	00030b63          	beqz	t1,800004c8 <printint+0x5a>
    buf[i++] = '-';
    800004b6:	fe040793          	addi	a5,s0,-32
    800004ba:	963e                	add	a2,a2,a5
    800004bc:	02d00793          	li	a5,45
    800004c0:	fef60423          	sb	a5,-24(a2)
    800004c4:	0028871b          	addiw	a4,a7,2

  while (--i >= 0)
    800004c8:	02e05463          	blez	a4,800004f0 <printint+0x82>
    800004cc:	f426                	sd	s1,40(sp)
    800004ce:	377d                	addiw	a4,a4,-1
    800004d0:	00e904b3          	add	s1,s2,a4
    800004d4:	197d                	addi	s2,s2,-1
    800004d6:	993a                	add	s2,s2,a4
    800004d8:	1702                	slli	a4,a4,0x20
    800004da:	9301                	srli	a4,a4,0x20
    800004dc:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    800004e0:	0004c503          	lbu	a0,0(s1)
    800004e4:	d99ff0ef          	jal	8000027c <consputc>
  while (--i >= 0)
    800004e8:	14fd                	addi	s1,s1,-1
    800004ea:	ff249be3          	bne	s1,s2,800004e0 <printint+0x72>
    800004ee:	74a2                	ld	s1,40(sp)
}
    800004f0:	70e2                	ld	ra,56(sp)
    800004f2:	7442                	ld	s0,48(sp)
    800004f4:	7902                	ld	s2,32(sp)
    800004f6:	6121                	addi	sp,sp,64
    800004f8:	8082                	ret
    x = -xx;
    800004fa:	40a00533          	neg	a0,a0
  if (sign && (sign = (xx < 0)))
    800004fe:	4305                	li	t1,1
    x = -xx;
    80000500:	b741                	j	80000480 <printint+0x12>

0000000080000502 <printk>:
}

// Print to the console.
int
printk(char *fmt, ...)
{
    80000502:	7131                	addi	sp,sp,-192
    80000504:	fc86                	sd	ra,120(sp)
    80000506:	f8a2                	sd	s0,112(sp)
    80000508:	f4a6                	sd	s1,104(sp)
    8000050a:	0100                	addi	s0,sp,128
    8000050c:	84aa                	mv	s1,a0
    8000050e:	e40c                	sd	a1,8(s0)
    80000510:	e810                	sd	a2,16(s0)
    80000512:	ec14                	sd	a3,24(s0)
    80000514:	f018                	sd	a4,32(s0)
    80000516:	f41c                	sd	a5,40(s0)
    80000518:	03043823          	sd	a6,48(s0)
    8000051c:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if (panicking == 0)
    80000520:	00007797          	auipc	a5,0x7
    80000524:	3247a783          	lw	a5,804(a5) # 80007844 <panicking>
    80000528:	cf9d                	beqz	a5,80000566 <printk+0x64>
    acquire(&pr.lock);

  va_start(ap, fmt);
    8000052a:	00840793          	addi	a5,s0,8
    8000052e:	f8f43423          	sd	a5,-120(s0)
  for (i = 0; (cx = fmt[i] & 0xff) != 0; i++) {
    80000532:	0004c503          	lbu	a0,0(s1)
    80000536:	22050363          	beqz	a0,8000075c <printk+0x25a>
    8000053a:	f0ca                	sd	s2,96(sp)
    8000053c:	ecce                	sd	s3,88(sp)
    8000053e:	e8d2                	sd	s4,80(sp)
    80000540:	e4d6                	sd	s5,72(sp)
    80000542:	e0da                	sd	s6,64(sp)
    80000544:	fc5e                	sd	s7,56(sp)
    80000546:	f862                	sd	s8,48(sp)
    80000548:	f06a                	sd	s10,32(sp)
    8000054a:	ec6e                	sd	s11,24(sp)
    8000054c:	4a01                	li	s4,0
    if (cx != '%') {
    8000054e:	02500993          	li	s3,37
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if (c0 == 'u') {
    80000552:	07500c13          	li	s8,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if (c0 == 'x') {
    80000556:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if (c0 == 'p') {
    8000055a:	07000d93          	li	s11,112
      printint(va_arg(ap, uint64), 10, 0);
    8000055e:	4b29                	li	s6,10
    if (c0 == 'd') {
    80000560:	06400b93          	li	s7,100
    80000564:	a015                	j	80000588 <printk+0x86>
    acquire(&pr.lock);
    80000566:	0000f517          	auipc	a0,0xf
    8000056a:	3b250513          	addi	a0,a0,946 # 8000f918 <pr>
    8000056e:	6aa000ef          	jal	80000c18 <acquire>
    80000572:	bf65                	j	8000052a <printk+0x28>
      consputc(cx);
    80000574:	d09ff0ef          	jal	8000027c <consputc>
  for (i = 0; (cx = fmt[i] & 0xff) != 0; i++) {
    80000578:	001a079b          	addiw	a5,s4,1
    8000057c:	8a3e                	mv	s4,a5
    8000057e:	97a6                	add	a5,a5,s1
    80000580:	0007c503          	lbu	a0,0(a5)
    80000584:	1c050363          	beqz	a0,8000074a <printk+0x248>
    if (cx != '%') {
    80000588:	ff3516e3          	bne	a0,s3,80000574 <printk+0x72>
    i++;
    8000058c:	001a091b          	addiw	s2,s4,1
    c0 = fmt[i + 0] & 0xff;
    80000590:	012487b3          	add	a5,s1,s2
    80000594:	0007ca83          	lbu	s5,0(a5)
    if (c0)
    80000598:	200a8763          	beqz	s5,800007a6 <printk+0x2a4>
      c1 = fmt[i + 1] & 0xff;
    8000059c:	0017c703          	lbu	a4,1(a5)
    if (c1)
    800005a0:	1e070a63          	beqz	a4,80000794 <printk+0x292>
    if (c0 == 'd') {
    800005a4:	037a8963          	beq	s5,s7,800005d6 <printk+0xd4>
    } else if (c0 == 'l' && c1 == 'd') {
    800005a8:	f94a8793          	addi	a5,s5,-108
    800005ac:	0017b793          	seqz	a5,a5
    800005b0:	f9c70693          	addi	a3,a4,-100
    800005b4:	0016b693          	seqz	a3,a3
    800005b8:	8efd                	and	a3,a3,a5
    800005ba:	ca9d                	beqz	a3,800005f0 <printk+0xee>
      printint(va_arg(ap, uint64), 10, 1);
    800005bc:	f8843783          	ld	a5,-120(s0)
    800005c0:	00878713          	addi	a4,a5,8
    800005c4:	f8e43423          	sd	a4,-120(s0)
    800005c8:	4605                	li	a2,1
    800005ca:	85da                	mv	a1,s6
    800005cc:	6388                	ld	a0,0(a5)
    800005ce:	ea1ff0ef          	jal	8000046e <printint>
      i += 1;
    800005d2:	2a09                	addiw	s4,s4,2
    800005d4:	b755                	j	80000578 <printk+0x76>
      printint(va_arg(ap, int), 10, 1);
    800005d6:	f8843783          	ld	a5,-120(s0)
    800005da:	00878713          	addi	a4,a5,8
    800005de:	f8e43423          	sd	a4,-120(s0)
    800005e2:	4605                	li	a2,1
    800005e4:	85da                	mv	a1,s6
    800005e6:	4388                	lw	a0,0(a5)
    800005e8:	e87ff0ef          	jal	8000046e <printint>
    i++;
    800005ec:	8a4a                	mv	s4,s2
    800005ee:	b769                	j	80000578 <printk+0x76>
      c2 = fmt[i + 2] & 0xff;
    800005f0:	012486b3          	add	a3,s1,s2
    800005f4:	863a                	mv	a2,a4
    800005f6:	0026c703          	lbu	a4,2(a3)
    800005fa:	aa65                	j	800007b2 <printk+0x2b0>
      printint(va_arg(ap, uint64), 10, 1);
    800005fc:	f8843783          	ld	a5,-120(s0)
    80000600:	00878713          	addi	a4,a5,8
    80000604:	f8e43423          	sd	a4,-120(s0)
    80000608:	4605                	li	a2,1
    8000060a:	45a9                	li	a1,10
    8000060c:	6388                	ld	a0,0(a5)
    8000060e:	e61ff0ef          	jal	8000046e <printint>
      i += 2;
    80000612:	2a0d                	addiw	s4,s4,3
    80000614:	b795                	j	80000578 <printk+0x76>
      printint(va_arg(ap, uint32), 10, 0);
    80000616:	f8843783          	ld	a5,-120(s0)
    8000061a:	00878713          	addi	a4,a5,8
    8000061e:	f8e43423          	sd	a4,-120(s0)
    80000622:	4601                	li	a2,0
    80000624:	85da                	mv	a1,s6
    80000626:	0007e503          	lwu	a0,0(a5)
    8000062a:	e45ff0ef          	jal	8000046e <printint>
    8000062e:	bf7d                	j	800005ec <printk+0xea>
      printint(va_arg(ap, uint64), 10, 0);
    80000630:	f8843783          	ld	a5,-120(s0)
    80000634:	00878713          	addi	a4,a5,8
    80000638:	f8e43423          	sd	a4,-120(s0)
    8000063c:	4601                	li	a2,0
    8000063e:	85da                	mv	a1,s6
    80000640:	6388                	ld	a0,0(a5)
    80000642:	e2dff0ef          	jal	8000046e <printint>
      i += 1;
    80000646:	2a09                	addiw	s4,s4,2
    80000648:	bf05                	j	80000578 <printk+0x76>
      printint(va_arg(ap, uint64), 10, 0);
    8000064a:	f8843783          	ld	a5,-120(s0)
    8000064e:	00878713          	addi	a4,a5,8
    80000652:	f8e43423          	sd	a4,-120(s0)
    80000656:	4601                	li	a2,0
    80000658:	45a9                	li	a1,10
    8000065a:	6388                	ld	a0,0(a5)
    8000065c:	e13ff0ef          	jal	8000046e <printint>
      i += 2;
    80000660:	2a0d                	addiw	s4,s4,3
    80000662:	bf19                	j	80000578 <printk+0x76>
      printint(va_arg(ap, uint32), 16, 0);
    80000664:	f8843783          	ld	a5,-120(s0)
    80000668:	00878713          	addi	a4,a5,8
    8000066c:	f8e43423          	sd	a4,-120(s0)
    80000670:	4601                	li	a2,0
    80000672:	45c1                	li	a1,16
    80000674:	0007e503          	lwu	a0,0(a5)
    80000678:	df7ff0ef          	jal	8000046e <printint>
    8000067c:	bf85                	j	800005ec <printk+0xea>
      printint(va_arg(ap, uint64), 16, 0);
    8000067e:	f8843783          	ld	a5,-120(s0)
    80000682:	00878713          	addi	a4,a5,8
    80000686:	f8e43423          	sd	a4,-120(s0)
    8000068a:	4601                	li	a2,0
    8000068c:	45c1                	li	a1,16
    8000068e:	6388                	ld	a0,0(a5)
    80000690:	ddfff0ef          	jal	8000046e <printint>
      i += 1;
    80000694:	2a09                	addiw	s4,s4,2
    80000696:	b5cd                	j	80000578 <printk+0x76>
      printint(va_arg(ap, uint64), 16, 0);
    80000698:	f8843783          	ld	a5,-120(s0)
    8000069c:	00878713          	addi	a4,a5,8
    800006a0:	f8e43423          	sd	a4,-120(s0)
    800006a4:	45c1                	li	a1,16
    800006a6:	6388                	ld	a0,0(a5)
    800006a8:	dc7ff0ef          	jal	8000046e <printint>
      i += 2;
    800006ac:	2a0d                	addiw	s4,s4,3
    800006ae:	b5e9                	j	80000578 <printk+0x76>
    800006b0:	f466                	sd	s9,40(sp)
      printptr(va_arg(ap, uint64));
    800006b2:	f8843783          	ld	a5,-120(s0)
    800006b6:	00878713          	addi	a4,a5,8
    800006ba:	f8e43423          	sd	a4,-120(s0)
    800006be:	0007ba83          	ld	s5,0(a5)
  consputc('0');
    800006c2:	03000513          	li	a0,48
    800006c6:	bb7ff0ef          	jal	8000027c <consputc>
  consputc('x');
    800006ca:	07800513          	li	a0,120
    800006ce:	bafff0ef          	jal	8000027c <consputc>
    800006d2:	4a41                	li	s4,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006d4:	00007c97          	auipc	s9,0x7
    800006d8:	03cc8c93          	addi	s9,s9,60 # 80007710 <digits>
    800006dc:	03cad793          	srli	a5,s5,0x3c
    800006e0:	97e6                	add	a5,a5,s9
    800006e2:	0007c503          	lbu	a0,0(a5)
    800006e6:	b97ff0ef          	jal	8000027c <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006ea:	0a92                	slli	s5,s5,0x4
    800006ec:	3a7d                	addiw	s4,s4,-1
    800006ee:	fe0a17e3          	bnez	s4,800006dc <printk+0x1da>
    800006f2:	7ca2                	ld	s9,40(sp)
    800006f4:	bde5                	j	800005ec <printk+0xea>
    } else if (c0 == 'c') {
      consputc(va_arg(ap, uint));
    800006f6:	f8843783          	ld	a5,-120(s0)
    800006fa:	00878713          	addi	a4,a5,8
    800006fe:	f8e43423          	sd	a4,-120(s0)
    80000702:	4388                	lw	a0,0(a5)
    80000704:	b79ff0ef          	jal	8000027c <consputc>
    80000708:	b5d5                	j	800005ec <printk+0xea>
    } else if (c0 == 's') {
      if ((s = va_arg(ap, char *)) == 0)
    8000070a:	f8843783          	ld	a5,-120(s0)
    8000070e:	00878713          	addi	a4,a5,8
    80000712:	f8e43423          	sd	a4,-120(s0)
    80000716:	0007ba03          	ld	s4,0(a5)
    8000071a:	000a0d63          	beqz	s4,80000734 <printk+0x232>
        s = "(null)";
      for (; *s; s++)
    8000071e:	000a4503          	lbu	a0,0(s4)
    80000722:	ec0505e3          	beqz	a0,800005ec <printk+0xea>
        consputc(*s);
    80000726:	b57ff0ef          	jal	8000027c <consputc>
      for (; *s; s++)
    8000072a:	0a05                	addi	s4,s4,1
    8000072c:	000a4503          	lbu	a0,0(s4)
    80000730:	f97d                	bnez	a0,80000726 <printk+0x224>
    80000732:	bd6d                	j	800005ec <printk+0xea>
        s = "(null)";
    80000734:	00007a17          	auipc	s4,0x7
    80000738:	8d4a0a13          	addi	s4,s4,-1836 # 80007008 <etext+0x8>
      for (; *s; s++)
    8000073c:	02800513          	li	a0,40
    80000740:	b7dd                	j	80000726 <printk+0x224>
    } else if (c0 == '%') {
      consputc('%');
    80000742:	8556                	mv	a0,s5
    80000744:	b39ff0ef          	jal	8000027c <consputc>
    80000748:	b555                	j	800005ec <printk+0xea>
    8000074a:	7906                	ld	s2,96(sp)
    8000074c:	69e6                	ld	s3,88(sp)
    8000074e:	6a46                	ld	s4,80(sp)
    80000750:	6aa6                	ld	s5,72(sp)
    80000752:	6b06                	ld	s6,64(sp)
    80000754:	7be2                	ld	s7,56(sp)
    80000756:	7c42                	ld	s8,48(sp)
    80000758:	7d02                	ld	s10,32(sp)
    8000075a:	6de2                	ld	s11,24(sp)
      consputc(c0);
    }
  }
  va_end(ap);

  if (panicking == 0)
    8000075c:	00007797          	auipc	a5,0x7
    80000760:	0e87a783          	lw	a5,232(a5) # 80007844 <panicking>
    80000764:	c38d                	beqz	a5,80000786 <printk+0x284>
    release(&pr.lock);

  return 0;
}
    80000766:	4501                	li	a0,0
    80000768:	70e6                	ld	ra,120(sp)
    8000076a:	7446                	ld	s0,112(sp)
    8000076c:	74a6                	ld	s1,104(sp)
    8000076e:	6129                	addi	sp,sp,192
    80000770:	8082                	ret
    80000772:	7906                	ld	s2,96(sp)
    80000774:	69e6                	ld	s3,88(sp)
    80000776:	6a46                	ld	s4,80(sp)
    80000778:	6aa6                	ld	s5,72(sp)
    8000077a:	6b06                	ld	s6,64(sp)
    8000077c:	7be2                	ld	s7,56(sp)
    8000077e:	7c42                	ld	s8,48(sp)
    80000780:	7d02                	ld	s10,32(sp)
    80000782:	6de2                	ld	s11,24(sp)
    80000784:	bfe1                	j	8000075c <printk+0x25a>
    release(&pr.lock);
    80000786:	0000f517          	auipc	a0,0xf
    8000078a:	19250513          	addi	a0,a0,402 # 8000f918 <pr>
    8000078e:	50e000ef          	jal	80000c9c <release>
  return 0;
    80000792:	bfd1                	j	80000766 <printk+0x264>
    if (c0 == 'd') {
    80000794:	e57a81e3          	beq	s5,s7,800005d6 <printk+0xd4>
    } else if (c0 == 'l' && c1 == 'd') {
    80000798:	f94a8793          	addi	a5,s5,-108
    8000079c:	0017b793          	seqz	a5,a5
    800007a0:	863a                	mv	a2,a4
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
    800007a2:	4681                	li	a3,0
    800007a4:	a01d                	j	800007ca <printk+0x2c8>
    } else if (c0 == 'l' && c1 == 'd') {
    800007a6:	f94a8793          	addi	a5,s5,-108
    800007aa:	0017b793          	seqz	a5,a5
    c1 = c2 = 0;
    800007ae:	8656                	mv	a2,s5
    800007b0:	8756                	mv	a4,s5
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
    800007b2:	f9460693          	addi	a3,a2,-108
    800007b6:	0016b693          	seqz	a3,a3
    800007ba:	8efd                	and	a3,a3,a5
    800007bc:	f9c70593          	addi	a1,a4,-100
    800007c0:	0015b593          	seqz	a1,a1
    800007c4:	8df5                	and	a1,a1,a3
    800007c6:	e2059be3          	bnez	a1,800005fc <printk+0xfa>
    } else if (c0 == 'u') {
    800007ca:	e58a86e3          	beq	s5,s8,80000616 <printk+0x114>
    } else if (c0 == 'l' && c1 == 'u') {
    800007ce:	f8b60593          	addi	a1,a2,-117
    800007d2:	0015b593          	seqz	a1,a1
    800007d6:	8dfd                	and	a1,a1,a5
    800007d8:	e4059ce3          	bnez	a1,80000630 <printk+0x12e>
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
    800007dc:	f8b70593          	addi	a1,a4,-117
    800007e0:	0015b593          	seqz	a1,a1
    800007e4:	8df5                	and	a1,a1,a3
    800007e6:	e60592e3          	bnez	a1,8000064a <printk+0x148>
    } else if (c0 == 'x') {
    800007ea:	e7aa8de3          	beq	s5,s10,80000664 <printk+0x162>
    } else if (c0 == 'l' && c1 == 'x') {
    800007ee:	f8860613          	addi	a2,a2,-120
    800007f2:	00163613          	seqz	a2,a2
    800007f6:	8e7d                	and	a2,a2,a5
    800007f8:	e80613e3          	bnez	a2,8000067e <printk+0x17c>
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
    800007fc:	f8870713          	addi	a4,a4,-120
    80000800:	00173713          	seqz	a4,a4
    80000804:	8f75                	and	a4,a4,a3
    80000806:	e80719e3          	bnez	a4,80000698 <printk+0x196>
    } else if (c0 == 'p') {
    8000080a:	ebba83e3          	beq	s5,s11,800006b0 <printk+0x1ae>
    } else if (c0 == 'c') {
    8000080e:	06300793          	li	a5,99
    80000812:	eefa82e3          	beq	s5,a5,800006f6 <printk+0x1f4>
    } else if (c0 == 's') {
    80000816:	07300793          	li	a5,115
    8000081a:	eefa88e3          	beq	s5,a5,8000070a <printk+0x208>
    } else if (c0 == '%') {
    8000081e:	02500793          	li	a5,37
    80000822:	f2fa80e3          	beq	s5,a5,80000742 <printk+0x240>
    } else if (c0 == 0) {
    80000826:	f40a86e3          	beqz	s5,80000772 <printk+0x270>
      consputc('%');
    8000082a:	02500513          	li	a0,37
    8000082e:	a4fff0ef          	jal	8000027c <consputc>
      consputc(c0);
    80000832:	8556                	mv	a0,s5
    80000834:	a49ff0ef          	jal	8000027c <consputc>
    80000838:	bb55                	j	800005ec <printk+0xea>

000000008000083a <panic>:

void
panic(char *s)
{
    8000083a:	1101                	addi	sp,sp,-32
    8000083c:	ec06                	sd	ra,24(sp)
    8000083e:	e822                	sd	s0,16(sp)
    80000840:	e426                	sd	s1,8(sp)
    80000842:	e04a                	sd	s2,0(sp)
    80000844:	1000                	addi	s0,sp,32
    80000846:	892a                	mv	s2,a0
  panicking = 1;
    80000848:	4485                	li	s1,1
    8000084a:	00007797          	auipc	a5,0x7
    8000084e:	fe97ad23          	sw	s1,-6(a5) # 80007844 <panicking>
  printk("panic: ");
    80000852:	00006517          	auipc	a0,0x6
    80000856:	7c650513          	addi	a0,a0,1990 # 80007018 <etext+0x18>
    8000085a:	ca9ff0ef          	jal	80000502 <printk>
  printk("%s\n", s);
    8000085e:	85ca                	mv	a1,s2
    80000860:	00006517          	auipc	a0,0x6
    80000864:	7c050513          	addi	a0,a0,1984 # 80007020 <etext+0x20>
    80000868:	c9bff0ef          	jal	80000502 <printk>
  panicked = 1; // freeze uart output from other CPUs
    8000086c:	00007797          	auipc	a5,0x7
    80000870:	fc97aa23          	sw	s1,-44(a5) # 80007840 <panicked>
  for (;;)
    80000874:	a001                	j	80000874 <panic+0x3a>

0000000080000876 <printkinit>:
    ;
}

void
printkinit(void)
{
    80000876:	1141                	addi	sp,sp,-16
    80000878:	e406                	sd	ra,8(sp)
    8000087a:	e022                	sd	s0,0(sp)
    8000087c:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    8000087e:	00006597          	auipc	a1,0x6
    80000882:	7aa58593          	addi	a1,a1,1962 # 80007028 <etext+0x28>
    80000886:	0000f517          	auipc	a0,0xf
    8000088a:	09250513          	addi	a0,a0,146 # 8000f918 <pr>
    8000088e:	30a000ef          	jal	80000b98 <initlock>
}
    80000892:	60a2                	ld	ra,8(sp)
    80000894:	6402                	ld	s0,0(sp)
    80000896:	0141                	addi	sp,sp,16
    80000898:	8082                	ret

000000008000089a <uartinit>:
extern volatile int panicking; // from printk.c
extern volatile int panicked;  // from printk.c

void
uartinit(void)
{
    8000089a:	1141                	addi	sp,sp,-16
    8000089c:	e406                	sd	ra,8(sp)
    8000089e:	e022                	sd	s0,0(sp)
    800008a0:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800008a2:	100007b7          	lui	a5,0x10000
    800008a6:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800008aa:	10000737          	lui	a4,0x10000
    800008ae:	f8000693          	li	a3,-128
    800008b2:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800008b6:	468d                	li	a3,3
    800008b8:	10000637          	lui	a2,0x10000
    800008bc:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800008c0:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800008c4:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800008c8:	8732                	mv	a4,a2
    800008ca:	461d                	li	a2,7
    800008cc:	00c70123          	sb	a2,2(a4)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800008d0:	00d780a3          	sb	a3,1(a5)

  initlock(&tx_lock, "uart");
    800008d4:	00006597          	auipc	a1,0x6
    800008d8:	75c58593          	addi	a1,a1,1884 # 80007030 <etext+0x30>
    800008dc:	0000f517          	auipc	a0,0xf
    800008e0:	05450513          	addi	a0,a0,84 # 8000f930 <tx_lock>
    800008e4:	2b4000ef          	jal	80000b98 <initlock>
}
    800008e8:	60a2                	ld	ra,8(sp)
    800008ea:	6402                	ld	s0,0(sp)
    800008ec:	0141                	addi	sp,sp,16
    800008ee:	8082                	ret

00000000800008f0 <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    800008f0:	715d                	addi	sp,sp,-80
    800008f2:	e486                	sd	ra,72(sp)
    800008f4:	e0a2                	sd	s0,64(sp)
    800008f6:	fc26                	sd	s1,56(sp)
    800008f8:	ec56                	sd	s5,24(sp)
    800008fa:	0880                	addi	s0,sp,80
    800008fc:	8aaa                	mv	s5,a0
    800008fe:	84ae                	mv	s1,a1
  acquire(&tx_lock);
    80000900:	0000f517          	auipc	a0,0xf
    80000904:	03050513          	addi	a0,a0,48 # 8000f930 <tx_lock>
    80000908:	310000ef          	jal	80000c18 <acquire>

  int i = 0;
  while (i < n) {
    8000090c:	06905063          	blez	s1,8000096c <uartwrite+0x7c>
    80000910:	f84a                	sd	s2,48(sp)
    80000912:	f44e                	sd	s3,40(sp)
    80000914:	f052                	sd	s4,32(sp)
    80000916:	e85a                	sd	s6,16(sp)
    80000918:	e45e                	sd	s7,8(sp)
    8000091a:	8a56                	mv	s4,s5
    8000091c:	9aa6                	add	s5,s5,s1
    while (tx_busy != 0) {
    8000091e:	00007497          	auipc	s1,0x7
    80000922:	f2e48493          	addi	s1,s1,-210 # 8000784c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000926:	0000f997          	auipc	s3,0xf
    8000092a:	00a98993          	addi	s3,s3,10 # 8000f930 <tx_lock>
    8000092e:	00007917          	auipc	s2,0x7
    80000932:	f1a90913          	addi	s2,s2,-230 # 80007848 <tx_chan>
    }

    WriteReg(THR, buf[i]);
    80000936:	10000bb7          	lui	s7,0x10000
    i += 1;
    tx_busy = 1;
    8000093a:	4b05                	li	s6,1
    8000093c:	a005                	j	8000095c <uartwrite+0x6c>
      sleep(&tx_chan, &tx_lock);
    8000093e:	85ce                	mv	a1,s3
    80000940:	854a                	mv	a0,s2
    80000942:	58e010ef          	jal	80001ed0 <sleep>
    while (tx_busy != 0) {
    80000946:	409c                	lw	a5,0(s1)
    80000948:	fbfd                	bnez	a5,8000093e <uartwrite+0x4e>
    WriteReg(THR, buf[i]);
    8000094a:	000a4783          	lbu	a5,0(s4)
    8000094e:	00fb8023          	sb	a5,0(s7) # 10000000 <_entry-0x70000000>
    tx_busy = 1;
    80000952:	0164a023          	sw	s6,0(s1)
  while (i < n) {
    80000956:	0a05                	addi	s4,s4,1
    80000958:	015a0563          	beq	s4,s5,80000962 <uartwrite+0x72>
    while (tx_busy != 0) {
    8000095c:	409c                	lw	a5,0(s1)
    8000095e:	f3e5                	bnez	a5,8000093e <uartwrite+0x4e>
    80000960:	b7ed                	j	8000094a <uartwrite+0x5a>
    80000962:	7942                	ld	s2,48(sp)
    80000964:	79a2                	ld	s3,40(sp)
    80000966:	7a02                	ld	s4,32(sp)
    80000968:	6b42                	ld	s6,16(sp)
    8000096a:	6ba2                	ld	s7,8(sp)
  }

  release(&tx_lock);
    8000096c:	0000f517          	auipc	a0,0xf
    80000970:	fc450513          	addi	a0,a0,-60 # 8000f930 <tx_lock>
    80000974:	328000ef          	jal	80000c9c <release>
}
    80000978:	60a6                	ld	ra,72(sp)
    8000097a:	6406                	ld	s0,64(sp)
    8000097c:	74e2                	ld	s1,56(sp)
    8000097e:	6ae2                	ld	s5,24(sp)
    80000980:	6161                	addi	sp,sp,80
    80000982:	8082                	ret

0000000080000984 <uartputc_sync>:
// interrupts, for use by kernel printk() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000984:	1101                	addi	sp,sp,-32
    80000986:	ec06                	sd	ra,24(sp)
    80000988:	e822                	sd	s0,16(sp)
    8000098a:	e426                	sd	s1,8(sp)
    8000098c:	1000                	addi	s0,sp,32
    8000098e:	84aa                	mv	s1,a0
  if (panicking == 0)
    80000990:	00007797          	auipc	a5,0x7
    80000994:	eb47a783          	lw	a5,-332(a5) # 80007844 <panicking>
    80000998:	cb91                	beqz	a5,800009ac <uartputc_sync+0x28>
    push_off();

  if (panicked) {
    8000099a:	00007797          	auipc	a5,0x7
    8000099e:	ea67a783          	lw	a5,-346(a5) # 80007840 <panicked>
    for (;;)
      ;
  }

  // wait for UART to set Transmit Holding Empty in LSR.
  while ((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800009a2:	10000737          	lui	a4,0x10000
    800009a6:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
  if (panicked) {
    800009a8:	c789                	beqz	a5,800009b2 <uartputc_sync+0x2e>
    for (;;)
    800009aa:	a001                	j	800009aa <uartputc_sync+0x26>
    push_off();
    800009ac:	232000ef          	jal	80000bde <push_off>
    800009b0:	b7ed                	j	8000099a <uartputc_sync+0x16>
  while ((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800009b2:	00074783          	lbu	a5,0(a4)
    800009b6:	0207f793          	andi	a5,a5,32
    800009ba:	dfe5                	beqz	a5,800009b2 <uartputc_sync+0x2e>
    ;
  WriteReg(THR, c);
    800009bc:	100007b7          	lui	a5,0x10000
    800009c0:	00978023          	sb	s1,0(a5) # 10000000 <_entry-0x70000000>

  if (panicking == 0)
    800009c4:	00007797          	auipc	a5,0x7
    800009c8:	e807a783          	lw	a5,-384(a5) # 80007844 <panicking>
    800009cc:	c791                	beqz	a5,800009d8 <uartputc_sync+0x54>
    pop_off();
}
    800009ce:	60e2                	ld	ra,24(sp)
    800009d0:	6442                	ld	s0,16(sp)
    800009d2:	64a2                	ld	s1,8(sp)
    800009d4:	6105                	addi	sp,sp,32
    800009d6:	8082                	ret
    pop_off();
    800009d8:	27c000ef          	jal	80000c54 <pop_off>
}
    800009dc:	bfcd                	j	800009ce <uartputc_sync+0x4a>

00000000800009de <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009de:	1101                	addi	sp,sp,-32
    800009e0:	ec06                	sd	ra,24(sp)
    800009e2:	e822                	sd	s0,16(sp)
    800009e4:	e426                	sd	s1,8(sp)
    800009e6:	e04a                	sd	s2,0(sp)
    800009e8:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    800009ea:	100007b7          	lui	a5,0x10000
    800009ee:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>

  acquire(&tx_lock);
    800009f2:	0000f517          	auipc	a0,0xf
    800009f6:	f3e50513          	addi	a0,a0,-194 # 8000f930 <tx_lock>
    800009fa:	21e000ef          	jal	80000c18 <acquire>
  if (ReadReg(LSR) & LSR_TX_IDLE) {
    800009fe:	100007b7          	lui	a5,0x10000
    80000a02:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000a06:	0207f793          	andi	a5,a5,32
    80000a0a:	e78d                	bnez	a5,80000a34 <uartintr+0x56>
    // UART finished transmitting; wake up sending thread.
    tx_busy = 0;
    wakeup(&tx_chan);
  }
  release(&tx_lock);
    80000a0c:	0000f517          	auipc	a0,0xf
    80000a10:	f2450513          	addi	a0,a0,-220 # 8000f930 <tx_lock>
    80000a14:	288000ef          	jal	80000c9c <release>
  if (ReadReg(LSR) & LSR_RX_READY) {
    80000a18:	100004b7          	lui	s1,0x10000
    80000a1c:	0495                	addi	s1,s1,5 # 10000005 <_entry-0x6ffffffb>
    return ReadReg(RHR);
    80000a1e:	10000937          	lui	s2,0x10000
  if (ReadReg(LSR) & LSR_RX_READY) {
    80000a22:	0004c783          	lbu	a5,0(s1)
    80000a26:	8b85                	andi	a5,a5,1
    80000a28:	c38d                	beqz	a5,80000a4a <uartintr+0x6c>
  // read and process incoming characters, if any.
  while (1) {
    int c = uartgetc();
    if (c == -1)
      break;
    consoleintr(c);
    80000a2a:	00094503          	lbu	a0,0(s2) # 10000000 <_entry-0x70000000>
    80000a2e:	881ff0ef          	jal	800002ae <consoleintr>
  while (1) {
    80000a32:	bfc5                	j	80000a22 <uartintr+0x44>
    tx_busy = 0;
    80000a34:	00007797          	auipc	a5,0x7
    80000a38:	e007ac23          	sw	zero,-488(a5) # 8000784c <tx_busy>
    wakeup(&tx_chan);
    80000a3c:	00007517          	auipc	a0,0x7
    80000a40:	e0c50513          	addi	a0,a0,-500 # 80007848 <tx_chan>
    80000a44:	4d8010ef          	jal	80001f1c <wakeup>
    80000a48:	b7d1                	j	80000a0c <uartintr+0x2e>
  }
}
    80000a4a:	60e2                	ld	ra,24(sp)
    80000a4c:	6442                	ld	s0,16(sp)
    80000a4e:	64a2                	ld	s1,8(sp)
    80000a50:	6902                	ld	s2,0(sp)
    80000a52:	6105                	addi	sp,sp,32
    80000a54:	8082                	ret

0000000080000a56 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a56:	1101                	addi	sp,sp,-32
    80000a58:	ec06                	sd	ra,24(sp)
    80000a5a:	e822                	sd	s0,16(sp)
    80000a5c:	e426                	sd	s1,8(sp)
    80000a5e:	e04a                	sd	s2,0(sp)
    80000a60:	1000                	addi	s0,sp,32
  struct run *r;

  if (((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
    80000a62:	00020797          	auipc	a5,0x20
    80000a66:	11678793          	addi	a5,a5,278 # 80020b78 <end>
    80000a6a:	00f53733          	sltu	a4,a0,a5
    80000a6e:	47c5                	li	a5,17
    80000a70:	07ee                	slli	a5,a5,0x1b
    80000a72:	17fd                	addi	a5,a5,-1
    80000a74:	00a7b7b3          	sltu	a5,a5,a0
    80000a78:	8fd9                	or	a5,a5,a4
    80000a7a:	03451713          	slli	a4,a0,0x34
    80000a7e:	8fd9                	or	a5,a5,a4
    80000a80:	eb9d                	bnez	a5,80000ab6 <kfree+0x60>
    80000a82:	84aa                	mv	s1,a0
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a84:	6605                	lui	a2,0x1
    80000a86:	4585                	li	a1,1
    80000a88:	24c000ef          	jal	80000cd4 <memset>

  r = (struct run *)pa;

  acquire(&kmem.lock);
    80000a8c:	0000f917          	auipc	s2,0xf
    80000a90:	ebc90913          	addi	s2,s2,-324 # 8000f948 <kmem>
    80000a94:	854a                	mv	a0,s2
    80000a96:	182000ef          	jal	80000c18 <acquire>
  r->next = kmem.freelist;
    80000a9a:	01893783          	ld	a5,24(s2)
    80000a9e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000aa0:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000aa4:	854a                	mv	a0,s2
    80000aa6:	1f6000ef          	jal	80000c9c <release>
}
    80000aaa:	60e2                	ld	ra,24(sp)
    80000aac:	6442                	ld	s0,16(sp)
    80000aae:	64a2                	ld	s1,8(sp)
    80000ab0:	6902                	ld	s2,0(sp)
    80000ab2:	6105                	addi	sp,sp,32
    80000ab4:	8082                	ret
    panic("kfree");
    80000ab6:	00006517          	auipc	a0,0x6
    80000aba:	58250513          	addi	a0,a0,1410 # 80007038 <etext+0x38>
    80000abe:	d7dff0ef          	jal	8000083a <panic>

0000000080000ac2 <freerange>:
{
    80000ac2:	7179                	addi	sp,sp,-48
    80000ac4:	f406                	sd	ra,40(sp)
    80000ac6:	f022                	sd	s0,32(sp)
    80000ac8:	ec26                	sd	s1,24(sp)
    80000aca:	1800                	addi	s0,sp,48
  p = (char *)PGROUNDUP((uint64)pa_start);
    80000acc:	6785                	lui	a5,0x1
    80000ace:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ad2:	00e504b3          	add	s1,a0,a4
    80000ad6:	777d                	lui	a4,0xfffff
    80000ad8:	8cf9                	and	s1,s1,a4
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000ada:	94be                	add	s1,s1,a5
    80000adc:	0295e263          	bltu	a1,s1,80000b00 <freerange+0x3e>
    80000ae0:	e84a                	sd	s2,16(sp)
    80000ae2:	e44e                	sd	s3,8(sp)
    80000ae4:	e052                	sd	s4,0(sp)
    80000ae6:	892e                	mv	s2,a1
    kfree(p);
    80000ae8:	8a3a                	mv	s4,a4
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000aea:	89be                	mv	s3,a5
    kfree(p);
    80000aec:	01448533          	add	a0,s1,s4
    80000af0:	f67ff0ef          	jal	80000a56 <kfree>
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000af4:	94ce                	add	s1,s1,s3
    80000af6:	fe997be3          	bgeu	s2,s1,80000aec <freerange+0x2a>
    80000afa:	6942                	ld	s2,16(sp)
    80000afc:	69a2                	ld	s3,8(sp)
    80000afe:	6a02                	ld	s4,0(sp)
}
    80000b00:	70a2                	ld	ra,40(sp)
    80000b02:	7402                	ld	s0,32(sp)
    80000b04:	64e2                	ld	s1,24(sp)
    80000b06:	6145                	addi	sp,sp,48
    80000b08:	8082                	ret

0000000080000b0a <kinit>:
{
    80000b0a:	1141                	addi	sp,sp,-16
    80000b0c:	e406                	sd	ra,8(sp)
    80000b0e:	e022                	sd	s0,0(sp)
    80000b10:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b12:	00006597          	auipc	a1,0x6
    80000b16:	52e58593          	addi	a1,a1,1326 # 80007040 <etext+0x40>
    80000b1a:	0000f517          	auipc	a0,0xf
    80000b1e:	e2e50513          	addi	a0,a0,-466 # 8000f948 <kmem>
    80000b22:	076000ef          	jal	80000b98 <initlock>
  freerange(end, (void *)PHYSTOP);
    80000b26:	45c5                	li	a1,17
    80000b28:	05ee                	slli	a1,a1,0x1b
    80000b2a:	00020517          	auipc	a0,0x20
    80000b2e:	04e50513          	addi	a0,a0,78 # 80020b78 <end>
    80000b32:	f91ff0ef          	jal	80000ac2 <freerange>
}
    80000b36:	60a2                	ld	ra,8(sp)
    80000b38:	6402                	ld	s0,0(sp)
    80000b3a:	0141                	addi	sp,sp,16
    80000b3c:	8082                	ret

0000000080000b3e <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b3e:	1101                	addi	sp,sp,-32
    80000b40:	ec06                	sd	ra,24(sp)
    80000b42:	e822                	sd	s0,16(sp)
    80000b44:	e426                	sd	s1,8(sp)
    80000b46:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b48:	0000f517          	auipc	a0,0xf
    80000b4c:	e0050513          	addi	a0,a0,-512 # 8000f948 <kmem>
    80000b50:	0c8000ef          	jal	80000c18 <acquire>
  r = kmem.freelist;
    80000b54:	0000f497          	auipc	s1,0xf
    80000b58:	e0c4b483          	ld	s1,-500(s1) # 8000f960 <kmem+0x18>
  if (r)
    80000b5c:	c49d                	beqz	s1,80000b8a <kalloc+0x4c>
    kmem.freelist = r->next;
    80000b5e:	609c                	ld	a5,0(s1)
    80000b60:	0000f717          	auipc	a4,0xf
    80000b64:	e0f73023          	sd	a5,-512(a4) # 8000f960 <kmem+0x18>
  release(&kmem.lock);
    80000b68:	0000f517          	auipc	a0,0xf
    80000b6c:	de050513          	addi	a0,a0,-544 # 8000f948 <kmem>
    80000b70:	12c000ef          	jal	80000c9c <release>

  if (r)
    memset((char *)r, 5, PGSIZE); // fill with junk
    80000b74:	6605                	lui	a2,0x1
    80000b76:	4595                	li	a1,5
    80000b78:	8526                	mv	a0,s1
    80000b7a:	15a000ef          	jal	80000cd4 <memset>
  return (void *)r;
}
    80000b7e:	8526                	mv	a0,s1
    80000b80:	60e2                	ld	ra,24(sp)
    80000b82:	6442                	ld	s0,16(sp)
    80000b84:	64a2                	ld	s1,8(sp)
    80000b86:	6105                	addi	sp,sp,32
    80000b88:	8082                	ret
  release(&kmem.lock);
    80000b8a:	0000f517          	auipc	a0,0xf
    80000b8e:	dbe50513          	addi	a0,a0,-578 # 8000f948 <kmem>
    80000b92:	10a000ef          	jal	80000c9c <release>
  if (r)
    80000b96:	b7e5                	j	80000b7e <kalloc+0x40>

0000000080000b98 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b98:	1141                	addi	sp,sp,-16
    80000b9a:	e406                	sd	ra,8(sp)
    80000b9c:	e022                	sd	s0,0(sp)
    80000b9e:	0800                	addi	s0,sp,16
  lk->name = name;
    80000ba0:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000ba2:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000ba6:	00053823          	sd	zero,16(a0)
}
    80000baa:	60a2                	ld	ra,8(sp)
    80000bac:	6402                	ld	s0,0(sp)
    80000bae:	0141                	addi	sp,sp,16
    80000bb0:	8082                	ret

0000000080000bb2 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000bb2:	411c                	lw	a5,0(a0)
    80000bb4:	e399                	bnez	a5,80000bba <holding+0x8>
    80000bb6:	4501                	li	a0,0
  return r;
}
    80000bb8:	8082                	ret
{
    80000bba:	1101                	addi	sp,sp,-32
    80000bbc:	ec06                	sd	ra,24(sp)
    80000bbe:	e822                	sd	s0,16(sp)
    80000bc0:	e426                	sd	s1,8(sp)
    80000bc2:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000bc4:	691c                	ld	a5,16(a0)
    80000bc6:	84be                	mv	s1,a5
    80000bc8:	4f7000ef          	jal	800018be <mycpu>
    80000bcc:	40a48533          	sub	a0,s1,a0
    80000bd0:	00153513          	seqz	a0,a0
}
    80000bd4:	60e2                	ld	ra,24(sp)
    80000bd6:	6442                	ld	s0,16(sp)
    80000bd8:	64a2                	ld	s1,8(sp)
    80000bda:	6105                	addi	sp,sp,32
    80000bdc:	8082                	ret

0000000080000bde <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bde:	1101                	addi	sp,sp,-32
    80000be0:	ec06                	sd	ra,24(sp)
    80000be2:	e822                	sd	s0,16(sp)
    80000be4:	e426                	sd	s1,8(sp)
    80000be6:	1000                	addi	s0,sp,32
  __asm__ __volatile__("csrrc %0, sstatus, %1" : "=r"(x) : "rK"(x) : "memory");
    80000be8:	100177f3          	csrrci	a5,sstatus,2
    80000bec:	84be                	mv	s1,a5
  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  uint64 flags = rc_sstatus(SSTATUS_SIE);
  int old = !!(flags & SSTATUS_SIE);

  if (mycpu()->noff == 0)
    80000bee:	4d1000ef          	jal	800018be <mycpu>
    80000bf2:	5d3c                	lw	a5,120(a0)
    80000bf4:	cb99                	beqz	a5,80000c0a <push_off+0x2c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bf6:	4c9000ef          	jal	800018be <mycpu>
    80000bfa:	5d3c                	lw	a5,120(a0)
    80000bfc:	2785                	addiw	a5,a5,1
    80000bfe:	dd3c                	sw	a5,120(a0)
}
    80000c00:	60e2                	ld	ra,24(sp)
    80000c02:	6442                	ld	s0,16(sp)
    80000c04:	64a2                	ld	s1,8(sp)
    80000c06:	6105                	addi	sp,sp,32
    80000c08:	8082                	ret
    mycpu()->intena = old;
    80000c0a:	4b5000ef          	jal	800018be <mycpu>
  int old = !!(flags & SSTATUS_SIE);
    80000c0e:	0014d793          	srli	a5,s1,0x1
    80000c12:	8b85                	andi	a5,a5,1
    mycpu()->intena = old;
    80000c14:	dd7c                	sw	a5,124(a0)
    80000c16:	b7c5                	j	80000bf6 <push_off+0x18>

0000000080000c18 <acquire>:
{
    80000c18:	1101                	addi	sp,sp,-32
    80000c1a:	ec06                	sd	ra,24(sp)
    80000c1c:	e822                	sd	s0,16(sp)
    80000c1e:	e426                	sd	s1,8(sp)
    80000c20:	1000                	addi	s0,sp,32
    80000c22:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c24:	fbbff0ef          	jal	80000bde <push_off>
  if (holding(lk))
    80000c28:	8526                	mv	a0,s1
    80000c2a:	f89ff0ef          	jal	80000bb2 <holding>
  while (__atomic_exchange_n(&lk->locked, 1, __ATOMIC_ACQUIRE) != 0)
    80000c2e:	4705                	li	a4,1
  if (holding(lk))
    80000c30:	ed01                	bnez	a0,80000c48 <acquire+0x30>
  while (__atomic_exchange_n(&lk->locked, 1, __ATOMIC_ACQUIRE) != 0)
    80000c32:	0ce4a7af          	amoswap.w.aq	a5,a4,(s1)
    80000c36:	fff5                	bnez	a5,80000c32 <acquire+0x1a>
  lk->cpu = mycpu();
    80000c38:	487000ef          	jal	800018be <mycpu>
    80000c3c:	e888                	sd	a0,16(s1)
}
    80000c3e:	60e2                	ld	ra,24(sp)
    80000c40:	6442                	ld	s0,16(sp)
    80000c42:	64a2                	ld	s1,8(sp)
    80000c44:	6105                	addi	sp,sp,32
    80000c46:	8082                	ret
    panic("acquire");
    80000c48:	00006517          	auipc	a0,0x6
    80000c4c:	40050513          	addi	a0,a0,1024 # 80007048 <etext+0x48>
    80000c50:	bebff0ef          	jal	8000083a <panic>

0000000080000c54 <pop_off>:

void
pop_off(void)
{
    80000c54:	1141                	addi	sp,sp,-16
    80000c56:	e406                	sd	ra,8(sp)
    80000c58:	e022                	sd	s0,0(sp)
    80000c5a:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c5c:	463000ef          	jal	800018be <mycpu>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80000c60:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c64:	8b89                	andi	a5,a5,2
  if (intr_get())
    80000c66:	ef99                	bnez	a5,80000c84 <pop_off+0x30>
    panic("pop_off - interruptible");
  if (c->noff < 1)
    80000c68:	5d3c                	lw	a5,120(a0)
    80000c6a:	02f05363          	blez	a5,80000c90 <pop_off+0x3c>
    panic("pop_off");
  c->noff -= 1;
    80000c6e:	37fd                	addiw	a5,a5,-1
    80000c70:	dd3c                	sw	a5,120(a0)
  if (c->noff == 0 && c->intena)
    80000c72:	e789                	bnez	a5,80000c7c <pop_off+0x28>
    80000c74:	5d7c                	lw	a5,124(a0)
    80000c76:	c399                	beqz	a5,80000c7c <pop_off+0x28>
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80000c78:	10016073          	csrsi	sstatus,2
    intr_on();
}
    80000c7c:	60a2                	ld	ra,8(sp)
    80000c7e:	6402                	ld	s0,0(sp)
    80000c80:	0141                	addi	sp,sp,16
    80000c82:	8082                	ret
    panic("pop_off - interruptible");
    80000c84:	00006517          	auipc	a0,0x6
    80000c88:	3cc50513          	addi	a0,a0,972 # 80007050 <etext+0x50>
    80000c8c:	bafff0ef          	jal	8000083a <panic>
    panic("pop_off");
    80000c90:	00006517          	auipc	a0,0x6
    80000c94:	3d850513          	addi	a0,a0,984 # 80007068 <etext+0x68>
    80000c98:	ba3ff0ef          	jal	8000083a <panic>

0000000080000c9c <release>:
{
    80000c9c:	1101                	addi	sp,sp,-32
    80000c9e:	ec06                	sd	ra,24(sp)
    80000ca0:	e822                	sd	s0,16(sp)
    80000ca2:	e426                	sd	s1,8(sp)
    80000ca4:	1000                	addi	s0,sp,32
    80000ca6:	84aa                	mv	s1,a0
  if (!holding(lk))
    80000ca8:	f0bff0ef          	jal	80000bb2 <holding>
    80000cac:	cd11                	beqz	a0,80000cc8 <release+0x2c>
  lk->cpu = 0;
    80000cae:	0004b823          	sd	zero,16(s1)
  __atomic_store_n(&lk->locked, 0, __ATOMIC_RELEASE);
    80000cb2:	0310000f          	fence	rw,w
    80000cb6:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000cba:	f9bff0ef          	jal	80000c54 <pop_off>
}
    80000cbe:	60e2                	ld	ra,24(sp)
    80000cc0:	6442                	ld	s0,16(sp)
    80000cc2:	64a2                	ld	s1,8(sp)
    80000cc4:	6105                	addi	sp,sp,32
    80000cc6:	8082                	ret
    panic("release");
    80000cc8:	00006517          	auipc	a0,0x6
    80000ccc:	3a850513          	addi	a0,a0,936 # 80007070 <etext+0x70>
    80000cd0:	b6bff0ef          	jal	8000083a <panic>

0000000080000cd4 <memset>:
#include "types.h"

void *
memset(void *dst, int c, uint n)
{
    80000cd4:	1141                	addi	sp,sp,-16
    80000cd6:	e406                	sd	ra,8(sp)
    80000cd8:	e022                	sd	s0,0(sp)
    80000cda:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
    80000cdc:	ca19                	beqz	a2,80000cf2 <memset+0x1e>
    80000cde:	87aa                	mv	a5,a0
    80000ce0:	1602                	slli	a2,a2,0x20
    80000ce2:	9201                	srli	a2,a2,0x20
    80000ce4:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ce8:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
    80000cec:	0785                	addi	a5,a5,1
    80000cee:	fee79de3          	bne	a5,a4,80000ce8 <memset+0x14>
  }
  return dst;
}
    80000cf2:	60a2                	ld	ra,8(sp)
    80000cf4:	6402                	ld	s0,0(sp)
    80000cf6:	0141                	addi	sp,sp,16
    80000cf8:	8082                	ret

0000000080000cfa <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cfa:	1141                	addi	sp,sp,-16
    80000cfc:	e406                	sd	ra,8(sp)
    80000cfe:	e022                	sd	s0,0(sp)
    80000d00:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while (n-- > 0) {
    80000d02:	ce19                	beqz	a2,80000d20 <memcmp+0x26>
    80000d04:	1602                	slli	a2,a2,0x20
    80000d06:	9201                	srli	a2,a2,0x20
    80000d08:	00c506b3          	add	a3,a0,a2
    if (*s1 != *s2)
    80000d0c:	00054783          	lbu	a5,0(a0)
    80000d10:	0005c703          	lbu	a4,0(a1)
    80000d14:	00e79b63          	bne	a5,a4,80000d2a <memcmp+0x30>
      return *s1 - *s2;
    s1++, s2++;
    80000d18:	0505                	addi	a0,a0,1
    80000d1a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    80000d1c:	fed518e3          	bne	a0,a3,80000d0c <memcmp+0x12>
  }

  return 0;
    80000d20:	4501                	li	a0,0
}
    80000d22:	60a2                	ld	ra,8(sp)
    80000d24:	6402                	ld	s0,0(sp)
    80000d26:	0141                	addi	sp,sp,16
    80000d28:	8082                	ret
      return *s1 - *s2;
    80000d2a:	40e7853b          	subw	a0,a5,a4
    80000d2e:	bfd5                	j	80000d22 <memcmp+0x28>

0000000080000d30 <memmove>:

void *
memmove(void *dst, const void *src, uint n)
{
    80000d30:	1141                	addi	sp,sp,-16
    80000d32:	e406                	sd	ra,8(sp)
    80000d34:	e022                	sd	s0,0(sp)
    80000d36:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if (n == 0)
    80000d38:	c61d                	beqz	a2,80000d66 <memmove+0x36>
    return dst;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
    80000d3a:	00a5f963          	bgeu	a1,a0,80000d4c <memmove+0x1c>
    80000d3e:	02061693          	slli	a3,a2,0x20
    80000d42:	9281                	srli	a3,a3,0x20
    80000d44:	00d58733          	add	a4,a1,a3
    80000d48:	02e56363          	bltu	a0,a4,80000d6e <memmove+0x3e>
    s += n;
    d += n;
    while (n-- > 0)
      *--d = *--s;
  } else
    while (n-- > 0)
    80000d4c:	1602                	slli	a2,a2,0x20
    80000d4e:	9201                	srli	a2,a2,0x20
    80000d50:	00c587b3          	add	a5,a1,a2
{
    80000d54:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d56:	0585                	addi	a1,a1,1
    80000d58:	0705                	addi	a4,a4,1
    80000d5a:	fff5c683          	lbu	a3,-1(a1)
    80000d5e:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
    80000d62:	fef59ae3          	bne	a1,a5,80000d56 <memmove+0x26>

  return dst;
}
    80000d66:	60a2                	ld	ra,8(sp)
    80000d68:	6402                	ld	s0,0(sp)
    80000d6a:	0141                	addi	sp,sp,16
    80000d6c:	8082                	ret
    d += n;
    80000d6e:	96aa                	add	a3,a3,a0
    while (n-- > 0)
    80000d70:	fff6079b          	addiw	a5,a2,-1 # fff <_entry-0x7ffff001>
    80000d74:	1782                	slli	a5,a5,0x20
    80000d76:	9381                	srli	a5,a5,0x20
    80000d78:	fff7c793          	not	a5,a5
    80000d7c:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d7e:	177d                	addi	a4,a4,-1
    80000d80:	16fd                	addi	a3,a3,-1
    80000d82:	00074603          	lbu	a2,0(a4)
    80000d86:	00c68023          	sb	a2,0(a3)
    while (n-- > 0)
    80000d8a:	fee79ae3          	bne	a5,a4,80000d7e <memmove+0x4e>
    80000d8e:	bfe1                	j	80000d66 <memmove+0x36>

0000000080000d90 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void *
memcpy(void *dst, const void *src, uint n)
{
    80000d90:	1141                	addi	sp,sp,-16
    80000d92:	e406                	sd	ra,8(sp)
    80000d94:	e022                	sd	s0,0(sp)
    80000d96:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d98:	f99ff0ef          	jal	80000d30 <memmove>
}
    80000d9c:	60a2                	ld	ra,8(sp)
    80000d9e:	6402                	ld	s0,0(sp)
    80000da0:	0141                	addi	sp,sp,16
    80000da2:	8082                	ret

0000000080000da4 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000da4:	1141                	addi	sp,sp,-16
    80000da6:	e406                	sd	ra,8(sp)
    80000da8:	e022                	sd	s0,0(sp)
    80000daa:	0800                	addi	s0,sp,16
  while (n > 0 && *p && *p == *q)
    80000dac:	ce01                	beqz	a2,80000dc4 <strncmp+0x20>
    80000dae:	00054783          	lbu	a5,0(a0)
    80000db2:	cb99                	beqz	a5,80000dc8 <strncmp+0x24>
    80000db4:	0005c703          	lbu	a4,0(a1)
    80000db8:	00f71863          	bne	a4,a5,80000dc8 <strncmp+0x24>
    n--, p++, q++;
    80000dbc:	367d                	addiw	a2,a2,-1
    80000dbe:	0505                	addi	a0,a0,1
    80000dc0:	0585                	addi	a1,a1,1
  while (n > 0 && *p && *p == *q)
    80000dc2:	f675                	bnez	a2,80000dae <strncmp+0xa>
  if (n == 0)
    return 0;
    80000dc4:	4501                	li	a0,0
    80000dc6:	a031                	j	80000dd2 <strncmp+0x2e>
  return (uchar)*p - (uchar)*q;
    80000dc8:	00054503          	lbu	a0,0(a0)
    80000dcc:	0005c783          	lbu	a5,0(a1)
    80000dd0:	9d1d                	subw	a0,a0,a5
}
    80000dd2:	60a2                	ld	ra,8(sp)
    80000dd4:	6402                	ld	s0,0(sp)
    80000dd6:	0141                	addi	sp,sp,16
    80000dd8:	8082                	ret

0000000080000dda <strncpy>:

char *
strncpy(char *s, const char *t, int n)
{
    80000dda:	1141                	addi	sp,sp,-16
    80000ddc:	e406                	sd	ra,8(sp)
    80000dde:	e022                	sd	s0,0(sp)
    80000de0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while (n-- > 0 && (*s++ = *t++) != 0)
    80000de2:	87aa                	mv	a5,a0
    80000de4:	a011                	j	80000de8 <strncpy+0xe>
    80000de6:	8636                	mv	a2,a3
    80000de8:	02c05763          	blez	a2,80000e16 <strncpy+0x3c>
    80000dec:	fff6069b          	addiw	a3,a2,-1
    80000df0:	0785                	addi	a5,a5,1
    80000df2:	0005c703          	lbu	a4,0(a1)
    80000df6:	fee78fa3          	sb	a4,-1(a5)
    80000dfa:	0585                	addi	a1,a1,1
    80000dfc:	f76d                	bnez	a4,80000de6 <strncpy+0xc>
    ;
  while (n-- > 0)
    80000dfe:	873e                	mv	a4,a5
    80000e00:	00d05b63          	blez	a3,80000e16 <strncpy+0x3c>
    80000e04:	9fb1                	addw	a5,a5,a2
    80000e06:	37fd                	addiw	a5,a5,-1
    *s++ = 0;
    80000e08:	0705                	addi	a4,a4,1
    80000e0a:	fe070fa3          	sb	zero,-1(a4)
  while (n-- > 0)
    80000e0e:	40e786bb          	subw	a3,a5,a4
    80000e12:	fed04be3          	bgtz	a3,80000e08 <strncpy+0x2e>
  return os;
}
    80000e16:	60a2                	ld	ra,8(sp)
    80000e18:	6402                	ld	s0,0(sp)
    80000e1a:	0141                	addi	sp,sp,16
    80000e1c:	8082                	ret

0000000080000e1e <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char *
safestrcpy(char *s, const char *t, int n)
{
    80000e1e:	1141                	addi	sp,sp,-16
    80000e20:	e406                	sd	ra,8(sp)
    80000e22:	e022                	sd	s0,0(sp)
    80000e24:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if (n <= 0)
    80000e26:	02c05363          	blez	a2,80000e4c <safestrcpy+0x2e>
    80000e2a:	fff6069b          	addiw	a3,a2,-1
    80000e2e:	1682                	slli	a3,a3,0x20
    80000e30:	9281                	srli	a3,a3,0x20
    80000e32:	96ae                	add	a3,a3,a1
    80000e34:	87aa                	mv	a5,a0
    return os;
  while (--n > 0 && (*s++ = *t++) != 0)
    80000e36:	00d58963          	beq	a1,a3,80000e48 <safestrcpy+0x2a>
    80000e3a:	0585                	addi	a1,a1,1
    80000e3c:	0785                	addi	a5,a5,1
    80000e3e:	fff5c703          	lbu	a4,-1(a1)
    80000e42:	fee78fa3          	sb	a4,-1(a5)
    80000e46:	fb65                	bnez	a4,80000e36 <safestrcpy+0x18>
    ;
  *s = 0;
    80000e48:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e4c:	60a2                	ld	ra,8(sp)
    80000e4e:	6402                	ld	s0,0(sp)
    80000e50:	0141                	addi	sp,sp,16
    80000e52:	8082                	ret

0000000080000e54 <strlen>:

int
strlen(const char *s)
{
    80000e54:	1141                	addi	sp,sp,-16
    80000e56:	e406                	sd	ra,8(sp)
    80000e58:	e022                	sd	s0,0(sp)
    80000e5a:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
    80000e5c:	00054783          	lbu	a5,0(a0)
    80000e60:	cf91                	beqz	a5,80000e7c <strlen+0x28>
    80000e62:	00150793          	addi	a5,a0,1
    80000e66:	86be                	mv	a3,a5
    80000e68:	0785                	addi	a5,a5,1
    80000e6a:	fff7c703          	lbu	a4,-1(a5)
    80000e6e:	ff65                	bnez	a4,80000e66 <strlen+0x12>
    80000e70:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
    80000e74:	60a2                	ld	ra,8(sp)
    80000e76:	6402                	ld	s0,0(sp)
    80000e78:	0141                	addi	sp,sp,16
    80000e7a:	8082                	ret
  for (n = 0; s[n]; n++)
    80000e7c:	4501                	li	a0,0
    80000e7e:	bfdd                	j	80000e74 <strlen+0x20>

0000000080000e80 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e80:	1141                	addi	sp,sp,-16
    80000e82:	e406                	sd	ra,8(sp)
    80000e84:	e022                	sd	s0,0(sp)
    80000e86:	0800                	addi	s0,sp,16
  if (cpuid() == 0) {
    80000e88:	223000ef          	jal	800018aa <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();         // first user process

    __atomic_store_n(&started, 1, __ATOMIC_RELEASE);
  } else {
    while (__atomic_load_n(&started, __ATOMIC_ACQUIRE) == 0)
    80000e8c:	00007717          	auipc	a4,0x7
    80000e90:	9c470713          	addi	a4,a4,-1596 # 80007850 <started>
  if (cpuid() == 0) {
    80000e94:	c51d                	beqz	a0,80000ec2 <main+0x42>
    while (__atomic_load_n(&started, __ATOMIC_ACQUIRE) == 0)
    80000e96:	431c                	lw	a5,0(a4)
    80000e98:	0230000f          	fence	r,rw
    80000e9c:	2781                	sext.w	a5,a5
    80000e9e:	dfe5                	beqz	a5,80000e96 <main+0x16>
      ;

    printk("hart %d starting\n", cpuid());
    80000ea0:	20b000ef          	jal	800018aa <cpuid>
    80000ea4:	85aa                	mv	a1,a0
    80000ea6:	00006517          	auipc	a0,0x6
    80000eaa:	1f250513          	addi	a0,a0,498 # 80007098 <etext+0x98>
    80000eae:	e54ff0ef          	jal	80000502 <printk>
    kvminithart();  // turn on paging
    80000eb2:	082000ef          	jal	80000f34 <kvminithart>
    trapinithart(); // install kernel trap vector
    80000eb6:	538010ef          	jal	800023ee <trapinithart>
    plicinithart(); // ask PLIC for device interrupts
    80000eba:	51e040ef          	jal	800053d8 <plicinithart>
  }

  scheduler();
    80000ebe:	693000ef          	jal	80001d50 <scheduler>
    consoleinit();
    80000ec2:	d68ff0ef          	jal	8000042a <consoleinit>
    printkinit();
    80000ec6:	9b1ff0ef          	jal	80000876 <printkinit>
    printk("\n");
    80000eca:	00006517          	auipc	a0,0x6
    80000ece:	1ae50513          	addi	a0,a0,430 # 80007078 <etext+0x78>
    80000ed2:	e30ff0ef          	jal	80000502 <printk>
    printk("xv6 kernel is booting\n");
    80000ed6:	00006517          	auipc	a0,0x6
    80000eda:	1aa50513          	addi	a0,a0,426 # 80007080 <etext+0x80>
    80000ede:	e24ff0ef          	jal	80000502 <printk>
    printk("\n");
    80000ee2:	00006517          	auipc	a0,0x6
    80000ee6:	19650513          	addi	a0,a0,406 # 80007078 <etext+0x78>
    80000eea:	e18ff0ef          	jal	80000502 <printk>
    kinit();            // physical page allocator
    80000eee:	c1dff0ef          	jal	80000b0a <kinit>
    kvminit();          // create kernel page table
    80000ef2:	2c2000ef          	jal	800011b4 <kvminit>
    kvminithart();      // turn on paging
    80000ef6:	03e000ef          	jal	80000f34 <kvminithart>
    procinit();         // process table
    80000efa:	0f9000ef          	jal	800017f2 <procinit>
    trapinit();         // trap vectors
    80000efe:	4cc010ef          	jal	800023ca <trapinit>
    trapinithart();     // install kernel trap vector
    80000f02:	4ec010ef          	jal	800023ee <trapinithart>
    plicinit();         // set up interrupt controller
    80000f06:	4b8040ef          	jal	800053be <plicinit>
    plicinithart();     // ask PLIC for device interrupts
    80000f0a:	4ce040ef          	jal	800053d8 <plicinithart>
    binit();            // buffer cache
    80000f0e:	365010ef          	jal	80002a72 <binit>
    iinit();            // inode table
    80000f12:	0be020ef          	jal	80002fd0 <iinit>
    fileinit();         // file table
    80000f16:	054030ef          	jal	80003f6a <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f1a:	5ae040ef          	jal	800054c8 <virtio_disk_init>
    userinit();         // first user process
    80000f1e:	491000ef          	jal	80001bae <userinit>
    __atomic_store_n(&started, 1, __ATOMIC_RELEASE);
    80000f22:	00007797          	auipc	a5,0x7
    80000f26:	92e78793          	addi	a5,a5,-1746 # 80007850 <started>
    80000f2a:	4705                	li	a4,1
    80000f2c:	0310000f          	fence	rw,w
    80000f30:	c398                	sw	a4,0(a5)
    80000f32:	b771                	j	80000ebe <main+0x3e>

0000000080000f34 <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000f34:	1141                	addi	sp,sp,-16
    80000f36:	e406                	sd	ra,8(sp)
    80000f38:	e022                	sd	s0,0(sp)
    80000f3a:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero" ::: "memory");
    80000f3c:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f40:	00007797          	auipc	a5,0x7
    80000f44:	9187b783          	ld	a5,-1768(a5) # 80007858 <kernel_pagetable>
    80000f48:	83b1                	srli	a5,a5,0xc
    80000f4a:	577d                	li	a4,-1
    80000f4c:	177e                	slli	a4,a4,0x3f
    80000f4e:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r"(x));
    80000f50:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero" ::: "memory");
    80000f54:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f58:	60a2                	ld	ra,8(sp)
    80000f5a:	6402                	ld	s0,0(sp)
    80000f5c:	0141                	addi	sp,sp,16
    80000f5e:	8082                	ret

0000000080000f60 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f60:	7139                	addi	sp,sp,-64
    80000f62:	fc06                	sd	ra,56(sp)
    80000f64:	f822                	sd	s0,48(sp)
    80000f66:	f426                	sd	s1,40(sp)
    80000f68:	f04a                	sd	s2,32(sp)
    80000f6a:	ec4e                	sd	s3,24(sp)
    80000f6c:	e852                	sd	s4,16(sp)
    80000f6e:	e456                	sd	s5,8(sp)
    80000f70:	e05a                	sd	s6,0(sp)
    80000f72:	0080                	addi	s0,sp,64
    80000f74:	84aa                	mv	s1,a0
    80000f76:	89ae                	mv	s3,a1
    80000f78:	8b32                	mv	s6,a2
  if (va >= MAXVA)
    80000f7a:	57fd                	li	a5,-1
    80000f7c:	83e9                	srli	a5,a5,0x1a
    80000f7e:	4a79                	li	s4,30
    panic("walk");

  for (int level = 2; level > 0; level--) {
    80000f80:	4ab1                	li	s5,12
  if (va >= MAXVA)
    80000f82:	06b7e363          	bltu	a5,a1,80000fe8 <walk+0x88>
    pte_t *pte = &pagetable[PX(level, va)];
    80000f86:	0149d933          	srl	s2,s3,s4
    80000f8a:	1ff97913          	andi	s2,s2,511
    80000f8e:	090e                	slli	s2,s2,0x3
    80000f90:	9926                	add	s2,s2,s1
    if (*pte & PTE_V) {
    80000f92:	00093483          	ld	s1,0(s2)
    80000f96:	0014f793          	andi	a5,s1,1
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000f9a:	80a9                	srli	s1,s1,0xa
    80000f9c:	04b2                	slli	s1,s1,0xc
    if (*pte & PTE_V) {
    80000f9e:	e395                	bnez	a5,80000fc2 <walk+0x62>
    } else {
      if (!alloc || (pagetable = (pde_t *)kalloc()) == 0)
    80000fa0:	040b0a63          	beqz	s6,80000ff4 <walk+0x94>
    80000fa4:	b9bff0ef          	jal	80000b3e <kalloc>
    80000fa8:	84aa                	mv	s1,a0
    80000faa:	c50d                	beqz	a0,80000fd4 <walk+0x74>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000fac:	6605                	lui	a2,0x1
    80000fae:	4581                	li	a1,0
    80000fb0:	d25ff0ef          	jal	80000cd4 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000fb4:	00c4d793          	srli	a5,s1,0xc
    80000fb8:	07aa                	slli	a5,a5,0xa
    80000fba:	0017e793          	ori	a5,a5,1
    80000fbe:	00f93023          	sd	a5,0(s2)
  for (int level = 2; level > 0; level--) {
    80000fc2:	3a5d                	addiw	s4,s4,-9
    80000fc4:	fd5a11e3          	bne	s4,s5,80000f86 <walk+0x26>
    }
  }
  return &pagetable[PX(0, va)];
    80000fc8:	00c9d513          	srli	a0,s3,0xc
    80000fcc:	1ff57513          	andi	a0,a0,511
    80000fd0:	050e                	slli	a0,a0,0x3
    80000fd2:	9526                	add	a0,a0,s1
}
    80000fd4:	70e2                	ld	ra,56(sp)
    80000fd6:	7442                	ld	s0,48(sp)
    80000fd8:	74a2                	ld	s1,40(sp)
    80000fda:	7902                	ld	s2,32(sp)
    80000fdc:	69e2                	ld	s3,24(sp)
    80000fde:	6a42                	ld	s4,16(sp)
    80000fe0:	6aa2                	ld	s5,8(sp)
    80000fe2:	6b02                	ld	s6,0(sp)
    80000fe4:	6121                	addi	sp,sp,64
    80000fe6:	8082                	ret
    panic("walk");
    80000fe8:	00006517          	auipc	a0,0x6
    80000fec:	0c850513          	addi	a0,a0,200 # 800070b0 <etext+0xb0>
    80000ff0:	84bff0ef          	jal	8000083a <panic>
        return 0;
    80000ff4:	4501                	li	a0,0
    80000ff6:	bff9                	j	80000fd4 <walk+0x74>

0000000080000ff8 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if (va >= MAXVA)
    80000ff8:	57fd                	li	a5,-1
    80000ffa:	83e9                	srli	a5,a5,0x1a
    80000ffc:	00b7f463          	bgeu	a5,a1,80001004 <walkaddr+0xc>
    return 0;
    80001000:	4501                	li	a0,0
    return 0;
  if ((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001002:	8082                	ret
{
    80001004:	1141                	addi	sp,sp,-16
    80001006:	e406                	sd	ra,8(sp)
    80001008:	e022                	sd	s0,0(sp)
    8000100a:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000100c:	4601                	li	a2,0
    8000100e:	f53ff0ef          	jal	80000f60 <walk>
  if (pte == 0)
    80001012:	c519                	beqz	a0,80001020 <walkaddr+0x28>
  if ((*pte & PTE_V) == 0)
    80001014:	6108                	ld	a0,0(a0)
  if ((*pte & PTE_U) == 0)
    80001016:	01157713          	andi	a4,a0,17
    8000101a:	47c5                	li	a5,17
    8000101c:	00f70763          	beq	a4,a5,8000102a <walkaddr+0x32>
    return 0;
    80001020:	4501                	li	a0,0
}
    80001022:	60a2                	ld	ra,8(sp)
    80001024:	6402                	ld	s0,0(sp)
    80001026:	0141                	addi	sp,sp,16
    80001028:	8082                	ret
  pa = PTE2PA(*pte);
    8000102a:	8129                	srli	a0,a0,0xa
    8000102c:	0532                	slli	a0,a0,0xc
  return pa;
    8000102e:	bfd5                	j	80001022 <walkaddr+0x2a>

0000000080001030 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001030:	715d                	addi	sp,sp,-80
    80001032:	e486                	sd	ra,72(sp)
    80001034:	e0a2                	sd	s0,64(sp)
    80001036:	fc26                	sd	s1,56(sp)
    80001038:	f84a                	sd	s2,48(sp)
    8000103a:	f44e                	sd	s3,40(sp)
    8000103c:	f052                	sd	s4,32(sp)
    8000103e:	ec56                	sd	s5,24(sp)
    80001040:	e85a                	sd	s6,16(sp)
    80001042:	e45e                	sd	s7,8(sp)
    80001044:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if ((va % PGSIZE) != 0)
    80001046:	03459793          	slli	a5,a1,0x34
    8000104a:	e7b1                	bnez	a5,80001096 <mappages+0x66>
    8000104c:	8a2a                	mv	s4,a0
    8000104e:	8aba                	mv	s5,a4
    panic("mappages: va not aligned");

  if ((size % PGSIZE) != 0)
    80001050:	03461793          	slli	a5,a2,0x34
    80001054:	e7b9                	bnez	a5,800010a2 <mappages+0x72>
    panic("mappages: size not aligned");

  if (size == 0)
    80001056:	ce21                	beqz	a2,800010ae <mappages+0x7e>
    panic("mappages: size");

  a = va;
  last = va + size - PGSIZE;
    80001058:	77fd                	lui	a5,0xfffff
    8000105a:	963e                	add	a2,a2,a5
    8000105c:	00b60933          	add	s2,a2,a1
  a = va;
    80001060:	84ae                	mv	s1,a1
  for (;;) {
    if ((pte = walk(pagetable, a, 1)) == 0)
    80001062:	4b05                	li	s6,1
    80001064:	40b689b3          	sub	s3,a3,a1
    if (*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if (a == last)
      break;
    a += PGSIZE;
    80001068:	6b85                	lui	s7,0x1
    if ((pte = walk(pagetable, a, 1)) == 0)
    8000106a:	865a                	mv	a2,s6
    8000106c:	85a6                	mv	a1,s1
    8000106e:	8552                	mv	a0,s4
    80001070:	ef1ff0ef          	jal	80000f60 <walk>
    80001074:	c929                	beqz	a0,800010c6 <mappages+0x96>
    if (*pte & PTE_V)
    80001076:	611c                	ld	a5,0(a0)
    80001078:	8b85                	andi	a5,a5,1
    8000107a:	e3a1                	bnez	a5,800010ba <mappages+0x8a>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000107c:	013487b3          	add	a5,s1,s3
    80001080:	83b1                	srli	a5,a5,0xc
    80001082:	07aa                	slli	a5,a5,0xa
    80001084:	0157e7b3          	or	a5,a5,s5
    80001088:	0017e793          	ori	a5,a5,1
    8000108c:	e11c                	sd	a5,0(a0)
    if (a == last)
    8000108e:	05248863          	beq	s1,s2,800010de <mappages+0xae>
    a += PGSIZE;
    80001092:	94de                	add	s1,s1,s7
    if ((pte = walk(pagetable, a, 1)) == 0)
    80001094:	bfd9                	j	8000106a <mappages+0x3a>
    panic("mappages: va not aligned");
    80001096:	00006517          	auipc	a0,0x6
    8000109a:	02250513          	addi	a0,a0,34 # 800070b8 <etext+0xb8>
    8000109e:	f9cff0ef          	jal	8000083a <panic>
    panic("mappages: size not aligned");
    800010a2:	00006517          	auipc	a0,0x6
    800010a6:	03650513          	addi	a0,a0,54 # 800070d8 <etext+0xd8>
    800010aa:	f90ff0ef          	jal	8000083a <panic>
    panic("mappages: size");
    800010ae:	00006517          	auipc	a0,0x6
    800010b2:	04a50513          	addi	a0,a0,74 # 800070f8 <etext+0xf8>
    800010b6:	f84ff0ef          	jal	8000083a <panic>
      panic("mappages: remap");
    800010ba:	00006517          	auipc	a0,0x6
    800010be:	04e50513          	addi	a0,a0,78 # 80007108 <etext+0x108>
    800010c2:	f78ff0ef          	jal	8000083a <panic>
      return -1;
    800010c6:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800010c8:	60a6                	ld	ra,72(sp)
    800010ca:	6406                	ld	s0,64(sp)
    800010cc:	74e2                	ld	s1,56(sp)
    800010ce:	7942                	ld	s2,48(sp)
    800010d0:	79a2                	ld	s3,40(sp)
    800010d2:	7a02                	ld	s4,32(sp)
    800010d4:	6ae2                	ld	s5,24(sp)
    800010d6:	6b42                	ld	s6,16(sp)
    800010d8:	6ba2                	ld	s7,8(sp)
    800010da:	6161                	addi	sp,sp,80
    800010dc:	8082                	ret
  return 0;
    800010de:	4501                	li	a0,0
    800010e0:	b7e5                	j	800010c8 <mappages+0x98>

00000000800010e2 <kvmmap>:
{
    800010e2:	1141                	addi	sp,sp,-16
    800010e4:	e406                	sd	ra,8(sp)
    800010e6:	e022                	sd	s0,0(sp)
    800010e8:	0800                	addi	s0,sp,16
    800010ea:	87b6                	mv	a5,a3
  if (mappages(kpgtbl, va, sz, pa, perm) != 0)
    800010ec:	86b2                	mv	a3,a2
    800010ee:	863e                	mv	a2,a5
    800010f0:	f41ff0ef          	jal	80001030 <mappages>
    800010f4:	e509                	bnez	a0,800010fe <kvmmap+0x1c>
}
    800010f6:	60a2                	ld	ra,8(sp)
    800010f8:	6402                	ld	s0,0(sp)
    800010fa:	0141                	addi	sp,sp,16
    800010fc:	8082                	ret
    panic("kvmmap");
    800010fe:	00006517          	auipc	a0,0x6
    80001102:	01a50513          	addi	a0,a0,26 # 80007118 <etext+0x118>
    80001106:	f34ff0ef          	jal	8000083a <panic>

000000008000110a <kvmmake>:
{
    8000110a:	1101                	addi	sp,sp,-32
    8000110c:	ec06                	sd	ra,24(sp)
    8000110e:	e822                	sd	s0,16(sp)
    80001110:	e426                	sd	s1,8(sp)
    80001112:	e04a                	sd	s2,0(sp)
    80001114:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t)kalloc();
    80001116:	a29ff0ef          	jal	80000b3e <kalloc>
    8000111a:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000111c:	6605                	lui	a2,0x1
    8000111e:	4581                	li	a1,0
    80001120:	bb5ff0ef          	jal	80000cd4 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001124:	4719                	li	a4,6
    80001126:	6685                	lui	a3,0x1
    80001128:	10000637          	lui	a2,0x10000
    8000112c:	85b2                	mv	a1,a2
    8000112e:	8526                	mv	a0,s1
    80001130:	fb3ff0ef          	jal	800010e2 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001134:	4719                	li	a4,6
    80001136:	6685                	lui	a3,0x1
    80001138:	10001637          	lui	a2,0x10001
    8000113c:	85b2                	mv	a1,a2
    8000113e:	8526                	mv	a0,s1
    80001140:	fa3ff0ef          	jal	800010e2 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    80001144:	4719                	li	a4,6
    80001146:	040006b7          	lui	a3,0x4000
    8000114a:	0c000637          	lui	a2,0xc000
    8000114e:	85b2                	mv	a1,a2
    80001150:	8526                	mv	a0,s1
    80001152:	f91ff0ef          	jal	800010e2 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext - KERNBASE, PTE_R | PTE_X);
    80001156:	00006917          	auipc	s2,0x6
    8000115a:	eaa90913          	addi	s2,s2,-342 # 80007000 <etext>
    8000115e:	4729                	li	a4,10
    80001160:	800006b7          	lui	a3,0x80000
    80001164:	96ca                	add	a3,a3,s2
    80001166:	4605                	li	a2,1
    80001168:	067e                	slli	a2,a2,0x1f
    8000116a:	85b2                	mv	a1,a2
    8000116c:	8526                	mv	a0,s1
    8000116e:	f75ff0ef          	jal	800010e2 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP - (uint64)etext,
    80001172:	4719                	li	a4,6
    80001174:	46c5                	li	a3,17
    80001176:	06ee                	slli	a3,a3,0x1b
    80001178:	412686b3          	sub	a3,a3,s2
    8000117c:	864a                	mv	a2,s2
    8000117e:	85ca                	mv	a1,s2
    80001180:	8526                	mv	a0,s1
    80001182:	f61ff0ef          	jal	800010e2 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001186:	4729                	li	a4,10
    80001188:	6685                	lui	a3,0x1
    8000118a:	00005617          	auipc	a2,0x5
    8000118e:	e7660613          	addi	a2,a2,-394 # 80006000 <_trampoline>
    80001192:	040005b7          	lui	a1,0x4000
    80001196:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001198:	05b2                	slli	a1,a1,0xc
    8000119a:	8526                	mv	a0,s1
    8000119c:	f47ff0ef          	jal	800010e2 <kvmmap>
  proc_mapstacks(kpgtbl);
    800011a0:	8526                	mv	a0,s1
    800011a2:	5bc000ef          	jal	8000175e <proc_mapstacks>
}
    800011a6:	8526                	mv	a0,s1
    800011a8:	60e2                	ld	ra,24(sp)
    800011aa:	6442                	ld	s0,16(sp)
    800011ac:	64a2                	ld	s1,8(sp)
    800011ae:	6902                	ld	s2,0(sp)
    800011b0:	6105                	addi	sp,sp,32
    800011b2:	8082                	ret

00000000800011b4 <kvminit>:
{
    800011b4:	1141                	addi	sp,sp,-16
    800011b6:	e406                	sd	ra,8(sp)
    800011b8:	e022                	sd	s0,0(sp)
    800011ba:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800011bc:	f4fff0ef          	jal	8000110a <kvmmake>
    800011c0:	00006797          	auipc	a5,0x6
    800011c4:	68a7bc23          	sd	a0,1688(a5) # 80007858 <kernel_pagetable>
}
    800011c8:	60a2                	ld	ra,8(sp)
    800011ca:	6402                	ld	s0,0(sp)
    800011cc:	0141                	addi	sp,sp,16
    800011ce:	8082                	ret

00000000800011d0 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800011d0:	1101                	addi	sp,sp,-32
    800011d2:	ec06                	sd	ra,24(sp)
    800011d4:	e822                	sd	s0,16(sp)
    800011d6:	e426                	sd	s1,8(sp)
    800011d8:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t)kalloc();
    800011da:	965ff0ef          	jal	80000b3e <kalloc>
    800011de:	84aa                	mv	s1,a0
  if (pagetable == 0)
    800011e0:	c509                	beqz	a0,800011ea <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800011e2:	6605                	lui	a2,0x1
    800011e4:	4581                	li	a1,0
    800011e6:	aefff0ef          	jal	80000cd4 <memset>
  return pagetable;
}
    800011ea:	8526                	mv	a0,s1
    800011ec:	60e2                	ld	ra,24(sp)
    800011ee:	6442                	ld	s0,16(sp)
    800011f0:	64a2                	ld	s1,8(sp)
    800011f2:	6105                	addi	sp,sp,32
    800011f4:	8082                	ret

00000000800011f6 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800011f6:	7139                	addi	sp,sp,-64
    800011f8:	fc06                	sd	ra,56(sp)
    800011fa:	f822                	sd	s0,48(sp)
    800011fc:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if ((va % PGSIZE) != 0)
    800011fe:	03459793          	slli	a5,a1,0x34
    80001202:	e38d                	bnez	a5,80001224 <uvmunmap+0x2e>
    80001204:	f04a                	sd	s2,32(sp)
    80001206:	ec4e                	sd	s3,24(sp)
    80001208:	e852                	sd	s4,16(sp)
    8000120a:	e456                	sd	s5,8(sp)
    8000120c:	e05a                	sd	s6,0(sp)
    8000120e:	8a2a                	mv	s4,a0
    80001210:	892e                	mv	s2,a1
    80001212:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for (a = va; a < va + npages * PGSIZE; a += PGSIZE) {
    80001214:	0632                	slli	a2,a2,0xc
    80001216:	00b609b3          	add	s3,a2,a1
    8000121a:	6b05                	lui	s6,0x1
    8000121c:	0535f963          	bgeu	a1,s3,8000126e <uvmunmap+0x78>
    80001220:	f426                	sd	s1,40(sp)
    80001222:	a015                	j	80001246 <uvmunmap+0x50>
    80001224:	f426                	sd	s1,40(sp)
    80001226:	f04a                	sd	s2,32(sp)
    80001228:	ec4e                	sd	s3,24(sp)
    8000122a:	e852                	sd	s4,16(sp)
    8000122c:	e456                	sd	s5,8(sp)
    8000122e:	e05a                	sd	s6,0(sp)
    panic("uvmunmap: not aligned");
    80001230:	00006517          	auipc	a0,0x6
    80001234:	ef050513          	addi	a0,a0,-272 # 80007120 <etext+0x120>
    80001238:	e02ff0ef          	jal	8000083a <panic>
      continue;
    if (do_free) {
      uint64 pa = PTE2PA(*pte);
      kfree((void *)pa);
    }
    *pte = 0;
    8000123c:	0004b023          	sd	zero,0(s1)
  for (a = va; a < va + npages * PGSIZE; a += PGSIZE) {
    80001240:	995a                	add	s2,s2,s6
    80001242:	03397563          	bgeu	s2,s3,8000126c <uvmunmap+0x76>
    if ((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    80001246:	4601                	li	a2,0
    80001248:	85ca                	mv	a1,s2
    8000124a:	8552                	mv	a0,s4
    8000124c:	d15ff0ef          	jal	80000f60 <walk>
    80001250:	84aa                	mv	s1,a0
    80001252:	d57d                	beqz	a0,80001240 <uvmunmap+0x4a>
    if ((*pte & PTE_V) == 0) // has physical page been allocated?
    80001254:	611c                	ld	a5,0(a0)
    80001256:	0017f713          	andi	a4,a5,1
    8000125a:	d37d                	beqz	a4,80001240 <uvmunmap+0x4a>
    if (do_free) {
    8000125c:	fe0a80e3          	beqz	s5,8000123c <uvmunmap+0x46>
      uint64 pa = PTE2PA(*pte);
    80001260:	83a9                	srli	a5,a5,0xa
      kfree((void *)pa);
    80001262:	00c79513          	slli	a0,a5,0xc
    80001266:	ff0ff0ef          	jal	80000a56 <kfree>
    8000126a:	bfc9                	j	8000123c <uvmunmap+0x46>
    8000126c:	74a2                	ld	s1,40(sp)
    8000126e:	7902                	ld	s2,32(sp)
    80001270:	69e2                	ld	s3,24(sp)
    80001272:	6a42                	ld	s4,16(sp)
    80001274:	6aa2                	ld	s5,8(sp)
    80001276:	6b02                	ld	s6,0(sp)
  }
}
    80001278:	70e2                	ld	ra,56(sp)
    8000127a:	7442                	ld	s0,48(sp)
    8000127c:	6121                	addi	sp,sp,64
    8000127e:	8082                	ret

0000000080001280 <uvmdealloc>:
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
  if (newsz >= oldsz)
    80001280:	04b67163          	bgeu	a2,a1,800012c2 <uvmdealloc+0x42>
{
    80001284:	1101                	addi	sp,sp,-32
    80001286:	ec06                	sd	ra,24(sp)
    80001288:	e822                	sd	s0,16(sp)
    8000128a:	e426                	sd	s1,8(sp)
    8000128c:	1000                	addi	s0,sp,32
    8000128e:	84b2                	mv	s1,a2
    return oldsz;

  if (PGROUNDUP(newsz) < PGROUNDUP(oldsz)) {
    80001290:	6785                	lui	a5,0x1
    80001292:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001294:	00f60733          	add	a4,a2,a5
    80001298:	76fd                	lui	a3,0xfffff
    8000129a:	8f75                	and	a4,a4,a3
    8000129c:	97ae                	add	a5,a5,a1
    8000129e:	8ff5                	and	a5,a5,a3
    800012a0:	00f76863          	bltu	a4,a5,800012b0 <uvmdealloc+0x30>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
    800012a4:	8526                	mv	a0,s1
}
    800012a6:	60e2                	ld	ra,24(sp)
    800012a8:	6442                	ld	s0,16(sp)
    800012aa:	64a2                	ld	s1,8(sp)
    800012ac:	6105                	addi	sp,sp,32
    800012ae:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800012b0:	8f99                	sub	a5,a5,a4
    800012b2:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800012b4:	4685                	li	a3,1
    800012b6:	0007861b          	sext.w	a2,a5
    800012ba:	85ba                	mv	a1,a4
    800012bc:	f3bff0ef          	jal	800011f6 <uvmunmap>
    800012c0:	b7d5                	j	800012a4 <uvmdealloc+0x24>
    return oldsz;
    800012c2:	852e                	mv	a0,a1
}
    800012c4:	8082                	ret

00000000800012c6 <uvmalloc>:
  if (newsz < oldsz)
    800012c6:	08b66e63          	bltu	a2,a1,80001362 <uvmalloc+0x9c>
{
    800012ca:	715d                	addi	sp,sp,-80
    800012cc:	e486                	sd	ra,72(sp)
    800012ce:	e0a2                	sd	s0,64(sp)
    800012d0:	f052                	sd	s4,32(sp)
    800012d2:	ec56                	sd	s5,24(sp)
    800012d4:	e45e                	sd	s7,8(sp)
    800012d6:	0880                	addi	s0,sp,80
    800012d8:	8aaa                	mv	s5,a0
    800012da:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800012dc:	6785                	lui	a5,0x1
    800012de:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800012e0:	95be                	add	a1,a1,a5
    800012e2:	77fd                	lui	a5,0xfffff
    800012e4:	8fed                	and	a5,a5,a1
    800012e6:	8bbe                	mv	s7,a5
  for (a = oldsz; a < newsz; a += PGSIZE) {
    800012e8:	04c7f163          	bgeu	a5,a2,8000132a <uvmalloc+0x64>
    800012ec:	fc26                	sd	s1,56(sp)
    800012ee:	f84a                	sd	s2,48(sp)
    800012f0:	f44e                	sd	s3,40(sp)
    800012f2:	e85a                	sd	s6,16(sp)
    800012f4:	893e                	mv	s2,a5
    memset(mem, 0, PGSIZE);
    800012f6:	6985                	lui	s3,0x1
    if (mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R | PTE_U | xperm) !=
    800012f8:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    800012fc:	843ff0ef          	jal	80000b3e <kalloc>
    80001300:	84aa                	mv	s1,a0
    if (mem == 0) {
    80001302:	c515                	beqz	a0,8000132e <uvmalloc+0x68>
    memset(mem, 0, PGSIZE);
    80001304:	864e                	mv	a2,s3
    80001306:	4581                	li	a1,0
    80001308:	9cdff0ef          	jal	80000cd4 <memset>
    if (mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R | PTE_U | xperm) !=
    8000130c:	875a                	mv	a4,s6
    8000130e:	86a6                	mv	a3,s1
    80001310:	864e                	mv	a2,s3
    80001312:	85ca                	mv	a1,s2
    80001314:	8556                	mv	a0,s5
    80001316:	d1bff0ef          	jal	80001030 <mappages>
    8000131a:	e91d                	bnez	a0,80001350 <uvmalloc+0x8a>
  for (a = oldsz; a < newsz; a += PGSIZE) {
    8000131c:	994e                	add	s2,s2,s3
    8000131e:	fd496fe3          	bltu	s2,s4,800012fc <uvmalloc+0x36>
    80001322:	74e2                	ld	s1,56(sp)
    80001324:	7942                	ld	s2,48(sp)
    80001326:	79a2                	ld	s3,40(sp)
    80001328:	6b42                	ld	s6,16(sp)
  return newsz;
    8000132a:	8552                	mv	a0,s4
    8000132c:	a819                	j	80001342 <uvmalloc+0x7c>
      uvmdealloc(pagetable, a, oldsz);
    8000132e:	865e                	mv	a2,s7
    80001330:	85ca                	mv	a1,s2
    80001332:	8556                	mv	a0,s5
    80001334:	f4dff0ef          	jal	80001280 <uvmdealloc>
      return 0;
    80001338:	4501                	li	a0,0
    8000133a:	74e2                	ld	s1,56(sp)
    8000133c:	7942                	ld	s2,48(sp)
    8000133e:	79a2                	ld	s3,40(sp)
    80001340:	6b42                	ld	s6,16(sp)
}
    80001342:	60a6                	ld	ra,72(sp)
    80001344:	6406                	ld	s0,64(sp)
    80001346:	7a02                	ld	s4,32(sp)
    80001348:	6ae2                	ld	s5,24(sp)
    8000134a:	6ba2                	ld	s7,8(sp)
    8000134c:	6161                	addi	sp,sp,80
    8000134e:	8082                	ret
      kfree(mem);
    80001350:	8526                	mv	a0,s1
    80001352:	f04ff0ef          	jal	80000a56 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001356:	865e                	mv	a2,s7
    80001358:	85ca                	mv	a1,s2
    8000135a:	8556                	mv	a0,s5
    8000135c:	f25ff0ef          	jal	80001280 <uvmdealloc>
      return 0;
    80001360:	bfe1                	j	80001338 <uvmalloc+0x72>
    return oldsz;
    80001362:	852e                	mv	a0,a1
}
    80001364:	8082                	ret

0000000080001366 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001366:	7179                	addi	sp,sp,-48
    80001368:	f406                	sd	ra,40(sp)
    8000136a:	f022                	sd	s0,32(sp)
    8000136c:	ec26                	sd	s1,24(sp)
    8000136e:	e84a                	sd	s2,16(sp)
    80001370:	e44e                	sd	s3,8(sp)
    80001372:	1800                	addi	s0,sp,48
    80001374:	89aa                	mv	s3,a0
  // there are 2^9 = 512 PTEs in a page table.
  for (int i = 0; i < 512; i++) {
    80001376:	84aa                	mv	s1,a0
    80001378:	6905                	lui	s2,0x1
    8000137a:	992a                	add	s2,s2,a0
    8000137c:	a811                	j	80001390 <freewalk+0x2a>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
      freewalk((pagetable_t)child);
      pagetable[i] = 0;
    } else if (pte & PTE_V) {
      panic("freewalk: leaf");
    8000137e:	00006517          	auipc	a0,0x6
    80001382:	dba50513          	addi	a0,a0,-582 # 80007138 <etext+0x138>
    80001386:	cb4ff0ef          	jal	8000083a <panic>
  for (int i = 0; i < 512; i++) {
    8000138a:	04a1                	addi	s1,s1,8
    8000138c:	03248163          	beq	s1,s2,800013ae <freewalk+0x48>
    pte_t pte = pagetable[i];
    80001390:	609c                	ld	a5,0(s1)
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
    80001392:	0017f713          	andi	a4,a5,1
    80001396:	db75                	beqz	a4,8000138a <freewalk+0x24>
    80001398:	00e7f713          	andi	a4,a5,14
    8000139c:	f36d                	bnez	a4,8000137e <freewalk+0x18>
      uint64 child = PTE2PA(pte);
    8000139e:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800013a0:	00c79513          	slli	a0,a5,0xc
    800013a4:	fc3ff0ef          	jal	80001366 <freewalk>
      pagetable[i] = 0;
    800013a8:	0004b023          	sd	zero,0(s1)
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
    800013ac:	bff9                	j	8000138a <freewalk+0x24>
    }
  }
  kfree((void *)pagetable);
    800013ae:	854e                	mv	a0,s3
    800013b0:	ea6ff0ef          	jal	80000a56 <kfree>
}
    800013b4:	70a2                	ld	ra,40(sp)
    800013b6:	7402                	ld	s0,32(sp)
    800013b8:	64e2                	ld	s1,24(sp)
    800013ba:	6942                	ld	s2,16(sp)
    800013bc:	69a2                	ld	s3,8(sp)
    800013be:	6145                	addi	sp,sp,48
    800013c0:	8082                	ret

00000000800013c2 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800013c2:	1101                	addi	sp,sp,-32
    800013c4:	ec06                	sd	ra,24(sp)
    800013c6:	e822                	sd	s0,16(sp)
    800013c8:	e426                	sd	s1,8(sp)
    800013ca:	1000                	addi	s0,sp,32
    800013cc:	84aa                	mv	s1,a0
  if (sz > 0)
    800013ce:	e989                	bnez	a1,800013e0 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
  freewalk(pagetable);
    800013d0:	8526                	mv	a0,s1
    800013d2:	f95ff0ef          	jal	80001366 <freewalk>
}
    800013d6:	60e2                	ld	ra,24(sp)
    800013d8:	6442                	ld	s0,16(sp)
    800013da:	64a2                	ld	s1,8(sp)
    800013dc:	6105                	addi	sp,sp,32
    800013de:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
    800013e0:	6785                	lui	a5,0x1
    800013e2:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013e4:	95be                	add	a1,a1,a5
    800013e6:	4685                	li	a3,1
    800013e8:	00c5d613          	srli	a2,a1,0xc
    800013ec:	4581                	li	a1,0
    800013ee:	e09ff0ef          	jal	800011f6 <uvmunmap>
    800013f2:	bff9                	j	800013d0 <uvmfree+0xe>

00000000800013f4 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for (i = 0; i < sz; i += PGSIZE) {
    800013f4:	ca59                	beqz	a2,8000148a <uvmcopy+0x96>
{
    800013f6:	715d                	addi	sp,sp,-80
    800013f8:	e486                	sd	ra,72(sp)
    800013fa:	e0a2                	sd	s0,64(sp)
    800013fc:	fc26                	sd	s1,56(sp)
    800013fe:	f84a                	sd	s2,48(sp)
    80001400:	f44e                	sd	s3,40(sp)
    80001402:	f052                	sd	s4,32(sp)
    80001404:	ec56                	sd	s5,24(sp)
    80001406:	e85a                	sd	s6,16(sp)
    80001408:	e45e                	sd	s7,8(sp)
    8000140a:	0880                	addi	s0,sp,80
    8000140c:	8b2a                	mv	s6,a0
    8000140e:	8bae                	mv	s7,a1
    80001410:	8ab2                	mv	s5,a2
  for (i = 0; i < sz; i += PGSIZE) {
    80001412:	4481                	li	s1,0
      continue; // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);
    if ((mem = kalloc()) == 0)
      goto err;
    memmove(mem, (char *)pa, PGSIZE);
    80001414:	6a05                	lui	s4,0x1
    80001416:	a021                	j	8000141e <uvmcopy+0x2a>
  for (i = 0; i < sz; i += PGSIZE) {
    80001418:	94d2                	add	s1,s1,s4
    8000141a:	0554fc63          	bgeu	s1,s5,80001472 <uvmcopy+0x7e>
    if ((pte = walk(old, i, 0)) == 0)
    8000141e:	4601                	li	a2,0
    80001420:	85a6                	mv	a1,s1
    80001422:	855a                	mv	a0,s6
    80001424:	b3dff0ef          	jal	80000f60 <walk>
    80001428:	d965                	beqz	a0,80001418 <uvmcopy+0x24>
    if ((*pte & PTE_V) == 0)
    8000142a:	00053983          	ld	s3,0(a0)
    8000142e:	0019f793          	andi	a5,s3,1
    80001432:	d3fd                	beqz	a5,80001418 <uvmcopy+0x24>
    if ((mem = kalloc()) == 0)
    80001434:	f0aff0ef          	jal	80000b3e <kalloc>
    80001438:	892a                	mv	s2,a0
    8000143a:	c11d                	beqz	a0,80001460 <uvmcopy+0x6c>
    pa = PTE2PA(*pte);
    8000143c:	00a9d593          	srli	a1,s3,0xa
    memmove(mem, (char *)pa, PGSIZE);
    80001440:	8652                	mv	a2,s4
    80001442:	05b2                	slli	a1,a1,0xc
    80001444:	8edff0ef          	jal	80000d30 <memmove>
    if (mappages(new, i, PGSIZE, (uint64)mem, flags) != 0) {
    80001448:	3ff9f713          	andi	a4,s3,1023
    8000144c:	86ca                	mv	a3,s2
    8000144e:	8652                	mv	a2,s4
    80001450:	85a6                	mv	a1,s1
    80001452:	855e                	mv	a0,s7
    80001454:	bddff0ef          	jal	80001030 <mappages>
    80001458:	d161                	beqz	a0,80001418 <uvmcopy+0x24>
      kfree(mem);
    8000145a:	854a                	mv	a0,s2
    8000145c:	dfaff0ef          	jal	80000a56 <kfree>
    }
  }
  return 0;

err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001460:	4685                	li	a3,1
    80001462:	00c4d613          	srli	a2,s1,0xc
    80001466:	4581                	li	a1,0
    80001468:	855e                	mv	a0,s7
    8000146a:	d8dff0ef          	jal	800011f6 <uvmunmap>
  return -1;
    8000146e:	557d                	li	a0,-1
    80001470:	a011                	j	80001474 <uvmcopy+0x80>
  return 0;
    80001472:	4501                	li	a0,0
}
    80001474:	60a6                	ld	ra,72(sp)
    80001476:	6406                	ld	s0,64(sp)
    80001478:	74e2                	ld	s1,56(sp)
    8000147a:	7942                	ld	s2,48(sp)
    8000147c:	79a2                	ld	s3,40(sp)
    8000147e:	7a02                	ld	s4,32(sp)
    80001480:	6ae2                	ld	s5,24(sp)
    80001482:	6b42                	ld	s6,16(sp)
    80001484:	6ba2                	ld	s7,8(sp)
    80001486:	6161                	addi	sp,sp,80
    80001488:	8082                	ret
  return 0;
    8000148a:	4501                	li	a0,0
}
    8000148c:	8082                	ret

000000008000148e <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000148e:	1141                	addi	sp,sp,-16
    80001490:	e406                	sd	ra,8(sp)
    80001492:	e022                	sd	s0,0(sp)
    80001494:	0800                	addi	s0,sp,16
  pte_t *pte;

  pte = walk(pagetable, va, 0);
    80001496:	4601                	li	a2,0
    80001498:	ac9ff0ef          	jal	80000f60 <walk>
  if (pte == 0)
    8000149c:	c901                	beqz	a0,800014ac <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000149e:	611c                	ld	a5,0(a0)
    800014a0:	9bbd                	andi	a5,a5,-17
    800014a2:	e11c                	sd	a5,0(a0)
}
    800014a4:	60a2                	ld	ra,8(sp)
    800014a6:	6402                	ld	s0,0(sp)
    800014a8:	0141                	addi	sp,sp,16
    800014aa:	8082                	ret
    panic("uvmclear");
    800014ac:	00006517          	auipc	a0,0x6
    800014b0:	c9c50513          	addi	a0,a0,-868 # 80007148 <etext+0x148>
    800014b4:	b86ff0ef          	jal	8000083a <panic>

00000000800014b8 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while (got_null == 0 && max > 0) {
    800014b8:	cac5                	beqz	a3,80001568 <copyinstr+0xb0>
{
    800014ba:	715d                	addi	sp,sp,-80
    800014bc:	e486                	sd	ra,72(sp)
    800014be:	e0a2                	sd	s0,64(sp)
    800014c0:	fc26                	sd	s1,56(sp)
    800014c2:	f84a                	sd	s2,48(sp)
    800014c4:	f44e                	sd	s3,40(sp)
    800014c6:	f052                	sd	s4,32(sp)
    800014c8:	ec56                	sd	s5,24(sp)
    800014ca:	e85a                	sd	s6,16(sp)
    800014cc:	e45e                	sd	s7,8(sp)
    800014ce:	0880                	addi	s0,sp,80
    800014d0:	8aaa                	mv	s5,a0
    800014d2:	84ae                	mv	s1,a1
    800014d4:	8bb2                	mv	s7,a2
    800014d6:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800014d8:	7b7d                	lui	s6,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if (pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800014da:	6a05                	lui	s4,0x1
    800014dc:	a82d                	j	80001516 <copyinstr+0x5e>
      n = max;

    char *p = (char *)(pa0 + (srcva - va0));
    while (n > 0) {
      if (*p == '\0') {
        *dst = '\0';
    800014de:	00078023          	sb	zero,0(a5)
        got_null = 1;
    800014e2:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if (got_null) {
    800014e4:	0017c793          	xori	a5,a5,1
    800014e8:	40f0053b          	negw	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800014ec:	60a6                	ld	ra,72(sp)
    800014ee:	6406                	ld	s0,64(sp)
    800014f0:	74e2                	ld	s1,56(sp)
    800014f2:	7942                	ld	s2,48(sp)
    800014f4:	79a2                	ld	s3,40(sp)
    800014f6:	7a02                	ld	s4,32(sp)
    800014f8:	6ae2                	ld	s5,24(sp)
    800014fa:	6b42                	ld	s6,16(sp)
    800014fc:	6ba2                	ld	s7,8(sp)
    800014fe:	6161                	addi	sp,sp,80
    80001500:	8082                	ret
    80001502:	fff98713          	addi	a4,s3,-1 # fff <_entry-0x7ffff001>
    80001506:	9726                	add	a4,a4,s1
      --max;
    80001508:	40b709b3          	sub	s3,a4,a1
    srcva = va0 + PGSIZE;
    8000150c:	01490bb3          	add	s7,s2,s4
  while (got_null == 0 && max > 0) {
    80001510:	04e58463          	beq	a1,a4,80001558 <copyinstr+0xa0>
{
    80001514:	84be                	mv	s1,a5
    va0 = PGROUNDDOWN(srcva);
    80001516:	016bf933          	and	s2,s7,s6
    pa0 = walkaddr(pagetable, va0);
    8000151a:	85ca                	mv	a1,s2
    8000151c:	8556                	mv	a0,s5
    8000151e:	adbff0ef          	jal	80000ff8 <walkaddr>
    if (pa0 == 0)
    80001522:	cd0d                	beqz	a0,8000155c <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80001524:	41790633          	sub	a2,s2,s7
    80001528:	9652                	add	a2,a2,s4
    if (n > max)
    8000152a:	00c9f363          	bgeu	s3,a2,80001530 <copyinstr+0x78>
    8000152e:	864e                	mv	a2,s3
    while (n > 0) {
    80001530:	ca05                	beqz	a2,80001560 <copyinstr+0xa8>
    char *p = (char *)(pa0 + (srcva - va0));
    80001532:	034b9693          	slli	a3,s7,0x34
    80001536:	92d1                	srli	a3,a3,0x34
    80001538:	96aa                	add	a3,a3,a0
    8000153a:	87a6                	mv	a5,s1
      if (*p == '\0') {
    8000153c:	8e85                	sub	a3,a3,s1
    while (n > 0) {
    8000153e:	9626                	add	a2,a2,s1
    80001540:	85be                	mv	a1,a5
      if (*p == '\0') {
    80001542:	00f68733          	add	a4,a3,a5
    80001546:	00074703          	lbu	a4,0(a4)
    8000154a:	db51                	beqz	a4,800014de <copyinstr+0x26>
        *dst = *p;
    8000154c:	00e78023          	sb	a4,0(a5)
      dst++;
    80001550:	0785                	addi	a5,a5,1
    while (n > 0) {
    80001552:	fec797e3          	bne	a5,a2,80001540 <copyinstr+0x88>
    80001556:	b775                	j	80001502 <copyinstr+0x4a>
    srcva = va0 + PGSIZE;
    80001558:	4781                	li	a5,0
    8000155a:	b769                	j	800014e4 <copyinstr+0x2c>
      return -1;
    8000155c:	557d                	li	a0,-1
    8000155e:	b779                	j	800014ec <copyinstr+0x34>
    srcva = va0 + PGSIZE;
    80001560:	6b85                	lui	s7,0x1
    80001562:	9bca                	add	s7,s7,s2
    80001564:	87a6                	mv	a5,s1
    80001566:	b77d                	j	80001514 <copyinstr+0x5c>
    80001568:	4781                	li	a5,0
  if (got_null) {
    8000156a:	0017c793          	xori	a5,a5,1
    8000156e:	40f0053b          	negw	a0,a5
}
    80001572:	8082                	ret

0000000080001574 <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    80001574:	1141                	addi	sp,sp,-16
    80001576:	e406                	sd	ra,8(sp)
    80001578:	e022                	sd	s0,0(sp)
    8000157a:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    8000157c:	4601                	li	a2,0
    8000157e:	9e3ff0ef          	jal	80000f60 <walk>
  if (pte == 0) {
    80001582:	c119                	beqz	a0,80001588 <ismapped+0x14>
    return 0;
  }
  if (*pte & PTE_V) {
    80001584:	6108                	ld	a0,0(a0)
    80001586:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    80001588:	60a2                	ld	ra,8(sp)
    8000158a:	6402                	ld	s0,0(sp)
    8000158c:	0141                	addi	sp,sp,16
    8000158e:	8082                	ret

0000000080001590 <vmfault>:
{
    80001590:	7179                	addi	sp,sp,-48
    80001592:	f406                	sd	ra,40(sp)
    80001594:	f022                	sd	s0,32(sp)
    80001596:	e84a                	sd	s2,16(sp)
    80001598:	e052                	sd	s4,0(sp)
    8000159a:	1800                	addi	s0,sp,48
    8000159c:	8a2a                	mv	s4,a0
    8000159e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800015a0:	33e000ef          	jal	800018de <myproc>
  if (va >= p->sz)
    800015a4:	653c                	ld	a5,72(a0)
    800015a6:	00f96d63          	bltu	s2,a5,800015c0 <vmfault+0x30>
    return 0;
    800015aa:	4a01                	li	s4,0
}
    800015ac:	8552                	mv	a0,s4
    800015ae:	70a2                	ld	ra,40(sp)
    800015b0:	7402                	ld	s0,32(sp)
    800015b2:	6942                	ld	s2,16(sp)
    800015b4:	6a02                	ld	s4,0(sp)
    800015b6:	6145                	addi	sp,sp,48
    800015b8:	8082                	ret
    800015ba:	64e2                	ld	s1,24(sp)
    800015bc:	69a2                	ld	s3,8(sp)
    800015be:	b7f5                	j	800015aa <vmfault+0x1a>
    800015c0:	ec26                	sd	s1,24(sp)
    800015c2:	e44e                	sd	s3,8(sp)
    800015c4:	84aa                	mv	s1,a0
  va = PGROUNDDOWN(va);
    800015c6:	77fd                	lui	a5,0xfffff
    800015c8:	00f979b3          	and	s3,s2,a5
  if (ismapped(pagetable, va)) {
    800015cc:	85ce                	mv	a1,s3
    800015ce:	8552                	mv	a0,s4
    800015d0:	fa5ff0ef          	jal	80001574 <ismapped>
    800015d4:	c501                	beqz	a0,800015dc <vmfault+0x4c>
    800015d6:	64e2                	ld	s1,24(sp)
    800015d8:	69a2                	ld	s3,8(sp)
    800015da:	bfc1                	j	800015aa <vmfault+0x1a>
  mem = (uint64)kalloc();
    800015dc:	d62ff0ef          	jal	80000b3e <kalloc>
    800015e0:	892a                	mv	s2,a0
  if (mem == 0)
    800015e2:	dd61                	beqz	a0,800015ba <vmfault+0x2a>
  mem = (uint64)kalloc();
    800015e4:	8a2a                	mv	s4,a0
  memset((void *)mem, 0, PGSIZE);
    800015e6:	6605                	lui	a2,0x1
    800015e8:	4581                	li	a1,0
    800015ea:	eeaff0ef          	jal	80000cd4 <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W | PTE_U | PTE_R) != 0) {
    800015ee:	4759                	li	a4,22
    800015f0:	86ca                	mv	a3,s2
    800015f2:	6605                	lui	a2,0x1
    800015f4:	85ce                	mv	a1,s3
    800015f6:	68a8                	ld	a0,80(s1)
    800015f8:	a39ff0ef          	jal	80001030 <mappages>
    800015fc:	e501                	bnez	a0,80001604 <vmfault+0x74>
    800015fe:	64e2                	ld	s1,24(sp)
    80001600:	69a2                	ld	s3,8(sp)
    80001602:	b76d                	j	800015ac <vmfault+0x1c>
    kfree((void *)mem);
    80001604:	854a                	mv	a0,s2
    80001606:	c50ff0ef          	jal	80000a56 <kfree>
    return 0;
    8000160a:	64e2                	ld	s1,24(sp)
    8000160c:	69a2                	ld	s3,8(sp)
    8000160e:	bf71                	j	800015aa <vmfault+0x1a>

0000000080001610 <copyout>:
  while (len > 0) {
    80001610:	cad5                	beqz	a3,800016c4 <copyout+0xb4>
{
    80001612:	711d                	addi	sp,sp,-96
    80001614:	ec86                	sd	ra,88(sp)
    80001616:	e8a2                	sd	s0,80(sp)
    80001618:	e4a6                	sd	s1,72(sp)
    8000161a:	e0ca                	sd	s2,64(sp)
    8000161c:	fc4e                	sd	s3,56(sp)
    8000161e:	f852                	sd	s4,48(sp)
    80001620:	f456                	sd	s5,40(sp)
    80001622:	f05a                	sd	s6,32(sp)
    80001624:	ec5e                	sd	s7,24(sp)
    80001626:	e862                	sd	s8,16(sp)
    80001628:	e466                	sd	s9,8(sp)
    8000162a:	e06a                	sd	s10,0(sp)
    8000162c:	1080                	addi	s0,sp,96
    8000162e:	8baa                	mv	s7,a0
    80001630:	84ae                	mv	s1,a1
    80001632:	8b32                	mv	s6,a2
    80001634:	8ab6                	mv	s5,a3
    va0 = PGROUNDDOWN(dstva);
    80001636:	7d7d                	lui	s10,0xfffff
    if (va0 >= MAXVA)
    80001638:	5cfd                	li	s9,-1
    8000163a:	01acdc93          	srli	s9,s9,0x1a
    n = PGSIZE - (dstva - va0);
    8000163e:	6c05                	lui	s8,0x1
    80001640:	a081                	j	80001680 <copyout+0x70>
      return -1;
    80001642:	557d                	li	a0,-1
}
    80001644:	60e6                	ld	ra,88(sp)
    80001646:	6446                	ld	s0,80(sp)
    80001648:	64a6                	ld	s1,72(sp)
    8000164a:	6906                	ld	s2,64(sp)
    8000164c:	79e2                	ld	s3,56(sp)
    8000164e:	7a42                	ld	s4,48(sp)
    80001650:	7aa2                	ld	s5,40(sp)
    80001652:	7b02                	ld	s6,32(sp)
    80001654:	6be2                	ld	s7,24(sp)
    80001656:	6c42                	ld	s8,16(sp)
    80001658:	6ca2                	ld	s9,8(sp)
    8000165a:	6d02                	ld	s10,0(sp)
    8000165c:	6125                	addi	sp,sp,96
    8000165e:	8082                	ret
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001660:	03449513          	slli	a0,s1,0x34
    80001664:	9151                	srli	a0,a0,0x34
    80001666:	0009061b          	sext.w	a2,s2
    8000166a:	85da                	mv	a1,s6
    8000166c:	954e                	add	a0,a0,s3
    8000166e:	ec2ff0ef          	jal	80000d30 <memmove>
    len -= n;
    80001672:	412a8ab3          	sub	s5,s5,s2
    src += n;
    80001676:	9b4a                	add	s6,s6,s2
    dstva = va0 + PGSIZE;
    80001678:	018a04b3          	add	s1,s4,s8
  while (len > 0) {
    8000167c:	040a8263          	beqz	s5,800016c0 <copyout+0xb0>
    va0 = PGROUNDDOWN(dstva);
    80001680:	01a4fa33          	and	s4,s1,s10
    if (va0 >= MAXVA)
    80001684:	fb4cefe3          	bltu	s9,s4,80001642 <copyout+0x32>
    pa0 = walkaddr(pagetable, va0);
    80001688:	85d2                	mv	a1,s4
    8000168a:	855e                	mv	a0,s7
    8000168c:	96dff0ef          	jal	80000ff8 <walkaddr>
    80001690:	89aa                	mv	s3,a0
    if (pa0 == 0) {
    80001692:	e901                	bnez	a0,800016a2 <copyout+0x92>
      if ((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001694:	4601                	li	a2,0
    80001696:	85d2                	mv	a1,s4
    80001698:	855e                	mv	a0,s7
    8000169a:	ef7ff0ef          	jal	80001590 <vmfault>
    8000169e:	89aa                	mv	s3,a0
    800016a0:	d14d                	beqz	a0,80001642 <copyout+0x32>
    pte = walk(pagetable, va0, 0);
    800016a2:	4601                	li	a2,0
    800016a4:	85d2                	mv	a1,s4
    800016a6:	855e                	mv	a0,s7
    800016a8:	8b9ff0ef          	jal	80000f60 <walk>
    if ((*pte & PTE_W) == 0)
    800016ac:	611c                	ld	a5,0(a0)
    800016ae:	8b91                	andi	a5,a5,4
    800016b0:	dbc9                	beqz	a5,80001642 <copyout+0x32>
    n = PGSIZE - (dstva - va0);
    800016b2:	409a0933          	sub	s2,s4,s1
    800016b6:	9962                	add	s2,s2,s8
    if (n > len)
    800016b8:	fb2af4e3          	bgeu	s5,s2,80001660 <copyout+0x50>
    800016bc:	8956                	mv	s2,s5
    800016be:	b74d                	j	80001660 <copyout+0x50>
  return 0;
    800016c0:	4501                	li	a0,0
    800016c2:	b749                	j	80001644 <copyout+0x34>
    800016c4:	4501                	li	a0,0
}
    800016c6:	8082                	ret

00000000800016c8 <copyin>:
  while (len > 0) {
    800016c8:	cac9                	beqz	a3,8000175a <copyin+0x92>
{
    800016ca:	711d                	addi	sp,sp,-96
    800016cc:	ec86                	sd	ra,88(sp)
    800016ce:	e8a2                	sd	s0,80(sp)
    800016d0:	e4a6                	sd	s1,72(sp)
    800016d2:	e0ca                	sd	s2,64(sp)
    800016d4:	fc4e                	sd	s3,56(sp)
    800016d6:	f852                	sd	s4,48(sp)
    800016d8:	f456                	sd	s5,40(sp)
    800016da:	f05a                	sd	s6,32(sp)
    800016dc:	ec5e                	sd	s7,24(sp)
    800016de:	e862                	sd	s8,16(sp)
    800016e0:	e466                	sd	s9,8(sp)
    800016e2:	1080                	addi	s0,sp,96
    800016e4:	8baa                	mv	s7,a0
    800016e6:	8aae                	mv	s5,a1
    800016e8:	84b2                	mv	s1,a2
    800016ea:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800016ec:	7c7d                	lui	s8,0xfffff
      if ((pa0 = vmfault(pagetable, va0, 1)) == 0) {
    800016ee:	4c85                	li	s9,1
    n = PGSIZE - (srcva - va0);
    800016f0:	6b05                	lui	s6,0x1
    800016f2:	a03d                	j	80001720 <copyin+0x58>
    800016f4:	409a0933          	sub	s2,s4,s1
    800016f8:	995a                	add	s2,s2,s6
    if (n > len)
    800016fa:	0129f363          	bgeu	s3,s2,80001700 <copyin+0x38>
    800016fe:	894e                	mv	s2,s3
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001700:	03449593          	slli	a1,s1,0x34
    80001704:	91d1                	srli	a1,a1,0x34
    80001706:	0009061b          	sext.w	a2,s2
    8000170a:	95aa                	add	a1,a1,a0
    8000170c:	8556                	mv	a0,s5
    8000170e:	e22ff0ef          	jal	80000d30 <memmove>
    len -= n;
    80001712:	412989b3          	sub	s3,s3,s2
    dst += n;
    80001716:	9aca                	add	s5,s5,s2
    srcva = va0 + PGSIZE;
    80001718:	016a04b3          	add	s1,s4,s6
  while (len > 0) {
    8000171c:	02098163          	beqz	s3,8000173e <copyin+0x76>
    va0 = PGROUNDDOWN(srcva);
    80001720:	0184fa33          	and	s4,s1,s8
    pa0 = walkaddr(pagetable, va0);
    80001724:	85d2                	mv	a1,s4
    80001726:	855e                	mv	a0,s7
    80001728:	8d1ff0ef          	jal	80000ff8 <walkaddr>
    if (pa0 == 0) {
    8000172c:	f561                	bnez	a0,800016f4 <copyin+0x2c>
      if ((pa0 = vmfault(pagetable, va0, 1)) == 0) {
    8000172e:	8666                	mv	a2,s9
    80001730:	85d2                	mv	a1,s4
    80001732:	855e                	mv	a0,s7
    80001734:	e5dff0ef          	jal	80001590 <vmfault>
    80001738:	fd55                	bnez	a0,800016f4 <copyin+0x2c>
        return -1;
    8000173a:	557d                	li	a0,-1
    8000173c:	a011                	j	80001740 <copyin+0x78>
  return 0;
    8000173e:	4501                	li	a0,0
}
    80001740:	60e6                	ld	ra,88(sp)
    80001742:	6446                	ld	s0,80(sp)
    80001744:	64a6                	ld	s1,72(sp)
    80001746:	6906                	ld	s2,64(sp)
    80001748:	79e2                	ld	s3,56(sp)
    8000174a:	7a42                	ld	s4,48(sp)
    8000174c:	7aa2                	ld	s5,40(sp)
    8000174e:	7b02                	ld	s6,32(sp)
    80001750:	6be2                	ld	s7,24(sp)
    80001752:	6c42                	ld	s8,16(sp)
    80001754:	6ca2                	ld	s9,8(sp)
    80001756:	6125                	addi	sp,sp,96
    80001758:	8082                	ret
  return 0;
    8000175a:	4501                	li	a0,0
}
    8000175c:	8082                	ret

000000008000175e <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    8000175e:	715d                	addi	sp,sp,-80
    80001760:	e486                	sd	ra,72(sp)
    80001762:	e0a2                	sd	s0,64(sp)
    80001764:	fc26                	sd	s1,56(sp)
    80001766:	f84a                	sd	s2,48(sp)
    80001768:	f44e                	sd	s3,40(sp)
    8000176a:	f052                	sd	s4,32(sp)
    8000176c:	ec56                	sd	s5,24(sp)
    8000176e:	e85a                	sd	s6,16(sp)
    80001770:	e45e                	sd	s7,8(sp)
    80001772:	0880                	addi	s0,sp,80
    80001774:	8aaa                	mv	s5,a0
    80001776:	4481                	li	s1,0

  for (p = proc; p < &proc[NPROC]; p++) {
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    80001778:	000a57b7          	lui	a5,0xa5
    8000177c:	fa578793          	addi	a5,a5,-91 # a4fa5 <_entry-0x7ff5b05b>
    80001780:	07b2                	slli	a5,a5,0xc
    80001782:	fa578793          	addi	a5,a5,-91
    80001786:	4fa50937          	lui	s2,0x4fa50
    8000178a:	a4f90913          	addi	s2,s2,-1457 # 4fa4fa4f <_entry-0x305b05b1>
    8000178e:	1902                	slli	s2,s2,0x20
    80001790:	993e                	add	s2,s2,a5
    80001792:	040009b7          	lui	s3,0x4000
    80001796:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001798:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000179a:	4b99                	li	s7,6
    8000179c:	6b05                	lui	s6,0x1
  for (p = proc; p < &proc[NPROC]; p++) {
    8000179e:	6a19                	lui	s4,0x6
    800017a0:	a00a0a13          	addi	s4,s4,-1536 # 5a00 <_entry-0x7fffa600>
    char *pa = kalloc();
    800017a4:	b9aff0ef          	jal	80000b3e <kalloc>
    800017a8:	862a                	mv	a2,a0
    if (pa == 0)
    800017aa:	cd15                	beqz	a0,800017e6 <proc_mapstacks+0x88>
    uint64 va = KSTACK((int)(p - proc));
    800017ac:	4034d593          	srai	a1,s1,0x3
    800017b0:	032585b3          	mul	a1,a1,s2
    800017b4:	05b6                	slli	a1,a1,0xd
    800017b6:	6789                	lui	a5,0x2
    800017b8:	9dbd                	addw	a1,a1,a5
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017ba:	875e                	mv	a4,s7
    800017bc:	86da                	mv	a3,s6
    800017be:	40b985b3          	sub	a1,s3,a1
    800017c2:	8556                	mv	a0,s5
    800017c4:	91fff0ef          	jal	800010e2 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++) {
    800017c8:	16848493          	addi	s1,s1,360
    800017cc:	fd449ce3          	bne	s1,s4,800017a4 <proc_mapstacks+0x46>
  }
}
    800017d0:	60a6                	ld	ra,72(sp)
    800017d2:	6406                	ld	s0,64(sp)
    800017d4:	74e2                	ld	s1,56(sp)
    800017d6:	7942                	ld	s2,48(sp)
    800017d8:	79a2                	ld	s3,40(sp)
    800017da:	7a02                	ld	s4,32(sp)
    800017dc:	6ae2                	ld	s5,24(sp)
    800017de:	6b42                	ld	s6,16(sp)
    800017e0:	6ba2                	ld	s7,8(sp)
    800017e2:	6161                	addi	sp,sp,80
    800017e4:	8082                	ret
      panic("kalloc");
    800017e6:	00006517          	auipc	a0,0x6
    800017ea:	97250513          	addi	a0,a0,-1678 # 80007158 <etext+0x158>
    800017ee:	84cff0ef          	jal	8000083a <panic>

00000000800017f2 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800017f2:	7139                	addi	sp,sp,-64
    800017f4:	fc06                	sd	ra,56(sp)
    800017f6:	f822                	sd	s0,48(sp)
    800017f8:	f426                	sd	s1,40(sp)
    800017fa:	f04a                	sd	s2,32(sp)
    800017fc:	ec4e                	sd	s3,24(sp)
    800017fe:	e852                	sd	s4,16(sp)
    80001800:	e456                	sd	s5,8(sp)
    80001802:	e05a                	sd	s6,0(sp)
    80001804:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    80001806:	00006597          	auipc	a1,0x6
    8000180a:	95a58593          	addi	a1,a1,-1702 # 80007160 <etext+0x160>
    8000180e:	0000e517          	auipc	a0,0xe
    80001812:	15a50513          	addi	a0,a0,346 # 8000f968 <pid_lock>
    80001816:	b82ff0ef          	jal	80000b98 <initlock>
  initlock(&wait_lock, "wait_lock");
    8000181a:	00006597          	auipc	a1,0x6
    8000181e:	94e58593          	addi	a1,a1,-1714 # 80007168 <etext+0x168>
    80001822:	0000e517          	auipc	a0,0xe
    80001826:	15e50513          	addi	a0,a0,350 # 8000f980 <wait_lock>
    8000182a:	b6eff0ef          	jal	80000b98 <initlock>
    8000182e:	4901                	li	s2,0
  for (p = proc; p < &proc[NPROC]; p++) {
    80001830:	0000e497          	auipc	s1,0xe
    80001834:	56848493          	addi	s1,s1,1384 # 8000fd98 <proc>
    initlock(&p->lock, "proc");
    80001838:	00006a97          	auipc	s5,0x6
    8000183c:	940a8a93          	addi	s5,s5,-1728 # 80007178 <etext+0x178>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    80001840:	000a57b7          	lui	a5,0xa5
    80001844:	fa578793          	addi	a5,a5,-91 # a4fa5 <_entry-0x7ff5b05b>
    80001848:	07b2                	slli	a5,a5,0xc
    8000184a:	fa578793          	addi	a5,a5,-91
    8000184e:	4fa509b7          	lui	s3,0x4fa50
    80001852:	a4f98993          	addi	s3,s3,-1457 # 4fa4fa4f <_entry-0x305b05b1>
    80001856:	1982                	slli	s3,s3,0x20
    80001858:	99be                	add	s3,s3,a5
    8000185a:	04000a37          	lui	s4,0x4000
    8000185e:	1a7d                	addi	s4,s4,-1 # 3ffffff <_entry-0x7c000001>
    80001860:	0a32                	slli	s4,s4,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    80001862:	00014b17          	auipc	s6,0x14
    80001866:	f36b0b13          	addi	s6,s6,-202 # 80015798 <tickslock>
    initlock(&p->lock, "proc");
    8000186a:	85d6                	mv	a1,s5
    8000186c:	8526                	mv	a0,s1
    8000186e:	b2aff0ef          	jal	80000b98 <initlock>
    p->state = UNUSED;
    80001872:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    80001876:	40395793          	srai	a5,s2,0x3
    8000187a:	033787b3          	mul	a5,a5,s3
    8000187e:	07b6                	slli	a5,a5,0xd
    80001880:	6709                	lui	a4,0x2
    80001882:	9fb9                	addw	a5,a5,a4
    80001884:	40fa07b3          	sub	a5,s4,a5
    80001888:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++) {
    8000188a:	16848493          	addi	s1,s1,360
    8000188e:	16890913          	addi	s2,s2,360
    80001892:	fd649ce3          	bne	s1,s6,8000186a <procinit+0x78>
  }
}
    80001896:	70e2                	ld	ra,56(sp)
    80001898:	7442                	ld	s0,48(sp)
    8000189a:	74a2                	ld	s1,40(sp)
    8000189c:	7902                	ld	s2,32(sp)
    8000189e:	69e2                	ld	s3,24(sp)
    800018a0:	6a42                	ld	s4,16(sp)
    800018a2:	6aa2                	ld	s5,8(sp)
    800018a4:	6b02                	ld	s6,0(sp)
    800018a6:	6121                	addi	sp,sp,64
    800018a8:	8082                	ret

00000000800018aa <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800018aa:	1141                	addi	sp,sp,-16
    800018ac:	e406                	sd	ra,8(sp)
    800018ae:	e022                	sd	s0,0(sp)
    800018b0:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r"(x));
    800018b2:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800018b4:	2501                	sext.w	a0,a0
    800018b6:	60a2                	ld	ra,8(sp)
    800018b8:	6402                	ld	s0,0(sp)
    800018ba:	0141                	addi	sp,sp,16
    800018bc:	8082                	ret

00000000800018be <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    800018be:	1141                	addi	sp,sp,-16
    800018c0:	e406                	sd	ra,8(sp)
    800018c2:	e022                	sd	s0,0(sp)
    800018c4:	0800                	addi	s0,sp,16
    800018c6:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800018c8:	2781                	sext.w	a5,a5
    800018ca:	079e                	slli	a5,a5,0x7
  return c;
}
    800018cc:	0000e517          	auipc	a0,0xe
    800018d0:	0cc50513          	addi	a0,a0,204 # 8000f998 <cpus>
    800018d4:	953e                	add	a0,a0,a5
    800018d6:	60a2                	ld	ra,8(sp)
    800018d8:	6402                	ld	s0,0(sp)
    800018da:	0141                	addi	sp,sp,16
    800018dc:	8082                	ret

00000000800018de <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    800018de:	1101                	addi	sp,sp,-32
    800018e0:	ec06                	sd	ra,24(sp)
    800018e2:	e822                	sd	s0,16(sp)
    800018e4:	e426                	sd	s1,8(sp)
    800018e6:	1000                	addi	s0,sp,32
  push_off();
    800018e8:	af6ff0ef          	jal	80000bde <push_off>
    800018ec:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800018ee:	2781                	sext.w	a5,a5
    800018f0:	079e                	slli	a5,a5,0x7
    800018f2:	0000e717          	auipc	a4,0xe
    800018f6:	07670713          	addi	a4,a4,118 # 8000f968 <pid_lock>
    800018fa:	97ba                	add	a5,a5,a4
    800018fc:	7b9c                	ld	a5,48(a5)
    800018fe:	84be                	mv	s1,a5
  pop_off();
    80001900:	b54ff0ef          	jal	80000c54 <pop_off>
  return p;
}
    80001904:	8526                	mv	a0,s1
    80001906:	60e2                	ld	ra,24(sp)
    80001908:	6442                	ld	s0,16(sp)
    8000190a:	64a2                	ld	s1,8(sp)
    8000190c:	6105                	addi	sp,sp,32
    8000190e:	8082                	ret

0000000080001910 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001910:	7179                	addi	sp,sp,-48
    80001912:	f406                	sd	ra,40(sp)
    80001914:	f022                	sd	s0,32(sp)
    80001916:	ec26                	sd	s1,24(sp)
    80001918:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    8000191a:	fc5ff0ef          	jal	800018de <myproc>
    8000191e:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001920:	b7cff0ef          	jal	80000c9c <release>

  if (__atomic_load_n(&first, __ATOMIC_ACQUIRE)) {
    80001924:	00006797          	auipc	a5,0x6
    80001928:	f0c78793          	addi	a5,a5,-244 # 80007830 <first.1>
    8000192c:	439c                	lw	a5,0(a5)
    8000192e:	0230000f          	fence	r,rw
    80001932:	2781                	sext.w	a5,a5
    80001934:	c3a1                	beqz	a5,80001974 <forkret+0x64>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001936:	4505                	li	a0,1
    80001938:	355010ef          	jal	8000348c <fsinit>

    // ensure other cores see first=0.
    __atomic_store_n(&first, 0, __ATOMIC_RELEASE);
    8000193c:	00006797          	auipc	a5,0x6
    80001940:	ef478793          	addi	a5,a5,-268 # 80007830 <first.1>
    80001944:	0310000f          	fence	rw,w
    80001948:	0007a023          	sw	zero,0(a5)

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){"/init", 0});
    8000194c:	00006797          	auipc	a5,0x6
    80001950:	83478793          	addi	a5,a5,-1996 # 80007180 <etext+0x180>
    80001954:	fcf43823          	sd	a5,-48(s0)
    80001958:	fc043c23          	sd	zero,-40(s0)
    8000195c:	fd040593          	addi	a1,s0,-48
    80001960:	853e                	mv	a0,a5
    80001962:	511020ef          	jal	80004672 <kexec>
    80001966:	6cbc                	ld	a5,88(s1)
    80001968:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    8000196a:	6cbc                	ld	a5,88(s1)
    8000196c:	7bb8                	ld	a4,112(a5)
    8000196e:	57fd                	li	a5,-1
    80001970:	02f70d63          	beq	a4,a5,800019aa <forkret+0x9a>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001974:	297000ef          	jal	8000240a <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001978:	68a8                	ld	a0,80(s1)
    8000197a:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    8000197c:	04000737          	lui	a4,0x4000
    80001980:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001982:	0732                	slli	a4,a4,0xc
    80001984:	00004797          	auipc	a5,0x4
    80001988:	71878793          	addi	a5,a5,1816 # 8000609c <userret>
    8000198c:	00004697          	auipc	a3,0x4
    80001990:	67468693          	addi	a3,a3,1652 # 80006000 <_trampoline>
    80001994:	8f95                	sub	a5,a5,a3
    80001996:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001998:	577d                	li	a4,-1
    8000199a:	177e                	slli	a4,a4,0x3f
    8000199c:	8d59                	or	a0,a0,a4
    8000199e:	9782                	jalr	a5
}
    800019a0:	70a2                	ld	ra,40(sp)
    800019a2:	7402                	ld	s0,32(sp)
    800019a4:	64e2                	ld	s1,24(sp)
    800019a6:	6145                	addi	sp,sp,48
    800019a8:	8082                	ret
      panic("exec");
    800019aa:	00005517          	auipc	a0,0x5
    800019ae:	7de50513          	addi	a0,a0,2014 # 80007188 <etext+0x188>
    800019b2:	e89fe0ef          	jal	8000083a <panic>

00000000800019b6 <allocpid>:
{
    800019b6:	1101                	addi	sp,sp,-32
    800019b8:	ec06                	sd	ra,24(sp)
    800019ba:	e822                	sd	s0,16(sp)
    800019bc:	e426                	sd	s1,8(sp)
    800019be:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    800019c0:	0000e517          	auipc	a0,0xe
    800019c4:	fa850513          	addi	a0,a0,-88 # 8000f968 <pid_lock>
    800019c8:	a50ff0ef          	jal	80000c18 <acquire>
  pid = nextpid;
    800019cc:	00006797          	auipc	a5,0x6
    800019d0:	e6878793          	addi	a5,a5,-408 # 80007834 <nextpid>
    800019d4:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    800019d6:	0014871b          	addiw	a4,s1,1
    800019da:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    800019dc:	0000e517          	auipc	a0,0xe
    800019e0:	f8c50513          	addi	a0,a0,-116 # 8000f968 <pid_lock>
    800019e4:	ab8ff0ef          	jal	80000c9c <release>
}
    800019e8:	8526                	mv	a0,s1
    800019ea:	60e2                	ld	ra,24(sp)
    800019ec:	6442                	ld	s0,16(sp)
    800019ee:	64a2                	ld	s1,8(sp)
    800019f0:	6105                	addi	sp,sp,32
    800019f2:	8082                	ret

00000000800019f4 <proc_pagetable>:
{
    800019f4:	1101                	addi	sp,sp,-32
    800019f6:	ec06                	sd	ra,24(sp)
    800019f8:	e822                	sd	s0,16(sp)
    800019fa:	e426                	sd	s1,8(sp)
    800019fc:	e04a                	sd	s2,0(sp)
    800019fe:	1000                	addi	s0,sp,32
    80001a00:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a02:	fceff0ef          	jal	800011d0 <uvmcreate>
    80001a06:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001a08:	cd05                	beqz	a0,80001a40 <proc_pagetable+0x4c>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE, (uint64)trampoline,
    80001a0a:	4729                	li	a4,10
    80001a0c:	00004697          	auipc	a3,0x4
    80001a10:	5f468693          	addi	a3,a3,1524 # 80006000 <_trampoline>
    80001a14:	6605                	lui	a2,0x1
    80001a16:	040005b7          	lui	a1,0x4000
    80001a1a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a1c:	05b2                	slli	a1,a1,0xc
    80001a1e:	e12ff0ef          	jal	80001030 <mappages>
    80001a22:	02054663          	bltz	a0,80001a4e <proc_pagetable+0x5a>
  if (mappages(pagetable, TRAPFRAME, PGSIZE, (uint64)(p->trapframe),
    80001a26:	4719                	li	a4,6
    80001a28:	05893683          	ld	a3,88(s2)
    80001a2c:	6605                	lui	a2,0x1
    80001a2e:	020005b7          	lui	a1,0x2000
    80001a32:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a34:	05b6                	slli	a1,a1,0xd
    80001a36:	8526                	mv	a0,s1
    80001a38:	df8ff0ef          	jal	80001030 <mappages>
    80001a3c:	00054f63          	bltz	a0,80001a5a <proc_pagetable+0x66>
}
    80001a40:	8526                	mv	a0,s1
    80001a42:	60e2                	ld	ra,24(sp)
    80001a44:	6442                	ld	s0,16(sp)
    80001a46:	64a2                	ld	s1,8(sp)
    80001a48:	6902                	ld	s2,0(sp)
    80001a4a:	6105                	addi	sp,sp,32
    80001a4c:	8082                	ret
    uvmfree(pagetable, 0);
    80001a4e:	4581                	li	a1,0
    80001a50:	8526                	mv	a0,s1
    80001a52:	971ff0ef          	jal	800013c2 <uvmfree>
    return 0;
    80001a56:	4481                	li	s1,0
    80001a58:	b7e5                	j	80001a40 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a5a:	4681                	li	a3,0
    80001a5c:	4605                	li	a2,1
    80001a5e:	040005b7          	lui	a1,0x4000
    80001a62:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a64:	05b2                	slli	a1,a1,0xc
    80001a66:	8526                	mv	a0,s1
    80001a68:	f8eff0ef          	jal	800011f6 <uvmunmap>
    uvmfree(pagetable, 0);
    80001a6c:	4581                	li	a1,0
    80001a6e:	8526                	mv	a0,s1
    80001a70:	953ff0ef          	jal	800013c2 <uvmfree>
    return 0;
    80001a74:	b7cd                	j	80001a56 <proc_pagetable+0x62>

0000000080001a76 <proc_freepagetable>:
{
    80001a76:	1101                	addi	sp,sp,-32
    80001a78:	ec06                	sd	ra,24(sp)
    80001a7a:	e822                	sd	s0,16(sp)
    80001a7c:	e426                	sd	s1,8(sp)
    80001a7e:	e04a                	sd	s2,0(sp)
    80001a80:	1000                	addi	s0,sp,32
    80001a82:	84aa                	mv	s1,a0
    80001a84:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a86:	4681                	li	a3,0
    80001a88:	4605                	li	a2,1
    80001a8a:	040005b7          	lui	a1,0x4000
    80001a8e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a90:	05b2                	slli	a1,a1,0xc
    80001a92:	f64ff0ef          	jal	800011f6 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001a96:	4681                	li	a3,0
    80001a98:	4605                	li	a2,1
    80001a9a:	020005b7          	lui	a1,0x2000
    80001a9e:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001aa0:	05b6                	slli	a1,a1,0xd
    80001aa2:	8526                	mv	a0,s1
    80001aa4:	f52ff0ef          	jal	800011f6 <uvmunmap>
  uvmfree(pagetable, sz);
    80001aa8:	85ca                	mv	a1,s2
    80001aaa:	8526                	mv	a0,s1
    80001aac:	917ff0ef          	jal	800013c2 <uvmfree>
}
    80001ab0:	60e2                	ld	ra,24(sp)
    80001ab2:	6442                	ld	s0,16(sp)
    80001ab4:	64a2                	ld	s1,8(sp)
    80001ab6:	6902                	ld	s2,0(sp)
    80001ab8:	6105                	addi	sp,sp,32
    80001aba:	8082                	ret

0000000080001abc <freeproc>:
{
    80001abc:	1101                	addi	sp,sp,-32
    80001abe:	ec06                	sd	ra,24(sp)
    80001ac0:	e822                	sd	s0,16(sp)
    80001ac2:	e426                	sd	s1,8(sp)
    80001ac4:	1000                	addi	s0,sp,32
    80001ac6:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001ac8:	6d28                	ld	a0,88(a0)
    80001aca:	c119                	beqz	a0,80001ad0 <freeproc+0x14>
    kfree((void *)p->trapframe);
    80001acc:	f8bfe0ef          	jal	80000a56 <kfree>
  p->trapframe = 0;
    80001ad0:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001ad4:	68a8                	ld	a0,80(s1)
    80001ad6:	c501                	beqz	a0,80001ade <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001ad8:	64ac                	ld	a1,72(s1)
    80001ada:	f9dff0ef          	jal	80001a76 <proc_freepagetable>
  p->pagetable = 0;
    80001ade:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001ae2:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001ae6:	0204a823          	sw	zero,48(s1)
  p->name[0] = 0;
    80001aea:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001aee:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001af2:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001af6:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001afa:	0004ac23          	sw	zero,24(s1)
}
    80001afe:	60e2                	ld	ra,24(sp)
    80001b00:	6442                	ld	s0,16(sp)
    80001b02:	64a2                	ld	s1,8(sp)
    80001b04:	6105                	addi	sp,sp,32
    80001b06:	8082                	ret

0000000080001b08 <allocproc>:
{
    80001b08:	1101                	addi	sp,sp,-32
    80001b0a:	ec06                	sd	ra,24(sp)
    80001b0c:	e822                	sd	s0,16(sp)
    80001b0e:	e426                	sd	s1,8(sp)
    80001b10:	e04a                	sd	s2,0(sp)
    80001b12:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++) {
    80001b14:	0000e497          	auipc	s1,0xe
    80001b18:	28448493          	addi	s1,s1,644 # 8000fd98 <proc>
    80001b1c:	00014917          	auipc	s2,0x14
    80001b20:	c7c90913          	addi	s2,s2,-900 # 80015798 <tickslock>
    acquire(&p->lock);
    80001b24:	8526                	mv	a0,s1
    80001b26:	8f2ff0ef          	jal	80000c18 <acquire>
    if (p->state == UNUSED) {
    80001b2a:	4c9c                	lw	a5,24(s1)
    80001b2c:	cb91                	beqz	a5,80001b40 <allocproc+0x38>
      release(&p->lock);
    80001b2e:	8526                	mv	a0,s1
    80001b30:	96cff0ef          	jal	80000c9c <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001b34:	16848493          	addi	s1,s1,360
    80001b38:	ff2496e3          	bne	s1,s2,80001b24 <allocproc+0x1c>
  return 0;
    80001b3c:	4481                	li	s1,0
    80001b3e:	a089                	j	80001b80 <allocproc+0x78>
  p->pid = allocpid();
    80001b40:	e77ff0ef          	jal	800019b6 <allocpid>
    80001b44:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001b46:	4785                	li	a5,1
    80001b48:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0) {
    80001b4a:	ff5fe0ef          	jal	80000b3e <kalloc>
    80001b4e:	892a                	mv	s2,a0
    80001b50:	eca8                	sd	a0,88(s1)
    80001b52:	cd15                	beqz	a0,80001b8e <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001b54:	8526                	mv	a0,s1
    80001b56:	e9fff0ef          	jal	800019f4 <proc_pagetable>
    80001b5a:	892a                	mv	s2,a0
    80001b5c:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0) {
    80001b5e:	c121                	beqz	a0,80001b9e <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001b60:	07000613          	li	a2,112
    80001b64:	4581                	li	a1,0
    80001b66:	06048513          	addi	a0,s1,96
    80001b6a:	96aff0ef          	jal	80000cd4 <memset>
  p->context.ra = (uint64)forkret;
    80001b6e:	00000797          	auipc	a5,0x0
    80001b72:	da278793          	addi	a5,a5,-606 # 80001910 <forkret>
    80001b76:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001b78:	60bc                	ld	a5,64(s1)
    80001b7a:	6705                	lui	a4,0x1
    80001b7c:	97ba                	add	a5,a5,a4
    80001b7e:	f4bc                	sd	a5,104(s1)
}
    80001b80:	8526                	mv	a0,s1
    80001b82:	60e2                	ld	ra,24(sp)
    80001b84:	6442                	ld	s0,16(sp)
    80001b86:	64a2                	ld	s1,8(sp)
    80001b88:	6902                	ld	s2,0(sp)
    80001b8a:	6105                	addi	sp,sp,32
    80001b8c:	8082                	ret
    freeproc(p);
    80001b8e:	8526                	mv	a0,s1
    80001b90:	f2dff0ef          	jal	80001abc <freeproc>
    release(&p->lock);
    80001b94:	8526                	mv	a0,s1
    80001b96:	906ff0ef          	jal	80000c9c <release>
    return 0;
    80001b9a:	84ca                	mv	s1,s2
    80001b9c:	b7d5                	j	80001b80 <allocproc+0x78>
    freeproc(p);
    80001b9e:	8526                	mv	a0,s1
    80001ba0:	f1dff0ef          	jal	80001abc <freeproc>
    release(&p->lock);
    80001ba4:	8526                	mv	a0,s1
    80001ba6:	8f6ff0ef          	jal	80000c9c <release>
    return 0;
    80001baa:	84ca                	mv	s1,s2
    80001bac:	bfd1                	j	80001b80 <allocproc+0x78>

0000000080001bae <userinit>:
{
    80001bae:	1101                	addi	sp,sp,-32
    80001bb0:	ec06                	sd	ra,24(sp)
    80001bb2:	e822                	sd	s0,16(sp)
    80001bb4:	e426                	sd	s1,8(sp)
    80001bb6:	1000                	addi	s0,sp,32
  p = allocproc();
    80001bb8:	f51ff0ef          	jal	80001b08 <allocproc>
    80001bbc:	84aa                	mv	s1,a0
  initproc = p;
    80001bbe:	00006797          	auipc	a5,0x6
    80001bc2:	caa7b123          	sd	a0,-862(a5) # 80007860 <initproc>
  p->cwd = namei("/");
    80001bc6:	00005517          	auipc	a0,0x5
    80001bca:	5ca50513          	addi	a0,a0,1482 # 80007190 <etext+0x190>
    80001bce:	609010ef          	jal	800039d6 <namei>
    80001bd2:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001bd6:	478d                	li	a5,3
    80001bd8:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001bda:	8526                	mv	a0,s1
    80001bdc:	8c0ff0ef          	jal	80000c9c <release>
}
    80001be0:	60e2                	ld	ra,24(sp)
    80001be2:	6442                	ld	s0,16(sp)
    80001be4:	64a2                	ld	s1,8(sp)
    80001be6:	6105                	addi	sp,sp,32
    80001be8:	8082                	ret

0000000080001bea <growproc>:
{
    80001bea:	1101                	addi	sp,sp,-32
    80001bec:	ec06                	sd	ra,24(sp)
    80001bee:	e822                	sd	s0,16(sp)
    80001bf0:	e426                	sd	s1,8(sp)
    80001bf2:	e04a                	sd	s2,0(sp)
    80001bf4:	1000                	addi	s0,sp,32
    80001bf6:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001bf8:	ce7ff0ef          	jal	800018de <myproc>
    80001bfc:	892a                	mv	s2,a0
  sz = p->sz;
    80001bfe:	652c                	ld	a1,72(a0)
  if (n > 0) {
    80001c00:	02905b63          	blez	s1,80001c36 <growproc+0x4c>
    if (sz + n > TRAPFRAME) {
    80001c04:	00b48633          	add	a2,s1,a1
    80001c08:	020007b7          	lui	a5,0x2000
    80001c0c:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001c0e:	07b6                	slli	a5,a5,0xd
    80001c10:	02c7e163          	bltu	a5,a2,80001c32 <growproc+0x48>
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001c14:	4691                	li	a3,4
    80001c16:	6928                	ld	a0,80(a0)
    80001c18:	eaeff0ef          	jal	800012c6 <uvmalloc>
    80001c1c:	85aa                	mv	a1,a0
    80001c1e:	c911                	beqz	a0,80001c32 <growproc+0x48>
  p->sz = sz;
    80001c20:	04b93423          	sd	a1,72(s2)
  return 0;
    80001c24:	4501                	li	a0,0
}
    80001c26:	60e2                	ld	ra,24(sp)
    80001c28:	6442                	ld	s0,16(sp)
    80001c2a:	64a2                	ld	s1,8(sp)
    80001c2c:	6902                	ld	s2,0(sp)
    80001c2e:	6105                	addi	sp,sp,32
    80001c30:	8082                	ret
      return -1;
    80001c32:	557d                	li	a0,-1
    80001c34:	bfcd                	j	80001c26 <growproc+0x3c>
  } else if (n < 0) {
    80001c36:	fe04d5e3          	bgez	s1,80001c20 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001c3a:	00b48633          	add	a2,s1,a1
    80001c3e:	6928                	ld	a0,80(a0)
    80001c40:	e40ff0ef          	jal	80001280 <uvmdealloc>
    80001c44:	85aa                	mv	a1,a0
    80001c46:	bfe9                	j	80001c20 <growproc+0x36>

0000000080001c48 <kfork>:
{
    80001c48:	7139                	addi	sp,sp,-64
    80001c4a:	fc06                	sd	ra,56(sp)
    80001c4c:	f822                	sd	s0,48(sp)
    80001c4e:	f426                	sd	s1,40(sp)
    80001c50:	e456                	sd	s5,8(sp)
    80001c52:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001c54:	c8bff0ef          	jal	800018de <myproc>
    80001c58:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0) {
    80001c5a:	eafff0ef          	jal	80001b08 <allocproc>
    80001c5e:	c92d                	beqz	a0,80001cd0 <kfork+0x88>
    80001c60:	e852                	sd	s4,16(sp)
    80001c62:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0) {
    80001c64:	048ab603          	ld	a2,72(s5)
    80001c68:	692c                	ld	a1,80(a0)
    80001c6a:	050ab503          	ld	a0,80(s5)
    80001c6e:	f86ff0ef          	jal	800013f4 <uvmcopy>
    80001c72:	04054863          	bltz	a0,80001cc2 <kfork+0x7a>
    80001c76:	f04a                	sd	s2,32(sp)
    80001c78:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001c7a:	048ab783          	ld	a5,72(s5)
    80001c7e:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001c82:	058ab683          	ld	a3,88(s5)
    80001c86:	87b6                	mv	a5,a3
    80001c88:	058a3703          	ld	a4,88(s4)
    80001c8c:	12068693          	addi	a3,a3,288
    80001c90:	6388                	ld	a0,0(a5)
    80001c92:	678c                	ld	a1,8(a5)
    80001c94:	6b90                	ld	a2,16(a5)
    80001c96:	e308                	sd	a0,0(a4)
    80001c98:	e70c                	sd	a1,8(a4)
    80001c9a:	eb10                	sd	a2,16(a4)
    80001c9c:	6f90                	ld	a2,24(a5)
    80001c9e:	ef10                	sd	a2,24(a4)
    80001ca0:	02078793          	addi	a5,a5,32
    80001ca4:	02070713          	addi	a4,a4,32 # 1020 <_entry-0x7fffefe0>
    80001ca8:	fed794e3          	bne	a5,a3,80001c90 <kfork+0x48>
  np->trapframe->a0 = 0;
    80001cac:	058a3783          	ld	a5,88(s4)
    80001cb0:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001cb4:	0d0a8493          	addi	s1,s5,208
    80001cb8:	0d0a0913          	addi	s2,s4,208
    80001cbc:	150a8993          	addi	s3,s5,336
    80001cc0:	a831                	j	80001cdc <kfork+0x94>
    freeproc(np);
    80001cc2:	8552                	mv	a0,s4
    80001cc4:	df9ff0ef          	jal	80001abc <freeproc>
    release(&np->lock);
    80001cc8:	8552                	mv	a0,s4
    80001cca:	fd3fe0ef          	jal	80000c9c <release>
    return -1;
    80001cce:	6a42                	ld	s4,16(sp)
    return -1;
    80001cd0:	54fd                	li	s1,-1
    80001cd2:	a885                	j	80001d42 <kfork+0xfa>
  for (i = 0; i < NOFILE; i++)
    80001cd4:	04a1                	addi	s1,s1,8
    80001cd6:	0921                	addi	s2,s2,8
    80001cd8:	01348963          	beq	s1,s3,80001cea <kfork+0xa2>
    if (p->ofile[i])
    80001cdc:	6088                	ld	a0,0(s1)
    80001cde:	d97d                	beqz	a0,80001cd4 <kfork+0x8c>
      np->ofile[i] = filedup(p->ofile[i]);
    80001ce0:	30c020ef          	jal	80003fec <filedup>
    80001ce4:	00a93023          	sd	a0,0(s2)
    80001ce8:	b7f5                	j	80001cd4 <kfork+0x8c>
  np->cwd = idup(p->cwd);
    80001cea:	150ab503          	ld	a0,336(s5)
    80001cee:	474010ef          	jal	80003162 <idup>
    80001cf2:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001cf6:	4641                	li	a2,16
    80001cf8:	158a8593          	addi	a1,s5,344
    80001cfc:	158a0513          	addi	a0,s4,344
    80001d00:	91eff0ef          	jal	80000e1e <safestrcpy>
  pid = np->pid;
    80001d04:	030a2483          	lw	s1,48(s4)
  release(&np->lock);
    80001d08:	8552                	mv	a0,s4
    80001d0a:	f93fe0ef          	jal	80000c9c <release>
  acquire(&wait_lock);
    80001d0e:	0000e517          	auipc	a0,0xe
    80001d12:	c7250513          	addi	a0,a0,-910 # 8000f980 <wait_lock>
    80001d16:	f03fe0ef          	jal	80000c18 <acquire>
  np->parent = p;
    80001d1a:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001d1e:	0000e517          	auipc	a0,0xe
    80001d22:	c6250513          	addi	a0,a0,-926 # 8000f980 <wait_lock>
    80001d26:	f77fe0ef          	jal	80000c9c <release>
  acquire(&np->lock);
    80001d2a:	8552                	mv	a0,s4
    80001d2c:	eedfe0ef          	jal	80000c18 <acquire>
  np->state = RUNNABLE;
    80001d30:	478d                	li	a5,3
    80001d32:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001d36:	8552                	mv	a0,s4
    80001d38:	f65fe0ef          	jal	80000c9c <release>
    80001d3c:	7902                	ld	s2,32(sp)
    80001d3e:	69e2                	ld	s3,24(sp)
    80001d40:	6a42                	ld	s4,16(sp)
}
    80001d42:	8526                	mv	a0,s1
    80001d44:	70e2                	ld	ra,56(sp)
    80001d46:	7442                	ld	s0,48(sp)
    80001d48:	74a2                	ld	s1,40(sp)
    80001d4a:	6aa2                	ld	s5,8(sp)
    80001d4c:	6121                	addi	sp,sp,64
    80001d4e:	8082                	ret

0000000080001d50 <scheduler>:
{
    80001d50:	715d                	addi	sp,sp,-80
    80001d52:	e486                	sd	ra,72(sp)
    80001d54:	e0a2                	sd	s0,64(sp)
    80001d56:	fc26                	sd	s1,56(sp)
    80001d58:	f84a                	sd	s2,48(sp)
    80001d5a:	f44e                	sd	s3,40(sp)
    80001d5c:	f052                	sd	s4,32(sp)
    80001d5e:	ec56                	sd	s5,24(sp)
    80001d60:	e85a                	sd	s6,16(sp)
    80001d62:	e45e                	sd	s7,8(sp)
    80001d64:	e062                	sd	s8,0(sp)
    80001d66:	0880                	addi	s0,sp,80
    80001d68:	8792                	mv	a5,tp
  int id = r_tp();
    80001d6a:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001d6c:	00779693          	slli	a3,a5,0x7
    80001d70:	0000e717          	auipc	a4,0xe
    80001d74:	bf870713          	addi	a4,a4,-1032 # 8000f968 <pid_lock>
    80001d78:	9736                	add	a4,a4,a3
    80001d7a:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001d7e:	0000eb17          	auipc	s6,0xe
    80001d82:	c22b0b13          	addi	s6,s6,-990 # 8000f9a0 <cpus+0x8>
    80001d86:	9b36                	add	s6,s6,a3
        p->state = RUNNING;
    80001d88:	4c11                	li	s8,4
        c->proc = p;
    80001d8a:	8a3a                	mv	s4,a4
        found = 1;
    80001d8c:	4b85                	li	s7,1
    80001d8e:	a83d                	j	80001dcc <scheduler+0x7c>
      release(&p->lock);
    80001d90:	8526                	mv	a0,s1
    80001d92:	f0bfe0ef          	jal	80000c9c <release>
    for (p = proc; p < &proc[NPROC]; p++) {
    80001d96:	16848493          	addi	s1,s1,360
    80001d9a:	03248563          	beq	s1,s2,80001dc4 <scheduler+0x74>
      acquire(&p->lock);
    80001d9e:	8526                	mv	a0,s1
    80001da0:	e79fe0ef          	jal	80000c18 <acquire>
      if (p->state == RUNNABLE) {
    80001da4:	4c9c                	lw	a5,24(s1)
    80001da6:	ff3795e3          	bne	a5,s3,80001d90 <scheduler+0x40>
        p->state = RUNNING;
    80001daa:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001dae:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001db2:	06048593          	addi	a1,s1,96
    80001db6:	855a                	mv	a0,s6
    80001db8:	5a8000ef          	jal	80002360 <swtch>
        c->proc = 0;
    80001dbc:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001dc0:	8ade                	mv	s5,s7
    80001dc2:	b7f9                	j	80001d90 <scheduler+0x40>
    if (found == 0) {
    80001dc4:	000a9463          	bnez	s5,80001dcc <scheduler+0x7c>
      asm volatile("wfi");
    80001dc8:	10500073          	wfi
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80001dcc:	10016073          	csrsi	sstatus,2
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    80001dd0:	10017073          	csrci	sstatus,2
    int found = 0;
    80001dd4:	4a81                	li	s5,0
    for (p = proc; p < &proc[NPROC]; p++) {
    80001dd6:	0000e497          	auipc	s1,0xe
    80001dda:	fc248493          	addi	s1,s1,-62 # 8000fd98 <proc>
      if (p->state == RUNNABLE) {
    80001dde:	498d                	li	s3,3
    for (p = proc; p < &proc[NPROC]; p++) {
    80001de0:	00014917          	auipc	s2,0x14
    80001de4:	9b890913          	addi	s2,s2,-1608 # 80015798 <tickslock>
    80001de8:	bf5d                	j	80001d9e <scheduler+0x4e>

0000000080001dea <sched>:
{
    80001dea:	7179                	addi	sp,sp,-48
    80001dec:	f406                	sd	ra,40(sp)
    80001dee:	f022                	sd	s0,32(sp)
    80001df0:	ec26                	sd	s1,24(sp)
    80001df2:	e84a                	sd	s2,16(sp)
    80001df4:	e44e                	sd	s3,8(sp)
    80001df6:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001df8:	ae7ff0ef          	jal	800018de <myproc>
    80001dfc:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80001dfe:	db5fe0ef          	jal	80000bb2 <holding>
    80001e02:	c92d                	beqz	a0,80001e74 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r"(x));
    80001e04:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80001e06:	2781                	sext.w	a5,a5
    80001e08:	079e                	slli	a5,a5,0x7
    80001e0a:	0000e717          	auipc	a4,0xe
    80001e0e:	b5e70713          	addi	a4,a4,-1186 # 8000f968 <pid_lock>
    80001e12:	97ba                	add	a5,a5,a4
    80001e14:	0a87a703          	lw	a4,168(a5)
    80001e18:	4785                	li	a5,1
    80001e1a:	06f71363          	bne	a4,a5,80001e80 <sched+0x96>
  if (p->state == RUNNING)
    80001e1e:	4c98                	lw	a4,24(s1)
    80001e20:	4791                	li	a5,4
    80001e22:	06f70563          	beq	a4,a5,80001e8c <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80001e26:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e2a:	8b89                	andi	a5,a5,2
  if (intr_get())
    80001e2c:	e7b5                	bnez	a5,80001e98 <sched+0xae>
  asm volatile("mv %0, tp" : "=r"(x));
    80001e2e:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e30:	0000e917          	auipc	s2,0xe
    80001e34:	b3890913          	addi	s2,s2,-1224 # 8000f968 <pid_lock>
    80001e38:	2781                	sext.w	a5,a5
    80001e3a:	079e                	slli	a5,a5,0x7
    80001e3c:	97ca                	add	a5,a5,s2
    80001e3e:	0ac7a983          	lw	s3,172(a5)
    80001e42:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001e44:	2781                	sext.w	a5,a5
    80001e46:	079e                	slli	a5,a5,0x7
    80001e48:	0000e597          	auipc	a1,0xe
    80001e4c:	b5858593          	addi	a1,a1,-1192 # 8000f9a0 <cpus+0x8>
    80001e50:	95be                	add	a1,a1,a5
    80001e52:	06048513          	addi	a0,s1,96
    80001e56:	50a000ef          	jal	80002360 <swtch>
    80001e5a:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001e5c:	2781                	sext.w	a5,a5
    80001e5e:	079e                	slli	a5,a5,0x7
    80001e60:	993e                	add	s2,s2,a5
    80001e62:	0b392623          	sw	s3,172(s2)
}
    80001e66:	70a2                	ld	ra,40(sp)
    80001e68:	7402                	ld	s0,32(sp)
    80001e6a:	64e2                	ld	s1,24(sp)
    80001e6c:	6942                	ld	s2,16(sp)
    80001e6e:	69a2                	ld	s3,8(sp)
    80001e70:	6145                	addi	sp,sp,48
    80001e72:	8082                	ret
    panic("sched p->lock");
    80001e74:	00005517          	auipc	a0,0x5
    80001e78:	32450513          	addi	a0,a0,804 # 80007198 <etext+0x198>
    80001e7c:	9bffe0ef          	jal	8000083a <panic>
    panic("sched locks");
    80001e80:	00005517          	auipc	a0,0x5
    80001e84:	32850513          	addi	a0,a0,808 # 800071a8 <etext+0x1a8>
    80001e88:	9b3fe0ef          	jal	8000083a <panic>
    panic("sched RUNNING");
    80001e8c:	00005517          	auipc	a0,0x5
    80001e90:	32c50513          	addi	a0,a0,812 # 800071b8 <etext+0x1b8>
    80001e94:	9a7fe0ef          	jal	8000083a <panic>
    panic("sched interruptible");
    80001e98:	00005517          	auipc	a0,0x5
    80001e9c:	33050513          	addi	a0,a0,816 # 800071c8 <etext+0x1c8>
    80001ea0:	99bfe0ef          	jal	8000083a <panic>

0000000080001ea4 <yield>:
{
    80001ea4:	1101                	addi	sp,sp,-32
    80001ea6:	ec06                	sd	ra,24(sp)
    80001ea8:	e822                	sd	s0,16(sp)
    80001eaa:	e426                	sd	s1,8(sp)
    80001eac:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001eae:	a31ff0ef          	jal	800018de <myproc>
    80001eb2:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001eb4:	d65fe0ef          	jal	80000c18 <acquire>
  p->state = RUNNABLE;
    80001eb8:	478d                	li	a5,3
    80001eba:	cc9c                	sw	a5,24(s1)
  sched();
    80001ebc:	f2fff0ef          	jal	80001dea <sched>
  release(&p->lock);
    80001ec0:	8526                	mv	a0,s1
    80001ec2:	ddbfe0ef          	jal	80000c9c <release>
}
    80001ec6:	60e2                	ld	ra,24(sp)
    80001ec8:	6442                	ld	s0,16(sp)
    80001eca:	64a2                	ld	s1,8(sp)
    80001ecc:	6105                	addi	sp,sp,32
    80001ece:	8082                	ret

0000000080001ed0 <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001ed0:	7179                	addi	sp,sp,-48
    80001ed2:	f406                	sd	ra,40(sp)
    80001ed4:	f022                	sd	s0,32(sp)
    80001ed6:	ec26                	sd	s1,24(sp)
    80001ed8:	e84a                	sd	s2,16(sp)
    80001eda:	e44e                	sd	s3,8(sp)
    80001edc:	1800                	addi	s0,sp,48
    80001ede:	89aa                	mv	s3,a0
    80001ee0:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001ee2:	9fdff0ef          	jal	800018de <myproc>
    80001ee6:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); //DOC: sleeplock1
    80001ee8:	d31fe0ef          	jal	80000c18 <acquire>
  release(lk);
    80001eec:	854a                	mv	a0,s2
    80001eee:	daffe0ef          	jal	80000c9c <release>

  // Go to sleep.
  p->chan = chan;
    80001ef2:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001ef6:	4789                	li	a5,2
    80001ef8:	cc9c                	sw	a5,24(s1)

  sched();
    80001efa:	ef1ff0ef          	jal	80001dea <sched>

  // Tidy up.
  p->chan = 0;
    80001efe:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001f02:	8526                	mv	a0,s1
    80001f04:	d99fe0ef          	jal	80000c9c <release>
  acquire(lk);
    80001f08:	854a                	mv	a0,s2
    80001f0a:	d0ffe0ef          	jal	80000c18 <acquire>
}
    80001f0e:	70a2                	ld	ra,40(sp)
    80001f10:	7402                	ld	s0,32(sp)
    80001f12:	64e2                	ld	s1,24(sp)
    80001f14:	6942                	ld	s2,16(sp)
    80001f16:	69a2                	ld	s3,8(sp)
    80001f18:	6145                	addi	sp,sp,48
    80001f1a:	8082                	ret

0000000080001f1c <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    80001f1c:	7139                	addi	sp,sp,-64
    80001f1e:	fc06                	sd	ra,56(sp)
    80001f20:	f822                	sd	s0,48(sp)
    80001f22:	f426                	sd	s1,40(sp)
    80001f24:	f04a                	sd	s2,32(sp)
    80001f26:	ec4e                	sd	s3,24(sp)
    80001f28:	e852                	sd	s4,16(sp)
    80001f2a:	e456                	sd	s5,8(sp)
    80001f2c:	0080                	addi	s0,sp,64
    80001f2e:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80001f30:	0000e497          	auipc	s1,0xe
    80001f34:	e6848493          	addi	s1,s1,-408 # 8000fd98 <proc>
    if (p != myproc()) {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan) {
    80001f38:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001f3a:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++) {
    80001f3c:	00014917          	auipc	s2,0x14
    80001f40:	85c90913          	addi	s2,s2,-1956 # 80015798 <tickslock>
    80001f44:	a801                	j	80001f54 <wakeup+0x38>
      }
      release(&p->lock);
    80001f46:	8526                	mv	a0,s1
    80001f48:	d55fe0ef          	jal	80000c9c <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001f4c:	16848493          	addi	s1,s1,360
    80001f50:	03248263          	beq	s1,s2,80001f74 <wakeup+0x58>
    if (p != myproc()) {
    80001f54:	98bff0ef          	jal	800018de <myproc>
    80001f58:	fe950ae3          	beq	a0,s1,80001f4c <wakeup+0x30>
      acquire(&p->lock);
    80001f5c:	8526                	mv	a0,s1
    80001f5e:	cbbfe0ef          	jal	80000c18 <acquire>
      if (p->state == SLEEPING && p->chan == chan) {
    80001f62:	4c9c                	lw	a5,24(s1)
    80001f64:	ff3791e3          	bne	a5,s3,80001f46 <wakeup+0x2a>
    80001f68:	709c                	ld	a5,32(s1)
    80001f6a:	fd479ee3          	bne	a5,s4,80001f46 <wakeup+0x2a>
        p->state = RUNNABLE;
    80001f6e:	0154ac23          	sw	s5,24(s1)
    80001f72:	bfd1                	j	80001f46 <wakeup+0x2a>
    }
  }
}
    80001f74:	70e2                	ld	ra,56(sp)
    80001f76:	7442                	ld	s0,48(sp)
    80001f78:	74a2                	ld	s1,40(sp)
    80001f7a:	7902                	ld	s2,32(sp)
    80001f7c:	69e2                	ld	s3,24(sp)
    80001f7e:	6a42                	ld	s4,16(sp)
    80001f80:	6aa2                	ld	s5,8(sp)
    80001f82:	6121                	addi	sp,sp,64
    80001f84:	8082                	ret

0000000080001f86 <reparent>:
{
    80001f86:	7179                	addi	sp,sp,-48
    80001f88:	f406                	sd	ra,40(sp)
    80001f8a:	f022                	sd	s0,32(sp)
    80001f8c:	ec26                	sd	s1,24(sp)
    80001f8e:	e84a                	sd	s2,16(sp)
    80001f90:	e44e                	sd	s3,8(sp)
    80001f92:	e052                	sd	s4,0(sp)
    80001f94:	1800                	addi	s0,sp,48
    80001f96:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80001f98:	0000e497          	auipc	s1,0xe
    80001f9c:	e0048493          	addi	s1,s1,-512 # 8000fd98 <proc>
      pp->parent = initproc;
    80001fa0:	00006a17          	auipc	s4,0x6
    80001fa4:	8c0a0a13          	addi	s4,s4,-1856 # 80007860 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80001fa8:	00013997          	auipc	s3,0x13
    80001fac:	7f098993          	addi	s3,s3,2032 # 80015798 <tickslock>
    80001fb0:	a029                	j	80001fba <reparent+0x34>
    80001fb2:	16848493          	addi	s1,s1,360
    80001fb6:	01348b63          	beq	s1,s3,80001fcc <reparent+0x46>
    if (pp->parent == p) {
    80001fba:	7c9c                	ld	a5,56(s1)
    80001fbc:	ff279be3          	bne	a5,s2,80001fb2 <reparent+0x2c>
      pp->parent = initproc;
    80001fc0:	000a3503          	ld	a0,0(s4)
    80001fc4:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80001fc6:	f57ff0ef          	jal	80001f1c <wakeup>
    80001fca:	b7e5                	j	80001fb2 <reparent+0x2c>
}
    80001fcc:	70a2                	ld	ra,40(sp)
    80001fce:	7402                	ld	s0,32(sp)
    80001fd0:	64e2                	ld	s1,24(sp)
    80001fd2:	6942                	ld	s2,16(sp)
    80001fd4:	69a2                	ld	s3,8(sp)
    80001fd6:	6a02                	ld	s4,0(sp)
    80001fd8:	6145                	addi	sp,sp,48
    80001fda:	8082                	ret

0000000080001fdc <kexit>:
{
    80001fdc:	7179                	addi	sp,sp,-48
    80001fde:	f406                	sd	ra,40(sp)
    80001fe0:	f022                	sd	s0,32(sp)
    80001fe2:	ec26                	sd	s1,24(sp)
    80001fe4:	e84a                	sd	s2,16(sp)
    80001fe6:	e44e                	sd	s3,8(sp)
    80001fe8:	e052                	sd	s4,0(sp)
    80001fea:	1800                	addi	s0,sp,48
    80001fec:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80001fee:	8f1ff0ef          	jal	800018de <myproc>
    80001ff2:	89aa                	mv	s3,a0
  if (p == initproc)
    80001ff4:	00006797          	auipc	a5,0x6
    80001ff8:	86c7b783          	ld	a5,-1940(a5) # 80007860 <initproc>
    80001ffc:	0d050493          	addi	s1,a0,208
    80002000:	15050913          	addi	s2,a0,336
    80002004:	00a79b63          	bne	a5,a0,8000201a <kexit+0x3e>
    panic("init exiting");
    80002008:	00005517          	auipc	a0,0x5
    8000200c:	1d850513          	addi	a0,a0,472 # 800071e0 <etext+0x1e0>
    80002010:	82bfe0ef          	jal	8000083a <panic>
  for (int fd = 0; fd < NOFILE; fd++) {
    80002014:	04a1                	addi	s1,s1,8
    80002016:	01248963          	beq	s1,s2,80002028 <kexit+0x4c>
    if (p->ofile[fd]) {
    8000201a:	6088                	ld	a0,0(s1)
    8000201c:	dd65                	beqz	a0,80002014 <kexit+0x38>
      fileclose(f);
    8000201e:	014020ef          	jal	80004032 <fileclose>
      p->ofile[fd] = 0;
    80002022:	0004b023          	sd	zero,0(s1)
    80002026:	b7fd                	j	80002014 <kexit+0x38>
  begin_op();
    80002028:	38d010ef          	jal	80003bb4 <begin_op>
  iput(p->cwd);
    8000202c:	1509b503          	ld	a0,336(s3)
    80002030:	2ea010ef          	jal	8000331a <iput>
  end_op();
    80002034:	3f1010ef          	jal	80003c24 <end_op>
  p->cwd = 0;
    80002038:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000203c:	0000e517          	auipc	a0,0xe
    80002040:	94450513          	addi	a0,a0,-1724 # 8000f980 <wait_lock>
    80002044:	bd5fe0ef          	jal	80000c18 <acquire>
  reparent(p);
    80002048:	854e                	mv	a0,s3
    8000204a:	f3dff0ef          	jal	80001f86 <reparent>
  wakeup(p->parent);
    8000204e:	0389b503          	ld	a0,56(s3)
    80002052:	ecbff0ef          	jal	80001f1c <wakeup>
  acquire(&p->lock);
    80002056:	854e                	mv	a0,s3
    80002058:	bc1fe0ef          	jal	80000c18 <acquire>
  p->xstate = status;
    8000205c:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002060:	4795                	li	a5,5
    80002062:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002066:	0000e517          	auipc	a0,0xe
    8000206a:	91a50513          	addi	a0,a0,-1766 # 8000f980 <wait_lock>
    8000206e:	c2ffe0ef          	jal	80000c9c <release>
  sched();
    80002072:	d79ff0ef          	jal	80001dea <sched>
  panic("zombie exit");
    80002076:	00005517          	auipc	a0,0x5
    8000207a:	17a50513          	addi	a0,a0,378 # 800071f0 <etext+0x1f0>
    8000207e:	fbcfe0ef          	jal	8000083a <panic>

0000000080002082 <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    80002082:	7179                	addi	sp,sp,-48
    80002084:	f406                	sd	ra,40(sp)
    80002086:	f022                	sd	s0,32(sp)
    80002088:	ec26                	sd	s1,24(sp)
    8000208a:	e84a                	sd	s2,16(sp)
    8000208c:	e44e                	sd	s3,8(sp)
    8000208e:	1800                	addi	s0,sp,48
    80002090:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80002092:	0000e497          	auipc	s1,0xe
    80002096:	d0648493          	addi	s1,s1,-762 # 8000fd98 <proc>
    8000209a:	00013997          	auipc	s3,0x13
    8000209e:	6fe98993          	addi	s3,s3,1790 # 80015798 <tickslock>
    acquire(&p->lock);
    800020a2:	8526                	mv	a0,s1
    800020a4:	b75fe0ef          	jal	80000c18 <acquire>
    if (p->pid == pid) {
    800020a8:	589c                	lw	a5,48(s1)
    800020aa:	01278b63          	beq	a5,s2,800020c0 <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800020ae:	8526                	mv	a0,s1
    800020b0:	bedfe0ef          	jal	80000c9c <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    800020b4:	16848493          	addi	s1,s1,360
    800020b8:	ff3495e3          	bne	s1,s3,800020a2 <kkill+0x20>
  }
  return -1;
    800020bc:	557d                	li	a0,-1
    800020be:	a819                	j	800020d4 <kkill+0x52>
      p->killed = 1;
    800020c0:	4785                	li	a5,1
    800020c2:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING) {
    800020c4:	4c98                	lw	a4,24(s1)
    800020c6:	4789                	li	a5,2
    800020c8:	00f70d63          	beq	a4,a5,800020e2 <kkill+0x60>
      release(&p->lock);
    800020cc:	8526                	mv	a0,s1
    800020ce:	bcffe0ef          	jal	80000c9c <release>
      return 0;
    800020d2:	4501                	li	a0,0
}
    800020d4:	70a2                	ld	ra,40(sp)
    800020d6:	7402                	ld	s0,32(sp)
    800020d8:	64e2                	ld	s1,24(sp)
    800020da:	6942                	ld	s2,16(sp)
    800020dc:	69a2                	ld	s3,8(sp)
    800020de:	6145                	addi	sp,sp,48
    800020e0:	8082                	ret
        p->state = RUNNABLE;
    800020e2:	478d                	li	a5,3
    800020e4:	cc9c                	sw	a5,24(s1)
    800020e6:	b7dd                	j	800020cc <kkill+0x4a>

00000000800020e8 <setkilled>:

void
setkilled(struct proc *p)
{
    800020e8:	1101                	addi	sp,sp,-32
    800020ea:	ec06                	sd	ra,24(sp)
    800020ec:	e822                	sd	s0,16(sp)
    800020ee:	e426                	sd	s1,8(sp)
    800020f0:	1000                	addi	s0,sp,32
    800020f2:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020f4:	b25fe0ef          	jal	80000c18 <acquire>
  p->killed = 1;
    800020f8:	4785                	li	a5,1
    800020fa:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800020fc:	8526                	mv	a0,s1
    800020fe:	b9ffe0ef          	jal	80000c9c <release>
}
    80002102:	60e2                	ld	ra,24(sp)
    80002104:	6442                	ld	s0,16(sp)
    80002106:	64a2                	ld	s1,8(sp)
    80002108:	6105                	addi	sp,sp,32
    8000210a:	8082                	ret

000000008000210c <killed>:

int
killed(struct proc *p)
{
    8000210c:	1101                	addi	sp,sp,-32
    8000210e:	ec06                	sd	ra,24(sp)
    80002110:	e822                	sd	s0,16(sp)
    80002112:	e426                	sd	s1,8(sp)
    80002114:	e04a                	sd	s2,0(sp)
    80002116:	1000                	addi	s0,sp,32
    80002118:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    8000211a:	afffe0ef          	jal	80000c18 <acquire>
  k = p->killed;
    8000211e:	549c                	lw	a5,40(s1)
    80002120:	893e                	mv	s2,a5
  release(&p->lock);
    80002122:	8526                	mv	a0,s1
    80002124:	b79fe0ef          	jal	80000c9c <release>
  return k;
}
    80002128:	854a                	mv	a0,s2
    8000212a:	60e2                	ld	ra,24(sp)
    8000212c:	6442                	ld	s0,16(sp)
    8000212e:	64a2                	ld	s1,8(sp)
    80002130:	6902                	ld	s2,0(sp)
    80002132:	6105                	addi	sp,sp,32
    80002134:	8082                	ret

0000000080002136 <kwait>:
{
    80002136:	715d                	addi	sp,sp,-80
    80002138:	e486                	sd	ra,72(sp)
    8000213a:	e0a2                	sd	s0,64(sp)
    8000213c:	fc26                	sd	s1,56(sp)
    8000213e:	f84a                	sd	s2,48(sp)
    80002140:	f44e                	sd	s3,40(sp)
    80002142:	f052                	sd	s4,32(sp)
    80002144:	ec56                	sd	s5,24(sp)
    80002146:	e85a                	sd	s6,16(sp)
    80002148:	e45e                	sd	s7,8(sp)
    8000214a:	0880                	addi	s0,sp,80
    8000214c:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    8000214e:	f90ff0ef          	jal	800018de <myproc>
    80002152:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002154:	0000e517          	auipc	a0,0xe
    80002158:	82c50513          	addi	a0,a0,-2004 # 8000f980 <wait_lock>
    8000215c:	abdfe0ef          	jal	80000c18 <acquire>
        if (pp->state == ZOMBIE) {
    80002160:	4a15                	li	s4,5
        havekids = 1;
    80002162:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002164:	00013997          	auipc	s3,0x13
    80002168:	63498993          	addi	s3,s3,1588 # 80015798 <tickslock>
    sleep(p, &wait_lock); //DOC: wait-sleep
    8000216c:	0000eb17          	auipc	s6,0xe
    80002170:	814b0b13          	addi	s6,s6,-2028 # 8000f980 <wait_lock>
    80002174:	a871                	j	80002210 <kwait+0xda>
          pid = pp->pid;
    80002176:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000217a:	000b8c63          	beqz	s7,80002192 <kwait+0x5c>
    8000217e:	4691                	li	a3,4
    80002180:	02c48613          	addi	a2,s1,44
    80002184:	85de                	mv	a1,s7
    80002186:	05093503          	ld	a0,80(s2)
    8000218a:	c86ff0ef          	jal	80001610 <copyout>
    8000218e:	02054c63          	bltz	a0,800021c6 <kwait+0x90>
          pp->parent = 0;
    80002192:	0204bc23          	sd	zero,56(s1)
          freeproc(pp);
    80002196:	8526                	mv	a0,s1
    80002198:	925ff0ef          	jal	80001abc <freeproc>
          release(&pp->lock);
    8000219c:	8526                	mv	a0,s1
    8000219e:	afffe0ef          	jal	80000c9c <release>
          release(&wait_lock);
    800021a2:	0000d517          	auipc	a0,0xd
    800021a6:	7de50513          	addi	a0,a0,2014 # 8000f980 <wait_lock>
    800021aa:	af3fe0ef          	jal	80000c9c <release>
}
    800021ae:	854e                	mv	a0,s3
    800021b0:	60a6                	ld	ra,72(sp)
    800021b2:	6406                	ld	s0,64(sp)
    800021b4:	74e2                	ld	s1,56(sp)
    800021b6:	7942                	ld	s2,48(sp)
    800021b8:	79a2                	ld	s3,40(sp)
    800021ba:	7a02                	ld	s4,32(sp)
    800021bc:	6ae2                	ld	s5,24(sp)
    800021be:	6b42                	ld	s6,16(sp)
    800021c0:	6ba2                	ld	s7,8(sp)
    800021c2:	6161                	addi	sp,sp,80
    800021c4:	8082                	ret
            release(&pp->lock);
    800021c6:	8526                	mv	a0,s1
    800021c8:	ad5fe0ef          	jal	80000c9c <release>
            release(&wait_lock);
    800021cc:	0000d517          	auipc	a0,0xd
    800021d0:	7b450513          	addi	a0,a0,1972 # 8000f980 <wait_lock>
    800021d4:	ac9fe0ef          	jal	80000c9c <release>
            return -1;
    800021d8:	a881                	j	80002228 <kwait+0xf2>
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800021da:	16848493          	addi	s1,s1,360
    800021de:	03348063          	beq	s1,s3,800021fe <kwait+0xc8>
      if (pp->parent == p) {
    800021e2:	7c9c                	ld	a5,56(s1)
    800021e4:	ff279be3          	bne	a5,s2,800021da <kwait+0xa4>
        acquire(&pp->lock);
    800021e8:	8526                	mv	a0,s1
    800021ea:	a2ffe0ef          	jal	80000c18 <acquire>
        if (pp->state == ZOMBIE) {
    800021ee:	4c9c                	lw	a5,24(s1)
    800021f0:	f94783e3          	beq	a5,s4,80002176 <kwait+0x40>
        release(&pp->lock);
    800021f4:	8526                	mv	a0,s1
    800021f6:	aa7fe0ef          	jal	80000c9c <release>
        havekids = 1;
    800021fa:	8756                	mv	a4,s5
    800021fc:	bff9                	j	800021da <kwait+0xa4>
    if (!havekids || killed(p)) {
    800021fe:	cf19                	beqz	a4,8000221c <kwait+0xe6>
    80002200:	854a                	mv	a0,s2
    80002202:	f0bff0ef          	jal	8000210c <killed>
    80002206:	e919                	bnez	a0,8000221c <kwait+0xe6>
    sleep(p, &wait_lock); //DOC: wait-sleep
    80002208:	85da                	mv	a1,s6
    8000220a:	854a                	mv	a0,s2
    8000220c:	cc5ff0ef          	jal	80001ed0 <sleep>
    havekids = 0;
    80002210:	4701                	li	a4,0
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002212:	0000e497          	auipc	s1,0xe
    80002216:	b8648493          	addi	s1,s1,-1146 # 8000fd98 <proc>
    8000221a:	b7e1                	j	800021e2 <kwait+0xac>
      release(&wait_lock);
    8000221c:	0000d517          	auipc	a0,0xd
    80002220:	76450513          	addi	a0,a0,1892 # 8000f980 <wait_lock>
    80002224:	a79fe0ef          	jal	80000c9c <release>
            return -1;
    80002228:	59fd                	li	s3,-1
    8000222a:	b751                	j	800021ae <kwait+0x78>

000000008000222c <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000222c:	7179                	addi	sp,sp,-48
    8000222e:	f406                	sd	ra,40(sp)
    80002230:	f022                	sd	s0,32(sp)
    80002232:	ec26                	sd	s1,24(sp)
    80002234:	e84a                	sd	s2,16(sp)
    80002236:	e44e                	sd	s3,8(sp)
    80002238:	e052                	sd	s4,0(sp)
    8000223a:	1800                	addi	s0,sp,48
    8000223c:	84aa                	mv	s1,a0
    8000223e:	8a2e                	mv	s4,a1
    80002240:	89b2                	mv	s3,a2
    80002242:	8936                	mv	s2,a3
  struct proc *p = myproc();
    80002244:	e9aff0ef          	jal	800018de <myproc>
  if (user_dst) {
    80002248:	cc99                	beqz	s1,80002266 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    8000224a:	86ca                	mv	a3,s2
    8000224c:	864e                	mv	a2,s3
    8000224e:	85d2                	mv	a1,s4
    80002250:	6928                	ld	a0,80(a0)
    80002252:	bbeff0ef          	jal	80001610 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002256:	70a2                	ld	ra,40(sp)
    80002258:	7402                	ld	s0,32(sp)
    8000225a:	64e2                	ld	s1,24(sp)
    8000225c:	6942                	ld	s2,16(sp)
    8000225e:	69a2                	ld	s3,8(sp)
    80002260:	6a02                	ld	s4,0(sp)
    80002262:	6145                	addi	sp,sp,48
    80002264:	8082                	ret
    memmove((char *)dst, src, len);
    80002266:	0009061b          	sext.w	a2,s2
    8000226a:	85ce                	mv	a1,s3
    8000226c:	8552                	mv	a0,s4
    8000226e:	ac3fe0ef          	jal	80000d30 <memmove>
    return 0;
    80002272:	8526                	mv	a0,s1
    80002274:	b7cd                	j	80002256 <either_copyout+0x2a>

0000000080002276 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002276:	7179                	addi	sp,sp,-48
    80002278:	f406                	sd	ra,40(sp)
    8000227a:	f022                	sd	s0,32(sp)
    8000227c:	ec26                	sd	s1,24(sp)
    8000227e:	e84a                	sd	s2,16(sp)
    80002280:	e44e                	sd	s3,8(sp)
    80002282:	e052                	sd	s4,0(sp)
    80002284:	1800                	addi	s0,sp,48
    80002286:	8a2a                	mv	s4,a0
    80002288:	84ae                	mv	s1,a1
    8000228a:	89b2                	mv	s3,a2
    8000228c:	8936                	mv	s2,a3
  struct proc *p = myproc();
    8000228e:	e50ff0ef          	jal	800018de <myproc>
  if (user_src) {
    80002292:	cc99                	beqz	s1,800022b0 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002294:	86ca                	mv	a3,s2
    80002296:	864e                	mv	a2,s3
    80002298:	85d2                	mv	a1,s4
    8000229a:	6928                	ld	a0,80(a0)
    8000229c:	c2cff0ef          	jal	800016c8 <copyin>
  } else {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    800022a0:	70a2                	ld	ra,40(sp)
    800022a2:	7402                	ld	s0,32(sp)
    800022a4:	64e2                	ld	s1,24(sp)
    800022a6:	6942                	ld	s2,16(sp)
    800022a8:	69a2                	ld	s3,8(sp)
    800022aa:	6a02                	ld	s4,0(sp)
    800022ac:	6145                	addi	sp,sp,48
    800022ae:	8082                	ret
    memmove(dst, (char *)src, len);
    800022b0:	0009061b          	sext.w	a2,s2
    800022b4:	85ce                	mv	a1,s3
    800022b6:	8552                	mv	a0,s4
    800022b8:	a79fe0ef          	jal	80000d30 <memmove>
    return 0;
    800022bc:	8526                	mv	a0,s1
    800022be:	b7cd                	j	800022a0 <either_copyin+0x2a>

00000000800022c0 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800022c0:	715d                	addi	sp,sp,-80
    800022c2:	e486                	sd	ra,72(sp)
    800022c4:	e0a2                	sd	s0,64(sp)
    800022c6:	fc26                	sd	s1,56(sp)
    800022c8:	f84a                	sd	s2,48(sp)
    800022ca:	f44e                	sd	s3,40(sp)
    800022cc:	f052                	sd	s4,32(sp)
    800022ce:	ec56                	sd	s5,24(sp)
    800022d0:	e85a                	sd	s6,16(sp)
    800022d2:	e45e                	sd	s7,8(sp)
    800022d4:	0880                	addi	s0,sp,80
    // clang-format on
  };
  struct proc *p;
  char *state;

  printk("\n");
    800022d6:	00005517          	auipc	a0,0x5
    800022da:	da250513          	addi	a0,a0,-606 # 80007078 <etext+0x78>
    800022de:	a24fe0ef          	jal	80000502 <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    800022e2:	0000e497          	auipc	s1,0xe
    800022e6:	c0e48493          	addi	s1,s1,-1010 # 8000fef0 <proc+0x158>
    800022ea:	00013917          	auipc	s2,0x13
    800022ee:	60690913          	addi	s2,s2,1542 # 800158f0 <bcache+0x140>
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800022f2:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800022f4:	00005a97          	auipc	s5,0x5
    800022f8:	f0ca8a93          	addi	s5,s5,-244 # 80007200 <etext+0x200>
    printk("%d %s %s", p->pid, state, p->name);
    800022fc:	00005a17          	auipc	s4,0x5
    80002300:	f0ca0a13          	addi	s4,s4,-244 # 80007208 <etext+0x208>
    printk("\n");
    80002304:	00005997          	auipc	s3,0x5
    80002308:	d7498993          	addi	s3,s3,-652 # 80007078 <etext+0x78>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000230c:	00005b97          	auipc	s7,0x5
    80002310:	41cb8b93          	addi	s7,s7,1052 # 80007728 <states.0>
    80002314:	a829                	j	8000232e <procdump+0x6e>
    printk("%d %s %s", p->pid, state, p->name);
    80002316:	ed86a583          	lw	a1,-296(a3)
    8000231a:	8552                	mv	a0,s4
    8000231c:	9e6fe0ef          	jal	80000502 <printk>
    printk("\n");
    80002320:	854e                	mv	a0,s3
    80002322:	9e0fe0ef          	jal	80000502 <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002326:	16848493          	addi	s1,s1,360
    8000232a:	03248063          	beq	s1,s2,8000234a <procdump+0x8a>
    if (p->state == UNUSED)
    8000232e:	86a6                	mv	a3,s1
    80002330:	ec04a783          	lw	a5,-320(s1)
    80002334:	dbed                	beqz	a5,80002326 <procdump+0x66>
      state = "???";
    80002336:	8656                	mv	a2,s5
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002338:	fcfb6fe3          	bltu	s6,a5,80002316 <procdump+0x56>
    8000233c:	02079713          	slli	a4,a5,0x20
    80002340:	01d75793          	srli	a5,a4,0x1d
    80002344:	97de                	add	a5,a5,s7
    80002346:	6390                	ld	a2,0(a5)
      state = states[p->state];
    80002348:	b7f9                	j	80002316 <procdump+0x56>
  }
}
    8000234a:	60a6                	ld	ra,72(sp)
    8000234c:	6406                	ld	s0,64(sp)
    8000234e:	74e2                	ld	s1,56(sp)
    80002350:	7942                	ld	s2,48(sp)
    80002352:	79a2                	ld	s3,40(sp)
    80002354:	7a02                	ld	s4,32(sp)
    80002356:	6ae2                	ld	s5,24(sp)
    80002358:	6b42                	ld	s6,16(sp)
    8000235a:	6ba2                	ld	s7,8(sp)
    8000235c:	6161                	addi	sp,sp,80
    8000235e:	8082                	ret

0000000080002360 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    80002360:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80002364:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    80002368:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    8000236a:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    8000236c:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    80002370:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80002374:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    80002378:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    8000237c:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80002380:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80002384:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80002388:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    8000238c:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002390:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80002394:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    80002398:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    8000239c:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    8000239e:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    800023a0:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    800023a4:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    800023a8:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    800023ac:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    800023b0:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    800023b4:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    800023b8:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    800023bc:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    800023c0:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    800023c4:	0685bd83          	ld	s11,104(a1)
        
        ret
    800023c8:	8082                	ret

00000000800023ca <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800023ca:	1141                	addi	sp,sp,-16
    800023cc:	e406                	sd	ra,8(sp)
    800023ce:	e022                	sd	s0,0(sp)
    800023d0:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800023d2:	00005597          	auipc	a1,0x5
    800023d6:	e7658593          	addi	a1,a1,-394 # 80007248 <etext+0x248>
    800023da:	00013517          	auipc	a0,0x13
    800023de:	3be50513          	addi	a0,a0,958 # 80015798 <tickslock>
    800023e2:	fb6fe0ef          	jal	80000b98 <initlock>
}
    800023e6:	60a2                	ld	ra,8(sp)
    800023e8:	6402                	ld	s0,0(sp)
    800023ea:	0141                	addi	sp,sp,16
    800023ec:	8082                	ret

00000000800023ee <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800023ee:	1141                	addi	sp,sp,-16
    800023f0:	e406                	sd	ra,8(sp)
    800023f2:	e022                	sd	s0,0(sp)
    800023f4:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r"(x));
    800023f6:	00003797          	auipc	a5,0x3
    800023fa:	f6a78793          	addi	a5,a5,-150 # 80005360 <kernelvec>
    800023fe:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002402:	60a2                	ld	ra,8(sp)
    80002404:	6402                	ld	s0,0(sp)
    80002406:	0141                	addi	sp,sp,16
    80002408:	8082                	ret

000000008000240a <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    8000240a:	1141                	addi	sp,sp,-16
    8000240c:	e406                	sd	ra,8(sp)
    8000240e:	e022                	sd	s0,0(sp)
    80002410:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002412:	cccff0ef          	jal	800018de <myproc>
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    80002416:	10017073          	csrci	sstatus,2
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000241a:	04000737          	lui	a4,0x4000
    8000241e:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80002420:	0732                	slli	a4,a4,0xc
    80002422:	00004797          	auipc	a5,0x4
    80002426:	bde78793          	addi	a5,a5,-1058 # 80006000 <_trampoline>
    8000242a:	00004697          	auipc	a3,0x4
    8000242e:	bd668693          	addi	a3,a3,-1066 # 80006000 <_trampoline>
    80002432:	8f95                	sub	a5,a5,a3
    80002434:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r"(x));
    80002436:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000243a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r"(x));
    8000243c:	18002773          	csrr	a4,satp
    80002440:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002442:	6d38                	ld	a4,88(a0)
    80002444:	613c                	ld	a5,64(a0)
    80002446:	6685                	lui	a3,0x1
    80002448:	97b6                	add	a5,a5,a3
    8000244a:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000244c:	6d3c                	ld	a5,88(a0)
    8000244e:	00000717          	auipc	a4,0x0
    80002452:	0f470713          	addi	a4,a4,244 # 80002542 <usertrap>
    80002456:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002458:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r"(x));
    8000245a:	8712                	mv	a4,tp
    8000245c:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r"(x));
    8000245e:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002462:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002466:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r"(x));
    8000246a:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000246e:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r"(x));
    80002470:	6f9c                	ld	a5,24(a5)
    80002472:	14179073          	csrw	sepc,a5
}
    80002476:	60a2                	ld	ra,8(sp)
    80002478:	6402                	ld	s0,0(sp)
    8000247a:	0141                	addi	sp,sp,16
    8000247c:	8082                	ret

000000008000247e <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000247e:	1141                	addi	sp,sp,-16
    80002480:	e406                	sd	ra,8(sp)
    80002482:	e022                	sd	s0,0(sp)
    80002484:	0800                	addi	s0,sp,16
  if (cpuid() == 0) {
    80002486:	c24ff0ef          	jal	800018aa <cpuid>
    8000248a:	cd11                	beqz	a0,800024a6 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r"(x));
    8000248c:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002490:	000f4737          	lui	a4,0xf4
    80002494:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002498:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
    8000249a:	14d79073          	csrw	stimecmp,a5
}
    8000249e:	60a2                	ld	ra,8(sp)
    800024a0:	6402                	ld	s0,0(sp)
    800024a2:	0141                	addi	sp,sp,16
    800024a4:	8082                	ret
    acquire(&tickslock);
    800024a6:	00013517          	auipc	a0,0x13
    800024aa:	2f250513          	addi	a0,a0,754 # 80015798 <tickslock>
    800024ae:	f6afe0ef          	jal	80000c18 <acquire>
    ticks++;
    800024b2:	00005717          	auipc	a4,0x5
    800024b6:	3b670713          	addi	a4,a4,950 # 80007868 <ticks>
    800024ba:	431c                	lw	a5,0(a4)
    800024bc:	2785                	addiw	a5,a5,1
    800024be:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    800024c0:	853a                	mv	a0,a4
    800024c2:	a5bff0ef          	jal	80001f1c <wakeup>
    release(&tickslock);
    800024c6:	00013517          	auipc	a0,0x13
    800024ca:	2d250513          	addi	a0,a0,722 # 80015798 <tickslock>
    800024ce:	fcefe0ef          	jal	80000c9c <release>
    800024d2:	bf6d                	j	8000248c <clockintr+0xe>

00000000800024d4 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800024d4:	1101                	addi	sp,sp,-32
    800024d6:	ec06                	sd	ra,24(sp)
    800024d8:	e822                	sd	s0,16(sp)
    800024da:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r"(x));
    800024dc:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if (scause == 0x8000000000000009L) {
    800024e0:	57fd                	li	a5,-1
    800024e2:	17fe                	slli	a5,a5,0x3f
    800024e4:	07a5                	addi	a5,a5,9
    800024e6:	00f70c63          	beq	a4,a5,800024fe <devintr+0x2a>
    // now allowed to interrupt again.
    if (irq)
      plic_complete(irq);

    return 1;
  } else if (scause == 0x8000000000000005L) {
    800024ea:	57fd                	li	a5,-1
    800024ec:	17fe                	slli	a5,a5,0x3f
    800024ee:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    800024f0:	4501                	li	a0,0
  } else if (scause == 0x8000000000000005L) {
    800024f2:	04f70463          	beq	a4,a5,8000253a <devintr+0x66>
  }
}
    800024f6:	60e2                	ld	ra,24(sp)
    800024f8:	6442                	ld	s0,16(sp)
    800024fa:	6105                	addi	sp,sp,32
    800024fc:	8082                	ret
    800024fe:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002500:	70d020ef          	jal	8000540c <plic_claim>
    80002504:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ) {
    80002506:	47a9                	li	a5,10
    80002508:	02f50363          	beq	a0,a5,8000252e <devintr+0x5a>
    } else if (irq == VIRTIO0_IRQ) {
    8000250c:	4785                	li	a5,1
    8000250e:	02f50363          	beq	a0,a5,80002534 <devintr+0x60>
    } else if (irq) {
    80002512:	c919                	beqz	a0,80002528 <devintr+0x54>
      printk("unexpected interrupt irq=%d\n", irq);
    80002514:	85aa                	mv	a1,a0
    80002516:	00005517          	auipc	a0,0x5
    8000251a:	d3a50513          	addi	a0,a0,-710 # 80007250 <etext+0x250>
    8000251e:	fe5fd0ef          	jal	80000502 <printk>
      plic_complete(irq);
    80002522:	8526                	mv	a0,s1
    80002524:	709020ef          	jal	8000542c <plic_complete>
    return 1;
    80002528:	4505                	li	a0,1
    8000252a:	64a2                	ld	s1,8(sp)
    8000252c:	b7e9                	j	800024f6 <devintr+0x22>
      uartintr();
    8000252e:	cb0fe0ef          	jal	800009de <uartintr>
    if (irq)
    80002532:	bfc5                	j	80002522 <devintr+0x4e>
      virtio_disk_intr();
    80002534:	35c030ef          	jal	80005890 <virtio_disk_intr>
    if (irq)
    80002538:	b7ed                	j	80002522 <devintr+0x4e>
    clockintr();
    8000253a:	f45ff0ef          	jal	8000247e <clockintr>
    return 2;
    8000253e:	4509                	li	a0,2
    80002540:	bf5d                	j	800024f6 <devintr+0x22>

0000000080002542 <usertrap>:
{
    80002542:	1101                	addi	sp,sp,-32
    80002544:	ec06                	sd	ra,24(sp)
    80002546:	e822                	sd	s0,16(sp)
    80002548:	e426                	sd	s1,8(sp)
    8000254a:	e04a                	sd	s2,0(sp)
    8000254c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r"(x));
    8000254e:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002552:	1007f793          	andi	a5,a5,256
    80002556:	eba5                	bnez	a5,800025c6 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r"(x));
    80002558:	00003797          	auipc	a5,0x3
    8000255c:	e0878793          	addi	a5,a5,-504 # 80005360 <kernelvec>
    80002560:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002564:	b7aff0ef          	jal	800018de <myproc>
    80002568:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000256a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r"(x));
    8000256c:	14102773          	csrr	a4,sepc
    80002570:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r"(x));
    80002572:	14202773          	csrr	a4,scause
  if (r_scause() == 8) {
    80002576:	47a1                	li	a5,8
    80002578:	04f70d63          	beq	a4,a5,800025d2 <usertrap+0x90>
  } else if ((which_dev = devintr()) != 0) {
    8000257c:	f59ff0ef          	jal	800024d4 <devintr>
    80002580:	892a                	mv	s2,a0
    80002582:	e545                	bnez	a0,8000262a <usertrap+0xe8>
    80002584:	14202773          	csrr	a4,scause
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    80002588:	47bd                	li	a5,15
    8000258a:	08f70463          	beq	a4,a5,80002612 <usertrap+0xd0>
    8000258e:	14202773          	csrr	a4,scause
    80002592:	47b5                	li	a5,13
    80002594:	06f70f63          	beq	a4,a5,80002612 <usertrap+0xd0>
    80002598:	142025f3          	csrr	a1,scause
    printk("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    8000259c:	5890                	lw	a2,48(s1)
    8000259e:	00005517          	auipc	a0,0x5
    800025a2:	cf250513          	addi	a0,a0,-782 # 80007290 <etext+0x290>
    800025a6:	f5dfd0ef          	jal	80000502 <printk>
  asm volatile("csrr %0, sepc" : "=r"(x));
    800025aa:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    800025ae:	14302673          	csrr	a2,stval
    printk("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    800025b2:	00005517          	auipc	a0,0x5
    800025b6:	d0e50513          	addi	a0,a0,-754 # 800072c0 <etext+0x2c0>
    800025ba:	f49fd0ef          	jal	80000502 <printk>
    setkilled(p);
    800025be:	8526                	mv	a0,s1
    800025c0:	b29ff0ef          	jal	800020e8 <setkilled>
    800025c4:	a015                	j	800025e8 <usertrap+0xa6>
    panic("usertrap: not from user mode");
    800025c6:	00005517          	auipc	a0,0x5
    800025ca:	caa50513          	addi	a0,a0,-854 # 80007270 <etext+0x270>
    800025ce:	a6cfe0ef          	jal	8000083a <panic>
    if (killed(p))
    800025d2:	b3bff0ef          	jal	8000210c <killed>
    800025d6:	e915                	bnez	a0,8000260a <usertrap+0xc8>
    p->trapframe->epc += 4;
    800025d8:	6cb8                	ld	a4,88(s1)
    800025da:	6f1c                	ld	a5,24(a4)
    800025dc:	0791                	addi	a5,a5,4
    800025de:	ef1c                	sd	a5,24(a4)
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    800025e0:	10016073          	csrsi	sstatus,2
    syscall();
    800025e4:	23c000ef          	jal	80002820 <syscall>
  if (killed(p))
    800025e8:	8526                	mv	a0,s1
    800025ea:	b23ff0ef          	jal	8000210c <killed>
    800025ee:	e139                	bnez	a0,80002634 <usertrap+0xf2>
  prepare_return();
    800025f0:	e1bff0ef          	jal	8000240a <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800025f4:	68a8                	ld	a0,80(s1)
    800025f6:	8131                	srli	a0,a0,0xc
    800025f8:	57fd                	li	a5,-1
    800025fa:	17fe                	slli	a5,a5,0x3f
    800025fc:	8d5d                	or	a0,a0,a5
}
    800025fe:	60e2                	ld	ra,24(sp)
    80002600:	6442                	ld	s0,16(sp)
    80002602:	64a2                	ld	s1,8(sp)
    80002604:	6902                	ld	s2,0(sp)
    80002606:	6105                	addi	sp,sp,32
    80002608:	8082                	ret
      kexit(-1);
    8000260a:	557d                	li	a0,-1
    8000260c:	9d1ff0ef          	jal	80001fdc <kexit>
    80002610:	b7e1                	j	800025d8 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r"(x));
    80002612:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r"(x));
    80002616:	14202673          	csrr	a2,scause
             vmfault(p->pagetable, r_stval(), (r_scause() == 13) ? 1 : 0) !=
    8000261a:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    8000261c:	00163613          	seqz	a2,a2
    80002620:	68a8                	ld	a0,80(s1)
    80002622:	f6ffe0ef          	jal	80001590 <vmfault>
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    80002626:	f169                	bnez	a0,800025e8 <usertrap+0xa6>
    80002628:	bf85                	j	80002598 <usertrap+0x56>
  if (killed(p))
    8000262a:	8526                	mv	a0,s1
    8000262c:	ae1ff0ef          	jal	8000210c <killed>
    80002630:	c511                	beqz	a0,8000263c <usertrap+0xfa>
    80002632:	a011                	j	80002636 <usertrap+0xf4>
    80002634:	4901                	li	s2,0
    kexit(-1);
    80002636:	557d                	li	a0,-1
    80002638:	9a5ff0ef          	jal	80001fdc <kexit>
  if (which_dev == 2)
    8000263c:	4789                	li	a5,2
    8000263e:	faf919e3          	bne	s2,a5,800025f0 <usertrap+0xae>
    yield();
    80002642:	863ff0ef          	jal	80001ea4 <yield>
    80002646:	b76d                	j	800025f0 <usertrap+0xae>

0000000080002648 <kerneltrap>:
{
    80002648:	7179                	addi	sp,sp,-48
    8000264a:	f406                	sd	ra,40(sp)
    8000264c:	f022                	sd	s0,32(sp)
    8000264e:	ec26                	sd	s1,24(sp)
    80002650:	e84a                	sd	s2,16(sp)
    80002652:	e44e                	sd	s3,8(sp)
    80002654:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002656:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r"(x));
    8000265a:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r"(x));
    8000265e:	142027f3          	csrr	a5,scause
    80002662:	89be                	mv	s3,a5
  if ((sstatus & SSTATUS_SPP) == 0)
    80002664:	1004f793          	andi	a5,s1,256
    80002668:	c795                	beqz	a5,80002694 <kerneltrap+0x4c>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    8000266a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000266e:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    80002670:	eb85                	bnez	a5,800026a0 <kerneltrap+0x58>
  if ((which_dev = devintr()) == 0) {
    80002672:	e63ff0ef          	jal	800024d4 <devintr>
    80002676:	c91d                	beqz	a0,800026ac <kerneltrap+0x64>
  if (which_dev == 2 && myproc() != 0)
    80002678:	4789                	li	a5,2
    8000267a:	04f50a63          	beq	a0,a5,800026ce <kerneltrap+0x86>
  asm volatile("csrw sepc, %0" : : "r"(x));
    8000267e:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r"(x));
    80002682:	10049073          	csrw	sstatus,s1
}
    80002686:	70a2                	ld	ra,40(sp)
    80002688:	7402                	ld	s0,32(sp)
    8000268a:	64e2                	ld	s1,24(sp)
    8000268c:	6942                	ld	s2,16(sp)
    8000268e:	69a2                	ld	s3,8(sp)
    80002690:	6145                	addi	sp,sp,48
    80002692:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002694:	00005517          	auipc	a0,0x5
    80002698:	c5450513          	addi	a0,a0,-940 # 800072e8 <etext+0x2e8>
    8000269c:	99efe0ef          	jal	8000083a <panic>
    panic("kerneltrap: interrupts enabled");
    800026a0:	00005517          	auipc	a0,0x5
    800026a4:	c7050513          	addi	a0,a0,-912 # 80007310 <etext+0x310>
    800026a8:	992fe0ef          	jal	8000083a <panic>
  asm volatile("csrr %0, sepc" : "=r"(x));
    800026ac:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    800026b0:	143026f3          	csrr	a3,stval
    printk("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(),
    800026b4:	85ce                	mv	a1,s3
    800026b6:	00005517          	auipc	a0,0x5
    800026ba:	c7a50513          	addi	a0,a0,-902 # 80007330 <etext+0x330>
    800026be:	e45fd0ef          	jal	80000502 <printk>
    panic("kerneltrap");
    800026c2:	00005517          	auipc	a0,0x5
    800026c6:	c9650513          	addi	a0,a0,-874 # 80007358 <etext+0x358>
    800026ca:	970fe0ef          	jal	8000083a <panic>
  if (which_dev == 2 && myproc() != 0)
    800026ce:	a10ff0ef          	jal	800018de <myproc>
    800026d2:	d555                	beqz	a0,8000267e <kerneltrap+0x36>
    yield();
    800026d4:	fd0ff0ef          	jal	80001ea4 <yield>
    800026d8:	b75d                	j	8000267e <kerneltrap+0x36>

00000000800026da <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800026da:	1101                	addi	sp,sp,-32
    800026dc:	ec06                	sd	ra,24(sp)
    800026de:	e822                	sd	s0,16(sp)
    800026e0:	e426                	sd	s1,8(sp)
    800026e2:	1000                	addi	s0,sp,32
    800026e4:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800026e6:	9f8ff0ef          	jal	800018de <myproc>
  switch (n) {
    800026ea:	4795                	li	a5,5
    800026ec:	0497e163          	bltu	a5,s1,8000272e <argraw+0x54>
    800026f0:	048a                	slli	s1,s1,0x2
    800026f2:	00005717          	auipc	a4,0x5
    800026f6:	06670713          	addi	a4,a4,102 # 80007758 <states.0+0x30>
    800026fa:	94ba                	add	s1,s1,a4
    800026fc:	409c                	lw	a5,0(s1)
    800026fe:	97ba                	add	a5,a5,a4
    80002700:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002702:	6d3c                	ld	a5,88(a0)
    80002704:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002706:	60e2                	ld	ra,24(sp)
    80002708:	6442                	ld	s0,16(sp)
    8000270a:	64a2                	ld	s1,8(sp)
    8000270c:	6105                	addi	sp,sp,32
    8000270e:	8082                	ret
    return p->trapframe->a1;
    80002710:	6d3c                	ld	a5,88(a0)
    80002712:	7fa8                	ld	a0,120(a5)
    80002714:	bfcd                	j	80002706 <argraw+0x2c>
    return p->trapframe->a2;
    80002716:	6d3c                	ld	a5,88(a0)
    80002718:	63c8                	ld	a0,128(a5)
    8000271a:	b7f5                	j	80002706 <argraw+0x2c>
    return p->trapframe->a3;
    8000271c:	6d3c                	ld	a5,88(a0)
    8000271e:	67c8                	ld	a0,136(a5)
    80002720:	b7dd                	j	80002706 <argraw+0x2c>
    return p->trapframe->a4;
    80002722:	6d3c                	ld	a5,88(a0)
    80002724:	6bc8                	ld	a0,144(a5)
    80002726:	b7c5                	j	80002706 <argraw+0x2c>
    return p->trapframe->a5;
    80002728:	6d3c                	ld	a5,88(a0)
    8000272a:	6fc8                	ld	a0,152(a5)
    8000272c:	bfe9                	j	80002706 <argraw+0x2c>
  panic("argraw");
    8000272e:	00005517          	auipc	a0,0x5
    80002732:	c3a50513          	addi	a0,a0,-966 # 80007368 <etext+0x368>
    80002736:	904fe0ef          	jal	8000083a <panic>

000000008000273a <fetchaddr>:
{
    8000273a:	1101                	addi	sp,sp,-32
    8000273c:	ec06                	sd	ra,24(sp)
    8000273e:	e822                	sd	s0,16(sp)
    80002740:	e426                	sd	s1,8(sp)
    80002742:	e04a                	sd	s2,0(sp)
    80002744:	1000                	addi	s0,sp,32
    80002746:	84aa                	mv	s1,a0
    80002748:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000274a:	994ff0ef          	jal	800018de <myproc>
  if (addr >= p->sz ||
    8000274e:	653c                	ld	a5,72(a0)
    80002750:	02f4f663          	bgeu	s1,a5,8000277c <fetchaddr+0x42>
      addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002754:	00848713          	addi	a4,s1,8
  if (addr >= p->sz ||
    80002758:	02e7e263          	bltu	a5,a4,8000277c <fetchaddr+0x42>
  if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    8000275c:	46a1                	li	a3,8
    8000275e:	8626                	mv	a2,s1
    80002760:	85ca                	mv	a1,s2
    80002762:	6928                	ld	a0,80(a0)
    80002764:	f65fe0ef          	jal	800016c8 <copyin>
    80002768:	00a03533          	snez	a0,a0
    8000276c:	40a0053b          	negw	a0,a0
}
    80002770:	60e2                	ld	ra,24(sp)
    80002772:	6442                	ld	s0,16(sp)
    80002774:	64a2                	ld	s1,8(sp)
    80002776:	6902                	ld	s2,0(sp)
    80002778:	6105                	addi	sp,sp,32
    8000277a:	8082                	ret
    return -1;
    8000277c:	557d                	li	a0,-1
    8000277e:	bfcd                	j	80002770 <fetchaddr+0x36>

0000000080002780 <fetchstr>:
{
    80002780:	7179                	addi	sp,sp,-48
    80002782:	f406                	sd	ra,40(sp)
    80002784:	f022                	sd	s0,32(sp)
    80002786:	ec26                	sd	s1,24(sp)
    80002788:	e84a                	sd	s2,16(sp)
    8000278a:	e44e                	sd	s3,8(sp)
    8000278c:	1800                	addi	s0,sp,48
    8000278e:	89aa                	mv	s3,a0
    80002790:	84ae                	mv	s1,a1
    80002792:	8932                	mv	s2,a2
  struct proc *p = myproc();
    80002794:	94aff0ef          	jal	800018de <myproc>
  if (copyinstr(p->pagetable, buf, addr, max) < 0)
    80002798:	86ca                	mv	a3,s2
    8000279a:	864e                	mv	a2,s3
    8000279c:	85a6                	mv	a1,s1
    8000279e:	6928                	ld	a0,80(a0)
    800027a0:	d19fe0ef          	jal	800014b8 <copyinstr>
    800027a4:	00054c63          	bltz	a0,800027bc <fetchstr+0x3c>
  return strlen(buf);
    800027a8:	8526                	mv	a0,s1
    800027aa:	eaafe0ef          	jal	80000e54 <strlen>
}
    800027ae:	70a2                	ld	ra,40(sp)
    800027b0:	7402                	ld	s0,32(sp)
    800027b2:	64e2                	ld	s1,24(sp)
    800027b4:	6942                	ld	s2,16(sp)
    800027b6:	69a2                	ld	s3,8(sp)
    800027b8:	6145                	addi	sp,sp,48
    800027ba:	8082                	ret
    return -1;
    800027bc:	557d                	li	a0,-1
    800027be:	bfc5                	j	800027ae <fetchstr+0x2e>

00000000800027c0 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    800027c0:	1101                	addi	sp,sp,-32
    800027c2:	ec06                	sd	ra,24(sp)
    800027c4:	e822                	sd	s0,16(sp)
    800027c6:	e426                	sd	s1,8(sp)
    800027c8:	1000                	addi	s0,sp,32
    800027ca:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800027cc:	f0fff0ef          	jal	800026da <argraw>
    800027d0:	c088                	sw	a0,0(s1)
}
    800027d2:	60e2                	ld	ra,24(sp)
    800027d4:	6442                	ld	s0,16(sp)
    800027d6:	64a2                	ld	s1,8(sp)
    800027d8:	6105                	addi	sp,sp,32
    800027da:	8082                	ret

00000000800027dc <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    800027dc:	1101                	addi	sp,sp,-32
    800027de:	ec06                	sd	ra,24(sp)
    800027e0:	e822                	sd	s0,16(sp)
    800027e2:	e426                	sd	s1,8(sp)
    800027e4:	1000                	addi	s0,sp,32
    800027e6:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800027e8:	ef3ff0ef          	jal	800026da <argraw>
    800027ec:	e088                	sd	a0,0(s1)
}
    800027ee:	60e2                	ld	ra,24(sp)
    800027f0:	6442                	ld	s0,16(sp)
    800027f2:	64a2                	ld	s1,8(sp)
    800027f4:	6105                	addi	sp,sp,32
    800027f6:	8082                	ret

00000000800027f8 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (not including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800027f8:	1101                	addi	sp,sp,-32
    800027fa:	ec06                	sd	ra,24(sp)
    800027fc:	e822                	sd	s0,16(sp)
    800027fe:	e426                	sd	s1,8(sp)
    80002800:	e04a                	sd	s2,0(sp)
    80002802:	1000                	addi	s0,sp,32
    80002804:	892e                	mv	s2,a1
    80002806:	84b2                	mv	s1,a2
  *ip = argraw(n);
    80002808:	ed3ff0ef          	jal	800026da <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    8000280c:	8626                	mv	a2,s1
    8000280e:	85ca                	mv	a1,s2
    80002810:	f71ff0ef          	jal	80002780 <fetchstr>
}
    80002814:	60e2                	ld	ra,24(sp)
    80002816:	6442                	ld	s0,16(sp)
    80002818:	64a2                	ld	s1,8(sp)
    8000281a:	6902                	ld	s2,0(sp)
    8000281c:	6105                	addi	sp,sp,32
    8000281e:	8082                	ret

0000000080002820 <syscall>:
  // clang-format on
};

void
syscall(void)
{
    80002820:	1101                	addi	sp,sp,-32
    80002822:	ec06                	sd	ra,24(sp)
    80002824:	e822                	sd	s0,16(sp)
    80002826:	e426                	sd	s1,8(sp)
    80002828:	e04a                	sd	s2,0(sp)
    8000282a:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    8000282c:	8b2ff0ef          	jal	800018de <myproc>
    80002830:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002832:	05853903          	ld	s2,88(a0)
    80002836:	0a893783          	ld	a5,168(s2)
    8000283a:	0007869b          	sext.w	a3,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    8000283e:	37fd                	addiw	a5,a5,-1
    80002840:	4759                	li	a4,22
    80002842:	00f76f63          	bltu	a4,a5,80002860 <syscall+0x40>
    80002846:	00369713          	slli	a4,a3,0x3
    8000284a:	00005797          	auipc	a5,0x5
    8000284e:	f2678793          	addi	a5,a5,-218 # 80007770 <syscalls>
    80002852:	97ba                	add	a5,a5,a4
    80002854:	639c                	ld	a5,0(a5)
    80002856:	c789                	beqz	a5,80002860 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002858:	9782                	jalr	a5
    8000285a:	06a93823          	sd	a0,112(s2)
    8000285e:	a829                	j	80002878 <syscall+0x58>
  } else {
    printk("%d %s: unknown sys call %d\n", p->pid, p->name, num);
    80002860:	15848613          	addi	a2,s1,344
    80002864:	588c                	lw	a1,48(s1)
    80002866:	00005517          	auipc	a0,0x5
    8000286a:	b0a50513          	addi	a0,a0,-1270 # 80007370 <etext+0x370>
    8000286e:	c95fd0ef          	jal	80000502 <printk>
    p->trapframe->a0 = -1;
    80002872:	6cbc                	ld	a5,88(s1)
    80002874:	577d                	li	a4,-1
    80002876:	fbb8                	sd	a4,112(a5)
  }
}
    80002878:	60e2                	ld	ra,24(sp)
    8000287a:	6442                	ld	s0,16(sp)
    8000287c:	64a2                	ld	s1,8(sp)
    8000287e:	6902                	ld	s2,0(sp)
    80002880:	6105                	addi	sp,sp,32
    80002882:	8082                	ret

0000000080002884 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80002884:	1101                	addi	sp,sp,-32
    80002886:	ec06                	sd	ra,24(sp)
    80002888:	e822                	sd	s0,16(sp)
    8000288a:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    8000288c:	fec40593          	addi	a1,s0,-20
    80002890:	4501                	li	a0,0
    80002892:	f2fff0ef          	jal	800027c0 <argint>
  kexit(n);
    80002896:	fec42503          	lw	a0,-20(s0)
    8000289a:	f42ff0ef          	jal	80001fdc <kexit>
  return 0; // not reached
}
    8000289e:	4501                	li	a0,0
    800028a0:	60e2                	ld	ra,24(sp)
    800028a2:	6442                	ld	s0,16(sp)
    800028a4:	6105                	addi	sp,sp,32
    800028a6:	8082                	ret

00000000800028a8 <sys_getpid>:

uint64
sys_getpid(void)
{
    800028a8:	1141                	addi	sp,sp,-16
    800028aa:	e406                	sd	ra,8(sp)
    800028ac:	e022                	sd	s0,0(sp)
    800028ae:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800028b0:	82eff0ef          	jal	800018de <myproc>
}
    800028b4:	5908                	lw	a0,48(a0)
    800028b6:	60a2                	ld	ra,8(sp)
    800028b8:	6402                	ld	s0,0(sp)
    800028ba:	0141                	addi	sp,sp,16
    800028bc:	8082                	ret

00000000800028be <sys_fork>:

uint64
sys_fork(void)
{
    800028be:	1141                	addi	sp,sp,-16
    800028c0:	e406                	sd	ra,8(sp)
    800028c2:	e022                	sd	s0,0(sp)
    800028c4:	0800                	addi	s0,sp,16
  return kfork();
    800028c6:	b82ff0ef          	jal	80001c48 <kfork>
}
    800028ca:	60a2                	ld	ra,8(sp)
    800028cc:	6402                	ld	s0,0(sp)
    800028ce:	0141                	addi	sp,sp,16
    800028d0:	8082                	ret

00000000800028d2 <sys_wait>:

uint64
sys_wait(void)
{
    800028d2:	1101                	addi	sp,sp,-32
    800028d4:	ec06                	sd	ra,24(sp)
    800028d6:	e822                	sd	s0,16(sp)
    800028d8:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800028da:	fe840593          	addi	a1,s0,-24
    800028de:	4501                	li	a0,0
    800028e0:	efdff0ef          	jal	800027dc <argaddr>
  return kwait(p);
    800028e4:	fe843503          	ld	a0,-24(s0)
    800028e8:	84fff0ef          	jal	80002136 <kwait>
}
    800028ec:	60e2                	ld	ra,24(sp)
    800028ee:	6442                	ld	s0,16(sp)
    800028f0:	6105                	addi	sp,sp,32
    800028f2:	8082                	ret

00000000800028f4 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800028f4:	7179                	addi	sp,sp,-48
    800028f6:	f406                	sd	ra,40(sp)
    800028f8:	f022                	sd	s0,32(sp)
    800028fa:	ec26                	sd	s1,24(sp)
    800028fc:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    800028fe:	fd840593          	addi	a1,s0,-40
    80002902:	4501                	li	a0,0
    80002904:	ebdff0ef          	jal	800027c0 <argint>
  argint(1, &t);
    80002908:	fdc40593          	addi	a1,s0,-36
    8000290c:	4505                	li	a0,1
    8000290e:	eb3ff0ef          	jal	800027c0 <argint>
  addr = myproc()->sz;
    80002912:	fcdfe0ef          	jal	800018de <myproc>
    80002916:	6524                	ld	s1,72(a0)

  if (t == SBRK_EAGER || n < 0) {
    80002918:	fdc42703          	lw	a4,-36(s0)
    8000291c:	4785                	li	a5,1
    8000291e:	02f70a63          	beq	a4,a5,80002952 <sys_sbrk+0x5e>
    80002922:	fd842783          	lw	a5,-40(s0)
    80002926:	0207c663          	bltz	a5,80002952 <sys_sbrk+0x5e>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if (addr + n < addr)
    8000292a:	00978733          	add	a4,a5,s1
      return -1;
    if (addr + n > TRAPFRAME)
    8000292e:	020007b7          	lui	a5,0x2000
    80002932:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80002934:	07b6                	slli	a5,a5,0xd
    80002936:	00e7b7b3          	sltu	a5,a5,a4
    if (addr + n < addr)
    8000293a:	00973733          	sltu	a4,a4,s1
    if (addr + n > TRAPFRAME)
    8000293e:	8fd9                	or	a5,a5,a4
    80002940:	e79d                	bnez	a5,8000296e <sys_sbrk+0x7a>
      return -1;
    myproc()->sz += n;
    80002942:	f9dfe0ef          	jal	800018de <myproc>
    80002946:	fd842703          	lw	a4,-40(s0)
    8000294a:	653c                	ld	a5,72(a0)
    8000294c:	97ba                	add	a5,a5,a4
    8000294e:	e53c                	sd	a5,72(a0)
    80002950:	a039                	j	8000295e <sys_sbrk+0x6a>
    if (growproc(n) < 0) {
    80002952:	fd842503          	lw	a0,-40(s0)
    80002956:	a94ff0ef          	jal	80001bea <growproc>
    8000295a:	00054863          	bltz	a0,8000296a <sys_sbrk+0x76>
  }
  return addr;
}
    8000295e:	8526                	mv	a0,s1
    80002960:	70a2                	ld	ra,40(sp)
    80002962:	7402                	ld	s0,32(sp)
    80002964:	64e2                	ld	s1,24(sp)
    80002966:	6145                	addi	sp,sp,48
    80002968:	8082                	ret
      return -1;
    8000296a:	54fd                	li	s1,-1
    8000296c:	bfcd                	j	8000295e <sys_sbrk+0x6a>
      return -1;
    8000296e:	54fd                	li	s1,-1
    80002970:	b7fd                	j	8000295e <sys_sbrk+0x6a>

0000000080002972 <sys_pause>:

uint64
sys_pause(void)
{
    80002972:	7139                	addi	sp,sp,-64
    80002974:	fc06                	sd	ra,56(sp)
    80002976:	f822                	sd	s0,48(sp)
    80002978:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    8000297a:	fcc40593          	addi	a1,s0,-52
    8000297e:	4501                	li	a0,0
    80002980:	e41ff0ef          	jal	800027c0 <argint>
  if (n < 0)
    80002984:	fcc42783          	lw	a5,-52(s0)
    80002988:	0607c863          	bltz	a5,800029f8 <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    8000298c:	00013517          	auipc	a0,0x13
    80002990:	e0c50513          	addi	a0,a0,-500 # 80015798 <tickslock>
    80002994:	a84fe0ef          	jal	80000c18 <acquire>
  ticks0 = ticks;
  while (ticks - ticks0 < n) {
    80002998:	fcc42783          	lw	a5,-52(s0)
    8000299c:	c3b9                	beqz	a5,800029e2 <sys_pause+0x70>
    8000299e:	f426                	sd	s1,40(sp)
    800029a0:	f04a                	sd	s2,32(sp)
    800029a2:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    800029a4:	00005997          	auipc	s3,0x5
    800029a8:	ec49a983          	lw	s3,-316(s3) # 80007868 <ticks>
    if (killed(myproc())) {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800029ac:	00013917          	auipc	s2,0x13
    800029b0:	dec90913          	addi	s2,s2,-532 # 80015798 <tickslock>
    800029b4:	00005497          	auipc	s1,0x5
    800029b8:	eb448493          	addi	s1,s1,-332 # 80007868 <ticks>
    if (killed(myproc())) {
    800029bc:	f23fe0ef          	jal	800018de <myproc>
    800029c0:	f4cff0ef          	jal	8000210c <killed>
    800029c4:	ed0d                	bnez	a0,800029fe <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    800029c6:	85ca                	mv	a1,s2
    800029c8:	8526                	mv	a0,s1
    800029ca:	d06ff0ef          	jal	80001ed0 <sleep>
  while (ticks - ticks0 < n) {
    800029ce:	409c                	lw	a5,0(s1)
    800029d0:	413787bb          	subw	a5,a5,s3
    800029d4:	fcc42703          	lw	a4,-52(s0)
    800029d8:	fee7e2e3          	bltu	a5,a4,800029bc <sys_pause+0x4a>
    800029dc:	74a2                	ld	s1,40(sp)
    800029de:	7902                	ld	s2,32(sp)
    800029e0:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    800029e2:	00013517          	auipc	a0,0x13
    800029e6:	db650513          	addi	a0,a0,-586 # 80015798 <tickslock>
    800029ea:	ab2fe0ef          	jal	80000c9c <release>
  return 0;
    800029ee:	4501                	li	a0,0
}
    800029f0:	70e2                	ld	ra,56(sp)
    800029f2:	7442                	ld	s0,48(sp)
    800029f4:	6121                	addi	sp,sp,64
    800029f6:	8082                	ret
    n = 0;
    800029f8:	fc042623          	sw	zero,-52(s0)
    800029fc:	bf41                	j	8000298c <sys_pause+0x1a>
      release(&tickslock);
    800029fe:	00013517          	auipc	a0,0x13
    80002a02:	d9a50513          	addi	a0,a0,-614 # 80015798 <tickslock>
    80002a06:	a96fe0ef          	jal	80000c9c <release>
      return -1;
    80002a0a:	557d                	li	a0,-1
    80002a0c:	74a2                	ld	s1,40(sp)
    80002a0e:	7902                	ld	s2,32(sp)
    80002a10:	69e2                	ld	s3,24(sp)
    80002a12:	bff9                	j	800029f0 <sys_pause+0x7e>

0000000080002a14 <sys_kill>:

uint64
sys_kill(void)
{
    80002a14:	1101                	addi	sp,sp,-32
    80002a16:	ec06                	sd	ra,24(sp)
    80002a18:	e822                	sd	s0,16(sp)
    80002a1a:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002a1c:	fec40593          	addi	a1,s0,-20
    80002a20:	4501                	li	a0,0
    80002a22:	d9fff0ef          	jal	800027c0 <argint>
  return kkill(pid);
    80002a26:	fec42503          	lw	a0,-20(s0)
    80002a2a:	e58ff0ef          	jal	80002082 <kkill>
}
    80002a2e:	60e2                	ld	ra,24(sp)
    80002a30:	6442                	ld	s0,16(sp)
    80002a32:	6105                	addi	sp,sp,32
    80002a34:	8082                	ret

0000000080002a36 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002a36:	1101                	addi	sp,sp,-32
    80002a38:	ec06                	sd	ra,24(sp)
    80002a3a:	e822                	sd	s0,16(sp)
    80002a3c:	e426                	sd	s1,8(sp)
    80002a3e:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002a40:	00013517          	auipc	a0,0x13
    80002a44:	d5850513          	addi	a0,a0,-680 # 80015798 <tickslock>
    80002a48:	9d0fe0ef          	jal	80000c18 <acquire>
  xticks = ticks;
    80002a4c:	00005797          	auipc	a5,0x5
    80002a50:	e1c7a783          	lw	a5,-484(a5) # 80007868 <ticks>
    80002a54:	84be                	mv	s1,a5
  release(&tickslock);
    80002a56:	00013517          	auipc	a0,0x13
    80002a5a:	d4250513          	addi	a0,a0,-702 # 80015798 <tickslock>
    80002a5e:	a3efe0ef          	jal	80000c9c <release>
  return xticks;
}
    80002a62:	02049513          	slli	a0,s1,0x20
    80002a66:	9101                	srli	a0,a0,0x20
    80002a68:	60e2                	ld	ra,24(sp)
    80002a6a:	6442                	ld	s0,16(sp)
    80002a6c:	64a2                	ld	s1,8(sp)
    80002a6e:	6105                	addi	sp,sp,32
    80002a70:	8082                	ret

0000000080002a72 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002a72:	7179                	addi	sp,sp,-48
    80002a74:	f406                	sd	ra,40(sp)
    80002a76:	f022                	sd	s0,32(sp)
    80002a78:	ec26                	sd	s1,24(sp)
    80002a7a:	e84a                	sd	s2,16(sp)
    80002a7c:	e44e                	sd	s3,8(sp)
    80002a7e:	e052                	sd	s4,0(sp)
    80002a80:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002a82:	00005597          	auipc	a1,0x5
    80002a86:	90e58593          	addi	a1,a1,-1778 # 80007390 <etext+0x390>
    80002a8a:	00013517          	auipc	a0,0x13
    80002a8e:	d2650513          	addi	a0,a0,-730 # 800157b0 <bcache>
    80002a92:	906fe0ef          	jal	80000b98 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002a96:	0001b797          	auipc	a5,0x1b
    80002a9a:	d1a78793          	addi	a5,a5,-742 # 8001d7b0 <bcache+0x8000>
    80002a9e:	0001b717          	auipc	a4,0x1b
    80002aa2:	f7a70713          	addi	a4,a4,-134 # 8001da18 <bcache+0x8268>
    80002aa6:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002aaa:	2ae7bc23          	sd	a4,696(a5)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002aae:	00013497          	auipc	s1,0x13
    80002ab2:	d1a48493          	addi	s1,s1,-742 # 800157c8 <bcache+0x18>
    b->next = bcache.head.next;
    80002ab6:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002ab8:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002aba:	00005a17          	auipc	s4,0x5
    80002abe:	8dea0a13          	addi	s4,s4,-1826 # 80007398 <etext+0x398>
    b->next = bcache.head.next;
    80002ac2:	2b893783          	ld	a5,696(s2)
    80002ac6:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002ac8:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002acc:	85d2                	mv	a1,s4
    80002ace:	01048513          	addi	a0,s1,16
    80002ad2:	39a010ef          	jal	80003e6c <initsleeplock>
    bcache.head.next->prev = b;
    80002ad6:	2b893783          	ld	a5,696(s2)
    80002ada:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002adc:	2a993c23          	sd	s1,696(s2)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002ae0:	45848493          	addi	s1,s1,1112
    80002ae4:	fd349fe3          	bne	s1,s3,80002ac2 <binit+0x50>
  }
}
    80002ae8:	70a2                	ld	ra,40(sp)
    80002aea:	7402                	ld	s0,32(sp)
    80002aec:	64e2                	ld	s1,24(sp)
    80002aee:	6942                	ld	s2,16(sp)
    80002af0:	69a2                	ld	s3,8(sp)
    80002af2:	6a02                	ld	s4,0(sp)
    80002af4:	6145                	addi	sp,sp,48
    80002af6:	8082                	ret

0000000080002af8 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf *
bread(uint dev, uint blockno)
{
    80002af8:	7179                	addi	sp,sp,-48
    80002afa:	f406                	sd	ra,40(sp)
    80002afc:	f022                	sd	s0,32(sp)
    80002afe:	ec26                	sd	s1,24(sp)
    80002b00:	e84a                	sd	s2,16(sp)
    80002b02:	e44e                	sd	s3,8(sp)
    80002b04:	1800                	addi	s0,sp,48
    80002b06:	892a                	mv	s2,a0
    80002b08:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002b0a:	00013517          	auipc	a0,0x13
    80002b0e:	ca650513          	addi	a0,a0,-858 # 800157b0 <bcache>
    80002b12:	906fe0ef          	jal	80000c18 <acquire>
  for (b = bcache.head.next; b != &bcache.head; b = b->next) {
    80002b16:	0001b497          	auipc	s1,0x1b
    80002b1a:	f524b483          	ld	s1,-174(s1) # 8001da68 <bcache+0x82b8>
    80002b1e:	0001b797          	auipc	a5,0x1b
    80002b22:	efa78793          	addi	a5,a5,-262 # 8001da18 <bcache+0x8268>
    80002b26:	02f48b63          	beq	s1,a5,80002b5c <bread+0x64>
    80002b2a:	873e                	mv	a4,a5
    80002b2c:	a021                	j	80002b34 <bread+0x3c>
    80002b2e:	68a4                	ld	s1,80(s1)
    80002b30:	02e48663          	beq	s1,a4,80002b5c <bread+0x64>
    if (b->dev == dev && b->blockno == blockno) {
    80002b34:	449c                	lw	a5,8(s1)
    80002b36:	ff279ce3          	bne	a5,s2,80002b2e <bread+0x36>
    80002b3a:	44dc                	lw	a5,12(s1)
    80002b3c:	ff3799e3          	bne	a5,s3,80002b2e <bread+0x36>
      b->refcnt++;
    80002b40:	40bc                	lw	a5,64(s1)
    80002b42:	2785                	addiw	a5,a5,1
    80002b44:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002b46:	00013517          	auipc	a0,0x13
    80002b4a:	c6a50513          	addi	a0,a0,-918 # 800157b0 <bcache>
    80002b4e:	94efe0ef          	jal	80000c9c <release>
      acquiresleep(&b->lock);
    80002b52:	01048513          	addi	a0,s1,16
    80002b56:	34c010ef          	jal	80003ea2 <acquiresleep>
      return b;
    80002b5a:	a889                	j	80002bac <bread+0xb4>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002b5c:	0001b497          	auipc	s1,0x1b
    80002b60:	f044b483          	ld	s1,-252(s1) # 8001da60 <bcache+0x82b0>
    80002b64:	0001b797          	auipc	a5,0x1b
    80002b68:	eb478793          	addi	a5,a5,-332 # 8001da18 <bcache+0x8268>
    80002b6c:	00f48863          	beq	s1,a5,80002b7c <bread+0x84>
    80002b70:	873e                	mv	a4,a5
    if (b->refcnt == 0) {
    80002b72:	40bc                	lw	a5,64(s1)
    80002b74:	cb91                	beqz	a5,80002b88 <bread+0x90>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002b76:	64a4                	ld	s1,72(s1)
    80002b78:	fee49de3          	bne	s1,a4,80002b72 <bread+0x7a>
  panic("bget: no buffers");
    80002b7c:	00005517          	auipc	a0,0x5
    80002b80:	82450513          	addi	a0,a0,-2012 # 800073a0 <etext+0x3a0>
    80002b84:	cb7fd0ef          	jal	8000083a <panic>
      b->dev = dev;
    80002b88:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002b8c:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002b90:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002b94:	4785                	li	a5,1
    80002b96:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002b98:	00013517          	auipc	a0,0x13
    80002b9c:	c1850513          	addi	a0,a0,-1000 # 800157b0 <bcache>
    80002ba0:	8fcfe0ef          	jal	80000c9c <release>
      acquiresleep(&b->lock);
    80002ba4:	01048513          	addi	a0,s1,16
    80002ba8:	2fa010ef          	jal	80003ea2 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if (!b->valid) {
    80002bac:	409c                	lw	a5,0(s1)
    80002bae:	cb89                	beqz	a5,80002bc0 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002bb0:	8526                	mv	a0,s1
    80002bb2:	70a2                	ld	ra,40(sp)
    80002bb4:	7402                	ld	s0,32(sp)
    80002bb6:	64e2                	ld	s1,24(sp)
    80002bb8:	6942                	ld	s2,16(sp)
    80002bba:	69a2                	ld	s3,8(sp)
    80002bbc:	6145                	addi	sp,sp,48
    80002bbe:	8082                	ret
    virtio_disk_rw(b, 0);
    80002bc0:	4581                	li	a1,0
    80002bc2:	8526                	mv	a0,s1
    80002bc4:	2bf020ef          	jal	80005682 <virtio_disk_rw>
    b->valid = 1;
    80002bc8:	4785                	li	a5,1
    80002bca:	c09c                	sw	a5,0(s1)
  return b;
    80002bcc:	b7d5                	j	80002bb0 <bread+0xb8>

0000000080002bce <bwrite>:

// Write b's contents to disk.  Must be locked.
// Only the log calls bwrite.
void
bwrite(struct buf *b)
{
    80002bce:	1101                	addi	sp,sp,-32
    80002bd0:	ec06                	sd	ra,24(sp)
    80002bd2:	e822                	sd	s0,16(sp)
    80002bd4:	e426                	sd	s1,8(sp)
    80002bd6:	1000                	addi	s0,sp,32
    80002bd8:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002bda:	0541                	addi	a0,a0,16
    80002bdc:	344010ef          	jal	80003f20 <holdingsleep>
    80002be0:	c911                	beqz	a0,80002bf4 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002be2:	4585                	li	a1,1
    80002be4:	8526                	mv	a0,s1
    80002be6:	29d020ef          	jal	80005682 <virtio_disk_rw>
}
    80002bea:	60e2                	ld	ra,24(sp)
    80002bec:	6442                	ld	s0,16(sp)
    80002bee:	64a2                	ld	s1,8(sp)
    80002bf0:	6105                	addi	sp,sp,32
    80002bf2:	8082                	ret
    panic("bwrite");
    80002bf4:	00004517          	auipc	a0,0x4
    80002bf8:	7c450513          	addi	a0,a0,1988 # 800073b8 <etext+0x3b8>
    80002bfc:	c3ffd0ef          	jal	8000083a <panic>

0000000080002c00 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002c00:	1101                	addi	sp,sp,-32
    80002c02:	ec06                	sd	ra,24(sp)
    80002c04:	e822                	sd	s0,16(sp)
    80002c06:	e426                	sd	s1,8(sp)
    80002c08:	e04a                	sd	s2,0(sp)
    80002c0a:	1000                	addi	s0,sp,32
    80002c0c:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002c0e:	01050913          	addi	s2,a0,16
    80002c12:	854a                	mv	a0,s2
    80002c14:	30c010ef          	jal	80003f20 <holdingsleep>
    80002c18:	c125                	beqz	a0,80002c78 <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    80002c1a:	854a                	mv	a0,s2
    80002c1c:	2cc010ef          	jal	80003ee8 <releasesleep>

  acquire(&bcache.lock);
    80002c20:	00013517          	auipc	a0,0x13
    80002c24:	b9050513          	addi	a0,a0,-1136 # 800157b0 <bcache>
    80002c28:	ff1fd0ef          	jal	80000c18 <acquire>
  b->refcnt--;
    80002c2c:	40bc                	lw	a5,64(s1)
    80002c2e:	37fd                	addiw	a5,a5,-1
    80002c30:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002c32:	e79d                	bnez	a5,80002c60 <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002c34:	68b8                	ld	a4,80(s1)
    80002c36:	64bc                	ld	a5,72(s1)
    80002c38:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002c3a:	68b8                	ld	a4,80(s1)
    80002c3c:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002c3e:	0001b797          	auipc	a5,0x1b
    80002c42:	b7278793          	addi	a5,a5,-1166 # 8001d7b0 <bcache+0x8000>
    80002c46:	2b87b703          	ld	a4,696(a5)
    80002c4a:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002c4c:	0001b717          	auipc	a4,0x1b
    80002c50:	dcc70713          	addi	a4,a4,-564 # 8001da18 <bcache+0x8268>
    80002c54:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002c56:	2b87b703          	ld	a4,696(a5)
    80002c5a:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002c5c:	2a97bc23          	sd	s1,696(a5)
  }

  release(&bcache.lock);
    80002c60:	00013517          	auipc	a0,0x13
    80002c64:	b5050513          	addi	a0,a0,-1200 # 800157b0 <bcache>
    80002c68:	834fe0ef          	jal	80000c9c <release>
}
    80002c6c:	60e2                	ld	ra,24(sp)
    80002c6e:	6442                	ld	s0,16(sp)
    80002c70:	64a2                	ld	s1,8(sp)
    80002c72:	6902                	ld	s2,0(sp)
    80002c74:	6105                	addi	sp,sp,32
    80002c76:	8082                	ret
    panic("brelse");
    80002c78:	00004517          	auipc	a0,0x4
    80002c7c:	74850513          	addi	a0,a0,1864 # 800073c0 <etext+0x3c0>
    80002c80:	bbbfd0ef          	jal	8000083a <panic>

0000000080002c84 <bpin>:

void
bpin(struct buf *b)
{
    80002c84:	1101                	addi	sp,sp,-32
    80002c86:	ec06                	sd	ra,24(sp)
    80002c88:	e822                	sd	s0,16(sp)
    80002c8a:	e426                	sd	s1,8(sp)
    80002c8c:	1000                	addi	s0,sp,32
    80002c8e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002c90:	00013517          	auipc	a0,0x13
    80002c94:	b2050513          	addi	a0,a0,-1248 # 800157b0 <bcache>
    80002c98:	f81fd0ef          	jal	80000c18 <acquire>
  b->refcnt++;
    80002c9c:	40bc                	lw	a5,64(s1)
    80002c9e:	2785                	addiw	a5,a5,1
    80002ca0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002ca2:	00013517          	auipc	a0,0x13
    80002ca6:	b0e50513          	addi	a0,a0,-1266 # 800157b0 <bcache>
    80002caa:	ff3fd0ef          	jal	80000c9c <release>
}
    80002cae:	60e2                	ld	ra,24(sp)
    80002cb0:	6442                	ld	s0,16(sp)
    80002cb2:	64a2                	ld	s1,8(sp)
    80002cb4:	6105                	addi	sp,sp,32
    80002cb6:	8082                	ret

0000000080002cb8 <bunpin>:

void
bunpin(struct buf *b)
{
    80002cb8:	1101                	addi	sp,sp,-32
    80002cba:	ec06                	sd	ra,24(sp)
    80002cbc:	e822                	sd	s0,16(sp)
    80002cbe:	e426                	sd	s1,8(sp)
    80002cc0:	1000                	addi	s0,sp,32
    80002cc2:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002cc4:	00013517          	auipc	a0,0x13
    80002cc8:	aec50513          	addi	a0,a0,-1300 # 800157b0 <bcache>
    80002ccc:	f4dfd0ef          	jal	80000c18 <acquire>
  b->refcnt--;
    80002cd0:	40bc                	lw	a5,64(s1)
    80002cd2:	37fd                	addiw	a5,a5,-1
    80002cd4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002cd6:	00013517          	auipc	a0,0x13
    80002cda:	ada50513          	addi	a0,a0,-1318 # 800157b0 <bcache>
    80002cde:	fbffd0ef          	jal	80000c9c <release>
}
    80002ce2:	60e2                	ld	ra,24(sp)
    80002ce4:	6442                	ld	s0,16(sp)
    80002ce6:	64a2                	ld	s1,8(sp)
    80002ce8:	6105                	addi	sp,sp,32
    80002cea:	8082                	ret

0000000080002cec <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002cec:	1101                	addi	sp,sp,-32
    80002cee:	ec06                	sd	ra,24(sp)
    80002cf0:	e822                	sd	s0,16(sp)
    80002cf2:	e426                	sd	s1,8(sp)
    80002cf4:	e04a                	sd	s2,0(sp)
    80002cf6:	1000                	addi	s0,sp,32
    80002cf8:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002cfa:	00d5d79b          	srliw	a5,a1,0xd
    80002cfe:	0001b597          	auipc	a1,0x1b
    80002d02:	18e5a583          	lw	a1,398(a1) # 8001de8c <sb+0x1c>
    80002d06:	9dbd                	addw	a1,a1,a5
    80002d08:	df1ff0ef          	jal	80002af8 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002d0c:	0074f713          	andi	a4,s1,7
    80002d10:	4785                	li	a5,1
    80002d12:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    80002d16:	14ce                	slli	s1,s1,0x33
  if ((bp->data[bi / 8] & m) == 0)
    80002d18:	90d9                	srli	s1,s1,0x36
    80002d1a:	00950733          	add	a4,a0,s1
    80002d1e:	05874703          	lbu	a4,88(a4)
    80002d22:	00e7f6b3          	and	a3,a5,a4
    80002d26:	c29d                	beqz	a3,80002d4c <bfree+0x60>
    80002d28:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi / 8] &= ~m;
    80002d2a:	94aa                	add	s1,s1,a0
    80002d2c:	fff7c793          	not	a5,a5
    80002d30:	8f7d                	and	a4,a4,a5
    80002d32:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002d36:	010010ef          	jal	80003d46 <log_write>
  brelse(bp);
    80002d3a:	854a                	mv	a0,s2
    80002d3c:	ec5ff0ef          	jal	80002c00 <brelse>
}
    80002d40:	60e2                	ld	ra,24(sp)
    80002d42:	6442                	ld	s0,16(sp)
    80002d44:	64a2                	ld	s1,8(sp)
    80002d46:	6902                	ld	s2,0(sp)
    80002d48:	6105                	addi	sp,sp,32
    80002d4a:	8082                	ret
    panic("freeing free block");
    80002d4c:	00004517          	auipc	a0,0x4
    80002d50:	67c50513          	addi	a0,a0,1660 # 800073c8 <etext+0x3c8>
    80002d54:	ae7fd0ef          	jal	8000083a <panic>

0000000080002d58 <balloc>:
{
    80002d58:	715d                	addi	sp,sp,-80
    80002d5a:	e486                	sd	ra,72(sp)
    80002d5c:	e0a2                	sd	s0,64(sp)
    80002d5e:	fc26                	sd	s1,56(sp)
    80002d60:	0880                	addi	s0,sp,80
  for (b = 0; b < sb.size; b += BPB) {
    80002d62:	0001b797          	auipc	a5,0x1b
    80002d66:	1127a783          	lw	a5,274(a5) # 8001de74 <sb+0x4>
    80002d6a:	0e078263          	beqz	a5,80002e4e <balloc+0xf6>
    80002d6e:	f84a                	sd	s2,48(sp)
    80002d70:	f44e                	sd	s3,40(sp)
    80002d72:	f052                	sd	s4,32(sp)
    80002d74:	ec56                	sd	s5,24(sp)
    80002d76:	e85a                	sd	s6,16(sp)
    80002d78:	e45e                	sd	s7,8(sp)
    80002d7a:	e062                	sd	s8,0(sp)
    80002d7c:	8baa                	mv	s7,a0
    80002d7e:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002d80:	0001bb17          	auipc	s6,0x1b
    80002d84:	0f0b0b13          	addi	s6,s6,240 # 8001de70 <sb>
      m = 1 << (bi % 8);
    80002d88:	4985                	li	s3,1
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002d8a:	6a09                	lui	s4,0x2
  for (b = 0; b < sb.size; b += BPB) {
    80002d8c:	6c09                	lui	s8,0x2
    80002d8e:	a09d                	j	80002df4 <balloc+0x9c>
        bp->data[bi / 8] |= m;           // Mark block in use.
    80002d90:	97ca                	add	a5,a5,s2
    80002d92:	8e55                	or	a2,a2,a3
    80002d94:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002d98:	854a                	mv	a0,s2
    80002d9a:	7ad000ef          	jal	80003d46 <log_write>
        brelse(bp);
    80002d9e:	854a                	mv	a0,s2
    80002da0:	e61ff0ef          	jal	80002c00 <brelse>
  bp = bread(dev, bno);
    80002da4:	85a6                	mv	a1,s1
    80002da6:	855e                	mv	a0,s7
    80002da8:	d51ff0ef          	jal	80002af8 <bread>
    80002dac:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002dae:	40000613          	li	a2,1024
    80002db2:	4581                	li	a1,0
    80002db4:	05850513          	addi	a0,a0,88
    80002db8:	f1dfd0ef          	jal	80000cd4 <memset>
  log_write(bp);
    80002dbc:	854a                	mv	a0,s2
    80002dbe:	789000ef          	jal	80003d46 <log_write>
  brelse(bp);
    80002dc2:	854a                	mv	a0,s2
    80002dc4:	e3dff0ef          	jal	80002c00 <brelse>
        return b + bi;
    80002dc8:	7942                	ld	s2,48(sp)
    80002dca:	79a2                	ld	s3,40(sp)
    80002dcc:	7a02                	ld	s4,32(sp)
    80002dce:	6ae2                	ld	s5,24(sp)
    80002dd0:	6b42                	ld	s6,16(sp)
    80002dd2:	6ba2                	ld	s7,8(sp)
    80002dd4:	6c02                	ld	s8,0(sp)
}
    80002dd6:	8526                	mv	a0,s1
    80002dd8:	60a6                	ld	ra,72(sp)
    80002dda:	6406                	ld	s0,64(sp)
    80002ddc:	74e2                	ld	s1,56(sp)
    80002dde:	6161                	addi	sp,sp,80
    80002de0:	8082                	ret
    brelse(bp);
    80002de2:	854a                	mv	a0,s2
    80002de4:	e1dff0ef          	jal	80002c00 <brelse>
  for (b = 0; b < sb.size; b += BPB) {
    80002de8:	015c0abb          	addw	s5,s8,s5
    80002dec:	004b2783          	lw	a5,4(s6)
    80002df0:	04faf863          	bgeu	s5,a5,80002e40 <balloc+0xe8>
    bp = bread(dev, BBLOCK(b, sb));
    80002df4:	40dad59b          	sraiw	a1,s5,0xd
    80002df8:	01cb2783          	lw	a5,28(s6)
    80002dfc:	9dbd                	addw	a1,a1,a5
    80002dfe:	855e                	mv	a0,s7
    80002e00:	cf9ff0ef          	jal	80002af8 <bread>
    80002e04:	892a                	mv	s2,a0
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002e06:	004b2503          	lw	a0,4(s6)
    80002e0a:	84d6                	mv	s1,s5
    80002e0c:	4701                	li	a4,0
    80002e0e:	fca4fae3          	bgeu	s1,a0,80002de2 <balloc+0x8a>
      m = 1 << (bi % 8);
    80002e12:	00777693          	andi	a3,a4,7
    80002e16:	00d996bb          	sllw	a3,s3,a3
      if ((bp->data[bi / 8] & m) == 0) { // Is block free?
    80002e1a:	41f7579b          	sraiw	a5,a4,0x1f
    80002e1e:	01d7d79b          	srliw	a5,a5,0x1d
    80002e22:	9fb9                	addw	a5,a5,a4
    80002e24:	4037d79b          	sraiw	a5,a5,0x3
    80002e28:	00f90633          	add	a2,s2,a5
    80002e2c:	05864603          	lbu	a2,88(a2)
    80002e30:	00c6f5b3          	and	a1,a3,a2
    80002e34:	ddb1                	beqz	a1,80002d90 <balloc+0x38>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002e36:	2705                	addiw	a4,a4,1
    80002e38:	2485                	addiw	s1,s1,1
    80002e3a:	fd471ae3          	bne	a4,s4,80002e0e <balloc+0xb6>
    80002e3e:	b755                	j	80002de2 <balloc+0x8a>
    80002e40:	7942                	ld	s2,48(sp)
    80002e42:	79a2                	ld	s3,40(sp)
    80002e44:	7a02                	ld	s4,32(sp)
    80002e46:	6ae2                	ld	s5,24(sp)
    80002e48:	6b42                	ld	s6,16(sp)
    80002e4a:	6ba2                	ld	s7,8(sp)
    80002e4c:	6c02                	ld	s8,0(sp)
  printk("balloc: out of blocks\n");
    80002e4e:	00004517          	auipc	a0,0x4
    80002e52:	59250513          	addi	a0,a0,1426 # 800073e0 <etext+0x3e0>
    80002e56:	eacfd0ef          	jal	80000502 <printk>
  return 0;
    80002e5a:	4481                	li	s1,0
    80002e5c:	bfad                	j	80002dd6 <balloc+0x7e>

0000000080002e5e <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002e5e:	7179                	addi	sp,sp,-48
    80002e60:	f406                	sd	ra,40(sp)
    80002e62:	f022                	sd	s0,32(sp)
    80002e64:	ec26                	sd	s1,24(sp)
    80002e66:	e84a                	sd	s2,16(sp)
    80002e68:	e44e                	sd	s3,8(sp)
    80002e6a:	1800                	addi	s0,sp,48
    80002e6c:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if (bn < NDIRECT) {
    80002e6e:	47ad                	li	a5,11
    80002e70:	02b7e363          	bltu	a5,a1,80002e96 <bmap+0x38>
    if ((addr = ip->addrs[bn]) == 0) {
    80002e74:	02059793          	slli	a5,a1,0x20
    80002e78:	01e7d593          	srli	a1,a5,0x1e
    80002e7c:	00b509b3          	add	s3,a0,a1
    80002e80:	0509a483          	lw	s1,80(s3)
    80002e84:	e0b5                	bnez	s1,80002ee8 <bmap+0x8a>
      addr = balloc(ip->dev);
    80002e86:	4108                	lw	a0,0(a0)
    80002e88:	ed1ff0ef          	jal	80002d58 <balloc>
    80002e8c:	84aa                	mv	s1,a0
      if (addr == 0)
    80002e8e:	cd29                	beqz	a0,80002ee8 <bmap+0x8a>
        return 0;
      ip->addrs[bn] = addr;
    80002e90:	04a9a823          	sw	a0,80(s3)
    80002e94:	a891                	j	80002ee8 <bmap+0x8a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002e96:	ff45879b          	addiw	a5,a1,-12
    80002e9a:	873e                	mv	a4,a5
    80002e9c:	89be                	mv	s3,a5

  if (bn < NINDIRECT) {
    80002e9e:	0ff00793          	li	a5,255
    80002ea2:	06e7e763          	bltu	a5,a4,80002f10 <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if ((addr = ip->addrs[NDIRECT]) == 0) {
    80002ea6:	08052483          	lw	s1,128(a0)
    80002eaa:	e891                	bnez	s1,80002ebe <bmap+0x60>
      addr = balloc(ip->dev);
    80002eac:	4108                	lw	a0,0(a0)
    80002eae:	eabff0ef          	jal	80002d58 <balloc>
    80002eb2:	84aa                	mv	s1,a0
      if (addr == 0)
    80002eb4:	c915                	beqz	a0,80002ee8 <bmap+0x8a>
    80002eb6:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002eb8:	08a92023          	sw	a0,128(s2)
    80002ebc:	a011                	j	80002ec0 <bmap+0x62>
    80002ebe:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80002ec0:	85a6                	mv	a1,s1
    80002ec2:	00092503          	lw	a0,0(s2)
    80002ec6:	c33ff0ef          	jal	80002af8 <bread>
    80002eca:	8a2a                	mv	s4,a0
    a = (uint *)bp->data;
    80002ecc:	05850793          	addi	a5,a0,88
    if ((addr = a[bn]) == 0) {
    80002ed0:	02099713          	slli	a4,s3,0x20
    80002ed4:	01e75593          	srli	a1,a4,0x1e
    80002ed8:	97ae                	add	a5,a5,a1
    80002eda:	89be                	mv	s3,a5
    80002edc:	4384                	lw	s1,0(a5)
    80002ede:	cc89                	beqz	s1,80002ef8 <bmap+0x9a>
      if (addr) {
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002ee0:	8552                	mv	a0,s4
    80002ee2:	d1fff0ef          	jal	80002c00 <brelse>
    return addr;
    80002ee6:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80002ee8:	8526                	mv	a0,s1
    80002eea:	70a2                	ld	ra,40(sp)
    80002eec:	7402                	ld	s0,32(sp)
    80002eee:	64e2                	ld	s1,24(sp)
    80002ef0:	6942                	ld	s2,16(sp)
    80002ef2:	69a2                	ld	s3,8(sp)
    80002ef4:	6145                	addi	sp,sp,48
    80002ef6:	8082                	ret
      addr = balloc(ip->dev);
    80002ef8:	00092503          	lw	a0,0(s2)
    80002efc:	e5dff0ef          	jal	80002d58 <balloc>
    80002f00:	84aa                	mv	s1,a0
      if (addr) {
    80002f02:	dd79                	beqz	a0,80002ee0 <bmap+0x82>
        a[bn] = addr;
    80002f04:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    80002f08:	8552                	mv	a0,s4
    80002f0a:	63d000ef          	jal	80003d46 <log_write>
    80002f0e:	bfc9                	j	80002ee0 <bmap+0x82>
    80002f10:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80002f12:	00004517          	auipc	a0,0x4
    80002f16:	4e650513          	addi	a0,a0,1254 # 800073f8 <etext+0x3f8>
    80002f1a:	921fd0ef          	jal	8000083a <panic>

0000000080002f1e <iget>:
{
    80002f1e:	7179                	addi	sp,sp,-48
    80002f20:	f406                	sd	ra,40(sp)
    80002f22:	f022                	sd	s0,32(sp)
    80002f24:	ec26                	sd	s1,24(sp)
    80002f26:	e84a                	sd	s2,16(sp)
    80002f28:	e44e                	sd	s3,8(sp)
    80002f2a:	e052                	sd	s4,0(sp)
    80002f2c:	1800                	addi	s0,sp,48
    80002f2e:	89aa                	mv	s3,a0
    80002f30:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80002f32:	0001b517          	auipc	a0,0x1b
    80002f36:	f5e50513          	addi	a0,a0,-162 # 8001de90 <itable>
    80002f3a:	cdffd0ef          	jal	80000c18 <acquire>
  empty = 0;
    80002f3e:	4901                	li	s2,0
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    80002f40:	0001b497          	auipc	s1,0x1b
    80002f44:	f6848493          	addi	s1,s1,-152 # 8001dea8 <itable+0x18>
    80002f48:	0001d697          	auipc	a3,0x1d
    80002f4c:	9f068693          	addi	a3,a3,-1552 # 8001f938 <log>
    80002f50:	a819                	j	80002f66 <iget+0x48>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    80002f52:	0017b793          	seqz	a5,a5
    80002f56:	00193713          	seqz	a4,s2
    80002f5a:	8ff9                	and	a5,a5,a4
    80002f5c:	eb85                	bnez	a5,80002f8c <iget+0x6e>
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    80002f5e:	08848493          	addi	s1,s1,136
    80002f62:	02d48763          	beq	s1,a3,80002f90 <iget+0x72>
    if (ip->ref > 0 && ip->dev == dev && ip->inum == inum) {
    80002f66:	449c                	lw	a5,8(s1)
    80002f68:	fef055e3          	blez	a5,80002f52 <iget+0x34>
    80002f6c:	4098                	lw	a4,0(s1)
    80002f6e:	ff3718e3          	bne	a4,s3,80002f5e <iget+0x40>
    80002f72:	40d8                	lw	a4,4(s1)
    80002f74:	ff4715e3          	bne	a4,s4,80002f5e <iget+0x40>
      ip->ref++;
    80002f78:	2785                	addiw	a5,a5,1
    80002f7a:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80002f7c:	0001b517          	auipc	a0,0x1b
    80002f80:	f1450513          	addi	a0,a0,-236 # 8001de90 <itable>
    80002f84:	d19fd0ef          	jal	80000c9c <release>
      return ip;
    80002f88:	8926                	mv	s2,s1
    80002f8a:	a025                	j	80002fb2 <iget+0x94>
      empty = ip;
    80002f8c:	8926                	mv	s2,s1
    80002f8e:	bfc1                	j	80002f5e <iget+0x40>
  if (empty == 0)
    80002f90:	02090a63          	beqz	s2,80002fc4 <iget+0xa6>
  ip->dev = dev;
    80002f94:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80002f98:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80002f9c:	4785                	li	a5,1
    80002f9e:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80002fa2:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80002fa6:	0001b517          	auipc	a0,0x1b
    80002faa:	eea50513          	addi	a0,a0,-278 # 8001de90 <itable>
    80002fae:	ceffd0ef          	jal	80000c9c <release>
}
    80002fb2:	854a                	mv	a0,s2
    80002fb4:	70a2                	ld	ra,40(sp)
    80002fb6:	7402                	ld	s0,32(sp)
    80002fb8:	64e2                	ld	s1,24(sp)
    80002fba:	6942                	ld	s2,16(sp)
    80002fbc:	69a2                	ld	s3,8(sp)
    80002fbe:	6a02                	ld	s4,0(sp)
    80002fc0:	6145                	addi	sp,sp,48
    80002fc2:	8082                	ret
    panic("iget: no inodes");
    80002fc4:	00004517          	auipc	a0,0x4
    80002fc8:	44c50513          	addi	a0,a0,1100 # 80007410 <etext+0x410>
    80002fcc:	86ffd0ef          	jal	8000083a <panic>

0000000080002fd0 <iinit>:
{
    80002fd0:	7179                	addi	sp,sp,-48
    80002fd2:	f406                	sd	ra,40(sp)
    80002fd4:	f022                	sd	s0,32(sp)
    80002fd6:	ec26                	sd	s1,24(sp)
    80002fd8:	e84a                	sd	s2,16(sp)
    80002fda:	e44e                	sd	s3,8(sp)
    80002fdc:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80002fde:	00004597          	auipc	a1,0x4
    80002fe2:	44258593          	addi	a1,a1,1090 # 80007420 <etext+0x420>
    80002fe6:	0001b517          	auipc	a0,0x1b
    80002fea:	eaa50513          	addi	a0,a0,-342 # 8001de90 <itable>
    80002fee:	babfd0ef          	jal	80000b98 <initlock>
  for (i = 0; i < NINODE; i++) {
    80002ff2:	0001b497          	auipc	s1,0x1b
    80002ff6:	ec648493          	addi	s1,s1,-314 # 8001deb8 <itable+0x28>
    80002ffa:	0001d997          	auipc	s3,0x1d
    80002ffe:	94e98993          	addi	s3,s3,-1714 # 8001f948 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003002:	00004917          	auipc	s2,0x4
    80003006:	42690913          	addi	s2,s2,1062 # 80007428 <etext+0x428>
    8000300a:	85ca                	mv	a1,s2
    8000300c:	8526                	mv	a0,s1
    8000300e:	65f000ef          	jal	80003e6c <initsleeplock>
  for (i = 0; i < NINODE; i++) {
    80003012:	08848493          	addi	s1,s1,136
    80003016:	ff349ae3          	bne	s1,s3,8000300a <iinit+0x3a>
}
    8000301a:	70a2                	ld	ra,40(sp)
    8000301c:	7402                	ld	s0,32(sp)
    8000301e:	64e2                	ld	s1,24(sp)
    80003020:	6942                	ld	s2,16(sp)
    80003022:	69a2                	ld	s3,8(sp)
    80003024:	6145                	addi	sp,sp,48
    80003026:	8082                	ret

0000000080003028 <ialloc>:
{
    80003028:	7139                	addi	sp,sp,-64
    8000302a:	fc06                	sd	ra,56(sp)
    8000302c:	f822                	sd	s0,48(sp)
    8000302e:	0080                	addi	s0,sp,64
  for (inum = 1; inum < sb.ninodes; inum++) {
    80003030:	0001b717          	auipc	a4,0x1b
    80003034:	e4c72703          	lw	a4,-436(a4) # 8001de7c <sb+0xc>
    80003038:	4785                	li	a5,1
    8000303a:	06e7f063          	bgeu	a5,a4,8000309a <ialloc+0x72>
    8000303e:	f426                	sd	s1,40(sp)
    80003040:	f04a                	sd	s2,32(sp)
    80003042:	ec4e                	sd	s3,24(sp)
    80003044:	e852                	sd	s4,16(sp)
    80003046:	e456                	sd	s5,8(sp)
    80003048:	e05a                	sd	s6,0(sp)
    8000304a:	8aaa                	mv	s5,a0
    8000304c:	8b2e                	mv	s6,a1
    8000304e:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    80003050:	0001ba17          	auipc	s4,0x1b
    80003054:	e20a0a13          	addi	s4,s4,-480 # 8001de70 <sb>
    80003058:	00495593          	srli	a1,s2,0x4
    8000305c:	018a2783          	lw	a5,24(s4)
    80003060:	9dbd                	addw	a1,a1,a5
    80003062:	8556                	mv	a0,s5
    80003064:	a95ff0ef          	jal	80002af8 <bread>
    80003068:	84aa                	mv	s1,a0
    dip = (struct dinode *)bp->data + inum % IPB;
    8000306a:	05850993          	addi	s3,a0,88
    8000306e:	00f97793          	andi	a5,s2,15
    80003072:	079a                	slli	a5,a5,0x6
    80003074:	99be                	add	s3,s3,a5
    if (dip->type == 0) { // a free inode
    80003076:	00099783          	lh	a5,0(s3)
    8000307a:	cb9d                	beqz	a5,800030b0 <ialloc+0x88>
    brelse(bp);
    8000307c:	b85ff0ef          	jal	80002c00 <brelse>
  for (inum = 1; inum < sb.ninodes; inum++) {
    80003080:	0905                	addi	s2,s2,1
    80003082:	00ca2703          	lw	a4,12(s4)
    80003086:	0009079b          	sext.w	a5,s2
    8000308a:	fce7e7e3          	bltu	a5,a4,80003058 <ialloc+0x30>
    8000308e:	74a2                	ld	s1,40(sp)
    80003090:	7902                	ld	s2,32(sp)
    80003092:	69e2                	ld	s3,24(sp)
    80003094:	6a42                	ld	s4,16(sp)
    80003096:	6aa2                	ld	s5,8(sp)
    80003098:	6b02                	ld	s6,0(sp)
  printk("ialloc: no inodes\n");
    8000309a:	00004517          	auipc	a0,0x4
    8000309e:	39650513          	addi	a0,a0,918 # 80007430 <etext+0x430>
    800030a2:	c60fd0ef          	jal	80000502 <printk>
  return 0;
    800030a6:	4501                	li	a0,0
}
    800030a8:	70e2                	ld	ra,56(sp)
    800030aa:	7442                	ld	s0,48(sp)
    800030ac:	6121                	addi	sp,sp,64
    800030ae:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800030b0:	04000613          	li	a2,64
    800030b4:	4581                	li	a1,0
    800030b6:	854e                	mv	a0,s3
    800030b8:	c1dfd0ef          	jal	80000cd4 <memset>
      dip->type = type;
    800030bc:	01699023          	sh	s6,0(s3)
      log_write(bp); // mark it allocated on the disk
    800030c0:	8526                	mv	a0,s1
    800030c2:	485000ef          	jal	80003d46 <log_write>
      brelse(bp);
    800030c6:	8526                	mv	a0,s1
    800030c8:	b39ff0ef          	jal	80002c00 <brelse>
      return iget(dev, inum);
    800030cc:	0009059b          	sext.w	a1,s2
    800030d0:	8556                	mv	a0,s5
    800030d2:	e4dff0ef          	jal	80002f1e <iget>
    800030d6:	74a2                	ld	s1,40(sp)
    800030d8:	7902                	ld	s2,32(sp)
    800030da:	69e2                	ld	s3,24(sp)
    800030dc:	6a42                	ld	s4,16(sp)
    800030de:	6aa2                	ld	s5,8(sp)
    800030e0:	6b02                	ld	s6,0(sp)
    800030e2:	b7d9                	j	800030a8 <ialloc+0x80>

00000000800030e4 <iupdate>:
{
    800030e4:	1101                	addi	sp,sp,-32
    800030e6:	ec06                	sd	ra,24(sp)
    800030e8:	e822                	sd	s0,16(sp)
    800030ea:	e426                	sd	s1,8(sp)
    800030ec:	e04a                	sd	s2,0(sp)
    800030ee:	1000                	addi	s0,sp,32
    800030f0:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800030f2:	415c                	lw	a5,4(a0)
    800030f4:	0047d79b          	srliw	a5,a5,0x4
    800030f8:	0001b597          	auipc	a1,0x1b
    800030fc:	d905a583          	lw	a1,-624(a1) # 8001de88 <sb+0x18>
    80003100:	9dbd                	addw	a1,a1,a5
    80003102:	4108                	lw	a0,0(a0)
    80003104:	9f5ff0ef          	jal	80002af8 <bread>
    80003108:	892a                	mv	s2,a0
  dip = (struct dinode *)bp->data + ip->inum % IPB;
    8000310a:	05850793          	addi	a5,a0,88
    8000310e:	40d8                	lw	a4,4(s1)
    80003110:	8b3d                	andi	a4,a4,15
    80003112:	071a                	slli	a4,a4,0x6
    80003114:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003116:	04449703          	lh	a4,68(s1)
    8000311a:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000311e:	04649703          	lh	a4,70(s1)
    80003122:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003126:	04849703          	lh	a4,72(s1)
    8000312a:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000312e:	04a49703          	lh	a4,74(s1)
    80003132:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003136:	44f8                	lw	a4,76(s1)
    80003138:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000313a:	03400613          	li	a2,52
    8000313e:	05048593          	addi	a1,s1,80
    80003142:	00c78513          	addi	a0,a5,12
    80003146:	bebfd0ef          	jal	80000d30 <memmove>
  log_write(bp);
    8000314a:	854a                	mv	a0,s2
    8000314c:	3fb000ef          	jal	80003d46 <log_write>
  brelse(bp);
    80003150:	854a                	mv	a0,s2
    80003152:	aafff0ef          	jal	80002c00 <brelse>
}
    80003156:	60e2                	ld	ra,24(sp)
    80003158:	6442                	ld	s0,16(sp)
    8000315a:	64a2                	ld	s1,8(sp)
    8000315c:	6902                	ld	s2,0(sp)
    8000315e:	6105                	addi	sp,sp,32
    80003160:	8082                	ret

0000000080003162 <idup>:
{
    80003162:	1101                	addi	sp,sp,-32
    80003164:	ec06                	sd	ra,24(sp)
    80003166:	e822                	sd	s0,16(sp)
    80003168:	e426                	sd	s1,8(sp)
    8000316a:	1000                	addi	s0,sp,32
    8000316c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000316e:	0001b517          	auipc	a0,0x1b
    80003172:	d2250513          	addi	a0,a0,-734 # 8001de90 <itable>
    80003176:	aa3fd0ef          	jal	80000c18 <acquire>
  ip->ref++;
    8000317a:	449c                	lw	a5,8(s1)
    8000317c:	2785                	addiw	a5,a5,1
    8000317e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003180:	0001b517          	auipc	a0,0x1b
    80003184:	d1050513          	addi	a0,a0,-752 # 8001de90 <itable>
    80003188:	b15fd0ef          	jal	80000c9c <release>
}
    8000318c:	8526                	mv	a0,s1
    8000318e:	60e2                	ld	ra,24(sp)
    80003190:	6442                	ld	s0,16(sp)
    80003192:	64a2                	ld	s1,8(sp)
    80003194:	6105                	addi	sp,sp,32
    80003196:	8082                	ret

0000000080003198 <ilock>:
{
    80003198:	1101                	addi	sp,sp,-32
    8000319a:	ec06                	sd	ra,24(sp)
    8000319c:	e822                	sd	s0,16(sp)
    8000319e:	e426                	sd	s1,8(sp)
    800031a0:	1000                	addi	s0,sp,32
  if (ip == 0 || ip->ref < 1)
    800031a2:	cd19                	beqz	a0,800031c0 <ilock+0x28>
    800031a4:	84aa                	mv	s1,a0
    800031a6:	451c                	lw	a5,8(a0)
    800031a8:	00f05c63          	blez	a5,800031c0 <ilock+0x28>
  acquiresleep(&ip->lock);
    800031ac:	0541                	addi	a0,a0,16
    800031ae:	4f5000ef          	jal	80003ea2 <acquiresleep>
  if (ip->valid == 0) {
    800031b2:	40bc                	lw	a5,64(s1)
    800031b4:	cf89                	beqz	a5,800031ce <ilock+0x36>
}
    800031b6:	60e2                	ld	ra,24(sp)
    800031b8:	6442                	ld	s0,16(sp)
    800031ba:	64a2                	ld	s1,8(sp)
    800031bc:	6105                	addi	sp,sp,32
    800031be:	8082                	ret
    800031c0:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800031c2:	00004517          	auipc	a0,0x4
    800031c6:	28650513          	addi	a0,a0,646 # 80007448 <etext+0x448>
    800031ca:	e70fd0ef          	jal	8000083a <panic>
    800031ce:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800031d0:	40dc                	lw	a5,4(s1)
    800031d2:	0047d79b          	srliw	a5,a5,0x4
    800031d6:	0001b597          	auipc	a1,0x1b
    800031da:	cb25a583          	lw	a1,-846(a1) # 8001de88 <sb+0x18>
    800031de:	9dbd                	addw	a1,a1,a5
    800031e0:	4088                	lw	a0,0(s1)
    800031e2:	917ff0ef          	jal	80002af8 <bread>
    800031e6:	892a                	mv	s2,a0
    dip = (struct dinode *)bp->data + ip->inum % IPB;
    800031e8:	05850593          	addi	a1,a0,88
    800031ec:	40dc                	lw	a5,4(s1)
    800031ee:	8bbd                	andi	a5,a5,15
    800031f0:	079a                	slli	a5,a5,0x6
    800031f2:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800031f4:	00059783          	lh	a5,0(a1)
    800031f8:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800031fc:	00259783          	lh	a5,2(a1)
    80003200:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003204:	00459783          	lh	a5,4(a1)
    80003208:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000320c:	00659783          	lh	a5,6(a1)
    80003210:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003214:	459c                	lw	a5,8(a1)
    80003216:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003218:	03400613          	li	a2,52
    8000321c:	05b1                	addi	a1,a1,12
    8000321e:	05048513          	addi	a0,s1,80
    80003222:	b0ffd0ef          	jal	80000d30 <memmove>
    brelse(bp);
    80003226:	854a                	mv	a0,s2
    80003228:	9d9ff0ef          	jal	80002c00 <brelse>
    ip->valid = 1;
    8000322c:	4785                	li	a5,1
    8000322e:	c0bc                	sw	a5,64(s1)
    if (ip->type == 0)
    80003230:	04449783          	lh	a5,68(s1)
    80003234:	c399                	beqz	a5,8000323a <ilock+0xa2>
    80003236:	6902                	ld	s2,0(sp)
    80003238:	bfbd                	j	800031b6 <ilock+0x1e>
      panic("ilock: no type");
    8000323a:	00004517          	auipc	a0,0x4
    8000323e:	21650513          	addi	a0,a0,534 # 80007450 <etext+0x450>
    80003242:	df8fd0ef          	jal	8000083a <panic>

0000000080003246 <iunlock>:
{
    80003246:	1101                	addi	sp,sp,-32
    80003248:	ec06                	sd	ra,24(sp)
    8000324a:	e822                	sd	s0,16(sp)
    8000324c:	e426                	sd	s1,8(sp)
    8000324e:	e04a                	sd	s2,0(sp)
    80003250:	1000                	addi	s0,sp,32
  if (ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003252:	c505                	beqz	a0,8000327a <iunlock+0x34>
    80003254:	84aa                	mv	s1,a0
    80003256:	01050913          	addi	s2,a0,16
    8000325a:	854a                	mv	a0,s2
    8000325c:	4c5000ef          	jal	80003f20 <holdingsleep>
    80003260:	cd09                	beqz	a0,8000327a <iunlock+0x34>
    80003262:	449c                	lw	a5,8(s1)
    80003264:	00f05b63          	blez	a5,8000327a <iunlock+0x34>
  releasesleep(&ip->lock);
    80003268:	854a                	mv	a0,s2
    8000326a:	47f000ef          	jal	80003ee8 <releasesleep>
}
    8000326e:	60e2                	ld	ra,24(sp)
    80003270:	6442                	ld	s0,16(sp)
    80003272:	64a2                	ld	s1,8(sp)
    80003274:	6902                	ld	s2,0(sp)
    80003276:	6105                	addi	sp,sp,32
    80003278:	8082                	ret
    panic("iunlock");
    8000327a:	00004517          	auipc	a0,0x4
    8000327e:	1e650513          	addi	a0,a0,486 # 80007460 <etext+0x460>
    80003282:	db8fd0ef          	jal	8000083a <panic>

0000000080003286 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003286:	7179                	addi	sp,sp,-48
    80003288:	f406                	sd	ra,40(sp)
    8000328a:	f022                	sd	s0,32(sp)
    8000328c:	ec26                	sd	s1,24(sp)
    8000328e:	e84a                	sd	s2,16(sp)
    80003290:	e44e                	sd	s3,8(sp)
    80003292:	1800                	addi	s0,sp,48
    80003294:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for (i = 0; i < NDIRECT; i++) {
    80003296:	05050493          	addi	s1,a0,80
    8000329a:	08050913          	addi	s2,a0,128
    8000329e:	a021                	j	800032a6 <itrunc+0x20>
    800032a0:	0491                	addi	s1,s1,4
    800032a2:	01248b63          	beq	s1,s2,800032b8 <itrunc+0x32>
    if (ip->addrs[i]) {
    800032a6:	408c                	lw	a1,0(s1)
    800032a8:	dde5                	beqz	a1,800032a0 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800032aa:	0009a503          	lw	a0,0(s3)
    800032ae:	a3fff0ef          	jal	80002cec <bfree>
      ip->addrs[i] = 0;
    800032b2:	0004a023          	sw	zero,0(s1)
    800032b6:	b7ed                	j	800032a0 <itrunc+0x1a>
    }
  }

  if (ip->addrs[NDIRECT]) {
    800032b8:	0809a583          	lw	a1,128(s3)
    800032bc:	ed89                	bnez	a1,800032d6 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800032be:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800032c2:	854e                	mv	a0,s3
    800032c4:	e21ff0ef          	jal	800030e4 <iupdate>
}
    800032c8:	70a2                	ld	ra,40(sp)
    800032ca:	7402                	ld	s0,32(sp)
    800032cc:	64e2                	ld	s1,24(sp)
    800032ce:	6942                	ld	s2,16(sp)
    800032d0:	69a2                	ld	s3,8(sp)
    800032d2:	6145                	addi	sp,sp,48
    800032d4:	8082                	ret
    800032d6:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800032d8:	0009a503          	lw	a0,0(s3)
    800032dc:	81dff0ef          	jal	80002af8 <bread>
    800032e0:	8a2a                	mv	s4,a0
    for (j = 0; j < NINDIRECT; j++) {
    800032e2:	05850493          	addi	s1,a0,88
    800032e6:	45850913          	addi	s2,a0,1112
    800032ea:	a021                	j	800032f2 <itrunc+0x6c>
    800032ec:	0491                	addi	s1,s1,4
    800032ee:	01248963          	beq	s1,s2,80003300 <itrunc+0x7a>
      if (a[j])
    800032f2:	408c                	lw	a1,0(s1)
    800032f4:	dde5                	beqz	a1,800032ec <itrunc+0x66>
        bfree(ip->dev, a[j]);
    800032f6:	0009a503          	lw	a0,0(s3)
    800032fa:	9f3ff0ef          	jal	80002cec <bfree>
    800032fe:	b7fd                	j	800032ec <itrunc+0x66>
    brelse(bp);
    80003300:	8552                	mv	a0,s4
    80003302:	8ffff0ef          	jal	80002c00 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003306:	0809a583          	lw	a1,128(s3)
    8000330a:	0009a503          	lw	a0,0(s3)
    8000330e:	9dfff0ef          	jal	80002cec <bfree>
    ip->addrs[NDIRECT] = 0;
    80003312:	0809a023          	sw	zero,128(s3)
    80003316:	6a02                	ld	s4,0(sp)
    80003318:	b75d                	j	800032be <itrunc+0x38>

000000008000331a <iput>:
{
    8000331a:	1101                	addi	sp,sp,-32
    8000331c:	ec06                	sd	ra,24(sp)
    8000331e:	e822                	sd	s0,16(sp)
    80003320:	e426                	sd	s1,8(sp)
    80003322:	1000                	addi	s0,sp,32
    80003324:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003326:	0001b517          	auipc	a0,0x1b
    8000332a:	b6a50513          	addi	a0,a0,-1174 # 8001de90 <itable>
    8000332e:	8ebfd0ef          	jal	80000c18 <acquire>
  if (ip->ref == 1 && ip->valid && ip->nlink == 0) {
    80003332:	4498                	lw	a4,8(s1)
    80003334:	4785                	li	a5,1
    80003336:	02f70063          	beq	a4,a5,80003356 <iput+0x3c>
  ip->ref--;
    8000333a:	449c                	lw	a5,8(s1)
    8000333c:	37fd                	addiw	a5,a5,-1
    8000333e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003340:	0001b517          	auipc	a0,0x1b
    80003344:	b5050513          	addi	a0,a0,-1200 # 8001de90 <itable>
    80003348:	955fd0ef          	jal	80000c9c <release>
}
    8000334c:	60e2                	ld	ra,24(sp)
    8000334e:	6442                	ld	s0,16(sp)
    80003350:	64a2                	ld	s1,8(sp)
    80003352:	6105                	addi	sp,sp,32
    80003354:	8082                	ret
  if (ip->ref == 1 && ip->valid && ip->nlink == 0) {
    80003356:	40bc                	lw	a5,64(s1)
    80003358:	d3ed                	beqz	a5,8000333a <iput+0x20>
    8000335a:	04a49783          	lh	a5,74(s1)
    8000335e:	fff1                	bnez	a5,8000333a <iput+0x20>
    80003360:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003362:	01048793          	addi	a5,s1,16
    80003366:	893e                	mv	s2,a5
    80003368:	853e                	mv	a0,a5
    8000336a:	339000ef          	jal	80003ea2 <acquiresleep>
    release(&itable.lock);
    8000336e:	0001b517          	auipc	a0,0x1b
    80003372:	b2250513          	addi	a0,a0,-1246 # 8001de90 <itable>
    80003376:	927fd0ef          	jal	80000c9c <release>
    itrunc(ip);
    8000337a:	8526                	mv	a0,s1
    8000337c:	f0bff0ef          	jal	80003286 <itrunc>
    ip->type = 0;
    80003380:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003384:	8526                	mv	a0,s1
    80003386:	d5fff0ef          	jal	800030e4 <iupdate>
    ip->valid = 0;
    8000338a:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000338e:	854a                	mv	a0,s2
    80003390:	359000ef          	jal	80003ee8 <releasesleep>
    acquire(&itable.lock);
    80003394:	0001b517          	auipc	a0,0x1b
    80003398:	afc50513          	addi	a0,a0,-1284 # 8001de90 <itable>
    8000339c:	87dfd0ef          	jal	80000c18 <acquire>
    800033a0:	6902                	ld	s2,0(sp)
    800033a2:	bf61                	j	8000333a <iput+0x20>

00000000800033a4 <iunlockput>:
{
    800033a4:	1101                	addi	sp,sp,-32
    800033a6:	ec06                	sd	ra,24(sp)
    800033a8:	e822                	sd	s0,16(sp)
    800033aa:	e426                	sd	s1,8(sp)
    800033ac:	1000                	addi	s0,sp,32
    800033ae:	84aa                	mv	s1,a0
  iunlock(ip);
    800033b0:	e97ff0ef          	jal	80003246 <iunlock>
  iput(ip);
    800033b4:	8526                	mv	a0,s1
    800033b6:	f65ff0ef          	jal	8000331a <iput>
}
    800033ba:	60e2                	ld	ra,24(sp)
    800033bc:	6442                	ld	s0,16(sp)
    800033be:	64a2                	ld	s1,8(sp)
    800033c0:	6105                	addi	sp,sp,32
    800033c2:	8082                	ret

00000000800033c4 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800033c4:	0001b717          	auipc	a4,0x1b
    800033c8:	ab872703          	lw	a4,-1352(a4) # 8001de7c <sb+0xc>
    800033cc:	4785                	li	a5,1
    800033ce:	0ae7fe63          	bgeu	a5,a4,8000348a <ireclaim+0xc6>
{
    800033d2:	7139                	addi	sp,sp,-64
    800033d4:	fc06                	sd	ra,56(sp)
    800033d6:	f822                	sd	s0,48(sp)
    800033d8:	f426                	sd	s1,40(sp)
    800033da:	f04a                	sd	s2,32(sp)
    800033dc:	ec4e                	sd	s3,24(sp)
    800033de:	e852                	sd	s4,16(sp)
    800033e0:	e456                	sd	s5,8(sp)
    800033e2:	e05a                	sd	s6,0(sp)
    800033e4:	0080                	addi	s0,sp,64
    800033e6:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800033e8:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800033ea:	0001ba17          	auipc	s4,0x1b
    800033ee:	a86a0a13          	addi	s4,s4,-1402 # 8001de70 <sb>
      printk("ireclaim: orphaned inode %d\n", inum);
    800033f2:	00004b17          	auipc	s6,0x4
    800033f6:	076b0b13          	addi	s6,s6,118 # 80007468 <etext+0x468>
    800033fa:	a099                	j	80003440 <ireclaim+0x7c>
    800033fc:	85ce                	mv	a1,s3
    800033fe:	855a                	mv	a0,s6
    80003400:	902fd0ef          	jal	80000502 <printk>
      ip = iget(dev, inum);
    80003404:	85ce                	mv	a1,s3
    80003406:	8556                	mv	a0,s5
    80003408:	b17ff0ef          	jal	80002f1e <iget>
    8000340c:	89aa                	mv	s3,a0
    brelse(bp);
    8000340e:	854a                	mv	a0,s2
    80003410:	ff0ff0ef          	jal	80002c00 <brelse>
    if (ip) {
    80003414:	00098f63          	beqz	s3,80003432 <ireclaim+0x6e>
      begin_op();
    80003418:	79c000ef          	jal	80003bb4 <begin_op>
      ilock(ip);
    8000341c:	854e                	mv	a0,s3
    8000341e:	d7bff0ef          	jal	80003198 <ilock>
      iunlock(ip);
    80003422:	854e                	mv	a0,s3
    80003424:	e23ff0ef          	jal	80003246 <iunlock>
      iput(ip);
    80003428:	854e                	mv	a0,s3
    8000342a:	ef1ff0ef          	jal	8000331a <iput>
      end_op();
    8000342e:	7f6000ef          	jal	80003c24 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003432:	0485                	addi	s1,s1,1
    80003434:	00ca2703          	lw	a4,12(s4)
    80003438:	0004879b          	sext.w	a5,s1
    8000343c:	02e7fd63          	bgeu	a5,a4,80003476 <ireclaim+0xb2>
    80003440:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003444:	0044d593          	srli	a1,s1,0x4
    80003448:	018a2783          	lw	a5,24(s4)
    8000344c:	9dbd                	addw	a1,a1,a5
    8000344e:	8556                	mv	a0,s5
    80003450:	ea8ff0ef          	jal	80002af8 <bread>
    80003454:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003456:	05850793          	addi	a5,a0,88
    8000345a:	00f9f713          	andi	a4,s3,15
    8000345e:	071a                	slli	a4,a4,0x6
    80003460:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) { // is an orphaned inode
    80003462:	00079703          	lh	a4,0(a5)
    80003466:	c701                	beqz	a4,8000346e <ireclaim+0xaa>
    80003468:	00679783          	lh	a5,6(a5)
    8000346c:	dbc1                	beqz	a5,800033fc <ireclaim+0x38>
    brelse(bp);
    8000346e:	854a                	mv	a0,s2
    80003470:	f90ff0ef          	jal	80002c00 <brelse>
    if (ip) {
    80003474:	bf7d                	j	80003432 <ireclaim+0x6e>
}
    80003476:	70e2                	ld	ra,56(sp)
    80003478:	7442                	ld	s0,48(sp)
    8000347a:	74a2                	ld	s1,40(sp)
    8000347c:	7902                	ld	s2,32(sp)
    8000347e:	69e2                	ld	s3,24(sp)
    80003480:	6a42                	ld	s4,16(sp)
    80003482:	6aa2                	ld	s5,8(sp)
    80003484:	6b02                	ld	s6,0(sp)
    80003486:	6121                	addi	sp,sp,64
    80003488:	8082                	ret
    8000348a:	8082                	ret

000000008000348c <fsinit>:
{
    8000348c:	1101                	addi	sp,sp,-32
    8000348e:	ec06                	sd	ra,24(sp)
    80003490:	e822                	sd	s0,16(sp)
    80003492:	e426                	sd	s1,8(sp)
    80003494:	e04a                	sd	s2,0(sp)
    80003496:	1000                	addi	s0,sp,32
    80003498:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000349a:	4585                	li	a1,1
    8000349c:	e5cff0ef          	jal	80002af8 <bread>
    800034a0:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800034a2:	02000613          	li	a2,32
    800034a6:	05850593          	addi	a1,a0,88
    800034aa:	0001b517          	auipc	a0,0x1b
    800034ae:	9c650513          	addi	a0,a0,-1594 # 8001de70 <sb>
    800034b2:	87ffd0ef          	jal	80000d30 <memmove>
  brelse(bp);
    800034b6:	8526                	mv	a0,s1
    800034b8:	f48ff0ef          	jal	80002c00 <brelse>
  if (sb.magic != FSMAGIC)
    800034bc:	0001b717          	auipc	a4,0x1b
    800034c0:	9b472703          	lw	a4,-1612(a4) # 8001de70 <sb>
    800034c4:	102037b7          	lui	a5,0x10203
    800034c8:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800034cc:	02f71263          	bne	a4,a5,800034f0 <fsinit+0x64>
  initlog(dev, &sb);
    800034d0:	0001b597          	auipc	a1,0x1b
    800034d4:	9a058593          	addi	a1,a1,-1632 # 8001de70 <sb>
    800034d8:	854a                	mv	a0,s2
    800034da:	658000ef          	jal	80003b32 <initlog>
  ireclaim(dev);
    800034de:	854a                	mv	a0,s2
    800034e0:	ee5ff0ef          	jal	800033c4 <ireclaim>
}
    800034e4:	60e2                	ld	ra,24(sp)
    800034e6:	6442                	ld	s0,16(sp)
    800034e8:	64a2                	ld	s1,8(sp)
    800034ea:	6902                	ld	s2,0(sp)
    800034ec:	6105                	addi	sp,sp,32
    800034ee:	8082                	ret
    panic("invalid file system");
    800034f0:	00004517          	auipc	a0,0x4
    800034f4:	f9850513          	addi	a0,a0,-104 # 80007488 <etext+0x488>
    800034f8:	b42fd0ef          	jal	8000083a <panic>

00000000800034fc <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800034fc:	1141                	addi	sp,sp,-16
    800034fe:	e406                	sd	ra,8(sp)
    80003500:	e022                	sd	s0,0(sp)
    80003502:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003504:	411c                	lw	a5,0(a0)
    80003506:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003508:	415c                	lw	a5,4(a0)
    8000350a:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000350c:	04451783          	lh	a5,68(a0)
    80003510:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003514:	04a51783          	lh	a5,74(a0)
    80003518:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000351c:	04c56783          	lwu	a5,76(a0)
    80003520:	e99c                	sd	a5,16(a1)
}
    80003522:	60a2                	ld	ra,8(sp)
    80003524:	6402                	ld	s0,0(sp)
    80003526:	0141                	addi	sp,sp,16
    80003528:	8082                	ret

000000008000352a <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    8000352a:	457c                	lw	a5,76(a0)
    8000352c:	0ed7e663          	bltu	a5,a3,80003618 <readi+0xee>
{
    80003530:	7159                	addi	sp,sp,-112
    80003532:	f486                	sd	ra,104(sp)
    80003534:	f0a2                	sd	s0,96(sp)
    80003536:	eca6                	sd	s1,88(sp)
    80003538:	e0d2                	sd	s4,64(sp)
    8000353a:	fc56                	sd	s5,56(sp)
    8000353c:	f85a                	sd	s6,48(sp)
    8000353e:	f45e                	sd	s7,40(sp)
    80003540:	1880                	addi	s0,sp,112
    80003542:	8b2a                	mv	s6,a0
    80003544:	8bae                	mv	s7,a1
    80003546:	8a32                	mv	s4,a2
    80003548:	84b6                	mv	s1,a3
    8000354a:	8aba                	mv	s5,a4
  if (off > ip->size || off + n < off)
    8000354c:	9f35                	addw	a4,a4,a3
    return 0;
    8000354e:	4501                	li	a0,0
  if (off > ip->size || off + n < off)
    80003550:	0ad76b63          	bltu	a4,a3,80003606 <readi+0xdc>
    80003554:	e4ce                	sd	s3,72(sp)
  if (off + n > ip->size)
    80003556:	00e7f463          	bgeu	a5,a4,8000355e <readi+0x34>
    n = ip->size - off;
    8000355a:	40d78abb          	subw	s5,a5,a3

  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    8000355e:	080a8b63          	beqz	s5,800035f4 <readi+0xca>
    80003562:	e8ca                	sd	s2,80(sp)
    80003564:	f062                	sd	s8,32(sp)
    80003566:	ec66                	sd	s9,24(sp)
    80003568:	e86a                	sd	s10,16(sp)
    8000356a:	e46e                	sd	s11,8(sp)
    8000356c:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    8000356e:	40000c93          	li	s9,1024
    if (either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003572:	5c7d                	li	s8,-1
    80003574:	a80d                	j	800035a6 <readi+0x7c>
    80003576:	020d1d93          	slli	s11,s10,0x20
    8000357a:	020ddd93          	srli	s11,s11,0x20
    8000357e:	05890613          	addi	a2,s2,88
    80003582:	86ee                	mv	a3,s11
    80003584:	963e                	add	a2,a2,a5
    80003586:	85d2                	mv	a1,s4
    80003588:	855e                	mv	a0,s7
    8000358a:	ca3fe0ef          	jal	8000222c <either_copyout>
    8000358e:	05850363          	beq	a0,s8,800035d4 <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003592:	854a                	mv	a0,s2
    80003594:	e6cff0ef          	jal	80002c00 <brelse>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    80003598:	013d09bb          	addw	s3,s10,s3
    8000359c:	009d04bb          	addw	s1,s10,s1
    800035a0:	9a6e                	add	s4,s4,s11
    800035a2:	0559f363          	bgeu	s3,s5,800035e8 <readi+0xbe>
    uint addr = bmap(ip, off / BSIZE);
    800035a6:	00a4d59b          	srliw	a1,s1,0xa
    800035aa:	855a                	mv	a0,s6
    800035ac:	8b3ff0ef          	jal	80002e5e <bmap>
    800035b0:	85aa                	mv	a1,a0
    if (addr == 0)
    800035b2:	c139                	beqz	a0,800035f8 <readi+0xce>
    bp = bread(ip->dev, addr);
    800035b4:	000b2503          	lw	a0,0(s6)
    800035b8:	d40ff0ef          	jal	80002af8 <bread>
    800035bc:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    800035be:	3ff4f793          	andi	a5,s1,1023
    800035c2:	40fc873b          	subw	a4,s9,a5
    800035c6:	413a86bb          	subw	a3,s5,s3
    800035ca:	8d3a                	mv	s10,a4
    800035cc:	fae6f5e3          	bgeu	a3,a4,80003576 <readi+0x4c>
    800035d0:	8d36                	mv	s10,a3
    800035d2:	b755                	j	80003576 <readi+0x4c>
      brelse(bp);
    800035d4:	854a                	mv	a0,s2
    800035d6:	e2aff0ef          	jal	80002c00 <brelse>
      tot = -1;
    800035da:	59fd                	li	s3,-1
      break;
    800035dc:	6946                	ld	s2,80(sp)
    800035de:	7c02                	ld	s8,32(sp)
    800035e0:	6ce2                	ld	s9,24(sp)
    800035e2:	6d42                	ld	s10,16(sp)
    800035e4:	6da2                	ld	s11,8(sp)
    800035e6:	a831                	j	80003602 <readi+0xd8>
    800035e8:	6946                	ld	s2,80(sp)
    800035ea:	7c02                	ld	s8,32(sp)
    800035ec:	6ce2                	ld	s9,24(sp)
    800035ee:	6d42                	ld	s10,16(sp)
    800035f0:	6da2                	ld	s11,8(sp)
    800035f2:	a801                	j	80003602 <readi+0xd8>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    800035f4:	89d6                	mv	s3,s5
    800035f6:	a031                	j	80003602 <readi+0xd8>
    800035f8:	6946                	ld	s2,80(sp)
    800035fa:	7c02                	ld	s8,32(sp)
    800035fc:	6ce2                	ld	s9,24(sp)
    800035fe:	6d42                	ld	s10,16(sp)
    80003600:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003602:	854e                	mv	a0,s3
    80003604:	69a6                	ld	s3,72(sp)
}
    80003606:	70a6                	ld	ra,104(sp)
    80003608:	7406                	ld	s0,96(sp)
    8000360a:	64e6                	ld	s1,88(sp)
    8000360c:	6a06                	ld	s4,64(sp)
    8000360e:	7ae2                	ld	s5,56(sp)
    80003610:	7b42                	ld	s6,48(sp)
    80003612:	7ba2                	ld	s7,40(sp)
    80003614:	6165                	addi	sp,sp,112
    80003616:	8082                	ret
    return 0;
    80003618:	4501                	li	a0,0
}
    8000361a:	8082                	ret

000000008000361c <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    8000361c:	457c                	lw	a5,76(a0)
    8000361e:	10d7e163          	bltu	a5,a3,80003720 <writei+0x104>
{
    80003622:	7159                	addi	sp,sp,-112
    80003624:	f486                	sd	ra,104(sp)
    80003626:	f0a2                	sd	s0,96(sp)
    80003628:	e8ca                	sd	s2,80(sp)
    8000362a:	e0d2                	sd	s4,64(sp)
    8000362c:	fc56                	sd	s5,56(sp)
    8000362e:	f85a                	sd	s6,48(sp)
    80003630:	f45e                	sd	s7,40(sp)
    80003632:	1880                	addi	s0,sp,112
    80003634:	8aaa                	mv	s5,a0
    80003636:	8bae                	mv	s7,a1
    80003638:	8a32                	mv	s4,a2
    8000363a:	8936                	mv	s2,a3
    8000363c:	8b3a                	mv	s6,a4
  if (off > ip->size || off + n < off)
    8000363e:	9f35                	addw	a4,a4,a3
    return -1;
  if (off + n > MAXFILE * BSIZE)
    80003640:	000437b7          	lui	a5,0x43
    80003644:	00e7b7b3          	sltu	a5,a5,a4
  if (off > ip->size || off + n < off)
    80003648:	00d73733          	sltu	a4,a4,a3
  if (off + n > MAXFILE * BSIZE)
    8000364c:	8fd9                	or	a5,a5,a4
    8000364e:	ef91                	bnez	a5,8000366a <writei+0x4e>
    80003650:	e4ce                	sd	s3,72(sp)
    return -1;

  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80003652:	0a0b0f63          	beqz	s6,80003710 <writei+0xf4>
    80003656:	eca6                	sd	s1,88(sp)
    80003658:	f062                	sd	s8,32(sp)
    8000365a:	ec66                	sd	s9,24(sp)
    8000365c:	e86a                	sd	s10,16(sp)
    8000365e:	e46e                	sd	s11,8(sp)
    80003660:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    80003662:	40000c93          	li	s9,1024
    if (either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003666:	5c7d                	li	s8,-1
    80003668:	a835                	j	800036a4 <writei+0x88>
    return -1;
    8000366a:	557d                	li	a0,-1
    8000366c:	a849                	j	800036fe <writei+0xe2>
    if (either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000366e:	020d1d93          	slli	s11,s10,0x20
    80003672:	020ddd93          	srli	s11,s11,0x20
    80003676:	05848513          	addi	a0,s1,88
    8000367a:	86ee                	mv	a3,s11
    8000367c:	8652                	mv	a2,s4
    8000367e:	85de                	mv	a1,s7
    80003680:	953e                	add	a0,a0,a5
    80003682:	bf5fe0ef          	jal	80002276 <either_copyin>
    80003686:	05850663          	beq	a0,s8,800036d2 <writei+0xb6>
      // Might have partially updated the block, so we need to log it.
      log_write(bp);
      brelse(bp);
      break;
    }
    log_write(bp);
    8000368a:	8526                	mv	a0,s1
    8000368c:	6ba000ef          	jal	80003d46 <log_write>
    brelse(bp);
    80003690:	8526                	mv	a0,s1
    80003692:	d6eff0ef          	jal	80002c00 <brelse>
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80003696:	013d09bb          	addw	s3,s10,s3
    8000369a:	012d093b          	addw	s2,s10,s2
    8000369e:	9a6e                	add	s4,s4,s11
    800036a0:	0369ff63          	bgeu	s3,s6,800036de <writei+0xc2>
    uint addr = bmap(ip, off / BSIZE);
    800036a4:	00a9559b          	srliw	a1,s2,0xa
    800036a8:	8556                	mv	a0,s5
    800036aa:	fb4ff0ef          	jal	80002e5e <bmap>
    800036ae:	85aa                	mv	a1,a0
    if (addr == 0)
    800036b0:	c51d                	beqz	a0,800036de <writei+0xc2>
    bp = bread(ip->dev, addr);
    800036b2:	000aa503          	lw	a0,0(s5)
    800036b6:	c42ff0ef          	jal	80002af8 <bread>
    800036ba:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    800036bc:	3ff97793          	andi	a5,s2,1023
    800036c0:	40fc873b          	subw	a4,s9,a5
    800036c4:	413b06bb          	subw	a3,s6,s3
    800036c8:	8d3a                	mv	s10,a4
    800036ca:	fae6f2e3          	bgeu	a3,a4,8000366e <writei+0x52>
    800036ce:	8d36                	mv	s10,a3
    800036d0:	bf79                	j	8000366e <writei+0x52>
      log_write(bp);
    800036d2:	8526                	mv	a0,s1
    800036d4:	672000ef          	jal	80003d46 <log_write>
      brelse(bp);
    800036d8:	8526                	mv	a0,s1
    800036da:	d26ff0ef          	jal	80002c00 <brelse>
  }

  if (off > ip->size)
    800036de:	04caa783          	lw	a5,76(s5)
    800036e2:	0327f963          	bgeu	a5,s2,80003714 <writei+0xf8>
    ip->size = off;
    800036e6:	052aa623          	sw	s2,76(s5)
    800036ea:	64e6                	ld	s1,88(sp)
    800036ec:	7c02                	ld	s8,32(sp)
    800036ee:	6ce2                	ld	s9,24(sp)
    800036f0:	6d42                	ld	s10,16(sp)
    800036f2:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800036f4:	8556                	mv	a0,s5
    800036f6:	9efff0ef          	jal	800030e4 <iupdate>

  return tot;
    800036fa:	854e                	mv	a0,s3
    800036fc:	69a6                	ld	s3,72(sp)
}
    800036fe:	70a6                	ld	ra,104(sp)
    80003700:	7406                	ld	s0,96(sp)
    80003702:	6946                	ld	s2,80(sp)
    80003704:	6a06                	ld	s4,64(sp)
    80003706:	7ae2                	ld	s5,56(sp)
    80003708:	7b42                	ld	s6,48(sp)
    8000370a:	7ba2                	ld	s7,40(sp)
    8000370c:	6165                	addi	sp,sp,112
    8000370e:	8082                	ret
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80003710:	89da                	mv	s3,s6
    80003712:	b7cd                	j	800036f4 <writei+0xd8>
    80003714:	64e6                	ld	s1,88(sp)
    80003716:	7c02                	ld	s8,32(sp)
    80003718:	6ce2                	ld	s9,24(sp)
    8000371a:	6d42                	ld	s10,16(sp)
    8000371c:	6da2                	ld	s11,8(sp)
    8000371e:	bfd9                	j	800036f4 <writei+0xd8>
    return -1;
    80003720:	557d                	li	a0,-1
}
    80003722:	8082                	ret

0000000080003724 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003724:	1141                	addi	sp,sp,-16
    80003726:	e406                	sd	ra,8(sp)
    80003728:	e022                	sd	s0,0(sp)
    8000372a:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000372c:	4639                	li	a2,14
    8000372e:	e76fd0ef          	jal	80000da4 <strncmp>
}
    80003732:	60a2                	ld	ra,8(sp)
    80003734:	6402                	ld	s0,0(sp)
    80003736:	0141                	addi	sp,sp,16
    80003738:	8082                	ret

000000008000373a <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode *
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000373a:	711d                	addi	sp,sp,-96
    8000373c:	ec86                	sd	ra,88(sp)
    8000373e:	e8a2                	sd	s0,80(sp)
    80003740:	e4a6                	sd	s1,72(sp)
    80003742:	e0ca                	sd	s2,64(sp)
    80003744:	fc4e                	sd	s3,56(sp)
    80003746:	f852                	sd	s4,48(sp)
    80003748:	f456                	sd	s5,40(sp)
    8000374a:	f05a                	sd	s6,32(sp)
    8000374c:	ec5e                	sd	s7,24(sp)
    8000374e:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if (dp->type != T_DIR)
    80003750:	04451703          	lh	a4,68(a0)
    80003754:	4785                	li	a5,1
    80003756:	02f71963          	bne	a4,a5,80003788 <dirlookup+0x4e>
    8000375a:	892a                	mv	s2,a0
    8000375c:	8aae                	mv	s5,a1
    8000375e:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003760:	457c                	lw	a5,76(a0)
    80003762:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003764:	fa040a13          	addi	s4,s0,-96
    80003768:	49c1                	li	s3,16
      panic("dirlookup read");
    if (de.inum == 0)
      continue;
    if (namecmp(name, de.name) == 0) {
    8000376a:	fa240b13          	addi	s6,s0,-94
  for (off = 0; off < dp->size; off += sizeof(de)) {
    8000376e:	ef95                	bnez	a5,800037aa <dirlookup+0x70>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003770:	4501                	li	a0,0
}
    80003772:	60e6                	ld	ra,88(sp)
    80003774:	6446                	ld	s0,80(sp)
    80003776:	64a6                	ld	s1,72(sp)
    80003778:	6906                	ld	s2,64(sp)
    8000377a:	79e2                	ld	s3,56(sp)
    8000377c:	7a42                	ld	s4,48(sp)
    8000377e:	7aa2                	ld	s5,40(sp)
    80003780:	7b02                	ld	s6,32(sp)
    80003782:	6be2                	ld	s7,24(sp)
    80003784:	6125                	addi	sp,sp,96
    80003786:	8082                	ret
    panic("dirlookup not DIR");
    80003788:	00004517          	auipc	a0,0x4
    8000378c:	d1850513          	addi	a0,a0,-744 # 800074a0 <etext+0x4a0>
    80003790:	8aafd0ef          	jal	8000083a <panic>
      panic("dirlookup read");
    80003794:	00004517          	auipc	a0,0x4
    80003798:	d2450513          	addi	a0,a0,-732 # 800074b8 <etext+0x4b8>
    8000379c:	89efd0ef          	jal	8000083a <panic>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    800037a0:	24c1                	addiw	s1,s1,16
    800037a2:	04c92783          	lw	a5,76(s2)
    800037a6:	fcf4f5e3          	bgeu	s1,a5,80003770 <dirlookup+0x36>
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800037aa:	874e                	mv	a4,s3
    800037ac:	86a6                	mv	a3,s1
    800037ae:	8652                	mv	a2,s4
    800037b0:	4581                	li	a1,0
    800037b2:	854a                	mv	a0,s2
    800037b4:	d77ff0ef          	jal	8000352a <readi>
    800037b8:	fd351ee3          	bne	a0,s3,80003794 <dirlookup+0x5a>
    if (de.inum == 0)
    800037bc:	fa045783          	lhu	a5,-96(s0)
    800037c0:	d3e5                	beqz	a5,800037a0 <dirlookup+0x66>
    if (namecmp(name, de.name) == 0) {
    800037c2:	85da                	mv	a1,s6
    800037c4:	8556                	mv	a0,s5
    800037c6:	f5fff0ef          	jal	80003724 <namecmp>
    800037ca:	f979                	bnez	a0,800037a0 <dirlookup+0x66>
      if (poff)
    800037cc:	000b8463          	beqz	s7,800037d4 <dirlookup+0x9a>
        *poff = off;
    800037d0:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    800037d4:	fa045583          	lhu	a1,-96(s0)
    800037d8:	00092503          	lw	a0,0(s2)
    800037dc:	f42ff0ef          	jal	80002f1e <iget>
    800037e0:	bf49                	j	80003772 <dirlookup+0x38>

00000000800037e2 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode *
namex(char *path, int nameiparent, char *name)
{
    800037e2:	711d                	addi	sp,sp,-96
    800037e4:	ec86                	sd	ra,88(sp)
    800037e6:	e8a2                	sd	s0,80(sp)
    800037e8:	e4a6                	sd	s1,72(sp)
    800037ea:	e0ca                	sd	s2,64(sp)
    800037ec:	fc4e                	sd	s3,56(sp)
    800037ee:	f852                	sd	s4,48(sp)
    800037f0:	f456                	sd	s5,40(sp)
    800037f2:	f05a                	sd	s6,32(sp)
    800037f4:	ec5e                	sd	s7,24(sp)
    800037f6:	e862                	sd	s8,16(sp)
    800037f8:	e466                	sd	s9,8(sp)
    800037fa:	e06a                	sd	s10,0(sp)
    800037fc:	1080                	addi	s0,sp,96
    800037fe:	84aa                	mv	s1,a0
    80003800:	8b2e                	mv	s6,a1
    80003802:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if (*path == '/')
    80003804:	00054703          	lbu	a4,0(a0)
    80003808:	02f00793          	li	a5,47
    8000380c:	00f70f63          	beq	a4,a5,8000382a <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003810:	8cefe0ef          	jal	800018de <myproc>
    80003814:	15053503          	ld	a0,336(a0)
    80003818:	94bff0ef          	jal	80003162 <idup>
    8000381c:	8a2a                	mv	s4,a0
  while (*path == '/')
    8000381e:	02f00993          	li	s3,47
  if (len >= DIRSIZ)
    80003822:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003824:	4cb9                	li	s9,14

  while ((path = skipelem(path, name)) != 0) {
    ilock(ip);
    if (ip->type != T_DIR) {
    80003826:	4b85                	li	s7,1
    80003828:	a879                	j	800038c6 <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    8000382a:	4585                	li	a1,1
    8000382c:	852e                	mv	a0,a1
    8000382e:	ef0ff0ef          	jal	80002f1e <iget>
    80003832:	8a2a                	mv	s4,a0
    80003834:	b7ed                	j	8000381e <namex+0x3c>
      iunlockput(ip);
    80003836:	8552                	mv	a0,s4
    80003838:	b6dff0ef          	jal	800033a4 <iunlockput>
      return 0;
    8000383c:	4a01                	li	s4,0
  if (nameiparent) {
    iput(ip);
    return 0;
  }
  return ip;
}
    8000383e:	8552                	mv	a0,s4
    80003840:	60e6                	ld	ra,88(sp)
    80003842:	6446                	ld	s0,80(sp)
    80003844:	64a6                	ld	s1,72(sp)
    80003846:	6906                	ld	s2,64(sp)
    80003848:	79e2                	ld	s3,56(sp)
    8000384a:	7a42                	ld	s4,48(sp)
    8000384c:	7aa2                	ld	s5,40(sp)
    8000384e:	7b02                	ld	s6,32(sp)
    80003850:	6be2                	ld	s7,24(sp)
    80003852:	6c42                	ld	s8,16(sp)
    80003854:	6ca2                	ld	s9,8(sp)
    80003856:	6d02                	ld	s10,0(sp)
    80003858:	6125                	addi	sp,sp,96
    8000385a:	8082                	ret
      iunlock(ip);
    8000385c:	8552                	mv	a0,s4
    8000385e:	9e9ff0ef          	jal	80003246 <iunlock>
      return ip;
    80003862:	bff1                	j	8000383e <namex+0x5c>
      iunlockput(ip);
    80003864:	8552                	mv	a0,s4
    80003866:	b3fff0ef          	jal	800033a4 <iunlockput>
      return 0;
    8000386a:	8a4a                	mv	s4,s2
    8000386c:	bfc9                	j	8000383e <namex+0x5c>
  while (*path != '/' && *path != 0)
    8000386e:	8926                	mv	s2,s1
  len = path - s;
    80003870:	4d01                	li	s10,0
    80003872:	4601                	li	a2,0
    memmove(name, s, len);
    80003874:	2601                	sext.w	a2,a2
    80003876:	85a6                	mv	a1,s1
    80003878:	8556                	mv	a0,s5
    8000387a:	cb6fd0ef          	jal	80000d30 <memmove>
    name[len] = 0;
    8000387e:	9d56                	add	s10,s10,s5
    80003880:	000d0023          	sb	zero,0(s10) # fffffffffffff000 <end+0xffffffff7ffde488>
    80003884:	84ca                	mv	s1,s2
  while (*path == '/')
    80003886:	0004c783          	lbu	a5,0(s1)
    8000388a:	01379763          	bne	a5,s3,80003898 <namex+0xb6>
    path++;
    8000388e:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003890:	0004c783          	lbu	a5,0(s1)
    80003894:	ff378de3          	beq	a5,s3,8000388e <namex+0xac>
    ilock(ip);
    80003898:	8552                	mv	a0,s4
    8000389a:	8ffff0ef          	jal	80003198 <ilock>
    if (ip->type != T_DIR) {
    8000389e:	044a1783          	lh	a5,68(s4)
    800038a2:	f9779ae3          	bne	a5,s7,80003836 <namex+0x54>
    if (nameiparent && *path == '\0') {
    800038a6:	000b0563          	beqz	s6,800038b0 <namex+0xce>
    800038aa:	0004c783          	lbu	a5,0(s1)
    800038ae:	d7dd                	beqz	a5,8000385c <namex+0x7a>
    if ((next = dirlookup(ip, name, 0)) == 0) {
    800038b0:	4601                	li	a2,0
    800038b2:	85d6                	mv	a1,s5
    800038b4:	8552                	mv	a0,s4
    800038b6:	e85ff0ef          	jal	8000373a <dirlookup>
    800038ba:	892a                	mv	s2,a0
    800038bc:	d545                	beqz	a0,80003864 <namex+0x82>
    iunlockput(ip);
    800038be:	8552                	mv	a0,s4
    800038c0:	ae5ff0ef          	jal	800033a4 <iunlockput>
    ip = next;
    800038c4:	8a4a                	mv	s4,s2
  while (*path == '/')
    800038c6:	0004c783          	lbu	a5,0(s1)
    800038ca:	01379763          	bne	a5,s3,800038d8 <namex+0xf6>
    path++;
    800038ce:	0485                	addi	s1,s1,1
  while (*path == '/')
    800038d0:	0004c783          	lbu	a5,0(s1)
    800038d4:	ff378de3          	beq	a5,s3,800038ce <namex+0xec>
  if (*path == 0)
    800038d8:	c7a1                	beqz	a5,80003920 <namex+0x13e>
  while (*path != '/' && *path != 0)
    800038da:	0004c703          	lbu	a4,0(s1)
    800038de:	fd170793          	addi	a5,a4,-47
    800038e2:	00f037b3          	snez	a5,a5
    800038e6:	00e03733          	snez	a4,a4
    800038ea:	8ff9                	and	a5,a5,a4
    800038ec:	d3c9                	beqz	a5,8000386e <namex+0x8c>
    800038ee:	8926                	mv	s2,s1
    path++;
    800038f0:	0905                	addi	s2,s2,1
  while (*path != '/' && *path != 0)
    800038f2:	00094703          	lbu	a4,0(s2)
    800038f6:	fd170793          	addi	a5,a4,-47
    800038fa:	00f037b3          	snez	a5,a5
    800038fe:	00e03733          	snez	a4,a4
    80003902:	8ff9                	and	a5,a5,a4
    80003904:	f7f5                	bnez	a5,800038f0 <namex+0x10e>
  len = path - s;
    80003906:	40990633          	sub	a2,s2,s1
    8000390a:	00060d1b          	sext.w	s10,a2
  if (len >= DIRSIZ)
    8000390e:	f7ac53e3          	bge	s8,s10,80003874 <namex+0x92>
    memmove(name, s, DIRSIZ);
    80003912:	8666                	mv	a2,s9
    80003914:	85a6                	mv	a1,s1
    80003916:	8556                	mv	a0,s5
    80003918:	c18fd0ef          	jal	80000d30 <memmove>
    8000391c:	84ca                	mv	s1,s2
    8000391e:	b7a5                	j	80003886 <namex+0xa4>
  if (nameiparent) {
    80003920:	f00b0fe3          	beqz	s6,8000383e <namex+0x5c>
    iput(ip);
    80003924:	8552                	mv	a0,s4
    80003926:	9f5ff0ef          	jal	8000331a <iput>
    return 0;
    8000392a:	bf09                	j	8000383c <namex+0x5a>

000000008000392c <dirlink>:
{
    8000392c:	715d                	addi	sp,sp,-80
    8000392e:	e486                	sd	ra,72(sp)
    80003930:	e0a2                	sd	s0,64(sp)
    80003932:	f84a                	sd	s2,48(sp)
    80003934:	ec56                	sd	s5,24(sp)
    80003936:	e85a                	sd	s6,16(sp)
    80003938:	0880                	addi	s0,sp,80
    8000393a:	892a                	mv	s2,a0
    8000393c:	8aae                	mv	s5,a1
    8000393e:	8b32                	mv	s6,a2
  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80003940:	4601                	li	a2,0
    80003942:	df9ff0ef          	jal	8000373a <dirlookup>
    80003946:	ed1d                	bnez	a0,80003984 <dirlink+0x58>
    80003948:	fc26                	sd	s1,56(sp)
  for (off = 0; off < dp->size; off += sizeof(de)) {
    8000394a:	04c92483          	lw	s1,76(s2)
    8000394e:	c4b9                	beqz	s1,8000399c <dirlink+0x70>
    80003950:	f44e                	sd	s3,40(sp)
    80003952:	f052                	sd	s4,32(sp)
    80003954:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003956:	fb040a13          	addi	s4,s0,-80
    8000395a:	49c1                	li	s3,16
    8000395c:	874e                	mv	a4,s3
    8000395e:	86a6                	mv	a3,s1
    80003960:	8652                	mv	a2,s4
    80003962:	4581                	li	a1,0
    80003964:	854a                	mv	a0,s2
    80003966:	bc5ff0ef          	jal	8000352a <readi>
    8000396a:	03351163          	bne	a0,s3,8000398c <dirlink+0x60>
    if (de.inum == 0)
    8000396e:	fb045783          	lhu	a5,-80(s0)
    80003972:	c39d                	beqz	a5,80003998 <dirlink+0x6c>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003974:	24c1                	addiw	s1,s1,16
    80003976:	04c92783          	lw	a5,76(s2)
    8000397a:	fef4e1e3          	bltu	s1,a5,8000395c <dirlink+0x30>
    8000397e:	79a2                	ld	s3,40(sp)
    80003980:	7a02                	ld	s4,32(sp)
    80003982:	a829                	j	8000399c <dirlink+0x70>
    iput(ip);
    80003984:	997ff0ef          	jal	8000331a <iput>
    return -1;
    80003988:	557d                	li	a0,-1
    8000398a:	a83d                	j	800039c8 <dirlink+0x9c>
      panic("dirlink read");
    8000398c:	00004517          	auipc	a0,0x4
    80003990:	b3c50513          	addi	a0,a0,-1220 # 800074c8 <etext+0x4c8>
    80003994:	ea7fc0ef          	jal	8000083a <panic>
    80003998:	79a2                	ld	s3,40(sp)
    8000399a:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    8000399c:	4639                	li	a2,14
    8000399e:	85d6                	mv	a1,s5
    800039a0:	fb240513          	addi	a0,s0,-78
    800039a4:	c36fd0ef          	jal	80000dda <strncpy>
  de.inum = inum;
    800039a8:	fb641823          	sh	s6,-80(s0)
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800039ac:	4741                	li	a4,16
    800039ae:	86a6                	mv	a3,s1
    800039b0:	fb040613          	addi	a2,s0,-80
    800039b4:	4581                	li	a1,0
    800039b6:	854a                	mv	a0,s2
    800039b8:	c65ff0ef          	jal	8000361c <writei>
    800039bc:	1541                	addi	a0,a0,-16
    800039be:	00a03533          	snez	a0,a0
    800039c2:	40a0053b          	negw	a0,a0
    800039c6:	74e2                	ld	s1,56(sp)
}
    800039c8:	60a6                	ld	ra,72(sp)
    800039ca:	6406                	ld	s0,64(sp)
    800039cc:	7942                	ld	s2,48(sp)
    800039ce:	6ae2                	ld	s5,24(sp)
    800039d0:	6b42                	ld	s6,16(sp)
    800039d2:	6161                	addi	sp,sp,80
    800039d4:	8082                	ret

00000000800039d6 <namei>:

struct inode *
namei(char *path)
{
    800039d6:	1101                	addi	sp,sp,-32
    800039d8:	ec06                	sd	ra,24(sp)
    800039da:	e822                	sd	s0,16(sp)
    800039dc:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800039de:	fe040613          	addi	a2,s0,-32
    800039e2:	4581                	li	a1,0
    800039e4:	dffff0ef          	jal	800037e2 <namex>
}
    800039e8:	60e2                	ld	ra,24(sp)
    800039ea:	6442                	ld	s0,16(sp)
    800039ec:	6105                	addi	sp,sp,32
    800039ee:	8082                	ret

00000000800039f0 <nameiparent>:

struct inode *
nameiparent(char *path, char *name)
{
    800039f0:	1141                	addi	sp,sp,-16
    800039f2:	e406                	sd	ra,8(sp)
    800039f4:	e022                	sd	s0,0(sp)
    800039f6:	0800                	addi	s0,sp,16
    800039f8:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800039fa:	4585                	li	a1,1
    800039fc:	de7ff0ef          	jal	800037e2 <namex>
}
    80003a00:	60a2                	ld	ra,8(sp)
    80003a02:	6402                	ld	s0,0(sp)
    80003a04:	0141                	addi	sp,sp,16
    80003a06:	8082                	ret

0000000080003a08 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003a08:	1101                	addi	sp,sp,-32
    80003a0a:	ec06                	sd	ra,24(sp)
    80003a0c:	e822                	sd	s0,16(sp)
    80003a0e:	e426                	sd	s1,8(sp)
    80003a10:	e04a                	sd	s2,0(sp)
    80003a12:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003a14:	0001c917          	auipc	s2,0x1c
    80003a18:	f2490913          	addi	s2,s2,-220 # 8001f938 <log>
    80003a1c:	01892583          	lw	a1,24(s2)
    80003a20:	02492503          	lw	a0,36(s2)
    80003a24:	8d4ff0ef          	jal	80002af8 <bread>
    80003a28:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *)(buf->data);
  int i;
  hb->n = log.lh.n;
    80003a2a:	02c92603          	lw	a2,44(s2)
    80003a2e:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003a30:	00c05f63          	blez	a2,80003a4e <write_head+0x46>
    80003a34:	0001c717          	auipc	a4,0x1c
    80003a38:	f3470713          	addi	a4,a4,-204 # 8001f968 <log+0x30>
    80003a3c:	87aa                	mv	a5,a0
    80003a3e:	060a                	slli	a2,a2,0x2
    80003a40:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003a42:	4314                	lw	a3,0(a4)
    80003a44:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003a46:	0711                	addi	a4,a4,4
    80003a48:	0791                	addi	a5,a5,4 # 43004 <_entry-0x7ffbcffc>
    80003a4a:	fec79ce3          	bne	a5,a2,80003a42 <write_head+0x3a>
  }
  bwrite(buf);
    80003a4e:	8526                	mv	a0,s1
    80003a50:	97eff0ef          	jal	80002bce <bwrite>
  brelse(buf);
    80003a54:	8526                	mv	a0,s1
    80003a56:	9aaff0ef          	jal	80002c00 <brelse>
}
    80003a5a:	60e2                	ld	ra,24(sp)
    80003a5c:	6442                	ld	s0,16(sp)
    80003a5e:	64a2                	ld	s1,8(sp)
    80003a60:	6902                	ld	s2,0(sp)
    80003a62:	6105                	addi	sp,sp,32
    80003a64:	8082                	ret

0000000080003a66 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003a66:	0001c797          	auipc	a5,0x1c
    80003a6a:	efe7a783          	lw	a5,-258(a5) # 8001f964 <log+0x2c>
    80003a6e:	0cf05163          	blez	a5,80003b30 <install_trans+0xca>
{
    80003a72:	715d                	addi	sp,sp,-80
    80003a74:	e486                	sd	ra,72(sp)
    80003a76:	e0a2                	sd	s0,64(sp)
    80003a78:	fc26                	sd	s1,56(sp)
    80003a7a:	f84a                	sd	s2,48(sp)
    80003a7c:	f44e                	sd	s3,40(sp)
    80003a7e:	f052                	sd	s4,32(sp)
    80003a80:	ec56                	sd	s5,24(sp)
    80003a82:	e85a                	sd	s6,16(sp)
    80003a84:	e45e                	sd	s7,8(sp)
    80003a86:	e062                	sd	s8,0(sp)
    80003a88:	0880                	addi	s0,sp,80
    80003a8a:	8b2a                	mv	s6,a0
    80003a8c:	0001ca97          	auipc	s5,0x1c
    80003a90:	edca8a93          	addi	s5,s5,-292 # 8001f968 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003a94:	4981                	li	s3,0
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003a96:	00004c17          	auipc	s8,0x4
    80003a9a:	a42c0c13          	addi	s8,s8,-1470 # 800074d8 <etext+0x4d8>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003a9e:	0001ca17          	auipc	s4,0x1c
    80003aa2:	e9aa0a13          	addi	s4,s4,-358 # 8001f938 <log>
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003aa6:	40000b93          	li	s7,1024
    80003aaa:	a025                	j	80003ad2 <install_trans+0x6c>
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003aac:	000aa603          	lw	a2,0(s5)
    80003ab0:	85ce                	mv	a1,s3
    80003ab2:	8562                	mv	a0,s8
    80003ab4:	a4ffc0ef          	jal	80000502 <printk>
    80003ab8:	a839                	j	80003ad6 <install_trans+0x70>
    brelse(lbuf);
    80003aba:	854a                	mv	a0,s2
    80003abc:	944ff0ef          	jal	80002c00 <brelse>
    brelse(dbuf);
    80003ac0:	8526                	mv	a0,s1
    80003ac2:	93eff0ef          	jal	80002c00 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ac6:	2985                	addiw	s3,s3,1
    80003ac8:	0a91                	addi	s5,s5,4
    80003aca:	02ca2783          	lw	a5,44(s4)
    80003ace:	04f9d563          	bge	s3,a5,80003b18 <install_trans+0xb2>
    if (recovering) {
    80003ad2:	fc0b1de3          	bnez	s6,80003aac <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003ad6:	018a2583          	lw	a1,24(s4)
    80003ada:	013585bb          	addw	a1,a1,s3
    80003ade:	2585                	addiw	a1,a1,1
    80003ae0:	024a2503          	lw	a0,36(s4)
    80003ae4:	814ff0ef          	jal	80002af8 <bread>
    80003ae8:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]);   // read dst
    80003aea:	000aa583          	lw	a1,0(s5)
    80003aee:	024a2503          	lw	a0,36(s4)
    80003af2:	806ff0ef          	jal	80002af8 <bread>
    80003af6:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003af8:	865e                	mv	a2,s7
    80003afa:	05890593          	addi	a1,s2,88
    80003afe:	05850513          	addi	a0,a0,88
    80003b02:	a2efd0ef          	jal	80000d30 <memmove>
    bwrite(dbuf);                           // write dst to disk
    80003b06:	8526                	mv	a0,s1
    80003b08:	8c6ff0ef          	jal	80002bce <bwrite>
    if (recovering == 0)
    80003b0c:	fa0b17e3          	bnez	s6,80003aba <install_trans+0x54>
      bunpin(dbuf);
    80003b10:	8526                	mv	a0,s1
    80003b12:	9a6ff0ef          	jal	80002cb8 <bunpin>
    80003b16:	b755                	j	80003aba <install_trans+0x54>
}
    80003b18:	60a6                	ld	ra,72(sp)
    80003b1a:	6406                	ld	s0,64(sp)
    80003b1c:	74e2                	ld	s1,56(sp)
    80003b1e:	7942                	ld	s2,48(sp)
    80003b20:	79a2                	ld	s3,40(sp)
    80003b22:	7a02                	ld	s4,32(sp)
    80003b24:	6ae2                	ld	s5,24(sp)
    80003b26:	6b42                	ld	s6,16(sp)
    80003b28:	6ba2                	ld	s7,8(sp)
    80003b2a:	6c02                	ld	s8,0(sp)
    80003b2c:	6161                	addi	sp,sp,80
    80003b2e:	8082                	ret
    80003b30:	8082                	ret

0000000080003b32 <initlog>:
{
    80003b32:	7179                	addi	sp,sp,-48
    80003b34:	f406                	sd	ra,40(sp)
    80003b36:	f022                	sd	s0,32(sp)
    80003b38:	ec26                	sd	s1,24(sp)
    80003b3a:	e84a                	sd	s2,16(sp)
    80003b3c:	e44e                	sd	s3,8(sp)
    80003b3e:	1800                	addi	s0,sp,48
    80003b40:	84aa                	mv	s1,a0
    80003b42:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003b44:	0001c917          	auipc	s2,0x1c
    80003b48:	df490913          	addi	s2,s2,-524 # 8001f938 <log>
    80003b4c:	00004597          	auipc	a1,0x4
    80003b50:	9ac58593          	addi	a1,a1,-1620 # 800074f8 <etext+0x4f8>
    80003b54:	854a                	mv	a0,s2
    80003b56:	842fd0ef          	jal	80000b98 <initlock>
  log.start = sb->logstart;
    80003b5a:	0149a583          	lw	a1,20(s3)
    80003b5e:	00b92c23          	sw	a1,24(s2)
  log.dev = dev;
    80003b62:	02992223          	sw	s1,36(s2)
  struct buf *buf = bread(log.dev, log.start);
    80003b66:	8526                	mv	a0,s1
    80003b68:	f91fe0ef          	jal	80002af8 <bread>
  log.lh.n = lh->n;
    80003b6c:	4d30                	lw	a2,88(a0)
    80003b6e:	02c92623          	sw	a2,44(s2)
  for (i = 0; i < log.lh.n; i++) {
    80003b72:	00c05f63          	blez	a2,80003b90 <initlog+0x5e>
    80003b76:	87aa                	mv	a5,a0
    80003b78:	0001c717          	auipc	a4,0x1c
    80003b7c:	df070713          	addi	a4,a4,-528 # 8001f968 <log+0x30>
    80003b80:	060a                	slli	a2,a2,0x2
    80003b82:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003b84:	4ff4                	lw	a3,92(a5)
    80003b86:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003b88:	0791                	addi	a5,a5,4
    80003b8a:	0711                	addi	a4,a4,4
    80003b8c:	fec79ce3          	bne	a5,a2,80003b84 <initlog+0x52>
  brelse(buf);
    80003b90:	870ff0ef          	jal	80002c00 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003b94:	4505                	li	a0,1
    80003b96:	ed1ff0ef          	jal	80003a66 <install_trans>
  log.lh.n = 0;
    80003b9a:	0001c797          	auipc	a5,0x1c
    80003b9e:	dc07a523          	sw	zero,-566(a5) # 8001f964 <log+0x2c>
  write_head(); // clear the log
    80003ba2:	e67ff0ef          	jal	80003a08 <write_head>
}
    80003ba6:	70a2                	ld	ra,40(sp)
    80003ba8:	7402                	ld	s0,32(sp)
    80003baa:	64e2                	ld	s1,24(sp)
    80003bac:	6942                	ld	s2,16(sp)
    80003bae:	69a2                	ld	s3,8(sp)
    80003bb0:	6145                	addi	sp,sp,48
    80003bb2:	8082                	ret

0000000080003bb4 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003bb4:	1101                	addi	sp,sp,-32
    80003bb6:	ec06                	sd	ra,24(sp)
    80003bb8:	e822                	sd	s0,16(sp)
    80003bba:	e426                	sd	s1,8(sp)
    80003bbc:	e04a                	sd	s2,0(sp)
    80003bbe:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003bc0:	0001c517          	auipc	a0,0x1c
    80003bc4:	d7850513          	addi	a0,a0,-648 # 8001f938 <log>
    80003bc8:	850fd0ef          	jal	80000c18 <acquire>
  while (1) {
    if (log.committing) {
    80003bcc:	0001c497          	auipc	s1,0x1c
    80003bd0:	d6c48493          	addi	s1,s1,-660 # 8001f938 <log>
      sleep(&log, &log.lock);
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003bd4:	4979                	li	s2,30
    80003bd6:	a029                	j	80003be0 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003bd8:	85a6                	mv	a1,s1
    80003bda:	8526                	mv	a0,s1
    80003bdc:	af4fe0ef          	jal	80001ed0 <sleep>
    if (log.committing) {
    80003be0:	509c                	lw	a5,32(s1)
    80003be2:	fbfd                	bnez	a5,80003bd8 <begin_op+0x24>
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003be4:	4cd8                	lw	a4,28(s1)
    80003be6:	2705                	addiw	a4,a4,1
    80003be8:	0027179b          	slliw	a5,a4,0x2
    80003bec:	9fb9                	addw	a5,a5,a4
    80003bee:	0017979b          	slliw	a5,a5,0x1
    80003bf2:	54d4                	lw	a3,44(s1)
    80003bf4:	9fb5                	addw	a5,a5,a3
    80003bf6:	00f95763          	bge	s2,a5,80003c04 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003bfa:	85a6                	mv	a1,s1
    80003bfc:	8526                	mv	a0,s1
    80003bfe:	ad2fe0ef          	jal	80001ed0 <sleep>
    80003c02:	bff9                	j	80003be0 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003c04:	0001c797          	auipc	a5,0x1c
    80003c08:	d4e7a823          	sw	a4,-688(a5) # 8001f954 <log+0x1c>
      release(&log.lock);
    80003c0c:	0001c517          	auipc	a0,0x1c
    80003c10:	d2c50513          	addi	a0,a0,-724 # 8001f938 <log>
    80003c14:	888fd0ef          	jal	80000c9c <release>
      break;
    }
  }
}
    80003c18:	60e2                	ld	ra,24(sp)
    80003c1a:	6442                	ld	s0,16(sp)
    80003c1c:	64a2                	ld	s1,8(sp)
    80003c1e:	6902                	ld	s2,0(sp)
    80003c20:	6105                	addi	sp,sp,32
    80003c22:	8082                	ret

0000000080003c24 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003c24:	7139                	addi	sp,sp,-64
    80003c26:	fc06                	sd	ra,56(sp)
    80003c28:	f822                	sd	s0,48(sp)
    80003c2a:	f426                	sd	s1,40(sp)
    80003c2c:	f04a                	sd	s2,32(sp)
    80003c2e:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003c30:	0001c497          	auipc	s1,0x1c
    80003c34:	d0848493          	addi	s1,s1,-760 # 8001f938 <log>
    80003c38:	8526                	mv	a0,s1
    80003c3a:	fdffc0ef          	jal	80000c18 <acquire>
  log.outstanding -= 1;
    80003c3e:	4cdc                	lw	a5,28(s1)
    80003c40:	37fd                	addiw	a5,a5,-1
    80003c42:	893e                	mv	s2,a5
    80003c44:	ccdc                	sw	a5,28(s1)
  if (log.committing)
    80003c46:	509c                	lw	a5,32(s1)
    80003c48:	e7b9                	bnez	a5,80003c96 <end_op+0x72>
    panic("log.committing");
  if (log.outstanding == 0) {
    80003c4a:	04091f63          	bnez	s2,80003ca8 <end_op+0x84>
    do_commit = 1;
    log.committing = 1;
    80003c4e:	0001c497          	auipc	s1,0x1c
    80003c52:	cea48493          	addi	s1,s1,-790 # 8001f938 <log>
    80003c56:	4785                	li	a5,1
    80003c58:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003c5a:	8526                	mv	a0,s1
    80003c5c:	840fd0ef          	jal	80000c9c <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003c60:	54dc                	lw	a5,44(s1)
    80003c62:	06f04063          	bgtz	a5,80003cc2 <end_op+0x9e>
    acquire(&log.lock);
    80003c66:	0001c497          	auipc	s1,0x1c
    80003c6a:	cd248493          	addi	s1,s1,-814 # 8001f938 <log>
    80003c6e:	8526                	mv	a0,s1
    80003c70:	fa9fc0ef          	jal	80000c18 <acquire>
    log.committing = 0;
    80003c74:	0204a023          	sw	zero,32(s1)
    log.ncommit += 1;
    80003c78:	549c                	lw	a5,40(s1)
    80003c7a:	2785                	addiw	a5,a5,1
    80003c7c:	d49c                	sw	a5,40(s1)
    wakeup(&log);
    80003c7e:	8526                	mv	a0,s1
    80003c80:	a9cfe0ef          	jal	80001f1c <wakeup>
    release(&log.lock);
    80003c84:	8526                	mv	a0,s1
    80003c86:	816fd0ef          	jal	80000c9c <release>
}
    80003c8a:	70e2                	ld	ra,56(sp)
    80003c8c:	7442                	ld	s0,48(sp)
    80003c8e:	74a2                	ld	s1,40(sp)
    80003c90:	7902                	ld	s2,32(sp)
    80003c92:	6121                	addi	sp,sp,64
    80003c94:	8082                	ret
    80003c96:	ec4e                	sd	s3,24(sp)
    80003c98:	e852                	sd	s4,16(sp)
    80003c9a:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003c9c:	00004517          	auipc	a0,0x4
    80003ca0:	86450513          	addi	a0,a0,-1948 # 80007500 <etext+0x500>
    80003ca4:	b97fc0ef          	jal	8000083a <panic>
    wakeup(&log);
    80003ca8:	0001c517          	auipc	a0,0x1c
    80003cac:	c9050513          	addi	a0,a0,-880 # 8001f938 <log>
    80003cb0:	a6cfe0ef          	jal	80001f1c <wakeup>
  release(&log.lock);
    80003cb4:	0001c517          	auipc	a0,0x1c
    80003cb8:	c8450513          	addi	a0,a0,-892 # 8001f938 <log>
    80003cbc:	fe1fc0ef          	jal	80000c9c <release>
  if (do_commit) {
    80003cc0:	b7e9                	j	80003c8a <end_op+0x66>
    80003cc2:	ec4e                	sd	s3,24(sp)
    80003cc4:	e852                	sd	s4,16(sp)
    80003cc6:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003cc8:	0001ca97          	auipc	s5,0x1c
    80003ccc:	ca0a8a93          	addi	s5,s5,-864 # 8001f968 <log+0x30>
    struct buf *to = bread(log.dev, log.start + tail + 1); // log block
    80003cd0:	0001ca17          	auipc	s4,0x1c
    80003cd4:	c68a0a13          	addi	s4,s4,-920 # 8001f938 <log>
    80003cd8:	018a2583          	lw	a1,24(s4)
    80003cdc:	012585bb          	addw	a1,a1,s2
    80003ce0:	2585                	addiw	a1,a1,1
    80003ce2:	024a2503          	lw	a0,36(s4)
    80003ce6:	e13fe0ef          	jal	80002af8 <bread>
    80003cea:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003cec:	000aa583          	lw	a1,0(s5)
    80003cf0:	024a2503          	lw	a0,36(s4)
    80003cf4:	e05fe0ef          	jal	80002af8 <bread>
    80003cf8:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003cfa:	40000613          	li	a2,1024
    80003cfe:	05850593          	addi	a1,a0,88
    80003d02:	05848513          	addi	a0,s1,88
    80003d06:	82afd0ef          	jal	80000d30 <memmove>
    bwrite(to); // write the log
    80003d0a:	8526                	mv	a0,s1
    80003d0c:	ec3fe0ef          	jal	80002bce <bwrite>
    brelse(from);
    80003d10:	854e                	mv	a0,s3
    80003d12:	eeffe0ef          	jal	80002c00 <brelse>
    brelse(to);
    80003d16:	8526                	mv	a0,s1
    80003d18:	ee9fe0ef          	jal	80002c00 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d1c:	2905                	addiw	s2,s2,1
    80003d1e:	0a91                	addi	s5,s5,4
    80003d20:	02ca2783          	lw	a5,44(s4)
    80003d24:	faf94ae3          	blt	s2,a5,80003cd8 <end_op+0xb4>
    write_log();      // Write modified blocks from cache to log
    write_head();     // Write header to disk -- the real commit
    80003d28:	ce1ff0ef          	jal	80003a08 <write_head>
    install_trans(0); // Now install writes to home locations
    80003d2c:	4501                	li	a0,0
    80003d2e:	d39ff0ef          	jal	80003a66 <install_trans>
    log.lh.n = 0;
    80003d32:	0001c797          	auipc	a5,0x1c
    80003d36:	c207a923          	sw	zero,-974(a5) # 8001f964 <log+0x2c>
    write_head(); // Erase the transaction from the log
    80003d3a:	ccfff0ef          	jal	80003a08 <write_head>
    80003d3e:	69e2                	ld	s3,24(sp)
    80003d40:	6a42                	ld	s4,16(sp)
    80003d42:	6aa2                	ld	s5,8(sp)
    80003d44:	b70d                	j	80003c66 <end_op+0x42>

0000000080003d46 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003d46:	1101                	addi	sp,sp,-32
    80003d48:	ec06                	sd	ra,24(sp)
    80003d4a:	e822                	sd	s0,16(sp)
    80003d4c:	e426                	sd	s1,8(sp)
    80003d4e:	1000                	addi	s0,sp,32
    80003d50:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003d52:	0001c517          	auipc	a0,0x1c
    80003d56:	be650513          	addi	a0,a0,-1050 # 8001f938 <log>
    80003d5a:	ebffc0ef          	jal	80000c18 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003d5e:	0001c617          	auipc	a2,0x1c
    80003d62:	c0662603          	lw	a2,-1018(a2) # 8001f964 <log+0x2c>
    80003d66:	47f5                	li	a5,29
    80003d68:	04c7cc63          	blt	a5,a2,80003dc0 <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003d6c:	0001c797          	auipc	a5,0x1c
    80003d70:	be87a783          	lw	a5,-1048(a5) # 8001f954 <log+0x1c>
    80003d74:	04f05c63          	blez	a5,80003dcc <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003d78:	4781                	li	a5,0
    80003d7a:	04c05f63          	blez	a2,80003dd8 <log_write+0x92>
    if (log.lh.block[i] == b->blockno) // log absorption
    80003d7e:	44cc                	lw	a1,12(s1)
    80003d80:	0001c717          	auipc	a4,0x1c
    80003d84:	be870713          	addi	a4,a4,-1048 # 8001f968 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003d88:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno) // log absorption
    80003d8a:	4314                	lw	a3,0(a4)
    80003d8c:	04b68663          	beq	a3,a1,80003dd8 <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    80003d90:	2785                	addiw	a5,a5,1
    80003d92:	0711                	addi	a4,a4,4
    80003d94:	fef61be3          	bne	a2,a5,80003d8a <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003d98:	0621                	addi	a2,a2,8
    80003d9a:	060a                	slli	a2,a2,0x2
    80003d9c:	0001c797          	auipc	a5,0x1c
    80003da0:	b9c78793          	addi	a5,a5,-1124 # 8001f938 <log>
    80003da4:	97b2                	add	a5,a5,a2
    80003da6:	44d8                	lw	a4,12(s1)
    80003da8:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) { // Add new block to log?
    bpin(b);
    80003daa:	8526                	mv	a0,s1
    80003dac:	ed9fe0ef          	jal	80002c84 <bpin>
    log.lh.n++;
    80003db0:	0001c717          	auipc	a4,0x1c
    80003db4:	b8870713          	addi	a4,a4,-1144 # 8001f938 <log>
    80003db8:	575c                	lw	a5,44(a4)
    80003dba:	2785                	addiw	a5,a5,1
    80003dbc:	d75c                	sw	a5,44(a4)
    80003dbe:	a80d                	j	80003df0 <log_write+0xaa>
    panic("too big a transaction");
    80003dc0:	00003517          	auipc	a0,0x3
    80003dc4:	75050513          	addi	a0,a0,1872 # 80007510 <etext+0x510>
    80003dc8:	a73fc0ef          	jal	8000083a <panic>
    panic("log_write outside of trans");
    80003dcc:	00003517          	auipc	a0,0x3
    80003dd0:	75c50513          	addi	a0,a0,1884 # 80007528 <etext+0x528>
    80003dd4:	a67fc0ef          	jal	8000083a <panic>
  log.lh.block[i] = b->blockno;
    80003dd8:	00878693          	addi	a3,a5,8
    80003ddc:	068a                	slli	a3,a3,0x2
    80003dde:	0001c717          	auipc	a4,0x1c
    80003de2:	b5a70713          	addi	a4,a4,-1190 # 8001f938 <log>
    80003de6:	9736                	add	a4,a4,a3
    80003de8:	44d4                	lw	a3,12(s1)
    80003dea:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) { // Add new block to log?
    80003dec:	faf60fe3          	beq	a2,a5,80003daa <log_write+0x64>
  }
  release(&log.lock);
    80003df0:	0001c517          	auipc	a0,0x1c
    80003df4:	b4850513          	addi	a0,a0,-1208 # 8001f938 <log>
    80003df8:	ea5fc0ef          	jal	80000c9c <release>
}
    80003dfc:	60e2                	ld	ra,24(sp)
    80003dfe:	6442                	ld	s0,16(sp)
    80003e00:	64a2                	ld	s1,8(sp)
    80003e02:	6105                	addi	sp,sp,32
    80003e04:	8082                	ret

0000000080003e06 <sys_sync>:

uint64
sys_sync(void)
{
    80003e06:	1101                	addi	sp,sp,-32
    80003e08:	ec06                	sd	ra,24(sp)
    80003e0a:	e822                	sd	s0,16(sp)
    80003e0c:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003e0e:	0001c517          	auipc	a0,0x1c
    80003e12:	b2a50513          	addi	a0,a0,-1238 # 8001f938 <log>
    80003e16:	e03fc0ef          	jal	80000c18 <acquire>
  if (log.committing || log.outstanding > 0) {
    80003e1a:	0001c797          	auipc	a5,0x1c
    80003e1e:	b3e7a783          	lw	a5,-1218(a5) # 8001f958 <log+0x20>
    80003e22:	e799                	bnez	a5,80003e30 <sys_sync+0x2a>
    80003e24:	0001c797          	auipc	a5,0x1c
    80003e28:	b307a783          	lw	a5,-1232(a5) # 8001f954 <log+0x1c>
    80003e2c:	02f05563          	blez	a5,80003e56 <sys_sync+0x50>
    80003e30:	e426                	sd	s1,8(sp)
    80003e32:	e04a                	sd	s2,0(sp)
    int n = log.ncommit + 1;
    80003e34:	0001c917          	auipc	s2,0x1c
    80003e38:	b2c92903          	lw	s2,-1236(s2) # 8001f960 <log+0x28>
    while (log.ncommit < n) {
      sleep(&log, &log.lock);
    80003e3c:	0001c497          	auipc	s1,0x1c
    80003e40:	afc48493          	addi	s1,s1,-1284 # 8001f938 <log>
    80003e44:	85a6                	mv	a1,s1
    80003e46:	8526                	mv	a0,s1
    80003e48:	888fe0ef          	jal	80001ed0 <sleep>
    while (log.ncommit < n) {
    80003e4c:	549c                	lw	a5,40(s1)
    80003e4e:	fef95be3          	bge	s2,a5,80003e44 <sys_sync+0x3e>
    80003e52:	64a2                	ld	s1,8(sp)
    80003e54:	6902                	ld	s2,0(sp)
    }
  }
  release(&log.lock);
    80003e56:	0001c517          	auipc	a0,0x1c
    80003e5a:	ae250513          	addi	a0,a0,-1310 # 8001f938 <log>
    80003e5e:	e3ffc0ef          	jal	80000c9c <release>
  return 0;
}
    80003e62:	4501                	li	a0,0
    80003e64:	60e2                	ld	ra,24(sp)
    80003e66:	6442                	ld	s0,16(sp)
    80003e68:	6105                	addi	sp,sp,32
    80003e6a:	8082                	ret

0000000080003e6c <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003e6c:	1101                	addi	sp,sp,-32
    80003e6e:	ec06                	sd	ra,24(sp)
    80003e70:	e822                	sd	s0,16(sp)
    80003e72:	e426                	sd	s1,8(sp)
    80003e74:	e04a                	sd	s2,0(sp)
    80003e76:	1000                	addi	s0,sp,32
    80003e78:	84aa                	mv	s1,a0
    80003e7a:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003e7c:	00003597          	auipc	a1,0x3
    80003e80:	6cc58593          	addi	a1,a1,1740 # 80007548 <etext+0x548>
    80003e84:	0521                	addi	a0,a0,8
    80003e86:	d13fc0ef          	jal	80000b98 <initlock>
  lk->name = name;
    80003e8a:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003e8e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003e92:	0204a423          	sw	zero,40(s1)
}
    80003e96:	60e2                	ld	ra,24(sp)
    80003e98:	6442                	ld	s0,16(sp)
    80003e9a:	64a2                	ld	s1,8(sp)
    80003e9c:	6902                	ld	s2,0(sp)
    80003e9e:	6105                	addi	sp,sp,32
    80003ea0:	8082                	ret

0000000080003ea2 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003ea2:	1101                	addi	sp,sp,-32
    80003ea4:	ec06                	sd	ra,24(sp)
    80003ea6:	e822                	sd	s0,16(sp)
    80003ea8:	e426                	sd	s1,8(sp)
    80003eaa:	e04a                	sd	s2,0(sp)
    80003eac:	1000                	addi	s0,sp,32
    80003eae:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003eb0:	00850913          	addi	s2,a0,8
    80003eb4:	854a                	mv	a0,s2
    80003eb6:	d63fc0ef          	jal	80000c18 <acquire>
  while (lk->locked) {
    80003eba:	409c                	lw	a5,0(s1)
    80003ebc:	c799                	beqz	a5,80003eca <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003ebe:	85ca                	mv	a1,s2
    80003ec0:	8526                	mv	a0,s1
    80003ec2:	80efe0ef          	jal	80001ed0 <sleep>
  while (lk->locked) {
    80003ec6:	409c                	lw	a5,0(s1)
    80003ec8:	fbfd                	bnez	a5,80003ebe <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003eca:	4785                	li	a5,1
    80003ecc:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003ece:	a11fd0ef          	jal	800018de <myproc>
    80003ed2:	591c                	lw	a5,48(a0)
    80003ed4:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003ed6:	854a                	mv	a0,s2
    80003ed8:	dc5fc0ef          	jal	80000c9c <release>
}
    80003edc:	60e2                	ld	ra,24(sp)
    80003ede:	6442                	ld	s0,16(sp)
    80003ee0:	64a2                	ld	s1,8(sp)
    80003ee2:	6902                	ld	s2,0(sp)
    80003ee4:	6105                	addi	sp,sp,32
    80003ee6:	8082                	ret

0000000080003ee8 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003ee8:	1101                	addi	sp,sp,-32
    80003eea:	ec06                	sd	ra,24(sp)
    80003eec:	e822                	sd	s0,16(sp)
    80003eee:	e426                	sd	s1,8(sp)
    80003ef0:	e04a                	sd	s2,0(sp)
    80003ef2:	1000                	addi	s0,sp,32
    80003ef4:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003ef6:	00850913          	addi	s2,a0,8
    80003efa:	854a                	mv	a0,s2
    80003efc:	d1dfc0ef          	jal	80000c18 <acquire>
  lk->locked = 0;
    80003f00:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003f04:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003f08:	8526                	mv	a0,s1
    80003f0a:	812fe0ef          	jal	80001f1c <wakeup>
  release(&lk->lk);
    80003f0e:	854a                	mv	a0,s2
    80003f10:	d8dfc0ef          	jal	80000c9c <release>
}
    80003f14:	60e2                	ld	ra,24(sp)
    80003f16:	6442                	ld	s0,16(sp)
    80003f18:	64a2                	ld	s1,8(sp)
    80003f1a:	6902                	ld	s2,0(sp)
    80003f1c:	6105                	addi	sp,sp,32
    80003f1e:	8082                	ret

0000000080003f20 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003f20:	7179                	addi	sp,sp,-48
    80003f22:	f406                	sd	ra,40(sp)
    80003f24:	f022                	sd	s0,32(sp)
    80003f26:	ec26                	sd	s1,24(sp)
    80003f28:	e84a                	sd	s2,16(sp)
    80003f2a:	1800                	addi	s0,sp,48
    80003f2c:	84aa                	mv	s1,a0
  int r;

  acquire(&lk->lk);
    80003f2e:	00850913          	addi	s2,a0,8
    80003f32:	854a                	mv	a0,s2
    80003f34:	ce5fc0ef          	jal	80000c18 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003f38:	409c                	lw	a5,0(s1)
    80003f3a:	ef81                	bnez	a5,80003f52 <holdingsleep+0x32>
    80003f3c:	4481                	li	s1,0
  release(&lk->lk);
    80003f3e:	854a                	mv	a0,s2
    80003f40:	d5dfc0ef          	jal	80000c9c <release>
  return r;
}
    80003f44:	8526                	mv	a0,s1
    80003f46:	70a2                	ld	ra,40(sp)
    80003f48:	7402                	ld	s0,32(sp)
    80003f4a:	64e2                	ld	s1,24(sp)
    80003f4c:	6942                	ld	s2,16(sp)
    80003f4e:	6145                	addi	sp,sp,48
    80003f50:	8082                	ret
    80003f52:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80003f54:	0284a983          	lw	s3,40(s1)
    80003f58:	987fd0ef          	jal	800018de <myproc>
    80003f5c:	5904                	lw	s1,48(a0)
    80003f5e:	413484b3          	sub	s1,s1,s3
    80003f62:	0014b493          	seqz	s1,s1
    80003f66:	69a2                	ld	s3,8(sp)
    80003f68:	bfd9                	j	80003f3e <holdingsleep+0x1e>

0000000080003f6a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003f6a:	1141                	addi	sp,sp,-16
    80003f6c:	e406                	sd	ra,8(sp)
    80003f6e:	e022                	sd	s0,0(sp)
    80003f70:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003f72:	00003597          	auipc	a1,0x3
    80003f76:	5e658593          	addi	a1,a1,1510 # 80007558 <etext+0x558>
    80003f7a:	0001c517          	auipc	a0,0x1c
    80003f7e:	b0650513          	addi	a0,a0,-1274 # 8001fa80 <ftable>
    80003f82:	c17fc0ef          	jal	80000b98 <initlock>
}
    80003f86:	60a2                	ld	ra,8(sp)
    80003f88:	6402                	ld	s0,0(sp)
    80003f8a:	0141                	addi	sp,sp,16
    80003f8c:	8082                	ret

0000000080003f8e <filealloc>:

// Allocate a file structure.
struct file *
filealloc(void)
{
    80003f8e:	1101                	addi	sp,sp,-32
    80003f90:	ec06                	sd	ra,24(sp)
    80003f92:	e822                	sd	s0,16(sp)
    80003f94:	e426                	sd	s1,8(sp)
    80003f96:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80003f98:	0001c517          	auipc	a0,0x1c
    80003f9c:	ae850513          	addi	a0,a0,-1304 # 8001fa80 <ftable>
    80003fa0:	c79fc0ef          	jal	80000c18 <acquire>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    80003fa4:	0001c497          	auipc	s1,0x1c
    80003fa8:	af448493          	addi	s1,s1,-1292 # 8001fa98 <ftable+0x18>
    80003fac:	0001d717          	auipc	a4,0x1d
    80003fb0:	a8c70713          	addi	a4,a4,-1396 # 80020a38 <disk>
    if (f->ref == 0) {
    80003fb4:	40dc                	lw	a5,4(s1)
    80003fb6:	cf89                	beqz	a5,80003fd0 <filealloc+0x42>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    80003fb8:	02848493          	addi	s1,s1,40
    80003fbc:	fee49ce3          	bne	s1,a4,80003fb4 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80003fc0:	0001c517          	auipc	a0,0x1c
    80003fc4:	ac050513          	addi	a0,a0,-1344 # 8001fa80 <ftable>
    80003fc8:	cd5fc0ef          	jal	80000c9c <release>
  return 0;
    80003fcc:	4481                	li	s1,0
    80003fce:	a809                	j	80003fe0 <filealloc+0x52>
      f->ref = 1;
    80003fd0:	4785                	li	a5,1
    80003fd2:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80003fd4:	0001c517          	auipc	a0,0x1c
    80003fd8:	aac50513          	addi	a0,a0,-1364 # 8001fa80 <ftable>
    80003fdc:	cc1fc0ef          	jal	80000c9c <release>
}
    80003fe0:	8526                	mv	a0,s1
    80003fe2:	60e2                	ld	ra,24(sp)
    80003fe4:	6442                	ld	s0,16(sp)
    80003fe6:	64a2                	ld	s1,8(sp)
    80003fe8:	6105                	addi	sp,sp,32
    80003fea:	8082                	ret

0000000080003fec <filedup>:

// Increment ref count for file f.
struct file *
filedup(struct file *f)
{
    80003fec:	1101                	addi	sp,sp,-32
    80003fee:	ec06                	sd	ra,24(sp)
    80003ff0:	e822                	sd	s0,16(sp)
    80003ff2:	e426                	sd	s1,8(sp)
    80003ff4:	1000                	addi	s0,sp,32
    80003ff6:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003ff8:	0001c517          	auipc	a0,0x1c
    80003ffc:	a8850513          	addi	a0,a0,-1400 # 8001fa80 <ftable>
    80004000:	c19fc0ef          	jal	80000c18 <acquire>
  if (f->ref < 1)
    80004004:	40dc                	lw	a5,4(s1)
    80004006:	02f05063          	blez	a5,80004026 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    8000400a:	2785                	addiw	a5,a5,1
    8000400c:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000400e:	0001c517          	auipc	a0,0x1c
    80004012:	a7250513          	addi	a0,a0,-1422 # 8001fa80 <ftable>
    80004016:	c87fc0ef          	jal	80000c9c <release>
  return f;
}
    8000401a:	8526                	mv	a0,s1
    8000401c:	60e2                	ld	ra,24(sp)
    8000401e:	6442                	ld	s0,16(sp)
    80004020:	64a2                	ld	s1,8(sp)
    80004022:	6105                	addi	sp,sp,32
    80004024:	8082                	ret
    panic("filedup");
    80004026:	00003517          	auipc	a0,0x3
    8000402a:	53a50513          	addi	a0,a0,1338 # 80007560 <etext+0x560>
    8000402e:	80dfc0ef          	jal	8000083a <panic>

0000000080004032 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004032:	7139                	addi	sp,sp,-64
    80004034:	fc06                	sd	ra,56(sp)
    80004036:	f822                	sd	s0,48(sp)
    80004038:	f426                	sd	s1,40(sp)
    8000403a:	0080                	addi	s0,sp,64
    8000403c:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000403e:	0001c517          	auipc	a0,0x1c
    80004042:	a4250513          	addi	a0,a0,-1470 # 8001fa80 <ftable>
    80004046:	bd3fc0ef          	jal	80000c18 <acquire>
  if (f->ref < 1)
    8000404a:	40dc                	lw	a5,4(s1)
    8000404c:	04f05a63          	blez	a5,800040a0 <fileclose+0x6e>
    panic("fileclose");
  if (--f->ref > 0) {
    80004050:	37fd                	addiw	a5,a5,-1
    80004052:	c0dc                	sw	a5,4(s1)
    80004054:	06f04063          	bgtz	a5,800040b4 <fileclose+0x82>
    80004058:	f04a                	sd	s2,32(sp)
    8000405a:	ec4e                	sd	s3,24(sp)
    8000405c:	e852                	sd	s4,16(sp)
    8000405e:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004060:	0004a903          	lw	s2,0(s1)
    80004064:	0094c783          	lbu	a5,9(s1)
    80004068:	89be                	mv	s3,a5
    8000406a:	689c                	ld	a5,16(s1)
    8000406c:	8a3e                	mv	s4,a5
    8000406e:	6c9c                	ld	a5,24(s1)
    80004070:	8abe                	mv	s5,a5
  f->ref = 0;
    80004072:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004076:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000407a:	0001c517          	auipc	a0,0x1c
    8000407e:	a0650513          	addi	a0,a0,-1530 # 8001fa80 <ftable>
    80004082:	c1bfc0ef          	jal	80000c9c <release>

  if (ff.type == FD_PIPE) {
    80004086:	4785                	li	a5,1
    80004088:	04f90163          	beq	s2,a5,800040ca <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if (ff.type == FD_INODE || ff.type == FD_DEVICE) {
    8000408c:	ffe9079b          	addiw	a5,s2,-2
    80004090:	4705                	li	a4,1
    80004092:	04f77563          	bgeu	a4,a5,800040dc <fileclose+0xaa>
    80004096:	7902                	ld	s2,32(sp)
    80004098:	69e2                	ld	s3,24(sp)
    8000409a:	6a42                	ld	s4,16(sp)
    8000409c:	6aa2                	ld	s5,8(sp)
    8000409e:	a00d                	j	800040c0 <fileclose+0x8e>
    800040a0:	f04a                	sd	s2,32(sp)
    800040a2:	ec4e                	sd	s3,24(sp)
    800040a4:	e852                	sd	s4,16(sp)
    800040a6:	e456                	sd	s5,8(sp)
    panic("fileclose");
    800040a8:	00003517          	auipc	a0,0x3
    800040ac:	4c050513          	addi	a0,a0,1216 # 80007568 <etext+0x568>
    800040b0:	f8afc0ef          	jal	8000083a <panic>
    release(&ftable.lock);
    800040b4:	0001c517          	auipc	a0,0x1c
    800040b8:	9cc50513          	addi	a0,a0,-1588 # 8001fa80 <ftable>
    800040bc:	be1fc0ef          	jal	80000c9c <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    800040c0:	70e2                	ld	ra,56(sp)
    800040c2:	7442                	ld	s0,48(sp)
    800040c4:	74a2                	ld	s1,40(sp)
    800040c6:	6121                	addi	sp,sp,64
    800040c8:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800040ca:	85ce                	mv	a1,s3
    800040cc:	8552                	mv	a0,s4
    800040ce:	332000ef          	jal	80004400 <pipeclose>
    800040d2:	7902                	ld	s2,32(sp)
    800040d4:	69e2                	ld	s3,24(sp)
    800040d6:	6a42                	ld	s4,16(sp)
    800040d8:	6aa2                	ld	s5,8(sp)
    800040da:	b7dd                	j	800040c0 <fileclose+0x8e>
    begin_op();
    800040dc:	ad9ff0ef          	jal	80003bb4 <begin_op>
    iput(ff.ip);
    800040e0:	8556                	mv	a0,s5
    800040e2:	a38ff0ef          	jal	8000331a <iput>
    end_op();
    800040e6:	b3fff0ef          	jal	80003c24 <end_op>
    800040ea:	7902                	ld	s2,32(sp)
    800040ec:	69e2                	ld	s3,24(sp)
    800040ee:	6a42                	ld	s4,16(sp)
    800040f0:	6aa2                	ld	s5,8(sp)
    800040f2:	b7f9                	j	800040c0 <fileclose+0x8e>

00000000800040f4 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800040f4:	715d                	addi	sp,sp,-80
    800040f6:	e486                	sd	ra,72(sp)
    800040f8:	e0a2                	sd	s0,64(sp)
    800040fa:	fc26                	sd	s1,56(sp)
    800040fc:	f052                	sd	s4,32(sp)
    800040fe:	0880                	addi	s0,sp,80
    80004100:	84aa                	mv	s1,a0
    80004102:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    80004104:	fdafd0ef          	jal	800018de <myproc>
  struct stat st;

  if (f->type == FD_INODE || f->type == FD_DEVICE) {
    80004108:	409c                	lw	a5,0(s1)
    8000410a:	37f9                	addiw	a5,a5,-2
    8000410c:	4705                	li	a4,1
    8000410e:	04f76263          	bltu	a4,a5,80004152 <filestat+0x5e>
    80004112:	f84a                	sd	s2,48(sp)
    80004114:	f44e                	sd	s3,40(sp)
    80004116:	89aa                	mv	s3,a0
    ilock(f->ip);
    80004118:	6c88                	ld	a0,24(s1)
    8000411a:	87eff0ef          	jal	80003198 <ilock>
    stati(f->ip, &st);
    8000411e:	fb840913          	addi	s2,s0,-72
    80004122:	85ca                	mv	a1,s2
    80004124:	6c88                	ld	a0,24(s1)
    80004126:	bd6ff0ef          	jal	800034fc <stati>
    iunlock(f->ip);
    8000412a:	6c88                	ld	a0,24(s1)
    8000412c:	91aff0ef          	jal	80003246 <iunlock>
    if (copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004130:	46e1                	li	a3,24
    80004132:	864a                	mv	a2,s2
    80004134:	85d2                	mv	a1,s4
    80004136:	0509b503          	ld	a0,80(s3)
    8000413a:	cd6fd0ef          	jal	80001610 <copyout>
    8000413e:	41f5551b          	sraiw	a0,a0,0x1f
    80004142:	7942                	ld	s2,48(sp)
    80004144:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004146:	60a6                	ld	ra,72(sp)
    80004148:	6406                	ld	s0,64(sp)
    8000414a:	74e2                	ld	s1,56(sp)
    8000414c:	7a02                	ld	s4,32(sp)
    8000414e:	6161                	addi	sp,sp,80
    80004150:	8082                	ret
  return -1;
    80004152:	557d                	li	a0,-1
    80004154:	bfcd                	j	80004146 <filestat+0x52>

0000000080004156 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004156:	7179                	addi	sp,sp,-48
    80004158:	f406                	sd	ra,40(sp)
    8000415a:	f022                	sd	s0,32(sp)
    8000415c:	e84a                	sd	s2,16(sp)
    8000415e:	1800                	addi	s0,sp,48
  int r = 0;

  if (f->readable == 0)
    80004160:	00854783          	lbu	a5,8(a0)
    80004164:	c3c5                	beqz	a5,80004204 <fileread+0xae>
    80004166:	ec26                	sd	s1,24(sp)
    80004168:	e44e                	sd	s3,8(sp)
    8000416a:	84aa                	mv	s1,a0
    8000416c:	892e                	mv	s2,a1
    8000416e:	89b2                	mv	s3,a2
    return -1;

  if (f->type == FD_PIPE) {
    80004170:	411c                	lw	a5,0(a0)
    80004172:	4705                	li	a4,1
    80004174:	04e78363          	beq	a5,a4,800041ba <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    80004178:	470d                	li	a4,3
    8000417a:	04e78763          	beq	a5,a4,800041c8 <fileread+0x72>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if (f->type == FD_INODE) {
    8000417e:	4709                	li	a4,2
    80004180:	06e79a63          	bne	a5,a4,800041f4 <fileread+0x9e>
    ilock(f->ip);
    80004184:	6d08                	ld	a0,24(a0)
    80004186:	812ff0ef          	jal	80003198 <ilock>
    if ((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000418a:	874e                	mv	a4,s3
    8000418c:	5094                	lw	a3,32(s1)
    8000418e:	864a                	mv	a2,s2
    80004190:	4585                	li	a1,1
    80004192:	6c88                	ld	a0,24(s1)
    80004194:	b96ff0ef          	jal	8000352a <readi>
    80004198:	892a                	mv	s2,a0
    8000419a:	00a05563          	blez	a0,800041a4 <fileread+0x4e>
      f->off += r;
    8000419e:	509c                	lw	a5,32(s1)
    800041a0:	9fa9                	addw	a5,a5,a0
    800041a2:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800041a4:	6c88                	ld	a0,24(s1)
    800041a6:	8a0ff0ef          	jal	80003246 <iunlock>
    800041aa:	64e2                	ld	s1,24(sp)
    800041ac:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800041ae:	854a                	mv	a0,s2
    800041b0:	70a2                	ld	ra,40(sp)
    800041b2:	7402                	ld	s0,32(sp)
    800041b4:	6942                	ld	s2,16(sp)
    800041b6:	6145                	addi	sp,sp,48
    800041b8:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800041ba:	6908                	ld	a0,16(a0)
    800041bc:	39a000ef          	jal	80004556 <piperead>
    800041c0:	892a                	mv	s2,a0
    800041c2:	64e2                	ld	s1,24(sp)
    800041c4:	69a2                	ld	s3,8(sp)
    800041c6:	b7e5                	j	800041ae <fileread+0x58>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800041c8:	02451783          	lh	a5,36(a0)
    800041cc:	03079693          	slli	a3,a5,0x30
    800041d0:	92c1                	srli	a3,a3,0x30
    800041d2:	4725                	li	a4,9
    800041d4:	02d76663          	bltu	a4,a3,80004200 <fileread+0xaa>
    800041d8:	0792                	slli	a5,a5,0x4
    800041da:	0001c717          	auipc	a4,0x1c
    800041de:	80670713          	addi	a4,a4,-2042 # 8001f9e0 <devsw>
    800041e2:	97ba                	add	a5,a5,a4
    800041e4:	639c                	ld	a5,0(a5)
    800041e6:	c395                	beqz	a5,8000420a <fileread+0xb4>
    r = devsw[f->major].read(1, addr, n);
    800041e8:	4505                	li	a0,1
    800041ea:	9782                	jalr	a5
    800041ec:	892a                	mv	s2,a0
    800041ee:	64e2                	ld	s1,24(sp)
    800041f0:	69a2                	ld	s3,8(sp)
    800041f2:	bf75                	j	800041ae <fileread+0x58>
    panic("fileread");
    800041f4:	00003517          	auipc	a0,0x3
    800041f8:	38450513          	addi	a0,a0,900 # 80007578 <etext+0x578>
    800041fc:	e3efc0ef          	jal	8000083a <panic>
    80004200:	64e2                	ld	s1,24(sp)
    80004202:	69a2                	ld	s3,8(sp)
    return -1;
    80004204:	57fd                	li	a5,-1
    80004206:	893e                	mv	s2,a5
    80004208:	b75d                	j	800041ae <fileread+0x58>
    8000420a:	64e2                	ld	s1,24(sp)
    8000420c:	69a2                	ld	s3,8(sp)
    8000420e:	bfdd                	j	80004204 <fileread+0xae>

0000000080004210 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if (f->writable == 0)
    80004210:	00954783          	lbu	a5,9(a0)
    80004214:	12078463          	beqz	a5,8000433c <filewrite+0x12c>
{
    80004218:	711d                	addi	sp,sp,-96
    8000421a:	ec86                	sd	ra,88(sp)
    8000421c:	e8a2                	sd	s0,80(sp)
    8000421e:	e0ca                	sd	s2,64(sp)
    80004220:	f456                	sd	s5,40(sp)
    80004222:	f05a                	sd	s6,32(sp)
    80004224:	1080                	addi	s0,sp,96
    80004226:	892a                	mv	s2,a0
    80004228:	8b2e                	mv	s6,a1
    8000422a:	8ab2                	mv	s5,a2
    return -1;

  if (f->type == FD_PIPE) {
    8000422c:	411c                	lw	a5,0(a0)
    8000422e:	4705                	li	a4,1
    80004230:	02e78a63          	beq	a5,a4,80004264 <filewrite+0x54>
    ret = pipewrite(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    80004234:	470d                	li	a4,3
    80004236:	02e78b63          	beq	a5,a4,8000426c <filewrite+0x5c>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if (f->type == FD_INODE) {
    8000423a:	4709                	li	a4,2
    8000423c:	0ce79f63          	bne	a5,a4,8000431a <filewrite+0x10a>
    80004240:	f852                	sd	s4,48(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS - 1 - 1 - 2) / 2) * BSIZE;
    int i = 0;
    while (i < n) {
    80004242:	0ac05a63          	blez	a2,800042f6 <filewrite+0xe6>
    80004246:	e4a6                	sd	s1,72(sp)
    80004248:	fc4e                	sd	s3,56(sp)
    8000424a:	ec5e                	sd	s7,24(sp)
    8000424c:	e862                	sd	s8,16(sp)
    8000424e:	e466                	sd	s9,8(sp)
    int i = 0;
    80004250:	4a01                	li	s4,0
      int n1 = n - i;
      if (n1 > max)
    80004252:	6b85                	lui	s7,0x1
    80004254:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004258:	6785                	lui	a5,0x1
    8000425a:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    8000425e:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004260:	4c05                	li	s8,1
    80004262:	a8ad                	j	800042dc <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    80004264:	6908                	ld	a0,16(a0)
    80004266:	1f8000ef          	jal	8000445e <pipewrite>
    8000426a:	a04d                	j	8000430c <filewrite+0xfc>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000426c:	02451783          	lh	a5,36(a0)
    80004270:	03079693          	slli	a3,a5,0x30
    80004274:	92c1                	srli	a3,a3,0x30
    80004276:	4725                	li	a4,9
    80004278:	0ad76d63          	bltu	a4,a3,80004332 <filewrite+0x122>
    8000427c:	0792                	slli	a5,a5,0x4
    8000427e:	0001b717          	auipc	a4,0x1b
    80004282:	76270713          	addi	a4,a4,1890 # 8001f9e0 <devsw>
    80004286:	97ba                	add	a5,a5,a4
    80004288:	679c                	ld	a5,8(a5)
    8000428a:	c7c5                	beqz	a5,80004332 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    8000428c:	4505                	li	a0,1
    8000428e:	9782                	jalr	a5
    80004290:	a8b5                	j	8000430c <filewrite+0xfc>
      if (n1 > max)
    80004292:	2981                	sext.w	s3,s3
      begin_op();
    80004294:	921ff0ef          	jal	80003bb4 <begin_op>
      ilock(f->ip);
    80004298:	01893503          	ld	a0,24(s2)
    8000429c:	efdfe0ef          	jal	80003198 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800042a0:	874e                	mv	a4,s3
    800042a2:	02092683          	lw	a3,32(s2)
    800042a6:	016a0633          	add	a2,s4,s6
    800042aa:	85e2                	mv	a1,s8
    800042ac:	01893503          	ld	a0,24(s2)
    800042b0:	b6cff0ef          	jal	8000361c <writei>
    800042b4:	84aa                	mv	s1,a0
    800042b6:	00a05763          	blez	a0,800042c4 <filewrite+0xb4>
        f->off += r;
    800042ba:	02092783          	lw	a5,32(s2)
    800042be:	9fa9                	addw	a5,a5,a0
    800042c0:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800042c4:	01893503          	ld	a0,24(s2)
    800042c8:	f7ffe0ef          	jal	80003246 <iunlock>
      end_op();
    800042cc:	959ff0ef          	jal	80003c24 <end_op>

      if (r != n1) {
    800042d0:	02999563          	bne	s3,s1,800042fa <filewrite+0xea>
        // error from writei
        break;
      }
      i += r;
    800042d4:	01448a3b          	addw	s4,s1,s4
    while (i < n) {
    800042d8:	015a5963          	bge	s4,s5,800042ea <filewrite+0xda>
      int n1 = n - i;
    800042dc:	414a87bb          	subw	a5,s5,s4
    800042e0:	89be                	mv	s3,a5
      if (n1 > max)
    800042e2:	fafbd8e3          	bge	s7,a5,80004292 <filewrite+0x82>
    800042e6:	89e6                	mv	s3,s9
    800042e8:	b76d                	j	80004292 <filewrite+0x82>
    800042ea:	64a6                	ld	s1,72(sp)
    800042ec:	79e2                	ld	s3,56(sp)
    800042ee:	6be2                	ld	s7,24(sp)
    800042f0:	6c42                	ld	s8,16(sp)
    800042f2:	6ca2                	ld	s9,8(sp)
    800042f4:	a801                	j	80004304 <filewrite+0xf4>
    int i = 0;
    800042f6:	4a01                	li	s4,0
    800042f8:	a031                	j	80004304 <filewrite+0xf4>
    800042fa:	64a6                	ld	s1,72(sp)
    800042fc:	79e2                	ld	s3,56(sp)
    800042fe:	6be2                	ld	s7,24(sp)
    80004300:	6c42                	ld	s8,16(sp)
    80004302:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    80004304:	034a9963          	bne	s5,s4,80004336 <filewrite+0x126>
    80004308:	8556                	mv	a0,s5
    8000430a:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000430c:	60e6                	ld	ra,88(sp)
    8000430e:	6446                	ld	s0,80(sp)
    80004310:	6906                	ld	s2,64(sp)
    80004312:	7aa2                	ld	s5,40(sp)
    80004314:	7b02                	ld	s6,32(sp)
    80004316:	6125                	addi	sp,sp,96
    80004318:	8082                	ret
    8000431a:	e4a6                	sd	s1,72(sp)
    8000431c:	fc4e                	sd	s3,56(sp)
    8000431e:	f852                	sd	s4,48(sp)
    80004320:	ec5e                	sd	s7,24(sp)
    80004322:	e862                	sd	s8,16(sp)
    80004324:	e466                	sd	s9,8(sp)
    panic("filewrite");
    80004326:	00003517          	auipc	a0,0x3
    8000432a:	26250513          	addi	a0,a0,610 # 80007588 <etext+0x588>
    8000432e:	d0cfc0ef          	jal	8000083a <panic>
    return -1;
    80004332:	557d                	li	a0,-1
    80004334:	bfe1                	j	8000430c <filewrite+0xfc>
    ret = (i == n ? n : -1);
    80004336:	557d                	li	a0,-1
    80004338:	7a42                	ld	s4,48(sp)
    8000433a:	bfc9                	j	8000430c <filewrite+0xfc>
    return -1;
    8000433c:	557d                	li	a0,-1
}
    8000433e:	8082                	ret

0000000080004340 <pipealloc>:
  int writeopen; // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004340:	7179                	addi	sp,sp,-48
    80004342:	f406                	sd	ra,40(sp)
    80004344:	f022                	sd	s0,32(sp)
    80004346:	ec26                	sd	s1,24(sp)
    80004348:	e052                	sd	s4,0(sp)
    8000434a:	1800                	addi	s0,sp,48
    8000434c:	84aa                	mv	s1,a0
    8000434e:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004350:	0005b023          	sd	zero,0(a1)
    80004354:	00053023          	sd	zero,0(a0)
  if ((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004358:	c37ff0ef          	jal	80003f8e <filealloc>
    8000435c:	e088                	sd	a0,0(s1)
    8000435e:	c549                	beqz	a0,800043e8 <pipealloc+0xa8>
    80004360:	c2fff0ef          	jal	80003f8e <filealloc>
    80004364:	00aa3023          	sd	a0,0(s4)
    80004368:	cd25                	beqz	a0,800043e0 <pipealloc+0xa0>
    8000436a:	e84a                	sd	s2,16(sp)
    goto bad;
  if ((pi = (struct pipe *)kalloc()) == 0)
    8000436c:	fd2fc0ef          	jal	80000b3e <kalloc>
    80004370:	892a                	mv	s2,a0
    80004372:	c12d                	beqz	a0,800043d4 <pipealloc+0x94>
    80004374:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004376:	4985                	li	s3,1
    80004378:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000437c:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004380:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004384:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004388:	00003597          	auipc	a1,0x3
    8000438c:	21058593          	addi	a1,a1,528 # 80007598 <etext+0x598>
    80004390:	809fc0ef          	jal	80000b98 <initlock>
  (*f0)->type = FD_PIPE;
    80004394:	609c                	ld	a5,0(s1)
    80004396:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000439a:	609c                	ld	a5,0(s1)
    8000439c:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800043a0:	609c                	ld	a5,0(s1)
    800043a2:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800043a6:	609c                	ld	a5,0(s1)
    800043a8:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800043ac:	000a3783          	ld	a5,0(s4)
    800043b0:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800043b4:	000a3783          	ld	a5,0(s4)
    800043b8:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800043bc:	000a3783          	ld	a5,0(s4)
    800043c0:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800043c4:	000a3783          	ld	a5,0(s4)
    800043c8:	0127b823          	sd	s2,16(a5)
  return 0;
    800043cc:	4501                	li	a0,0
    800043ce:	6942                	ld	s2,16(sp)
    800043d0:	69a2                	ld	s3,8(sp)
    800043d2:	a00d                	j	800043f4 <pipealloc+0xb4>

bad:
  if (pi)
    kfree((char *)pi);
  if (*f0)
    800043d4:	6088                	ld	a0,0(s1)
    800043d6:	c119                	beqz	a0,800043dc <pipealloc+0x9c>
    800043d8:	6942                	ld	s2,16(sp)
    800043da:	a029                	j	800043e4 <pipealloc+0xa4>
    800043dc:	6942                	ld	s2,16(sp)
    800043de:	a029                	j	800043e8 <pipealloc+0xa8>
    800043e0:	6088                	ld	a0,0(s1)
    800043e2:	c901                	beqz	a0,800043f2 <pipealloc+0xb2>
    fileclose(*f0);
    800043e4:	c4fff0ef          	jal	80004032 <fileclose>
  if (*f1)
    800043e8:	000a3503          	ld	a0,0(s4)
    800043ec:	c119                	beqz	a0,800043f2 <pipealloc+0xb2>
    fileclose(*f1);
    800043ee:	c45ff0ef          	jal	80004032 <fileclose>
  return -1;
    800043f2:	557d                	li	a0,-1
}
    800043f4:	70a2                	ld	ra,40(sp)
    800043f6:	7402                	ld	s0,32(sp)
    800043f8:	64e2                	ld	s1,24(sp)
    800043fa:	6a02                	ld	s4,0(sp)
    800043fc:	6145                	addi	sp,sp,48
    800043fe:	8082                	ret

0000000080004400 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004400:	1101                	addi	sp,sp,-32
    80004402:	ec06                	sd	ra,24(sp)
    80004404:	e822                	sd	s0,16(sp)
    80004406:	e426                	sd	s1,8(sp)
    80004408:	e04a                	sd	s2,0(sp)
    8000440a:	1000                	addi	s0,sp,32
    8000440c:	84aa                	mv	s1,a0
    8000440e:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004410:	809fc0ef          	jal	80000c18 <acquire>
  if (writable) {
    80004414:	02090763          	beqz	s2,80004442 <pipeclose+0x42>
    pi->writeopen = 0;
    80004418:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000441c:	21848513          	addi	a0,s1,536
    80004420:	afdfd0ef          	jal	80001f1c <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if (pi->readopen == 0 && pi->writeopen == 0) {
    80004424:	2204a783          	lw	a5,544(s1)
    80004428:	e781                	bnez	a5,80004430 <pipeclose+0x30>
    8000442a:	2244a783          	lw	a5,548(s1)
    8000442e:	c38d                	beqz	a5,80004450 <pipeclose+0x50>
    release(&pi->lock);
    kfree((char *)pi);
  } else
    release(&pi->lock);
    80004430:	8526                	mv	a0,s1
    80004432:	86bfc0ef          	jal	80000c9c <release>
}
    80004436:	60e2                	ld	ra,24(sp)
    80004438:	6442                	ld	s0,16(sp)
    8000443a:	64a2                	ld	s1,8(sp)
    8000443c:	6902                	ld	s2,0(sp)
    8000443e:	6105                	addi	sp,sp,32
    80004440:	8082                	ret
    pi->readopen = 0;
    80004442:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004446:	21c48513          	addi	a0,s1,540
    8000444a:	ad3fd0ef          	jal	80001f1c <wakeup>
    8000444e:	bfd9                	j	80004424 <pipeclose+0x24>
    release(&pi->lock);
    80004450:	8526                	mv	a0,s1
    80004452:	84bfc0ef          	jal	80000c9c <release>
    kfree((char *)pi);
    80004456:	8526                	mv	a0,s1
    80004458:	dfefc0ef          	jal	80000a56 <kfree>
    8000445c:	bfe9                	j	80004436 <pipeclose+0x36>

000000008000445e <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000445e:	7159                	addi	sp,sp,-112
    80004460:	f486                	sd	ra,104(sp)
    80004462:	f0a2                	sd	s0,96(sp)
    80004464:	eca6                	sd	s1,88(sp)
    80004466:	e8ca                	sd	s2,80(sp)
    80004468:	e4ce                	sd	s3,72(sp)
    8000446a:	e0d2                	sd	s4,64(sp)
    8000446c:	fc56                	sd	s5,56(sp)
    8000446e:	1880                	addi	s0,sp,112
    80004470:	84aa                	mv	s1,a0
    80004472:	8aae                	mv	s5,a1
    80004474:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004476:	c68fd0ef          	jal	800018de <myproc>
    8000447a:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    8000447c:	8526                	mv	a0,s1
    8000447e:	f9afc0ef          	jal	80000c18 <acquire>
  while (i < n) {
    80004482:	0d405263          	blez	s4,80004546 <pipewrite+0xe8>
    80004486:	f85a                	sd	s6,48(sp)
    80004488:	f45e                	sd	s7,40(sp)
    8000448a:	f062                	sd	s8,32(sp)
    8000448c:	ec66                	sd	s9,24(sp)
    8000448e:	e86a                	sd	s10,16(sp)
  int i = 0;
    80004490:	4901                	li	s2,0
    if (pi->nwrite == pi->nread + PIPESIZE) { //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if (copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004492:	f9f40c13          	addi	s8,s0,-97
    80004496:	4b85                	li	s7,1
    80004498:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000449a:	21848d13          	addi	s10,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000449e:	21c48c93          	addi	s9,s1,540
    800044a2:	a82d                	j	800044dc <pipewrite+0x7e>
      release(&pi->lock);
    800044a4:	8526                	mv	a0,s1
    800044a6:	ff6fc0ef          	jal	80000c9c <release>
      return -1;
    800044aa:	597d                	li	s2,-1
    800044ac:	7b42                	ld	s6,48(sp)
    800044ae:	7ba2                	ld	s7,40(sp)
    800044b0:	7c02                	ld	s8,32(sp)
    800044b2:	6ce2                	ld	s9,24(sp)
    800044b4:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800044b6:	854a                	mv	a0,s2
    800044b8:	70a6                	ld	ra,104(sp)
    800044ba:	7406                	ld	s0,96(sp)
    800044bc:	64e6                	ld	s1,88(sp)
    800044be:	6946                	ld	s2,80(sp)
    800044c0:	69a6                	ld	s3,72(sp)
    800044c2:	6a06                	ld	s4,64(sp)
    800044c4:	7ae2                	ld	s5,56(sp)
    800044c6:	6165                	addi	sp,sp,112
    800044c8:	8082                	ret
      wakeup(&pi->nread);
    800044ca:	856a                	mv	a0,s10
    800044cc:	a51fd0ef          	jal	80001f1c <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800044d0:	85a6                	mv	a1,s1
    800044d2:	8566                	mv	a0,s9
    800044d4:	9fdfd0ef          	jal	80001ed0 <sleep>
  while (i < n) {
    800044d8:	05495a63          	bge	s2,s4,8000452c <pipewrite+0xce>
    if (pi->readopen == 0 || killed(pr)) {
    800044dc:	2204a783          	lw	a5,544(s1)
    800044e0:	d3f1                	beqz	a5,800044a4 <pipewrite+0x46>
    800044e2:	854e                	mv	a0,s3
    800044e4:	c29fd0ef          	jal	8000210c <killed>
    800044e8:	fd55                	bnez	a0,800044a4 <pipewrite+0x46>
    if (pi->nwrite == pi->nread + PIPESIZE) { //DOC: pipewrite-full
    800044ea:	2184a783          	lw	a5,536(s1)
    800044ee:	21c4a703          	lw	a4,540(s1)
    800044f2:	2007879b          	addiw	a5,a5,512
    800044f6:	fcf70ae3          	beq	a4,a5,800044ca <pipewrite+0x6c>
      if (copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800044fa:	86de                	mv	a3,s7
    800044fc:	01590633          	add	a2,s2,s5
    80004500:	85e2                	mv	a1,s8
    80004502:	0509b503          	ld	a0,80(s3)
    80004506:	9c2fd0ef          	jal	800016c8 <copyin>
    8000450a:	05650063          	beq	a0,s6,8000454a <pipewrite+0xec>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000450e:	21c4a783          	lw	a5,540(s1)
    80004512:	0017871b          	addiw	a4,a5,1
    80004516:	20e4ae23          	sw	a4,540(s1)
    8000451a:	1ff7f793          	andi	a5,a5,511
    8000451e:	97a6                	add	a5,a5,s1
    80004520:	f9f44703          	lbu	a4,-97(s0)
    80004524:	00e78c23          	sb	a4,24(a5)
      i++;
    80004528:	2905                	addiw	s2,s2,1
    8000452a:	b77d                	j	800044d8 <pipewrite+0x7a>
    8000452c:	7b42                	ld	s6,48(sp)
    8000452e:	7ba2                	ld	s7,40(sp)
    80004530:	7c02                	ld	s8,32(sp)
    80004532:	6ce2                	ld	s9,24(sp)
    80004534:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    80004536:	21848513          	addi	a0,s1,536
    8000453a:	9e3fd0ef          	jal	80001f1c <wakeup>
  release(&pi->lock);
    8000453e:	8526                	mv	a0,s1
    80004540:	f5cfc0ef          	jal	80000c9c <release>
  return i;
    80004544:	bf8d                	j	800044b6 <pipewrite+0x58>
  int i = 0;
    80004546:	4901                	li	s2,0
    80004548:	b7fd                	j	80004536 <pipewrite+0xd8>
    8000454a:	7b42                	ld	s6,48(sp)
    8000454c:	7ba2                	ld	s7,40(sp)
    8000454e:	7c02                	ld	s8,32(sp)
    80004550:	6ce2                	ld	s9,24(sp)
    80004552:	6d42                	ld	s10,16(sp)
    80004554:	b7cd                	j	80004536 <pipewrite+0xd8>

0000000080004556 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004556:	711d                	addi	sp,sp,-96
    80004558:	ec86                	sd	ra,88(sp)
    8000455a:	e8a2                	sd	s0,80(sp)
    8000455c:	e4a6                	sd	s1,72(sp)
    8000455e:	e0ca                	sd	s2,64(sp)
    80004560:	fc4e                	sd	s3,56(sp)
    80004562:	f852                	sd	s4,48(sp)
    80004564:	f456                	sd	s5,40(sp)
    80004566:	1080                	addi	s0,sp,96
    80004568:	84aa                	mv	s1,a0
    8000456a:	892e                	mv	s2,a1
    8000456c:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000456e:	b70fd0ef          	jal	800018de <myproc>
    80004572:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004574:	8526                	mv	a0,s1
    80004576:	ea2fc0ef          	jal	80000c18 <acquire>
  while (pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    8000457a:	2184a703          	lw	a4,536(s1)
    8000457e:	21c4a783          	lw	a5,540(s1)
    if (killed(pr)) {
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004582:	21848993          	addi	s3,s1,536
  while (pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004586:	02f71363          	bne	a4,a5,800045ac <piperead+0x56>
    8000458a:	2244a783          	lw	a5,548(s1)
    8000458e:	cf99                	beqz	a5,800045ac <piperead+0x56>
    if (killed(pr)) {
    80004590:	8552                	mv	a0,s4
    80004592:	b7bfd0ef          	jal	8000210c <killed>
    80004596:	e925                	bnez	a0,80004606 <piperead+0xb0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004598:	85a6                	mv	a1,s1
    8000459a:	854e                	mv	a0,s3
    8000459c:	935fd0ef          	jal	80001ed0 <sleep>
  while (pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    800045a0:	2184a703          	lw	a4,536(s1)
    800045a4:	21c4a783          	lw	a5,540(s1)
    800045a8:	fef701e3          	beq	a4,a5,8000458a <piperead+0x34>
  }
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    800045ac:	07505863          	blez	s5,8000461c <piperead+0xc6>
    800045b0:	f05a                	sd	s6,32(sp)
    800045b2:	ec5e                	sd	s7,24(sp)
    800045b4:	e862                	sd	s8,16(sp)
    800045b6:	4981                	li	s3,0
    if (pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if (copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    800045b8:	faf40c13          	addi	s8,s0,-81
    800045bc:	4b85                	li	s7,1
    800045be:	5b7d                	li	s6,-1
    if (pi->nread == pi->nwrite)
    800045c0:	2184a783          	lw	a5,536(s1)
    800045c4:	21c4a703          	lw	a4,540(s1)
    800045c8:	06f70163          	beq	a4,a5,8000462a <piperead+0xd4>
    ch = pi->data[pi->nread % PIPESIZE];
    800045cc:	1ff7f793          	andi	a5,a5,511
    800045d0:	97a6                	add	a5,a5,s1
    800045d2:	0187c783          	lbu	a5,24(a5)
    800045d6:	faf407a3          	sb	a5,-81(s0)
    if (copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    800045da:	86de                	mv	a3,s7
    800045dc:	8662                	mv	a2,s8
    800045de:	85ca                	mv	a1,s2
    800045e0:	050a3503          	ld	a0,80(s4)
    800045e4:	82cfd0ef          	jal	80001610 <copyout>
    800045e8:	03650463          	beq	a0,s6,80004610 <piperead+0xba>
      if (i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    800045ec:	2184a783          	lw	a5,536(s1)
    800045f0:	2785                	addiw	a5,a5,1
    800045f2:	20f4ac23          	sw	a5,536(s1)
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    800045f6:	2985                	addiw	s3,s3,1
    800045f8:	0905                	addi	s2,s2,1
    800045fa:	fd3a93e3          	bne	s5,s3,800045c0 <piperead+0x6a>
    800045fe:	7b02                	ld	s6,32(sp)
    80004600:	6be2                	ld	s7,24(sp)
    80004602:	6c42                	ld	s8,16(sp)
    80004604:	a035                	j	80004630 <piperead+0xda>
      release(&pi->lock);
    80004606:	8526                	mv	a0,s1
    80004608:	e94fc0ef          	jal	80000c9c <release>
      return -1;
    8000460c:	59fd                	li	s3,-1
    8000460e:	a805                	j	8000463e <piperead+0xe8>
      if (i == 0)
    80004610:	00098863          	beqz	s3,80004620 <piperead+0xca>
    80004614:	7b02                	ld	s6,32(sp)
    80004616:	6be2                	ld	s7,24(sp)
    80004618:	6c42                	ld	s8,16(sp)
    8000461a:	a819                	j	80004630 <piperead+0xda>
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    8000461c:	4981                	li	s3,0
    8000461e:	a809                	j	80004630 <piperead+0xda>
        i = -1;
    80004620:	89aa                	mv	s3,a0
    80004622:	7b02                	ld	s6,32(sp)
    80004624:	6be2                	ld	s7,24(sp)
    80004626:	6c42                	ld	s8,16(sp)
    80004628:	a021                	j	80004630 <piperead+0xda>
    8000462a:	7b02                	ld	s6,32(sp)
    8000462c:	6be2                	ld	s7,24(sp)
    8000462e:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nwrite); //DOC: piperead-wakeup
    80004630:	21c48513          	addi	a0,s1,540
    80004634:	8e9fd0ef          	jal	80001f1c <wakeup>
  release(&pi->lock);
    80004638:	8526                	mv	a0,s1
    8000463a:	e62fc0ef          	jal	80000c9c <release>
  return i;
}
    8000463e:	854e                	mv	a0,s3
    80004640:	60e6                	ld	ra,88(sp)
    80004642:	6446                	ld	s0,80(sp)
    80004644:	64a6                	ld	s1,72(sp)
    80004646:	6906                	ld	s2,64(sp)
    80004648:	79e2                	ld	s3,56(sp)
    8000464a:	7a42                	ld	s4,48(sp)
    8000464c:	7aa2                	ld	s5,40(sp)
    8000464e:	6125                	addi	sp,sp,96
    80004650:	8082                	ret

0000000080004652 <flags2perm>:
static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int
flags2perm(int flags)
{
    80004652:	1141                	addi	sp,sp,-16
    80004654:	e406                	sd	ra,8(sp)
    80004656:	e022                	sd	s0,0(sp)
    80004658:	0800                	addi	s0,sp,16
    8000465a:	87aa                	mv	a5,a0
  int perm = 0;
  if (flags & 0x1)
    8000465c:	0035151b          	slliw	a0,a0,0x3
    80004660:	8921                	andi	a0,a0,8
    perm = PTE_X;
  if (flags & 0x2)
    80004662:	8b89                	andi	a5,a5,2
    80004664:	c399                	beqz	a5,8000466a <flags2perm+0x18>
    perm |= PTE_W;
    80004666:	00456513          	ori	a0,a0,4
  return perm;
}
    8000466a:	60a2                	ld	ra,8(sp)
    8000466c:	6402                	ld	s0,0(sp)
    8000466e:	0141                	addi	sp,sp,16
    80004670:	8082                	ret

0000000080004672 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80004672:	df010113          	addi	sp,sp,-528
    80004676:	20113423          	sd	ra,520(sp)
    8000467a:	20813023          	sd	s0,512(sp)
    8000467e:	ffa6                	sd	s1,504(sp)
    80004680:	fbca                	sd	s2,496(sp)
    80004682:	0c00                	addi	s0,sp,528
    80004684:	892a                	mv	s2,a0
    80004686:	e0a43023          	sd	a0,-512(s0)
    8000468a:	deb43c23          	sd	a1,-520(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000468e:	a50fd0ef          	jal	800018de <myproc>
    80004692:	84aa                	mv	s1,a0

  begin_op();
    80004694:	d20ff0ef          	jal	80003bb4 <begin_op>

  // Open the executable file.
  if ((ip = namei(path)) == 0) {
    80004698:	854a                	mv	a0,s2
    8000469a:	b3cff0ef          	jal	800039d6 <namei>
    8000469e:	c931                	beqz	a0,800046f2 <kexec+0x80>
    800046a0:	f3d2                	sd	s4,480(sp)
    800046a2:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800046a4:	af5fe0ef          	jal	80003198 <ilock>

  // Read the ELF header.
  if (readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800046a8:	04000713          	li	a4,64
    800046ac:	4681                	li	a3,0
    800046ae:	e5040613          	addi	a2,s0,-432
    800046b2:	4581                	li	a1,0
    800046b4:	8552                	mv	a0,s4
    800046b6:	e75fe0ef          	jal	8000352a <readi>
    800046ba:	04000793          	li	a5,64
    800046be:	00f51a63          	bne	a0,a5,800046d2 <kexec+0x60>
    goto bad;

  // Is this really an ELF file?
  if (elf.magic != ELF_MAGIC)
    800046c2:	e5042703          	lw	a4,-432(s0)
    800046c6:	464c47b7          	lui	a5,0x464c4
    800046ca:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800046ce:	02f70563          	beq	a4,a5,800046f8 <kexec+0x86>

bad:
  if (pagetable)
    proc_freepagetable(pagetable, sz);
  if (ip) {
    iunlockput(ip);
    800046d2:	8552                	mv	a0,s4
    800046d4:	cd1fe0ef          	jal	800033a4 <iunlockput>
    end_op();
    800046d8:	d4cff0ef          	jal	80003c24 <end_op>
    800046dc:	7a1e                	ld	s4,480(sp)
    return -1;
    800046de:	557d                	li	a0,-1
  }
  return -1;
}
    800046e0:	20813083          	ld	ra,520(sp)
    800046e4:	20013403          	ld	s0,512(sp)
    800046e8:	74fe                	ld	s1,504(sp)
    800046ea:	795e                	ld	s2,496(sp)
    800046ec:	21010113          	addi	sp,sp,528
    800046f0:	8082                	ret
    end_op();
    800046f2:	d32ff0ef          	jal	80003c24 <end_op>
    return -1;
    800046f6:	b7e5                	j	800046de <kexec+0x6c>
    800046f8:	ebda                	sd	s6,464(sp)
  if ((pagetable = proc_pagetable(p)) == 0)
    800046fa:	8526                	mv	a0,s1
    800046fc:	af8fd0ef          	jal	800019f4 <proc_pagetable>
    80004700:	8b2a                	mv	s6,a0
    80004702:	26050063          	beqz	a0,80004962 <kexec+0x2f0>
    80004706:	f7ce                	sd	s3,488(sp)
    80004708:	efd6                	sd	s5,472(sp)
    8000470a:	e7de                	sd	s7,456(sp)
    8000470c:	e3e2                	sd	s8,448(sp)
    8000470e:	ff66                	sd	s9,440(sp)
    80004710:	fb6a                	sd	s10,432(sp)
    80004712:	f76e                	sd	s11,424(sp)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004714:	e8845783          	lhu	a5,-376(s0)
    80004718:	cff9                	beqz	a5,800047f6 <kexec+0x184>
    8000471a:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000471e:	4901                	li	s2,0
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004720:	4d01                	li	s10,0
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004722:	03800d93          	li	s11,56

  for (i = 0; i < sz; i += PGSIZE) {
    pa = walkaddr(pagetable, va + i);
    if (pa == 0)
      panic("loadseg: address should exist");
    if (sz - i < PGSIZE)
    80004726:	6c85                	lui	s9,0x1
    80004728:	6a85                	lui	s5,0x1
    8000472a:	a085                	j	8000478a <kexec+0x118>
      panic("loadseg: address should exist");
    8000472c:	00003517          	auipc	a0,0x3
    80004730:	e7450513          	addi	a0,a0,-396 # 800075a0 <etext+0x5a0>
    80004734:	906fc0ef          	jal	8000083a <panic>
    if (sz - i < PGSIZE)
    80004738:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if (readi(ip, 0, (uint64)pa, offset + i, n) != n)
    8000473a:	874a                	mv	a4,s2
    8000473c:	009b86bb          	addw	a3,s7,s1
    80004740:	4581                	li	a1,0
    80004742:	8552                	mv	a0,s4
    80004744:	de7fe0ef          	jal	8000352a <readi>
    80004748:	22a91163          	bne	s2,a0,8000496a <kexec+0x2f8>
  for (i = 0; i < sz; i += PGSIZE) {
    8000474c:	009a84bb          	addw	s1,s5,s1
    80004750:	0334f263          	bgeu	s1,s3,80004774 <kexec+0x102>
    pa = walkaddr(pagetable, va + i);
    80004754:	02049593          	slli	a1,s1,0x20
    80004758:	9181                	srli	a1,a1,0x20
    8000475a:	95e2                	add	a1,a1,s8
    8000475c:	855a                	mv	a0,s6
    8000475e:	89bfc0ef          	jal	80000ff8 <walkaddr>
    80004762:	862a                	mv	a2,a0
    if (pa == 0)
    80004764:	d561                	beqz	a0,8000472c <kexec+0xba>
    if (sz - i < PGSIZE)
    80004766:	409987bb          	subw	a5,s3,s1
    8000476a:	893e                	mv	s2,a5
    8000476c:	fcfcf6e3          	bgeu	s9,a5,80004738 <kexec+0xc6>
    80004770:	8956                	mv	s2,s5
    80004772:	b7d9                	j	80004738 <kexec+0xc6>
    sz = sz1;
    80004774:	df043903          	ld	s2,-528(s0)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004778:	2d05                	addiw	s10,s10,1
    8000477a:	e0843783          	ld	a5,-504(s0)
    8000477e:	0387869b          	addiw	a3,a5,56
    80004782:	e8845783          	lhu	a5,-376(s0)
    80004786:	06fd5963          	bge	s10,a5,800047f8 <kexec+0x186>
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000478a:	e0d43423          	sd	a3,-504(s0)
    8000478e:	876e                	mv	a4,s11
    80004790:	e1840613          	addi	a2,s0,-488
    80004794:	4581                	li	a1,0
    80004796:	8552                	mv	a0,s4
    80004798:	d93fe0ef          	jal	8000352a <readi>
    8000479c:	1db51563          	bne	a0,s11,80004966 <kexec+0x2f4>
    if (ph.type != ELF_PROG_LOAD)
    800047a0:	e1842783          	lw	a5,-488(s0)
    800047a4:	4705                	li	a4,1
    800047a6:	fce799e3          	bne	a5,a4,80004778 <kexec+0x106>
    if (ph.memsz < ph.filesz)
    800047aa:	e4043483          	ld	s1,-448(s0)
    800047ae:	e3843783          	ld	a5,-456(s0)
    800047b2:	1af4ea63          	bltu	s1,a5,80004966 <kexec+0x2f4>
    if (ph.vaddr + ph.memsz < ph.vaddr)
    800047b6:	e2843783          	ld	a5,-472(s0)
    800047ba:	94be                	add	s1,s1,a5
    800047bc:	1af4e563          	bltu	s1,a5,80004966 <kexec+0x2f4>
    if (ph.vaddr % PGSIZE != 0)
    800047c0:	17d2                	slli	a5,a5,0x34
    800047c2:	1a079263          	bnez	a5,80004966 <kexec+0x2f4>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz,
    800047c6:	e1c42503          	lw	a0,-484(s0)
    800047ca:	e89ff0ef          	jal	80004652 <flags2perm>
    800047ce:	86aa                	mv	a3,a0
    800047d0:	8626                	mv	a2,s1
    800047d2:	85ca                	mv	a1,s2
    800047d4:	855a                	mv	a0,s6
    800047d6:	af1fc0ef          	jal	800012c6 <uvmalloc>
    800047da:	dea43823          	sd	a0,-528(s0)
    800047de:	18050463          	beqz	a0,80004966 <kexec+0x2f4>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800047e2:	e3842983          	lw	s3,-456(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    800047e6:	f80987e3          	beqz	s3,80004774 <kexec+0x102>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800047ea:	e2843c03          	ld	s8,-472(s0)
    800047ee:	e2042b83          	lw	s7,-480(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    800047f2:	4481                	li	s1,0
    800047f4:	b785                	j	80004754 <kexec+0xe2>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800047f6:	4901                	li	s2,0
  iunlockput(ip);
    800047f8:	8552                	mv	a0,s4
    800047fa:	babfe0ef          	jal	800033a4 <iunlockput>
  end_op();
    800047fe:	c26ff0ef          	jal	80003c24 <end_op>
  p = myproc();
    80004802:	8dcfd0ef          	jal	800018de <myproc>
    80004806:	89aa                	mv	s3,a0
  uint64 oldsz = p->sz;
    80004808:	04853a83          	ld	s5,72(a0)
  sz = PGROUNDUP(sz);
    8000480c:	6485                	lui	s1,0x1
    8000480e:	14fd                	addi	s1,s1,-1 # fff <_entry-0x7ffff001>
    80004810:	94ca                	add	s1,s1,s2
    80004812:	77fd                	lui	a5,0xfffff
    80004814:	8cfd                	and	s1,s1,a5
  if ((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK + 1) * PGSIZE, PTE_W)) ==
    80004816:	4691                	li	a3,4
    80004818:	6609                	lui	a2,0x2
    8000481a:	9626                	add	a2,a2,s1
    8000481c:	85a6                	mv	a1,s1
    8000481e:	855a                	mv	a0,s6
    80004820:	aa7fc0ef          	jal	800012c6 <uvmalloc>
    80004824:	8a2a                	mv	s4,a0
    80004826:	ed19                	bnez	a0,80004844 <kexec+0x1d2>
    proc_freepagetable(pagetable, sz);
    80004828:	85a6                	mv	a1,s1
    8000482a:	855a                	mv	a0,s6
    8000482c:	a4afd0ef          	jal	80001a76 <proc_freepagetable>
  if (ip) {
    80004830:	79be                	ld	s3,488(sp)
    80004832:	7a1e                	ld	s4,480(sp)
    80004834:	6afe                	ld	s5,472(sp)
    80004836:	6b5e                	ld	s6,464(sp)
    80004838:	6bbe                	ld	s7,456(sp)
    8000483a:	6c1e                	ld	s8,448(sp)
    8000483c:	7cfa                	ld	s9,440(sp)
    8000483e:	7d5a                	ld	s10,432(sp)
    80004840:	7dba                	ld	s11,424(sp)
    80004842:	bd71                	j	800046de <kexec+0x6c>
  uvmclear(pagetable, sz - (USERSTACK + 1) * PGSIZE);
    80004844:	75f9                	lui	a1,0xffffe
    80004846:	95aa                	add	a1,a1,a0
    80004848:	855a                	mv	a0,s6
    8000484a:	c45fc0ef          	jal	8000148e <uvmclear>
  stackbase = sp - USERSTACK * PGSIZE;
    8000484e:	7c7d                	lui	s8,0xfffff
    80004850:	9c52                	add	s8,s8,s4
  for (argc = 0; argv[argc]; argc++) {
    80004852:	df843783          	ld	a5,-520(s0)
    80004856:	6388                	ld	a0,0(a5)
  sp = sz;
    80004858:	8952                	mv	s2,s4
  for (argc = 0; argv[argc]; argc++) {
    8000485a:	4481                	li	s1,0
    ustack[argc] = sp;
    8000485c:	e9040c93          	addi	s9,s0,-368
    if (argc >= MAXARG)
    80004860:	02000d13          	li	s10,32
  for (argc = 0; argv[argc]; argc++) {
    80004864:	cd21                	beqz	a0,800048bc <kexec+0x24a>
    sp -= strlen(argv[argc]) + 1;
    80004866:	deefc0ef          	jal	80000e54 <strlen>
    8000486a:	0015079b          	addiw	a5,a0,1
    8000486e:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004872:	ff07f913          	andi	s2,a5,-16
    if (sp < stackbase)
    80004876:	05896163          	bltu	s2,s8,800048b8 <kexec+0x246>
    if (copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000487a:	df843d83          	ld	s11,-520(s0)
    8000487e:	000dbb83          	ld	s7,0(s11)
    80004882:	855e                	mv	a0,s7
    80004884:	dd0fc0ef          	jal	80000e54 <strlen>
    80004888:	0015069b          	addiw	a3,a0,1
    8000488c:	865e                	mv	a2,s7
    8000488e:	85ca                	mv	a1,s2
    80004890:	855a                	mv	a0,s6
    80004892:	d7ffc0ef          	jal	80001610 <copyout>
    80004896:	02054163          	bltz	a0,800048b8 <kexec+0x246>
    ustack[argc] = sp;
    8000489a:	00349793          	slli	a5,s1,0x3
    8000489e:	97e6                	add	a5,a5,s9
    800048a0:	0127b023          	sd	s2,0(a5) # fffffffffffff000 <end+0xffffffff7ffde488>
  for (argc = 0; argv[argc]; argc++) {
    800048a4:	0485                	addi	s1,s1,1
    800048a6:	008d8793          	addi	a5,s11,8
    800048aa:	def43c23          	sd	a5,-520(s0)
    800048ae:	008db503          	ld	a0,8(s11)
    800048b2:	c509                	beqz	a0,800048bc <kexec+0x24a>
    if (argc >= MAXARG)
    800048b4:	fba499e3          	bne	s1,s10,80004866 <kexec+0x1f4>
  sz = sz1;
    800048b8:	84d2                	mv	s1,s4
    800048ba:	b7bd                	j	80004828 <kexec+0x1b6>
  ustack[argc] = 0;
    800048bc:	00349793          	slli	a5,s1,0x3
    800048c0:	f9040713          	addi	a4,s0,-112
    800048c4:	97ba                	add	a5,a5,a4
    800048c6:	f007b023          	sd	zero,-256(a5)
  sp -= (argc + 1) * sizeof(uint64);
    800048ca:	00148693          	addi	a3,s1,1
    800048ce:	068e                	slli	a3,a3,0x3
    800048d0:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800048d4:	ff097913          	andi	s2,s2,-16
  if (sp < stackbase)
    800048d8:	ff8960e3          	bltu	s2,s8,800048b8 <kexec+0x246>
  if (copyout(pagetable, sp, (char *)ustack, (argc + 1) * sizeof(uint64)) < 0)
    800048dc:	e9040613          	addi	a2,s0,-368
    800048e0:	85ca                	mv	a1,s2
    800048e2:	855a                	mv	a0,s6
    800048e4:	d2dfc0ef          	jal	80001610 <copyout>
    800048e8:	fc0548e3          	bltz	a0,800048b8 <kexec+0x246>
  p->trapframe->a1 = sp;
    800048ec:	0589b783          	ld	a5,88(s3)
    800048f0:	0727bc23          	sd	s2,120(a5)
  for (last = s = path; *s; s++)
    800048f4:	e0043783          	ld	a5,-512(s0)
    800048f8:	0007c703          	lbu	a4,0(a5)
    800048fc:	cf11                	beqz	a4,80004918 <kexec+0x2a6>
    800048fe:	0785                	addi	a5,a5,1
    if (*s == '/')
    80004900:	02f00693          	li	a3,47
    80004904:	a029                	j	8000490e <kexec+0x29c>
  for (last = s = path; *s; s++)
    80004906:	0785                	addi	a5,a5,1
    80004908:	fff7c703          	lbu	a4,-1(a5)
    8000490c:	c711                	beqz	a4,80004918 <kexec+0x2a6>
    if (*s == '/')
    8000490e:	fed71ce3          	bne	a4,a3,80004906 <kexec+0x294>
      last = s + 1;
    80004912:	e0f43023          	sd	a5,-512(s0)
    80004916:	bfc5                	j	80004906 <kexec+0x294>
  safestrcpy(p->name, last, sizeof(p->name));
    80004918:	4641                	li	a2,16
    8000491a:	e0043583          	ld	a1,-512(s0)
    8000491e:	15898513          	addi	a0,s3,344
    80004922:	cfcfc0ef          	jal	80000e1e <safestrcpy>
  oldpagetable = p->pagetable;
    80004926:	0509b503          	ld	a0,80(s3)
  p->pagetable = pagetable;
    8000492a:	0569b823          	sd	s6,80(s3)
  p->sz = sz;
    8000492e:	0549b423          	sd	s4,72(s3)
  p->trapframe->epc = elf.entry; // initial program counter = ulib.c:start()
    80004932:	0589b783          	ld	a5,88(s3)
    80004936:	e6843703          	ld	a4,-408(s0)
    8000493a:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;         // initial stack pointer
    8000493c:	0589b783          	ld	a5,88(s3)
    80004940:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004944:	85d6                	mv	a1,s5
    80004946:	930fd0ef          	jal	80001a76 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000494a:	0004851b          	sext.w	a0,s1
    8000494e:	79be                	ld	s3,488(sp)
    80004950:	7a1e                	ld	s4,480(sp)
    80004952:	6afe                	ld	s5,472(sp)
    80004954:	6b5e                	ld	s6,464(sp)
    80004956:	6bbe                	ld	s7,456(sp)
    80004958:	6c1e                	ld	s8,448(sp)
    8000495a:	7cfa                	ld	s9,440(sp)
    8000495c:	7d5a                	ld	s10,432(sp)
    8000495e:	7dba                	ld	s11,424(sp)
    80004960:	b341                	j	800046e0 <kexec+0x6e>
    80004962:	6b5e                	ld	s6,464(sp)
    80004964:	b3bd                	j	800046d2 <kexec+0x60>
    return -1;
    80004966:	df243823          	sd	s2,-528(s0)
    proc_freepagetable(pagetable, sz);
    8000496a:	df043583          	ld	a1,-528(s0)
    8000496e:	855a                	mv	a0,s6
    80004970:	906fd0ef          	jal	80001a76 <proc_freepagetable>
  if (ip) {
    80004974:	79be                	ld	s3,488(sp)
    80004976:	6afe                	ld	s5,472(sp)
    80004978:	6b5e                	ld	s6,464(sp)
    8000497a:	6bbe                	ld	s7,456(sp)
    8000497c:	6c1e                	ld	s8,448(sp)
    8000497e:	7cfa                	ld	s9,440(sp)
    80004980:	7d5a                	ld	s10,432(sp)
    80004982:	7dba                	ld	s11,424(sp)
    80004984:	b3b9                	j	800046d2 <kexec+0x60>

0000000080004986 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004986:	7179                	addi	sp,sp,-48
    80004988:	f406                	sd	ra,40(sp)
    8000498a:	f022                	sd	s0,32(sp)
    8000498c:	ec26                	sd	s1,24(sp)
    8000498e:	e84a                	sd	s2,16(sp)
    80004990:	1800                	addi	s0,sp,48
    80004992:	892e                	mv	s2,a1
    80004994:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004996:	fdc40593          	addi	a1,s0,-36
    8000499a:	e27fd0ef          	jal	800027c0 <argint>
  if (fd < 0 || fd >= NOFILE || (f = myproc()->ofile[fd]) == 0)
    8000499e:	fdc42703          	lw	a4,-36(s0)
    800049a2:	47bd                	li	a5,15
    800049a4:	02e7e963          	bltu	a5,a4,800049d6 <argfd+0x50>
    800049a8:	f37fc0ef          	jal	800018de <myproc>
    800049ac:	fdc42703          	lw	a4,-36(s0)
    800049b0:	01a70793          	addi	a5,a4,26
    800049b4:	078e                	slli	a5,a5,0x3
    800049b6:	953e                	add	a0,a0,a5
    800049b8:	611c                	ld	a5,0(a0)
    800049ba:	cf91                	beqz	a5,800049d6 <argfd+0x50>
    return -1;
  if (pfd)
    800049bc:	00090463          	beqz	s2,800049c4 <argfd+0x3e>
    *pfd = fd;
    800049c0:	00e92023          	sw	a4,0(s2)
  if (pf)
    800049c4:	c091                	beqz	s1,800049c8 <argfd+0x42>
    *pf = f;
    800049c6:	e09c                	sd	a5,0(s1)
  return 0;
    800049c8:	4501                	li	a0,0
}
    800049ca:	70a2                	ld	ra,40(sp)
    800049cc:	7402                	ld	s0,32(sp)
    800049ce:	64e2                	ld	s1,24(sp)
    800049d0:	6942                	ld	s2,16(sp)
    800049d2:	6145                	addi	sp,sp,48
    800049d4:	8082                	ret
    return -1;
    800049d6:	557d                	li	a0,-1
    800049d8:	bfcd                	j	800049ca <argfd+0x44>

00000000800049da <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800049da:	1101                	addi	sp,sp,-32
    800049dc:	ec06                	sd	ra,24(sp)
    800049de:	e822                	sd	s0,16(sp)
    800049e0:	e426                	sd	s1,8(sp)
    800049e2:	1000                	addi	s0,sp,32
    800049e4:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800049e6:	ef9fc0ef          	jal	800018de <myproc>
    800049ea:	862a                	mv	a2,a0

  for (fd = 0; fd < NOFILE; fd++) {
    800049ec:	0d050793          	addi	a5,a0,208
    800049f0:	4501                	li	a0,0
    800049f2:	46c1                	li	a3,16
    if (p->ofile[fd] == 0) {
    800049f4:	6398                	ld	a4,0(a5)
    800049f6:	cb19                	beqz	a4,80004a0c <fdalloc+0x32>
  for (fd = 0; fd < NOFILE; fd++) {
    800049f8:	2505                	addiw	a0,a0,1
    800049fa:	07a1                	addi	a5,a5,8
    800049fc:	fed51ce3          	bne	a0,a3,800049f4 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004a00:	557d                	li	a0,-1
}
    80004a02:	60e2                	ld	ra,24(sp)
    80004a04:	6442                	ld	s0,16(sp)
    80004a06:	64a2                	ld	s1,8(sp)
    80004a08:	6105                	addi	sp,sp,32
    80004a0a:	8082                	ret
      p->ofile[fd] = f;
    80004a0c:	01a50793          	addi	a5,a0,26
    80004a10:	078e                	slli	a5,a5,0x3
    80004a12:	963e                	add	a2,a2,a5
    80004a14:	e204                	sd	s1,0(a2)
      return fd;
    80004a16:	b7f5                	j	80004a02 <fdalloc+0x28>

0000000080004a18 <create>:
  return -1;
}

static struct inode *
create(char *path, short type, short major, short minor)
{
    80004a18:	715d                	addi	sp,sp,-80
    80004a1a:	e486                	sd	ra,72(sp)
    80004a1c:	e0a2                	sd	s0,64(sp)
    80004a1e:	fc26                	sd	s1,56(sp)
    80004a20:	f84a                	sd	s2,48(sp)
    80004a22:	f44e                	sd	s3,40(sp)
    80004a24:	f052                	sd	s4,32(sp)
    80004a26:	ec56                	sd	s5,24(sp)
    80004a28:	e85a                	sd	s6,16(sp)
    80004a2a:	0880                	addi	s0,sp,80
    80004a2c:	892e                	mv	s2,a1
    80004a2e:	8a2e                	mv	s4,a1
    80004a30:	8ab2                	mv	s5,a2
    80004a32:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if ((dp = nameiparent(path, name)) == 0)
    80004a34:	fb040593          	addi	a1,s0,-80
    80004a38:	fb9fe0ef          	jal	800039f0 <nameiparent>
    80004a3c:	84aa                	mv	s1,a0
    return 0;
    80004a3e:	89aa                	mv	s3,a0
  if ((dp = nameiparent(path, name)) == 0)
    80004a40:	cd05                	beqz	a0,80004a78 <create+0x60>

  ilock(dp);
    80004a42:	f56fe0ef          	jal	80003198 <ilock>

  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80004a46:	4601                	li	a2,0
    80004a48:	fb040593          	addi	a1,s0,-80
    80004a4c:	8526                	mv	a0,s1
    80004a4e:	cedfe0ef          	jal	8000373a <dirlookup>
    80004a52:	89aa                	mv	s3,a0
    80004a54:	c131                	beqz	a0,80004a98 <create+0x80>
    iunlockput(dp);
    80004a56:	8526                	mv	a0,s1
    80004a58:	94dfe0ef          	jal	800033a4 <iunlockput>
    ilock(ip);
    80004a5c:	854e                	mv	a0,s3
    80004a5e:	f3afe0ef          	jal	80003198 <ilock>
    if (type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004a62:	4789                	li	a5,2
    80004a64:	02f91563          	bne	s2,a5,80004a8e <create+0x76>
    80004a68:	0449d783          	lhu	a5,68(s3)
    80004a6c:	37f9                	addiw	a5,a5,-2
    80004a6e:	17c2                	slli	a5,a5,0x30
    80004a70:	93c1                	srli	a5,a5,0x30
    80004a72:	4705                	li	a4,1
    80004a74:	00f76d63          	bltu	a4,a5,80004a8e <create+0x76>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004a78:	854e                	mv	a0,s3
    80004a7a:	60a6                	ld	ra,72(sp)
    80004a7c:	6406                	ld	s0,64(sp)
    80004a7e:	74e2                	ld	s1,56(sp)
    80004a80:	7942                	ld	s2,48(sp)
    80004a82:	79a2                	ld	s3,40(sp)
    80004a84:	7a02                	ld	s4,32(sp)
    80004a86:	6ae2                	ld	s5,24(sp)
    80004a88:	6b42                	ld	s6,16(sp)
    80004a8a:	6161                	addi	sp,sp,80
    80004a8c:	8082                	ret
    iunlockput(ip);
    80004a8e:	854e                	mv	a0,s3
    80004a90:	915fe0ef          	jal	800033a4 <iunlockput>
    return 0;
    80004a94:	4981                	li	s3,0
    80004a96:	b7cd                	j	80004a78 <create+0x60>
  if ((ip = ialloc(dp->dev, type)) == 0) {
    80004a98:	85ca                	mv	a1,s2
    80004a9a:	4088                	lw	a0,0(s1)
    80004a9c:	d8cfe0ef          	jal	80003028 <ialloc>
    80004aa0:	892a                	mv	s2,a0
    80004aa2:	cd15                	beqz	a0,80004ade <create+0xc6>
  ilock(ip);
    80004aa4:	ef4fe0ef          	jal	80003198 <ilock>
  ip->major = major;
    80004aa8:	05591323          	sh	s5,70(s2)
  ip->minor = minor;
    80004aac:	05691423          	sh	s6,72(s2)
  ip->nlink = 1;
    80004ab0:	4785                	li	a5,1
    80004ab2:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004ab6:	854a                	mv	a0,s2
    80004ab8:	e2cfe0ef          	jal	800030e4 <iupdate>
  if (type == T_DIR) { // Create . and .. entries.
    80004abc:	4705                	li	a4,1
    80004abe:	02ea0463          	beq	s4,a4,80004ae6 <create+0xce>
  if (dirlink(dp, name, ip->inum) < 0)
    80004ac2:	00492603          	lw	a2,4(s2)
    80004ac6:	fb040593          	addi	a1,s0,-80
    80004aca:	8526                	mv	a0,s1
    80004acc:	e61fe0ef          	jal	8000392c <dirlink>
    80004ad0:	06054263          	bltz	a0,80004b34 <create+0x11c>
  iunlockput(dp);
    80004ad4:	8526                	mv	a0,s1
    80004ad6:	8cffe0ef          	jal	800033a4 <iunlockput>
    return 0;
    80004ada:	89ca                	mv	s3,s2
    80004adc:	bf71                	j	80004a78 <create+0x60>
    iunlockput(dp);
    80004ade:	8526                	mv	a0,s1
    80004ae0:	8c5fe0ef          	jal	800033a4 <iunlockput>
    return 0;
    80004ae4:	bfdd                	j	80004ada <create+0xc2>
    if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004ae6:	00492603          	lw	a2,4(s2)
    80004aea:	00003597          	auipc	a1,0x3
    80004aee:	ad658593          	addi	a1,a1,-1322 # 800075c0 <etext+0x5c0>
    80004af2:	854a                	mv	a0,s2
    80004af4:	e39fe0ef          	jal	8000392c <dirlink>
    80004af8:	02054e63          	bltz	a0,80004b34 <create+0x11c>
    80004afc:	40d0                	lw	a2,4(s1)
    80004afe:	00003597          	auipc	a1,0x3
    80004b02:	aca58593          	addi	a1,a1,-1334 # 800075c8 <etext+0x5c8>
    80004b06:	854a                	mv	a0,s2
    80004b08:	e25fe0ef          	jal	8000392c <dirlink>
    80004b0c:	02054463          	bltz	a0,80004b34 <create+0x11c>
  if (dirlink(dp, name, ip->inum) < 0)
    80004b10:	00492603          	lw	a2,4(s2)
    80004b14:	fb040593          	addi	a1,s0,-80
    80004b18:	8526                	mv	a0,s1
    80004b1a:	e13fe0ef          	jal	8000392c <dirlink>
    80004b1e:	00054b63          	bltz	a0,80004b34 <create+0x11c>
    dp->nlink++; // for ".."
    80004b22:	04a4d783          	lhu	a5,74(s1)
    80004b26:	2785                	addiw	a5,a5,1
    80004b28:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004b2c:	8526                	mv	a0,s1
    80004b2e:	db6fe0ef          	jal	800030e4 <iupdate>
    80004b32:	b74d                	j	80004ad4 <create+0xbc>
  ip->nlink = 0;
    80004b34:	04091523          	sh	zero,74(s2)
  iupdate(ip);
    80004b38:	854a                	mv	a0,s2
    80004b3a:	daafe0ef          	jal	800030e4 <iupdate>
  iunlockput(ip);
    80004b3e:	854a                	mv	a0,s2
    80004b40:	865fe0ef          	jal	800033a4 <iunlockput>
  iunlockput(dp);
    80004b44:	8526                	mv	a0,s1
    80004b46:	85ffe0ef          	jal	800033a4 <iunlockput>
  return 0;
    80004b4a:	b73d                	j	80004a78 <create+0x60>

0000000080004b4c <sys_dup>:
{
    80004b4c:	7179                	addi	sp,sp,-48
    80004b4e:	f406                	sd	ra,40(sp)
    80004b50:	f022                	sd	s0,32(sp)
    80004b52:	1800                	addi	s0,sp,48
  if (argfd(0, 0, &f) < 0)
    80004b54:	fd840613          	addi	a2,s0,-40
    80004b58:	4581                	li	a1,0
    80004b5a:	4501                	li	a0,0
    80004b5c:	e2bff0ef          	jal	80004986 <argfd>
    80004b60:	02054863          	bltz	a0,80004b90 <sys_dup+0x44>
    80004b64:	ec26                	sd	s1,24(sp)
    80004b66:	e84a                	sd	s2,16(sp)
  if ((fd = fdalloc(f)) < 0)
    80004b68:	fd843483          	ld	s1,-40(s0)
    80004b6c:	8526                	mv	a0,s1
    80004b6e:	e6dff0ef          	jal	800049da <fdalloc>
    80004b72:	892a                	mv	s2,a0
    80004b74:	00054c63          	bltz	a0,80004b8c <sys_dup+0x40>
  filedup(f);
    80004b78:	8526                	mv	a0,s1
    80004b7a:	c72ff0ef          	jal	80003fec <filedup>
  return fd;
    80004b7e:	854a                	mv	a0,s2
    80004b80:	64e2                	ld	s1,24(sp)
    80004b82:	6942                	ld	s2,16(sp)
}
    80004b84:	70a2                	ld	ra,40(sp)
    80004b86:	7402                	ld	s0,32(sp)
    80004b88:	6145                	addi	sp,sp,48
    80004b8a:	8082                	ret
    80004b8c:	64e2                	ld	s1,24(sp)
    80004b8e:	6942                	ld	s2,16(sp)
    return -1;
    80004b90:	557d                	li	a0,-1
    80004b92:	bfcd                	j	80004b84 <sys_dup+0x38>

0000000080004b94 <sys_read>:
{
    80004b94:	7179                	addi	sp,sp,-48
    80004b96:	f406                	sd	ra,40(sp)
    80004b98:	f022                	sd	s0,32(sp)
    80004b9a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004b9c:	fd840593          	addi	a1,s0,-40
    80004ba0:	4505                	li	a0,1
    80004ba2:	c3bfd0ef          	jal	800027dc <argaddr>
  argint(2, &n);
    80004ba6:	fe440593          	addi	a1,s0,-28
    80004baa:	4509                	li	a0,2
    80004bac:	c15fd0ef          	jal	800027c0 <argint>
  if (argfd(0, 0, &f) < 0)
    80004bb0:	fe840613          	addi	a2,s0,-24
    80004bb4:	4581                	li	a1,0
    80004bb6:	4501                	li	a0,0
    80004bb8:	dcfff0ef          	jal	80004986 <argfd>
    80004bbc:	87aa                	mv	a5,a0
    return -1;
    80004bbe:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004bc0:	0007ca63          	bltz	a5,80004bd4 <sys_read+0x40>
  return fileread(f, p, n);
    80004bc4:	fe442603          	lw	a2,-28(s0)
    80004bc8:	fd843583          	ld	a1,-40(s0)
    80004bcc:	fe843503          	ld	a0,-24(s0)
    80004bd0:	d86ff0ef          	jal	80004156 <fileread>
}
    80004bd4:	70a2                	ld	ra,40(sp)
    80004bd6:	7402                	ld	s0,32(sp)
    80004bd8:	6145                	addi	sp,sp,48
    80004bda:	8082                	ret

0000000080004bdc <sys_write>:
{
    80004bdc:	7179                	addi	sp,sp,-48
    80004bde:	f406                	sd	ra,40(sp)
    80004be0:	f022                	sd	s0,32(sp)
    80004be2:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004be4:	fd840593          	addi	a1,s0,-40
    80004be8:	4505                	li	a0,1
    80004bea:	bf3fd0ef          	jal	800027dc <argaddr>
  argint(2, &n);
    80004bee:	fe440593          	addi	a1,s0,-28
    80004bf2:	4509                	li	a0,2
    80004bf4:	bcdfd0ef          	jal	800027c0 <argint>
  if (argfd(0, 0, &f) < 0)
    80004bf8:	fe840613          	addi	a2,s0,-24
    80004bfc:	4581                	li	a1,0
    80004bfe:	4501                	li	a0,0
    80004c00:	d87ff0ef          	jal	80004986 <argfd>
    80004c04:	87aa                	mv	a5,a0
    return -1;
    80004c06:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004c08:	0007ca63          	bltz	a5,80004c1c <sys_write+0x40>
  return filewrite(f, p, n);
    80004c0c:	fe442603          	lw	a2,-28(s0)
    80004c10:	fd843583          	ld	a1,-40(s0)
    80004c14:	fe843503          	ld	a0,-24(s0)
    80004c18:	df8ff0ef          	jal	80004210 <filewrite>
}
    80004c1c:	70a2                	ld	ra,40(sp)
    80004c1e:	7402                	ld	s0,32(sp)
    80004c20:	6145                	addi	sp,sp,48
    80004c22:	8082                	ret

0000000080004c24 <sys_close>:
{
    80004c24:	1101                	addi	sp,sp,-32
    80004c26:	ec06                	sd	ra,24(sp)
    80004c28:	e822                	sd	s0,16(sp)
    80004c2a:	1000                	addi	s0,sp,32
  if (argfd(0, &fd, &f) < 0)
    80004c2c:	fe040613          	addi	a2,s0,-32
    80004c30:	fec40593          	addi	a1,s0,-20
    80004c34:	4501                	li	a0,0
    80004c36:	d51ff0ef          	jal	80004986 <argfd>
    return -1;
    80004c3a:	57fd                	li	a5,-1
  if (argfd(0, &fd, &f) < 0)
    80004c3c:	02054063          	bltz	a0,80004c5c <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004c40:	c9ffc0ef          	jal	800018de <myproc>
    80004c44:	fec42783          	lw	a5,-20(s0)
    80004c48:	07e9                	addi	a5,a5,26
    80004c4a:	078e                	slli	a5,a5,0x3
    80004c4c:	953e                	add	a0,a0,a5
    80004c4e:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004c52:	fe043503          	ld	a0,-32(s0)
    80004c56:	bdcff0ef          	jal	80004032 <fileclose>
  return 0;
    80004c5a:	4781                	li	a5,0
}
    80004c5c:	853e                	mv	a0,a5
    80004c5e:	60e2                	ld	ra,24(sp)
    80004c60:	6442                	ld	s0,16(sp)
    80004c62:	6105                	addi	sp,sp,32
    80004c64:	8082                	ret

0000000080004c66 <sys_fstat>:
{
    80004c66:	1101                	addi	sp,sp,-32
    80004c68:	ec06                	sd	ra,24(sp)
    80004c6a:	e822                	sd	s0,16(sp)
    80004c6c:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004c6e:	fe040593          	addi	a1,s0,-32
    80004c72:	4505                	li	a0,1
    80004c74:	b69fd0ef          	jal	800027dc <argaddr>
  if (argfd(0, 0, &f) < 0)
    80004c78:	fe840613          	addi	a2,s0,-24
    80004c7c:	4581                	li	a1,0
    80004c7e:	4501                	li	a0,0
    80004c80:	d07ff0ef          	jal	80004986 <argfd>
    80004c84:	87aa                	mv	a5,a0
    return -1;
    80004c86:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004c88:	0007c863          	bltz	a5,80004c98 <sys_fstat+0x32>
  return filestat(f, st);
    80004c8c:	fe043583          	ld	a1,-32(s0)
    80004c90:	fe843503          	ld	a0,-24(s0)
    80004c94:	c60ff0ef          	jal	800040f4 <filestat>
}
    80004c98:	60e2                	ld	ra,24(sp)
    80004c9a:	6442                	ld	s0,16(sp)
    80004c9c:	6105                	addi	sp,sp,32
    80004c9e:	8082                	ret

0000000080004ca0 <sys_link>:
{
    80004ca0:	7169                	addi	sp,sp,-304
    80004ca2:	f606                	sd	ra,296(sp)
    80004ca4:	f222                	sd	s0,288(sp)
    80004ca6:	1a00                	addi	s0,sp,304
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004ca8:	08000613          	li	a2,128
    80004cac:	ed040593          	addi	a1,s0,-304
    80004cb0:	4501                	li	a0,0
    80004cb2:	b47fd0ef          	jal	800027f8 <argstr>
    80004cb6:	0c054a63          	bltz	a0,80004d8a <sys_link+0xea>
    80004cba:	08000613          	li	a2,128
    80004cbe:	f5040593          	addi	a1,s0,-176
    80004cc2:	4505                	li	a0,1
    80004cc4:	b35fd0ef          	jal	800027f8 <argstr>
    80004cc8:	0c054163          	bltz	a0,80004d8a <sys_link+0xea>
    80004ccc:	ee26                	sd	s1,280(sp)
  begin_op();
    80004cce:	ee7fe0ef          	jal	80003bb4 <begin_op>
  if ((ip = namei(old)) == 0) {
    80004cd2:	ed040513          	addi	a0,s0,-304
    80004cd6:	d01fe0ef          	jal	800039d6 <namei>
    80004cda:	84aa                	mv	s1,a0
    80004cdc:	c53d                	beqz	a0,80004d4a <sys_link+0xaa>
  ilock(ip);
    80004cde:	cbafe0ef          	jal	80003198 <ilock>
  if (ip->type == T_DIR) {
    80004ce2:	04449703          	lh	a4,68(s1)
    80004ce6:	4785                	li	a5,1
    80004ce8:	06f70563          	beq	a4,a5,80004d52 <sys_link+0xb2>
    80004cec:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004cee:	04a4d783          	lhu	a5,74(s1)
    80004cf2:	2785                	addiw	a5,a5,1
    80004cf4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004cf8:	8526                	mv	a0,s1
    80004cfa:	beafe0ef          	jal	800030e4 <iupdate>
  iunlock(ip);
    80004cfe:	8526                	mv	a0,s1
    80004d00:	d46fe0ef          	jal	80003246 <iunlock>
  if ((dp = nameiparent(new, name)) == 0)
    80004d04:	fd040593          	addi	a1,s0,-48
    80004d08:	f5040513          	addi	a0,s0,-176
    80004d0c:	ce5fe0ef          	jal	800039f0 <nameiparent>
    80004d10:	892a                	mv	s2,a0
    80004d12:	c931                	beqz	a0,80004d66 <sys_link+0xc6>
  ilock(dp);
    80004d14:	c84fe0ef          	jal	80003198 <ilock>
  if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0) {
    80004d18:	854a                	mv	a0,s2
    80004d1a:	00092703          	lw	a4,0(s2)
    80004d1e:	409c                	lw	a5,0(s1)
    80004d20:	04f71063          	bne	a4,a5,80004d60 <sys_link+0xc0>
    80004d24:	40d0                	lw	a2,4(s1)
    80004d26:	fd040593          	addi	a1,s0,-48
    80004d2a:	c03fe0ef          	jal	8000392c <dirlink>
    80004d2e:	02054963          	bltz	a0,80004d60 <sys_link+0xc0>
  iunlockput(dp);
    80004d32:	854a                	mv	a0,s2
    80004d34:	e70fe0ef          	jal	800033a4 <iunlockput>
  iput(ip);
    80004d38:	8526                	mv	a0,s1
    80004d3a:	de0fe0ef          	jal	8000331a <iput>
  end_op();
    80004d3e:	ee7fe0ef          	jal	80003c24 <end_op>
  return 0;
    80004d42:	4501                	li	a0,0
    80004d44:	64f2                	ld	s1,280(sp)
    80004d46:	6952                	ld	s2,272(sp)
    80004d48:	a091                	j	80004d8c <sys_link+0xec>
    end_op();
    80004d4a:	edbfe0ef          	jal	80003c24 <end_op>
    return -1;
    80004d4e:	64f2                	ld	s1,280(sp)
    80004d50:	a82d                	j	80004d8a <sys_link+0xea>
    iunlockput(ip);
    80004d52:	8526                	mv	a0,s1
    80004d54:	e50fe0ef          	jal	800033a4 <iunlockput>
    end_op();
    80004d58:	ecdfe0ef          	jal	80003c24 <end_op>
    return -1;
    80004d5c:	64f2                	ld	s1,280(sp)
    80004d5e:	a035                	j	80004d8a <sys_link+0xea>
    iunlockput(dp);
    80004d60:	854a                	mv	a0,s2
    80004d62:	e42fe0ef          	jal	800033a4 <iunlockput>
  ilock(ip);
    80004d66:	8526                	mv	a0,s1
    80004d68:	c30fe0ef          	jal	80003198 <ilock>
  ip->nlink--;
    80004d6c:	04a4d783          	lhu	a5,74(s1)
    80004d70:	37fd                	addiw	a5,a5,-1
    80004d72:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004d76:	8526                	mv	a0,s1
    80004d78:	b6cfe0ef          	jal	800030e4 <iupdate>
  iunlockput(ip);
    80004d7c:	8526                	mv	a0,s1
    80004d7e:	e26fe0ef          	jal	800033a4 <iunlockput>
  end_op();
    80004d82:	ea3fe0ef          	jal	80003c24 <end_op>
  return -1;
    80004d86:	64f2                	ld	s1,280(sp)
    80004d88:	6952                	ld	s2,272(sp)
    return -1;
    80004d8a:	557d                	li	a0,-1
}
    80004d8c:	70b2                	ld	ra,296(sp)
    80004d8e:	7412                	ld	s0,288(sp)
    80004d90:	6155                	addi	sp,sp,304
    80004d92:	8082                	ret

0000000080004d94 <sys_unlink>:
{
    80004d94:	7151                	addi	sp,sp,-240
    80004d96:	f586                	sd	ra,232(sp)
    80004d98:	f1a2                	sd	s0,224(sp)
    80004d9a:	1980                	addi	s0,sp,240
  if (argstr(0, path, MAXPATH) < 0)
    80004d9c:	08000613          	li	a2,128
    80004da0:	f3040593          	addi	a1,s0,-208
    80004da4:	4501                	li	a0,0
    80004da6:	a53fd0ef          	jal	800027f8 <argstr>
    80004daa:	14054763          	bltz	a0,80004ef8 <sys_unlink+0x164>
    80004dae:	eda6                	sd	s1,216(sp)
  begin_op();
    80004db0:	e05fe0ef          	jal	80003bb4 <begin_op>
  if ((dp = nameiparent(path, name)) == 0) {
    80004db4:	fb040593          	addi	a1,s0,-80
    80004db8:	f3040513          	addi	a0,s0,-208
    80004dbc:	c35fe0ef          	jal	800039f0 <nameiparent>
    80004dc0:	84aa                	mv	s1,a0
    80004dc2:	c955                	beqz	a0,80004e76 <sys_unlink+0xe2>
  ilock(dp);
    80004dc4:	bd4fe0ef          	jal	80003198 <ilock>
  if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004dc8:	00002597          	auipc	a1,0x2
    80004dcc:	7f858593          	addi	a1,a1,2040 # 800075c0 <etext+0x5c0>
    80004dd0:	fb040513          	addi	a0,s0,-80
    80004dd4:	951fe0ef          	jal	80003724 <namecmp>
    80004dd8:	10050a63          	beqz	a0,80004eec <sys_unlink+0x158>
    80004ddc:	00002597          	auipc	a1,0x2
    80004de0:	7ec58593          	addi	a1,a1,2028 # 800075c8 <etext+0x5c8>
    80004de4:	fb040513          	addi	a0,s0,-80
    80004de8:	93dfe0ef          	jal	80003724 <namecmp>
    80004dec:	10050063          	beqz	a0,80004eec <sys_unlink+0x158>
    80004df0:	e9ca                	sd	s2,208(sp)
  if ((ip = dirlookup(dp, name, &off)) == 0)
    80004df2:	f2c40613          	addi	a2,s0,-212
    80004df6:	fb040593          	addi	a1,s0,-80
    80004dfa:	8526                	mv	a0,s1
    80004dfc:	93ffe0ef          	jal	8000373a <dirlookup>
    80004e00:	892a                	mv	s2,a0
    80004e02:	0e050463          	beqz	a0,80004eea <sys_unlink+0x156>
    80004e06:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    80004e08:	b90fe0ef          	jal	80003198 <ilock>
  if (ip->nlink < 1)
    80004e0c:	04a91783          	lh	a5,74(s2)
    80004e10:	06f05763          	blez	a5,80004e7e <sys_unlink+0xea>
  if (ip->type == T_DIR && !isdirempty(ip)) {
    80004e14:	04491703          	lh	a4,68(s2)
    80004e18:	4785                	li	a5,1
    80004e1a:	06f70863          	beq	a4,a5,80004e8a <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80004e1e:	fc040993          	addi	s3,s0,-64
    80004e22:	4641                	li	a2,16
    80004e24:	4581                	li	a1,0
    80004e26:	854e                	mv	a0,s3
    80004e28:	eadfb0ef          	jal	80000cd4 <memset>
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004e2c:	4741                	li	a4,16
    80004e2e:	f2c42683          	lw	a3,-212(s0)
    80004e32:	864e                	mv	a2,s3
    80004e34:	4581                	li	a1,0
    80004e36:	8526                	mv	a0,s1
    80004e38:	fe4fe0ef          	jal	8000361c <writei>
    80004e3c:	47c1                	li	a5,16
    80004e3e:	08f51763          	bne	a0,a5,80004ecc <sys_unlink+0x138>
  if (ip->type == T_DIR) {
    80004e42:	04491703          	lh	a4,68(s2)
    80004e46:	4785                	li	a5,1
    80004e48:	08f70863          	beq	a4,a5,80004ed8 <sys_unlink+0x144>
  iunlockput(dp);
    80004e4c:	8526                	mv	a0,s1
    80004e4e:	d56fe0ef          	jal	800033a4 <iunlockput>
  ip->nlink--;
    80004e52:	04a95783          	lhu	a5,74(s2)
    80004e56:	37fd                	addiw	a5,a5,-1
    80004e58:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004e5c:	854a                	mv	a0,s2
    80004e5e:	a86fe0ef          	jal	800030e4 <iupdate>
  iunlockput(ip);
    80004e62:	854a                	mv	a0,s2
    80004e64:	d40fe0ef          	jal	800033a4 <iunlockput>
  end_op();
    80004e68:	dbdfe0ef          	jal	80003c24 <end_op>
  return 0;
    80004e6c:	4501                	li	a0,0
    80004e6e:	64ee                	ld	s1,216(sp)
    80004e70:	694e                	ld	s2,208(sp)
    80004e72:	69ae                	ld	s3,200(sp)
    80004e74:	a059                	j	80004efa <sys_unlink+0x166>
    end_op();
    80004e76:	daffe0ef          	jal	80003c24 <end_op>
    return -1;
    80004e7a:	64ee                	ld	s1,216(sp)
    80004e7c:	a8b5                	j	80004ef8 <sys_unlink+0x164>
    panic("unlink: nlink < 1");
    80004e7e:	00002517          	auipc	a0,0x2
    80004e82:	75250513          	addi	a0,a0,1874 # 800075d0 <etext+0x5d0>
    80004e86:	9b5fb0ef          	jal	8000083a <panic>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    80004e8a:	04c92703          	lw	a4,76(s2)
    80004e8e:	02000793          	li	a5,32
    80004e92:	f8e7f6e3          	bgeu	a5,a4,80004e1e <sys_unlink+0x8a>
    80004e96:	89be                	mv	s3,a5
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004e98:	4741                	li	a4,16
    80004e9a:	86ce                	mv	a3,s3
    80004e9c:	f1840613          	addi	a2,s0,-232
    80004ea0:	4581                	li	a1,0
    80004ea2:	854a                	mv	a0,s2
    80004ea4:	e86fe0ef          	jal	8000352a <readi>
    80004ea8:	47c1                	li	a5,16
    80004eaa:	00f51b63          	bne	a0,a5,80004ec0 <sys_unlink+0x12c>
    if (de.inum != 0)
    80004eae:	f1845783          	lhu	a5,-232(s0)
    80004eb2:	eba1                	bnez	a5,80004f02 <sys_unlink+0x16e>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    80004eb4:	29c1                	addiw	s3,s3,16
    80004eb6:	04c92783          	lw	a5,76(s2)
    80004eba:	fcf9efe3          	bltu	s3,a5,80004e98 <sys_unlink+0x104>
    80004ebe:	b785                	j	80004e1e <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80004ec0:	00002517          	auipc	a0,0x2
    80004ec4:	72850513          	addi	a0,a0,1832 # 800075e8 <etext+0x5e8>
    80004ec8:	973fb0ef          	jal	8000083a <panic>
    panic("unlink: writei");
    80004ecc:	00002517          	auipc	a0,0x2
    80004ed0:	73450513          	addi	a0,a0,1844 # 80007600 <etext+0x600>
    80004ed4:	967fb0ef          	jal	8000083a <panic>
    dp->nlink--;
    80004ed8:	04a4d783          	lhu	a5,74(s1)
    80004edc:	37fd                	addiw	a5,a5,-1
    80004ede:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004ee2:	8526                	mv	a0,s1
    80004ee4:	a00fe0ef          	jal	800030e4 <iupdate>
    80004ee8:	b795                	j	80004e4c <sys_unlink+0xb8>
    80004eea:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80004eec:	8526                	mv	a0,s1
    80004eee:	cb6fe0ef          	jal	800033a4 <iunlockput>
  end_op();
    80004ef2:	d33fe0ef          	jal	80003c24 <end_op>
  return -1;
    80004ef6:	64ee                	ld	s1,216(sp)
    return -1;
    80004ef8:	557d                	li	a0,-1
}
    80004efa:	70ae                	ld	ra,232(sp)
    80004efc:	740e                	ld	s0,224(sp)
    80004efe:	616d                	addi	sp,sp,240
    80004f00:	8082                	ret
    iunlockput(ip);
    80004f02:	854a                	mv	a0,s2
    80004f04:	ca0fe0ef          	jal	800033a4 <iunlockput>
    goto bad;
    80004f08:	694e                	ld	s2,208(sp)
    80004f0a:	69ae                	ld	s3,200(sp)
    80004f0c:	b7c5                	j	80004eec <sys_unlink+0x158>

0000000080004f0e <sys_open>:

uint64
sys_open(void)
{
    80004f0e:	7131                	addi	sp,sp,-192
    80004f10:	fd06                	sd	ra,184(sp)
    80004f12:	f922                	sd	s0,176(sp)
    80004f14:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80004f16:	f4c40593          	addi	a1,s0,-180
    80004f1a:	4505                	li	a0,1
    80004f1c:	8a5fd0ef          	jal	800027c0 <argint>
  if ((n = argstr(0, path, MAXPATH)) < 0)
    80004f20:	08000613          	li	a2,128
    80004f24:	f5040593          	addi	a1,s0,-176
    80004f28:	4501                	li	a0,0
    80004f2a:	8cffd0ef          	jal	800027f8 <argstr>
    80004f2e:	10054563          	bltz	a0,80005038 <sys_open+0x12a>
    80004f32:	f526                	sd	s1,168(sp)
    return -1;

  begin_op();
    80004f34:	c81fe0ef          	jal	80003bb4 <begin_op>

  if (omode & O_CREATE) {
    80004f38:	f4c42783          	lw	a5,-180(s0)
    80004f3c:	2007f793          	andi	a5,a5,512
    80004f40:	cfd9                	beqz	a5,80004fde <sys_open+0xd0>
    ip = create(path, T_FILE, 0, 0);
    80004f42:	4681                	li	a3,0
    80004f44:	4601                	li	a2,0
    80004f46:	4589                	li	a1,2
    80004f48:	f5040513          	addi	a0,s0,-176
    80004f4c:	acdff0ef          	jal	80004a18 <create>
    80004f50:	84aa                	mv	s1,a0
    if (ip == 0) {
    80004f52:	c151                	beqz	a0,80004fd6 <sys_open+0xc8>
      end_op();
      return -1;
    }
  }

  if (ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)) {
    80004f54:	04449703          	lh	a4,68(s1)
    80004f58:	478d                	li	a5,3
    80004f5a:	00f71763          	bne	a4,a5,80004f68 <sys_open+0x5a>
    80004f5e:	0464d703          	lhu	a4,70(s1)
    80004f62:	47a5                	li	a5,9
    80004f64:	0ae7e863          	bltu	a5,a4,80005014 <sys_open+0x106>
    80004f68:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0) {
    80004f6a:	824ff0ef          	jal	80003f8e <filealloc>
    80004f6e:	892a                	mv	s2,a0
    80004f70:	cd4d                	beqz	a0,8000502a <sys_open+0x11c>
    80004f72:	ed4e                	sd	s3,152(sp)
    80004f74:	a67ff0ef          	jal	800049da <fdalloc>
    80004f78:	89aa                	mv	s3,a0
    80004f7a:	0a054463          	bltz	a0,80005022 <sys_open+0x114>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if (ip->type == T_DEVICE) {
    80004f7e:	04449703          	lh	a4,68(s1)
    80004f82:	478d                	li	a5,3
    80004f84:	0af70f63          	beq	a4,a5,80005042 <sys_open+0x134>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004f88:	4789                	li	a5,2
    80004f8a:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80004f8e:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80004f92:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80004f96:	f4c42783          	lw	a5,-180(s0)
    80004f9a:	0017f713          	andi	a4,a5,1
    80004f9e:	00174713          	xori	a4,a4,1
    80004fa2:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004fa6:	0037f713          	andi	a4,a5,3
    80004faa:	00e03733          	snez	a4,a4
    80004fae:	00e904a3          	sb	a4,9(s2)

  if ((omode & O_TRUNC) && ip->type == T_FILE) {
    80004fb2:	4007f793          	andi	a5,a5,1024
    80004fb6:	c791                	beqz	a5,80004fc2 <sys_open+0xb4>
    80004fb8:	04449703          	lh	a4,68(s1)
    80004fbc:	4789                	li	a5,2
    80004fbe:	08f70963          	beq	a4,a5,80005050 <sys_open+0x142>
    itrunc(ip);
  }

  iunlock(ip);
    80004fc2:	8526                	mv	a0,s1
    80004fc4:	a82fe0ef          	jal	80003246 <iunlock>
  end_op();
    80004fc8:	c5dfe0ef          	jal	80003c24 <end_op>

  return fd;
    80004fcc:	854e                	mv	a0,s3
    80004fce:	74aa                	ld	s1,168(sp)
    80004fd0:	790a                	ld	s2,160(sp)
    80004fd2:	69ea                	ld	s3,152(sp)
    80004fd4:	a09d                	j	8000503a <sys_open+0x12c>
      end_op();
    80004fd6:	c4ffe0ef          	jal	80003c24 <end_op>
      return -1;
    80004fda:	74aa                	ld	s1,168(sp)
    80004fdc:	a8b1                	j	80005038 <sys_open+0x12a>
    if ((ip = namei(path)) == 0) {
    80004fde:	f5040513          	addi	a0,s0,-176
    80004fe2:	9f5fe0ef          	jal	800039d6 <namei>
    80004fe6:	84aa                	mv	s1,a0
    80004fe8:	c115                	beqz	a0,8000500c <sys_open+0xfe>
    ilock(ip);
    80004fea:	9aefe0ef          	jal	80003198 <ilock>
    if (ip->type == T_DIR && omode != O_RDONLY) {
    80004fee:	04449703          	lh	a4,68(s1)
    80004ff2:	4785                	li	a5,1
    80004ff4:	f6f710e3          	bne	a4,a5,80004f54 <sys_open+0x46>
    80004ff8:	f4c42783          	lw	a5,-180(s0)
    80004ffc:	d7b5                	beqz	a5,80004f68 <sys_open+0x5a>
      iunlockput(ip);
    80004ffe:	8526                	mv	a0,s1
    80005000:	ba4fe0ef          	jal	800033a4 <iunlockput>
      end_op();
    80005004:	c21fe0ef          	jal	80003c24 <end_op>
      return -1;
    80005008:	74aa                	ld	s1,168(sp)
    8000500a:	a03d                	j	80005038 <sys_open+0x12a>
      end_op();
    8000500c:	c19fe0ef          	jal	80003c24 <end_op>
      return -1;
    80005010:	74aa                	ld	s1,168(sp)
    80005012:	a01d                	j	80005038 <sys_open+0x12a>
    iunlockput(ip);
    80005014:	8526                	mv	a0,s1
    80005016:	b8efe0ef          	jal	800033a4 <iunlockput>
    end_op();
    8000501a:	c0bfe0ef          	jal	80003c24 <end_op>
    return -1;
    8000501e:	74aa                	ld	s1,168(sp)
    80005020:	a821                	j	80005038 <sys_open+0x12a>
      fileclose(f);
    80005022:	854a                	mv	a0,s2
    80005024:	80eff0ef          	jal	80004032 <fileclose>
    80005028:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    8000502a:	8526                	mv	a0,s1
    8000502c:	b78fe0ef          	jal	800033a4 <iunlockput>
    end_op();
    80005030:	bf5fe0ef          	jal	80003c24 <end_op>
    return -1;
    80005034:	74aa                	ld	s1,168(sp)
    80005036:	790a                	ld	s2,160(sp)
    return -1;
    80005038:	557d                	li	a0,-1
}
    8000503a:	70ea                	ld	ra,184(sp)
    8000503c:	744a                	ld	s0,176(sp)
    8000503e:	6129                	addi	sp,sp,192
    80005040:	8082                	ret
    f->type = FD_DEVICE;
    80005042:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    80005046:	04649783          	lh	a5,70(s1)
    8000504a:	02f91223          	sh	a5,36(s2)
    8000504e:	b791                	j	80004f92 <sys_open+0x84>
    itrunc(ip);
    80005050:	8526                	mv	a0,s1
    80005052:	a34fe0ef          	jal	80003286 <itrunc>
    80005056:	b7b5                	j	80004fc2 <sys_open+0xb4>

0000000080005058 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005058:	7175                	addi	sp,sp,-144
    8000505a:	e506                	sd	ra,136(sp)
    8000505c:	e122                	sd	s0,128(sp)
    8000505e:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005060:	b55fe0ef          	jal	80003bb4 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0) {
    80005064:	08000613          	li	a2,128
    80005068:	f7040593          	addi	a1,s0,-144
    8000506c:	4501                	li	a0,0
    8000506e:	f8afd0ef          	jal	800027f8 <argstr>
    80005072:	02054363          	bltz	a0,80005098 <sys_mkdir+0x40>
    80005076:	4681                	li	a3,0
    80005078:	4601                	li	a2,0
    8000507a:	4585                	li	a1,1
    8000507c:	f7040513          	addi	a0,s0,-144
    80005080:	999ff0ef          	jal	80004a18 <create>
    80005084:	c911                	beqz	a0,80005098 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005086:	b1efe0ef          	jal	800033a4 <iunlockput>
  end_op();
    8000508a:	b9bfe0ef          	jal	80003c24 <end_op>
  return 0;
    8000508e:	4501                	li	a0,0
}
    80005090:	60aa                	ld	ra,136(sp)
    80005092:	640a                	ld	s0,128(sp)
    80005094:	6149                	addi	sp,sp,144
    80005096:	8082                	ret
    end_op();
    80005098:	b8dfe0ef          	jal	80003c24 <end_op>
    return -1;
    8000509c:	557d                	li	a0,-1
    8000509e:	bfcd                	j	80005090 <sys_mkdir+0x38>

00000000800050a0 <sys_mknod>:

uint64
sys_mknod(void)
{
    800050a0:	7135                	addi	sp,sp,-160
    800050a2:	ed06                	sd	ra,152(sp)
    800050a4:	e922                	sd	s0,144(sp)
    800050a6:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800050a8:	b0dfe0ef          	jal	80003bb4 <begin_op>
  argint(1, &major);
    800050ac:	f6c40593          	addi	a1,s0,-148
    800050b0:	4505                	li	a0,1
    800050b2:	f0efd0ef          	jal	800027c0 <argint>
  argint(2, &minor);
    800050b6:	f6840593          	addi	a1,s0,-152
    800050ba:	4509                	li	a0,2
    800050bc:	f04fd0ef          	jal	800027c0 <argint>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    800050c0:	08000613          	li	a2,128
    800050c4:	f7040593          	addi	a1,s0,-144
    800050c8:	4501                	li	a0,0
    800050ca:	f2efd0ef          	jal	800027f8 <argstr>
    800050ce:	02054563          	bltz	a0,800050f8 <sys_mknod+0x58>
      (ip = create(path, T_DEVICE, major, minor)) == 0) {
    800050d2:	f6841683          	lh	a3,-152(s0)
    800050d6:	f6c41603          	lh	a2,-148(s0)
    800050da:	458d                	li	a1,3
    800050dc:	f7040513          	addi	a0,s0,-144
    800050e0:	939ff0ef          	jal	80004a18 <create>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    800050e4:	c911                	beqz	a0,800050f8 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800050e6:	abefe0ef          	jal	800033a4 <iunlockput>
  end_op();
    800050ea:	b3bfe0ef          	jal	80003c24 <end_op>
  return 0;
    800050ee:	4501                	li	a0,0
}
    800050f0:	60ea                	ld	ra,152(sp)
    800050f2:	644a                	ld	s0,144(sp)
    800050f4:	610d                	addi	sp,sp,160
    800050f6:	8082                	ret
    end_op();
    800050f8:	b2dfe0ef          	jal	80003c24 <end_op>
    return -1;
    800050fc:	557d                	li	a0,-1
    800050fe:	bfcd                	j	800050f0 <sys_mknod+0x50>

0000000080005100 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005100:	7135                	addi	sp,sp,-160
    80005102:	ed06                	sd	ra,152(sp)
    80005104:	e922                	sd	s0,144(sp)
    80005106:	e14a                	sd	s2,128(sp)
    80005108:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000510a:	fd4fc0ef          	jal	800018de <myproc>
    8000510e:	892a                	mv	s2,a0

  begin_op();
    80005110:	aa5fe0ef          	jal	80003bb4 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0) {
    80005114:	08000613          	li	a2,128
    80005118:	f6040593          	addi	a1,s0,-160
    8000511c:	4501                	li	a0,0
    8000511e:	edafd0ef          	jal	800027f8 <argstr>
    80005122:	02054f63          	bltz	a0,80005160 <sys_chdir+0x60>
    80005126:	e526                	sd	s1,136(sp)
    80005128:	f6040513          	addi	a0,s0,-160
    8000512c:	8abfe0ef          	jal	800039d6 <namei>
    80005130:	84aa                	mv	s1,a0
    80005132:	c515                	beqz	a0,8000515e <sys_chdir+0x5e>
    end_op();
    return -1;
  }
  ilock(ip);
    80005134:	864fe0ef          	jal	80003198 <ilock>
  if (ip->type != T_DIR) {
    80005138:	04449703          	lh	a4,68(s1)
    8000513c:	4785                	li	a5,1
    8000513e:	02f71963          	bne	a4,a5,80005170 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005142:	8526                	mv	a0,s1
    80005144:	902fe0ef          	jal	80003246 <iunlock>
  iput(p->cwd);
    80005148:	15093503          	ld	a0,336(s2)
    8000514c:	9cefe0ef          	jal	8000331a <iput>
  end_op();
    80005150:	ad5fe0ef          	jal	80003c24 <end_op>
  p->cwd = ip;
    80005154:	14993823          	sd	s1,336(s2)
  return 0;
    80005158:	4501                	li	a0,0
    8000515a:	64aa                	ld	s1,136(sp)
    8000515c:	a029                	j	80005166 <sys_chdir+0x66>
    8000515e:	64aa                	ld	s1,136(sp)
    end_op();
    80005160:	ac5fe0ef          	jal	80003c24 <end_op>
    return -1;
    80005164:	557d                	li	a0,-1
}
    80005166:	60ea                	ld	ra,152(sp)
    80005168:	644a                	ld	s0,144(sp)
    8000516a:	690a                	ld	s2,128(sp)
    8000516c:	610d                	addi	sp,sp,160
    8000516e:	8082                	ret
    iunlockput(ip);
    80005170:	8526                	mv	a0,s1
    80005172:	a32fe0ef          	jal	800033a4 <iunlockput>
    end_op();
    80005176:	aaffe0ef          	jal	80003c24 <end_op>
    return -1;
    8000517a:	64aa                	ld	s1,136(sp)
    8000517c:	b7e5                	j	80005164 <sys_chdir+0x64>

000000008000517e <sys_exec>:

uint64
sys_exec(void)
{
    8000517e:	7105                	addi	sp,sp,-480
    80005180:	ef86                	sd	ra,472(sp)
    80005182:	eba2                	sd	s0,464(sp)
    80005184:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005186:	e2840593          	addi	a1,s0,-472
    8000518a:	4505                	li	a0,1
    8000518c:	e50fd0ef          	jal	800027dc <argaddr>
  if (argstr(0, path, MAXPATH) < 0) {
    80005190:	08000613          	li	a2,128
    80005194:	f3040593          	addi	a1,s0,-208
    80005198:	4501                	li	a0,0
    8000519a:	e5efd0ef          	jal	800027f8 <argstr>
    8000519e:	0c054e63          	bltz	a0,8000527a <sys_exec+0xfc>
    800051a2:	e7a6                	sd	s1,456(sp)
    800051a4:	e3ca                	sd	s2,448(sp)
    800051a6:	ff4e                	sd	s3,440(sp)
    800051a8:	fb52                	sd	s4,432(sp)
    800051aa:	f756                	sd	s5,424(sp)
    800051ac:	f35a                	sd	s6,416(sp)
    800051ae:	ef5e                	sd	s7,408(sp)
    return -1;
  }
  memset(argv, 0, sizeof(argv));
    800051b0:	e3040a13          	addi	s4,s0,-464
    800051b4:	10000613          	li	a2,256
    800051b8:	4581                	li	a1,0
    800051ba:	8552                	mv	a0,s4
    800051bc:	b19fb0ef          	jal	80000cd4 <memset>
  for (i = 0;; i++) {
    if (i >= NELEM(argv)) {
    800051c0:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    800051c2:	89d2                	mv	s3,s4
    800051c4:	4901                	li	s2,0
      goto bad;
    }
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    800051c6:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if (argv[i] == 0)
      goto bad;
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    800051ca:	6b05                	lui	s6,0x1
    if (i >= NELEM(argv)) {
    800051cc:	02000b93          	li	s7,32
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    800051d0:	00391513          	slli	a0,s2,0x3
    800051d4:	85d6                	mv	a1,s5
    800051d6:	e2843783          	ld	a5,-472(s0)
    800051da:	953e                	add	a0,a0,a5
    800051dc:	d5efd0ef          	jal	8000273a <fetchaddr>
    800051e0:	02054663          	bltz	a0,8000520c <sys_exec+0x8e>
    if (uarg == 0) {
    800051e4:	e2043783          	ld	a5,-480(s0)
    800051e8:	c3b9                	beqz	a5,8000522e <sys_exec+0xb0>
    argv[i] = kalloc();
    800051ea:	955fb0ef          	jal	80000b3e <kalloc>
    800051ee:	85aa                	mv	a1,a0
    800051f0:	00a9b023          	sd	a0,0(s3)
    if (argv[i] == 0)
    800051f4:	cd01                	beqz	a0,8000520c <sys_exec+0x8e>
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    800051f6:	865a                	mv	a2,s6
    800051f8:	e2043503          	ld	a0,-480(s0)
    800051fc:	d84fd0ef          	jal	80002780 <fetchstr>
    80005200:	00054663          	bltz	a0,8000520c <sys_exec+0x8e>
    if (i >= NELEM(argv)) {
    80005204:	0905                	addi	s2,s2,1
    80005206:	09a1                	addi	s3,s3,8
    80005208:	fd7914e3          	bne	s2,s7,800051d0 <sys_exec+0x52>
    kfree(argv[i]);

  return ret;

bad:
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000520c:	100a0a13          	addi	s4,s4,256
    80005210:	6088                	ld	a0,0(s1)
    80005212:	cd29                	beqz	a0,8000526c <sys_exec+0xee>
    kfree(argv[i]);
    80005214:	843fb0ef          	jal	80000a56 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005218:	04a1                	addi	s1,s1,8
    8000521a:	ff449be3          	bne	s1,s4,80005210 <sys_exec+0x92>
    8000521e:	64be                	ld	s1,456(sp)
    80005220:	691e                	ld	s2,448(sp)
    80005222:	79fa                	ld	s3,440(sp)
    80005224:	7a5a                	ld	s4,432(sp)
    80005226:	7aba                	ld	s5,424(sp)
    80005228:	7b1a                	ld	s6,416(sp)
    8000522a:	6bfa                	ld	s7,408(sp)
    8000522c:	a0b9                	j	8000527a <sys_exec+0xfc>
      argv[i] = 0;
    8000522e:	0009079b          	sext.w	a5,s2
    80005232:	e3040593          	addi	a1,s0,-464
    80005236:	078e                	slli	a5,a5,0x3
    80005238:	97ae                	add	a5,a5,a1
    8000523a:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    8000523e:	f3040513          	addi	a0,s0,-208
    80005242:	c30ff0ef          	jal	80004672 <kexec>
    80005246:	892a                	mv	s2,a0
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005248:	100a0a13          	addi	s4,s4,256
    8000524c:	6088                	ld	a0,0(s1)
    8000524e:	c511                	beqz	a0,8000525a <sys_exec+0xdc>
    kfree(argv[i]);
    80005250:	807fb0ef          	jal	80000a56 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005254:	04a1                	addi	s1,s1,8
    80005256:	ff449be3          	bne	s1,s4,8000524c <sys_exec+0xce>
  return ret;
    8000525a:	854a                	mv	a0,s2
    8000525c:	64be                	ld	s1,456(sp)
    8000525e:	691e                	ld	s2,448(sp)
    80005260:	79fa                	ld	s3,440(sp)
    80005262:	7a5a                	ld	s4,432(sp)
    80005264:	7aba                	ld	s5,424(sp)
    80005266:	7b1a                	ld	s6,416(sp)
    80005268:	6bfa                	ld	s7,408(sp)
    8000526a:	a809                	j	8000527c <sys_exec+0xfe>
    8000526c:	64be                	ld	s1,456(sp)
    8000526e:	691e                	ld	s2,448(sp)
    80005270:	79fa                	ld	s3,440(sp)
    80005272:	7a5a                	ld	s4,432(sp)
    80005274:	7aba                	ld	s5,424(sp)
    80005276:	7b1a                	ld	s6,416(sp)
    80005278:	6bfa                	ld	s7,408(sp)
    return -1;
    8000527a:	557d                	li	a0,-1
  return -1;
}
    8000527c:	60fe                	ld	ra,472(sp)
    8000527e:	645e                	ld	s0,464(sp)
    80005280:	613d                	addi	sp,sp,480
    80005282:	8082                	ret

0000000080005284 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005284:	7139                	addi	sp,sp,-64
    80005286:	fc06                	sd	ra,56(sp)
    80005288:	f822                	sd	s0,48(sp)
    8000528a:	f426                	sd	s1,40(sp)
    8000528c:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000528e:	e50fc0ef          	jal	800018de <myproc>
    80005292:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005294:	fd840593          	addi	a1,s0,-40
    80005298:	4501                	li	a0,0
    8000529a:	d42fd0ef          	jal	800027dc <argaddr>
  if (pipealloc(&rf, &wf) < 0)
    8000529e:	fc840593          	addi	a1,s0,-56
    800052a2:	fd040513          	addi	a0,s0,-48
    800052a6:	89aff0ef          	jal	80004340 <pipealloc>
    800052aa:	0a054463          	bltz	a0,80005352 <sys_pipe+0xce>
    return -1;
  fd0 = -1;
    800052ae:	57fd                	li	a5,-1
    800052b0:	fcf42223          	sw	a5,-60(s0)
  if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0) {
    800052b4:	fd043503          	ld	a0,-48(s0)
    800052b8:	f22ff0ef          	jal	800049da <fdalloc>
    800052bc:	fca42223          	sw	a0,-60(s0)
    800052c0:	08054163          	bltz	a0,80005342 <sys_pipe+0xbe>
    800052c4:	fc843503          	ld	a0,-56(s0)
    800052c8:	f12ff0ef          	jal	800049da <fdalloc>
    800052cc:	fca42023          	sw	a0,-64(s0)
    800052d0:	06054063          	bltz	a0,80005330 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if (copyout(p->pagetable, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    800052d4:	4691                	li	a3,4
    800052d6:	fc440613          	addi	a2,s0,-60
    800052da:	fd843583          	ld	a1,-40(s0)
    800052de:	68a8                	ld	a0,80(s1)
    800052e0:	b30fc0ef          	jal	80001610 <copyout>
    800052e4:	00054f63          	bltz	a0,80005302 <sys_pipe+0x7e>
      copyout(p->pagetable, fdarray + sizeof(fd0), (char *)&fd1, sizeof(fd1)) <
    800052e8:	4691                	li	a3,4
    800052ea:	fc040613          	addi	a2,s0,-64
    800052ee:	fd843583          	ld	a1,-40(s0)
    800052f2:	95b6                	add	a1,a1,a3
    800052f4:	68a8                	ld	a0,80(s1)
    800052f6:	b1afc0ef          	jal	80001610 <copyout>
    800052fa:	87aa                	mv	a5,a0
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800052fc:	4501                	li	a0,0
  if (copyout(p->pagetable, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    800052fe:	0407db63          	bgez	a5,80005354 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80005302:	fc442783          	lw	a5,-60(s0)
    80005306:	07e9                	addi	a5,a5,26
    80005308:	078e                	slli	a5,a5,0x3
    8000530a:	97a6                	add	a5,a5,s1
    8000530c:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005310:	fc042783          	lw	a5,-64(s0)
    80005314:	07e9                	addi	a5,a5,26
    80005316:	078e                	slli	a5,a5,0x3
    80005318:	97a6                	add	a5,a5,s1
    8000531a:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000531e:	fd043503          	ld	a0,-48(s0)
    80005322:	d11fe0ef          	jal	80004032 <fileclose>
    fileclose(wf);
    80005326:	fc843503          	ld	a0,-56(s0)
    8000532a:	d09fe0ef          	jal	80004032 <fileclose>
    return -1;
    8000532e:	a015                	j	80005352 <sys_pipe+0xce>
    if (fd0 >= 0)
    80005330:	fc442783          	lw	a5,-60(s0)
    80005334:	0007c763          	bltz	a5,80005342 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80005338:	07e9                	addi	a5,a5,26
    8000533a:	078e                	slli	a5,a5,0x3
    8000533c:	97a6                	add	a5,a5,s1
    8000533e:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005342:	fd043503          	ld	a0,-48(s0)
    80005346:	cedfe0ef          	jal	80004032 <fileclose>
    fileclose(wf);
    8000534a:	fc843503          	ld	a0,-56(s0)
    8000534e:	ce5fe0ef          	jal	80004032 <fileclose>
    return -1;
    80005352:	557d                	li	a0,-1
}
    80005354:	70e2                	ld	ra,56(sp)
    80005356:	7442                	ld	s0,48(sp)
    80005358:	74a2                	ld	s1,40(sp)
    8000535a:	6121                	addi	sp,sp,64
    8000535c:	8082                	ret
	...

0000000080005360 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005360:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005362:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005364:	e80e                	sd	gp,16(sp)
        # sd tp, 24(sp)
        sd t0, 32(sp)
    80005366:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    80005368:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000536a:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000536c:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    8000536e:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005370:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005372:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005374:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005376:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    80005378:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000537a:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000537c:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    8000537e:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005380:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005382:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005384:	ac4fd0ef          	jal	80002648 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    80005388:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000538a:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000538c:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    8000538e:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005390:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005392:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005394:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005396:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    80005398:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000539a:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000539c:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    8000539e:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    800053a0:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    800053a2:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    800053a4:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    800053a6:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    800053a8:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    800053aa:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    800053ac:	10200073          	sret
    800053b0:	0001                	nop
    800053b2:	00000013          	nop
    800053b6:	00000013          	nop
    800053ba:	00000013          	nop

00000000800053be <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800053be:	1141                	addi	sp,sp,-16
    800053c0:	e406                	sd	ra,8(sp)
    800053c2:	e022                	sd	s0,0(sp)
    800053c4:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32 *)(PLIC + UART0_IRQ * 4) = 1;
    800053c6:	0c000737          	lui	a4,0xc000
    800053ca:	4785                	li	a5,1
    800053cc:	d71c                	sw	a5,40(a4)
  *(uint32 *)(PLIC + VIRTIO0_IRQ * 4) = 1;
    800053ce:	c35c                	sw	a5,4(a4)
}
    800053d0:	60a2                	ld	ra,8(sp)
    800053d2:	6402                	ld	s0,0(sp)
    800053d4:	0141                	addi	sp,sp,16
    800053d6:	8082                	ret

00000000800053d8 <plicinithart>:

void
plicinithart(void)
{
    800053d8:	1141                	addi	sp,sp,-16
    800053da:	e406                	sd	ra,8(sp)
    800053dc:	e022                	sd	s0,0(sp)
    800053de:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800053e0:	ccafc0ef          	jal	800018aa <cpuid>

  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32 *)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800053e4:	0085171b          	slliw	a4,a0,0x8
    800053e8:	0c0027b7          	lui	a5,0xc002
    800053ec:	97ba                	add	a5,a5,a4
    800053ee:	40200713          	li	a4,1026
    800053f2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32 *)PLIC_SPRIORITY(hart) = 0;
    800053f6:	00d5151b          	slliw	a0,a0,0xd
    800053fa:	0c2017b7          	lui	a5,0xc201
    800053fe:	97aa                	add	a5,a5,a0
    80005400:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005404:	60a2                	ld	ra,8(sp)
    80005406:	6402                	ld	s0,0(sp)
    80005408:	0141                	addi	sp,sp,16
    8000540a:	8082                	ret

000000008000540c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000540c:	1141                	addi	sp,sp,-16
    8000540e:	e406                	sd	ra,8(sp)
    80005410:	e022                	sd	s0,0(sp)
    80005412:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005414:	c96fc0ef          	jal	800018aa <cpuid>
  int irq = *(uint32 *)PLIC_SCLAIM(hart);
    80005418:	00d5151b          	slliw	a0,a0,0xd
    8000541c:	0c2017b7          	lui	a5,0xc201
    80005420:	97aa                	add	a5,a5,a0
  return irq;
}
    80005422:	43c8                	lw	a0,4(a5)
    80005424:	60a2                	ld	ra,8(sp)
    80005426:	6402                	ld	s0,0(sp)
    80005428:	0141                	addi	sp,sp,16
    8000542a:	8082                	ret

000000008000542c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000542c:	1101                	addi	sp,sp,-32
    8000542e:	ec06                	sd	ra,24(sp)
    80005430:	e822                	sd	s0,16(sp)
    80005432:	e426                	sd	s1,8(sp)
    80005434:	1000                	addi	s0,sp,32
    80005436:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005438:	c72fc0ef          	jal	800018aa <cpuid>
  *(uint32 *)PLIC_SCLAIM(hart) = irq;
    8000543c:	00d5179b          	slliw	a5,a0,0xd
    80005440:	0c201737          	lui	a4,0xc201
    80005444:	97ba                	add	a5,a5,a4
    80005446:	c3c4                	sw	s1,4(a5)
}
    80005448:	60e2                	ld	ra,24(sp)
    8000544a:	6442                	ld	s0,16(sp)
    8000544c:	64a2                	ld	s1,8(sp)
    8000544e:	6105                	addi	sp,sp,32
    80005450:	8082                	ret

0000000080005452 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005452:	1141                	addi	sp,sp,-16
    80005454:	e406                	sd	ra,8(sp)
    80005456:	e022                	sd	s0,0(sp)
    80005458:	0800                	addi	s0,sp,16
  if (i >= NUM)
    8000545a:	479d                	li	a5,7
    8000545c:	04a7ca63          	blt	a5,a0,800054b0 <free_desc+0x5e>
    panic("free_desc 1");
  if (disk.free[i])
    80005460:	0001b797          	auipc	a5,0x1b
    80005464:	5d878793          	addi	a5,a5,1496 # 80020a38 <disk>
    80005468:	97aa                	add	a5,a5,a0
    8000546a:	0187c783          	lbu	a5,24(a5)
    8000546e:	e7b9                	bnez	a5,800054bc <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005470:	00451693          	slli	a3,a0,0x4
    80005474:	0001b797          	auipc	a5,0x1b
    80005478:	5c478793          	addi	a5,a5,1476 # 80020a38 <disk>
    8000547c:	6398                	ld	a4,0(a5)
    8000547e:	9736                	add	a4,a4,a3
    80005480:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    80005484:	6398                	ld	a4,0(a5)
    80005486:	9736                	add	a4,a4,a3
    80005488:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000548c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005490:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005494:	97aa                	add	a5,a5,a0
    80005496:	4705                	li	a4,1
    80005498:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000549c:	0001b517          	auipc	a0,0x1b
    800054a0:	5b450513          	addi	a0,a0,1460 # 80020a50 <disk+0x18>
    800054a4:	a79fc0ef          	jal	80001f1c <wakeup>
}
    800054a8:	60a2                	ld	ra,8(sp)
    800054aa:	6402                	ld	s0,0(sp)
    800054ac:	0141                	addi	sp,sp,16
    800054ae:	8082                	ret
    panic("free_desc 1");
    800054b0:	00002517          	auipc	a0,0x2
    800054b4:	16050513          	addi	a0,a0,352 # 80007610 <etext+0x610>
    800054b8:	b82fb0ef          	jal	8000083a <panic>
    panic("free_desc 2");
    800054bc:	00002517          	auipc	a0,0x2
    800054c0:	16450513          	addi	a0,a0,356 # 80007620 <etext+0x620>
    800054c4:	b76fb0ef          	jal	8000083a <panic>

00000000800054c8 <virtio_disk_init>:
{
    800054c8:	1101                	addi	sp,sp,-32
    800054ca:	ec06                	sd	ra,24(sp)
    800054cc:	e822                	sd	s0,16(sp)
    800054ce:	e426                	sd	s1,8(sp)
    800054d0:	e04a                	sd	s2,0(sp)
    800054d2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800054d4:	00002597          	auipc	a1,0x2
    800054d8:	15c58593          	addi	a1,a1,348 # 80007630 <etext+0x630>
    800054dc:	0001b517          	auipc	a0,0x1b
    800054e0:	68450513          	addi	a0,a0,1668 # 80020b60 <disk+0x128>
    800054e4:	eb4fb0ef          	jal	80000b98 <initlock>
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800054e8:	100017b7          	lui	a5,0x10001
    800054ec:	4398                	lw	a4,0(a5)
    800054ee:	747277b7          	lui	a5,0x74727
    800054f2:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800054f6:	14f71263          	bne	a4,a5,8000563a <virtio_disk_init+0x172>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800054fa:	100017b7          	lui	a5,0x10001
    800054fe:	43d8                	lw	a4,4(a5)
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005500:	4789                	li	a5,2
    80005502:	12f71c63          	bne	a4,a5,8000563a <virtio_disk_init+0x172>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005506:	100017b7          	lui	a5,0x10001
    8000550a:	4798                	lw	a4,8(a5)
    8000550c:	4789                	li	a5,2
    8000550e:	12f71663          	bne	a4,a5,8000563a <virtio_disk_init+0x172>
      *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551) {
    80005512:	100017b7          	lui	a5,0x10001
    80005516:	47d8                	lw	a4,12(a5)
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005518:	554d47b7          	lui	a5,0x554d4
    8000551c:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005520:	10f71d63          	bne	a4,a5,8000563a <virtio_disk_init+0x172>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005524:	100017b7          	lui	a5,0x10001
    80005528:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000552c:	4705                	li	a4,1
    8000552e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005530:	470d                	li	a4,3
    80005532:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005534:	10001737          	lui	a4,0x10001
    80005538:	4b18                	lw	a4,16(a4)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000553a:	c7ffe6b7          	lui	a3,0xc7ffe
    8000553e:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fddbe7>
    80005542:	8f75                	and	a4,a4,a3
    80005544:	100016b7          	lui	a3,0x10001
    80005548:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000554a:	472d                	li	a4,11
    8000554c:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    8000554e:	0707a903          	lw	s2,112(a5)
  if (!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005552:	00897793          	andi	a5,s2,8
    80005556:	0e078863          	beqz	a5,80005646 <virtio_disk_init+0x17e>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000555a:	100017b7          	lui	a5,0x10001
    8000555e:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if (*R(VIRTIO_MMIO_QUEUE_READY))
    80005562:	43fc                	lw	a5,68(a5)
    80005564:	0e079763          	bnez	a5,80005652 <virtio_disk_init+0x18a>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005568:	100017b7          	lui	a5,0x10001
    8000556c:	5bdc                	lw	a5,52(a5)
  if (max == 0)
    8000556e:	0e078863          	beqz	a5,8000565e <virtio_disk_init+0x196>
  if (max < NUM)
    80005572:	471d                	li	a4,7
    80005574:	0ef77b63          	bgeu	a4,a5,8000566a <virtio_disk_init+0x1a2>
  disk.desc = kalloc();
    80005578:	dc6fb0ef          	jal	80000b3e <kalloc>
    8000557c:	0001b497          	auipc	s1,0x1b
    80005580:	4bc48493          	addi	s1,s1,1212 # 80020a38 <disk>
    80005584:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005586:	db8fb0ef          	jal	80000b3e <kalloc>
    8000558a:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000558c:	db2fb0ef          	jal	80000b3e <kalloc>
    80005590:	87aa                	mv	a5,a0
    80005592:	e888                	sd	a0,16(s1)
  if (!disk.desc || !disk.avail || !disk.used)
    80005594:	6088                	ld	a0,0(s1)
    80005596:	0e050063          	beqz	a0,80005676 <virtio_disk_init+0x1ae>
    8000559a:	0001b717          	auipc	a4,0x1b
    8000559e:	4a673703          	ld	a4,1190(a4) # 80020a40 <disk+0x8>
    800055a2:	00173713          	seqz	a4,a4
    800055a6:	0017b793          	seqz	a5,a5
    800055aa:	8fd9                	or	a5,a5,a4
    800055ac:	e7e9                	bnez	a5,80005676 <virtio_disk_init+0x1ae>
  memset(disk.desc, 0, PGSIZE);
    800055ae:	6605                	lui	a2,0x1
    800055b0:	4581                	li	a1,0
    800055b2:	f22fb0ef          	jal	80000cd4 <memset>
  memset(disk.avail, 0, PGSIZE);
    800055b6:	0001b497          	auipc	s1,0x1b
    800055ba:	48248493          	addi	s1,s1,1154 # 80020a38 <disk>
    800055be:	6605                	lui	a2,0x1
    800055c0:	4581                	li	a1,0
    800055c2:	6488                	ld	a0,8(s1)
    800055c4:	f10fb0ef          	jal	80000cd4 <memset>
  memset(disk.used, 0, PGSIZE);
    800055c8:	6605                	lui	a2,0x1
    800055ca:	4581                	li	a1,0
    800055cc:	6888                	ld	a0,16(s1)
    800055ce:	f06fb0ef          	jal	80000cd4 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800055d2:	100017b7          	lui	a5,0x10001
    800055d6:	4721                	li	a4,8
    800055d8:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800055da:	4098                	lw	a4,0(s1)
    800055dc:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800055e0:	40d8                	lw	a4,4(s1)
    800055e2:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800055e6:	649c                	ld	a5,8(s1)
    800055e8:	10001737          	lui	a4,0x10001
    800055ec:	08f72823          	sw	a5,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800055f0:	9781                	srai	a5,a5,0x20
    800055f2:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800055f6:	689c                	ld	a5,16(s1)
    800055f8:	0af72023          	sw	a5,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800055fc:	9781                	srai	a5,a5,0x20
    800055fe:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005602:	4785                	li	a5,1
    80005604:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005606:	00f48c23          	sb	a5,24(s1)
    8000560a:	00f48ca3          	sb	a5,25(s1)
    8000560e:	00f48d23          	sb	a5,26(s1)
    80005612:	00f48da3          	sb	a5,27(s1)
    80005616:	00f48e23          	sb	a5,28(s1)
    8000561a:	00f48ea3          	sb	a5,29(s1)
    8000561e:	00f48f23          	sb	a5,30(s1)
    80005622:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005626:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    8000562a:	07272823          	sw	s2,112(a4)
}
    8000562e:	60e2                	ld	ra,24(sp)
    80005630:	6442                	ld	s0,16(sp)
    80005632:	64a2                	ld	s1,8(sp)
    80005634:	6902                	ld	s2,0(sp)
    80005636:	6105                	addi	sp,sp,32
    80005638:	8082                	ret
    panic("could not find virtio disk");
    8000563a:	00002517          	auipc	a0,0x2
    8000563e:	00650513          	addi	a0,a0,6 # 80007640 <etext+0x640>
    80005642:	9f8fb0ef          	jal	8000083a <panic>
    panic("virtio disk FEATURES_OK unset");
    80005646:	00002517          	auipc	a0,0x2
    8000564a:	01a50513          	addi	a0,a0,26 # 80007660 <etext+0x660>
    8000564e:	9ecfb0ef          	jal	8000083a <panic>
    panic("virtio disk should not be ready");
    80005652:	00002517          	auipc	a0,0x2
    80005656:	02e50513          	addi	a0,a0,46 # 80007680 <etext+0x680>
    8000565a:	9e0fb0ef          	jal	8000083a <panic>
    panic("virtio disk has no queue 0");
    8000565e:	00002517          	auipc	a0,0x2
    80005662:	04250513          	addi	a0,a0,66 # 800076a0 <etext+0x6a0>
    80005666:	9d4fb0ef          	jal	8000083a <panic>
    panic("virtio disk max queue too short");
    8000566a:	00002517          	auipc	a0,0x2
    8000566e:	05650513          	addi	a0,a0,86 # 800076c0 <etext+0x6c0>
    80005672:	9c8fb0ef          	jal	8000083a <panic>
    panic("virtio disk kalloc");
    80005676:	00002517          	auipc	a0,0x2
    8000567a:	06a50513          	addi	a0,a0,106 # 800076e0 <etext+0x6e0>
    8000567e:	9bcfb0ef          	jal	8000083a <panic>

0000000080005682 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005682:	711d                	addi	sp,sp,-96
    80005684:	ec86                	sd	ra,88(sp)
    80005686:	e8a2                	sd	s0,80(sp)
    80005688:	e4a6                	sd	s1,72(sp)
    8000568a:	e0ca                	sd	s2,64(sp)
    8000568c:	fc4e                	sd	s3,56(sp)
    8000568e:	f852                	sd	s4,48(sp)
    80005690:	f456                	sd	s5,40(sp)
    80005692:	f05a                	sd	s6,32(sp)
    80005694:	ec5e                	sd	s7,24(sp)
    80005696:	e862                	sd	s8,16(sp)
    80005698:	1080                	addi	s0,sp,96
    8000569a:	89aa                	mv	s3,a0
    8000569c:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000569e:	00c52b83          	lw	s7,12(a0)
    800056a2:	001b9b9b          	slliw	s7,s7,0x1
    800056a6:	1b82                	slli	s7,s7,0x20
    800056a8:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    800056ac:	0001b517          	auipc	a0,0x1b
    800056b0:	4b450513          	addi	a0,a0,1204 # 80020b60 <disk+0x128>
    800056b4:	d64fb0ef          	jal	80000c18 <acquire>
  for (int i = 0; i < NUM; i++) {
    800056b8:	44a1                	li	s1,8
      disk.free[i] = 0;
    800056ba:	0001ba97          	auipc	s5,0x1b
    800056be:	37ea8a93          	addi	s5,s5,894 # 80020a38 <disk>
  for (int i = 0; i < 3; i++) {
    800056c2:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    800056c4:	5c7d                	li	s8,-1
    800056c6:	a095                	j	8000572a <virtio_disk_rw+0xa8>
      disk.free[i] = 0;
    800056c8:	00fa8733          	add	a4,s5,a5
    800056cc:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800056d0:	c19c                	sw	a5,0(a1)
    if (idx[i] < 0) {
    800056d2:	0207c563          	bltz	a5,800056fc <virtio_disk_rw+0x7a>
  for (int i = 0; i < 3; i++) {
    800056d6:	2905                	addiw	s2,s2,1
    800056d8:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800056da:	05490c63          	beq	s2,s4,80005732 <virtio_disk_rw+0xb0>
    idx[i] = alloc_desc();
    800056de:	85b2                	mv	a1,a2
  for (int i = 0; i < NUM; i++) {
    800056e0:	0001b717          	auipc	a4,0x1b
    800056e4:	35870713          	addi	a4,a4,856 # 80020a38 <disk>
    800056e8:	4781                	li	a5,0
    if (disk.free[i]) {
    800056ea:	01874683          	lbu	a3,24(a4)
    800056ee:	fee9                	bnez	a3,800056c8 <virtio_disk_rw+0x46>
  for (int i = 0; i < NUM; i++) {
    800056f0:	2785                	addiw	a5,a5,1
    800056f2:	0705                	addi	a4,a4,1
    800056f4:	fe979be3          	bne	a5,s1,800056ea <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    800056f8:	0185a023          	sw	s8,0(a1)
      for (int j = 0; j < i; j++)
    800056fc:	01205d63          	blez	s2,80005716 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005700:	fa042503          	lw	a0,-96(s0)
    80005704:	d4fff0ef          	jal	80005452 <free_desc>
      for (int j = 0; j < i; j++)
    80005708:	4785                	li	a5,1
    8000570a:	0127d663          	bge	a5,s2,80005716 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    8000570e:	fa442503          	lw	a0,-92(s0)
    80005712:	d41ff0ef          	jal	80005452 <free_desc>
  int idx[3];
  while (1) {
    if (alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005716:	0001b597          	auipc	a1,0x1b
    8000571a:	44a58593          	addi	a1,a1,1098 # 80020b60 <disk+0x128>
    8000571e:	0001b517          	auipc	a0,0x1b
    80005722:	33250513          	addi	a0,a0,818 # 80020a50 <disk+0x18>
    80005726:	faafc0ef          	jal	80001ed0 <sleep>
  for (int i = 0; i < 3; i++) {
    8000572a:	fa040613          	addi	a2,s0,-96
    8000572e:	4901                	li	s2,0
    80005730:	b77d                	j	800056de <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005732:	fa042503          	lw	a0,-96(s0)
    80005736:	00451693          	slli	a3,a0,0x4

  if (write)
    8000573a:	0001b797          	auipc	a5,0x1b
    8000573e:	2fe78793          	addi	a5,a5,766 # 80020a38 <disk>
    80005742:	00451713          	slli	a4,a0,0x4
    80005746:	0a070713          	addi	a4,a4,160
    8000574a:	973e                	add	a4,a4,a5
    8000574c:	01603633          	snez	a2,s6
    80005750:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005752:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005756:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64)buf0;
    8000575a:	6398                	ld	a4,0(a5)
    8000575c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000575e:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80005762:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64)buf0;
    80005764:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005766:	6390                	ld	a2,0(a5)
    80005768:	00d605b3          	add	a1,a2,a3
    8000576c:	4741                	li	a4,16
    8000576e:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005770:	4805                	li	a6,1
    80005772:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80005776:	fa442703          	lw	a4,-92(s0)
    8000577a:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64)b->data;
    8000577e:	0712                	slli	a4,a4,0x4
    80005780:	963a                	add	a2,a2,a4
    80005782:	05898593          	addi	a1,s3,88
    80005786:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005788:	0007b883          	ld	a7,0(a5)
    8000578c:	9746                	add	a4,a4,a7
    8000578e:	40000613          	li	a2,1024
    80005792:	c710                	sw	a2,8(a4)
  if (write)
    80005794:	001b3613          	seqz	a2,s6
    80005798:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000579c:	01066633          	or	a2,a2,a6
    800057a0:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800057a4:	fa842583          	lw	a1,-88(s0)
    800057a8:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800057ac:	00250613          	addi	a2,a0,2
    800057b0:	0612                	slli	a2,a2,0x4
    800057b2:	963e                	add	a2,a2,a5
    800057b4:	577d                	li	a4,-1
    800057b6:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64)&disk.info[idx[0]].status;
    800057ba:	0592                	slli	a1,a1,0x4
    800057bc:	98ae                	add	a7,a7,a1
    800057be:	03068713          	addi	a4,a3,48
    800057c2:	973e                	add	a4,a4,a5
    800057c4:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    800057c8:	6398                	ld	a4,0(a5)
    800057ca:	972e                	add	a4,a4,a1
    800057cc:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800057d0:	4689                	li	a3,2
    800057d2:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    800057d6:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800057da:	0109a223          	sw	a6,4(s3)
  disk.info[idx[0]].b = b;
    800057de:	01363423          	sd	s3,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800057e2:	6794                	ld	a3,8(a5)
    800057e4:	0026d703          	lhu	a4,2(a3)
    800057e8:	8b1d                	andi	a4,a4,7
    800057ea:	0706                	slli	a4,a4,0x1
    800057ec:	96ba                	add	a3,a3,a4
    800057ee:	00a69223          	sh	a0,4(a3)

// fence for memory-mapped IO
static inline void
io_fence()
{
  asm volatile("fence iorw, iorw" ::: "memory");
    800057f2:	0ff0000f          	fence

  io_fence();

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800057f6:	6798                	ld	a4,8(a5)
    800057f8:	00275783          	lhu	a5,2(a4)
    800057fc:	2785                	addiw	a5,a5,1
    800057fe:	00f71123          	sh	a5,2(a4)
    80005802:	0ff0000f          	fence

  io_fence();

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005806:	100017b7          	lui	a5,0x10001
    8000580a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while (b->disk == 1) {
    8000580e:	0049a783          	lw	a5,4(s3)
    80005812:	01079f63          	bne	a5,a6,80005830 <virtio_disk_rw+0x1ae>
    sleep(b, &disk.vdisk_lock);
    80005816:	0001b917          	auipc	s2,0x1b
    8000581a:	34a90913          	addi	s2,s2,842 # 80020b60 <disk+0x128>
  while (b->disk == 1) {
    8000581e:	84be                	mv	s1,a5
    sleep(b, &disk.vdisk_lock);
    80005820:	85ca                	mv	a1,s2
    80005822:	854e                	mv	a0,s3
    80005824:	eacfc0ef          	jal	80001ed0 <sleep>
  while (b->disk == 1) {
    80005828:	0049a783          	lw	a5,4(s3)
    8000582c:	fe978ae3          	beq	a5,s1,80005820 <virtio_disk_rw+0x19e>
  }

  disk.info[idx[0]].b = 0;
    80005830:	fa042903          	lw	s2,-96(s0)
    80005834:	00290713          	addi	a4,s2,2
    80005838:	0712                	slli	a4,a4,0x4
    8000583a:	0001b797          	auipc	a5,0x1b
    8000583e:	1fe78793          	addi	a5,a5,510 # 80020a38 <disk>
    80005842:	97ba                	add	a5,a5,a4
    80005844:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005848:	0001b997          	auipc	s3,0x1b
    8000584c:	1f098993          	addi	s3,s3,496 # 80020a38 <disk>
    80005850:	00491713          	slli	a4,s2,0x4
    80005854:	0009b783          	ld	a5,0(s3)
    80005858:	97ba                	add	a5,a5,a4
    8000585a:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000585e:	854a                	mv	a0,s2
    80005860:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005864:	befff0ef          	jal	80005452 <free_desc>
    if (flag & VRING_DESC_F_NEXT)
    80005868:	8885                	andi	s1,s1,1
    8000586a:	f0fd                	bnez	s1,80005850 <virtio_disk_rw+0x1ce>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000586c:	0001b517          	auipc	a0,0x1b
    80005870:	2f450513          	addi	a0,a0,756 # 80020b60 <disk+0x128>
    80005874:	c28fb0ef          	jal	80000c9c <release>
}
    80005878:	60e6                	ld	ra,88(sp)
    8000587a:	6446                	ld	s0,80(sp)
    8000587c:	64a6                	ld	s1,72(sp)
    8000587e:	6906                	ld	s2,64(sp)
    80005880:	79e2                	ld	s3,56(sp)
    80005882:	7a42                	ld	s4,48(sp)
    80005884:	7aa2                	ld	s5,40(sp)
    80005886:	7b02                	ld	s6,32(sp)
    80005888:	6be2                	ld	s7,24(sp)
    8000588a:	6c42                	ld	s8,16(sp)
    8000588c:	6125                	addi	sp,sp,96
    8000588e:	8082                	ret

0000000080005890 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005890:	1101                	addi	sp,sp,-32
    80005892:	ec06                	sd	ra,24(sp)
    80005894:	e822                	sd	s0,16(sp)
    80005896:	e426                	sd	s1,8(sp)
    80005898:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000589a:	0001b497          	auipc	s1,0x1b
    8000589e:	19e48493          	addi	s1,s1,414 # 80020a38 <disk>
    800058a2:	0001b517          	auipc	a0,0x1b
    800058a6:	2be50513          	addi	a0,a0,702 # 80020b60 <disk+0x128>
    800058aa:	b6efb0ef          	jal	80000c18 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800058ae:	100017b7          	lui	a5,0x10001
    800058b2:	53bc                	lw	a5,96(a5)
    800058b4:	8b8d                	andi	a5,a5,3
    800058b6:	10001737          	lui	a4,0x10001
    800058ba:	d37c                	sw	a5,100(a4)
    800058bc:	0ff0000f          	fence
  io_fence();

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while (disk.used_idx != disk.used->idx) {
    800058c0:	689c                	ld	a5,16(s1)
    800058c2:	0204d703          	lhu	a4,32(s1)
    800058c6:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    800058ca:	04f70663          	beq	a4,a5,80005916 <virtio_disk_intr+0x86>
    800058ce:	0ff0000f          	fence
    io_fence();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800058d2:	6898                	ld	a4,16(s1)
    800058d4:	0204d783          	lhu	a5,32(s1)
    800058d8:	8b9d                	andi	a5,a5,7
    800058da:	078e                	slli	a5,a5,0x3
    800058dc:	97ba                	add	a5,a5,a4
    800058de:	43dc                	lw	a5,4(a5)

    if (disk.info[id].status != 0)
    800058e0:	00278713          	addi	a4,a5,2
    800058e4:	0712                	slli	a4,a4,0x4
    800058e6:	9726                	add	a4,a4,s1
    800058e8:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    800058ec:	e321                	bnez	a4,8000592c <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800058ee:	0789                	addi	a5,a5,2
    800058f0:	0792                	slli	a5,a5,0x4
    800058f2:	97a6                	add	a5,a5,s1
    800058f4:	6788                	ld	a0,8(a5)
    b->disk = 0; // disk is done with buf
    800058f6:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800058fa:	e22fc0ef          	jal	80001f1c <wakeup>

    disk.used_idx += 1;
    800058fe:	0204d783          	lhu	a5,32(s1)
    80005902:	2785                	addiw	a5,a5,1
    80005904:	17c2                	slli	a5,a5,0x30
    80005906:	93c1                	srli	a5,a5,0x30
    80005908:	02f49023          	sh	a5,32(s1)
  while (disk.used_idx != disk.used->idx) {
    8000590c:	6898                	ld	a4,16(s1)
    8000590e:	00275703          	lhu	a4,2(a4)
    80005912:	faf71ee3          	bne	a4,a5,800058ce <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005916:	0001b517          	auipc	a0,0x1b
    8000591a:	24a50513          	addi	a0,a0,586 # 80020b60 <disk+0x128>
    8000591e:	b7efb0ef          	jal	80000c9c <release>
}
    80005922:	60e2                	ld	ra,24(sp)
    80005924:	6442                	ld	s0,16(sp)
    80005926:	64a2                	ld	s1,8(sp)
    80005928:	6105                	addi	sp,sp,32
    8000592a:	8082                	ret
      panic("virtio_disk_intr status");
    8000592c:	00002517          	auipc	a0,0x2
    80005930:	dcc50513          	addi	a0,a0,-564 # 800076f8 <etext+0x6f8>
    80005934:	f07fa0ef          	jal	8000083a <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	9282                	jalr	t0

000000008000609c <userret>:
    8000609c:	0000100f          	fence.i
    800060a0:	12000073          	sfence.vma
    800060a4:	18051073          	csrw	satp,a0
    800060a8:	12000073          	sfence.vma
    800060ac:	02000537          	lui	a0,0x2000
    800060b0:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060b2:	0536                	slli	a0,a0,0xd
    800060b4:	02853083          	ld	ra,40(a0)
    800060b8:	03053103          	ld	sp,48(a0)
    800060bc:	03853183          	ld	gp,56(a0)
    800060c0:	04053203          	ld	tp,64(a0)
    800060c4:	04853283          	ld	t0,72(a0)
    800060c8:	05053303          	ld	t1,80(a0)
    800060cc:	05853383          	ld	t2,88(a0)
    800060d0:	7120                	ld	s0,96(a0)
    800060d2:	7524                	ld	s1,104(a0)
    800060d4:	7d2c                	ld	a1,120(a0)
    800060d6:	6150                	ld	a2,128(a0)
    800060d8:	6554                	ld	a3,136(a0)
    800060da:	6958                	ld	a4,144(a0)
    800060dc:	6d5c                	ld	a5,152(a0)
    800060de:	0a053803          	ld	a6,160(a0)
    800060e2:	0a853883          	ld	a7,168(a0)
    800060e6:	0b053903          	ld	s2,176(a0)
    800060ea:	0b853983          	ld	s3,184(a0)
    800060ee:	0c053a03          	ld	s4,192(a0)
    800060f2:	0c853a83          	ld	s5,200(a0)
    800060f6:	0d053b03          	ld	s6,208(a0)
    800060fa:	0d853b83          	ld	s7,216(a0)
    800060fe:	0e053c03          	ld	s8,224(a0)
    80006102:	0e853c83          	ld	s9,232(a0)
    80006106:	0f053d03          	ld	s10,240(a0)
    8000610a:	0f853d83          	ld	s11,248(a0)
    8000610e:	10053e03          	ld	t3,256(a0)
    80006112:	10853e83          	ld	t4,264(a0)
    80006116:	11053f03          	ld	t5,272(a0)
    8000611a:	11853f83          	ld	t6,280(a0)
    8000611e:	7928                	ld	a0,112(a0)
    80006120:	10200073          	sret
	...
