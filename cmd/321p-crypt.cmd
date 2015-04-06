SET FILES_PATH=L:\CRYPT\321-P\OUT
SET VERBA=C:\KEYS\tnb
SET SCHEME1=C:\KEYS\scheme1
SET ABONENT=2001
SET BIK3=714

SET ARJ="L:\PTK PSD\arj\ARJ.EXE"
SET SCSIGN_PATH="C:\Program Files\MGTU Bank of Russia\SignatureSC"
SET TEMP_PATH=C:\temp
REM ------------

cd /D %FILES_PATH%

if not exist %FILES_PATH%\06%BIK3%???.??? goto 1

REM Подготавливаем список файлов
del /q %TEMP_PATH%\filelist.txt
for /f %%i in ('dir /b /a-d %FILES_PATH%\06%BIK3%???.???') do echo %FILES_PATH%\%%i >> %TEMP_PATH%\filelist.txt


REM Проставляем КА
subst a: /d
subst a: %VERBA%
REM C:\windows\asrkeyw.exe
%SCSIGN_PATH%\SCSignEx.exe -s -l%TEMP_PATH%\filelist.txt -b0 -o%TEMP_PATH%\ScSignEx.log

REM Шифруем на ФСФМ файлы
subst a: /d
subst a: %SCHEME1%
if exist %TEMP_PATH%\filelist.txt %SCSIGN_PATH%\SCSignEx.exe -e -a%ABONENT% -l%TEMP_PATH%\filelist.txt -b0 -o%TEMP_PATH%\ScSignEx.log

if not exist %FILES_PATH%\PROCESS md %FILES_PATH%\PROCESS
for /f "delims=" %%i in (%TEMP_PATH%\filelist.txt) do move /y "%%i" "%FILES_PATH%\PROCESS"

REM Удаляем временный файл
del /q %TEMP_PATH%\filelist.txt
subst a: /d

:1