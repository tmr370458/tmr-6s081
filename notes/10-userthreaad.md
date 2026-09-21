可以。按你这次实验实际遇到的问题，整理成适合以后复习的 Note：

# xv6 Multithreading 实验问题总结

## 1. `thread_schedule()` 会不会死循环？

### 问题

寻找下一个 `RUNNABLE` 线程时：

```c
for(int i = 0; i < MAX_THREAD; i++)
```

会不会因为没有可运行线程而一直循环？

### 解决

不会。

循环次数被 `MAX_THREAD` 限制，最多检查所有线程一次。

如果没有找到：

```c
if (next_thread == 0) {
    printf("thread_schedule: no runnable threads\n");
    exit(-1);
}
```

因此这是**有限搜索**，不会死循环。

---

## 2. `thread_schedule()` 和 `thread_switch()` 分别负责什么？

### 问题

是否应该在 `thread_schedule()` 中直接保存、恢复寄存器？

### 解决

不是。

两者职责不同：

```text
thread_schedule()
    ↓
决定从哪个线程切换到哪个线程
    ↓
thread_switch(old, new)
    ↓
保存 old 的寄存器
恢复 new 的寄存器
```

`thread_schedule()` 负责**调度决策**。

`thread_switch()` 负责**实际的上下文切换**。

---

## 3. 被切换出去的线程为什么不能直接变成 `FREE`？

### 问题

线程 A 切换到线程 B 后，A 是否应该：

```c
A.state = FREE;
```

### 解决

不能。

线程只是暂时停止运行，并没有结束。

状态应该：

```text
RUNNING
   ↓ thread_yield()
RUNNABLE
```

以后还要重新运行。

只有线程真正执行结束时：

```c
current_thread->state = FREE;
```

才表示线程死亡，可以被重新创建。

所以：

```text
RUNNABLE ≠ FREE
```

---

## 4. 为什么这里暂时不需要原子操作？

### 问题

xv6 kernel 的 `swtch` / scheduler 涉及并发和锁，那么用户级线程的 `thread_switch` 是否也需要原子操作？

### 解决

这个实验的基本实现是**单个用户进程中的用户级线程**。

当前情况下，用户线程由自己的：

```c
thread_schedule()
```

进行调度，并不是多个 CPU 同时执行这个调度器。

因此这里的基本实现不需要像 kernel scheduler 一样使用原子操作。

多核并发会成为问题，但那属于实验的 optional challenge。

---

# 5. `context` 到底是什么？

### 问题

`struct context` 是 xv6 kernel 中的结构，为什么用户线程也需要它？

### 解决

`context` 本质上就是：

> 保存一个执行流当前 CPU 寄存器状态的数据结构。

线程切换时：

```text
CPU寄存器
    ↓
old.context
```

然后：

```text
new.context
    ↓
CPU寄存器
```

所以 `context` 并不是 kernel 专属概念。

kernel scheduler 需要它：

```text
kernel context switch
```

用户级线程同样需要它：

```text
user thread context switch
```

用户线程需要自己定义一个相应的 `context` 结构。

---

# 6. 为什么 `thread_switch()` 只保存这些寄存器？

需要保存：

```text
ra
sp
s0 ~ s11
```

原因是这些属于 RISC-V ABI 中的 callee-save 寄存器。

`thread_switch()` 的基本过程：

```text
a0 → old context
a1 → new context
```

保存：

```asm
sd ra,  0(a0)
sd sp,  8(a0)
sd s0, 16(a0)
...
sd s11, 104(a0)
```

恢复：

```asm
ld ra,  0(a1)
ld sp,  8(a1)
ld s0, 16(a1)
...
ld s11, 104(a1)
```

最后：

```asm
ret
```

---

# 7. `thread_switch(A, B)` 中 A 和 B 分别是什么？

理解方式：

```c
thread_switch(&A.context, &B.context);
```

其中：

```text
A = 当前正在运行、需要保存的线程
B = 即将运行、需要恢复的线程
```

因此：

```text
A.context ← CPU当前寄存器
B.context → CPU寄存器
```

可以记成：

```text
thread_switch(old, new)
```

---

# 8. `thread_switch()` 为什么最后一个 `ret` 就能进入 B？

恢复 B 时：

```asm
ld ra, 0(a1)
```

把 B 保存的 `ra` 放入 CPU 的 `ra`。

然后：

```asm
ret
```

实际上相当于：

```asm
jalr x0, 0(ra)
```

因此：

```text
B.context.ra
      ↓
CPU.ra
      ↓
ret
      ↓
B 上次保存的位置
```

所以 context switch 并不是直接“调用另一个线程”。

而是：

> **恢复另一个线程之前保存的执行现场，然后利用 `ret` 回到它原来的执行位置。**

---

# 9. `void (*func)()` 是什么意思？

### 问题

第一次看到：

```c
void thread_create(void (*func)())
```

不知道 `func` 是什么。

### 解决

这是一个**函数指针**。

```c
void (*func)()
```

表示：

> `func` 指向一个无参数、返回 `void` 的函数。

例如：

```c
void thread_a()
{
    ...
}
```

调用：

```c
thread_create(thread_a);
```

就是把 `thread_a` 的函数地址传给 `func`。

因此：

```text
func
 ↓
thread_a 的地址
```

---

# 10. 为什么新线程的 `ra` 设置成 `func`？

新线程以前从来没有运行过，因此没有“上次执行位置”。

所以需要人为构造一个初始 context。

设置：

```c
t->context.ra = (uint64)func;
```

第一次：

```text
thread_switch()
    ↓
恢复新线程 context
    ↓
ra = func
    ↓
ret
    ↓
func()
```

所以第一次运行线程时，就能进入：

```c
thread_a()
```

---

# 11. 为什么 `sp` 不能设置成 `func`？

`ra` 和 `sp` 的含义完全不同：

```text
ra = 返回/继续执行的位置
sp = 当前线程使用的栈
```

所以新线程应该：

```text
ra → func
sp → 自己的 stack
```

例如：

```c
t->context.ra = (uint64)func;
t->context.sp = (uint64)&t->stack[STACK_SIZE];
```

---

# 12. 为什么每个线程必须有自己的 stack？

例如：

```c
void thread_a()
{
    int i;
}
```

`i` 等局部变量会放在线程自己的栈上。

因此：

```text
thread A → stack A
thread B → stack B
thread C → stack C
```

线程切换时恢复：

```text
sp
```

就可以重新回到该线程自己的栈。

所以 `struct thread` 中：

```c
char stack[STACK_SIZE];
```

和：

```c
context.sp
```

是配套的。

---

# 13. 整个 uthread 实验的核心

最终可以把整个实验压缩成：

```text
thread_create()
    ↓
构造新线程的初始 context
    ↓
ra = thread function
sp = thread 自己的 stack
```

运行过程中：

```text
thread A
    ↓
thread_yield()
    ↓
thread_schedule()
    ↓
决定 A → B
    ↓
thread_switch(A.context, B.context)
    ↓
保存 A
恢复 B
    ↓
ret
    ↓
B继续执行
```

核心思想：

> **用户级线程切换，本质就是保存一个线程的寄存器现场，再恢复另一个线程的寄存器现场。**

这部分先作为 **Uthread 阶段的实验 Note**。后面的 `Using threads` 和 `Barrier` 可以等你实际做到那里，再分别整理，避免把知识点混在一起。
