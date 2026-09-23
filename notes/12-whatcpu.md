
# CPU、Scheduler、Process、Thread、Lock 关系总结

## 1. CPU：真正执行指令的硬件

CPU 是最底层的执行单元。

CPU 不理解：

- C语言
- 函数
- 进程
- 线程

它只知道：

```

PC(Program Counter)
↓
下一条机器指令地址

寄存器
↓
当前计算状态

```

执行过程：

```

取指令
↓
译码
↓
执行
↓
更新PC
↓
下一条指令

````

CPU 本质：

> 按照 PC 指向的位置，不断执行机器码。


---

# 2. CPU 和 xv6 的 struct cpu

xv6 中：

```c
struct cpu
````

不是 CPU 硬件。

它是 xv6 为每个硬件 CPU 创建的软件描述结构。

硬件：

```
CPU0
CPU1
CPU2
```

xv6：

```
struct cpu cpu[3]
```

对应关系：

```
硬件CPU
    |
    ↓
xv6 struct cpu
```

保存：

* 当前运行的 proc
* scheduler context
* 中断状态

---

# 3. Scheduler：CPU上的调度执行流

scheduler 不是一个管理 CPU 的外部程序。

在 xv6：

每个 CPU 都有一个 scheduler。

结构：

```
CPU0
 |
 scheduler


CPU1
 |
 scheduler
```

scheduler 本身也是一个执行流。

它负责：

```
寻找 RUNNABLE 进程
        |
        ↓
context switch
        |
        ↓
运行进程
```

流程：

```
scheduler

    |
    | swtch()
    ↓

process/thread

    |
    | yield/sleep/trap
    ↓

scheduler
```

---

# 4. Context Switch：CPU如何切换执行流

CPU 一次只能执行一个线程。

切换时：

保存：

```
当前线程寄存器
PC
sp
ra
s0-s11
```

恢复：

```
另一个线程寄存器
```

所以：

线程本质包含：

```
线程 =
    PC
    寄存器状态
    栈
```

也就是：

```
context
```

---

# 5. Thread：真正的执行流

线程是：

> CPU执行的一条独立路径。

线程拥有：

```
自己的：

- PC
- 寄存器
- 栈
```

多个线程可以共享资源：

```
代码
全局变量
堆
文件
```

---

# 6. Process 和 Thread 的关系

现代 Linux：

```
Process
 |
 +---- Thread1
 |
 +---- Thread2
 |
 +---- Thread3
```

Process 提供：

```
资源环境：

- 地址空间
- 文件
- 权限
```

Thread 提供：

```
执行：

- PC
- 寄存器
- 栈
```

---

# 7. xv6 为什么没有线程概念？

因为 xv6 简化了模型。

xv6：

```
struct proc
```

同时包含：

```
资源容器
+
执行流
```

所以：

```
xv6 proc

≈

Linux process + 一个 thread
```

例如：

xv6：

```
fork()

父proc

    ↓

子proc
```

实际创建：

```
新的地址空间
+
新的执行流
```

---

# 8. Linux中的变化

Linux：

```
task_struct
        |
        ↓
      thread
```

scheduler 调度：

```
task_struct
```

也就是线程。

多个 task_struct 可以共享：

```
mm_struct
(地址空间)

files_struct
(文件)
```

所以：

```
Linux:

进程 = 资源集合

线程 = 调度单位
```

---

# 9. Lock 为什么出现？

因为多个 CPU 可以同时运行多个线程。

例如：

```
CPU0                 CPU1

线程A                线程B

       ↓

共同访问共享数据
```

如果没有保护：

```
数据竞争
race condition
```

例如：

```
counter++

实际上：

读取
+
修改
+
写回
```

两个 CPU 同时执行可能丢失更新。

---

# 10. Spinlock

作用：

> 保证同一时间只有一个 CPU 进入临界区。

结构：

```
spinlock

locked
 |
 | 记录锁状态


cpu
 |
 | 记录持有者
```

---

# 11. Atomic Operation

锁不能简单写：

```c
if(lock==0)
    lock=1;
```

因为：

```
CPU0:
读取0

CPU1:
读取0

CPU0:
写1

CPU1:
写1
```

两个 CPU 都成功。

所以需要：

```
atomic operation
```

例如：

```c
__atomic_exchange_n()
```

它保证：

```
读取旧值
+
写入新值

不可被其他CPU插入
```

结果：

```
old=0
    ↓
成功获得锁


old=1
    ↓
锁已经被占用
```

---

# 12. push_off 和锁

push_off：

不是关闭所有 CPU。

只是：

```
关闭当前CPU的中断
```

原因：

防止：

```
当前CPU

拿锁

↓

中断

↓

中断处理再次拿同一把锁

↓

死锁
```

---

# 13. 整体关系图

```
              CPU(硬件)
                  |
                  |
             执行scheduler
                  |
                  |
        --------------------
        |                  |
      thread1           thread2
        |                  |
        --------------------
                  |
          访问共享数据
                  |
                lock
```

---

# 14. 学习路线理解

之前：

```
页表
 ↓
trap
 ↓
syscall
 ↓
context switch
 ↓
scheduler
```

解决：

> 一个 CPU 如何运行程序

现在：

```
scheduler
 ↓
thread
 ↓
lock
```

解决：

> 多个 CPU 如何同时运行多个执行流

以后 Linux：

```
xv6 proc
    ↓
理解执行流
    ↓
Linux task_struct
    ↓
线程和进程分离
```

---

核心记忆：

```
CPU:
执行机器指令


Scheduler:
选择下一个执行流


Thread:
真正被CPU执行的单位


Process:
提供资源环境


Lock:
协调多个执行流访问共享资源
```

```

```
