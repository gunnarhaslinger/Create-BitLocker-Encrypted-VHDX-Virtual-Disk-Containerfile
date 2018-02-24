@echo off
set DISKFILE=C:\Temp\virtualdisk-new-%RANDOM%.vhdx
set DISKSIZE=1000
set DRIVELETTER=V

rem Check for Admin-Rights
cd /d %~dp0
NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo.
    echo. ERROR! Can not run without Administrator-Permissions!
	echo.
    echo. Start this script with "Run as Administrator ..."
	echo.
	pause
	exit 1
) 

rem Create a diskpart-Script in TEMP-Directory
set DISKPARTSCRIPT=%TEMP%\diskpart-script.txt

rem Create a new VHDX-File and attach it to the System als virtual Disk
echo create vdisk file="%DISKFILE%" maximum=%DISKSIZE% type=expandable >"%DISKPARTSCRIPT%"
echo select vdisk file="%DISKFILE%" >>"%DISKPARTSCRIPT%"
echo attach vdisk >>"%DISKPARTSCRIPT%"
echo convert MBR >>"%DISKPARTSCRIPT%"

rem Create a Partition as "Recovery Partition" to avoid automatically mounting
echo create partition primary ID=27 >>"%DISKPARTSCRIPT%"

rem Format the Partition, using exfat Filesystem (large Files support)
echo format FS=EXFAT Label="vDisk" QUICK >>"%DISKPARTSCRIPT%"

rem Now after formating the Partition change ID from "Recovery Partition" to regular Data-Partition exFAT ID7 for mounting
echo set ID=07 >>"%DISKPARTSCRIPT%"

rem Assign a Drive Letter
echo assign letter=%DRIVELETTER% >>"%DISKPARTSCRIPT%"

rem Run the created Diskpart-Script
diskpart /s "%DISKPARTSCRIPT%"

if not "%ERRORLEVEL%" == "0" goto end
echo.
echo.
echo Virtual Disk "%DISKFILE%" created
echo.
echo To apply Bitlocker encryption press Space - or close this Script to leave partition in plaintext
echo.
pause

rem Apply Bitlocker Encryption
manage-bde.exe -on %DRIVELETTER%: -UsedSpaceOnly -Password -Encryptionmethod aes128

:end
pause
