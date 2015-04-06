SET WORK_DIR=c:\script

REM---------------------
C:\windows\asrkeyw.exe

:1
call %WORK_DIR%\311p-crypt.cmd
call %WORK_DIR%\311p-uncrypt.cmd
call %WORK_DIR%\364p-crypt.cmd
call %WORK_DIR%\364p-uncrypt.cmd
call %WORK_DIR%\365p-crypt.cmd
call %WORK_DIR%\365p-uncrypt.cmd
call %WORK_DIR%\321p-crypt.cmd
call %WORK_DIR%\321p-uncrypt.cmd
call %WORK_DIR%\1459u-crypt.cmd
call %WORK_DIR%\1459u-uncrypt.cmd
call %WORK_DIR%\spr_ul_ved-uncrypt.cmd
call %WORK_DIR%\base64\pbase64.cmd
call %WORK_DIR%\copy_cbp.cmd
call %WORK_DIR%\311p-auto-uncrypt.cmd
call %WORK_DIR%\365p-auto-uncrypt.cmd


REM Пауза 5 секунд
PING -n 5 127.0.0.1 >nul
goto 1