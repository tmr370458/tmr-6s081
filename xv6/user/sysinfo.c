#include "kernel/types.h"
#include "kernel/sysinfo.h"
#include "user/user.h"


int
main()
{
  struct sysinfo info;


  sysinfo(&info);


  printf("free memory: %lu\n", info.freemem);
  printf("process num: %lu\n", info.nproc);


  exit(0);
}