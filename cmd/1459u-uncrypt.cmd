SET FILES_PATH=L:\CRYPT\1459-U\IN
SET VERBA=C:\KEYS\tnb
SET SCHEME1=C:\KEYS\scheme1
SET BIK3=714


SET ARJ="L:\PTK PSD\arj\ARJ.EXE"
SET SCSIGN_PATH="C:\Program Files\MGTU Bank of Russia\SignatureSC"
SET TEMP_PATH=C:\temp
REM ------------

cd /D %FILES_PATH%

if exist sz???018.%BIK3% expand -r sz???018.%BIK3% && del sz???018.%BIK3%

if not exist sz???_18.%BIK3% goto 1

expand -r sz???_18.%BIK3%
del sz???_18.%BIK3%
%ARJ% e *.ARJ -u -y
del *.arj

REM Подготавливаем список файлов
del /q %TEMP_PATH%\filelist.txt
for /f %%i in ('dir /b /a-d %FILES_PATH%\*.xml') do echo %FILES_PATH%\%%i >> %TEMP_PATH%\filelist.txt

REM Расшифровываем Схемой1
subst a: /d
subst a: %SCHEME1%
%SCSIGN_PATH%\SCSignEx.exe -d -l%TEMP_PATH%\filelist.txt -b0 -o%TEMP_PATH%\ScSignEx.log

REM Убираем КА
subst a: /d
subst a: %VERBA%
%SCSIGN_PATH%\SCSignEx.exe -r -l%TEMP_PATH%\filelist.txt -b0 -o%TEMP_PATH%\ScSignEx.log

REM Удаляем временный файл
del /q %TEMP_PATH%\filelist.txt
subst a: /d

:1