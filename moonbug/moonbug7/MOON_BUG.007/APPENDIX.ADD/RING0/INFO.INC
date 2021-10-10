
defnum                  macro   c, x
                        local   i,j,f,k
                        j       = 1
                        rept    c
                          j       = j * 10
                        endm
                        f       = 0
                        rept    c
                          j       = j / 10
                          k       = x / j mod 10
                          if      (k eq 0) and (f eq 0) and (j ne 1)
                            db      ' '
                          else
                            f       = 1
                            db      k + '0'
                          endif
                        endm
                        endm

                        ts = 0
                        ms = 0

pginfo                  macro   x
                        db      'Page #&x&: '
                        defnum  4, page&x&_size
                        ts = ts + page&x&_size
                        ms = ms + 4096
                        db      ' of  4096 byte(s) ['
                        defnum  3, page&x&_size*100/4096
                        db      '.'
                        defnum  2, (page&x&_size*100*100/4096) mod 100
                        db      '%]',13,10
                        endm

                        db      13,10,13,10
                        pginfo  1
                        pginfo  2
                        db      '         ----    -----           --.--',13,10
                        db      'Total:   '
                        defnum  4, ts       ize
                        db      ' of '
                        defnum  5, ms
                        db      ' byte(s) ['
                        defnum  3, ts*100/ms
                        db      '.'
                        defnum  2, (ts*100*100/ms) mod 100
                        db      '%]',13,10

                        db      13,10,13,10
