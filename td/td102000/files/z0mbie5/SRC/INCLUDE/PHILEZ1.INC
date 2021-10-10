
da_next                 macro   x, lbl
                        local   __ll
                        downgrade __ll

                        xor     eax, (x) xor (_last_)
                        jz      lbl
                        _last_  = x

__ll:                   endm

da_first                macro   x, lbl
                        _last_  = 0
                        da_next x, lbl
                        endm

                        da_first -'don', __kill ; NOD*.*
                        da_next  -'wrd', __kill ; DRW*.*
                        da_next  -'pva', __kill ; AVP*.*
                        da_next  -'ida', __kill ; ADI*.*
                        da_next  -'ips', __kill ; SPI*.*
                        da_next  -'p-f', __kill ; F-P*.*
                        da_next  -'riv', __kill ; VIR*.*
                        da_next  -'eih', __kill ; HIE*.*
