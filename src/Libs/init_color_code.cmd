:init_color_code
SET COLOR_BLACK=30
SET COLOR_RED=31
SET COLOR_GREEN=32
SET COLOR_YELLOW=33
SET COLOR_BLUE=34
SET COLOR_MAGENTA=35
SET COLOR_CYAN=36
SET COLOR_WHITE=37

SET COLOR_WHITE_STRONG=90
SET COLOR_RED_STRONG=91
SET COLOR_GREEN_STRONG=92
SET COLOR_YELLOW_STRONG=93
SET COLOR_BLUE_STRONG=94
SET COLOR_MAGENTA_STRONG=95
SET COLOR_CYAN_STRONG=96
SET COLOR_WHITE_STRONG=97

EXIT /B

:print_all_color
FOR /F "tokens=1* delims==" %%A in ('SET COLOR_') DO (
    call:echo_color_nonewline "%%B" %%B
    call:echo_color " %%A" %%B
)
exit /b

:echo_color str color_code
IF "%windows_number%"=="10" (
    echo.[%~2m%~1[0m
) ELSE (
    echo.%~1
)
Exit /b

:echo_color_nonewline str color_code
IF "%windows_number%"=="10" (
    set /p ="[%~2m%~1[0m" < nul
) ELSE (
    set /p ="%~1" < nul
)
Exit /b

:echo_no_newline string
set /p ="%~1" < nul
Exit /b

:str_color str color_code retvar
IF "%windows_number%"=="10" (SET %~3=[%~2m%~1[0m) ELSE SET "%~3=%~1"
EXIT /B
