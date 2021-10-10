# MMAN.H
.set	PROT_READ,	    0x1
.set	PROT_WRITE, 	0x2
.set	PROT_EXEC,	    0x4
.set	PROT_NONE,	    0x0
.set	MAP_SHARED,	    0x1
.set	MAP_PRIVATE,	0x2
.set	MAP_TYPE,	    0xf
.set	MAP_FIXED,	    0x10
.set	MAP_ANONYMOUS,	0x20

# DIRENT.H
.set    dirent,         0x0
.set    dirent.d_ino,   0x0
.set    dirent.d_off,   0x4
.set    dirent.d_reclen,0x8
.set    dirent.d_name,  0xa
.set    dirent_size,    0x109

# STAT.H
.set	stat,		    0x0
.set	stat.st_dev,	0x0
.set	stat.__pad1,    0x2
.set	stat.st_ino,    0x4
.set	stat.st_mode,   0x8
.set	stat.st_nlink,  0xa
.set	stat.uid,       0xc
.set	stat.gid,       0xe
.set	stat.rdev,      0x10
.set	stat.__pad2,    0x12
.set	stat.st_size,   0x14
.set	stat.st_blksize,0x18
.set	stat.st_blocks, 0x1c
.set	stat.st_atime,  0x20
.set	stat.__unused1, 0x24
.set	stat.st_mtime,  0x28
.set	stat.__unused2, 0x2a
.set	stat.st_ctime,  0x30
.set	stat.__unused3, 0x34
.set	stat.__unused4, 0x38
.set	stat.__unused5,	0x3c
.set    stat_size,      0x40

.set    S_IFMT,         0170000
.set    S_IFSOCK,       0140000
.set    S_IFLNK,        0120000
.set    S_IFREG,        0100000
.set    S_IFBLK,        0060000
.set    S_IFDIR,        0040000
.set    S_IFCHR,        0020000
.set    S_IFIFO,        0010000
.set    S_ISUID,        0004000
.set    S_ISGID,        0002000
.set    S_ISVTX,        0001000

.set    S_IRWXU,        00700
.set    S_IRUSR,        00400
.set    S_IWUSR,        00200
.set    S_IXUSR,        00100

.set    S_IRWXG,        00070
.set    S_IRGRP,        00040
.set    S_IWGRP,        00020
.set    S_IXGRP,        00010

.set    S_IRWXO,        00007
.set    S_IROTH,        00004
.set    S_IWOTH,        00002
.set    S_IXOTH,        00001


# MMAP MANPAGE
.set    mmap,           0x0
.set    mmap.start,     0x0
.set    mmap.length,    0x4    
.set    mmap.prot,      0x8
.set    mmap.flags,     0xc
.set    mmap.fd,        0x10
.set    mmap.offset,    0x14
.set    mmap_size,      0x18

# LOCKS.C
.set    SEEK_SET,       0x0
.set    SEEK_CUR,       0x1
.set    SEEK_END,       0x2

# UNKNOWN
.set    PAGE_SIZE,      0x1000

# FCNTL.H
.set    O_ACCMODE,      0003
.set    O_RDONLY,       00
.set    O_WRONLY,       01
.set    O_RDWR,         02
.set    O_CREAT,        0100
.set    O_EXCL,         0200
.set    O_NOCTTY,       0400
.set    O_TRUNC,        01000
.set    O_APPEND,       02000
.set    O_NONBLOCK,     04000
.set    O_NDELAY,       O_NONBLOCK
.set    O_SYNC,         010000
.set    FASYNC,         020000
.set    O_DIRECT,       040000
.set    O_LARGEFILE,    0100000
.set    O_DIRECTORY,    0200000
.set    O_NOFOLLOW,     0400000

# UTIME MANPAGE
.set    utimbuf,        0x0
.set    utimbuf.actime, 0x0
.set    utimbuf.modtime,0x4
.set    utimbuf_size,   0x8

# UNISTD.H
.set    __NR_exit,      1
.set    __NR_fork,      2
.set	__NR_read,	3
.set    __NR_write,     4
.set    __NR_open,      5
.set    __NR_close,     6
.set    __NR_waitpid,   7
.set    __NR_creat,     8
.set    __NR_link,      9
.set    __NR_unlink,    10
.set    __NR_execve,    11
.set    __NR_chdir,     12
.set    __NR_time,      13
.set    __NR_chmod,     15
.set	__NR_oldstat,	18
.set    __NR_lseek,     19
.set    __NR_utime,     30
.set	__NR_dup,	41
.set	__NR_getppid,	64
.set    __NR_mmap,      90
.set    __NR_munmap,    91
.set    __NR_ftruncate, 93
.set	__NR_socketcall,102
.set    __NR_stat,      106
.set    __NR_mprotect,  125
.set    __NR_getdents,  141
.set	__NR_getcwd,	183

# ELF.H
.set    Elf32_Ehdr,             0x0
.set    Elf32_Ehdr.e_ident,     0x0
.set    Elf32_Ehdr.e_type,      0x10
.set    Elf32_Ehdr.e_machine,   0x12
.set    Elf32_Ehdr.e_version,   0x14
.set    Elf32_Ehdr.e_entry,     0x18
.set    Elf32_Ehdr.e_phoff,     0x1c
.set    Elf32_Ehdr.e_shoff,     0x20
.set    Elf32_Ehdr.e_flags,     0x24
.set    Elf32_Ehdr.e_ehsize,    0x28
.set    Elf32_Ehdr.e_phentsize, 0x2a
.set    Elf32_Ehdr.e_phnum,     0x2c
.set    Elf32_Ehdr.e_shentsize, 0x2e
.set    Elf32_Ehdr.e_shnum,     0x30
.set    Elf32_Ehdr.e_shstrndx,  0x32
.set    Elf32_Ehdr_Size,        0x34

.set    Elf32_Phdr,             0x0
.set    Elf32_Phdr.p_type,      0x0
.set    Elf32_Phdr.p_offset,    0x4
.set    Elf32_Phdr.p_vaddr,     0x8
.set    Elf32_Phdr.p_paddr,     0xc
.set    Elf32_Phdr.p_filesz,    0x10
.set    Elf32_Phdr.p_memsz,     0x14
.set    Elf32_Phdr.p_flags,     0x18
.set    Elf32_Phdr.p_align,     0x1c
.set    Elf32_Phdr_size,        0x20

.set    Elf32_Shdr,             0x0
.set    Elf32_Shdr.sh_name,     0x0        
.set    Elf32_Shdr.sh_type,     0x4        
.set    Elf32_Shdr.sh_flags,    0x8         
.set    Elf32_Shdr.sh_addr,     0xc        
.set    Elf32_Shdr.sh_offset,   0x10          
.set    Elf32_Shdr.sh_size,     0x14        
.set    Elf32_Shdr.sh_link,     0x18        
.set    Elf32_Shdr.sh_info,     0x1c        
.set    Elf32_Shdr.sh_addralign,0x20            
.set    Elf32_Shdr.sh_entsize,  0x24
.set    Elf32_Shdr_size,        0x28

.set    EI_MAG0,                0x0
.set    EI_MAG1,                0x1
.set    EI_MAG2,                0x2
.set    EI_MAG3,                0x3
.set    EI_CLASS,               0x4
.set    EI_DATA,                0x5
.set    EI_VERSION,             0x6
.set    EI_PAD,                 0x7

.set    ELFMAG,                 0x464c457f

.set    ELFCLASSNONE,           0x0
.set    ELFCLASS32,             0x1
.set    ELFCLASS64,             0x2
.set    ELFCLASSNUM,            0x3

.set    ELFDATANONE,            0x0
.set    ELFDATA2LSB,            0x1
.set    ELFDATA2MSB,            0x2

.set    EV_NONE,                0x0
.set    EV_CURRENT,             0x1
.set    EV_NUM,                 0x2

.set    PT_LOAD,                0x1
.set    ET_EXEC,                0x2
.set    EM_386,                 0x3
.set	SHT_NOBITS,		0x8

.set    PF_R,           0x4
.set    PF_W,           0x2
.set    PF_X,           0x1

# UNKNOWN
.set	MAXPATHLEN,	1024

# SOCKET.H
.set    AF_LOCAL,               1
.set    PF_LOCAL,               1
.set    AF_INET,                2
.set    PF_INET,                2

.set    SYS_SOCKETPAIR,         8
.set    SYS_SHUTDOWN,           13
.set    SYS_SOCKET,             1
.set    SYS_BIND,               2
.set    SYS_CONNECT,            3
.set    SYS_LISTEN,             4
.set    SYS_ACCEPT,             5

.set    SHUT_RD,                0
.set    SHUT_WR,                1
.set    SHUT_RDWR,              2

.set    SOCK_STREAM,            1
.set    SOCK_DGRAM,             2
.set    SOCK_RAW,               3
.set    SOCK_RDM,               4
.set    SOCK_SEOPACKET,         5
.set    SOCK_PACKET,            10

