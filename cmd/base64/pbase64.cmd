SET FROM=T:\EXG\wrk
SET TO=Z:\Операционный отдел\РКЦ\IN
REM SET TO=T:\EXG\wrk\pbase64
SET BASE64=C:\script\base64\pbase64.exe

REM ---------------
if not exist %FROM%\*.ed if not exist %FROM%\*.eds goto 1

for /f %%i in ('dir /b /a-d %FROM%\*.*') do (
%BASE64% -p %FROM%\%%i temp
move /y "%FROM%\%%i" "%TO%\%%i"
)

:1