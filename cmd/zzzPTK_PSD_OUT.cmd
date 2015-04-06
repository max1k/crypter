SET FILES_IN=L:\POST\ELO\OUT
SET FILES_OUT=T:\PTK_PSD_IN
SET VERBA=C:\KEYS\tnb
SET BIK3=714
SET ABONENT=0115

SET SCSIGN_PATH="C:\Program Files\MGTU Bank of Russia\SignatureSC"
SET TEMP_PATH=C:\temp
REM ------------

REM �������������� ������ ������
del /q %TEMP_PATH%\filelist.txt
for /f %%i in ('dir /b /a-d %FILES_IN%\*.%BIK3%') do echo %FILES_IN%\%%i >> %TEMP_PATH%\filelist.txt

REM �������������� �����
subst a: /d
subst a: %VERBA%
REM C:\windows\asrkeyw.exe
%SCSIGN_PATH%\SCSignEx.exe -d -l%TEMP_PATH%\filelist.txt -b0 -o%TEMP_PATH%\ScSignEx.log

REM ������� � ��� ��� ��
%SCSIGN_PATH%\SCSignEx.exe -r -l%TEMP_PATH%\filelist.txt -b0 -o%TEMP_PATH%\ScSignEx.log

REM ���������� �������������� �����
for /f "delims=" %%i in (%TEMP_PATH%\filelist.txt) do move /y %%i %FILES_OUT%

REM ������� ��������� ����
del /q %TEMP_PATH%\filelist.txt