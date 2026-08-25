
# xv6 Chapter 3：Virtual Memory 页表与地址转换笔记

## 1. 基本概念

现代操作系统使用**虚拟内存（Virtual Memory）**机制，让程序使用虚拟地址，而不是直接访问物理内存。

CPU产生：

```
Virtual Address (VA)
        |
        ↓
   页表(Page Table)
        |
        ↓
Physical Address (PA)
```

页表负责完成：

```
虚拟页号 VPN  →  物理页号 PPN
```

页内偏移 offset 保持不变。

---

# 2. 地址组成

## 2.1 虚拟地址 VA

xv6 使用 RISC-V Sv39 地址模式。

一个虚拟地址：

```
| VPN[2] | VPN[1] | VPN[0] | offset |
|   9bit |   9bit |   9bit | 12bit  |
```

其中：

* VPN：Virtual Page Number，虚拟页号
* offset：页内偏移

页大小：

```
4KB = 2^12 bytes
```

因此：

offset 占 12 bit。

---

# 3. Sv39三级页表

Sv39 使用三级页表：

```
                L2 Page Table
                     |
                     |
                  L2 PTE
                     |
                     ↓
                L1 Page Table
                     |
                     |
                  L1 PTE
                     |
                     ↓
                L0 Page Table
                     |
                     |
                  L0 PTE
                     |
                     ↓
              Physical Page
```

三级分别：

```
L2
L1
L0
```

---

# 4. 为什么每级页表有512项？

每一级索引：

```
VPN[0/1/2]
```

大小：

```
9 bit
```

所以：

```
2^9 = 512
```

每一级页表：

```
512 个 PTE
```

---

一个 PTE：

```c
typedef uint64 pte_t;
```

大小：

```
8 bytes
```

所以一个页表大小：

```
512 × 8

=4096 bytes

=4KB
```

因此：

```
一个页表 = 一个4KB页面 = 512个PTE
```

---

# 5. pagetable_t是什么？

xv6：

```c
typedef uint64 *pagetable_t;
```

含义：

```
pagetable_t = 指向PTE的指针
```

因为一个页表本质：

```
512个PTE组成的数组
```

所以：

```
pagetable_t
        |
        ↓

+---------+
| PTE[0]  |
+---------+
| PTE[1]  |
+---------+
| ...     |
+---------+
|PTE[511] |
+---------+
```

注意：

`pagetable_t`本身只有8字节。

它只是保存页表起始地址。

---

# 6. PTE结构

一个PTE：

```
63                    10 9        0
+----------------------+-----------+
|        PPN           |  Flags    |
+----------------------+-----------+
```

其中：

* PPN：Physical Page Number
* Flags：权限信息

Flags包括：

```
PTE_V  有效
PTE_R  可读
PTE_W  可写
PTE_X  可执行
```

---

# 7. 为什么PTE2PA是：

```c
#define PTE2PA(pte) (((pte)>>10)<<12)
```

原因：

PTE中：

```
低10位保存flags
高位保存PPN
```

所以：

## 第一步

去掉flags：

```
pte >> 10
```

得到：

```
PPN
```

## 第二步

恢复物理地址：

```
PPN << 12
```

因为：

```
页大小 = 4KB = 2^12
```

得到：

```
Physical Page Start Address
```

---

# 8. L2/L1/L0中的PTE区别

虽然三级页表中的PTE结构一样：

```
pte_t = uint64
```

但是含义不同。

## L2 PTE

保存：

```
L1页表的物理地址
```

即：

```
L2 PTE
      ↓
   L1 Page Table
```

---

## L1 PTE

保存：

```
L0页表的物理地址
```

即：

```
L1 PTE
      ↓
   L0 Page Table
```

---

## L0 PTE

保存：

```
真正数据页的物理地址
```

即：

```
L0 PTE
      ↓
 Physical Page
```

---

# 9. VA如何转换为PA？

假设：

虚拟地址：

```
VA

VPN[2]
VPN[1]
VPN[0]
offset
```

---

## 第一步：找到根页表

CPU通过：

```
satp寄存器
```

找到：

```
L2根页表
```

---

## 第二步：查L2

使用：

```
VPN[2]
```

访问：

```
L2[VPN[2]]
```

得到：

```
L1页表地址
```

---

## 第三步：查L1

使用：

```
VPN[1]
```

访问：

```
L1[VPN[1]]
```

得到：

```
L0页表地址
```

---

## 第四步：查L0

使用：

```
VPN[0]
```

访问：

```
L0[VPN[0]]
```

得到：

```
PTE
```

其中包含：

```
PPN
```

---

## 第五步：生成物理地址

物理地址：

```
PA = PPN + offset
```

也就是：

```
物理页号 + 页内偏移
```

---

# 10. walk()函数作用

xv6：

```c
walk()
```

作用：

```
VA
 |
 ↓
找到对应的PTE地址
```

它不会完成：

```
VA → PA
```

只是：

```
VA → PTE位置
```

流程：

```
L2
 |
VPN[2]

↓

L1
 |
VPN[1]

↓

L0
 |
VPN[0]

↓

返回PTE
```

---

# 11. 最大物理内存计算

Sv39：

PTE中的：

```
PPN = 44bit
```

页大小：

```
4KB = 2^12
```

所以：

物理地址：

```
PPN + offset
```

总位数：

```
44 + 12

=56 bit
```

最大物理地址空间：

```
2^56 bytes
```

即：

```
64 PB
```

---

# 12. 最大虚拟地址空间计算

Sv39：

VPN：

```
9 + 9 + 9

=27 bit
```

虚拟页数量：

```
2^27
```

每页：

```
2^12 bytes
```

所以：

```
2^27 × 2^12

=2^39 bytes
```

即：

```
512 GB
```

---

# 13. 总结

核心关系：

```
Virtual Address

= VPN + offset


Page Table

= VPN → PPN


Physical Address

= PPN + offset
```

三级页表：

```
VA

 |
 ↓

L2
 |
 ↓

L1
 |
 ↓

L0
 |
 ↓

PTE

 |
 ↓

PA
```

关键理解：

1. 一个页表大小为4KB，由512个PTE组成。
2. `pagetable_t`只是指向页表的指针。
3. 所有层级都有PTE。
4. L2/L1的PTE指向下一层页表。
5. L0的PTE指向真正物理页。
6. 页表只负责转换页号，offset始终保持不变。
