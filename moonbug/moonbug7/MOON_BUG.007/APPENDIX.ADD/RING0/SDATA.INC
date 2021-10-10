
sdata                   segment use32 at 666
sdata_start:

base                    dd      ?

gdtr                    label   fword
gdt_limit               dw      ?
gdt_base                dd      ?

idtr                    label   fword
idt_limit               dw      ?
idt_base                dd      ?

selector                dd      ?

gdt_descriptor_saved    dq      ?
idt_descriptor_saved    dq      ?

r0_idtr                 label   fword
r0_idt_limit            dw      ?
r0_idt_base             dd      ?

shadow_base             dd      ?

sdata_end:
sdata_size              equ     sdata_end-sdata_start
                        ends
onstack                 equ     < [ebp] - sdata_start >

