:update_installation_status
CLS
echo Installation Status
echo.
FOR /L %%G IN (1,1,!%ptr_SelectedPackage%.Items.Length!) DO (
    IF !%ptr_SelectedPackage%.Items[%%G].InstallState.ChangeFlag! EQU 1 (
        SET "%ptr_SelectedPackage%.Items[%%G].InstallState.ChangeFlag=0"
        REM SET ptr_item=
        SET "exit_code=!%ptr_SelectedPackage%.Items[%%G].InstallState.ExitCode!"
        SET "exit_code_file=!%ptr_SelectedPackage%.Items[%%G].InstallState.ExitCodeFile!"

        IF "!exit_code!" EQU "" (
            SET status=Installing
            IF "!exit_code_file!" NEQ "" (
                IF EXIST "!exit_code_file!" (
                    REM Background has finihed
                    SET /A "background_install_finished_count+=1"
                    FOR /F %%G in ('TYPE "!exit_code_file!"') DO SET "exit_code=%%G"
                    IF "!exit_code!" EQU "" (
                        REM This should never happen.
                        REM background install should redirect ErrorLevel value to the file
                    ) ELSE IF !exit_code! EQU 0 (
                        call:str_color "SUCCESS" %COLOR_GREEN% status
                    ) ELSE (
                        call:str_color "FAILED. Exit Code: !exit_code!." %COLOR_RED% status
                    )
                ) ELSE (
                    REM Background Still Running, check again next
                    SET "%ptr_SelectedPackage%.Items[%%G].InstallState.ChangeFlag=1"
                )
            )
            
        ) ELSE (
            IF !exit_code! EQU 0 (
                call:str_color "SUCCESS" %COLOR_GREEN% status
            ) ELSE (
                call:str_color "FAILED. Exit Code: !exit_code!." %COLOR_RED% status
            )
        )
        set "%ptr_SelectedPackage%.Items[%%G].InstallState.Text= !prefix!%%G. !%ptr_SelectedPackage%.Items[%%G].Desc.LineFormat! !status!"
    )
    echo !%ptr_SelectedPackage%.Items[%%G].InstallState.Text!
)
    REM SET "exit_code=!%ptr_item%.ExitCode!"
    REM SET "exit_code_file=!%ptr_item%.ExitCodeFile!"

    REM IF "!exit_code!" EQU "" (
    REM     SET install_state=Running
    REM ) ELSE (
    REM     IF !exit_code! EQU 0 (
    REM         call:str_color "SUCCESS" %COLOR_GREEN% install_state
    REM     ) ELSE (
    REM         call:str_color "FAILED. Exit Code: !exit_code!." %COLOR_RED% install_state
    REM     )
    REM )

    REM echo.  !prefix!%%A. !pkg_item_%%A_in_menu_text!
    REM SET "menu_entry=!%ptr_SelectedPackage%.Items[%%G].MenuEntry!"
    REM IF "!menu_entry!" EQU "" (
    REM     SET "app_name=!%ptr_SelectedPackage%.Items[%%G]!"
    REM     SET "menu_entry=!app_name!"
    REM )
    REM echo.  !prefix!%%G. !menu_entry!
    REM echo.  !prefix!%%G. !%ptr_SelectedPackage%.Items[%%G].Desc.LineFormat! !%ptr_SelectedPackage%.Items[%%G].PreparationStatus!
echo.
exit /b
