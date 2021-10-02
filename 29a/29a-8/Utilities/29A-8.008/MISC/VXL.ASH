
dd_hash                 macro   func
                        hash = 0
                        irpc    c, <func>
                        hash = ((hash shl 7) and 0FFFFFFFFh) or (hash shr (32-7))
                        hash = hash xor "&c"
                        endm
                        dd      hash
                        endm

callK32                 macro   func
                        call    callbyhash_k32
                        dd_hash func
                        endm

callANY                 macro   func
                        call    callbyhash_any
                        dd_hash func
                        endm
