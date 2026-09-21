# pthread 条件变量与 Barrier 实验理解笔记

## 1. Barrier 是什么？

Barrier（屏障）是一种线程同步机制：

> 多个线程必须全部到达某个点后，才能继续执行。

例如三个线程：

```
Thread A ----\
Thread B ----- > barrier
Thread C ----/
```

只有 A、B、C 都到达 barrier 后，三个线程才能一起继续。

应用场景：

* 并行计算分阶段执行
* 多线程任务同步
* 等待初始化完成

---

# 2. 为什么需要 Barrier？

假设：

```c
nthread = 已经到达 barrier 的线程数量
```

三个线程：

```
NTHREAD = 3
```

执行：

```
A 到达:
nthread = 1

B 到达:
nthread = 2

C 到达:
nthread = 3
```

只有 C 到达时，条件满足：

```
nthread == NTHREAD
```

之前到达的线程必须等待。

---

# 3. 为什么需要 mutex？

多个线程同时修改：

```c
nthread++;
```

会产生 race condition。

例如：

初始：

```
nthread = 0
```

两个线程同时执行：

```
Thread A:
读取 nthread = 0

Thread B:
读取 nthread = 0


Thread A:
写 nthread = 1

Thread B:
写 nthread = 1
```

最终：

```
nthread = 1
```

但实际上两个线程已经到达。

因此：

必须使用 mutex 保护共享变量。

流程：

```
pthread_mutex_lock()

修改共享数据

pthread_mutex_unlock()
```

---

# 4. condition variable（条件变量）是什么？

条件变量不是任务池，也不是缓冲区。

它本质是：

> 一个等待队列的标识。

它保存的是：

```
正在等待某个条件满足的线程
```

例如：

```
cond

等待队列:
[A]
[B]
```

表示：

A、B 两个线程正在等待某个条件。

---

# 5. pthread_cond_wait()

调用：

```c
pthread_cond_wait(&cond, &mutex);
```

执行过程：

```
线程持有 mutex

        |
        ↓

加入 cond 等待队列

        |
        ↓

释放 mutex

        |
        ↓

线程睡眠

        |
        ↓

被唤醒

        |
        ↓

重新获得 mutex

        |
        ↓

继续执行
```

重点：

睡眠时必须释放锁。

否则：

```
线程 A 睡眠
但是占有 mutex

线程 B:
想修改状态

拿不到锁

所有线程卡死
```

---

# 6. pthread_cond_broadcast()

调用：

```c
pthread_cond_broadcast(&cond);
```

作用：

唤醒所有等待 cond 的线程。

例如：

之前：

```
cond:

[A]
[B]
```

broadcast 后：

```
A → runnable
B → runnable
```

注意：

broadcast 不会直接运行线程。

它只是：

```
睡眠状态
    ↓
可运行状态
```

之后由调度器决定谁获得 CPU。

---

# 7. Barrier 的完整流程

假设：

```
NTHREAD = 3
```

初始：

```
round = 0
nthread = 0
```

---

## A 到达

记录当前轮：

```
old_round = 0
```

增加：

```
nthread = 1
```

发现：

```
1 != 3
```

等待：

```
while(round == old_round)

    cond_wait()
```

A 睡眠。

---

## B 到达

```
nthread = 2
```

等待。

---

## C 到达

```
nthread = 3
```

满足条件。

执行：

```
nthread = 0

round++

broadcast()
```

结果：

```
round:
0 → 1
```

唤醒 A、B。

---

# 8. 为什么需要 round？

不能只靠：

```
nthread == 0
```

判断。

原因：

Barrier 会循环执行。

例如：

第一轮：

```
A B C
```

结束：

```
nthread = 0
```

如果 A 太快进入第二轮：

```
A:
nthread++
```

变成：

```
nthread = 1
```

但是 B、C 可能还没有完全退出第一轮。

它们看到：

```
nthread = 1
```

会误认为：

"第一轮还没结束"

实际上：

这是第二轮的数据。

---

所以需要：

```
round
```

作为版本号。

线程进入 barrier 时记录：

```c
old_round = round;
```

然后等待：

```c
while(round == old_round)
{
    cond_wait();
}
```

含义：

> 只要 round 没变化，说明这一轮还没结束。

---

# 9. Barrier 和 xv6 的对应关系

| pthread        | xv6           |
| -------------- | ------------- |
| mutex          | lock          |
| cond_wait      | sleep         |
| cond_broadcast | wakeup        |
| waiting queue  | sleep channel |

本质思想：

```
线程发现条件不满足

        ↓

主动睡眠

        ↓

其他线程改变状态

        ↓

唤醒等待线程

        ↓

线程继续执行
```

---

# 10. 三个线程实验的联系

## uthread

学习：

```
线程切换
context保存
寄存器恢复
```

核心：

```
thread_switch()
```

---

## ph

学习：

```
多个线程共享数据
race condition
mutex
```

核心：

```
锁保护临界区
```

---

## barrier

学习：

```
线程之间协调执行顺序
条件变量
sleep/wakeup模型
```

核心：

```
等待条件满足
```

---

一句话总结：

> mutex 解决“谁能修改共享数据”；condition variable 解决“什么时候线程可以继续执行”。
