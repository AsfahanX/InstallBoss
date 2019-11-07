:create_shortcut file url

REM Obtain from google
(
    echo [{000214A0-0000-0000-C000-000000000046}]
    echo Prop3=19,11
    echo [InternetShortcut]
    echo IDList=
    echo URL=%2
    echo HotKey=0
) > "%~1"
exit /b
