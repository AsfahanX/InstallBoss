@echo off
CD /D "%~dp0"

SET target_filename=InstallBoss-binary.cmd

SET "src_path=src"
SET "library_path=src\libs"

SET target=%~dp0%target_filename%

SET line=REM =======================================================================

echo ==================================================
echo Building file %target%
echo.
type nul > "%target%"

REM Header
echo Header
(
    type "%src_path%\header.cmd"
) >> "%target%"

REM Settings
echo Header
(
    type "%src_path%\header.cmd"
) >> "%target%"

REM Main
echo Header
(
    type "%src_path%\header.cmd"
) >> "%target%"

REM Include libraries
For /R "%library_path%" %%G IN (*.cmd) do (
    REM Command
    echo Include File: %%G
    (
        echo %line%
        echo.
        type "%%~fG"
        echo.
        echo.
        echo %line%
        echo.
    ) >> "%target%"
)

