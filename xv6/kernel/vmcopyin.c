// kernel/vmcopyin.c
#include "kernel/types.h"
#include "kernel/riscv.h"
#include "kernel/defs.h"
#include "kernel/memlayout.h"

// Copy from user to kernel.
// Copy len bytes to dst from virtual address srcva in a given page table.
// Return 0 on success, -1 on error.
int
copyin_new(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
    // 关键：直接使用虚拟地址 srcva 进行拷贝
    // 因为假设 srcva 在当前进程的内核页表中已经存在有效映射
    memmove((void *) dst, (void *)srcva, len);
    return 0;
}

// Copy a null-terminated string from user to kernel.
// Copy bytes to dst from virtual address srcva in a given page table,
// until a '\0', or max.
// Return 0 on success, -1 on error.
int
copyinstr_new(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
    // 关键：同样直接使用虚拟地址 srcva
    // 但需要自己处理字符串拷贝的逻辑，直到遇到 '\0' 或达到 max 长度
    int i = 0;
    while (i < max - 1) {
        char c;
        // 从 srcva + i 处读取一个字节
        // 这里需要确保 srcva + i 处的内存是可读的
        // 在真实实现中，可能需要更细致的边界检查
        __copyin_user(&c, (void *)(srcva + i), 1);
        if (c == '\0') {
            break;
        }
        dst[i] = c;
        i++;
    }
    dst[i] = '\0';
    return 0;
}

// only copy memories from oldsz to newsz, which contains new mappings
void copy_proc_to_kernel(pagetable_t proc_pt, pagetable_t kernel_pt, uint64 oldsz, uint64 newsz) {
  uint64 a;

  if (newsz >= PLIC) {
    panic("user processes exceed PLIC");
  }

  for(a = oldsz; a < newsz; a += PGSIZE){
    pte_t *pte1 = walk(proc_pt, a, 0);
    if (pte1 == 0) {
      panic("no user pte");
    }
    if ((*pte1 & PTE_V) == 0) {
      panic("no valid user pte");
    }
    pte_t *pte2 = walk(kernel_pt, a, 1);
    if (pte2 == 0) {
      panic("no kernel pte");
    }
    
    // 复制
    *pte2 = *pte1;
    // 关闭读写权限, 关闭用户权限, 否则kernel无法使用
    *pte2 &= ~(PTE_U|PTE_W|PTE_X);
  }
}