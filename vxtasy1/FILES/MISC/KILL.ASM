.586p
.model flat, stdcall

extrn ExitProcess:proc
extrn MessageBoxA:proc

.data
a db "Kill cargo in memo...",0
b db "Press ok to Kill cargo in memo...",0

.code

start:
        push 1000h
        push offset a
        push offset b
        push 0
        call MessageBoxA
        push 0
        call ExitProcess

end start
end

