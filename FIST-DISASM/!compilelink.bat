@echo off
set rt11exe=C:\bin\rt11\rt11.exe

rem Define ESCchar to use in ANSI escape sequences
rem https://stackoverflow.com/questions/2048509/how-to-echo-with-different-colors-in-the-windows-command-line
for /F "delims=#" %%E in ('"prompt #$E# & for %%E in (1) do rem"') do set "ESCchar=%%E"

@if exist FIST.OBJ del FIST.OBJ
@if exist FIST.LST del FIST.LST

%rt11exe% MACRO/LIST:DK: FIST.MAC

for /f "delims=" %%a in ('findstr /B "Errors detected" FIST.LST') do set "errdet=%%a"
if "%errdet%"=="Errors detected:  0" (
  echo COMPILED SUCCESSFULLY
) ELSE (
  findstr /RC:"^[ABDEILMNOPQRTUZ] " FIST.LST
  echo ======= %errdet% =======
  exit /b
)

@if exist FIST.MAP del FIST.MAP
@if exist FIST.SAV del FIST.SAV

%rt11exe% LINK FIST /MAP:FIST.MAP

for /f "delims=" %%a in ('findstr /B "Undefined globals" FIST.MAP') do set "undefg=%%a"
if "%undefg%"=="" (
  type FIST.MAP
  echo.
  echo %ESCchar%[92mLINKED SUCCESSFULLY%ESCchar%[0m
) ELSE (
  echo %ESCchar%[91m======= LINK FAILED =======%ESCchar%[0m
  exit /b
)

fc /b FIST.SAV.etalon FIST.SAV