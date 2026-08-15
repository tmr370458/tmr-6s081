# C 项目编译、链接与 Makefile 笔记

日期：2026-08-15


包含

- c文件编译流程
- pl文件含义
- makefile文件解读

---

# 1. C 文件类型

## .c

C 源代码文件。

例如：

```c
int add(int a,int b)
{
    return a+b;
}
```

---

## .h

头文件（header）。

主要存放：

* 函数声明
* 宏定义
* 类型定义

例如：

```c
int add(int a,int b);
```

作用：

告诉编译器：

"这个函数存在，但是实现在哪里不用管。"

---

`.h` 和 `.c` 文件名不要求相同。

例如：

```
add.h

hello.c
```

也可以：

```
add.h
add.c
```

只是通常为了方便管理而保持一致。

---

# 2. C 编译流程

一个 C 程序：

```
.c
 |
 | 预处理
 ↓
.i
 |
 | 编译
 ↓
.s
 |
 | 汇编
 ↓
.o
 |
 | 链接
 ↓
可执行文件
```

---

# 3. .i 文件

预处理后的 C 文件。

生成：

```bash
gcc -E main.c -o main.i
```

主要处理：

* #include
* #define
* 条件编译

例如：

```c
#include<stdio.h>
```

会展开成 stdio.h 中的内容。

此时仍然是 C 代码。

---

# 4. .s 文件

汇编代码文件。

生成：

```bash
gcc -S main.i
```

作用：

把：

```
C语言
```

转换为：

```
汇编语言
```

例如：

C：

```c
return a+b;
```

可能变成：

```asm
add a0,a0,a1
ret
```

---

# 5. .o 文件

目标文件（object file）。

生成：

```bash
gcc -c main.s
```

或者：

```bash
gcc -c main.c
```

里面包含：

* 机器码
* 符号表
* 重定位信息

.o 不能直接运行。

它等待链接。

---

# 6. 链接（Link）

多个 .o 文件组合成最终程序。

例如：

```
main.c
   |
   ↓
main.o


add.c
   |
   ↓
add.o
```

链接：

```
main.o + add.o

        ↓

    program
```

---

## .o 如何找到函数实现？

不是 `.o` 自己寻找。

是链接器（linker）寻找。

例如：

main.o：

```
需要:
add()
```

add.o：

```
提供:
add()
```

链接器：

```
main.o
 +
add.o

↓

program
```

如果找不到：

```
undefined reference to add
```

---

# 7. 声明、定义、链接

## 声明

告诉编译器函数存在：

```c
int add(int,int);
```

通常放在：

```
.h
```

---

## 定义

真正实现：

```c
int add(int a,int b)
{
    return a+b;
}
```

通常放在：

```
.c
```

---

## 链接

把：

```
调用者

+

实现者
```

连接起来。

---

# 8. 为什么需要 .h？

理论上：

可以直接在 .c 中声明：

```c
int add(int,int);
```

但是大型项目会出现重复。

.h 的作用：

## 统一接口

多个文件：

```
a.c
b.c
c.c
```

都：

```c
#include "add.h"
```

不用每个文件重复写声明。

---

## 分离接口和实现

例如：

```
stdio.h
```

提供：

```c
printf()
scanf()
```

但是用户不需要知道 printf.c 如何实现。

---

# 9. .pl 文件

`.pl` 是 Perl 脚本文件。

Perl 不是 C。

它是一种脚本语言。

作用：

自动生成代码。

---

xv6 中：

```
usys.pl
```

里面：

```perl
entry("fork");
entry("exit");
entry("wait");
```

运行：

```bash
perl usys.pl > usys.S
```

生成：

```
usys.S
```

---

usys.pl 的意义：

不是编译 C。

而是：

```
系统调用列表

        ↓

自动生成汇编入口
```

避免手写大量重复代码。

---

# 10. xv6 中 fork 的编译关系

用户程序：

```
user/sh.c
```

调用：

```
fork()
```

但是：

user.h：

```c
int fork();
```

只有声明。

生成：

```
usys.pl

 ↓

usys.S

 ↓

usys.o
```

里面提供：

```asm
fork:
    li a7,SYS_fork
    ecall
    ret
```

链接：

```
sh.o

+

usys.o

↓

sh
```

运行时：

```
用户 fork()

↓

usys.S

↓

ecall

↓

kernel

↓

sys_fork()

↓

proc.c fork()
```

---

# 11. Makefile

Makefile 是描述编译流程的文件。

基本格式：

```makefile
目标: 依赖
	命令
```

例如：

```makefile
hello: hello.c
	gcc hello.c -o hello
```

意思：

生成 hello，需要 hello.c。

---

# 12. Makefile 的作用

大型项目：

```
很多 .c

↓

很多 .o

↓

程序
```

不可能手动输入所有命令。

Makefile 负责：

* 管理依赖
* 自动编译
* 增量编译

---

# 13. xv6 编译流程

xv6：

```
kernel/*.c

↓

kernel/*.o

↓

kernel/kernel


user/*.c

↓

user/*.o

↓

用户程序


用户程序

↓

mkfs

↓

fs.img


kernel/kernel

+

fs.img

↓

QEMU

↓

xv6
```

---

# 总结

C 项目核心关系：

```
.h
 |
 | 声明接口
 ↓

.c
 |
 | 实现功能
 ↓

.o
 |
 | 编译后的目标文件
 ↓

linker
 |
 ↓

可执行文件
```

辅助工具：

```
.pl
 |
 | 自动生成代码
 ↓
.s


Makefile
 |
 | 管理整个构建过程
 ↓
自动生成程序
```
