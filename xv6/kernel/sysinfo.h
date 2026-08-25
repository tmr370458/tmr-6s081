#include "kernel/types.h"


struct sysinfo {
  uint64 freemem; //当前系统空闲内存大小
  uint64 nproc;  //当前系统正在使用的进程数量
};