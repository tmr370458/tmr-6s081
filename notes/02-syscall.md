# xv6 系统调用流程笔记

## 以 fork() 为例

用户程序调用：

```c
fork();
```

实际上经历以下过程：

---

## 1. 用户态接口声明

文件：

```
user/user.h
```

里面：

```c
int fork(void);
```

作用：

告诉 C 编译器：

> 用户程序存在一个叫 fork 的函数。

但是这里**只有声明，没有实现**。

---

## 2. 生成用户态汇编接口

文件：

```
user/usys.pl
```

这是 Perl 脚本，用于自动生成：

```
user/usys.S
```

例如生成：

```asm
fork:
    li a7, SYS_fork
    ecall
    ret
```

作用：

提供用户态到内核态的桥梁。

主要完成：

1. 将系统调用编号写入寄存器：

```
a7 = SYS_fork
```

2. 执行：

```
ecall
```

触发 CPU 从用户态进入内核态。

---

# 3. ecall触发 Trap（陷入）

执行：

```asm
ecall
```

后：

CPU发生：

```
用户态
  |
  | ecall
  ↓
内核态
```

这个过程叫：

> trap（陷入）

CPU会自动完成：

### 保存用户程序状态

例如：

* 当前 PC
* 寄存器状态

保存到：

```
trapframe
```

---

### 切换权限

从：

```
U-mode
```

切换到：

```
S-mode
```

（RISC-V中用户态 → 监督者态）

---

### 跳转到内核入口

进入：

```
kernel/trampoline.S
```

然后：

```
usertrap()
```

---

# 4. Trap进入系统调用处理

文件：

```
kernel/trap.c
```

函数：

```c
usertrap()
```

发现：

这是一个系统调用：

```c
if(r_scause()==8)
```

于是调用：

```c
syscall();
```

---

# 5. syscall 分发系统调用

文件：

```
kernel/syscall.c
```

函数：

```c
syscall()
```

首先读取：

```c
num = p->trapframe->a7;
```

因为之前：

```asm
li a7,SYS_fork
```

所以现在：

```
a7 = fork对应编号
```

---

然后通过系统调用表：

```c
static uint64 (*syscalls[])(void)
```

找到对应函数：

例如：

```c
[SYS_fork] sys_fork,
```

于是：

```
SYS_fork
    |
    ↓
sys_fork()
```

---

# 6. 内核实现系统调用

文件：

```
kernel/sysproc.c
```

函数：

```c
sys_fork()
```

它会调用：

```
kernel/proc.c
```

中的：

```c
fork()
```

真正创建进程。

---

# 7. 返回值传递

系统调用返回：

```
sys_fork()
        |
        ↓
syscall()
```

然后：

```c
p->trapframe->a0 = return_value;
```

因为 RISC-V ABI规定：

```
a0
```

用于保存函数返回值。

---

之后：

```
内核态
 |
 sret
 |
 ↓
用户态
```

返回：

```c
fork()
```

用户程序得到返回值：

* 子进程：

```
0
```

* 父进程：

```
子进程pid
```

---


# 一句话总结

xv6 的系统调用通过用户态接口、汇编桩和 ecall 进入内核。用户程序调用 fork 时，实际调用的是 usys.S 中生成的汇编函数，该函数将系统调用编号写入 a7 寄存器并触发 trap。内核通过 trap 机制进入 syscall()，读取 a7 中的编号，在系统调用表中找到对应的内核函数 sys_fork() 执行，并将返回值写入 a0 返回用户态。
