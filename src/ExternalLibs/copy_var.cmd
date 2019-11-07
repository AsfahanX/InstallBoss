:copy_var src_var dst_var
%ECHO_VERBOSE% :copy_var %*
SET "src_var=%~1"
SET "dst_var=%~2"
REM SET "command=SET "%src_var%""
SET "command=SET %src_var%^| findstr /LIBC:"%src_var%""
(
    FOR /F "tokens=1* delims==" %%G in ('%command%') DO (
        SET "var_name=%%G"
        SET "attr_name=!var_name:%src_var%=!"
        SET "%dst_var%!attr_name!=%%H"
    )
) > nul 2>&1 && (exit /b !ERRORLEVEL!) || (exit /b !ERRORLEVEL!)
REM echo ERRORLEVEL !ERRORLEVEL!
