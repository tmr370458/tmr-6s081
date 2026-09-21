# xv6 Chapter 7 锁：进程切换与实验前理解笔记

## 1. 锁实验前需要理解的核心

锁解决的问题：

> 多个 CPU / 多个执行流同时访问共享数据时，避免数据被破坏。

例如：

CPU0 和 CPU1 同时修改：

```c
list
```

可能产生：

* 数据丢失
* 链表损坏
* 读取到未完成的数据

这种情况叫：

```
race condition（竞争）
```

---

# 2. 锁的基本思想

锁保证：

```
同一时间只有一个 CPU 进入临界区
```

例如：

```c
acquire(&lock);

// critical section
// 修改共享数据

release(&lock);
```

其中：

```
acquire 到 release
```

之间叫：

```
critical section（临界区）
```

锁保护的是：

```
共享数据的不变性 invariant
```

例如链表：

正常：

```
list → node1 → node2
```

push过程中：

```c
l->next = list;
list = l;
```

中间状态可能暂时破坏链表结构。

锁保证：

> 其他 CPU 不会看到这个中间状态。

---

# 3. spinlock（自旋锁）

xv6主要使用：

```c
struct spinlock
```

核心字段：

```c
locked
```

表示：

```
0:
锁空闲

1:
锁被占用
```

---

## 为什么不能简单写？

错误：

```c
if(lock == 0)
    lock = 1;
```

因为：

CPU0:

```
看到 lock=0
```

CPU1:

```
看到 lock=0
```

然后：

CPU0:

```
lock=1
```

CPU1:

```
lock=1
```

两个 CPU 都认为自己拿到了锁。

---

## xv6如何解决？

使用 RISC-V 原子指令：

```
amoswap
```

作用：

一次完成：

```
读取旧值
+
写入新值
```

不可被其他 CPU 插入。

代码：

```c
while(
 __atomic_exchange_n(&lk->locked,1,...)
 !=0)
 ;
```

含义：

不断尝试：

```
把1交换进去

如果之前是0:
成功获得锁

如果之前是1:
别人持有，继续等待
```

---

# 4. acquire流程

代码：

```c
acquire(struct spinlock *lk)
{
    push_off();

    while(atomic_swap())
        ;

    lk->cpu=mycpu();
}
```

流程：

```
acquire
 |
 |
关闭中断
 |
 |
原子抢锁
 |
 |
记录持有CPU
```

---

# 5. 为什么 acquire 要关闭中断？

因为中断可能导致死锁。

例如：

CPU执行：

```
sys_pause()
```

拿到：

```
tickslock
```

突然：

```
timer interrupt
```

进入：

```
clockintr()
```

中断处理也需要：

```
tickslock
```

于是：

```
clockintr等待tickslock
```

但是：

```
sys_pause
```

无法继续执行释放锁。

结果：

```
死锁
```

所以：

拿自旋锁前：

```
关闭当前CPU中断
```

---

# 6. push_off()

作用：

不是立即禁止所有中断，而是记录嵌套次数。

结构：

```c
cpu->noff
```

表示：

当前 CPU 关闭中断的嵌套层数。

例如：

第一次：

```
push_off()

noff=1
```

第二次：

```
push_off()

noff=2
```

只有：

```
noff=0
```

才重新打开中断。

---

# 7. 进程切换中的 context

xv6切换进程不是复制整个进程。

只是切换：

```
CPU执行上下文(context)
```

context保存：

```
ra
sp
s0-s11
```

等寄存器。

---

# 8. c->context 和 p->context

每个 CPU：

```c
struct cpu
{
    struct context context;
}
```

保存：

```
scheduler 的执行位置
```

也就是：

```
c->context
```

---

每个进程：

```c
struct proc
{
    struct context context;
}
```

保存：

```
进程上次运行的位置
```

也就是：

```
p->context
```

---

# 9. swtch()

核心函数：

```c
swtch(old,new)
```

含义：

## 保存old

把当前 CPU 寄存器：

```
CPU
 |
 ↓
old context
```

保存。

## 恢复new

把：

```
new context
 |
 ↓
CPU寄存器
```

加载。

---

# 10. scheduler 和 sched 的区别

## scheduler()

方向：

```
scheduler
    |
    | swtch(c,p)
    ↓
process
```

作用：

寻找 RUNNABLE 进程，让它运行。

---

## sched()

方向：

```
process
    |
    | swtch(p,c)
    ↓
scheduler
```

作用：

当前进程主动交还 CPU。

---

# 11. 一个完整切换流程

启动：

```
scheduler
    |
    acquire(p->lock)
    |
    p->state=RUNNING
    |
    swtch(c->context,p->context)
    |
    ↓
进程运行
```

---

时间片结束：

```
timer interrupt
        |
        ↓
usertrap()
        |
        ↓
yield()
        |
        ↓
sched()
        |
        ↓
swtch(p->context,c->context)
        |
        ↓
scheduler
```

---

# 12. yield / sleep / exit

它们都是：

```
process → scheduler
```

的入口。

## yield

主动让出 CPU：

```
yield()
 |
 sched()
 |
 swtch()
```

## sleep

等待资源：

```
sleep()
 |
 sched()
 |
 swtch()
```

## exit

结束进程：

```
exit()
 |
 sched()
 |
 swtch()
```

---

# 13. 多核 CPU 和调度

多个 CPU：

```
CPU0:
scheduler
  |
 process A


CPU1:
scheduler
  |
 process B
```

同时运行。

共享：

```
proc数组
内存
文件系统
```

因此需要：

```
p->lock
```

保护进程状态。

---

# 14. 锁实验重点阅读文件

优先：

```
kernel/spinlock.c
kernel/spinlock.h

kernel/proc.c

kernel/kalloc.c
```

重点函数：

```
acquire()
release()

push_off()
pop_off()

scheduler()

sched()

yield()

sleep()

wakeup()

kalloc()

kfree()
```

---

# 15. 做实验时的思考方式

看到：

```c
acquire(&xxx.lock)
```

不要只问：

"为什么加锁？"

应该问：

```
这个锁保护什么数据？
这个数据有什么invariant？
如果没有锁，会发生什么race？
```

例如：

```
kmem.lock
保护：
freelist

p->lock
保护：
proc状态
上下文
父子关系
```

---

# 实验前状态

当前已经掌握：

* race产生原因
* 锁的作用
* spinlock原理
* amoswap原子操作
* acquire/release流程
* 中断与锁死锁关系
* scheduler/sched/swtch关系

可以开始 xv6 Locking Lab。
