:get_windows_number outResult
SetLocal EnableExtensions EnableDelayedExpansion
SET "outResult=%~1"

SET "command=reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion" /v "ProductName""
FOR /F "tokens=4 delims=,	 " %%A in ('%command%') DO SET /A "windows_number=%%~A"

IF DEFINED outResult (
    EndLocal & REM -- RETURN VALUES
    SET /A "%outResult%=%windows_number%"
    REM set "%outResult%=7"
) ELSE (
    EndLocal & REM -- RETURN VALUES
    ECHO %windows_number%
)

EXIT /b
