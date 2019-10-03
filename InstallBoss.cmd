@echo off
CD /D "%~dp0"
REM CALL:install_3 nama_saya_adalah="oke" jadi tidak apa ya
REM CALL:install_3 base_dir:"Google Chrome" param:"/passive /norestart" wait:0 
REM call:echo_no_newline "ini satu baris"
REM call:echo_no_newline " "masih" satu baris"
REM pause
REM exit /b

REM.-- Prepare the Command Processor
SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION

REM.-- Version History --
REM         0.1           20191003 Author Asfahann
SET version=0.1-beta & rem 20191003 p.h.  initial version, providing the framework
REM !! For a new version entry, copy the last entry down and modify Date, Author and Description
SET version=%version: =%

REM.-- Set the window title 
SET title=%~n0
TITLE %title%

REM ====================================================================
REM CONSTANTS
SET "_MODE_INSTALL=1"
SET "_MODE_TEST=2"

SET "COMMENT_CHAR=;"
SET "google_search=https://www.google.com/search?q="

CALL:init_error_code

SET "VERBOSE_LEVEL_ERROR=1"
SET "VERBOSE_LEVEL_WARNING=2"
SET "VERBOSE_LEVEL_INFO=3"

CALL:init_color_code

SET "install_mode=%_MODE_TEST%"

REM ====================================================================
REM SETTINGS
SET "SETTINGS_VERBOSE_LEVEL=5"
SET "default_msi_param=/passive"
SET log_file="%~dpn0.log"
SET error_log_file="%~dpn0.error.log"
SET "params_ini_file=%~dpn0.params.ini"
REM SET "tmp_params_ini_file=%params_ini_file%.tmp"

SET "tmp_folder=%TMP%\%~n0"
SET "tmp_params_ini_file=%tmp_folder%\%~n0.params.ini.tmp"
SET "exit_codes_file=%tmp_folder%\%~n0.exit_codes.tmp"
SET "paket_semua_folder_file=%tmp_folder%\%~n0.paket.all.tmp"

SET "no_wait_installers_file=%tmp_folder%\%~n0.no_wait_installers.tmp"
SET "no_wait_installers_finished=%tmp_folder%\%~n0.no_wait_installers_finished.tmp"

SET "no_wait_installers_exit_codes_file=%tmp_folder%\%~n0.no_wait_installers_exit_codes.tmp"

IF NOT EXIST "%tmp_folder%" MD "%tmp_folder%"
DEL /Q "%tmp_folder%\*"
REM CALLREMpaket_install "%~dp0" %tmp_file%


SET "param_tipe_1=/S"
SET "param_tipe_2=/S /IEN"
SET "param_tipe_3=/VERYSILENT /SUPPRESSMSGBOXES /NORESTART"

SET "STREAM_HANDLE_FOR_LOG=3"
SET "STREAM_HANDLE_FOR_INTERNAL_ERROR=4"


REM echo.START %DATE% %TIME% >>%error_log_file%
REM echo.START %DATE% %TIME% >>%log_file%

REM Handle 3 redirected to log file
SET "LOG=1>&%STREAM_HANDLE_FOR_LOG% echo"
REM SET "LOG=1>> %log_file% echo"
SET "LOG_RAW=1>&%STREAM_HANDLE_FOR_LOG%"

CALL:main 2>>%log_file% %STREAM_HANDLE_FOR_LOG%>&2
EXIT /B

:main
REM ====================================================================
REM INIT
REM SetLocal EnableExtensions EnableDelayedExpansion

%LOG%.
%LOG% --------------------------------
%LOG% START %DATE% %TIME%
REM dir s
REM DIR S
REM %LOG% CALL:echo_color "echo color" %COLOR_BLACK%
REM pause
REM exit /b

Title %~n0
IF NOT EXIST "%params_ini_file%" (
    echo creating default params file . . .
    %LOG% Creating default INI file
    CALL:create_default_ini_file "%params_ini_file%"
)
REM findstr /vrc:"^[%COMMENT_CHAR%]" "%params_ini_file%" >"%tmp_params_ini_file%"
CALL:get_windows_number windows_number
CALL:get_windows_bit windows_bit

REM call:echo_color_nonewline "ini satu baris" %COLOR_GREEN%
REM call:echo_color_nonewline " masih satu baris"  %COLOR_GREEN%
REM call:echo_color_nonewline COBA  %COLOR_GREEN%
REM call:echo_color coba %COLOR_RED%
REM pause
REM exit /b


REM SetLocal EnableExtensions EnableDelayedExpansion
REM ====================================================================
REM MAIN MENU
SET "menu_item_prefix=   "

:menu_pilih_paket
SET "pkgs_num=0"
%LOG% Searching paket files
FOR /F "tokens=*" %%A in ('dir "%~dp0" /b /a-d /od ^| findstr /i /r /c:"%~n0[.]paket[.].*txt$"') do (
    SET /A pkgs_num+=1
    SET "tmp_pkgs_filename=%%~nA"
    SET "tmp_pkgs_desc=!tmp_pkgs_filename:%~n0.paket.=!"
    SET "pkgs_!pkgs_num!_file=%%~A"
    SET "pkgs_!pkgs_num!_desc=Paket !tmp_pkgs_desc!"
)
%LOG% Found %pkgs_num% paket

CLS
echo.========================================================
echo.= MENU =================================================
echo.
echo     Paket Instalasi:
FOR /L %%A IN (1,1,%pkgs_num%) DO (
    
    IF %%A LSS 10 SET "prefix=%menu_item_prefix% "
    echo !prefix!%%A. !pkgs_%%A_desc!
)
echo.
echo     Opsi Lainnya:
echo     B  Buat Paket Instalasi Baru
echo     I  Install Semua Folder
echo.
SET "menu_pilih_paket_choice="
SET /P menu_pilih_paket_choice="Pilih Paket Instalasi: "
IF NOT DEFINED menu_pilih_paket_choice goto menu_pilih_paket



REM Paket Semua folder
IF "%menu_pilih_paket_choice%"=="i" SET "menu_pilih_paket_choice=I"
IF "%menu_pilih_paket_choice%"=="I" (
    %LOG% Menu Install Semua Folder is selected
    SET "pkg_desc=Paket Semua Folder"
    SET "pkg_file=%paket_semua_folder_file%"
    DIR /ad-h /B | findstr /v /r /c:"^[.]">"!pkg_file!"
    IF EXIST "!pkg_file!" (
        %LOG% paket file created: !pkg_file!
    ) ELSE (
        >&2 echo Can't create paket file !pkg_file!
    )
    REM attrib +H "%tmp_file%"
    goto:menu_isi_paket
)

REM Buat paket
IF "%menu_pilih_paket_choice%"=="b" SET "menu_pilih_paket_choice=B"
IF "%menu_pilih_paket_choice%"=="B" (
    %LOG% Menu Buat Paket is selected
    CALL:buat_paket pkg_desc pkg_file
    IF EXIST "!pkg_file!" (
        %LOG% paket file created: !pkg_file!
    ) ELSE (
        >&2 echo Can't create paket file !pkg_file!
    )
    SET "pkg_desc=Paket !pkg_desc!
    goto menu_isi_paket
)
IF DEFINED pkgs_%menu_pilih_paket_choice%_file (
    REM Load paket pilihan
    SET "pkg_file=!pkgs_%menu_pilih_paket_choice%_file!"
    SET "pkg_desc=!pkgs_%menu_pilih_paket_choice%_desc!"
    %LOG% paket file selected: !pkg_file!
) ELSE goto menu_pilih_paket


:menu_isi_paket
SET "pkg_length=0"
CALL:echo_verbose 1 "Loading INI file . . ."
%LOG% Loading paket file: !pkg_file!
FOR /F "delims=" %%A in ('type "!pkg_file!"') DO (
    SET /A pkg_length+=1
    SET pkg_item_!pkg_length!=%%A
    SET pkg_item_!pkg_length!_in_menu_text=%%A
)
%LOG% Found %pkg_length% items

REM SET /A "show_param=0"
REM SET /A "show_file=0"
SET /A "show_detail=0"
:menu_display_isi_paket
CLS
echo Found %pkg_length% apps in %pkg_desc%:
echo.
FOR /L %%A IN (1,1,%pkg_length%) DO (
    IF %%A LSS 10 (
        SET "prefix= "
        SET "prefix_ex="
    ) ELSE (
        SET "prefix="
        SET "prefix_ex= "
    )
    echo.  !prefix!%%A. !pkg_item_%%A_in_menu_text!
    REM IF "%show_file%" EQU "1" echo.  !prefix!!prefix_ex!   file  : !pkg_item_%%A.installer_file!
    REM IF "%show_param%" EQU "1" echo.  !prefix!!prefix_ex!   param : !pkg_item_%%A.param!
    IF %show_detail% EQU 1 (
        echo.  !prefix!!prefix_ex!   file  : !pkg_item_%%A.installer_file!
        echo.  !prefix!!prefix_ex!   param : !pkg_item_%%A.param!
        
    )
    
    
)

SET "install_mode=%_MODE_INSTALL%%"
echo.
REM echo ============
REM echo ^|^|  MENU  ^|^|
REM echo ============
echo.========================================================
echo.= MENU =================================================
echo.
echo     Action:
echo     1. Install
echo     2. Test Command
echo     0. Menu Sebelumnya
echo.
echo     Option:
echo     3. Load Config
IF %show_detail% EQU 1 (
    echo     4. Hide Details
) ELSE echo     4. Show Details
echo.
SET /P install_mode="Pilih Menu: "
IF %install_mode%==0 goto menu_pilih_paket
IF %install_mode%==3 (
    %LOG% Menu item selected: 3. Check
    CALL:check_app_cfg
    goto:menu_display_isi_paket
)
IF %install_mode%==4 (
    REM SET "show_param=1"
    REM SET "show_file=1"
    IF %show_detail% EQU 0 (
        SET /A "show_detail=1"
        %LOG% Menu item selected: 4. Show Details
    ) ELSE (
        SET /A "show_detail=0"
        %LOG% Menu item selected: 4. Hide Details
    )
    goto:menu_display_isi_paket
)
IF NOT %install_mode%==%_MODE_INSTALL% (
    IF NOT %install_mode%==%_MODE_TEST% goto:menu_display_isi_paket
)
%LOG% Menu item selected: %install_mode%. 

REM ====================================================================
REM START INSTALLING
REM CALL:initProgress %pkg_length% "[[PPPP]] %~n0"
CALL:initProgress %pkg_length% "[[PPPP]] %~n0 - [[C] of %pkg_length%] Installing"
CLS
SET fail_count=0
FOR /L %%A IN (1,1,%pkg_length%) DO (
    REM CALL:install "!pkg_item_%%A!"
    REM CALL:install_2 "!pkg_item_%%A!" pkg_item_%%A
    echo [%%A/%pkg_length%]
    CALL:install_2 "!pkg_item_%%A!" pkg_item_%%A.
    echo.
    SET /A "pkg_item_%%A_exit_code=!errorlevel!"
    IF !pkg_item_%%A_exit_code! NEQ 0 (SET /A fail_count+=1)
    CALL:doProgress "!pkg_item_%%A!"
    
    
)
echo.

CALL:wait_bg_install

echo.
echo.
echo Done ^^!
echo.

REM Failed Info
IF %fail_count% EQU 0 goto main_end
echo =====================================
REM echo [31mWARNING[0m
CALL:echo_err "WARNING !"
echo %fail_count% apps failed to install
FOR /L %%A IN (1,1,%pkg_length%) DO (
    SET /A code=!pkg_item_%%A_exit_code!
    CALL:get_error_description !code! desc
    IF !code! NEQ 0 (
        echo    %%A. !pkg_item_%%A! ===^> !desc!
    )
)
FOR /L %%A IN (1,1,%bg_proc_num%) DO (
    REM echo    !bg_proc_%%A!. Exit Code: !bg_proc_%%A_exit_code!
    SET /A code=!bg_proc_%%A_exit_code!
    CALL:get_error_description !code! desc
    IF !code! NEQ 0 (
        echo    %%A. !pkg_item_%%A! ===^> !desc!
    )
)

:main_end
EndLocal
echo.
echo 
pause
EXIT /B

:check_app_cfg
rem Get start time:
for /F "tokens=1-4 delims=:.," %%a in ("%time%") do (
   set /A "start=(((%%a*60)+1%%b %% 100)*60+1%%c %% 100)*100+1%%d %% 100"
)
echo.
CALL:echo_verbose 1 "Loading INI file . . ."
FOR /L %%A IN (1,1,%pkg_length%) DO (
    CALL:echo_verbose 2 "Getting configuration for !pkg_item_%%A!"
    CALL:get_app_inst_cfg "%params_ini_file%" "!pkg_item_%%A!" pkg_item_%%A
)

CALL:echo_verbose 1 "Preparing menu display . . ."
REM Get longest string
SET /A longest_str_len=0
FOR /L %%A IN (1,1,%pkg_length%) DO (
    CALL:strLen "!pkg_item_%%A.desc!" str_len
    SET /A "pkg_item_%%A_str_len=!str_len!"
    IF !str_len! GTR !longest_str_len! SET /A "longest_str_len=!str_len!"
)
SET /A max_char=longest_str_len+3
REM Fill char
SET "tmp_str="
FOR /L %%A IN (1,1,%pkg_length%) DO (
    SET /A fill_char_count=max_char-!pkg_item_%%A_str_len!
    CALL:repeat_char - !fill_char_count! fill_char
    REM IF !pkg_item_%%A.status_code! NEQ 0 (
        REM CALL:str_color "!pkg_item_%%A.desc! !fill_char!" tmp_str
    REM ) ELSE SET "tmp_str=!pkg_item_%%A.desc! !fill_char!"
    SET "tmp_str=!pkg_item_%%A.desc! !fill_char!"
    SET "pkg_item_%%A_in_menu_text=!tmp_str! !pkg_item_%%A.status!"
    
)

rem Get end time:
for /F "tokens=1-4 delims=:.," %%a in ("%time%") do (
   set /A "end=(((%%a*60)+1%%b %% 100)*60+1%%c %% 100)*100+1%%d %% 100"
)
rem Get elapsed time:
set /A elapsed=end-start

rem Show elapsed time:
set /A hh=elapsed/(60*60*100), rest=elapsed%%(60*60*100), mm=rest/(60*100), rest%%=60*100, ss=rest/100, cc=rest%%100
if %mm% lss 10 set mm=0%mm%
if %ss% lss 10 set ss=0%ss%
if %cc% lss 10 set cc=0%cc%
echo %hh%:%mm%:%ss%,%cc%
REM pause
EXIT /B


:wait_bg_install
SET /A "delay=1"

SET /A "act_delay=delay+1"
SET /A "bg_proc_num=0"
REM IF NOT EXIST "%no_wait_installers_file%" echo can't find no_wait_installers_file
FOR /F "delims=" %%A in ('type "%no_wait_installers_file%"') do (
    SET /A "bg_proc_num+=1"
    SET "bg_proc_!bg_proc_num!=%%A"
    CALL:strLen "%%A" bg_proc_!bg_proc_num!_str_len
    REM echo Line !bg_proc_num!
)
REM echo bg_proc_num %bg_proc_num%
IF %bg_proc_num% EQU 0 goto:wait_bg_install__end

REM Prepare text to display
SET /A "longest=0"
FOR /L %%A IN (1,1,%bg_proc_num%) DO (
    IF !bg_proc_%%A_str_len! GTR !longest! SET /A "longest=!bg_proc_%%A_str_len!"
)
SET /A "longest+=4"
FOR /L %%A IN (1,1,%bg_proc_num%) DO (
    SET /A "repeat_num=%longest%-!bg_proc_%%A_str_len!"
    CALL:repeat_char - !repeat_num! suffix
    SET "bg_proc_%%A_in_menu_text=%%A. !bg_proc_%%A! !suffix!"
)

SET /A "num_finished=0"
SET /A "new_num_finished=0"
SET /A "first_display=1"
:wait_bg_install_loop
FOR /L %%A IN (1,1,%bg_proc_num%) DO (
    REM IF Exit code file not found
    IF "!bg_proc_%%A_exit_code!" EQU "" (
        SET "exit_code_file=%tmp_folder%\!bg_proc_%%A!.exit_code.tmp"
        IF EXIST "!exit_code_file!" (
            FOR /F %%a in ('type "!exit_code_file!"') DO SET /A "exit_code=%%a"
            SET /A "bg_proc_%%A_exit_code=!exit_code!"
            SET /A "new_num_finished=num_finished+1"
            IF !exit_code! EQU 0 (
                SET "stats=SUCCESS"
            ) ELSE (
                SET /A fail_count+=1
                SET "stats=ERROR. EXIT CODE: !bg_proc_%%A_exit_code!"
            )
        ) ELSE SET "stats=RUNNING"
        SET "bg_proc_%%A_status=!stats!"
    )
)
IF %new_num_finished% EQU %bg_proc_num% goto:wait_bg_install__end
REM IF not the first time and new status is different from before
REM display background installation status
SET /A "bool=0"
IF %first_display% EQU 1 (SET /A "first_display=0" & SET /A "bool=1")
IF %new_num_finished% NEQ %num_finished% (SET /A "bool=1" & SET /A "num_finished=%new_num_finished%")
IF %bool% EQU 1 (
    
    echo Waiting for %bg_proc_num% Background installation:
    FOR /L %%A IN (1,1,%bg_proc_num%) DO (
        echo    !bg_proc_%%A_in_menu_text! !bg_proc_%%A_status!
    )
    echo.
)
ping /n %act_delay% 127.0.0.1>nul
goto:wait_bg_install_loop

REM echo Waiting for Background installation:
REM SET /A "finished_num=0"
REM SET /A "unfinished_num=%lines_num%"
REM FOR /F "delims=" %%A in ('type "%no_wait_installers_file%" ) do (
    REM SET "exit_code_file=%tmp_folder%\%%A.exit_code.tmp"
    REM IF EXIST "!exit_code_file!" (
        REM SET /A "finished_num+=1"
        REM FOR /F %%A in ('type "!exit_code_file!"') DO (
            
        REM )
    REM ) ELSE (
        REM SET /A "unfinished_num+=1"
        REM echo     !unfinished_num!. %%A
    REM )
REM )
REM ping /n 3 127.0.0.1>nul
REM echo.
REM goto:wait_bg_install_loop

:wait_bg_install__end
EXIT /B

REM REM ==============================================================================
REM REM ORIGINAL

REM REM CALL:install ".RUNTIME\Microsoft .NET Framework\.NET Framework 4.7.2" /passive
REM REM CALL:install ".RUNTIME\Java"
REM REM CALL:install ".RUNTIME\DirectX\DirectX End-User Runtimes (June 2010)" /silent dxsetup.exe

REM CALL:install "Google Chrome"
REM CALL:install "Mozilla Firefox" -ms
REM CALL:install "Adobe Flash Player for Firefox, Safari" -install
REM REM CALL:install "Adobe Flash Player for Chrome, Chromium, Opera, UC Browser" -install
REM CALL:install "Adobe Acrobat Reader DC" "-sfx_nu /sALL /msi EULA_ACCEPT=YES"
REM CALL:install "WinRAR\WinRAR.v5.70.kuyhAa.Me" "/S /IEN"
REM REM CALL:install "Internet Download Manager (IDM)" "/S /EN"

REM CALL:install "VLC Media Player" /S
REM CALL:install "K-Lite Codec Pack" "/VERYSILENT /SUPPRESSMSGBOXES /NORESTART"
REM CALL:install "GOM Player" /S AUTO GRETECH\GOMPlayerPlus
REM CALL:install "AIMP" "/AUTO /SILENT"

REM CALL:install "Microsoft Office 2007 SP3" "/adminfile '%~dp0Microsoft Office 2007 SP3\basic.MSP'" AUTO AUTO FALSE
REM CALL:install "Microsoft Office 2016" "/adminfile '%~dp0Microsoft Office 2016\%windows_bit%\basic.MSP'" AUTO AUTO FALSE
REM REM CALL:install "Microsoft Office 2016" "/adminfile '%~dp0Microsoft Office 2016\64\basic.MSP'" AUTO AUTO FALSE
REM REM CALL:install "Microsoft Office 2016" "/adminfile '%~dp0Microsoft Office 2016\32\basic.MSP'" AUTO AUTO FALSE
REM CALL:install "Adobe Photoshop CS 4" "/VERYSILENT /SUPPRESSMSGBOXES /NORESTART"
REM CALL:install "CCleaner" "/S /IT /TM"
REM CALL:install "Format Factory" "/VERYSILENT /I /EN"
REM CALL:install "7Zip"
REM CALL:install "Notepad++" /S

REM REM ORIGINAL
REM REM ==============================================================================

REM REM ==============================================================================
REM REM TEST

REM REM CALL:install ".RUNTIME\Microsoft .NET Framework\.NET Framework 4.7.2" /passive
REM REM CALL:install ".RUNTIME\Java"
REM REM CALL:install ".RUNTIME\DirectX\DirectX End-User Runtimes (June 2010)" /silent dxsetup.exe

REM CALL:install "Google Chrome"
REM CALL:install "Mozilla Firefox"
REM CALL:install "Adobe Flash Player for Firefox, Safari"
REM REM CALL:install "Adobe Flash Player for Chrome, Chromium, Opera, UC Browser" -install
REM CALL:install "Adobe Acrobat Reader DC"
REM CALL:install "WinRAR\WinRAR.v5.70.kuyhAa.Me"
REM REM CALL:install "Internet Download Manager (IDM)" "/S /EN"

REM CALL:install "VLC Media Player"
REM CALL:install "K-Lite Codec Pack"
REM CALL:install "GOM Player"
REM CALL:install "AIMP"

REM CALL:install "Microsoft Office 2007 SP3" "/adminfile '%~dp0Microsoft Office 2007 SP3\basic.MSP'" AUTO AUTO FALSE
REM CALL:install "Microsoft Office 2016" "/adminfile '%~dp0Microsoft Office 2016\%windows_bit%\basic.MSP'" AUTO AUTO FALSE
REM REM CALL:install "Microsoft Office 2016" "/adminfile '%~dp0Microsoft Office 2016\64\basic.MSP'" AUTO AUTO FALSE
REM REM CALL:install "Microsoft Office 2016" "/adminfile '%~dp0Microsoft Office 2016\32\basic.MSP'" AUTO AUTO FALSE
REM CALL:install "Adobe Photoshop CS 4"
REM CALL:install "CCleaner"
REM CALL:install "Format Factory"
REM CALL:install "7Zip"
REM CALL:install "Notepad++"

REM REM TEST
REM REM ==============================================================================

REM CALL:install "" /S AUTO AUTO

:init_error_code
SET /A "_ERR_APP_CFG_NOT_FOUND=101"
SET "_ERR_DESC_101=App's Configuration Not Found"

SET /A "_ERR_INSTALLER_DIR_NOT_FOUND=102"
SET "_ERR_DESC_102=Installer Folder Not Found"

SET /A "_ERR_SPECIFIED_INSTALLER_FILE_NOT_FOUND=103"
SET "_ERR_DESC_103=Specified Installer File Not Found"

SET /A "_ERR_NO_INSTALLER_FILE=104"
SET "_ERR_DESC_104=Can't find any Installer File"

SET /A "_ERR_NO_PARAMS=105"
SET "_ERR_DESC_105=Param Not Specified in INI file"

REM https://ss64.com/nt/start.html
SET /A "_ERR_COMMAND_FAILS=9059"

SET /A "_ERR_ACCESS_DENIED=5"
SET "_ERR_DESC_5=Access Denied"

SET /A "_ERR_ACCESS_DENIED2=1603"
SET "_ERR_DESC_1603=Access Denied"

REM OFFICE Error Code
SET "_ERR_DESC_30012=MsOffice Error: adminfile not found"

EXIT /B

REM ==================================================================================
REM
:get_error_description err_code out_result
SetLocal EnableExtensions EnableDelayedExpansion
SET "err_code=%~1"
SET "out_result=%~2"

SET /A "exit_code=-1"
IF NOT DEFINED _ERR_DESC_%err_code% (
    SET "desc=UNKNOWN ERROR. CODE %err_code%!"
) ELSE (
    SET "desc=!_ERR_DESC_%err_code%!"
    SET /A "exit_code=0"
)

REM IF DEFINED out_result (
    REM EndLocal & REM -- RETURN VALUES
    REM set "%out_result%=%desc%"
REM ) ELSE (
    REM EndLocal & REM -- RETURN VALUES
    REM ECHO %out_result%
REM )
(ENDLOCAL & REM -- RETURN VALUES
    IF "%out_result%" NEQ "" (set "%out_result%=%desc%") ELSE ECHO %out_result%
    EXIT /B %exit_code%
)

:log str
echo.%TIME% %* >>%log_file%
exit /b

:log_err str
echo.%TIME% %~1 >>%error_log_file%
exit /b

REM ==================================================================================
REM INSTALL 
:install_2 app_name ptr_app_cfg
%LOG% Installing %~1
SetLocal EnableExtensions EnableDelayedExpansion
SET "app_name=%~1"
SET "ptr_app_cfg=%~2"

SET "exit_code=0"

SET /A "prepared=0"
IF DEFINED ptr_app_cfg (
    SET "%ptr_app_cfg%" > nul 2>&1
    IF !ERRORLEVEL! EQU 0 SET /A "prepared=1"
)
REM IF NOT DEFINED ptr_app_cfg (
    REM SET "op_or_check=1"
REM ) ELSE (
    REM IF NOT DEFINED %ptr_app_cfg% (SET "op_or_check=1") else set "%ptr_app_cfg%"
REM )
IF %prepared% NEQ 1 (
    %LOG% Getting app's configuration
    CALL:get_app_inst_cfg "%params_ini_file%" "%app_name%" app_cfg
    SET "exit_code=!ERRORLEVEL!"
    SET "ptr_app_cfg=app_cfg"
) ELSE (
    %LOG% App's configuration already loaded
    REM copy variable attributes
    REM SET "%ptr_app_cfg%"
    SET "%ptr_app_cfg%" > nul
    IF !ERRORLEVEL! EQU 0 (
        FOR /F "tokens=1,* delims=." %%A in ('SET "%ptr_app_cfg%"') do (
            IF "%%B" NEQ "" SET "app_cfg.%%B"
        )
    ) ELSE (
        CALL:echo_err "UNKNOWN ERROR"
    )
)
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
    IF DEFINED app_cfg.wait (
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
    
    IF DEFINED app_cfg.wait (
        %LOG% Executing command %start_command%
        %start_command%
    ) ELSE (
        REM WAIT=FALSE
        REM Start another cmd to capture exit code of app's installation
        %LOG% Executing command START "Installing %app_cfg.desc%" /D "%app_cfg.installer_dir%" /MIN cmd /v /c "(echo Don't Close this window...) & (%start_command%) & (echo Exit Code:^^!ERRORLEVEL^^!) & pause"
        REM START "%~n0 - Installing %app_cfg.desc%" /D "%app_cfg.installer_dir%" /MIN cmd /v /c "(echo Executing %app_cfg.installer_file% %app_cfg.param%) & (%start_command%) & SET /A "exit_code=ERRORLEVEL" & (echo Exit Code:^!ERRORLEVEL^! >exit_code.txt) & (echo Exit Code:^!ERRORLEVEL^!) & (echo %google_search%^!ERRORLEVEL^!) & pause"
        echo %app_name%>> "%no_wait_installers_file%"
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

REM ==================================================================================
REM FUNCTION NAME
:install_3 param1 retval param3
REM params:
REM		-- [IN]			param1			 - input
REM		-- [OUT]		retvar			 - Var to store Return Value.
REM		-- [IN,OPT]		param3			 - Optional. param3
SetLocal EnableExtensions EnableDelayedExpansion
set "options= /A:"" /C: /I: /P:"" /S: /T: /?: /??: /NH: /NE: /NM: /NS: /Q: /V: /H: /F:"" /FR:"" 
FOR %%O in (%*) do FOR /F "tokens=1,* delims=:" %%A in ("%%~O") do (
    REM echo %%A %%~B
    SET "_%%A=%%~B"
)
set _
REM SET "param1=%~1"
REM SET "retval=%~2"
REM SET "param3=%~3"

REM SET "exit_code=0"
REM SET "result="

REM SET "cfg_installer_dir=%~f2"
REM SET "cfg_specific_windows_number="
REM SET "cfg_specific_windows_bit="
REM SET "cfg_installer_file="
REM SET "cfg_wait="
REM SET "cfg_param="
REM SET "cfg_crack_dir="
REM SET "cfg_crack_file="
REM SET "cfg_crack_dst="
REM SET "cfg_script="

REM echo %param1%
pause

IF NOT DEFINED param3 (
    REM Default value for param3
)
REM for /F "tokens=*" %%a in ('find /v ""') do (
    REM rem
REM )

REM Function body

:install_3__end
(ENDLOCAL & REM -- RETURN VALUES
    IF "%retval%" NEQ "" SET "%retval%=%result%"
    EXIT /B %exit_code%
)


REM ==================================================================================
REM GET APP'S INSTALLATION CONFIGURATION
:get_app_inst_cfg ini_file section_name retvar
REM params:
REM		-- [IN]			ini_file		 - input
REM		-- [IN]			section_name	 - input
REM		-- [OUT]		retvar			 - Var to store Return Value.
SetLocal EnableExtensions EnableDelayedExpansion
SET "ini_file=%~1"
SET "section_name=%~2"
SET "retvar=%~3"

SET "cfg_installer_dir=%~f2"
SET "cfg_specific_windows_number="
SET "cfg_specific_windows_bit="
SET "cfg_installer_file="
SET "cfg_wait="
SET "cfg_param="
SET "cfg_crack_dir="
SET "cfg_crack_file="
SET "cfg_crack_dst="
SET "cfg_script="

SET /A "cfg_status_code=0"
SET "cfg_status="
SET "cfg_desc=%section_name%"
CALL:str_color READY %COLOR_GREEN% cfg_status

SET "exit_code=0"

%LOG% Extracting section %section_name% from INI file %ini_file%
CALL:extract_ini_section "%ini_file%" "%section_name%" cfg_
IF %ERRORLEVEL% NEQ 0 (
    SET /A "cfg_status_code=%_ERR_APP_CFG_NOT_FOUND%"
    REM CALL:str_color "APP CFG NOT FOUND" %COLOR_RED% cfg_status
    goto:get_app_inst_cfg__end
)

:search_dir
IF NOT EXIST "%cfg_installer_dir%" (
    SET /A "cfg_status_code=%_ERR_INSTALLER_DIR_NOT_FOUND%"
    REM CALL:str_color "FOLDER NOT FOUND" %COLOR_RED% cfg_status
    goto:get_app_inst_cfg__end
)
REM Specific Win7 Win8 Win10 folder
IF NOT DEFINED windows_number CALL :get_windows_number windows_number
SET "cfg_specific_windows_number="
SET /A "other_win_ver_found=0"
IF EXIST "%cfg_installer_dir%\Win *" (
    IF EXIST "%cfg_installer_dir%\Win %windows_number%" (
        SET "cfg_installer_dir=%cfg_installer_dir%\Win %windows_number%"
        SET "cfg_specific_windows_number=%windows_number%"
        SET "cfg_desc=%cfg_desc% [Win %windows_number%]"
    ) ELSE SET /A "other_win_ver_found=1"
)

REM Specific 32 64 folder
IF NOT DEFINED windows_bit CALL:get_windows_bit windows_bit
IF %windows_bit% EQU 32 (SET /A "windows_bit_inverse=64") ELSE SET /A "windows_bit_inverse=32"
SET "cfg_specific_windows_bit="
SET /A "other_win_bit_found=0"
IF EXIST "%cfg_installer_dir%\%windows_bit%" (
    SET "cfg_installer_dir=%cfg_installer_dir%\%windows_bit%"
    SET "cfg_specific_windows_bit=%windows_bit%"
    SET "cfg_desc=%cfg_desc% [%windows_bit%-bit]"
) ELSE IF EXIST "%cfg_installer_dir%\%windows_bit_inverse%" SET /A "other_win_bit_found=1"

REM Installer File
IF NOT DEFINED cfg_installer_file (
    %LOG% Searching Installer file
    CALL:search_installer_file "%cfg_installer_dir%" cfg_installer_file
    IF !ERRORLEVEL! NEQ 0 (
        SET /A "cfg_status_code=%_ERR_NO_INSTALLER_FILE%"
        REM CALL:str_color "INSTALLER FILE NOT FOUND" %COLOR_RED% cfg_status
        %LOG% Can't find any
        goto:get_app_inst_cfg__end
    ) ELSE (
        %LOG% Found !cfg_installer_file!
    )
) ELSE IF NOT EXIST "%cfg_installer_dir%\!cfg_installer_file!" (
        IF NOT EXIST "!cfg_installer_file!" (
            SET /A "cfg_status_code=%_ERR_SPECIFIED_INSTALLER_FILE_NOT_FOUND"
            %LOG% Can't find specified file !cfg_installer_file!
            REM CALL:str_color "INSTALLER FILE NOT FOUND" %COLOR_RED% cfg_status
            goto:get_app_inst_cfg__end
        )
    
)

IF DEFINED cfg_wait (
    IF "%cfg_wait%" EQU "false" SET "cfg_wait="
) ELSE (
    SET "cfg_wait=/WAIT"
)

IF DEFINED cfg_param (
    SET "cfg_param=!cfg_param:[CD]=%cfg_installer_dir%!"
    %LOG% param=!cfg_param!
) ELSE (
    %LOG% No Params
    SET /A "cfg_status_code=%_ERR_NO_PARAMS%"
    REM CALL:str_color "PARAM NOT SPECIFIED" %COLOR_RED% cfg_status
    goto:get_app_inst_cfg__end
)



IF NOT DEFINED cfg_crack_dst (
    SET "cfg_crack_dst=%ProgramFiles%\%section_name%"
)
IF NOT EXIST "%cfg_crack_dst%" (
    rem TODO
)

:get_app_inst_cfg__end
IF %cfg_status_code% NEQ 0 (
    CALL:get_error_description %cfg_status_code% error_desc
    CALL:str_color "!error_desc!" %COLOR_RED% cfg_status
)
(ENDLOCAL & REM -- RETURN VALUES
    IF "%retvar%" NEQ "" (
        SET "%retvar%.installer_dir=%cfg_installer_dir%"
        SET "%retvar%.specific_windows_number=%cfg_specific_windows_number%"
        SET "%retvar%.specific_windows_bit=%cfg_specific_windows_bit%"
        SET "%retvar%.installer_file=%cfg_installer_file%"
        SET "%retvar%.wait=%cfg_wait%"
        SET "%retvar%.param=%cfg_param%"
        SET "%retvar%.crack_file=%cfg_crack_file%"
        SET "%retvar%.crack_dst=%cfg_crack_dst%"
        SET "%retvar%.status=%cfg_status%"
        SET "%retvar%.status_code=%cfg_status_code%"
        SET "%retvar%.desc=%cfg_desc%"
    )
    EXIT /B %cfg_status_code%
)


REM ==================================================================================
REM SEARCH INSTALLER FILE
:search_installer_file installer_dir retvar
REM params:
REM		-- [IN]			installer_dir	 - input
REM		-- [OUT]		retvar			 - Var to store Return Value.
REM 
REM Search Priority
REM 	setup.exe
REM 	setup*.exe
REM 	*setup.exe
REM 	*setup*.exe
REM 	*x86*.exe OR *x64*.exe
REM 	Not *x86*.exe OR Not *x64*.exe
REM 	*.exe
REM 	setup.msi
REM 	setup*.msi
REM 	*setup.msi
REM 	*setup*.msi
REM 	*.msi
REM @echo on
SetLocal EnableExtensions EnableDelayedExpansion
SET "installer_dir=%~1"
SET "retvar=%~2"

SET "tmp_file_exe_msi="%tmp_folder%\%~n0.dir_list_exe_msi.tmp""
SET "tmp_file_exe="%tmp_folder%\%~n0.dir_list_exe.tmp""
SET "tmp_file_msi="%tmp_folder%\%~n0.dir_list_msi.tmp""
SET "installer_file="
SET /A "exit_code=0"
SET /A "exist_exe=0"
SET /A "exist_msi=0"

IF NOT DEFINED installer_dir (
    SET /A exit_code=1
    goto:search_installer_file__end
) ELSE IF NOT EXIST "%installer_dir%" (
    SET /A exit_code=1
    goto:search_installer_file__end
)

IF NOT DEFINED windows_bit CALL:get_windows_bit windows_bit
REM SET "windows_bit=32"
IF %windows_bit% EQU 32 (
    SET "bit_pattern=x86"
    SET "bit_pattern_inverse=x64"
    
) ELSE IF %windows_bit% EQU 64 (
    SET "bit_pattern=x64"
    SET "bit_pattern_inverse=x86"
)

REM DIR "%installer_dir%" /B /A:-D /O:-D | findstr /ir "\.exe$ \.msi$">%tmp_file_exe_msi%
DIR "%installer_dir%" /B /A:-D /O:-D /L | findstr /LE "exe msi">%tmp_file_exe_msi%
IF %errorlevel% NEQ 0 (
    SET /A exit_code=1
    goto:search_installer_file__end
)
findstr /LEC:".exe" %tmp_file_exe_msi%>%tmp_file_exe%
IF %errorlevel% EQU 0 SET /A "exist_exe=1"
findstr /LEC:".msi" %tmp_file_exe_msi%>%tmp_file_msi%
IF %errorlevel% EQU 0 SET /A "exist_msi=1"

REM IF EXIST "%installer_dir%\*.exe" SET "exist_exe=1"
REM IF EXIST "%installer_dir%\*.msi" SET "exist_msi=1"
REM IF "%exist_exe%" NEQ "1" IF "%exist_msi%" NEQ "1" (
    REM SET exit_code=1
    REM goto:search_installer_file__end
REM )

REM ----------
REM SEARCH EXE
:search_installer_file__exe
IF %exist_exe% NEQ 1 goto:search_installer_file__msi
IF EXIST "%installer_dir%\setup.exe" (
    SET "installer_file=setup.exe"
    goto:search_installer_file__end
)

REM --------
REM LITERAL
REM Search setup*.exe
FOR /F "delims=" %%A in ('findstr /LBC:"setup" %tmp_file_exe%') DO ^
SET "installer_file=%%A" & goto:search_installer_file__end

REM Search *setup.exe
FOR /F "delims=" %%A in ('findstr /LEC:"setup.exe" %tmp_file_exe%') DO ^
SET "installer_file=%%A" & goto:search_installer_file__end

REM Search *setup*.exe
FOR /F "delims=" %%A in ('findstr /LC:"setup" %tmp_file_exe%') DO ^
SET "installer_file=%%A" & goto:search_installer_file__end
REM ---------

REM REM --------
REM REM REGEX
REM REM Search setup*.exe
REM SET "regex=^setup"
REM FOR /F "delims=" %%A in ('findstr /irc:"%regex%" %tmp_file_exe%') DO ^
REM SET "installer_file=%%A" & goto:search_installer_file__end

REM REM Search *setup.exe
REM SET "regex=setup\.exe$"
REM FOR /F "delims=" %%A in ('findstr /irc:"%regex%" %tmp_file_exe%') DO ^
REM SET "installer_file=%%A" & goto:search_installer_file__end

REM REM Search *setup*.exe
REM SET "regex=setup"
REM FOR /F "delims=" %%A in ('findstr /irc:"%regex%" %tmp_file_exe%') DO ^
REM SET "installer_file=%%A" & goto:search_installer_file__end
REM REM ---------

REM Search *x86*.exe OR *x64*.exe
SET "regex=%bit_pattern%"
FOR /F "delims=" %%A in ('findstr /LC:"%regex%" %tmp_file_exe%') DO ^
SET "installer_file=%%A" & goto:search_installer_file__end
REM Search inverse *x86*.exe OR *x64*.exe
SET "regex=%bit_pattern_inverse%"
FOR /F "delims=" %%A in ('findstr /LVC:"%regex%" %tmp_file_exe%') DO ^
SET "installer_file=%%A" & goto:search_installer_file__end

REM Search *.exe
FOR /F "delims=" %%A in ('type %tmp_file_exe%') DO ^
SET "installer_file=%%A" & goto:search_installer_file__end

REM ----------
REM SEARCH MSI
:search_installer_file__msi
IF %exist_msi% NEQ 1 (
    SET /A exit_code=1
    goto:search_installer_file__end
)
IF EXIST "%installer_dir%\setup.msi" (
    SET "installer_file=setup.msi"
    goto:search_installer_file__end
)

REM --------
REM LITERAL
REM Search setup*.msi
FOR /F "delims=" %%A in ('findstr /LBC:"setup" %tmp_file_msi%') DO ^
SET "installer_file=%%A" & goto:search_installer_file__end

REM Search *setup.msi
FOR /F "delims=" %%A in ('findstr /LEC:"setup.msi" %tmp_file_msi%') DO ^
SET "installer_file=%%A" & goto:search_installer_file__end

REM Search *setup*.msi
FOR /F "delims=" %%A in ('findstr /LC:"setup" %tmp_file_msi%') DO ^
SET "installer_file=%%A" & goto:search_installer_file__end
REM ---------

REM REM --------
REM REM REGEX
REM REM Search setup*.msi
REM SET "regex=^setup"
REM FOR /F "delims=" %%A in ('findstr /irc:"%regex%" %tmp_file_msi%') DO ^
REM SET "installer_file=%%A" & goto:search_installer_file__end

REM REM Search *setup.msi
REM SET "regex=setup\.msi$"
REM FOR /F "delims=" %%A in ('findstr /irc:"%regex%" %tmp_file_msi%') DO ^
REM SET "installer_file=%%A" & goto:search_installer_file__end

REM REM Search *setup*.msi
REM SET "regex=setup"
REM FOR /F "delims=" %%A in ('findstr /irc:"%regex%" %tmp_file_msi%') DO ^
REM SET "installer_file=%%A" & goto:search_installer_file__end
REM REM ---------

REM Search *x86*.msi OR *x64*.msi
SET "regex=%bit_pattern%"
FOR /F "delims=" %%A in ('findstr /LC:"%regex%" %tmp_file_msi%') DO ^
SET "installer_file=%%A" & goto:search_installer_file__end
REM Search inverse *x86*.exe OR *x64*.exe
SET "regex=%bit_pattern_inverse%"
FOR /F "delims=" %%A in ('findstr /LVC:"%regex%" %tmp_file_msi%') DO ^
SET "installer_file=%%A" & goto:search_installer_file__end

REM Search *.msi
FOR /F "delims=" %%A in ('type %tmp_file_msi%') DO ^
SET "installer_file=%%A" & goto:search_installer_file__end

REM NOTHING FOUND
SET /A "exit_code=1"

:search_installer_file__end
(ENDLOCAL & REM -- RETURN VALUES
    IF "%retvar%" NEQ "" SET "%retvar%=%installer_file%"
    REM @echo off
    REM pause
    EXIT /B %exit_code%
)




REM ==================================================================================
REM
:import_all_reg_files search_dir out_num_imported
SetLocal EnableExtensions EnableDelayedExpansion
SET "search_dir=%~1"
SET "out_num_imported=%~2"

SET /A "num_found=0"
FOR /F "tokens=*" %%A IN ('dir /B /O:N "%search_dir%" ^| find /I ".reg"') DO (
    SET /A "num_found+=1"
    IF "%install_mode%"=="install" (REG IMPORT "%%A") ELSE (echo REG IMPORT "%%A")
)
IF %num_found% GTR 0 (
    echo found %num_found% .reg files
)
IF DEFINED out_num_imported (
    EndLocal & REM -- RETURN VALUES
    set "%out_num_imported%=%num_found%"
) ELSE (
    EndLocal & REM -- RETURN VALUES
    ECHO %num_found%
)
EXIT /B




REM ==================================================================================
REM FUNCTION NAME
:get_version retvar
REM params:
REM		-- [OUT]		retvar			 - Var to store Return Value.
SetLocal EnableExtensions EnableDelayedExpansion
SET "retvar=%~1"
SET "result="

Set file_name=%~n0
Set "file_name=%file_name:_v=:%!"
for /F "tokens=2 delims=:" %%A in ("%file_name%") do SET "result=%%A"

(ENDLOCAL & REM -- RETURN VALUES
    IF "%retvar%" NEQ "" (SET "%retvar%=%result%") ELSE echo %result%
)
EXIT /B %errorlevel%

:echo_verbose level str
IF "%SETTINGS_VERBOSE_LEVEL%" GEQ "%1" echo.%~2
Exit /b


:echo col txt -- echoes text in a specific color
REM            -- col [in]  - color code, append a DOT to omit line break, call 'color /?' for color codes
REM            -- txt [in]  - text output
:$created 20060101 :$changed 20080219 :$categories Echo,Color
:$source https://www.dostips.com
SETLOCAL
for /f "tokens=1,*" %%a in ("%*") do (
    set col=%%a
    set txt=%%~b
)
set cr=Y
if "%col:~-1%"=="." (
    set cr=N
    set col=%col:~0,-1%
)
call:getColorCode "%col%" col
set com=%temp%.\color%col%.com
if not exist "%com%" (
    echo.N %COM%
    echo.A 100
    echo.MOV BL,%col%
    echo.MOV BH,0
    echo.MOV SI,0082
    echo.MOV AL,[SI]
    echo.MOV CX,1
    echo.MOV AH,09
    echo.INT 10
    echo.MOV AH,3
    echo.INT 10
    echo.INC DL
    echo.MOV AH,2
    echo.INT 10
    echo.INC SI
    echo.MOV AL,[SI]
    echo.CMP AL,0D
    echo.JNZ 109
    echo.RET
    echo.
    echo.r cx
    echo.22
    echo.w
    echo.q
)|debug>NUL
"%com%" %txt%
rem del "%com%" /q
if "%cr%"=="Y" echo.
EXIT /b

REM ==================================================================================
REM FUNCTION NAME
:create_default_ini_file filename retval param3
REM params:
REM		-- [IN]			param1			 - input
REM		-- [OUT]		retvar			 - Var to store Return Value.
REM		-- [IN,OPT]		param3			 - Optional. param3
SetLocal EnableExtensions EnableDelayedExpansion
SET "filename=%~1"
SET /A "exit_code=0"

REM HEADER
(
    echo ; GENERATED CONFIGURATION FILE 
    echo ;      AT        : %DATE% %TIME%
    echo ;      FROM FILE : %~f0
    echo ;      TO FILE   : %filename%
    echo ; 
    echo ; ==================================================================
    echo ;
    echo ; [Folder Name]
    echo ; Parameter to pass. Default: /passive
    echo ; param=
    echo ;
    echo ; Default: true
    echo ; wait=true/false
    echo ;
    echo ; Default: setup.exe
    echo ; installer_file=
    echo ;
    echo ; Default: %%PROGRAMFILES%%\[App Name]\
    echo ; crack_dst=
    echo ;
    echo ; -----------------------------------------------
    echo ; msi
    echo ;	/quiet /norestart
    echo ;	/passive /norestart
    echo ; Inno Setup
    echo ; 	/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-
    echo ; 	/SILENT /SUPPRESSMSGBOXES /NORESTART /SP-
    echo ; NSIS
    echo ;	/S
    echo ;
    echo ; -------------------------------------------------
    echo ; Some tools to detect silent install switches:
    echo ; Silent Key Finder
    echo ; 	https://www.softpedia.com/get/System/Launchers-Shutdown-Tools/Silent-key-finder.shtml
    echo ; Universal Silent Switch Finder
    echo ; 	https://www.softpedia.com/get/System/Launchers-Shutdown-Tools/Universal-Silent-Switch-Finder.shtml
    echo ; Silent Install Builder
    echo ;
    echo ; ==================================================================
    echo ;
)> "%filename%"

REM CONTENT
(
    echo [7Zip]
    echo param=/passive /norestart
    echo param_quiet=/quiet /norestart
    echo ; wait=false
    echo [AIMP]
    echo param=/AUTO /SILENT
    echo [Adobe Flash Player]
    echo param=-install
    echo [Adobe Acrobat Reader DC]
    echo ; https://www.adobe.com/devnet-docs/acrobatetk/tools/AdminGuide/basics.html#expanding-exe-packages
    echo ; param=-sfx_nu /sALL /msi EULA_ACCEPT=YES
    echo param=/sPB /msi /norestart EULA_ACCEPT=YES
    echo param_quiet=-sfx_nu /sALL /msi /norestart EULA_ACCEPT=YES
    echo [Adobe Flash Player for Chrome, Chromium, Opera, UC Browser]
    echo param=-install
    echo [Adobe Flash Player for Firefox, Safari]
    echo param=-install
    echo [Adobe Flash Player for Internet Explorer]
    echo param=-install
    echo [Adobe Photoshop CS 4]
    echo param=/SILENT /SUPPRESSMSGBOXES /NORESTART /SP-
    echo param-quiet=/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-
    echo [CCleaner]
    echo param=/S /IT /TM
    echo [DirectX]
    echo param=/silent
    echo [Format Factory]
    echo param=/VERYSILENT /I /EN
    echo [FurMark]
    echo param=/SILENT /SUPPRESSMSGBOXES /NORESTART /SP-
    echo param-quiet=/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-
    echo [GOM Player]
    echo param=/S
    echo crack_dst=%%ProgramFiles%%\GRETECH\GOMPlayerPlus
    echo [Google Chrome]
    echo param=/passive /norestart
    echo param_quiet=/quiet /norestart
    echo [Internet Download Manager IDM]
    echo param=/S /EN
    echo [Java]
    echo ; https://www.oracle.com/technetwork/java/javase/silent-136552.html
    echo ; https://docs.oracle.com/javase/8/docs/technotes/guides/install/config.html#installing_with_config_file
    echo param=/s REBOOT=0 AUTO_UPDATE=0
    echo [K-Lite Codec Pack]
    echo param=/SILENT /SUPPRESSMSGBOXES /NORESTART /SP-
    echo param_quiet=/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-
    echo [Kodi]
    echo param=/S
    echo [Microsoft .NET Framework]
    echo param=/passive /norestart
    echo param_quiet=/quiet /norestart
    echo [Microsoft Office 2007 SP3]
    echo param=/adminfile basic.MSP
    echo wait=false
    echo [Microsoft Office 2016]
    echo ;param=/adminfile "[CD]\basic.MSP"
    echo param=/adminfile basic_all.MSP
    echo wait=false
    echo [Microsoft Visual C++ Redistributable]
    echo param=/passive /norestart
    echo param_quiet=/quiet /norestart
    echo [Mozilla Firefox]
    echo param=-ms
    echo [MSI Afterburner]
    echo param=/S
    echo [Notepad++]
    echo param=/S
    echo [Snappy Driver Installer]
    echo ; installer_file=SDI_auto.bat
    echo param=-autoinstall
    echo wait=false
    echo [VLC Media Player]
    echo param=/S
    echo [WinRAR]
    echo param=/S /IEN
    echo.
)>> "%filename%"

IF NOT EXIST "%file_name%" (
    SET /A "exit_code=1"
    >&2 echo Can't create default INI file
)

:create_default_ini_file__end
(ENDLOCAL & REM -- RETURN VALUES
    REM IF "%retval%" NEQ "" SET "%retval%=%result%"
    EXIT /B %exit_code%
)

REM ==================================================================================
REM FUNCTION NAME
:buat_paket new_pkg_desc new_pkg_file
REM params:
REM		-- [OUT]		retvar			 - Var to store Return Value. Paket desc
REM		-- [OUT]		retvar			 - Var to store Return Value. Paket file
SetLocal EnableExtensions EnableDelayedExpansion
SET "new_pkg_desc=%~1"
SET "new_pkg_file=%~2"

SET /A "pkg_item_length=0"
FOR /F "tokens=*" %%A in ('DIR /ad-h /B ^| findstr /v /r /c:"^\."') DO (
    SET /A pkg_item_length+=1
    SET pkg_item_!pkg_item_length!=%%A
    SET /A "pkg_item_!pkg_item_length!_selected=0"
)

SET "selected_pkg_buffer= "
:buat_paket__compose
CLS
echo Found %pkg_item_length% apps in current folder:
echo.
FOR /L %%A IN (1,1,%pkg_item_length%) DO (
    IF !pkg_item_%%A_selected! EQU 1 (SET "prefix=  V  ") ELSE SET "prefix=     "
    IF %%A LSS 10 SET "prefix=!prefix! "
    echo !prefix!%%A. !pkg_item_%%A!
)
echo.
SET "new_pkg_input="
SET /P new_pkg_input="Pilih nomor app yg ingin ditambahkan (tekan 'Y' utk selesai): "

IF NOT DEFINED pkg_item_%new_pkg_input% (
    IF "%new_pkg_input%"=="Y" goto :buat_paket__confirm
    IF "%new_pkg_input%"=="y" goto :buat_paket__confirm
) ELSE (
    IF !pkg_item_%new_pkg_input%_selected! EQU 1 (
        SET /A "pkg_item_%new_pkg_input%_selected=0"
        SET "selected_pkg_buffer=!selected_pkg_buffer: %new_pkg_input% = !"
    ) ELSE (
        SET /A "pkg_item_%new_pkg_input%_selected=1"
        SET "selected_pkg_buffer=%selected_pkg_buffer%%new_pkg_input% "
    )
)
goto :buat_paket__compose

:buat_paket__confirm
SET /A "selected_pkg_num=0"
FOR %%A in (%selected_pkg_buffer%) DO (
    SET /A "selected_pkg_num+=1"
    SET "selected_pkg_!selected_pkg_num!=!pkg_item_%%A!"
)

echo.
echo Paket baru:
FOR /L %%A IN (1,1,%selected_pkg_num%) DO (
    echo    %%A. !selected_pkg_%%A!
)
echo.

:buat_paket__nama_paket
SET /P nama_paket="Nama Paket: "
IF "%nama_paket%"=="" goto:buat_paket__nama_paket
SET "paket_file=%~dpn0.paket.%nama_paket%.txt"

:buat_paket__nama_paket_confirm
SET "nama_paket_confirm=y"
IF EXIST "%paket_file%" (
    CALL:str_color "Paket dengan nama %nama_paket% sudah ada. Lanjutkan [Y/n]" %COLOR_RED% nama_paket_confirm_text
    SET /P nama_paket_confirm="!nama_paket_confirm_text! "
)
IF DEFINED nama_paket_confirm (
    IF "%nama_paket_confirm%"=="Y" goto:buat_paket__create_file
    IF "%nama_paket_confirm%"=="y" goto:buat_paket__create_file
)

goto:buat_paket__nama_paket

:buat_paket__create_file
REM create empty file
(type nul> "%paket_file%") > nul
REM copy nul %paket_file% > nul 2>&1

IF NOT EXIST "%paket_file%" (
    echo [ERROR] Nama paket invalid. Coba nama lain 1>&2
    echo.
    goto buat_paket__nama_paket
)
REM Write to file
FOR /L %%A IN (1,1,%selected_pkg_num%) DO (
    echo !selected_pkg_%%A!>> "%paket_file%"
)

:buat_paket__end
(ENDLOCAL & REM -- RETURN VALUES
    IF "%new_pkg_desc%" NEQ "" SET "%new_pkg_desc%=%nama_paket%"
    IF "%new_pkg_file%" NEQ "" SET "%new_pkg_file%=%paket_file%"
)
EXIT /B %errorlevel%




REM ==================================================================================
REM EXTRACT INI SECTION
:extract_ini_section ini_file section_name retvar comment_char
REM params:
REM		-- [IN]			ini_file			 - INI file
REM		-- [IN]			section_name		 - Section INI file
REM		-- [OUT,OPT]	retvar				 - Var to store Return Value. If none, Echo
SetLocal EnableExtensions EnableDelayedExpansion
SET "ini_file=%~1"
SET "section_name=%~2"
SET "retvar=%~3"
SET "comment_char=%~4"

SET /A "exit_code=0"
REM 1 = ini_file not found
REM 2 = section not found

IF NOT DEFINED comment_char SET "comment_char=;"

SET "line_start="
SET "command=findstr /inc:"[%section_name%]" "%ini_file%""
FOR /F "delims=:" %%A in ('%command%') DO (
    SET line_start=%%A
)
IF NOT DEFINED line_start (
    SET /A "exit_code=2"
    >&2 echo section %section_name% not found
    GOTO:extract_ini_section__end
)
SET "line_end="
(ENDLOCAL & REM -- RETURN VALUES
    FOR /F "skip=%line_start% delims=" %%A in ('type "%ini_file%"') DO (
        SetLocal EnableDelayedExpansion
        SET "line=%%A"
        SET "first_char=!line:~0,1!"
        IF "!first_char!"=="[" goto:extract_ini_section__end
        IF NOT "!first_char!"=="%comment_char%" (
            IF "%retvar%" NEQ "" (
                Endlocal & SET %retvar%%%A
            ) ELSE echo %%A& Endlocal
        ) ELSE EndLocal
    )
    EXIT /B
)
:extract_ini_section__end
ENDLOCAL & EXIT /B %exit_code%

REM ==================================================================================
REM GET_NEWEST_FILE
:get_newest_file file_dir file_ext out_result
SetLocal EnableExtensions EnableDelayedExpansion
SET "file_dir=%~1"
SET "file_ext=%~2"
SET "out_result=%~3"

FOR /F "tokens=*" %%A IN ('dir /B /O:-D "%file_dir%" ^| find /I ".%file_ext%"') DO SET "newest_file=%%A" & goto get_newest_file_stop
:get_newest_file_stop

IF NOT DEFINED newest_file (
    EndLocal & REM -- RETURN VALUES
    EXIT /B 1
) ELSE IF DEFINED out_result (
    EndLocal & REM -- RETURN VALUES
    set "%out_result%=%newest_file%"
) ELSE (
    EndLocal & REM -- RETURN VALUES
    ECHO %newest_file%
)

EXIT /b



:echo_err %~1
IF "%windows_number%"=="10" (
    echo.[31m%~1[0m
) ELSE (
    echo.[%~1]
)
echo.%~1 >&2
Exit /b

REM ==================================================================================
REM INIT COLOR CODE
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


:DEPRECATED_SUBROUTINE
REM ==================================================================================
REM ==================================================================================
REM 				DEPRECATED SUBROUTINE

REM ==================================================================================
REM
:paket_install search_dir result_file
SetLocal EnableExtensions EnableDelayedExpansion
SET "search_dir=%~f1"
SET "result_file=%~2"

SET /A "num_dir=0"
FOR /F "tokens=*" %%A IN ('dir /B /A:D /O:N "%search_dir%"') DO (
    SET /A "num_dir+=1"
    SET "dir_!num_dir!=%%A"
)
FOR /L %%A IN (1,1,%num_dir%) DO (
    IF "%%A" EQU "1" (
        echo %%A. !dir_%%A!>"%result_file%"
    ) ELSE (
        echo %%A. !dir_%%A!>>"%result_file%"
    )
)
EndLocal
EXIT /B

REM ==================================================================================
REM INSTALL 
:install installer_dir param installer_file_name install_dir wait
REM params:
REM 	installer_dir				: Folder that contains installer file.
REM 	[opt] param					: parameter for silent install.
REM 									Default: /passive
REM 	[opt] installer_file_name	: filename of the installer.
REM										Default: the newest file found in installer_dir
REM 	[opt] install_dir			: Folder name in C:\Program Files. For copying crack file
REM										Default: Folder name of installer_dir
REM		[opt] wait					: Wait until installation finish
REM 									Default: TRUE. FALSE otherwhise

SetLocal EnableExtensions EnableDelayedExpansion
REM params
SET "installer_dir=%~f1"
SET "param=%~2"
SET "installer_file_name=%~nx3"
SET "install_dir=%~4"
SET "wait=%~4"

SET "crack_dir=Crack"
SET "product_name=%~nx1"
SET "exit_code=0"

CALL :get_app_cfg "%params_ini_file%" "%product_name%" app_cfg
REM set app_cfg

echo.

REM echo Installing !product_name! . . . . .

REM Chek params
IF NOT DEFINED installer_dir (
    echo [ERROR] - Can't Install %product_name%. parameter installer_dir is required 1>&2
    SET "exit_code=%_ERR_NO_PARAMS%"
    goto install__end
)
IF NOT EXIST "%installer_dir%" (
    echo [ERROR] - Can't Install %product_name%. Can't find installer_dir "%installer_dir%" 1>&2
    SET "exit_code=%_ERR_INSTALLER_DIR_NOT_FOUND%"
    goto install__end
)
IF NOT DEFINED param SET "param=AUTO"
REM replace ' with ""
REM SET "param=%param:'="%"

IF NOT DEFINED installer_file_name SET "installer_file_name=AUTO"
IF NOT DEFINED install_dir SET "install_dir=AUTO"
REM IF NOT DEFINED wait (SET "wait=TRUE") ELSE (SET "wait=FALSE")
REM IF "%wait%"=="TRUE" (SET "wait=/WAIT") ELSE (SET "wait= ")
SET "wait= /WAIT"
IF DEFINED app_cfg_wait (
    IF "%app_cfg_wait%"=="false" SET "wait="
)

REM Specific Win7 Win8 Win10 folder
IF NOT DEFINED windows_number CALL :get_windows_number windows_number
SET "specific_windows_number="
IF EXIST "%installer_dir%\Win %windows_number%" (
    SET "installer_dir=%installer_dir%\Win %windows_number%"
    SET "specific_windows_number=%windows_number%"
)

REM Specific 32 64 folder
IF NOT DEFINED windows_bit CALL:get_windows_bit windows_bit
SET "specific_windows_bit="
IF EXIST "%installer_dir%\%windows_bit%" (
    SET "installer_dir=%installer_dir%\%windows_bit%"
    SET "specific_windows_bit=%windows_bit%"
)

REM Search for exe or msi file
IF NOT "%installer_file_name%"=="AUTO" (
    IF NOT EXIST "%installer_dir%\%installer_file_name%" (
        echo [ERROR] - Can't Install %product_name%. Can't find installer_file "%installer_dir%\%installer_file_name%" in 3rd parameter 1>&2
        SET "exit_code=%_ERR_FILE_NOT_FOUND%"
        goto install__end
    )
) ELSE IF EXIST "%installer_dir%\*.msi" (
    CALL:get_newest_file "%installer_dir%" msi installer_file_name
) ELSE IF EXIST "%installer_dir%\*.exe" (
    CALL:get_newest_file "%installer_dir%" exe installer_file_name
) ELSE (
    echo [ERROR] - Can't Install %product_name%. Can't find any .msi or .exe file in "%installer_dir%" 1>&2
    SET "exit_code=%_ERR_FILE_NOT_FOUND%"
    goto install__end
)

SET "installer_file=%installer_dir%\%installer_file_name%"
SET "installer_file_ext=%installer_file:~-3%"

REM Give default param if file is .msi
IF "!param!"=="AUTO" (
    set "param="
    CALL:get_params "%product_name%" param
    IF NOT "!param!"=="" (
        SET "param=!param:[CD]=%installer_dir%!"
        goto install_param_done
    )
    IF "%installer_file_ext%" NEQ "msi" (
        REM echo [ERROR] - Can't Install %product_name%. No param specified 1>&2
        REM EXIT /B %_ERR_NO_PARAMS%
        SET "exit_code=%_ERR_NO_PARAMS%"
        goto install__end
    ) ELSE (
        SET "param=%default_msi_param%"
    )
)
:install_param_done
REM ECHO %param%
REM ECHO !param!
REM SET "param=%param:'="%"
REM SET "param=!param:[INSTALLER_DIR]=%installer_dir%!"
REM ECHO %param%
REM ECHO !param!

REM final check
IF NOT EXIST "%installer_file%" (
    echo [ERROR] - Can't find "%installer_file%" 1>&2
    SET "exit_code=%_ERR_FILE_NOT_FOUND%"
    goto install__end
)

REM product info
IF DEFINED specific_windows_number (
    SET "product_name=!product_name! ^(Win %windows_number%^)"
)
IF DEFINED specific_windows_bit (
    SET "product_name=!product_name! ^(%windows_bit%-bit^)"
)
REM CALLREMget_file_prop "%installer_file%" version product_version

REM RUN
IF "%install_mode%"=="%_MODE_TEST%" (
    echo Installing !product_name! . . . . .
    echo START ""%wait% "%installer_file%" !param!
    SET "exit_code=%errorlevel%"
) ELSE IF "%install_mode%"=="%_MODE_INSTALL%" (
    echo Installing !product_name! . . . . .
    START ""%wait% "%installer_file%" !param!
)

REM Copy crack to install location
IF "%install_dir%"=="AUTO" SET "install_dir=%~1%"
SET "install_loc_1=C:\Program Files\%install_dir%"
SET "install_loc_2=C:\Program Files (x86)\%install_dir%"
IF EXIST "%install_loc_1%" (
    SET "install_location=%install_loc_1%"
) ELSE IF EXIST "%install_loc_2%" (
    SET "install_location=%install_loc_2%"
) ELSE (
    SET "install_location="
)
IF EXIST "%installer_dir%\%crack_dir%\*.exe" (
    echo copying crack file...
    IF DEFINED install_location (
        copy /Y "%installer_dir%\%crack_dir%\*.exe" "%install_location%"
    ) ELSE (
        echo [WARNING] - can't find install location "%install_loc_1%" or "%install_loc_2%" 1>&2
    )
)
REM CALL:get_newest_file "%installer_dir%\%crack_dir%" exe crack_file_name

REM Registry
CALL:import_all_reg_files "%installer_dir%" out_num_imported

:install__end
(ENDLOCAL & REM -- RETURN VALUES
    EXIT /B %exit_code%
)




REM ==================================================================================
REM GET PARAMETER
:get_params product_name out_result ini_file
SetLocal EnableExtensions EnableDelayedExpansion
SET "product_name=%~1"
SET "out_result=%~2"
SET "ini_file=%~3"

IF NOT DEFINED ini_file SET "ini_file=%~n0.params.ini"

SET "params="

SET "line_num="
FOR /F "delims=:" %%A in ('findstr /vrc:"^#" "%ini_file%" ^| findstr /inc:"[%product_name%]"') DO (
    SET line_num=%%A
)
IF NOT DEFINED line_num goto get_params_end

REM FOR /F "tokens=* skip=%line_num% delims=" %%A in ('type "%ini_file%"') DO (
    REM echo %%A
REM )
For /f tokens^=1*^ skip^=%line_num%^ delims^=^= %%A in ('type "%ini_file%"') do (
    SET "line=%%A%%B"
    IF "!line:~0,1!"=="[" goto get_params_end
    IF "%%A"=="param" SET "params=%%B" & goto get_params_end
)

:get_params_end

IF DEFINED out_result (
    EndLocal & REM -- RETURN VALUES
    set "%out_result%=%params%"
) ELSE (
    EndLocal & REM -- RETURN VALUES
    ECHO %params%
)
EXIT /B

REM ==================================================================================
REM FUNCTION NAME
:get_app_cfg ini_file product_name retvar
REM params:
REM		-- [IN]			param1			 - input
REM		-- [OUT]		retvar			 - Var to store Return Value.
REM		-- [IN,OPT]		param3			 - Optional. param3
SetLocal EnableExtensions EnableDelayedExpansion
REM @echo on
SET "ini_file=%~1"
SET "product_name=%~2"
SET "retvar=%~3"

SET "param="
SET "insttaller_file="
SET "crack_file="
SET "crack_dst="
SET "wait="

SET "line_num="
FOR /F "delims=:" %%A in ('findstr /vrc:"^;" "%ini_file%" ^| findstr /inc:"[%product_name%]"') DO (
    SET line_num=%%A
)
IF NOT DEFINED line_num goto get_app_cfg__end

REM FOR /F "tokens=* skip=%line_num% delims=" %%A in ('type "%ini_file%"') DO (
    REM echo %%A
REM )
For /f tokens^=1*^ skip^=%line_num%^ delims^=^= %%A in ('findstr /vrc:"^;" "%ini_file%"') do (
    SET "line=%%A%%B"
    IF "!line:~0,1!"=="[" goto get_app_cfg__end
    REM SET /A cfg_count+=1
    REM SET "cfg_item_key_!cfg_count!=%%A"
    REM SET "cfg_item_val_!cfg_count!=%%B"
    IF "%%A"=="param" (
        SET "param=%%B"
    ) ELSE IF "%%A"=="insttaller_file" (
        SET "insttaller_file=%%B"
    ) ELSE IF "%%A"=="crack_file" (
        SET "crack_file=%%B"
    ) ELSE IF "%%A"=="crack_dst" (
        SET "crack_dst=%%B"
    ) ELSE IF "%%A"=="wait" (
        SET "wait=%%B"
    )
)
:get_app_cfg__end
REM SET cfg
REM echo !cfg_item_key_%cfg_count%!
REM echo.
REM echo after Call

(ENDLOCAL & REM -- RETURN VALUES
    IF "%retvar%" NEQ "" (
        SET "%retvar%_param=%param%"
        SET "%retvar%_insttaller_file=%insttaller_file%"
        SET "%retvar%_crack_file=%crack_file%"
        SET "%retvar%_crack_dst=%crack_dst%"
        SET "%retvar%_wait=%wait%"
        REM FOR /L %%A IN (1,1,%cfg_count%) DO (
            REM SET _ctr=%%A
            REM REM SET "%retvar%_cfg_item_%%A=%cfg_item_%%A_key% "
            REM CALL SET "%retvar%_cfg_item_%%_ctr%%_key=%%cfg_item_key_%%%_ctr%%%%% "
        REM )
    )
)
EXIT /B %errorlevel%

REM ==================================================================================
REM GET_FILE_PROP
:get_file_prop file_path prop outResult
SetLocal EnableExtensions EnableDelayedExpansion
SET "file_path=%~f1"
SET "prop=%~2"
SET "outResult=%~3"

REM SET "command=wmic datafile where name='%file_path%' get %prop%"
SET "file_path=%file_path:\=\\%"
REM %command%

FOR /F "tokens=2 delims==" %%I IN (
  'wmic datafile where "name='%file_path%'" get %prop% /format:list'
) DO FOR /F "delims=" %%A IN ("%%I") DO SET "RESULT=%%A"

IF DEFINED outResult (
    EndLocal & REM -- RETURN VALUES
    set "%outResult%=%RESULT%"
) ELSE (
    EndLocal & REM -- RETURN VALUES
    ECHO %RESULT%
)

EXIT /b

REM =============================================================================================
REM =============================================================================================
REM                                        EXTERNAL SUBROUTINE
:EXTERNAL_SUBROUTINE



REM ==================================================================================
REM INIT PROGRESS
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

REM ==================================================================================
REM GET_WINDOWS_NUMBER
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

REM ==================================================================================
REM GET OS BITNESS
:get_os_bitness ret
SetLocal
Set /A "_os_bitness=64"
IF %PROCESSOR_ARCHITECTURE% == x86 (
    IF NOT DEFINED PROCESSOR_ARCHITEW6432 Set /A "_os_bitness=32"
)
Endlocal & IF "%~1" neq "" (set /A "%~1=%_os_bitness%") else echo %_os_bitness%

REM ==================================================================================
REM GET OS ARCHITECTURE
:get_os_architecture ret
SetLocal
Set "_os_architecture=x64"
IF %PROCESSOR_ARCHITECTURE% == x86 (
    IF NOT DEFINED PROCESSOR_ARCHITEW6432 Set "_os_architecture=x86"
)
Endlocal & IF "%~1" neq "" (set "%~1=%_os_architecture%") else echo %_os_architecture%

REM ==================================================================================
REM GET_WINDOWS_BIT
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

:get_ini_content file outVar
SET /A "section_num=0"
SET "section=NO_SECTION"
FOR /F "delims=" %%G in ('type "%~1"') DO (
    set line=%%G
    IF "!line:~0,1!" EQU ";" (
        REM DO nothing. comment
    ) ELSE IF "!line:~0,1!" EQU "[" (
        SET /A "section_num=section_num+1"
        REM FOR /F "delims=[]" %%g in ("!line!") DO SET %~2.section[!section_num!]=%%g
        FOR /F "delims=[]" %%g in ("!line!") DO SET "section=%%g"
    ) ELSE (
        FOR /F "tokens=1,2* delims==" %%g in ("!line!") DO SET %~2.section[!section!].%%g=%%h
    )
)
SET /A "%~2.section.length=%section_num%"
exit /b


:remove_array_item_by_value arr_var arr_size_var val_to_remove


:remove_array_item array_var array_size_var idx_to_remove
SET /A "arr_size=!%~2!"
SET /A "idx_to_remove=%~3"

echo array size %arr_size%
SET /A "ctr=0"
:remove_array_item__loop
SET /A "ctr+=1"
SET /A "next_ctr=ctr+1"
SET "next_item=!%~1%next_ctr%!"
IF %ctr% GTR %arr_size% (
    REM SET "%~1_%ctr%="
    SET /A "prev_ctr=ctr-1"
    SET /A "%~2=!prev_ctr!"
    goto:remove_array_item__end
)
IF %ctr% GEQ %idx_to_remove% (
    
    SET "%~1%ctr%=%next_item%"
)
goto:remove_array_item__loop
REM FOR /L %%G in (1,1,!%~1_num!) DO (
    REM SET /A "ctr=%%G"
    REM IF %%G EQU %~2 (
        REM SET "!%~1_num!"
    REM )
REM )
:remove_array_item__end
pause
Exit /B

:format_num num retvar
setlocal EnableDelayedExpansion
set "num=%1"
set "var2="
set "sign="
if "%num:~0,1%" equ "-" set "sign=-" & set "num=%num:~1%"
for /L %%i in (1,1,4) do if defined num (
   set "var2=.!num:~-3!!var2!"
   set "num=!num:~0,-3!"
)
set "var2=%sign%%var2:~1%"
(ENDLOCAL & REM -- RETURN VALUES
    IF "%~2" NEQ "" SET %~2=%var2%
)
EXIT /b

:strLen String retvar
Setlocal EnableDelayedExpansion
             REM -- String  The string to be measured, surround in quotes if it contains spaces.
             REM -- RtnVar  An optional variable to be used to return the string length.
Set "s=#%~1"
Set "len=0"
For %%N in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (
  if "!s:~%%N,1!" neq "" (
    set /a "len+=%%N"
    set "s=!s:~%%N!"
  )
)
Endlocal&if "%~2" neq "" (set /A "%~2=%len%") else echo %len%
Exit /b

:count_lines files retvar
SetLocal
SET /A "lines=-1"
for /f %%A in ('type "%~1" ^| find /c /v ""') DO SET /A "lines=%%A"
(ENDLOCAL & REM -- RETURN VALUES
    IF "%~2" NEQ "" SET /A "%~2=%lines%"
)
EXIT /b

:get_longest_lines_length file retvar
Setlocal EnableDelayedExpansion
SET /A "longest=0"
FOR /F "delims=" %%A in ('type "%~1"') DO (
    CALL:strLen "%%A" length
    IF !length! GTR %longest% SET /A "longest=!length!"
)
Endlocal&if "%~2" neq "" (set /A "%~2=%longest%") else echo %longest%
EXIT /b

:repeat_char char count retvar
SetLocal EnableExtensions EnableDelayedExpansion
SET "char=%~1"
SET "count=%~2"
SET "retvar=%~3"
SET "result="
IF DEFINED repeat_char_%char%_%count% (
    SET "result=!repeat_char_%char%_%count%!"
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
    SET "repeat_char_%char%_%count%=%result%"
    REM IF "%new_pkg_file%" NEQ "" SET "%new_pkg_file%=%paket_file%"
)
EXIT /B %errorlevel%

:split_str str delim idx retvar
SetLocal EnableExtensions EnableDelayedExpansion
SET "str=%~1"
SET "delim=%~2"
SET "idx=%~3"
SET "retvar=%~4"

IF "%idx%"=="FIRST" (
    SET "skip="
) ELSE IF "%idx%"=="LAST" (
    SET "skip="
) ELSE (
    SET "skip=skip=%idx% "
)

SET CRLF=^


SET new_str=%str:/=!CRLF!%
SET "result="
for /f "%skip%delims=" %%A in ("!new_str!") do (
    SET "result=%%A"
    IF "%idx%"=="FIRST" (
        goto :split_str__end
    ) ELSE IF "%idx%"=="LAST" (
        REM pass
    ) ELSE goto :split_str__end
)

:split_str__end
(ENDLOCAL & REM -- RETURN VALUES
    IF "%retvar%" NEQ "" SET "%retvar%=%result%"
    REM IF "%new_pkg_file%" NEQ "" SET "%new_pkg_file%=%paket_file%"
)
EXIT /B %errorlevel%

:create_shortcut file url
REM Obtain from google
(
    echo [{000214A0-0000-0000-C000-000000000046}]
    echo Prop3=19,11
    echo [InternetShortcut]
    echo IDList=
    echo URL=%~2
    echo HotKey=0
) > "%~1"
exit /b

REM ==================================================================================
REM SEARCH NEWEST FILE USING FINDSTR REGEX
:serach_file_by_regex base_dir regex retvar
REM params:
REM		-- [IN]			base_dir		 - Directory to search
REM		-- [IN]			regex			 - regex of findstr command
REM		-- [OUT]		retvar			 - Var to store Return Value.
SetLocal EnableExtensions EnableDelayedExpansion
SET "base_dir=%~1"
SET "regex=%~2"
SET "retvar=%~3"
SET "result="

SET "command=DIR "%base_dir%" /B /A:-D /O:-D ^| findstr /irc:"%regex%""
FOR /F "delims=" %%A in ('%command%') DO (
    SET "result=%%A"
)
(ENDLOCAL & REM -- RETURN VALUES
    IF "%retvar%" NEQ "" SET "%retvar%=%result%"
    EXIT /B
)

REM ==================================================================================
REM FUNCTION NAME
:function_name param1 retval param3
REM params:
REM		-- [IN]			param1			 - input
REM		-- [OUT]		retvar			 - Var to store Return Value.
REM		-- [IN,OPT]		param3			 - Optional. param3
SetLocal EnableExtensions EnableDelayedExpansion
SET param1=%~1
SET "retval=%~2"
SET "param3=%~3"

SET "exit_code=0"
SET "result="
set
echo %param1%
pause

IF NOT DEFINED param3 (
    REM Default value for param3
)
for /F "tokens=*" %%a in ('find /v ""') do (
    rem
)

REM Function body

:function_name__end
(ENDLOCAL & REM -- RETURN VALUES
    IF "%retval%" NEQ "" SET "%retval%=%result%"
    EXIT /B %exit_code%
)

:tes_func
for /f "tokens=*" %%A in ('findstr "adalah"') do (
    echo %%A
)

:create_object var
SetLocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

(ENDLOCAL & REM RETURN VALUES
    
)

IF %ERRORLEVEL% NEQ 0 (
    Echo An error was found
    REM Command
    
)

