
;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
;
; Shall sort
;
; ESI = bufer
; ECX = element count
;
;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
shsort:
		pusha

		mov edi,ecx				; h=n/2
		shr edi,1				;

		dec ecx					; bound = n-1
		jz shsort_exit

;------------------------------------------------------------------------------
shsort_h:
		mov edx,edi				; EDX=i  =h

;------------------------------------------------------------------------------
shsort_i:
		mov ebx,edx                             ; EBX=j  =i-h
		sub ebx,edi				;

;------------------------------------------------------------------------------
shsort_j:
                lea ebp,[ebx+edi]			; 
		lea ebp,[esi+ebp*4]			; m[j+h]
		mov eax,[ebp]                           ;

		cmp eax,[esi+ebx*4]			; m[j+h]<m[j] ?
		jae shsort_nexti

		mov eax,[ebp]				;
		xchg [esi+ebx*4],eax			; m[j]=m[j-h] t=m[j]
		mov [ebp],eax				; m[j-h]=t

shsort_nextj:
		sub ebx,edi
 		jns shsort_j

;------------------------------------------------------------------------------

shsort_nexti:
		inc edx
		cmp edx,ecx
		jna shsort_i

;------------------------------------------------------------------------------

		shr edi,1
		jnz shsort_h
shsort_exit:
		popa
		ret