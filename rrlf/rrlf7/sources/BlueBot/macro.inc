; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;               Macros

                macro mr id, size {
                local lallocs
                lallocs = allocs
                id equ (ebp+lallocs)
                allocs = allocs + size
                }

                macro dores a, b {
                mov esi, a
                call lookupapi
                mov [b], eax
                }

		macro cmpx a, b {
		;cmp eax, b xor 47b3a89fh
		cmp a, (b * 07B63002Fh) and 0ffffffffh
		}