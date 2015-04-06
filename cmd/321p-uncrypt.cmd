SET FILES_PATH=L:\CRYPT\321-P\IN
SET SCHEME2=C:\KEYS\scheme2


SET ARJ="L:\PTK PSD\arj\ARJ.EXE"
SET SCSIGN_PATH="C:\Program Files\MGTU Bank of Russia\SignatureSC"
SET TEMP_PATH=C:\temp
SET PAUSE=PING -n 20 127.0.0.1 >nul
REM ------------

cd /D %FILES_PATH%

if not exist *.c?? goto 1

%PAUSE%

REM Подготавливаем список файлов
del /q %TEMP_PATH%\filelist.txt
for /f %%i in ('dir /b /a-d %FILES_PATH%\*.c??') do echo %FILES_PATH%\%%i >> %TEMP_PATH%\filelist.txt

REM Расшифровываем файлы схемой2
subst a: /d
subst a: %SCHEME2%
%SCSIGN_PATH%\SCSignEx.exe -d -l%TEMP_PATH%\filelist.txt -b0 -o%TEMP_PATH%\ScSignEx.log

REM Убираем КА
%SCSIGN_PATH%\SCSignEx.exe -r -l%TEMP_PATH%\filelist.txt -b0 -o%TEMP_PATH%\ScSignEx.log

%ARJ% e *.c??
del *.c??


REM Удаляем временный файл
del /q %TEMP_PATH%\filelist.txt
subst a: /d

:1