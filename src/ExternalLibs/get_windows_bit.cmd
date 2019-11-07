:get_windows_bit outResult
SetLocal EnableExtensions EnableDelayedExpansion
SET "outResult=%~1"

REM Set _os_bitness=64
REM IF %PROCESSOR_ARCHITECTURE% == x86 (
    REM IF NOT DEFINED PROCESSOR_ARCHITEW6432 Set _os_bitness=32
REM )

IF DEFINED PROGRAMFILES^(X86^) (
    SET /A "windows_bit=64"
) ELSE (
    SET /A "windows_bit=32"
)
IF DEFINED outResult (
    EndLocal & REM -- RETURN VALUES
    SET /A "%outResult%=%windows_bit%"
) ELSE (
    EndLocal & REM -- RETURN VALUES
    ECHO %windows_bit%
)

EXIT /b
