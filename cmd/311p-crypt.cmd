SET FILES_PATH=L:\CRYPT\311-P\OUT

SET NOFILES=true
if exist %FILES_PATH%\SBC*.txt set NOFILES=false
if exist %FILES_PATH%\SBC*.xml set NOFILES=false
if exist %FILES_PATH%\SKD*.xml set NOFILES=false
if exist %FILES_PATH%\SFC*.xml set NOFILES=false
if "%NOFILES%"=="true" goto 1
REM ---/Проверка на файлы для обработки--

REM ---Параметры-------------------------
SET VERBA=C:\KEYS\tnb
SET SCHEME1=C:\KEYS\scheme1
SET ABONENT=0020
SET BIK5=06714
REM ---/Параметры------------------------ 

REM ---Служебные-------------------------
SET ARJ="L:\PTK PSD\arj\ARJ.EXE"
SET SCSIGN_PATH="C:\Program Files\MGTU Bank of Russia\SignatureSC"
SET TEMP_PATH=C:\temp

SET PROCESS_PATH=%TEMP_PATH%\PROCESS\311-P
SET PAUSE=PING -n 10 127.0.0.1 >nul
SET FILELIST=%TEMP_PATH%\list311p.txt
REM ---/Служебные------------------------

REM ---Динамичные------------------------
SET YY=%DATE:~8,2%
SET MM=%DATE:~3,2%
SET DD=%DATE:~0,2%
SET HRS=%time:~0,2%
SET MIN=%time:~3,2%
SET SEC=%time:~6,2%
SET MLS=%time:~9,2%
SET LOGFILE=%TEMP_PATH%\ScSignEx\%YY%%MM%%DD%.log
REM ---/Динамичные------------------------

%PAUSE%

REM ---Сохранение всех файлов-------------
SET COPYTO=S:\CBP\311P\OUT
copy /y %FILES_PATH%\S*.* %COPYTO%
REM ---/Сохранение всех файлов------------

if not exist %PROCESS_PATH% md %PROCESS_PATH%
move /y %FILES_PATH%\S*.* %PROCESS_PATH%

REM ---Подготавливаем список файлов-------
del /q %FILELIST%
for /f %%i in ('dir /b /a-d %PROCESS_PATH%\S*.*') do echo %PROCESS_PATH%\%%i >> %FILELIST%

REM ---Проставляем КА---------------------
subst a: /d & subst a: %VERBA%
%SCSIGN_PATH%\SCSignEx.exe -s -l%FILELIST% -b0 -o%LOGFILE%

REM ---Шифруем на ФНС---------------------
subst a: /d & subst a: %SCHEME1%
%SCSIGN_PATH%\SCSignEx.exe -e -a%ABONENT% -l%FILELIST% -b0 -o%LOGFILE%

REM ---Пакуем в архив---------------------
cd /d %PROCESS_PATH%
if exist SBC*.txt %ARJ% m -ey A%BIK5%%YY%%MM%%DD%01.arj SBC*.txt
if exist SBC*.xml %ARJ% m -ey AN%BIK5%%YY%%MM%%DD%0001.arj SBC*.xml
if exist SKD*.xml %ARJ% m -ey BN%BIK5%%YY%%MM%%DD%0001.arj SKD*.xml
if exist SFC*.xml %ARJ% m -ey BN%BIK5%%YY%%MM%%DD%0001.arj SFC*.xml

REM ---Удаляем временный файл и выгружаем в него список архивов
del /q %FILELIST%
for /f %%i in ('dir /b /a-d %PROCESS_PATH%\*.arj') do echo %PROCESS_PATH%\%%i >> %FILELIST%

REM ---Проставляем КА на архив------------
subst a: /d & subst a: %VERBA%
%SCSIGN_PATH%\SCSignEx.exe -s -l%FILELIST% -b0 -o%LOGFILE%
REM --------------------------------------

move /y %PROCESS_PATH%\*.arj %FILES_PATH%

REM ---Удаляем временный файл освобождаем диск
del /q %FILELIST%
subst a: /d

:1