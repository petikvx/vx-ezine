.386
.model flat, stdcall

extrn _main :proc
extrn ExitProcess :proc

.code

start:
	call _main

	push 0
	call ExitProcess
end start
