REM ====================================================================
REM MAIN
REM CALL:main
REM :end
REM.-- End of application
REM FOR /l %%a in (5,-1,1) do (TITLE %title% -- closing in %%as&ping -n 2 -w 1 127.0.0.1>NUL)
REM TITLE Press any key to close the application
REM ECHO.

REM REM If script launched from explorer, pause
REM SET /A "interactive=0"
REM ECHO %CMDCMDLINE%| FINDSTR /LXC:"\"%COMSPEC%\" "
REM IF %ERRORLEVEL% EQU 0 SET /A "interactive=1"
REM IF %interactive% NEQ 1 pause

REM EXIT /B

REM ====================================================================
REM MAIN
:main


REM ====================================================================
REM MAIN MENU
SET "menu_item_prefix=   "

REM :menu_pilih_paket
:scan_paket
SET "pkgs_num=0"
SET /A "AppPackages.Length=0"
SET "tmp_nama_paket="
SET "tmp_file_name="
%LOG% Searching paket files
FOR /F "tokens=*" %%G in ('dir "%script_path%" /b /a-d /od ^| findstr /i /r /c:"^%script_base_name%\.paket\..*\.txt$"') do (
    SET /A pkgs_num+=1
    SET /A "AppPackages.Length+=1"
    SET "tmp_pkgs_filename=%%~nG"
    SET "tmp_pkgs_desc=!tmp_pkgs_filename:%script_base_name%.paket.=!"
    SET "tmp_nama_paket="
    SET "pkgs_!pkgs_num!_file=%%~G"
    SET "pkgs_!pkgs_num!_desc=Paket !tmp_pkgs_desc!"
   
    SET AppPackages[!AppPackages.Length!]=!tmp_pkgs_desc!
    SET AppPackages['!tmp_pkgs_desc!'].File=%%~fG
    SET "items_num=0"
    FOR /F "delims=" %%g in ('type "%%~fG"') DO (
        SET /A "items_num+=1"
        SET "AppPackages['!tmp_pkgs_desc!'].Items[!items_num!]=%%g"
    )
    SET "AppPackages['!tmp_pkgs_desc!'].Items.Length=!items_num!"
    SET "AppPackages['!tmp_pkgs_desc!'].MenuEntry=Paket !tmp_pkgs_desc! [!items_num! Apps]"
    REM )
)
%LOG% Found %pkgs_num% paket
REM set AppPackages
REM pause

:menu_pilih_paket
CLS
echo.========================================================
echo.= MENU =================================================
echo.
echo     Paket Instalasi:
FOR /L %%G IN (1,1,%AppPackages.Length%) DO (
    IF %%G LSS 10 SET "prefix=%menu_item_prefix% "
    REM echo !prefix!%%A. !pkgs_%%A_desc!
    SET "index=%%A"
    SET "menu_entry=!prefix!%%G. !pkgs_%%G_desc!"
    SET "nama_paket=!AppPackages[%%G]!"
    REM echo !prefix!%%A. !nama_paket!
    call echo !prefix!%%G. %%AppPackages['!nama_paket!'].MenuEntry%%
)
echo.
echo     Opsi Lainnya:
echo     B  Buat Paket Instalasi Baru
echo     E  Buat Contoh Struktur Folder
echo     I  Install Semua Folder
echo.
SET "menu_pilih_paket_choice="
SET /P menu_pilih_paket_choice="Pilih Paket Instalasi: "
IF NOT DEFINED menu_pilih_paket_choice goto menu_pilih_paket

REM SET "var="&for /f "delims=0123456789" %%i in ("%1") do set var=%%i
REM if defined var (echo %1 NOT numeric) else (echo %1 numeric)
REM IF /I "%menu_pilih_paket_choice%"=="" goto :menu_pilih_paket
REM IF /I "%menu_pilih_paket_choice%"=="B" goto :
REM IF /I "%menu_pilih_paket_choice%"=="E" goto :
REM IF /I "%menu_pilih_paket_choice%"=="I" goto :

IF /I "%menu_pilih_paket_choice%"=="E" (
    REM REM Buat Contoh Struktur Folder
    REM SET /A "folder_found=0"
    REM FOR /F "delims=" %%G in ('DIR "%search_location%" /ad-h /B ^| findstr /v /r /c:"^[.]"') DO (
    REM     SET /A "folder_found=1"
    REM )
    REM IF %folder_found% EQU 0 (
    REM     SET "input_yes_no=N"
    REM     SET /P input_yes_no="Buat Contoh Struktur Folder [y/N] ? "
    REM     IF /I "!input_yes_no!"=="y" (
            call:create_example_folder_structure
        REM )
    REM )

)

REM Paket Semua folder
REM IF "%menu_pilih_paket_choice%"=="i" SET "menu_pilih_paket_choice=I"
IF /I "%menu_pilih_paket_choice%"=="I" (
    %LOG% [USER INPUT] Menu Install Semua Folder is selected
    SET "pkg_desc=Paket Semua Folder"
    SET "pkg_file=%paket_semua_folder_file%"
    DIR "%search_location%" /ad-h /B | findstr /v /r /c:"^[.]">"!pkg_file!"
    IF EXIST "!pkg_file!" (
        %LOG% paket file created: !pkg_file!
    ) ELSE (
        >&2 echo Can't create paket file !pkg_file!
        pause
        goto :menu_pilih_paket
    )
    REM attrib +H "%tmp_file%"

    SET AllFolderPackage=Semua Folder
    SET AllFolderPackage.File=!pkg_file!
    SET "items_num=0"
    FOR /F "delims=" %%g in ('type "!pkg_file!"') DO (
        SET /A "items_num+=1"
        SET "AllFolderPackage.Items[!items_num!]=%%g"
    )
    SET "AllFolderPackage.Items.Length=!items_num!"
    SET "AllFolderPackage.MenuEntry=Paket Semua Folder [!items_num! Apps]"
    SET "ptr_SelectedPackage=AllFolderPackage"
    goto:menu_isi_paket
)

REM Buat paket
REM IF "%menu_pilih_paket_choice%"=="b" SET "menu_pilih_paket_choice=B"
IF /I "%menu_pilih_paket_choice%"=="B" (
    %LOG% [USER INPUT] Menu Buat Paket is selected
    CALL:buat_paket pkg_desc pkg_file
    IF EXIST "!pkg_file!" (
        %LOG% paket file created: !pkg_file!
        SET /A "AppPackages.Length+=1"
        SET AppPackages[!AppPackages.Length!]=!pkg_desc!
        SET AppPackages['!pkg_desc!'].File=!pkg_file!
        SET "items_num=0"
        FOR /F "delims=" %%g in ('type "!pkg_file!"') DO (
            SET /A "items_num+=1"
            SET "AppPackages['!pkg_desc!'].Items[!items_num!]=%%g"
        )
        SET "AppPackages['!pkg_desc!'].Items.Length=!items_num!"
        SET "AppPackages['!pkg_desc!'].MenuEntry=Paket !pkg_desc! [!items_num! Apps]"
        SET "ptr_SelectedPackage=AppPackages['!pkg_desc!']"
    ) ELSE (
        >&2 echo Can't create paket file !pkg_file!
    )
    REM SET "pkg_desc=Paket !pkg_desc!"

    goto menu_isi_paket
)

IF "!AppPackages[%menu_pilih_paket_choice%]!" NEQ "" (
REM IF DEFINED pkgs_%menu_pilih_paket_choice%_file (
    REM Load paket pilihan
    SET "pkg_file=!pkgs_%menu_pilih_paket_choice%_file!"
    SET "pkg_desc=!pkgs_%menu_pilih_paket_choice%_desc!"
    
    SET "key=!AppPackages[%menu_pilih_paket_choice%]!"
    SET "ptr_SelectedPackage=AppPackages['!key!']"
    
    %LOG% [USER INPUT] paket file selected: !pkg_file!
) ELSE goto menu_pilih_paket


:menu_isi_paket
SET "pkg_length=0"
%ECHO_VERBOSE% 1 "Loading INI file . . ."
%LOG% Loading paket file: !pkg_file!
FOR /F "delims=" %%G in ('type "!%ptr_SelectedPackage%.File!"') DO (
REM FOR /F "delims=" %%A in ('type "!pkg_file!"') DO (
    SET /A pkg_length+=1
    SET pkg_item_!pkg_length!=%%G
    SET pkg_item_!pkg_length!_in_menu_text=%%G

    REM SET "%ptr_SelectedPackage%.Items[%%G].MenuEntry=%%G"
    REM SET "%ptr_SelectedPackage%.Items.Length=!pkg_length!"
    REM SET "%ptr_SelectedPackage%.Items[!pkg_length!]=%%A"
    REM IF "!AppCfg[%%A].is_loaded!" NEQ "1" (
    REM     CALL:get_appcfg IniContent "%%A" AppCfg
    
    REM )
    REM SET "%SelectedAppPackages%[!pkg_length!]=%%A"
)
%LOG% Found %pkg_length% items



REM CALL:check_app_cfg

REM SET /A "show_param=0"
REM SET /A "show_file=0"
SET /A "show_detail=0"
:menu_display_isi_paket
CLS
echo Found %pkg_length% apps in %pkg_desc%:
echo.
FOR /L %%G IN (1,1,!%ptr_SelectedPackage%.Items.Length!) DO (
    IF %%G LSS 10 (
        SET "prefix= "
        SET "prefix_ex="
    ) ELSE (
        SET "prefix="
        SET "prefix_ex= "
    )
    REM echo.  !prefix!%%A. !pkg_item_%%A_in_menu_text!
    SET "menu_entry=!%ptr_SelectedPackage%.Items[%%G].MenuEntry!"
	SET "app_name=!%ptr_SelectedPackage%.Items[%%G]!"
    IF "!menu_entry!" EQU "" (
        SET "menu_entry=!app_name!"
    )
    echo.  !prefix!%%G. !menu_entry!
    REM echo.  !prefix!%%G. !%ptr_SelectedPackage%.Items[%%G].Desc.LineFormat! !%ptr_SelectedPackage%.Items[%%G].PreparationStatus!
    
    REM IF "%show_file%" EQU "1" echo.  !prefix!!prefix_ex!   file  : !pkg_item_%%G.installer_file!
    REM IF "%show_param%" EQU "1" echo.  !prefix!!prefix_ex!   param : !pkg_item_%%G.param!
    IF %show_detail% EQU 1 (
        REM echo.  !prefix!!prefix_ex!   file  : !pkg_item_%%G.installer_file!
        REM echo.  !prefix!!prefix_ex!   param : !pkg_item_%%G.param!
		REM call echo.  !prefix!!prefix_ex!   file  : %%AppCfg[Winrar].installer_file%%
        call echo.  !prefix!!prefix_ex!   file  : %%AppCfg[!app_name!].installer_file%%
        call echo.  !prefix!!prefix_ex!   param : %%AppCfg[!app_name!].param%%
        
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
echo     2. Check Status
echo     0. Kembali ke Menu Sebelumnya
echo.
echo     Option:
IF %show_detail% EQU 1 (
    echo     3. Hide Details
) ELSE echo     3. Show Details
echo     4. Test Command
echo.
SET /P input_menu_install="Pilih Menu: "
IF %input_menu_install%==0 goto menu_pilih_paket
IF %input_menu_install%==2 (
    %LOG% Menu item selected: 2. Check Status
    CALL:check_app_cfg
    goto:menu_display_isi_paket
)
IF %input_menu_install%==3 (
    REM SET "show_param=1"
    REM SET "show_file=1"
    IF %show_detail% EQU 0 (
        SET /A "show_detail=1"
        %LOG% Menu item selected: 3. Show Details
    ) ELSE (
        SET /A "show_detail=0"
        %LOG% Menu item selected: 3. Hide Details
    )
    goto:menu_display_isi_paket
)
IF NOT "%input_menu_install%"=="1" (
    IF NOT "%input_menu_install%"=="4" goto:menu_display_isi_paket
)
IF "%input_menu_install%"=="1" SET "install_mode=%_MODE_INSTALL%"
IF "%input_menu_install%"=="4" SET "install_mode=%_MODE_TEST%"

%LOG% Menu item selected: %input_menu_install%. 

REM ====================================================================
REM START INSTALLING
SET "apps_count=!%ptr_SelectedPackage%.Items.Length!"
CALL:initProgress %pkg_length% "[[PPPP]] %title% - [[C] of %apps_count%] Installing"
CLS

SET fail_count=0
SET background_install_running_count=0
SET background_install_finished_count=0
CALL:prepare_installation_status
FOR /L %%G IN (1,1,%apps_count%) DO (
    SET "%ptr_SelectedPackage%.Items[%%G].InstallState.ChangeFlag=1"
    CALL:update_installation_status

    SET "app_name=!%ptr_SelectedPackage%.Items[%%G]!"
    SET "app_exit_code="
    CALL SET "wait=%%AppCfg[!app_name!].wait%%"
    echo [%%G/%apps_count%]
    
    CALL:install_2 "!app_name!" "AppCfg[!app_name!]"
    SET "app_exit_code=!ERRORLEVEL!"
    IF /I "!wait!" EQU "true" (
        SET "%ptr_SelectedPackage%.Items[%%G].ExitCode=!app_exit_code!"
        SET "%ptr_SelectedPackage%.Items[%%G].InstallState.ExitCode=!app_exit_code!"
    ) ELSE (
        set /A "background_install_running_count+=1"
        SET "%ptr_SelectedPackage%.Items[%%G].ExitCodeFile=%tmp_folder%\!app_name!.exit_code.tmp"
        SET "%ptr_SelectedPackage%.Items[%%G].InstallState.ExitCodeFile=%tmp_folder%\!app_name!.exit_code.tmp"
    )
    IF !app_exit_code! NEQ 0 (SET "fail_count+=1")
    echo.
    CALL:doProgress "!app_name!"
    SET "%ptr_SelectedPackage%.Items[%%G].InstallState.ChangeFlag=1"
)
:wait_background_install
CALL:update_installation_status
IF %background_install_finished_count% LSS %background_install_running_count% (
    echo ================================================================
    echo.
    %ECHO_DEBUG% %background_install_finished_count% of %background_install_running_count% Background installation finihed
    SET /P ="Waiting For Background Installation . . . "<nul
    ping /n 3 127.0.0.1>nul
    echo.
    goto:wait_background_install
)
echo.
REM echo Done ^^!
REM echo 
REM exit /b

REM CALL:wait_bg_install

REM echo.
REM echo.
REM echo Done ^^!
REM echo.

REM REM Failed Info
REM IF %fail_count% EQU 0 goto main_end
REM echo =====================================
REM REM echo [31mWARNING[0m
REM CALL:echo_err "WARNING !"
REM echo %fail_count% apps failed to install
REM SET "ctr=0"
REM FOR /L %%G IN (1,1,%apps_count%) DO (
    
REM     SET /A code=!pkg_item_%%G_exit_code!
REM     SET "code=!%ptr_SelectedPackage%.Items[%%G].ExitCode!"
REM     CALL:get_error_description !code! desc
REM     IF !code! NEQ 0 (
REM         SET /A "ctr+=1"
REM         echo    !ctr!. !pkg_item_%%G! ===^> Code: !code!. !desc!
REM     )
REM )
REM FOR /L %%G IN (1,1,%bg_proc_num%) DO (
REM     REM echo    !bg_proc_%%A!. Exit Code: !bg_proc_%%A_exit_code!
REM     SET /A code=!bg_proc_%%G_exit_code!
REM     CALL:get_error_description !code! desc
REM     IF !code! NEQ 0 (
REM         SET /A "ctr+=1"
REM         REM echo    %%G. !pkg_item_%%G! ===^> !desc!
REM         echo    !ctr!. !bg_proc_%%G! ===^> !desc!
REM     )
REM )

:main_end
echo Done ^^!
echo.
echo 
REM EXIT /B

REM If script launched from explorer, pause
SET /A "interactive=0"
ECHO %CMDCMDLINE%| FINDSTR /LXC:"\"%COMSPEC%\" "
IF %ERRORLEVEL% EQU 0 SET /A "interactive=1"
IF %interactive% NEQ 1 (
    SET /P ="Press any key to exit . . . " < nul
    pause > nul
    echo.
)

EXIT /B