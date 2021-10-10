; (c) Reminder (1997) 

.model tiny
.code
.startup
@0:	mov ax,1
jmp 		@1
@2:	mov ax,3
call 		@3
@4:	mov ax,5
call 	 	@5
@6:	mov ax,7
call 	 	@7
@1:	mov ax,2
call 	 	@2
@3:	mov ax,4
jz 		@4
@5:	mov ax,6
call 		@6
@7:	mov ax,8
ret
end
