:get_appcfg IniContentVar SectionName OutVar
REM ==================================================================================
REM FUNCTION GET APP'S INSTALLATION CONFIGURATION
REM - version 1.0
REM - desc : Get App's Installation Configuration
REM - params:
REM     -- [IN]     base_dir		 - Directory to search
REM     -- [IN]     regex			 - regex of findstr command
REM     -- [OUT]    retvar			 - Var to store Return Value.

IF "%ECHO_VERBOSE%" NEQ "" %ECHO_VERBOSE% Begin get_appcfg %*
SetLocal EnableExtensions EnableDelayedExpansion

SET "IniContentVar=%~1"
SET "SectionName=%~2"
SET "OutVar=%~3"

SET "SectionVar=%IniContentVar%[%SectionName%]"
SET /A "exit_code=0"

SET "cfg_installer_dir=!%SectionVar%[installer_dir]!"
SET "cfg_specific_windows_number="
SET "cfg_specific_windows_bit="
SET "cfg_installer_file=!%SectionVar%[installer_file]!"
SET "cfg_wait=!%SectionVar%[wait]!"
SET "cfg_param=!%SectionVar%[param]!"
SET "cfg_param_quiet=!%SectionVar%[param_quiet]!"
SET "cfg_crack_dir=!%SectionVar%[crack_dir]!"
SET "cfg_crack_file=!%SectionVar%[crack_file]!"
SET "cfg_crack_dst=!%SectionVar%[crack_dst]!"
SET "cfg_extra_script=!%SectionVar%[extra_script]!"
SET /A "cfg_status_code=0"
SET "cfg_status=Ready"
SET "cfg_desc=%SectionName%"

IF "!%IniContentVar%[%SectionName%].Exist!" NEQ "1" (
    SET /A "exit_code=1"
    SET "cfg_status=INI Section Not Found"
    goto:get_appcfg__end
)

:get_appcfg__installer_dir
IF DEFINED cfg_installer_dir (
    REM If not absolute path
    set "char=%cfg_installer_dir:~1,1%"
    IF "!char!" NEQ ":" (
        SET "installer_dir=%search_location%\%SectionName%\%installer_dir%"
    )
    IF NOT EXIST "!cfg_installer_dir!" (
        rem installer_dir not found
        %LOG% Specified installer_dir not found: !cfg_installer_dir!
        SET /A "exit_code=1"
        SET "cfg_status=Specified Folder Not Found"
        goto:get_appcfg__end
    )
) ELSE (
    SET "cfg_installer_dir=%search_location%\%SectionName%"
    IF NOT EXIST "!cfg_installer_dir!" (
        rem installer_dir not found
        %LOG% installer_dir not found: !cfg_installer_dir!
        SET /A "exit_code=1"
        SET "cfg_status=Folder Not Found"
        goto:get_appcfg__end
    )
)

REM Specific Win7 Win8 Win10 folder
IF EXIST "%cfg_installer_dir%\Win %windows_number%" (
    SET "cfg_installer_dir=%cfg_installer_dir%\Win %windows_number%"
    SET "cfg_specific_windows_number=%windows_number%"
    SET "cfg_desc=%cfg_desc% [Win %windows_number%]"
)

REM Specific 32 64 folder
IF %windows_bit% EQU 32 (SET /A "windows_bit_inverse=64") ELSE SET /A "windows_bit_inverse=32"
SET "cfg_specific_windows_bit="
SET /A "other_win_bit_found=0"
IF EXIST "%cfg_installer_dir%\%windows_bit%" (
    SET "cfg_installer_dir=%cfg_installer_dir%\%windows_bit%"
    SET "cfg_specific_windows_bit=%windows_bit%"
    SET "cfg_desc=%cfg_desc% [%windows_bit%-bit]"
) ELSE IF EXIST "%cfg_installer_dir%\%windows_bit_inverse%" SET /A "other_win_bit_found=1"

REM Installer File
SET "tmp_cfg_installer_file="
IF DEFINED cfg_installer_file (
    REM Check absolute path
    set "char=%cfg_installer_file:~1,1%"
    IF "!char!" NEQ ":" (
        rem relative path
        SET "cfg_installer_file=%installer_dir%\%cfg_installer_file%"
    )
    IF NOT EXIST "!cfg_installer_file!" (
        %LOG% Specified installer_file not found: !cfg_installer_file!
        SET /A "exit_code=1"
        SET "cfg_status=Specified Installer File Not Found"
        goto:get_appcfg__end
    )
) ELSE (
    %LOG% Searching Installer file
    CALL:search_installer_file "%cfg_installer_dir%" cfg_installer_file
    IF !ERRORLEVEL! NEQ 0 (
        %LOG% Can't find any
        SET /A "exit_code=3"
        SET "cfg_status=Installer File Not Found"
        REM CALL:str_color "INSTALLER FILE NOT FOUND" %COLOR_RED% cfg_status
        goto:get_appcfg__end
    ) ELSE (
        %LOG% Found !cfg_installer_file!
    )
)

REM Default is true
IF /I "%cfg_wait%" EQU "false" (
    SET "cfg_wait=false"
) ELSE SET "cfg_wait=true"

REM Parameter
IF NOT DEFINED cfg_param (
    call:get_default_param "%cfg_installer_file%" cfg_param
    IF "!cfg_param!" EQU "" (
        %LOG% No Params
        SET /A "exit_code=3"
        SET "cfg_status=No Parameter"
        REM CALL:str_color "PARAM NOT SPECIFIED" %COLOR_RED% cfg_status
        goto:get_appcfg__end
    )
)

IF NOT DEFINED cfg_crack_dst (
    SET "cfg_crack_dst=%ProgramFiles%\%SectionName%"
)
IF NOT EXIST "%cfg_crack_dst%" (
    rem TODO
)

:get_appcfg__end
(ENDLOCAL & REM -- RETURN VALUES
    IF "%OutVar%" NEQ "" (
        SET "%OutVar%.is_loaded=1"
        SET "%OutVar%.installer_dir=%cfg_installer_dir%"
        SET "%OutVar%.specific_windows_number=%cfg_specific_windows_number%"
        SET "%OutVar%.specific_windows_bit=%cfg_specific_windows_bit%"
        SET "%OutVar%.installer_file=%cfg_installer_file%"
        SET "%OutVar%.wait=%cfg_wait%"
        SET "%OutVar%.param=%cfg_param%"
        SET "%OutVar%.crack_file=%cfg_crack_file%"
        SET "%OutVar%.crack_dst=%cfg_crack_dst%"
        SET "%OutVar%.status=%cfg_status%"
        SET "%OutVar%.status_code=%exit_code%"
        SET "%OutVar%.desc=%cfg_desc%"
    )
    EXIT /B %exit_code%
)
