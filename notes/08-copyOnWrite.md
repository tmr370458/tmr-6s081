# xv6 Lab: Copy-on-Write Fork 问题记录与解决方案

## 实验目标

实现 xv6 的 Copy-on-Write Fork。

核心思想：

fork 时不立即复制父进程物理内存，而是：

1. 父子进程共享物理页
2. 清除写权限
3. 标记 COW
4. 第一次写入触发 page fault
5. 内核复制页面并恢复写权限

---

# 1. 为什么引用计数使用 PA 而不是 VA？

## 问题

COW 中为什么记录：

```c
refcnt[pa / PGSIZE]
```

而不是：

```c
refcnt[va / PGSIZE]
```

## 原因

引用计数管理的是：

> 一个物理页被多少个页表引用

而不是：

> 一个虚拟地址被多少进程使用

例如：

```
父进程:

VA 0x4000
      |
      v
     PA A


子进程:

VA 0x8000
      |
      v
     PA A
```

两个进程的虚拟地址不同，但是共享同一个物理页。

因此引用计数应该绑定：

```
物理页 PA
```

---

# 2. PHYSTOP 的理解

## 问题

为什么：

```c
#define PHYSTOP (KERNBASE + 128 * 1024 * 1024)
```

是不是表示 kernel 只有 128MB？

## 理解

PHYSTOP 是：

> xv6 物理内存管理器管理的最高物理地址

不是 kernel 专用内存。

布局：

```
0
|
设备
|
KERNBASE
|
kernel
|
end
|
可分配物理内存
|
PHYSTOP
```

kalloc 管理：

```
end ~ PHYSTOP
```

用户页、kernel 页、COW 页都来自这里。

---

# 3. refcnt 数组下标设计问题

## 错误理解

直接：

```c
int refcnt[PHYSTOP / PGSIZE];
```

虽然可以运行，但包含了：

```
0 ~ KERNBASE
```

这些 xv6 不管理的区域。

## 更合理

使用：

```c
(pa - KERNBASE) / PGSIZE
```

例如：

```
PA = 0x80001000

index:

(0x80001000 - 0x80000000)/4096

=1
```

---

# 4. kfree 为什么需要修改？

## 原版逻辑

原来的 kfree：

```
释放页面
 ↓
加入 freelist
```

但是 COW 后：

```
父进程
 |
 PA
 |
子进程
```

同一个物理页可能被多个页表引用。

所以：

```
kfree()
 ↓
ref--
 ↓
ref > 0
    不释放

ref == 0
    放入 freelist
```

---

# 5. 为什么需要修改 freerange？

## 问题

启动：

```
kinit()
 |
 freerange()
 |
 kfree()
```

但是新的 kfree：

```c
refcnt--
```

刚开始：

```
refcnt = 0
```

导致：

```
0 -> -1
```

错误。

## 解决

freerange 中：

先设置：

```c
refcnt[index] = 1;
```

然后：

```c
kfree()
```

流程：

```
初始化页

ref = 1

kfree()

ref--

ref = 0

加入 freelist
```

---

# 6. uvmcopy 修改问题

## 原版

fork：

```
父页
 |
复制物理页
 |
子页
```

缺点：

fork 很慢。

## COW

改为：

```
父
 |
 PA
 |
子
```

共享物理页。

需要：

### 1. 清除写权限

```c
*pte &= ~PTE_W;
```

### 2. 设置 COW

```c
*pte |= PTE_COW;
```

### 3. 子进程映射同一个 PA

```c
mappages(new, i, PGSIZE, pa, flags);
```

### 4. 引用计数增加

注意：

必须在循环内部：

错误：

```c
for(...)
{
}

kaddref(pa);
```

只增加一次。

正确：

```c
for(...)
{
    mappages();

    kaddref(pa);
}
```

每个页增加一次。

---

# 7. COW 不应该作用于所有页面

错误：

```c
*pte &= ~PTE_W;
*pte |= PTE_COW;
```

所有页面设置 COW。

问题：

代码段：

```
PTE_R
PTE_X
```

本来不可写。

COW 的意义：

> 原本可写，但是共享后暂时不可写。

正确：

```c
if(flags & PTE_W)
{
    *pte &= ~PTE_W;
    *pte |= PTE_COW;
}
```

---

# 8. store page fault 和 load page fault 区别

RISC-V：

| scause | 含义               |
| ------ | ---------------- |
| 13     | load page fault  |
| 15     | store page fault |

---

Lazy Allocation:

```
访问不存在的页

13/15
 ↓
vmfault()
```

---

COW:

```
写共享页

15
 ↓
复制页
```

---

# 9. 为什么 COW 主要处理 scause=15？

因为：

读 COW 页：

```
PTE_R=1
```

可以直接读取。

写 COW 页：

```
PTE_W=0
```

触发：

```
store page fault
```

所以：

```
13:
    lazy allocation

15:
    COW 或 lazy allocation
```

---

# 10. Lazy Allocation + COW 的 usertrap 顺序问题

错误：

```c
if(15 || 13)
    vmfault()
else if(15)
    COW
```

因为：

第一个条件会先捕获所有 15。

---

正确：

```
scause=15
 |
检查 PTE_COW
 |
 +----是
 |     COW
 |
 +----否
       lazy allocation


scause=13

lazy allocation
```

---

# 11. COW 缺页处理流程

发生：

```
store page fault
```

步骤：

## 找虚拟地址

```c
va = r_stval();
```

## 找 PTE

```c
pte = walk(pagetable, va, 0);
```

## 判断 COW

```c
(*pte & PTE_COW)
```

## 分配新页

```c
kalloc()
```

## 复制旧页

```c
memmove(new, old, PGSIZE)
```

## 修改 PTE

旧：

```
PA old
COW
W=0
```

新：

```
PA new
W=1
COW=0
```

## 减少旧页引用

```c
kfree(old_pa)
```

---

# 12. C 语言坑

## 位运算优先级

错误：

```c
if(flag & PTE_COW == 0)
```

实际：

```c
flag & (PTE_COW == 0)
```

正确：

```c
if((flag & PTE_COW)==0)
```

---

# 13. COW 和 Lazy Allocation 的联系

两个实验本质都是：

利用 page fault 延迟处理。

Lazy:

```
需要时分配
```

COW:

```
需要写时复制
```

共同思想：

```
减少提前工作
提高资源利用率
```

---

# 实验总结

通过 Lazy Allocation 和 COW，理解了 xv6 虚拟内存核心机制：

* 页表不仅负责地址转换，也负责权限控制
* page fault 是内核延迟处理的重要入口
* PTE flag 保存页面状态
* PA 是物理资源，VA 是进程视角
* fork 优化依靠共享和延迟复制
* 引用计数管理共享资源生命周期

这些机制对应 Linux 内核中的：

* `do_page_fault`
* `copy_page_range`
* `fork`
* `mm_struct`
* `struct page->_refcount`

是理解 Linux 内存管理的重要基础。
