;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;                                                                                                   
;                                                                                                      	 ;
;                                                                                                    	 ;
;      xxxxxxxxxxx      xxxxxxxx     xxxx    xxxx     xxxxxxxxxx          xxxxxxxx      xxxxxxxxx        ;  
;      xxxxxxxxxxxx    xxxx  xxxx    xxxx    xxxx    xxxxxxxxxxx         xxxxxxxxxx    xxxxxxxxxxx       ; 
;      xxxx    xxxx   xxxx    xxxx   xxxxx   xxxx   xxxx    xxxx         xxx    xxxx   xxx    xxxx       ;    
;      xxxx    xxxx   xxxx    xxxx   xxxxxx  xxxx   xxxx                        xxxx          xxxx       ;   
;      xxxx    xxxx   xxxx    xxxx   xxxxxxx xxxx   xxxx                   xxxxxxxx     xxxxxxxxxx       ;   
;      xxxxxxxxxxx    xxxx xx xxxx   xxxx xxxxxxx   xxxx                   xxxxxxxx    xxxxxxxxxx        ;  
;      xxxxxxxxxxxx   xxxx xx xxxx   xxxx  xxxxxx   xxxx   xxxxx                xxxx   xxxx              ;     
;      xxxx    xxxx   xxxx    xxxx   xxxx   xxxxx   xxxx    xxxx                xxxx   xxxx    xxx       ;   
;      xxxx    xxxx   xxxx    xxxx   xxxx    xxxx    xxxxxxxxxxx         xxxxxxxxxx    xxxxxxxxxxx       ;   
;      xxxx    xxxx   xxxx    xxxx   xxxx    xxxx     xxxxxxxxxx         xxxxxxxxx     xxxxxxxxxxx       ;   
;																										 ;
;																										 ; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;																										 ;
;								RAndom Numbers Generator 											 	 ; 
;																										 ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;																										 ;
;										:)!																 ;
;																										 ; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;																										 ;
;										RANG32														 	 ;
;							  ????????? ????????? ????? (???)  											 ;
;																										 ;
;																										 ;
;???? (stdcall: DWORD RANG32(DWORD N)):																	 ;
;	N	-	????? (N). ????? ?????????? ????? ?????????? ????? ? ????????? [0..N-1] 					 ;
;?????:																									 ;
;	EAX	-	????????? ????? ? ????????? [0..N-1] 														 ; 
;																										 ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;         
;																										 ;
;										y0p!															 ;
;																										 ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;																										 ;
;									  	????															 ;
;																										 ;
;(+) ?????????????????																					 ;
;(+) ????? ? ?????????????																				 ;
;(+) ?? ?????????? WinApi'??? 																			 ;
;(+) ????? ??? ???????																					 ; 
;																										 ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; 
;																										 ;
;									?????????????: 														 ;
;																										 ;
;1) ???????????:																						 ;
;		rang32.asm																						 ;
;2) ????? (?????? stdcall):																				 ;
;		push	5				;?????? ? ???? ?????													 ;
;		call	RANG32			;???????? ??? -> ? EAX ????? ?????? ????? ???????? [0..5-1]				 ;
;																										 ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;v1.0.2                                                                                                        



																		;m1x
																		;pr0mix@mail.ru
                                       									;EOF 
                                                                                                                                                                                          
                                                                                   

                                                                                                                                                   								                          
RANG32:                                                                            
	pushad																;????????? ????????                                                                     
	mov		ecx, dword ptr [esp + 24h]									;ecx=?????, ??? ???????? ? ?????
	db		0fh, 31h      					             
	imul	eax, eax, 1664525											;???? ?????? ?????????? ??? ?????????                                                   
	add		eax, 1013904223												;????? ?????????? ????? 
	imul	eax, dword ptr [esp+32]
	;add		eax, edx
	;adc		eax, esp 
	rcr		eax, 16                                  
	xor		edx, edx 	
	mul		ecx															;mul ????????? ??? div 
	mov		dword ptr [esp + 1Ch], edx                                            
	popad                                                                      
	ret		04
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;????? ??????? RANG32 																					       
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 
 