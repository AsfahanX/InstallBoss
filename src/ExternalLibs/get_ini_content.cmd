:get_ini_content file outVar
REM Example 1:
REM     To acces key's value:
REM     get_ini_content "config.ini" IniContent
REM     echo %IniContent[section][key]%
REM Example 2:
REM     To loop through all section:
REM     get_ini_content "config.ini" IniContent
REM     FOR /L %%G in (1,1,%IniContent.section.length%) do (
REM         echo !IniContent.section[%%G]!
REM     )
REM Example 3:
REM     To loop through all keys in section:
REM     get_ini_content "config.ini" IniContent
REM     SET section=section name
REM     FOR /L %%G in (1,1,!IniContent[%section%].key.length!) do (
REM         echo key %%G: !IniContent[%section%].key[%%G]!
REM     )
SET /A "section_num=0"
SET /A "key_num=0"
SET "section=NO_SECTION"
SET "key="
FOR /F "delims=" %%G in ('type "%~1"') DO (
    set "line=%%G"
    IF "!line:~0,1!" EQU ";" (
        REM DO nothing comment
    ) ELSE IF "!line:~0,1!" EQU "[" (
        SET /A "section_num=section_num+1"
        SET /A "key_num=0"
        FOR /F "delims=[]" %%g in ("!line!") DO (
            SET "section=%%g"
            SET "%~2.section[!section_num!]=!section!"
            SET "%~2[!section!].key.length=!key_num!"
            SET "%~2[!section!].Exist=1"
        )
    ) ELSE (
        FOR /F "tokens=1* delims==" %%g in ("!line!") DO (
            SET /A "key_num=key_num+1"
            SET "%~2[!section!][%%g]=%%h"
            SET "%~2[!section!].key[!key_num!]=%%g"
            SET "%~2[!section!].key.length=!key_num!"
        )
    )
)
SET /A "%~2.section.length=%section_num%"
exit /b
