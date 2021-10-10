
VxDcall                 macro   VxD, Service
                        db      0CDh
                        db      020h
                        dw      Service
                        dw      VxD
                        endm

VMMcall                 macro   Service
                        VxDcall VMM, Service
                        endm

VXDLDR                  equ     0027h
GetDeviceList           equ     0005h

VMM                     equ     0001h
PageQuery               equ     0134h
