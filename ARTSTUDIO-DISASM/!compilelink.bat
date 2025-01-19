@echo off
set rt11exe=C:\bin\rt11\rt11.exe

rem Define ESCchar to use in ANSI escape sequences
rem https://stackoverflow.com/questions/2048509/how-to-echo-with-different-colors-in-the-windows-command-line
for /F "delims=#" %%E in ('"prompt #$E# & for %%E in (1) do rem"') do set "ESCchar=%%E"

@if exist ART.OBJ del ART.OBJ
@if exist ART.LST del ART.LST
@if exist ART1.OBJ del ART1.OBJ
@if exist ART1.LST del ART1.LST

@if exist ART.MAP del ART.MAP
@if exist ART.SAV del ART.SAV

%rt11exe% MACRO/LIST:DK: ART.MAC

for /f "delims=" %%a in ('findstr /B "Errors detected" ART.LST') do set "errdet=%%a"
if "%errdet%"=="Errors detected:  0" (
  echo COMPILED SUCCESSFULLY
) ELSE (
  findstr /RC:"^[ABDEILMNOPQRTUZ] " ART.LST
  echo ======= %errdet% =======
  exit /b
)

%rt11exe% MACRO/LIST:DK: ART1.MAC

for /f "delims=" %%a in ('findstr /B "Errors detected" ART1.LST') do set "errdet=%%a"
if "%errdet%"=="Errors detected:  0" (
  echo COMPILED SUCCESSFULLY
) ELSE (
  findstr /RC:"^[ABDEILMNOPQRTUZ] " ART1.LST
  echo ======= %errdet% =======
  exit /b
)

%rt11exe% MACRO/LIST:DK: ART2.MAC

for /f "delims=" %%a in ('findstr /B "Errors detected" ART2.LST') do set "errdet=%%a"
if "%errdet%"=="Errors detected:  0" (
  echo COMPILED SUCCESSFULLY
) ELSE (
  findstr /RC:"^[ABDEILMNOPQRTUZ] " ART2.LST
  echo ======= %errdet% =======
  exit /b
)

%rt11exe% @ART

for /f "delims=" %%a in ('findstr /B "Undefined globals" ART.MAP') do set "undefg=%%a"
if "%undefg%"=="" (
  type ART.MAP
  echo.
  echo %ESCchar%[92mLINKED SUCCESSFULLY%ESCchar%[0m
) ELSE (
  echo %ESCchar%[91m======= LINK FAILED =======%ESCchar%[0m
  exit /b
)

fc /b ART.SAV.etalon1 ART.SAV