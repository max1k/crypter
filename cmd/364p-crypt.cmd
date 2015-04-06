SET FILES_PATH=L:\CRYPT\364-P\OUT
SET ES_KA_PATH=L:\ASVBK\FTS\364p\ES_KA
SET VERBA=C:\KEYS\tnb
SET SCHEME1=C:\KEYS\scheme1
SET ABONENT=0020

SET SCSIGN_PATH="C:\Program Files\MGTU Bank of Russia\SignatureSC"
SET TEMP_PATH=C:\temp
SET PAUSE=PING -n 15 127.0.0.1 >nul
SET CUR_DATE=%DATE:~0,2%.%DATE:~3,2%.%DATE:~6,4%
REM ------------

cd /D %FILES_PATH%

if not exist %FILES_PATH%\*.xml if not exist %FILES_PATH%\*.arj goto 1
%PAUSE%

REM Подготавливаем список файлов - нужно подписать ЭЦП все файлы
del /q %TEMP_PATH%\filelist.txt
for /f %%i in ('dir /b /a-d %FILES_PATH%\*.arj') do echo %FILES_PATH%\%%i >> %TEMP_PATH%\filelist.txt
copy /y %TEMP_PATH%\filelist.txt %TEMP_PATH%\filelist_arj.txt
for /f %%i in ('dir /b /a-d %FILES_PATH%\*.xml') do echo %FILES_PATH%\%%i >> %TEMP_PATH%\filelist.txt

REM Проставляем КА на файлы *.xml и *.arj
subst a: /d
subst a: %VERBA%
REM C:\windows\asrkeyw.exe
%SCSIGN_PATH%\SCSignEx.exe -s -l%TEMP_PATH%\filelist.txt -b0 -o%TEMP_PATH%\ScSignEx.log

REM формируем список файлов заново, включив в него только *.xml
del /q %TEMP_PATH%\filelist.txt
for /f %%i in ('dir /b /a-d %FILES_PATH%\*.xml') do echo %FILES_PATH%\%%i >> %TEMP_PATH%\filelist.txt

REM Шифруем на ФТС файлы с расширением *.xml
subst a: /d
subst a: %SCHEME1%
if exist %TEMP_PATH%\filelist.txt %SCSIGN_PATH%\SCSignEx.exe -e -a%ABONENT% -l%TEMP_PATH%\filelist.txt -b0 -o%TEMP_PATH%\ScSignEx.log

REM перемещаем архивы в папку PROCESS
if not exist %FILES_PATH%\PROCESS md %FILES_PATH%\PROCESS
for /f "delims=" %%i in (%TEMP_PATH%\filelist_arj.txt) do move /y "%%i" "%FILES_PATH%\PROCESS"

REM перемещаем xml в АСВКБ
if not exist %ES_KA_PATH%\%CUR_DATE% md %ES_KA_PATH%\%CUR_DATE%
for /f "delims=" %%i in (%TEMP_PATH%\filelist.txt) do move /y "%%i" %ES_KA_PATH%\%CUR_DATE%

REM Удаляем временный файл
del /q %TEMP_PATH%\filelist.txt
del /q %TEMP_PATH%\filelist_arj.txt
subst a: /d

:1