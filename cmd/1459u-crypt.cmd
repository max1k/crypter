SET FILES_PATH=L:\CRYPT\1459-U\OUT
SET VERBA=C:\KEYS\tnb

SET SCSIGN_PATH="C:\Program Files\MGTU Bank of Russia\SignatureSC"
SET TEMP_PATH=C:\temp
SET PAUSE=PING -n 10 127.0.0.1 >nul
SET CUR_DATE=%DATE:~0,2%.%DATE:~3,2%.%DATE:~6,4%
REM ------------

cd /D %FILES_PATH%

if not exist %FILES_PATH%\*.xml if not exist %FILES_PATH%\*.arj goto 1
%PAUSE%

REM �����⠢������ ᯨ᮪ 䠩��� - �㦭� �������� ��� �� 䠩��
del /q %TEMP_PATH%\filelist.txt
for /f %%i in ('dir /b /a-d %FILES_PATH%\*.arj') do echo %FILES_PATH%\%%i >> %TEMP_PATH%\filelist.txt
for /f %%i in ('dir /b /a-d %FILES_PATH%\*.xml') do echo %FILES_PATH%\%%i >> %TEMP_PATH%\filelist.txt

REM ���⠢�塞 �� �� 䠩�� *.xml � *.arj
subst a: /d
subst a: %VERBA%
%SCSIGN_PATH%\SCSignEx.exe -s -l%TEMP_PATH%\filelist.txt -b0 -o%TEMP_PATH%\ScSignEx.log

REM ��६�頥� ��娢� � ����� PROCESS
if not exist %FILES_PATH%\PROCESS md %FILES_PATH%\PROCESS
for /f "delims=" %%i in (%TEMP_PATH%\filelist.txt) do move /y "%%i" "%FILES_PATH%\PROCESS"

REM ����塞 �६���� 䠩�
del /q %TEMP_PATH%\filelist.txt
subst a: /d

:1