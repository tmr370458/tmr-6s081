
# RISC-V 汇编与 C 内联汇编基础

## 1. C 内联汇编

xv6 中经常看到：

```c
asm volatile("csrw satp, %0" : : "r"(x));
```

这是 GCC/Clang 的 **Extended Inline Assembly（扩展内联汇编）**，不是普通 C 语法。

基本结构：

```c
asm volatile(
    "汇编代码"
    : 输出操作数
    : 输入操作数
    : clobber
);
```

最多有三个 `:`，分别分隔：

```text
汇编代码
  :
输出
  :
输入
  :
clobber
```

如果某一区域为空，冒号仍然保留。

例如：

```c
asm volatile("csrw satp, %0" : : "r"(x));
```

表示：

* 第一个 `:` 后的输出区域为空
* 第二个 `:` 后是输入区域
* `"r"(x)`：把 `x` 作为输入，并放入通用寄存器
* `%0`：引用第 0 个操作数，也就是 `x`

常见约束：

```text
"r"(x)    输入，使用通用寄存器
"=r"(x)   输出，使用通用寄存器
"+r"(x)   输入 + 输出
```

`volatile` 表示这段汇编具有重要副作用，编译器不能因为它看起来没有返回值就随意删除或优化掉。

---

## 2. `%0`、`%1` 是什么

它们是 GCC 内联汇编中**操作数的编号**。

例如：

```c
asm(
    "add %0, %1, %2"
    : "=r"(c)
    : "r"(a), "r"(b)
);
```

对应：

```text
%0 → c
%1 → a
%2 → b
```

最终编译器会把这些占位符替换成实际寄存器。

注意：

> `%0/%1` 是 GCC 内联汇编的操作数编号，不等于 RISC-V 指令的操作数。

---

## 3. RISC-V 指令的操作数

例如：

```asm
sfence.vma x5, x6
```

这里 `x5` 和 `x6` 是 RISC-V 指令本身的操作数。

`sfence.vma` 可以接受两个操作数：

```text
rs1 → 虚拟地址
rs2 → ASID（地址空间标识）
```

特殊情况下：

```asm
sfence.vma zero, zero
```

其中 `zero` 是 RISC-V 的 `x0`，恒为 0。

这种形式可以理解为对当前地址空间范围执行全面的地址转换同步。

---

## 4. `sfence.vma`

`sfence.vma` 是 RISC-V 的特权指令，用于处理**页表修改与地址转换缓存之间的一致性**。

当修改：

```text
satp
```

或者修改页表后，处理器可能仍然存在旧的虚拟地址 → 物理地址转换状态（例如 TLB 中的缓存）。

因此 xv6 中经常看到：

```c
w_satp(...);
sfence_vma();
```

可以理解为：

```text
切换当前使用的页表
        ↓
sfence.vma
        ↓
后续地址转换按照新的页表处理
```

它不是普通的数据 Cache 刷新指令，而主要针对**虚拟内存地址转换机制**。

---

## 5. `satp` 与 `sfence.vma`

`RISC-V` 中：

```text
satp
 ↓
决定当前使用哪一个页表
```

而：

```text
sfence.vma
 ↓
让地址转换相关的旧状态与新的页表保持一致
```

因此 xv6：

```c
w_satp(MAKE_SATP(kernel_pagetable));
sfence_vma();
```

可以理解成：

```text
kernel_pagetable
       ↓
MAKE_SATP()
       ↓
得到 satp 的值
       ↓
w_satp()
       ↓
CPU 切换到新的页表
       ↓
sfence.vma
       ↓
同步地址转换状态
```

---

## 6. `w_satp()` 的实现

xv6 中类似：

```c
static inline void
w_satp(uint64 x)
{
    asm volatile("csrw satp, %0" : : "r"(x));
}
```

逐部分理解：

```text
static inline
    → 短小函数，允许编译器内联

asm volatile
    → 嵌入一段不会被随意优化掉的汇编

csrw satp, %0
    → 将操作数写入 satp

:
    → 输出为空

:
    → 开始输入区域

"r"(x)
    → x 是输入，并使用通用寄存器

%0
    → 第 0 个 GCC 操作数，即 x
```

最终本质上是在执行 RISC-V 的：

```asm
csrw satp, <某个寄存器>
```

---

## 7. 两种“操作数”不要混淆

### GCC 内联汇编操作数

```c
%0
%1
%2
```

表示：

```text
第 0、1、2 个 C 操作数
```

### RISC-V 指令操作数

```asm
sfence.vma x5, x6
```

表示：

```text
x5 → 第一个 RISC-V 指令操作数
x6 → 第二个 RISC-V 指令操作数
```

两者属于不同层次。

---

## 8. 当前阶段需要掌握的核心

```text
asm volatile
    ↓
C 中嵌入汇编

"r"(x)
    ↓
C变量作为寄存器输入

%0
    ↓
第0个 GCC 操作数

satp
    ↓
当前地址空间/页表的关键寄存器

csrw
    ↓
向 RISC-V CSR 写值

sfence.vma
    ↓
同步虚拟地址转换状态
```

这些知识足以看懂 xv6 中：

```c
w_satp(MAKE_SATP(...));
sfence_vma();
```

以及后续 kernel page table 实验中的页表切换代码。
