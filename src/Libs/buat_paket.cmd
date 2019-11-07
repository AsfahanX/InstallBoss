:buat_paket new_pkg_desc new_pkg_file
REM params:
REM		-- [OUT]		retvar			 - Var to store Return Value. Paket desc
REM		-- [OUT]		retvar			 - Var to store Return Value. Paket file
SetLocal EnableExtensions EnableDelayedExpansion
SET "new_pkg_desc=%~1"
SET "new_pkg_file=%~2"

SET /A "pkg_item_length=0"
FOR /F "tokens=*" %%A in ('DIR "%search_location%" /ad-h /B ^| findstr /v /r /c:"^\."') DO (
    SET /A pkg_item_length+=1
    SET pkg_item_!pkg_item_length!=%%A
    SET /A "pkg_item_!pkg_item_length!_selected=0"
)

SET "selected_pkg_buffer= "
:buat_paket__compose
CLS
echo Found %pkg_item_length% apps in current folder:
echo.
FOR /L %%A IN (1,1,%pkg_item_length%) DO (
    IF !pkg_item_%%A_selected! EQU 1 (SET "prefix=  V  ") ELSE SET "prefix=     "
    IF %%A LSS 10 SET "prefix=!prefix! "
    echo !prefix!%%A. !pkg_item_%%A!
)
echo.
SET "new_pkg_input="
SET /P new_pkg_input="Pilih nomor app yg ingin ditambahkan (tekan 'Y' utk selesai): "

IF NOT DEFINED pkg_item_%new_pkg_input% (
    IF "%new_pkg_input%"=="Y" goto :buat_paket__confirm
    IF "%new_pkg_input%"=="y" goto :buat_paket__confirm
) ELSE (
    %LOG% [USER INPUT] %new_pkg_input%
    IF !pkg_item_%new_pkg_input%_selected! EQU 1 (
        %LOG% Removed !pkg_item_%new_pkg_input%!
        SET /A "pkg_item_%new_pkg_input%_selected=0"
        SET "selected_pkg_buffer=!selected_pkg_buffer: %new_pkg_input% = !"
    ) ELSE (
        %LOG% Added !pkg_item_%new_pkg_input%!
        SET /A "pkg_item_%new_pkg_input%_selected=1"
        SET "selected_pkg_buffer=%selected_pkg_buffer%%new_pkg_input% "
    )
)
goto :buat_paket__compose

:buat_paket__confirm
SET /A "selected_pkg_num=0"
FOR %%A in (%selected_pkg_buffer%) DO (
    SET /A "selected_pkg_num+=1"
    SET "selected_pkg_!selected_pkg_num!=!pkg_item_%%A!"
)

echo.
echo Paket baru:
FOR /L %%A IN (1,1,%selected_pkg_num%) DO (
    echo    %%A. !selected_pkg_%%A!
)
echo.

:buat_paket__nama_paket
SET /P nama_paket="Nama Paket: "
%LOG% [USER INPUT] Nama Paket: "%nama_paket%"
IF "%nama_paket%"=="" goto:buat_paket__nama_paket
SET "paket_file=%~dpn0.paket.%nama_paket%.txt"

:buat_paket__nama_paket_confirm
SET "nama_paket_confirm=y"
IF EXIST "%paket_file%" (
    CALL:str_color "Paket dengan nama %nama_paket% sudah ada. Lanjutkan [Y/n]" %COLOR_RED% nama_paket_confirm_text
    SET /P nama_paket_confirm="!nama_paket_confirm_text! "
    %LOG% [USER INPUT] nama_paket_confirm=%nama_paket_confirm%
)
IF DEFINED nama_paket_confirm (
    IF "%nama_paket_confirm%"=="Y" goto:buat_paket__create_file
    IF "%nama_paket_confirm%"=="y" goto:buat_paket__create_file
)

goto:buat_paket__nama_paket

:buat_paket__create_file
REM create empty file
(type nul> "%paket_file%") > nul
REM copy nul %paket_file% > nul 2>&1

IF NOT EXIST "%paket_file%" (
    echo [ERROR] Nama paket invalid. Coba nama lain 1>&2
    echo.
    goto buat_paket__nama_paket
)
REM Write to file
FOR /L %%A IN (1,1,%selected_pkg_num%) DO (
    echo !selected_pkg_%%A!>> "%paket_file%"
)

:buat_paket__end
(ENDLOCAL & REM -- RETURN VALUES
    IF "%new_pkg_desc%" NEQ "" SET "%new_pkg_desc%=%nama_paket%"
    IF "%new_pkg_file%" NEQ "" SET "%new_pkg_file%=%paket_file%"
)
EXIT /B %errorlevel%
