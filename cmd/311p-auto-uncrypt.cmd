SET FILES_PATH=L:\CRYPT\AUTODEC\311\IN
SET PROCESS_PATH=L:\CRYPT\AUTODEC\311\IN\PROCESSED

SET STAT=S:\CBP\311P\IN
SET EML=L:\CRYPT\AUTODEC\311\IN\NEW
SET OMEGA="Z:\����樮��� �⤥�\311P\KVIT"

SET VERBA=C:\KEYS\tnb
SET SCHEME1=C:\KEYS\scheme1
SET BIK3=714

SET ARJ="L:\PTK PSD\arj\ARJ.EXE"
SET SCSIGN_PATH="C:\Program Files\MGTU Bank of Russia\SignatureSC"
SET TEMP_PATH=C:\temp
REM ------------

cd /D %FILES_PATH%
REM ------------��ࠡ��뢠��, �᫨ �� cab � ᮮ⢥��⢥��� ����� ���� xml-----------
if exist 2z???018.%BIK3% (
for /f %%f in ('dir /b /a-d %FILES_PATH%\2z???018.%BIK3%') do (
expand -r %%f
if exist UV*.xml move /y UV*.xml %PROCESS_PATH% && del /q %%f
)
)

REM ------------��, �� ��⠫��� �� ����� ⥪�⮢� 2z ��ண� �ଠ�-----------
if exist 2z???018.%BIK3% ren 2z???018.%BIK3% *.txt 
if exist 2z???018.txt move /y 2z???018.txt %PROCESS_PATH%

if not exist 2z???_18.%BIK3% goto prc

for /f %%f in ('dir /b /a-d %FILES_PATH%\2z???_18.%BIK3%') do (
cd /D %FILES_PATH%
move /y %%f %PROCESS_PATH%
cd /D %PROCESS_PATH%

expand -r %%f
if exist *.ARJ del %%f
%ARJ% e *.ARJ -u -y
if exist s*.* del *.arj

REM �����⠢������ ᯨ᮪ 䠩���
del /q %TEMP_PATH%\filelist.txt
for /f %%i in ('dir /b /a-d %PROCESS_PATH%\s*.*') do echo %PROCESS_PATH%\%%i >> %TEMP_PATH%\filelist.txt

REM ���ࠥ� ��
subst a: /d
subst a: %VERBA%
%SCSIGN_PATH%\SCSignEx.exe -r -l%TEMP_PATH%\filelist.txt -b0 -o%TEMP_PATH%\autoScSignEx.log

REM ����塞 �६���� 䠩�
del /q %TEMP_PATH%\filelist.txt
subst a: /d
)

:prc
cd /d %PROCESS_PATH%
if exist 2z*.txt copy /y 2z*.txt %STAT% && move /y 2z*.txt %EML%
if exist s*.* copy /y s*.* %STAT% && copy s*.* %OMEGA% && move /y s*.* %EML%
if exist UV*.xml copy /y UV*.xml %STAT% && move /y UV*.xml %EML%