#include "sysinfo.h"
#include "kernel/defs.h"

//需要实现
//struct sysinfo info;
//sysinfo(&info);
uint64
sysinfo(void){
      uint64 addr;

  if(argaddr(0, &addr) < 0){
    return -1;
  }
    

  struct sysinfo info;

  info.freemem = freemem();
  info.nproc = nproc();

  if(copyout(myproc()->pagetable, addr, (char *)&info, sizeof(info)) < 0){
    return -1;
  }
    

    return 0;

}
