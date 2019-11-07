:create_example_folder_structure
echo Creating Folder structure example on %search_location%
SET "ini_key_for_download=direct_download_url"
SET "ini_key_for_download_32=direct_download_url_32"
SET "ini_key_for_download_64=direct_download_url_64"

SET "command=SET IniContent.section[ ^| findstr /RC:"^IniContent\.section\[[0-9][0-9]*\]=""
FOR /F "tokens=1* delims==" %%G in ('%command%') DO (
    SET "section=%%H"

    REM 32/64
    SET "shortcut_dir=%search_location%\!section!"
    SET "ini_key=%ini_key_for_download%"
    IF DEFINED IniContent[!section!][!ini_key!] (
        IF NOT EXIST "!shortcut_dir!" MD "!shortcut_dir!"
        SET "shortcut_file=!shortcut_dir!\!ini_key!.url"
        CALL SET "url=%%IniContent[!section!][!ini_key!]%%"
        echo Creating shortcut for !section!
        call:create_shortcut "!shortcut_file!" "!url!"
    )

    REM 32
    SET "shortcut_dir=%search_location%\!section!\32"
    SET "ini_key=%ini_key_for_download_32%"
    IF DEFINED IniContent[!section!][!ini_key!] (
        IF NOT EXIST "!shortcut_dir!" MD "!shortcut_dir!"
        SET "shortcut_file=!shortcut_dir!\!ini_key!.url"
        CALL SET "url=%%IniContent[!section!][!ini_key!]%%"
        echo Creating shortcut for !section!
        call:create_shortcut "!shortcut_file!" "!url!"
    )

    REM 64
    SET "shortcut_dir=%search_location%\!section!\64"
    SET "ini_key=%ini_key_for_download_64%"
    IF DEFINED IniContent[!section!][!ini_key!] (
        IF NOT EXIST "!shortcut_dir!" MD "!shortcut_dir!"
        SET "shortcut_file=!shortcut_dir!\!ini_key!.url"
        CALL SET "url=%%IniContent[!section!][!ini_key!]%%"
        echo Creating shortcut for !section!
        call:create_shortcut "!shortcut_file!" "!url!"
    )
)

REM md "%search_location%\VLC Media Player"
REM call:create_shortcut "%search_location%\VLC Media Player\test.url" "http://www.google.com"
pause
exit /b
