:repeat_char char count retvar
SetLocal EnableExtensions EnableDelayedExpansion
SET "char=%~1"
SET "count=%~2"
SET "retvar=%~3"
SET "result="
IF DEFINED repeat_char_chace[%char%][%count%] (
    SET "result=!repeat_char_chace[%char%][%count%]!"
) ELSE (
    FOR /L %%A in (1,1,%count%) do (
        SET "result=!result!%char%"
    )
)
REM FOR /L %%A in (1,1,%count%) do (
    REM SET "result=!result!%char%"
REM )
(ENDLOCAL & REM -- RETURN VALUES
    IF "%retvar%" NEQ "" SET "%retvar%=%result%"
    SET "repeat_char_chace[%char%][%count%]=%result%"
    REM IF "%new_pkg_file%" NEQ "" SET "%new_pkg_file%=%paket_file%"
)
EXIT /B %errorlevel%
