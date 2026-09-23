// Physical memory allocator, for user processes,
// kernel stacks, page-table pages,
// and pipe buffers. Allocates whole 4096-byte pages.

#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "riscv.h"
#include "defs.h"

void freerange(void *pa_start, void *pa_end);

extern char end[]; // first address after kernel.
                   // defined by kernel.ld.

struct run {
  struct run *next;
};

struct {
  struct spinlock lock;
  struct run *freelist;
} kmem[NCPU];// ch8.1

// ch6 begin
struct {
  struct spinlock lock;
  int refcnt[(PHYSTOP - KERNBASE) / PGSIZE];
} ref;
// ch6 end

void
kinit()
{
  // ch8.1 begin
  for(int i=0; i<NCPU; i++){
    char name[9] = {0};
    snprintf(name, 8, "kmem-%d", i);
    initlock(&kmem[i].lock, name);
  }
  // ch8.1 end

  // ch6 begin
  initlock(&ref.lock,"ref");
  // ch6 end

  freerange(end, (void *)PHYSTOP);

}

void
freerange(void *pa_start, void *pa_end)
{
  char *p;
  p = (char *)PGROUNDUP((uint64)pa_start);
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    // ch6 begin
    ref.refcnt[((uint64)p - KERNBASE) / PGSIZE] = 1;
    // ch6 end
    kfree(p);
}

// Free the page of physical memory pointed at by pa,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
  struct run *r;

  if (((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);

  // ch6 begin
  acquire(&ref.lock);
  if (ref.refcnt[((uint64)pa - KERNBASE)/ PGSIZE] <= 0)
    panic("kfree");
  ref.refcnt[((uint64)pa - KERNBASE) / PGSIZE]--;
  if(ref.refcnt[((uint64)pa - KERNBASE) / PGSIZE] > 0){ // judge free or not
    release(&ref.lock);
    return;
  }
  release(&ref.lock);
  // ch6 end
  
  r = (struct run *)pa;

  // ch8.1 begin
  push_off();
  int cpu = cpuid();

  acquire(&kmem[cpu].lock);
  r->next = kmem[cpu].freelist;
  kmem[cpu].freelist = r;
  release(&kmem[cpu].lock);
  pop_off();
  // ch8.1 end
}

// ch8.1 begin
// steal pages from other cpu's freelist when needing
struct run* 
ksteal(int cpu)
{
  struct run *r;

  for(int i = 1; i < NCPU; i++){ // try stealing from next one
    int next_cpu = (cpu + i) % NCPU;
    acquire(&kmem[next_cpu].lock);
    r = kmem[next_cpu].freelist;
    if(r){
      kmem[next_cpu].freelist = r->next;
    }
    release(&kmem[next_cpu].lock);

    if(r)
      return r;
  }
  return 0;
}
// ch8.1 end

// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
  struct run *r ;
  // ch8.1 begin
  push_off();
  int cpu = cpuid();

  acquire(&kmem[cpu].lock);
  r = kmem[cpu].freelist;//get the 1st page from the freelist
  if (r)
    kmem[cpu].freelist = r->next;  //forward shift
  release(&kmem[cpu].lock);

  if(r == 0){
    r = ksteal(cpu);
  }

  if (r)  
    memset((char *)r, 5, PGSIZE); // fill with junk

    // ch6 begin
    acquire(&ref.lock);
    ref.refcnt[((uint64)r - KERNBASE)/ PGSIZE] = 1;
    release(&ref.lock);
    // ch6 end

  pop_off();
  // ch8.1 end
  return (void *)r;
}

uint64
freemem(void){
  uint64 count=0;
  struct run *r;
  
  acquire(&kmem.lock);
  r = kmem.freelist;
  while(r)
  {
    r = r->next;
    count++;
  }
  release(&kmem.lock);


  return count * PGSIZE;
}

uint64
nproc(void)
{
  struct proc *p;
  uint64 count = 0;


  for(p = proc; p < &proc[NPROC]; p++)
  {
    acquire(&p->lock);


    if(p->state != UNUSED)
      count++;


    release(&p->lock);
  }


  return count;
}

// ch6 begin
void
kaddref(uint64 pa)
{
  acquire(&ref.lock);
  ref.refcnt[(pa-KERNBASE)/PGSIZE]++;
  release(&ref.lock);
}

int
kref(uint64 pa)
{
  int cnt;

  acquire(&ref.lock);
  cnt = ref.refcnt[(pa-KERNBASE)/PGSIZE];
  release(&ref.lock);

  return cnt;
}
// ch6 end