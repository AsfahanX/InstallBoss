REM ====================================================================
REM CONSTANTS

CALL:init_color_code
CALL:init_error_code

SET "_MODE_INSTALL=1"
SET "_MODE_TEST=2"

SET "COMMENT_CHAR=;"
SET "google_search=https://www.google.com/search?q="
SET "latest_release_url=https://github.com/asfahann/InstallBoss/releases/latest"
SET "latest_release_binary=https://github.com/asfahann/InstallBoss/releases/latest/download/InstallBoss.cmd"

SET /A "VERBOSE_LEVEL_ERROR=1"
SET /A "VERBOSE_LEVEL_WARNING=2"
SET /A "VERBOSE_LEVEL_INFO=3"



SET "install_mode=%_MODE_TEST%"

REM ====================================================================
REM APPLICATION SETTINGS

SET script_fullname=%~f0
SET script_path=%~dp0
SET script_path=%script_path:~0,-1%
SET script_file_name=%~nx0
SET script_base_name=%~n0

REM Configuration file
SET ini_file=%script_path%\%script_base_name%.params.ini
SET "params_ini_file=%~dpn0.params.ini"

rem Log files
SET log_file="%~dpn0.log"
SET error_log_file="%~dpn0.error.log"

REM Temporary files
SET "tmp_folder=%TMP%\%~n0"
SET "tmp_params_ini_file=%tmp_folder%\%~n0.params.ini.tmp"
SET "exit_codes_file=%tmp_folder%\%~n0.exit_codes.tmp"
SET "paket_semua_folder_file=%tmp_folder%\%~n0.paket.all.tmp"
SET "tmp_html_file=%tmp_folder%\display_links.html"

SET "no_wait_installers_file=%tmp_folder%\%~n0.no_wait_installers.tmp"
SET "no_wait_installers_finished=%tmp_folder%\%~n0.no_wait_installers_finished.tmp"

SET "no_wait_installers_exit_codes_file=%tmp_folder%\%~n0.no_wait_installers_exit_codes.tmp"

IF NOT EXIST "%tmp_folder%" MD "%tmp_folder%"
DEL /Q "%tmp_folder%\*"

REM ====================================================================
REM USER SETTINGS
SET "search_location=%~1"
IF NOT DEFINED search_location (
    SET "search_location=%~dp0"
    SET search_location=!search_location:~0,-1!
)
SET /A "preload_app_cfg=0"
SET "SETTINGS_VERBOSE_LEVEL=5"
SET "default_msi_param=/passive /norestart"

SET "verbose=0"
SET "debug=0"

SET /A "suppress_error=0"

SET "param_tipe_1=/S"
SET "param_tipe_2=/S /IEN"
SET "param_tipe_3=/VERYSILENT /SUPPRESSMSGBOXES /NORESTART"

SET "STREAM_HANDLE_FOR_LOG=3"
SET "STREAM_HANDLE_FOR_INTERNAL_ERROR=4"

REM Handle 3 redirected to log file
REM SET "LOG=1>&%STREAM_HANDLE_FOR_LOG% echo"
SET "LOG=1>> %log_file% echo"
SET "LOG_ERR=2>> %log_file% echo"
SET "LOG_RAW=1>&%STREAM_HANDLE_FOR_LOG%"

SET "ECHO_VERBOSE=REM ."
IF "%verbose%" EQU "1" SET "ECHO_VERBOSE=echo [VERBOSE]"

SET "ECHO_DEBUG=REM ."
IF "%debug%" EQU "1" SET "ECHO_DEBUG=echo [DEBUG]"