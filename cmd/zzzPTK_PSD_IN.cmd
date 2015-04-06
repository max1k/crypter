SET FILES_IN=T:\PTK_PSD_IN
SET FILES_OUT=L:\POST\ELO\OUT
SET VERBA=C:\KEYS\tnb
SET BIK3=714

SET SCSIGN_PATH="C:\Program Files\MGTU Bank of Russia\SignatureSC"
SET TEMP_PATH=C:\temp
REM ------------

REM Подготавливаем список файлов
del /q %TEMP_PATH%\filelist.txt
for /f %%i in ('dir /b /a-d %FILES_IN%\*.%BIK3%') do echo %FILES_IN%\%%i >> %TEMP_PATH%\filelist.txt

REM Расшифровываем файлы
subst a: /d
subst a: %VERBA%
REM C:\windows\asrkeyw.exe
%SCSIGN_PATH%\SCSignEx.exe -d -l%TEMP_PATH%\filelist.txt -b0 -o%TEMP_PATH%\ScSignEx.log

REM Снимаем с них ЭЦП ЦБ
%SCSIGN_PATH%\SCSignEx.exe -r -l%TEMP_PATH%\filelist.txt -b0 -o%TEMP_PATH%\ScSignEx.log

REM Перемещаем расшифрованные файлы
for /f "delims=" %%i in (%TEMP_PATH%\filelist.txt) do move /y %%i %FILES_OUT%

REM Удаляем временный файл
del /q %TEMP_PATH%\filelist.txt