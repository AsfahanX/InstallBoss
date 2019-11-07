@echo off
SetLocal EnableDelayedExpansion
CD /D "%~dp0"

SET target_filename=InstallBoss-binary.cmd

echo Scanning included funtion
FOR /F "tokens=1* delims=:" %%G in (' TYPE "%target_filename%" ^| FINDSTR /RNIC:"^:[a-zA-Z0-9]" ') DO (
    FOR /F %%g in ("%%H") DO (
        SET "label_name=%%g"
        IF "!label_%%g!" NEQ "" (
            IF "!duplicate_label_%%g!" EQU "" (
                SET "duplicate_label_%%g=1"
            )
            SET "label_%%g=!label_%%g! %%G"
        ) ELSE SET "label_%%g=%%G"
    )
    echo label: !label_name!     line: %%G
)
exit /b

echo Checking function call . . .
SET "count=0"
FOR /F "tokens=1* delims=" %%G in (' TYPE "%target_filename%" ^| FINDSTR /VRNIC:"^[\t ]*REM" ^| FINDSTR /RIC:"^[0-9]*:.*CALL[ ]*:"  ') DO (
REM FOR /F "tokens=1* delims=" %%G in (' TYPE "%target_filename%" ^| FINDSTR /RIC:"CALL[ ]*:"  ') DO (
    echo %%G%%H
    SET /A "count+=1"
)
echo %count% lines