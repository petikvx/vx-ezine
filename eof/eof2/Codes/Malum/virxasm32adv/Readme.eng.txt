
 ======================================================================
 ====================[ LENGTH-DISASSEMBLER ENGINE ]====================
 ====================[ VIRXASM32 ]=========[ v1.5 ]====================
 ====================[ WRITTEN BY MALUM  12.02.07 ]====================
 ======================================================================

 History of version
 v1.0 - first beta-release
 v1.1 - extended opcode bugfix, added 9A and EA
 v1.2 - added 67h prefix support
 v1.3 - added MOV EAX,[OFF] (release on next day after 1.2, excuse me :) )
 v1.4 - 67h prefix bugfixed, added F1 opcode
 v1.5 - added f6w /1 undoced opcode

 -----------
 Description
 -----------
 VirXasm32  is  a  little  length-disassembler  that maked mainly for using in
 different  computer  creatures.   But it can be effectively used in any other
 tasks.  Size  of  tool  is  only  333  bytes that's why it can't give bad for
 even the most little virus (I belive).    Also VirXasm can't identify invalid
 opcodes. Imho all length-disasms can't indentify many invalid opcodes (what's
 the sens to find UD2 if it is not used ussually).

 In pakage two edition of disasm presented. The first is A edition that have
 the data outside of the code and second is B edition were all data pushs in 
 the stack and there is only code that can be permutated.  Both editions are
 base-independence and can be used in any address space.

 Also one notice for mutation.  Because the structure of VirXasm very tied on
 opportunities of assembler commands  that's why the changes like dec->sub 1, 
 loop->dec/jnz will be fatal for disasm (this is the consequence of very hard
 optimization). So according-model go down, permutation and garbage rules :)

 ----------
 How to use
 ----------
 For asm  you must include file virxasm32a.inc (or virxasm32b.inc) to your source
 in place were you want see the code of disasm. Before calling of disasm register
 ESI must point to code.  After call VirXasm will return the length of command in
 EAX register and flag DF will be set to zero.
 For example:

  ...
  mov	esi, [ebx+code_start]
next_opcode:
  call	VirXasm32
  cmp	byte ptr [esi], 0e8h
  lea	esi, [esi+eax]
  jne	next_opcode
  call	random
  test	al, 1
  jz	next_opcode
  ...
  include inc\virxasm32b.inc
  ...

 In package there are three types of object-files  coff  (for Micro$oft C++),  omf (for
 Borland C++/Delphi)  and elf  (for GCC but now is not tested)  for HLL languages. Like
 in asm version there are two editions A and B.    In all objs one exported function is
 "VirXasm32" in C convension. Declaration of this function is in file "inc\virxasm32.h"

unsigned long __cdecl VirXasm32 (const void *pCode);

 For example:

#include <stdio.h>
#include "VirXasm32.h"
int main(void)
{
    unsigned long code,n,i;
    for (code=0x401000;code < 0x401a00;)  {
        printf("%08X:", code);
        n = VirXasm32((void*)code);
        for (i=0; i<n; i++)
               printf(" %02X", ((unsigned long) *((char*)code++))&0xff );
        printf("\n");
    }
    return 0;
}

 For the most lazy people there is one DLL in package (in one edition) with one exported
 function "VirXasm32" in C convension and there is LIB files for it in three different
 formats (for different compilers). For Delphi you must include unit UVirXasm32 from file
 UVirXasm32.pas for C you must include directive #pragma comment(lib,"virxasm32.lib")

 -------------------
 Contacts and thanks
 -------------------
 Special thanks to roy g biv for offers and fixing of all my stupid bugs :)
 Also thanks to Vechaslav Patkov for offer to make VirXasm more presentable.

 If you found bug mail me, please.
 If you have questions then mail me and I certainly will try to give answer.
 And I'm sorry I speak (write? :)) English not very well.
 (X) Malum 12.02.07 - malum@mail.ru

; =======[
; ==========================[
; ===============================================[



