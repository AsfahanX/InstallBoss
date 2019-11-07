:initProgress max format -- initializes an internal progress counter and display the progress in percent
::                       -- max    [in]     - progress counter maximum, equal to 100 percent
::                       -- format [in,opt] - title string formatter, default is '[P] completed.'
:$created 20060101 :$changed 20080327 :$categories Progress
:$source https://www.dostips.com
set /a "ProgressCnt=-1"
set /a "ProgressMax=%~1"
CALL:format_num %ProgressMax% FormattedProgressMax
set "ProgressFormat=%~2"
if not defined ProgressFormat set "ProgressFormat=[PPPP]"
set "ProgressFormat=%ProgressFormat:[PPPP]=[P]%"
call:doProgress
EXIT /b

REM ==================================================================================
REM DO PROGRESS
:doProgress -- displays the next progress tick
:$created 20060101 :$changed 20080327 :$categories Progress
:$source https://www.dostips.com
set "extra=%~1"
set /a "ProgressCnt+=1"
SETLOCAL ENABLEDELAYEDEXPANSION
set /a "per100=100*ProgressCnt/ProgressMax"
set /a "per10=per100/10"
set /a "per10m=10-per100/10-1"
set "P=%per100%%%"
set "PP="
for /l %%N in (0,1,%per10%) do call set "PP=%%PP%%*"
for /l %%N in (%per10%,1,9) do call set "PP=%%PP%% "
set "PPP="
for /l %%N in (0,1,%per10m%) do call set "PPP=%%PPP%%*"
set "ProgressFormat=%ProgressFormat:[P]=!P!%"
set "ProgressFormat=%ProgressFormat:[PP]=!PP!%"
set "ProgressFormat=%ProgressFormat:[PPP]=!PPP!%"

CALL:format_num %ProgressCnt% FormattedProgressCnt
set "ProgressFormat=%ProgressFormat:[C]=!FormattedProgressCnt!%"
set "ProgressFormat=%ProgressFormat:[M]=!FormattedProgressMax!%"
IF "%~1" NEQ "" (
    set "extra=!extra:[C]=%FormattedProgressCnt%!"
    set "extra=!extra:[M]=%FormattedProgressMax%!"
)
title %ProgressFormat% %extra%
EXIT /b
