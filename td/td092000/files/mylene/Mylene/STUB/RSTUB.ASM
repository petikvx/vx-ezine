.model tiny
.code
start:
   db 'MZ'
   dw 50h
   dw 2h
   dw 0
   dw 40h/10h
   dw 0Fh
   dw -1
   dw 0
   dw 0B8h
   dw 0
   dw 0
   dw 0
   dw 0
   org 18h
   dw 40h, 1Ah
   org 40h-3 
   db 1,0,0
   org 40h
include stub.asb

end_stub:
end start
