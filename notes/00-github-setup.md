# 配置 6.S081 学习仓库记录

日期：2026-08-15

## 目标

为 MIT 6.S081 Operating System Engineering 课程建立个人学习仓库，用于保存：

- xv6 源码
- 实验代码
- 学习笔记
- 实验过程记录

仓库地址：

https://github.com/tmr370458/tmr-6s081

---

# 1. Git 环境配置

## 安装 Git

确认 Git 安装：

```bash
git --version
```

输出：

```
git version 2.53.0.windows.3
```

说明 Git 已正常安装。

## 配置 Git 用户信息

查看配置：

```bash
git config --global --list
```

配置：

```
user.name=tmr
user.email=tmr370458@gmail.com
```

---

# 2. 创建本地仓库

在 E 盘创建项目目录：

```cmd
E:
mkdir tmr-6s081
cd tmr-6s081
```

初始化 Git：

```bash
git init
```

创建第一个 README.md：

```text
README.md
```

提交：

```bash
git add README.md

git commit -m "docs: add initial README"
```

---

# 3. 连接 GitHub

添加远程仓库：

```bash
git remote add origin <github repository url>
```

检查：

```bash
git remote -v
```

过程中遇到仓库名称修改问题。

最终确定仓库：

```
tmr-6s081
```

远程地址：

```
https://github.com/tmr370458/tmr-6s081.git
```

修改 remote：

```bash
git remote set-url origin https://github.com/tmr370458/tmr-6s081.git
```

---

# 4. 第一次 push

执行：

```bash
git push -u origin master
```

遇到：

```
fatal: unable to access github
The requested URL returned error: 502
```

原因：

Git 无法使用浏览器代理访问 GitHub。

浏览器可以打开 GitHub，但是 Git 命令没有走 Clash 代理。

---

# 5. 配置 Clash 代理

使用 Clash for Windows。

确认代理端口：

```
127.0.0.1:56685
```

给 Git 设置代理：

```bash
git config --global http.proxy http://127.0.0.1:56685

git config --global https.proxy http://127.0.0.1:56685
```

再次 push：

```bash
git push -u origin master
```

成功。

---

# 6. 添加 xv6

已有 xv6 源码：

```
xv6/
├── kernel
├── user
├── mkfs
└── Makefile
```

确认：

* 没有嵌套 `.git`
* 可以在 WSL 中运行 QEMU

运行环境：

```
Windows
    |
    └── WSL Ubuntu
            |
            └── xv6
                    |
                    └── make qemu
```

成功启动 xv6。

---

# 7. 仓库结构设计

最终设计：

```
tmr-6s081

├── README.md

├── xv6
│   ├── kernel
│   ├── user
│   └── Makefile
│
├── notes
│
├── labs
│
└── experiments
```

目录用途：

## xv6

保存 MIT 6.S081 使用的 xv6-riscv 源码。

## notes

记录学习笔记：

例如：

* xv6启动流程
* 系统调用
* 虚拟内存
* 进程管理

## labs

保存实验记录。

## experiments

保存自己进行的小实验。

---

# 8. 学到的 Git 知识

## 查看状态

```bash
git status
```

## 添加文件

```bash
git add .
```

## 提交

```bash
git commit -m "message"
```

## 上传

```bash
git push
```

## 查看远程仓库

```bash
git remote -v
```

## 修改远程地址

```bash
git remote set-url origin <url>
```

---

# 总结

今天完成：

* Git 安装与配置
* 创建 GitHub 仓库
* 完成本地仓库初始化
* 学会 commit / push 工作流
* 解决 GitHub 网络代理问题
* 配置 WSL + QEMU 环境
* 成功运行 xv6
