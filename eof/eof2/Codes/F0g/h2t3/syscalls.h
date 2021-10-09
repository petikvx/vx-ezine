/*

  From /usr/src/sys/kern/syscalls.master (FreeBSD 6.3-RELEAS).
  There are changes in 7.0 release, but it still works under
  7.0-RC3 without any changes.

*/ 

#define		EXIT		1
#define		FORK		2
#define		WRITE		4
#define		OPEN		5
#define		CLOSE		6
#define		CHMOD		15
#define		MUNMAP		73
#define		STAT		188
#define		FSTAT		189
#define		MMAP		197
#define		GETDENTS	272
