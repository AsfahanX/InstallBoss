:prepare_installation_status

CALL:check_app_cfg

FOR /L %%G IN (1,1,!%ptr_SelectedPackage%.Items.Length!) DO (
    IF %%G LSS 10 (
        SET "prefix= "
        SET "prefix_ex="
    ) ELSE (
        SET "prefix="
        SET "prefix_ex= "
    )
    
    SET "ptr_item=%ptr_SelectedPackage%.Items[%%G]"
    SET "!ptr_item!.InstallState.ChangeFlag=0"
    SET "!ptr_item!.InstallState.Status="
    SET "!ptr_item!.InstallState.ExitCode="
    SET "!ptr_item!.InstallState.ExitCodeFile="

    SET "!ptr_item!.InstallState.Text= !prefix!%%G. !%ptr_SelectedPackage%.Items[%%G].Desc.LineFormat! Pending"
)
exit /b
