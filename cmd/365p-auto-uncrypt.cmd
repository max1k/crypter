SET FILES_PATH=L:\CRYPT\AUTODEC\365\IN
SET PROCESS_PATH=L:\CRYPT\AUTODEC\365\IN\PROCESSED

SET STAT=S:\CBP\365P\IN
SET EML=L:\CRYPT\AUTODEC\365\IN\NEW
SET OMEGA="Z:\����樮��� �⤥�\365P\IN"
SET OMEGAKWT="Z:\����樮��� �⤥�\365P\KVIT"

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

REM �����⠢������ ᯨ᮪ 䠩���
del /q %TEMP_PATH%\filelist.txt
for /f %%i in ('dir /b /a-d %PROCESS_PATH%\*.vrb') do echo %PROCESS_PATH%\%%i >> %TEMP_PATH%\filelist.txt

REM �����஢뢠�� 䠩�� �奬��1
subst a: /d
subst a: %SCHEME1%
if exist %TEMP_PATH%\filelist.txt %SCSIGN_PATH%\SCSignEx.exe -d -l%TEMP_PATH%\filelist.txt -b0 -o%TEMP_PATH%\autoScSignEx.log

REM ���塞 ���७�� VRB �� TXT � ᭨���� �� � ���� TXT-䠩���
if exist %TEMP_PATH%\filelist.txt for /f %%i in (%TEMP_PATH%\filelist.txt) do ren %%i *.txt

REM �����⠢������ ᯨ᮪ 䠩���
del /q %TEMP_PATH%\filelist.txt
for /f %%i in ('dir /b /a-d %PROCESS_PATH%\*.txt') do echo %PROCESS_PATH%\%%i >> %TEMP_PATH%\filelist.txt

REM ���ࠥ� � ��� ���
subst a: /d
subst a: %VERBA%
if exist %TEMP_PATH%\filelist.txt %SCSIGN_PATH%\SCSignEx.exe -r -l%TEMP_PATH%\filelist.txt -b0 -o%TEMP_PATH%\autoScSignEx.log

REM ����塞 �६���� 䠩�
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