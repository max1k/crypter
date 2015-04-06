SET FILES_PATH=L:\CRYPT\365-P\OUT
SET VERBA=C:\KEYS\tnb
SET SCHEME1=C:\KEYS\scheme1
SET ABONENT=0020
SET BIK3=714

SET ARJ="L:\PTK PSD\arj\ARJ.EXE"
SET SCSIGN_PATH="C:\Program Files\MGTU Bank of Russia\SignatureSC"
SET TEMP_PATH=C:\temp
SET PAUSE=PING -n 10 127.0.0.1 >nul

REM ------------
SET COPYTO=S:\CBP\365P\OUT
copy /y %FILES_PATH%\*.txt %COPYTO%
REM ------------

cd /D %FILES_PATH%

if not exist %FILES_PATH%\*.txt if not exist %FILES_PATH%\*.vrb goto 1

%PAUSE%

REM �������������� ������ ������ - ����� ��������� ��� ��� �����
del /q %TEMP_PATH%\filelist.txt
for /f %%i in ('dir /b /a-d %FILES_PATH%\*.txt') do echo %FILES_PATH%\%%i >> %TEMP_PATH%\filelist.txt
for /f %%i in ('dir /b /a-d %FILES_PATH%\*.vrb') do echo %FILES_PATH%\%%i >> %TEMP_PATH%\filelist.txt

REM ����������� ��
subst a: /d
subst a: %VERBA%
REM C:\windows\asrkeyw.exe
%SCSIGN_PATH%\SCSignEx.exe -s -l%TEMP_PATH%\filelist.txt -b0 -o%TEMP_PATH%\ScSignEx.log

rem ��������������� �����, ������� ����� �����������
cd /d %FILES_PATH%
ren BOS*.txt *.vrb
ren BV*.txt *.vrb
ren BNS*.txt *.vrb

REM �������������� ������ ������ - ����� ����������� ������ *.vrb
del /q %TEMP_PATH%\filelist.txt
for /f %%i in ('dir /b /a-d %FILES_PATH%\*.vrb') do echo %FILES_PATH%\%%i >> %TEMP_PATH%\filelist.txt

REM ������� �� ��� ����� � ����������� *.vrb
subst a: /d
subst a: %SCHEME1%
if exist %TEMP_PATH%\filelist.txt %SCSIGN_PATH%\SCSignEx.exe -e -a%ABONENT% -l%TEMP_PATH%\filelist.txt -b0 -o%TEMP_PATH%\ScSignEx.log

REM ����������� ��� � �����
%ARJ% m -ey AFN_1806%BIK3%_MIFNS00_%DATE:~6,4%%DATE:~3,2%%DATE:~0,2%_001.arj *.txt *.vrb

REM ����������� �� �� ����� - ��������� ������ �������
del /q %TEMP_PATH%\filelist.txt
for /f %%i in ('dir /b /a-d %FILES_PATH%\AFN*.arj') do echo %FILES_PATH%\%%i >> %TEMP_PATH%\filelist.txt

REM ����������� �� �� �����
subst a: /d
subst a: %VERBA%
REM C:\windows\asrkeyw.exe
%SCSIGN_PATH%\SCSignEx.exe -s -l%TEMP_PATH%\filelist.txt -b0 -o%TEMP_PATH%\ScSignEx.log

REM ������� ��������� ����
del /q %TEMP_PATH%\filelist.txt
subst a: /d

:1