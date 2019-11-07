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
