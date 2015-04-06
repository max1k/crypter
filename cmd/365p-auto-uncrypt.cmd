SET FILES_PATH=L:\CRYPT\AUTODEC\365\IN
SET PROCESS_PATH=L:\CRYPT\AUTODEC\365\IN\PROCESSED

SET STAT=S:\CBP\365P\IN
SET EML=L:\CRYPT\AUTODEC\365\IN\NEW
SET OMEGA="Z:\Операционный отдел\365P\IN"
SET OMEGAKWT="Z:\Операционный отдел\365P\KVIT"

SET VERBA=C:\KEYS\tnb
SET SCHEME1=C:\KEYS\scheme1
SET BIK3=714

SET ARJ="L:\PTK PSD\arj\ARJ.EXE"
SET SCSIGN_PATH="C:\Program Files\MGTU Bank of Russia\SignatureSC"
SET TEMP_PATH=C:\temp
REM ------------
cd /D %FILES_PATH%

if not exist mz????18.%BIK3% goto prc

for /f %%f in ('dir /b /a-d %FILES_PATH%\mz????18.%BIK3%') do (
cd /D %FILES_PATH%
move /y %%f %PROCESS_PATH%
cd /D %PROCESS_PATH%

expand -r %%f
del %%f
if exist *.ARJ %ARJ% e *.ARJ -u -y
del *.arj

REM Подготавливаем список файлов
del /q %TEMP_PATH%\filelist.txt
for /f %%i in ('dir /b /a-d %PROCESS_PATH%\*.vrb') do echo %PROCESS_PATH%\%%i >> %TEMP_PATH%\filelist.txt

REM Расшифровываем файлы схемой1
subst a: /d
subst a: %SCHEME1%
if exist %TEMP_PATH%\filelist.txt %SCSIGN_PATH%\SCSignEx.exe -d -l%TEMP_PATH%\filelist.txt -b0 -o%TEMP_PATH%\autoScSignEx.log

REM Меняем расширение VRB на TXT и снимаем КА со ВСЕХ TXT-файлов
if exist %TEMP_PATH%\filelist.txt for /f %%i in (%TEMP_PATH%\filelist.txt) do ren %%i *.txt

REM Подготавливаем список файлов
del /q %TEMP_PATH%\filelist.txt
for /f %%i in ('dir /b /a-d %PROCESS_PATH%\*.txt') do echo %PROCESS_PATH%\%%i >> %TEMP_PATH%\filelist.txt

REM Убираем с них ЭЦП
subst a: /d
subst a: %VERBA%
if exist %TEMP_PATH%\filelist.txt %SCSIGN_PATH%\SCSignEx.exe -r -l%TEMP_PATH%\filelist.txt -b0 -o%TEMP_PATH%\autoScSignEx.log

REM Удаляем временный файл
del /q %TEMP_PATH%\filelist.txt
subst a: /d

cd /d %PROCESS_PATH%
if exist IZVTUB*.txt copy /y IZVTUB*.txt %STAT% && move /y IZVTUB*.txt %EML%
if exist KWTFCB_PB?_*.txt copy /y KWTFCB_PB?_*.txt %STAT% && move /y KWTFCB_PB?_*.txt %EML%
if exist KWTFCB*.txt copy /y KWTFCB*.txt %STAT% && copy KWTFCB*.txt %OMEGAKWT% && move /y KWTFCB*.txt %EML%
if exist *.txt copy /y *.txt %STAT% && copy *.txt %OMEGA% && move /y *.txt %EML%
)

:prc
cd /d %PROCESS_PATH%
if exist IZVTUB*.txt copy /y IZVTUB*.txt %STAT% && move /y IZVTUB*.txt %EML%
if exist KWTFCB_PB?_*.txt copy /y KWTFCB_PB?_*.txt %STAT% && move /y KWTFCB_PB?_*.txt %EML%
if exist KWTFCB*.txt copy /y KWTFCB*.txt %STAT% && copy KWTFCB*.txt %OMEGAKWT% && move /y KWTFCB*.txt %EML%
if exist *.txt copy /y *.txt %STAT% && copy *.txt %OMEGA% && move /y *.txt %EML%