# xv6 Locking Lab：kalloc 内存分配

## 1. 为什么要改 `kmem`

原来的 xv6：

```c
struct {
  struct spinlock lock;
  struct run *freelist;
} kmem;
```

所有 CPU 都使用：

```text
kmem.freelist
```

所以多个 CPU 同时 `kalloc()` / `kfree()` 时，都需要竞争同一把锁。

问题：

```text
CPU 0 ─┐
CPU 1 ─┤
CPU 2 ─┼──→ 同一把 kmem.lock
CPU 3 ─┘
```

CPU 越多，锁竞争越严重。

---

## 2. 改成 per-CPU freelist

改成：

```text
CPU 0 → kmem[0].freelist + lock
CPU 1 → kmem[1].freelist + lock
CPU 2 → kmem[2].freelist + lock
CPU 3 → kmem[3].freelist + lock
```

初始化：

```c
for(int i = 0; i < NCPU; i++){
    char name[9] = {0};
    snprintf(name, 8, "kmem-%d", i);
    initlock(&kmem[i].lock, name);
}
```

核心思想：

> 把一把所有 CPU 争抢的全局锁，拆成每个 CPU 自己的一把锁。

这样正常情况下：

```text
CPU 0 → lock0
CPU 1 → lock1
CPU 2 → lock2
CPU 3 → lock3
```

可以并行执行。

---

# 3. `kfree()` 怎么改

原来：

```c
acquire(&kmem.lock);

r->next = kmem.freelist;
kmem.freelist = r;

release(&kmem.lock);
```

改成：

```c
push_off();

int cpu = cpuid();

acquire(&kmem[cpu].lock);

r->next = kmem[cpu].freelist;
kmem[cpu].freelist = r;

release(&kmem[cpu].lock);

pop_off();
```

逻辑：

```text
当前线程
    ↓
当前 CPU
    ↓
cpuid()
    ↓
找到对应 kmem[cpu]
    ↓
把页面放回这个 CPU 的 freelist
```

注意：

> 是按 **CPU** 分配，不是按线程分配。

---

# 4. 为什么需要 `push_off()`

因为这里：

```c
int cpu = cpuid();
```

得到的是当前 CPU。

我们希望在后面的操作中 CPU 身份保持稳定：

```text
push_off()
    ↓
cpuid()
    ↓
操作 kmem[cpu]
    ↓
pop_off()
```

所以 `push_off()` 是为了保证这段操作期间 CPU ID 不发生变化。

---

# 5. `kalloc()` 怎么改

首先查看当前 CPU：

```c
push_off();

int cpu = cpuid();

acquire(&kmem[cpu].lock);

r = kmem[cpu].freelist;

if(r)
    kmem[cpu].freelist = r->next;

release(&kmem[cpu].lock);
```

这里：

```c
if(r == 0)
```

表示：

> 当前 CPU 的 freelist 已经没有空闲页面。

所以：

```text
r != 0 → 直接拿自己的页面

r == 0 → 自己没有了 → 去其他 CPU 偷
```

---

# 6. 什么叫“偷”

例如：

```text
CPU 0: NULL
CPU 1: A → B → C
CPU 2: D
CPU 3: NULL
```

CPU 0 要 `kalloc()`：

```text
CPU 0 自己没页面
        ↓
寻找其他 CPU
        ↓
找到 CPU 1
        ↓
锁住 kmem[1]
        ↓
拿走 A
        ↓
CPU 1 剩下 B → C
```

变成：

```text
CPU 0：A
CPU 1：B → C
CPU 2：D
CPU 3：NULL
```

偷取的目的：

> 防止某个 CPU 没有空闲页，而另一个 CPU 还有大量空闲页。

---

# 7. 为什么偷别人时必须加别人的锁

例如 CPU 0 想操作：

```c
kmem[1].freelist
```

CPU 1 自己也可能同时操作自己的 freelist。

所以：

```c
acquire(&kmem[next_cpu].lock);
```

保护：

```c
r = kmem[next_cpu].freelist;

if(r)
    kmem[next_cpu].freelist = r->next;
```

然后马上：

```c
release(&kmem[next_cpu].lock);
```

核心原则：

> **谁的 freelist 被修改，就必须持有谁的锁。**

---

# 8. `ksteal()` 的关键 bug

最开始写成：

```c
void
ksteal(int cpu)
{
    struct run *r;
    ...
}
```

虽然确实偷到了页面：

```text
ksteal()
    ↓
r = A
```

但是 `r` 是 `ksteal()` 的局部变量。

函数结束：

```text
ksteal() 返回
    ↓
里面的 r 消失
```

外面的 `kalloc()`：

```c
r
```

仍然是 `0`。

所以必须让 `ksteal()` 返回页面：

```c
struct run*
ksteal(int cpu)
```

然后：

```c
if(r == 0)
    r = ksteal(cpu);
```

这样：

```text
自己的 freelist为空
        ↓
ksteal(cpu)
        ↓
偷到 A
        ↓
return A
        ↓
kalloc 中的 r = A
        ↓
继续正常处理
```

---

# 9. 偷取 CPU 的选择

可以：

```c
for(int i = 1; i < NCPU; i++){
    int next_cpu = (cpu + i) % NCPU;
    ...
}
```

例如当前：

```text
cpu = 2
NCPU = 4
```

那么检查顺序：

```text
CPU 3
CPU 0
CPU 1
```

利用：

```c
(cpu + i) % NCPU
```

实现循环寻找。

---

# 10. 为什么不用把偷来的页放进自己的 freelist

可以直接：

```text
偷到 A
 ↓
return A
 ↓
当前这次 kalloc() 直接使用 A
```

没必要：

```text
偷 A
 ↓
放入自己的 freelist
 ↓
再从自己的 freelist取 A
```

直接返回更简单。

---

# 11. 初始化分配的问题

这里容易混淆。

`freerange()` 会调用 `kfree()`。

但如果 `kfree()` 使用：

```c
cpu = cpuid();
```

那么启动初始化阶段如果一直在同一个 CPU 上执行：

```text
所有页面
    ↓
同一个 CPU
    ↓
同一个 freelist
```

所以初始化阶段需要额外考虑如何把页面平均分配给不同 CPU。

理想状态：

```text
page 0 → CPU 0
page 1 → CPU 1
page 2 → CPU 2
page 3 → CPU 3
page 4 → CPU 0
...
```

可以用：

```c
count % NCPU
```

轮流分配。

---

# 12. 最终整体模型

整个 allocator 可以记成：

```text
                kalloc()
                   │
             当前 CPU freelist
              /           \
           有页面          没页面
             │               │
          直接取            ksteal()
                             │
                       找其他 CPU
                             │
                        加对方的锁
                             │
                           偷页面
                             │
                         返回页面
```

而 `kfree()`：

```text
kfree(page)
     ↓
cpuid()
     ↓
当前 CPU 的 freelist
     ↓
加锁
     ↓
放回去
     ↓
解锁
```

## 最核心的一句话

> **平时各 CPU 用自己的 freelist，减少锁竞争；自己的 freelist 空了，再加锁从其他 CPU 偷页面。**
