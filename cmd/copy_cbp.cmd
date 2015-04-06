SET FILES_PATH=L:\POST\ELO\OUT
SET OUT311=L:\CRYPT\AUTODEC\311\IN\
SET OUT365=L:\CRYPT\AUTODEC\365\IN\
SET BIK3=714

SET YYYY=%DATE:~6,4%
SET MM=%DATE:~3,2%
SET DD=%DATE:~0,2%
SET ARCH=%FILES_PATH%\archive\%YYYY%\%MM%\%DD%\

cd /d %FILES_PATH%
if not exist 2z*.%BIK3% goto mz
if not exist %ARCH% md %ARCH%
for /f %%i in ('dir /b /a-d 2z*.%BIK3%') do copy /y %%i %OUT311% && move /y %%i %ARCH%

:mz
if not exist mz*.%BIK3% goto end
if not exist %ARCH% md %ARCH%
for /f %%i in ('dir /b /a-d mz*.%BIK3%') do copy /y %%i %OUT365% && move /y %%i %ARCH%

:end