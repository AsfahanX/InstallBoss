:install_2 app_name ptr_app_cfg
%LOG% Installing %~1
SetLocal EnableExtensions EnableDelayedExpansion
SET "app_name=%~1"
SET "ptr_app_cfg=%~2"

SET "exit_code=0"

SET /A "prepared=0"
IF DEFINED ptr_app_cfg (
    REM SET "%ptr_app_cfg%" > nul 2>&1
    CALL:copy_var "%ptr_app_cfg%" app_cfg
    IF !ERRORLEVEL! EQU 0 (
        SET /A "prepared=1"
    )
)
REM IF NOT DEFINED ptr_app_cfg (
    REM SET "op_or_check=1"
REM ) ELSE (
    REM IF NOT DEFINED %ptr_app_cfg% (SET "op_or_check=1") else set "%ptr_app_cfg%"
REM )
IF %prepared% NEQ 1 (
    %LOG% Getting app's configuration
    REM CALL:get_app_inst_cfg "%params_ini_file%" "%app_name%" app_cfg
    CALL:get_appcfg IniContent "%app_name%" app_cfg
    SET "exit_code=!ERRORLEVEL!"
    REM SET "ptr_app_cfg=app_cfg"
)
REM ) ELSE (
REM     %LOG% App's configuration already loaded
REM     REM copy variable attributes
REM     REM SET "%ptr_app_cfg%"
REM     SET "%ptr_app_cfg%" > nul
REM     IF !ERRORLEVEL! EQU 0 (
REM         FOR /F "tokens=1,* delims=." %%A in ('SET "%ptr_app_cfg%"') do (
REM             IF "%%B" NEQ "" SET "app_cfg.%%B"
REM         )
REM     ) ELSE (
REM         CALL:echo_err "UNKNOWN ERROR"
REM     )
REM )

SET "exit_code=%app_cfg.status_code%"
echo Installing %app_cfg.desc% . . . . .
IF %exit_code% NEQ 0 (
    CALL:echo_err [ERROR]
    CALL:get_error_description %exit_code% desc
    CALL:echo_err "!desc!"
    goto:install_2__end
)
REM SET "exit_codes_file=%~dpn0.exit_codes.tmp"
REM type nul > "%exit_code_file%"
REM IF EXIST "%exit_code_file%" (
    REM >&2 Can't create file %exit_code_file%
REM )
SET "start_command=START "%~n0 - Installing %app_cfg.desc%" /D "%app_cfg.installer_dir%" /WAIT "%app_cfg.installer_file%" %app_cfg.param%"
IF "%install_mode%"=="%_MODE_TEST%" (
    REM %LOG% Test echoing command START "Installing %app_cfg.desc%" /D "%app_cfg.installer_dir%" %app_cfg.wait% "%app_cfg.installer_dir%\%app_cfg.installer_file%" %app_cfg.param%
    REM echo START "Installing %app_cfg.desc%" /D "%app_cfg.installer_dir%" %app_cfg.wait% "%app_cfg.installer_dir%\%app_cfg.installer_file%" %app_cfg.param%
    REM IF DEFINED app_cfg.wait (
    IF /I "%app_cfg.wait%" EQU "false" (
        %LOG% Test echoing command %start_command%
        echo %start_command%
    ) ELSE (
        REM SET "new_start_command=START "%~n0 - Installing %app_cfg.desc%" /D "%app_cfg.installer_dir%" /MIN cmd /v /c "(echo Executing %app_cfg.installer_file% %app_cfg.param%) & (%start_command%) & (echo ^!ERRORLEVEL^!> "%tmp_folder%\%app_name%.exit_code.tmp")""
        REM set new_start_command
        REM pause
        REM %LOG% "Test echoing command %new_start_command%"
        REM echo "%new_start_command%"
        echo "%start_command%"
    )
    
) ELSE IF "%install_mode%"=="%_MODE_INSTALL%" (
    echo Executing %app_cfg.installer_file% %app_cfg.param%
    REM %LOG% Executing command START "Installing %app_cfg.desc%" /D "%app_cfg.installer_dir%" %app_cfg.wait% "%app_cfg.installer_dir%\%app_cfg.installer_file%" %app_cfg.param%
    REM START "Installing %app_cfg.desc%" /D "%app_cfg.installer_dir%" %app_cfg.wait% "%app_cfg.installer_dir%\%app_cfg.installer_file%" %app_cfg.param%
    
    REM IF DEFINED app_cfg.wait (
    IF /I "%app_cfg.wait%" EQU "true" (
        %LOG% Executing command %start_command%
        %start_command%
    ) ELSE (
        REM WAIT=FALSE
        REM Start another cmd to capture exit code of app's installation
        %LOG% Executing command START "Installing %app_cfg.desc%" /D "%app_cfg.installer_dir%" /MIN cmd /v /c "(echo Don't Close this window...) & (%start_command%) & (echo Exit Code:^^!ERRORLEVEL^^!) & pause"
        REM START "%~n0 - Installing %app_cfg.desc%" /D "%app_cfg.installer_dir%" /MIN cmd /v /c "(echo Executing %app_cfg.installer_file% %app_cfg.param%) & (%start_command%) & SET /A "exit_code=ERRORLEVEL" & (echo Exit Code:^!ERRORLEVEL^! >exit_code.txt) & (echo Exit Code:^!ERRORLEVEL^!) & (echo %google_search%^!ERRORLEVEL^!) & pause"
        echo.%app_name%>> "%no_wait_installers_file%"
        START "%~n0 - Installing %app_cfg.desc%" /D "%app_cfg.installer_dir%" /MIN cmd /v /c "(echo Executing %app_cfg.installer_file% %app_cfg.param%) & (%start_command%) & (echo ^!ERRORLEVEL^!> "%tmp_folder%\%app_name%.exit_code.tmp")"
    )
    
    SET /A "exit_code=!ERRORLEVEL!"
    %LOG% Exit Code !exit_code!
)

IF %exit_code% NEQ 0 (
    CALL:echo_err ERROR
    CALL:get_error_description %exit_code% desc
    CALL:echo_err "!desc!"
    goto:install_2__end
)

REM @echo off
:install_2__end
(ENDLOCAL & REM -- RETURN VALUES
    EXIT /B %exit_code%
)
