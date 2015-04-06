SET FILES_PATH=L:\CRYPT\365-P\IN
SET VERBA=C:\KEYS\tnb
SET SCHEME1=C:\KEYS\scheme1
SET BIK3=714
SET COPYTO=S:\CBP\365P\IN


SET ARJ="L:\PTK PSD\arj\ARJ.EXE"
SET SCSIGN_PATH="C:\Program Files\MGTU Bank of Russia\SignatureSC"
SET TEMP_PATH=C:\temp
REM ------------

cd /D %FILES_PATH%

if not exist mz???_18.%BIK3% goto 1

expand -r mz???_18.%BIK3%
del *.%BIK3%
%ARJ% e *.ARJ -u -y
del *.arj

REM Подготавливаем список файлов
del /q %TEMP_PATH%\filelist.txt
for /f %%i in ('dir /b /a-d %FILES_PATH%\*.txt') do echo %FILES_PATH%\%%i >> %TEMP_PATH%\filelist.txt
for /f %%i in ('dir /b /a-d %FILES_PATH%\*.vrb') do echo %FILES_PATH%\%%i >> %TEMP_PATH%\filelist.txt

REM Убираем КА
subst a: /d
subst a: %VERBA%
REM C:\windows\asrkeyw.exe
%SCSIGN_PATH%\SCSignEx.exe -r -l%TEMP_PATH%\filelist.txt -b0 -o%TEMP_PATH%\ScSignEx.log

REM Подготавливаем список файлов
del /q %TEMP_PATH%\filelist.txt
for /f %%i in ('dir /b /a-d %FILES_PATH%\*.vrb') do echo %FILES_PATH%\%%i >> %TEMP_PATH%\filelist.txt


REM Расшифровываем файлы схемой1
subst a: /d
subst a: %SCHEME1%
if exist %TEMP_PATH%\filelist.txt %SCSIGN_PATH%\SCSignEx.exe -d -l%TEMP_PATH%\filelist.txt -b0 -o%TEMP_PATH%\ScSignEx.log

REM Убираем с них ЭЦП
subst a: /d
subst a: %VERBA%
if exist %TEMP_PATH%\filelist.txt %SCSIGN_PATH%\SCSignEx.exe -r -l%TEMP_PATH%\filelist.txt -b0 -o%TEMP_PATH%\ScSignEx.log

if exist %TEMP_PATH%\filelist.txt for /f %%i in (c:\temp\filelist.txt) do ren %%i *.txt

REM Удаляем временный файл
del /q %TEMP_PATH%\filelist.txt
subst a: /d

copy /y %FILES_PATH%\*.txt %COPYTO%

:1