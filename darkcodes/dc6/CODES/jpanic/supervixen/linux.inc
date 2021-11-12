/* linux.inc for RaspberryPi.SuperVixen virus by JPanic, Australia, 2014. */
/* see supervixen.s for more details. */

.equ MAX_PATH, 256

.equ stdout,1

/* syscalls */
.equ syscall_exit,1
.equ syscall_read,3
.equ syscall_write,4
.equ syscall_open,5
.equ syscall_close,6
.equ syscall_execve,11
.equ syscall_fork,2
.equ syscall_mkdir,39
.equ syscall_setuid,23
.equ syscall_getuid,24
.equ syscall_geteuid,49
.equ syscall_chmod,15
.equ syscall_wait4,114
.equ syscall_pread64,180
.equ syscall_pwrite64,181
.equ syscall_getdents,141
.equ syscall_stat,106
.equ syscall_utimes,269
.equ syscall_gettimeofday,78
.equ syscall_getdents,141
.equ syscall_mmap2,192
.equ syscall_munmap,91
.equ syscall_exit_group,248
.equ syscall_lseek,19
.equ syscall_chdir,12
.equ syscall_readlink,85
.equ syscall_chown,182

/* open flags */
.equ O_RDONLY,	0x00000000
.equ O_WRONLY,	0x00000001
.equ O_RDWR,	0x00000002
.equ O_CREAT,	0x00000040
.equ O_EXCL,	0x00000080
.equ O_NOCTTY,	0x00000100
.equ O_TRUNC,	0x00000200
.equ O_APPEND,	0x00000400

/* file modes (permissions) */
.equ S_IRWXU,		0x1C0
.equ S_IRUSR,		0x100
.equ S_IWUSR,		0x080
.equ S_IXUSR,		0x040
.equ S_IRWXG,		0x038
.equ S_IRGRP,		0x020
.equ S_IWGRP,		0x010
.equ S_IXGRP,		0x008
.equ S_IRWXO,		0x007
.equ S_IROTH,		0x004
.equ S_IWOTH,		0x002
.equ S_IXOTH,		0x001
.equ S_ISUID,		04000

.equ S_IFREG,		0100000

/* mmap */
.equ PROT_READ, 	0x00000001
.equ PROT_WRITE, 	0x00000002

.equ MAP_PRIVATE,	0x00000002
.equ MAP_ANONYMOUS,	0x00000020

.equ WNOHANG,		0x00000001

/* linux_dirent */
.equ d_ino,		0
.equ d_off,		4
.equ d_reclen,		8
.equ d_name,		10

/* stat */	
.equ st_dev,		0
.equ st_ino,		4
.equ st_mode,		8
.equ st_nlink,		10
.equ st_uid,		12
.equ st_gid,		14
.equ st_rdev,		16
.equ st_size,		20
.equ st_blksize,	24
.equ st_blocks,		28
.equ st_atime,		32
.equ st_atime_nsec,	36
.equ st_mtime,		40
.equ st_mtime_nsec,	44
.equ st_ctime,		48
.equ st_ctime_nsec,	52
.equ st_unused4,	56	
.equ st_unused5,	60
.equ stat_size,		64
