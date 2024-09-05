@echo off
set rt11exe=C:\bin\rt11\rt11.exe

rem Define ESCchar to use in ANSI escape sequences
rem https://stackoverflow.com/questions/2048509/how-to-echo-with-different-colors-in-the-windows-command-line
for /F "delims=#" %%E in ('"prompt #$E# & for %%E in (1) do rem"') do set "ESCchar=%%E"

@if exist S2CORE.OBJ del S2CORE.OBJ
@if exist S2CORE.LST del S2CORE.LST

%rt11exe% MACRO/LIST:DK: S2CORE.MAC

for /f "delims=" %%a in ('findstr /B "Errors detected" S2CORE.LST') do set "errdet=%%a"
if "%errdet%"=="Errors detected:  0" (
  echo COMPILED SUCCESSFULLY
) ELSE (
  findstr /RC:"^[ABDEILMNOPQRTUZ] " S2CORE.LST
  echo ======= %errdet% =======
  exit /b
)

@if exist S2CORE.MAP del S2CORE.MAP
@if exist S2CORE.SAV del S2CORE.SAV

%rt11exe% LINK S2CORE /MAP:S2CORE.MAP

for /f "delims=" %%a in ('findstr /B "Undefined globals" S2CORE.MAP') do set "undefg=%%a"
if "%undefg%"=="" (
  type S2CORE.MAP
  echo.
  echo %ESCchar%[92mLINKED SUCCESSFULLY%ESCchar%[0m
) ELSE (
  echo %ESCchar%[91m======= LINK FAILED =======%ESCchar%[0m
  exit /b
)

fc /b S2CORE.SAV.etalon S2CORE.SAV