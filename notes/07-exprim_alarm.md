
# xv6 Alarm Lab：问题与解决记录

## 1. Alarm 的整体机制是什么？

### 问题

一开始不清楚：

> `sigalarm()` 到底是怎么让用户程序定期执行 handler 的？

### 理解

Alarm 并不是 kernel 直接调用用户函数。

真正流程：

```text
用户程序
   ↓
timer interrupt
   ↓
usertrap()
   ↓
保存当前 trapframe
   ↓
修改 trapframe->epc = alarm_handler
   ↓
返回用户态
   ↓
用户程序从 handler 地址开始执行
```

关键点：

```c
p->trapframe->epc = p->alarm_handler;
```

`epc` 是**用户程序下一条要执行的指令地址**。

因此修改 `epc`，就相当于：

> “从 trap 返回用户态之后，不回原来的代码，而是先去执行 handler。”

---

# 2. `usertrap()` 到底是什么？

### 问题

之前容易把 `usertrap()` 理解成一个“不断运行的循环”。

### 解决

`usertrap()` 其实只是：

> **一次 trap 发生之后，kernel 处理这次 trap 的函数。**

流程：

```text
用户态运行
   ↓
发生 trap
   ↓
uservec
   ↓
usertrap
   ↓
处理 trap
   ↓
prepare_return
   ↓
userret
   ↓
sret
   ↓
回到用户态
```

例如 timer：

```c
if(which_dev == 2) {
    // timer interrupt
}
```

每次 timer interrupt 都会重新进入一次 `usertrap()`。

所以 Alarm 的计时就是：

```text
timer
 ↓
usertrap()
 ↓
alarm_ticks++
 ↓
timer
 ↓
usertrap()
 ↓
alarm_ticks++
```

---

# 3. syscall 参数是怎么传进 kernel 的？

### 问题

例如：

```c
sigalarm(2, periodic);
```

kernel 为什么能拿到 `2` 和 `periodic`？

### 解决

RISC-V 使用寄存器传递 syscall 参数。

用户代码：

```c
sigalarm(2, periodic);
```

大致变成：

```text
a0 = 2
a1 = periodic
a7 = SYS_sigalarm
ecall
```

进入 kernel：

```text
ecall
 ↓
syscall()
 ↓
sys_sigalarm()
```

然后：

```c
argint(0, &ticks);
argaddr(1, &handler);
```

从当前进程的 trapframe 中取出：

```text
a0 → 第一个参数
a1 → 第二个参数
```

所以：

> **用户态 syscall 参数 → RISC-V 参数寄存器 → trapframe → kernel syscall。**

---

# 4. 为什么需要保存 `trapframe`？

### 问题

Alarm 触发时，不能直接覆盖当前的执行现场。

假设原程序：

```text
A
B
C   ← timer 在这里发生
D
E
```

Alarm 触发后：

```text
handler()
```

handler 执行完以后，还必须回到：

```text
D
E
```

所以必须记住：

```text
C 执行到哪里
各个寄存器是什么
sp 是多少
ra 是多少
```

这些都在：

```c
p->trapframe
```

里面。

因此触发 Alarm 时：

```c
*p->alarm_trapframe = *p->trapframe;
```

把当前现场保存下来。

然后：

```c
p->trapframe->epc = p->alarm_handler;
```

让返回用户态后执行 handler。

---

# 5. 为什么不能直接保存指针？

### 错误思路

```c
p->alarm_trapframe = p->trapframe;
```

这只是：

> 两个指针指向同一块内存。

也就是：

```text
alarm_trapframe ──┐
                  ↓
             trapframe
```

修改其中一个，另一个也会被修改。

### 正确做法

分配一块新的内存：

```c
p->alarm_trapframe = (struct trapframe *)kalloc();
```

然后：

```c
*p->alarm_trapframe = *p->trapframe;
```

这是：

> **复制整个 struct 的内容。**

结果：

```text
trapframe
    ↓
[独立的一份现场]

alarm_trapframe
    ↓
[保存下来的另一份现场]
```

---

# 6. `kalloc()` 怎么知道这是 `trapframe`？

### 问题

```c
(struct trapframe *)kalloc()
```

为什么 `kalloc()` 返回的东西可以当 `trapframe`？

### 解决

`kalloc()` 本身根本不知道什么是 `trapframe`。

它只是：

```text
申请一页物理内存
 ↓
返回地址
```

而：

```c
(struct trapframe *)
```

只是告诉 C 编译器：

> “把这个地址按照 `struct trapframe` 的内存布局来解释。”

所以：

```text
物理内存
┌────────────────────┐
│ 一堆 bytes          │
└────────────────────┘
         ↓
(struct trapframe *)
         ↓
按照 trapframe 的字段解释
```

---

# 7. `sigreturn()` 为什么能够恢复程序？

Alarm handler 执行完以后：

```c
sigreturn();
```

kernel：

```c
uint64
sys_sigreturn(void)
{
    struct proc *p = myproc();

    *p->trapframe = *p->alarm_trapframe;

    return 0;
}
```

核心就是：

```c
*p->trapframe = *p->alarm_trapframe;
```

把之前保存的：

```text
PC
SP
ra
a0-a7
s0-s11
...
```

全部恢复。

尤其重要的是：

```text
trapframe->epc
```

恢复成原来被 timer 打断的位置。

于是：

```text
handler
   ↓
sigreturn()
   ↓
恢复 trapframe
   ↓
sret
   ↓
回到原程序
```

这就是 test1 的核心。

---

# 8. 为什么 test2 会出现 handler 重入？

### 问题

假设：

```text
interval = 2
```

handler 本身执行时间比较长：

```text
程序
 ↓
timer
 ↓
handler 开始
 ↓
timer
 ↓
又进入 handler
 ↓
timer
 ↓
又进入 handler
```

因为：

```c
p->trapframe->epc = p->alarm_handler;
```

每次 timer 都可能再次把 `epc` 设置成 handler。

于是 handler 会不断嵌套。

---

# 9. 怎么解决 handler 重入？

增加一个状态：

```c
int alarm_active;
```

含义：

```text
0 → 当前没有执行 handler
1 → 当前正在执行 handler
```

触发条件：

```c
if(p->alarm_interval > 0 &&
   p->alarm_active == 0)
```

触发后：

```c
p->alarm_active = 1;
```

handler 执行期间：

```text
timer
 ↓
发现 alarm_active == 1
 ↓
不再触发 handler
```

handler 最后：

```c
sigreturn()
```

恢复现场，同时：

```c
p->alarm_active = 0;
```

相当于解锁。

所以整个机制可以理解成：

```text
alarm_active = 0
      ↓
允许进入 handler
      ↓
alarm_active = 1
      ↓
禁止再次进入 handler
      ↓
sigreturn()
      ↓
alarm_active = 0
```

它本质上是一个**防止 handler 重入的状态锁**。

---

# 10. 最终 Alarm 的核心数据结构

我们最终在 `struct proc` 中增加了：

```c
int alarm_interval;
int alarm_ticks;
uint64 alarm_handler;
struct trapframe *alarm_trapframe;
int alarm_active;
```

分别表示：

| 字段                | 作用                  |
| ------------------- | --------------------- |
| `alarm_interval`  | 每多少个 tick 触发    |
| `alarm_ticks`     | 当前已经经过多少 tick |
| `alarm_handler`   | 用户 handler 地址     |
| `alarm_trapframe` | 保存被打断时的现场    |
| `alarm_active`    | handler 是否正在执行  |

---

# 11. 最终完整流程

```text
sigalarm(2, handler)
        ↓
保存 interval + handler
        ↓
────────────────────────
用户程序正常运行
        ↓
timer interrupt
        ↓
usertrap()
        ↓
alarm_ticks++
        ↓
ticks >= interval ?
        ↓ YES
保存 trapframe
        ↓
alarm_active = 1
        ↓
trapframe->epc = handler
        ↓
返回用户态
        ↓
执行 handler
        ↓
sigreturn()
        ↓
恢复 alarm_trapframe
        ↓
alarm_active = 0
        ↓
回到原程序
        ↓
继续计时
```

## 这次实验真正需要掌握的 5 个知识点

```text
① timer interrupt 如何进入 usertrap()

② trapframe 如何保存/恢复用户态执行现场

③ 修改 epc 如何改变用户态返回后的执行位置

④ syscall 参数如何通过 a0/a1 等寄存器传入 kernel

⑤ 如何利用状态变量防止 handler 重入
```

**如果这 5 个点你已经能自己解释，Alarm 这个实验的核心就基本吃透了。**
