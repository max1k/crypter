SET FILES_PATH=L:\CRYPT\311-P\IN
SET VERBA=C:\KEYS\tnb
SET SCHEME1=C:\KEYS\scheme1
SET BIK3=714
SET COPYTO=S:\CBP\311P\IN


SET ARJ="L:\PTK PSD\arj\ARJ.EXE"
SET SCSIGN_PATH="C:\Program Files\MGTU Bank of Russia\SignatureSC"
SET TEMP_PATH=C:\temp
REM ------------

cd /D %FILES_PATH%

if exist 2z???018.%BIK3% ren 2z???018.%BIK3% *.txt
if exist 2z???018.txt copy /y %FILES_PATH%\2z???018.txt %COPYTO%
if not exist 2z???_18.%BIK3% goto 1

expand -r 2z???_18.%BIK3%
del *.%BIK3%
%ARJ% e *.ARJ -u -y
del *.arj

REM Подготавливаем список файлов
del /q %TEMP_PATH%\filelist.txt
for /f %%i in ('dir /b /a-d %FILES_PATH%\*.txt') do echo %FILES_PATH%\%%i >> %TEMP_PATH%\filelist.txt

REM Убираем КА
subst a: /d
subst a: %VERBA%
REM C:\windows\asrkeyw.exe
%SCSIGN_PATH%\SCSignEx.exe -r -l%TEMP_PATH%\filelist.txt -b0 -o%TEMP_PATH%\ScSignEx.log

REM Удаляем временный файл
del /q %TEMP_PATH%\filelist.txt
subst a: /d

copy /y %FILES_PATH%\*.txt %COPYTO%

:1