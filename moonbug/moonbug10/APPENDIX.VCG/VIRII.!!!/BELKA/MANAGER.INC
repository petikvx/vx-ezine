;(c) RedArc
_Manager:
         call _M@1
_M@1:
         pop si
         sub si,3
         mov dx,word ptr cs:[bp-3]
         mov di,bp
         add di,dx
         add di,8
         mov cx,si

         mov si,bp
         dec si
         mov al,byte ptr cs:[si]
         cmp al,0
         je _EndCount
         dec al
         mov byte ptr cs:[si],al
_EndCount:
         call _SaveFileVCG
         ret
