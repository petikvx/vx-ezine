Randomize Proc Near                       ; random nr. generator initializer
       Push cx dx                         ; save them
       Xor ah,ah                          ; ah = 0
       Int 1Ah                            ; get date/time
       Mov [rand_seed], dx                ; and save it in the seed
       Xchg ch,cl                         ; make some calculations
       Add [rand_seed_2], cx              ; and generate the second seed
       Pop dx cx                          ; and now pop these
       Ret                                ; and go away
Randomize Endp                            ;
                                          ;
Random Proc Near                          ; The Random Number Generator
       Push cx                            ;
       Push ax                            ;
       In al,40h                          ; get a random
       Sub ax, [rand_seed]                ; substract it from seed 1
       Db 35h                             ; Xor Ax by seed 2
rand_seed_2 Dw 0                          ;
       Inc ax                             ; increment ax
       Add [rand_seed], ax                ; and create new random seed
       Call Modulo                        ; boundaries
       Pop cx cx                          ;
       Ret                                ; and return
Random Endp                               ;
                                          ;
Modulo Proc Near                          ; this routine returns Ax modulo Cx.
       Push dx                            ; It's used to put AX between 0 and
       Xor dx, dx                         ; CX. DX is preserved.
       Div cx                             ;
       Xchg ax, dx                        ;
       Pop dx                             ;
       Ret                                ;
Modulo Endp                               ;

rand_seed dw 0