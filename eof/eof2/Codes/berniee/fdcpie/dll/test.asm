;Things To Be kept in mind:
;Fakedminded dll companion Patch in Engine v1.0 beta (FDCPIE)
;This Engine provided as it is to help coders to in(j/f)ect their dll functions(written)
;to the exectuable file, The Engine didnt get thru alot of testing so its version's name imply "beta"
;This code is based on the skeleton of my PE appender virus engine,thats why alarm maybe triggered
;by some avers.
;You can still be able to modify/Use/etc under one condition of that you mention the author of this Engine.
;contact me thru :ass-koder.de.vu [my site]-- eof-project.net [EOF-project's site]
;

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

      .486                      ; create 32 bit code
      .model flat, stdcall      ; 32 bit memory model
      option casemap :none      ; case sensitive 

;     include files
;     ~~~~~~~~~~~~~
      include \masm32\include\windows.inc
      include \masm32\include\masm32.inc
      include \masm32\include\gdi32.inc
      include \masm32\include\user32.inc
      include \masm32\include\kernel32.inc
      include \masm32\include\Comctl32.inc
      include \masm32\include\comdlg32.inc
      include \masm32\include\shell32.inc
      include \masm32\include\oleaut32.inc
      include \masm32\include\dialogs.inc
      include \masm32\macros\macros.asm     ; the macro file

;     libraries
;     ~~~~~~~~~
      includelib \masm32\lib\masm32.lib
      includelib \masm32\lib\gdi32.lib
      includelib \masm32\lib\user32.lib
      includelib \masm32\lib\kernel32.lib
      includelib \masm32\lib\Comctl32.lib
      includelib \masm32\lib\comdlg32.lib
      includelib \masm32\lib\shell32.lib
      includelib \masm32\lib\oleaut32.lib

    ; ----------------------------------------
    ; prototypes for local procedures go here
    ; ----------------------------------------

upload PROTO proc :DWORD

salsa PROTO PROC
      .data?
        hInstance dd ?

.data
Signature db "Win32 PE dll companion patche In Engine [FDCPIE] by fakedminded 07 ",0

.code

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

LibMain proc instance:DWORD,reason:DWORD,unused:DWORD 

    .if reason == DLL_PROCESS_ATTACH
      push instance
      pop hInstance
      mov eax, TRUE

    .elseif reason == DLL_PROCESS_DETACH

    .elseif reason == DLL_THREAD_ATTACH

    .elseif reason == DLL_THREAD_DETACH

    .endif

    ret

LibMain endp



.code

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл


  comment * -----------------------------------------------------
          You should add the procedures your DLL requires AFTER
          the LibMain procedure. For each procedure that you
          wish to EXPORT you must place its name in the "test.def"
          file so that the linker will know which procedures to
          put in the EXPORT table in the DLL. Use the following
          syntax AFTER the LIBRARY name on the 1st line.
          LIBRARY test
          EXPORTS YourProcName
          EXPORTS AnotherProcName
          ------------------------------------------------------- *
.data

code_file db "code.sss",0
.data?

f_mem dd ?
f_size dd ?
f_handle dd ?
buffer db 256 dup(?)
patchitup dd ?
code_size dd ?
tid dd ?
bwr dd ?


.data
shit db "The semen is seeded!",0

.code
testing_thread proc
invoke MessageBox,0,offset shit,offset Signature,0

ret
testing_thread endp

init_ proc

.code

mov edx,[esp+4]

mov patchitup,edx
mov edx,[esp+8]
mov code_size,edx
invoke CreateThread,0,0,offset testing_thread,0,0,offset tid
invoke CreateFile,offset code_file,80000000h,0,0,3,0,0
mov f_handle,eax
invoke GetFileSize,f_handle,0
mov f_size,eax

invoke GlobalAlloc,0,f_size
mov f_mem,eax
invoke ReadFile,f_handle,f_mem,f_size,offset bwr,0
invoke CloseHandle,f_handle
mov esi,f_mem
mov edi,patchitup
mov ecx,code_size
rep movsb



@@:
pop ecx
mov ecx,patchitup
jmp ecx

ret
init_ endp
end LibMain
