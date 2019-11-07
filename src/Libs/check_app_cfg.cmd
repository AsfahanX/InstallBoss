:check_app_cfg
rem Get start time:
for /F "tokens=1-4 delims=:.," %%a in ("%time%") do (
   set /A "start=(((%%a*60)+1%%b %% 100)*60+1%%c %% 100)*100+1%%d %% 100"
)
echo.
%ECHO_VERBOSE% 1 "Loading INI file . . ."
FOR /L %%G IN (1,1,!%ptr_SelectedPackage%.Items.Length!) DO (
    SET "app_name=!%ptr_SelectedPackage%.Items[%%G]!"
    call SET "is_loaded=%%AppCfg[!app_name!].is_loaded%%"
    REM IF "%AppCfg[!app_name!].is_loaded%" NEQ "1" echo Getting configuration for !app_name!
    IF "!is_loaded!" NEQ "1" (
        %ECHO_VERBOSE% Getting configuration for !app_name!
        CALL:get_appcfg IniContent "!app_name!" "AppCfg[!app_name!]"

    )
    CALL SET "desc=%%AppCfg[!app_name!].desc%%"
    SET "%ptr_SelectedPackage%.Items[%%G].desc=!desc!"

    REM CALL:echo_verbose 2 "Getting configuration for !app_name!"
    REM CALL:get_app_inst_cfg "%params_ini_file%" "!pkg_item_%%G!" pkg_item_%%G
    
    REM IF "!AppCfg[%%A]!" EQU "" (
    REM     CALL:get_app_inst_cfg "%params_ini_file%" "!pkg_item_%%A!" pkg_item_%%A AppCfg[%%A]
    REM )
)


%ECHO_VERBOSE% 1 "Preparing menu display . . ."
REM Get longest string
SET /A longest_str_len=0
FOR /L %%G IN (1,1,!%ptr_SelectedPackage%.Items.Length!) DO (
    SET "app_desc=!%ptr_SelectedPackage%.Items[%%G].desc!"
    CALL:strLen "!app_desc!" str_len
    SET "%ptr_SelectedPackage%.Items[%%G].desc.StringLength=!str_len!"
 
    REM SET /a "pkg_item_%%G_str_len=!str_len!"
    IF !str_len! GTR !longest_str_len! SET /a "longest_str_len=!str_len!"
    
)
SET /A "max_char=longest_str_len+3"
SET "%ptr_SelectedPackage%.Items.MaxStringLength=%max_char%"


REM echo longest_str_len %longest_str_len%
REM Fill char
SET "tmp_str="
FOR /L %%G IN (1,1,!%ptr_SelectedPackage%.Items.Length!) DO (
    SET "app_name=!%ptr_SelectedPackage%.Items[%%G]!"
    SET "app_desc=!%ptr_SelectedPackage%.Items[%%G].desc!"
    CALL SET "status=%%AppCfg[!app_name!].status%%"
    CALL SET "status_code=%%AppCfg[!app_name!].status_code%%"

    SET "str_len=!%ptr_SelectedPackage%.Items[%%G].desc.StringLength!"
    SET /A "fill_char_count=max_char-str_len"
    CALL:repeat_char - !fill_char_count! fill_char
    
    SET "desc_lineformat=!app_desc! !fill_char!"
    IF !status_code! NEQ 0 (
        call:str_color "!desc_lineformat!" %COLOR_RED% desc_colorlineformat
        call:str_color "!status!" %COLOR_RED% status_colorformat
        SET "tmp_str=!desc_colorlineformat! !status_colorformat!"
    ) ELSE (
        call:str_color "!status!" %COLOR_GREEN% status_colorformat
        SET "tmp_str=!desc_lineformat! !status_colorformat!"
    )
    
    SET "%ptr_SelectedPackage%.Items[%%G].MenuEntry=!tmp_str!"
    SET "%ptr_SelectedPackage%.Items[%%G].Desc.LineFormat=!desc_lineformat!"
    SET "%ptr_SelectedPackage%.Items[%%G].PreparationStatus=!status!"
    SET "%ptr_SelectedPackage%.Items[%%G].PreparationStatus.ColorFormat=!status_colorformat!"
    
    REM echo tmp_str !tmp_str!

    REM IF !pkg_item_%%G.status_code! NEQ 0 (
    REM     call:str_color "!tmp_str!" %COLOR_RED% tmp_str
    REM )
    REM IF !AppCfg[].status_code! NEQ 0 (
    REM     call:str_color "!tmp_str!" %COLOR_RED% tmp_str
    REM )
    REM SET "pkg_item_%%G_in_menu_text=!tmp_str! !pkg_item_%%G.status!"
    
)
REM pausepause

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

:prepare_AppPackages_menu_entry AppPackages['name']
SetLocal EnableExtensions EnableDelayedExpansion
SET "paket=%~1"

(ENDLOCAL & REM -- RETURN VALUES
    IF "%out_result%" NEQ "" (set "%out_result%=%desc%") ELSE ECHO %out_result%
    EXIT /B %exit_code%
)
