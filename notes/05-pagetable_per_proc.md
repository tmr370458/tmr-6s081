按你实际遇到的问题整理：

# 每进程 Kernel Page Table 实验问题记录

---

## 1. `kpagetable` 是什么？为什么需要它？

**问题：**

原来 xv6 已经有 `kernel_pagetable`，为什么还要加 `kpagetable`？

**解决：**

原版：

```
所有进程
    ↓
同一个 kernel_pagetable
```

实验改成：

```
进程A → A.kpagetable
进程B → B.kpagetable
```

目的：

* 每个进程有独立的内核地址空间
* 内核栈可以隔离
* 为后续更安全的内核设计做准备

---

## 2. `satp` 到底是什么？

**问题：**

之前误以为 `trapframe` 里面存的是页表，后来发现 satp 是 CPU 的。

**解决：**

`satp` 是 RISC-V CPU 寄存器：

```
satp
 ↓
当前使用的页表根地址
```

它不是页表。

真正：

```
VA → PA
```

存在页表 PTE 里面。

---

## 3. 为什么 trapframe 有 `kernel_satp`？

**问题：**

为什么 trapframe 里面保存 kernel_satp？

**解决：**

用户进入内核：

```
user
 ↓
uservec
 ↓
读取 trapframe->kernel_satp
 ↓
写入 satp
 ↓
切换内核页表
```

所以：

`kernel_satp` 是给下一次进入内核准备的。

---

## 4. VA 和 PA 的区别是什么？

**问题：**

为什么 VA 已经有了，还需要申请 PA？

**解决：**

理解：

```
VA = 门牌号
PA = 房子
页表 = 登记关系
```

例如：

```
kstack VA
    |
    ↓
页表
    |
    ↓
kernel stack PA
```

只有 VA：

```
没有实际内存
```

所以需要：

```
kalloc()
    ↓
得到 PA

mappages()
    ↓
VA → PA
```

---

## 5. `kstack` 是什么？

**问题：**

之前不知道 kstack 和 kpagetable 的关系。

**解决：**

kstack：

```
真正存内核运行数据的内存
```

进入内核：

```
sp
 ↓
kernel stack
```

保存：

* 函数调用
* 局部变量
* 返回地址

关系：

```
kstack(VA)
       ↓
kpagetable
       ↓
PA
```

---

## 6. procinit 为什么设置 kstack？

**问题：**

main 调 procinit 时还没有进程，怎么有 64 个 stack？

**解决：**

`proc[]` 数组提前存在：

```
proc[0]
proc[1]
...
proc[63]
```

procinit 做的是：

```
给未来的 proc 槽位准备资源
```

它只是分配：

```
p->kstack = KSTACK(i)
```

也就是 VA。

---

## 7. 为什么 allocproc 需要重新处理 kstack？

**问题：**

procinit 已经有 kstack 了，为什么 allocproc 还要管？

**解决：**

因为：

procinit：

```
确定 VA
```

allocproc：

```
真正创建进程

申请 PA

建立 VA→PA 映射
```

流程：

```
procinit
    |
    ↓
kstack VA


allocproc
    |
    ↓
kalloc()
    |
    ↓
kstack PA


map:
VA → PA
```

---

## 8. 为什么不能直接调用 kvminit？

**问题：**

创建 kpagetable 为什么不用 kvminit？

**解决：**

因为：

```
kvminit()
```

创建：

```
全局 kernel_pagetable
```

实验需要：

```
每个 proc 一张
```

所以用：

```
kvmmake()
```

创建新页表。

---

## 9. kvmmake 里的东西是不是全部复制？

**问题：**

每个进程的 kernel 页表是不是要复制所有内核内存？

**解决：**

不是复制物理内存。

例如：

```
kernel text
UART
PLIC
```

多个页表可以：

```
映射同一个 PA
```

只有：

```
kernel stack
```

需要每个进程独立。

---

## 10. scheduler 为什么原来没有 satp？

**问题：**

为什么 scheduler 原版不切换页表？

**解决：**

因为原版：

```
所有进程共享 kernel_pagetable
```

所以：

```
切进程
只需要切 context
```

实验后：

```
A → A.kpagetable
B → B.kpagetable
```

所以 scheduler 需要：

```
切换 satp
```

---

## 11. 为什么 scheduler 结束后要切回页表？

**问题：**

为什么跑完进程要恢复全局页表？

**解决：**

因为 scheduler 本身不是进程。

流程：

```
scheduler
 ↓
切A.kpagetable
 ↓
A运行
 ↓
yield
 ↓
回scheduler
 ↓
恢复scheduler自己的页表
```

---

## 12. freeproc 为什么要释放 kpagetable？

**问题：**

最后回收页表是什么？

**解决：**

创建：

```
allocproc
    ↓
创建kpagetable
```

销毁：

```
freeproc
    ↓
释放kpagetable
```

否则：

```
fork
exit
fork
exit

不断泄漏页表内存
```

---

## 13. 整个实验最终理解

你实际解决的问题链：

```
为什么需要kpagetable
        ↓
satp是什么
        ↓
VA/PA关系
        ↓
kstack是什么
        ↓
procinit准备VA
        ↓
allocproc申请PA并map
        ↓
scheduler切换页表
        ↓
trap进入内核使用kernel_satp
        ↓
freeproc释放
```

这基本就是你这次实验踩到的全部关键点。
