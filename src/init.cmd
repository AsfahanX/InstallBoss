REM ====================================================================
REM INIT



%LOG%.
%LOG% --------------------------------
%LOG% START %DATE% %TIME%

CALL:get_hash "%~f0" sha256 sha_256_hash
CALL:get_windows_number windows_number
CALL:get_windows_bit windows_bit


REM Check administrator
net session >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    call:echo_color_nonewline "WARNING " %COLOR_YELLOW% 
    echo Script not running as Administrator ^^!
    echo Some app require administrator rights to be installed.
    echo.
    SET input_confirm=Y
    SET /P input_confirm="Restart as administrator [Y/n] ? "
    IF /I "!input_confirm!"=="Y" (
        start "Restarting as administrator" /D "%CD%" powershell -command "& {Start-Process -FilePath '%script_fullname%' -WorkingDirectory '%CD%' -Verb RunAs}"
        exit /b
    )
    echo.
)

REM Check INI file
IF NOT EXIST "%params_ini_file%" (
    echo creating default INI file . . .
    %LOG% Creating default INI file
    CALL:create_default_ini_file "%params_ini_file%"
)

echo Loading INI file . . .
call:get_ini_content "%params_ini_file%" IniContent
echo.

REM set "IniContent[Winrar kosong]"
REM call:copy_var "IniContent[Winrar kosongg]" new_var
REM echo with copy_var:
REM echo exit code: %errorlevel%
REM set new_var
REM pause
REM exit /b

REM TODO Detect first run
SET /A "folder_found=0"
FOR /F "delims=" %%G in ('DIR "%search_location%" /ad-h /B ^| findstr /v /r /c:"^[.]"') DO (
    SET /A "folder_found=1"
)
IF %folder_found% EQU 0 (
    SET "input_yes_no=N"
    SET /P input_yes_no="Buat Contoh Struktur Folder [y/N] ? "
    IF /I "!input_yes_no!"=="y" (
        call:create_example_folder_structure
    )
)

rem Load All AppCfg in search_location
IF %preload_app_cfg% EQU 1 (
    echo Loading App's Configuration . . .
    DIR "%search_location%" /A:D-H /O:N /B | findstr /v /r /c:"^[.]">"%paket_semua_folder_file%"
    %ECHO_VERBOSE% Load All AppCfg in %search_location%
    FOR /F "delims=" %%G in ('type "%paket_semua_folder_file%"') DO (
        call:get_appcfg IniContent "%%G" "AppCfg[%%G]"
    )
)

REM Calculate string length of All App's name in search_location
REM %ECHO_VERBOSE% Calculating String length 
REM SET "AppName.MaxLength=0"
REM SET "string_length="
REM FOR /F "delims=" %%G in ('type "%paket_semua_folder_file%"') DO (
REM     CALL:strLen "%%G" string_length
REM     IF !string_length! GTR !AppName.MaxLength! SET "AppName.MaxLength=!string_length!"
REM     SET "AppName[%%G].StringLength=!string_length!"
REM )
REM set AppName

REM %ECHO_VERBOSE% Preparing Line String
REM call:init_line_string - 50 LINE_STRING
REM Set LINE_STRING
REM pause

REM set AppCfg
REM pause
REM exit /b
