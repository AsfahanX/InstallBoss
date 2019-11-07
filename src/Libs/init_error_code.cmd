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
