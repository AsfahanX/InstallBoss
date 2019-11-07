@echo off
CD /D "%~dp0"

SET target_filename=InstallBoss.cmd

SET "src_path=src"
SET "library_path=src\Libs"
SET "external_library_path=src\ExternalLibs"

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
echo Settings
(
    type "%src_path%\settings.cmd"
) >> "%target%"

REM Init
echo Init
(
    type "%src_path%\init.cmd"
) >> "%target%"

REM Main
echo Main
(
    type "%src_path%\main.cmd"
) >> "%target%"

echo ==================================================
REM Include libraries
(echo.& echo.)>> "%target%"
(
    echo %line%& echo %line%
    echo REM                     BEGIN INTERNAL SUBROUTINES
    echo.& echo.
) >> "%target%"
For /R "%library_path%" %%G IN (*.cmd) do (
    REM Command
    echo Include File: %%G
    (
        echo %line%& echo.
        type "%%~fG"
        echo.& echo.& echo %line%& echo.
    ) >> "%target%"
)
(
    echo.& echo.
    echo REM                     END INTERNAL SUBROUTINES
    echo %line%& echo %line%
) >> "%target%"


echo ==================================================
REM Include External libraries
(echo.& echo.)>> "%target%"
(
    echo %line%& echo %line%
    echo REM                     BEGIN EXTERNAL SUBROUTINES
    echo.& echo.
) >> "%target%"
For /R "%external_library_path%" %%G IN (*.cmd) do (
    REM Command
    echo Include File: %%G
    (
        echo %line%& echo.
        type "%%~fG"
        echo.& echo.& echo %line%& echo.
    ) >> "%target%"
)
(
    echo.& echo.
    echo REM                     END EXTERNAL SUBROUTINES
    echo %line%& echo %line%
) >> "%target%"
