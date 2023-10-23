@echo off
cd /d "%~dp0"
pushd "%~dp0"
setlocal enableextensions disabledelayedexpansion
setx Tmp C:\Temp
setx Tmp C:\temp /m
setx Temp C:\Temp
setx Temp C:\temp /m

::echo param1=%1
::echo param1=%2
::echo %~s0
::-------------------------------------
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"="
    ::echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "cmd.exe", "/c %~s0 %1 %2 %3", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
::--------------------------------------

If "_%1" == "_/FASTMEDIA" (
::Asumimos que es un drive rápido. Si queremos crear igualmente la unidad, proporcionamos los GB en el segundo parametro
::
	echo Bypassing Check Media
	set MEDIASPEED=FASTWRITE
	goto NoCheckMedia
	)

If "_%1" == "_/SLOWMEDIA" (
	echo Bypassing Check Media
	set MEDIASPEED=LOWWRITE
	goto NoCheckMedia
	)
	
::==========================================================
::========================================================== CHECK MEDIA SPEED
::==========================================================
set MEDIASPEED=UNKNOWN
set /a MINWRITESPEED=100
if not exist "C:\DNXSoftware" mkdir C:\DNXSoftware
set myOutWinsatFile=C:\DNXSoftware\outwinsat.txt
set myOutWinsatFile2=C:\DNXSoftware\outwinsat2.txt

echo Testing Speed of drive C

winsat disk -seq -write -drive C: >%myOutWinsatFile%

set "search=%1"
set "replace=%2"
set "search=^>"
set "replace=."
set "textFile=%myOutWinsatFile%"
for /f "delims=" %%i in ('type "%textFile%" ^& break ^> "%textFile%" ') do (
    set "line=%%i"
    setlocal enabledelayedexpansion
    >>"%textFile%" echo(!line:%search%=%replace%!
    endlocal
)
findstr "Sequential" %myOutWinsatFile% >%myOutWinsatFile2%

set /p MYVAR=<%myOutWinsatFile2%
set myvar=%MYVAR:~45,20%
call :GetVars VAR1 VAR2 %MYVAR%
::set string=%string:!=%    para eliminar . y , 
set VAR1=%VAR1:,= %
set VAR1=%VAR1:.= %
call :GetVars VAR1 XDEC %VAR1%
set /a VAR1=%VAR1%+0
echo Speed = %VAR1% MB/s
if %VAR1% LEQ %MINWRITESPEED% goto SLOWWRITE
if %VAR1% GTR %MINWRITESPEED% goto FASTWRITE

echo CANNOT EVALUATE SPEED
goto end1

::__________________________________________________________ Begin FUNCTIONS

:FASTWRITE
echo Running on SSD or HDD
set MEDIASPEED=FASTWRITE
goto end1

:SLOWWRITE
echo Running on MicroSD or USB. Activating RamDisk
set MEDIASPEED=SLOWWRITE

goto end1

:GetVars
set %1=%3
set %2=%4
exit /b

:GetTotalRAM
set "myWMICtxt=C:\DNXSoftware\OUTWMIC.txt"

wmic ComputerSystem get TotalPhysicalMemory >%myWMICtxt%

set /a NTargetLine=2, N=NTargetLine-1
<%myWMICtxt% (for /f %%v in ('more +%N%') do set "line=%%v" & goto done)
:done
set %1=%line%
exit /b

:STRLEN  strVar  [rtnVar]
setlocal disableDelayedExpansion
set len=0
if defined %~1 for /f "delims=:" %%N in (
  '"(cmd /v:on /c echo(!%~1!&echo()|findstr /o ^^"'
) do set /a "len=%%N-3"
endlocal & if "%~2" neq "" (set %~2=%len%) else echo %len%
exit /b

::__________________________________________________________ End FUNCTIONS

:end1

::	echo AUTO
::	echo MEDIASPEED=%MEDIASPEED%
::	pause

if "_%myOutWinsatFile%" NEQ "_" del /Q %myOutWinsatFile%
if "_%myOutWinsatFile2%" NEQ "_" del /Q %myOutWinsatFile2%

:NoCheckMedia
echo param1=%1
echo param2=%2
if "_%2" NEQ "_" (
	echo Set Fix RamDrive Size [%2 GB]
	SET myRD=%2
	goto NoCheckRAM
)
::==========================================================
::========================================================== CHECK AVAILABLE RAM
::==========================================================
:CHECK_RAM
if "_%MEDIASPEED%"=="_FASTWRITE" goto NoImDiskInstall
call :GetTotalRAM myRAM
set /a myRAM=%myRAM%
call :STRLEN myRAM smemlen
set "memMB=%myRAM:~0,-6%"
set /a "mem=((memMB-memMB/21) + (memMB-memMB/22))/2"
set mem=%mem:~0,2%
echo This computer has %mem% GB RAM

set /a myRAM=%mem%+0
set myRD=1
if %myRAM% GTR 16 set myRD=4
if %myRAM% LEQ 16 set myRD=3
if %myRAM% LEQ 8 set myRD=2
if %myRAM% LEQ 4 set myRD=1
if %myRAM% LEQ 2 (
	set MEDIASPEED=FASTWRITE
	goto NORAMDISK
)

echo RamDrive Size = %myRD% GB
pause
:ToContinue1

:NoCheckRAM

if "_%3" == "_/NOINSTALL" (
	echo Bypassing ImDisk Install
	goto NoImDiskInstall
)
::==========================================================
::========================================================== Installing ImDisk
::==========================================================

echo Installing ImDisk
echo cd=%cd%
call .\ImDisk\install.bat 7 /silent /menu_entries:1 /shortcuts_desktop:0 /shortcuts_all:0

:NoImDiskInstall

::==========================================================
::========================================================== Creating ImDisk
::==========================================================

:NORAMDISK
sc config awealloc start= auto
net start awealloc
::Detach Unit if exist
imdisk -D -m Z:

if "_%MEDIASPEED%"=="_FASTWRITE" (
	::Set the pagefile size to auto
	::wmic pagefileset where name="C:\\pagefile.sys" set InitialSize=%xmyVM%,MaximumSize=%xmyVM%
	echo ENABLING PAGEFILE
	wmic computersystem where name="%computername%" set AutomaticManagedPagefile=true
	RUNDLL32.EXE USER32.DLL,UpdatePerUserSystemParameters ,1 ,True
	goto ToContinue2
) else (
	::Disable pagefile
	echo DISABLING PAGEFILE
	wmic computersystem where name="%computername%" set AutomaticManagedPagefile=false
	wmic pagefileset where name="C:\\pagefile.sys" delete
	::wmic process where name="explorer.exe" call terminate
	RUNDLL32.EXE USER32.DLL,UpdatePerUserSystemParameters ,1 ,True
)
::Create Unit
imdisk -a -s %myRD%G -o awe -m Z: -p "/fs:ntfs /q /y"
REG ADD "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v ".DNXRamDrive" /t REG_SZ /d "C:\Users\Public\Desktop\DNX RamDrive.lnk" /f

::==========================================================
::========================================================== Config Temps and Cache
::==========================================================

if not exist Z:\Temp mkdir Z:\Temp
if exist "C:\TempRD" rmdir /q /s "C:\TempRD"
setx Tmp C:\TempRD
setx Tmp C:\TempRD /m
setx Temp C:\TempRD
setx Temp C:\TempRD /m
mklink /J "C:\TempRD" "Z:\Temp"

taskkill /f /im Chrome.exe
rmdir /q /s "%localappdata%\Google\Chrome\User Data\Default\Cache"
mkdir Z:\ChromeCache
mklink /J "%localappdata%\Google\Chrome\User Data\Default\Cache" Z:\ChromeCache

taskkill /f /im msedge.exe
rmdir /q /s "%localappdata%\Microsoft\Edge\User Data\Default\Cache"
mkdir Z:\EdgeCache
mklink /J "%localappdata%\Microsoft\Edge\User Data\Default\Cache" Z:\EdgeCache


:ToContinue2
set "myDNXRDLink=DNX RamDrive"
if not exist "C:\Users\Public\Desktop\%myDNXRDLink%.lnk" (
	echo creating lnk
	
	powershell -ExecutionPolicy Unrestricted -command "%~dp0DNXRamDriveLNK.ps1 '%myDNXRDLink%' '%~f0'"
)
::call "C:\DNXSoftware\CheckRD.lnk"

:EndScript
