:create_default_ini_file filename retval param3
REM params:
REM		-- [IN]			param1			 - input
REM		-- [OUT]		retvar			 - Var to store Return Value.
REM		-- [IN,OPT]		param3			 - Optional. param3
SetLocal EnableExtensions EnableDelayedExpansion
SET "filename=%~1"
SET /A "exit_code=0"

REM HEADER
(
    echo ; GENERATED CONFIGURATION FILE 
    echo ;      AT        : %DATE% %TIME%
    echo ;      FROM FILE : %~f0
    echo ;      TO FILE   : %filename%
    echo ; 
    echo ; ==================================================================
    echo ;
    echo ; [Folder Name]
    echo ; Parameter to pass. Default: /passive
    echo ; param=
    echo ;
    echo ; Default: true
    echo ; wait=true/false
    echo ;
    echo ; Default: setup.exe
    echo ; installer_file=
    echo ;
    echo ; Default: %%PROGRAMFILES%%\[App Name]\
    echo ; crack_dst=
    echo ;
    echo ; -----------------------------------------------
    echo ; MSI packages
    echo ;      /quiet /norestart
    echo ;      /passive /norestart
    echo ; Inno Setup
    echo ;      /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-
    echo ;      /SILENT /SUPPRESSMSGBOXES /NORESTART /SP-
    echo ; Nullsoft Scriptable Install System NSIS
    echo ;      /S
    echo ;
    echo ; More info about silent/unattended installation at:
    echo ;      http://unattended.sourceforge.net/installers.php
    echo ;      https://docs.microsoft.com/en-us/windows/win32/msi/standard-installer-command-line-options
    echo ;
    echo ; -------------------------------------------------
    echo ; Some tools to detect silent install switches:
    echo ; Silent Key Finder
    echo ; 	https://www.softpedia.com/get/System/Launchers-Shutdown-Tools/Silent-key-finder.shtml
    echo ; Universal Silent Switch Finder
    echo ; 	https://www.softpedia.com/get/System/Launchers-Shutdown-Tools/Universal-Silent-Switch-Finder.shtml
    echo ; Silent Install Builder
    echo ;
    echo ; ==================================================================
    echo ;
) > "%filename%"

REM CONTENT
(
    echo [7Zip]
    echo param=/passive /norestart
    echo param_quiet=/quiet /norestart
    echo param_exe=/S
    echo ; wait=false
    echo [AIMP]
    echo param=/AUTO /SILENT
    echo [Adobe Flash Player]
    echo param=-install
    echo [Adobe Acrobat Reader DC]
    echo ; https://www.adobe.com/devnet-docs/acrobatetk/tools/AdminGuide/basics.html#expanding-exe-packages
    echo ; param=-sfx_nu /sALL /msi EULA_ACCEPT=YES
    echo param=/sPB /msi /norestart EULA_ACCEPT=YES
    echo param_quiet=-sfx_nu /sALL /msi /norestart EULA_ACCEPT=YES
    echo direct_download_url=http://ardownload.adobe.com/pub/adobe/reader/win/AcrobatDC/1901220036/AcroRdrDC1901220036_en_US.exe
    echo [Adobe Flash Player for Chrome, Chromium, Opera, UC Browser]
    echo param=-install
    echo [Adobe Flash Player for Firefox, Safari]
    echo param=-install
    echo [Adobe Flash Player for Internet Explorer]
    echo param=-install
    echo [Adobe Photoshop CS 4]
    echo param=/SILENT /SUPPRESSMSGBOXES /NORESTART /SP-
    echo param-quiet=/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-
    echo [CCleaner]
    echo param=/S /IT /TM
    echo [DirectX]
    echo param=/silent
    echo direct_download_url=https://download.microsoft.com/download/8/4/A/84A35BF1-DAFE-4AE8-82AF-AD2AE20B6B14/directx_Jun2010_redist.exe
    echo [Format Factory]
    echo param=/VERYSILENT /I /EN
    echo [FurMark]
    echo param=/SILENT /SUPPRESSMSGBOXES /NORESTART /SP-
    echo param-quiet=/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-
    echo [GOM Player]
    echo param=/S
    echo crack_dst=%%ProgramFiles%%\GRETECH\GOMPlayerPlus
    echo [Google Chrome]
    echo param=/passive /norestart
    echo param_quiet=/quiet /norestart
    echo direct_download_url_32=https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise.msi
    echo direct_download_url_64=https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise64.msi
    echo [Internet Download Manager Silent]
    echo param=/S /EN
    echo [Java]
    echo ; https://www.oracle.com/technetwork/java/javase/silent-136552.html
    echo ; https://docs.oracle.com/javase/8/docs/technotes/guides/install/config.html#installing_with_config_file
    echo param=/s REBOOT=0 AUTO_UPDATE=0
    echo direct_download_url_32=https://javadl.oracle.com/webapps/download/AutoDL?BundleId=239856_230deb18db3e4014bb8e3e8324f81b43
    echo direct_download_url_64=https://javadl.oracle.com/webapps/download/AutoDL?BundleId=239858_230deb18db3e4014bb8e3e8324f81b43
    echo [K-Lite Codec Pack]
    echo param=/SILENT /SUPPRESSMSGBOXES /NORESTART /SP-
    echo param_quiet=/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-
    echo direct_download_url=https://files3.codecguide.com/K-Lite_Codec_Pack_1520_Mega.exe
    echo [Kodi]
    echo param=/S
    echo [Microsoft .NET Framework]
    echo param=/passive /norestart
    echo param_quiet=/quiet /norestart
    echo [Microsoft .NET Framework 4.8]
    echo param=/passive /norestart
    echo param_quiet=/quiet /norestart
    echo [Microsoft Office 2007 SP3]
    echo param=/adminfile basic.MSP
    echo wait=false
    echo [Microsoft Office 2016]
    echo ; .MSP files must be created first
    echo ; SEE https://www.google.com/search?q=microsoft%20office%202016%20silent%20install
    echo param=/adminfile basic_all.MSP
    echo wait=false
    echo [Microsoft Office Proofing Tools 2013]
    echo param=/passive /norestart
    echo param_quiet=/quiet /norestart
    echo [Microsoft Office Proofing Tools 2016]
    echo param=/passive /norestart
    echo param_quiet=/quiet /norestart
    echo [Microsoft Visual C++ Redistributable]
    echo param=/passive /norestart
    echo param_quiet=/quiet /norestart
    echo [Microsoft Visual C++ Redistributable All]
    echo param=/S
    echo [Mozilla Firefox]
    echo param=-ms
    echo direct_download_url_32=https://download.mozilla.org/?product=firefox-latest^&os=win^&lang=en-US
    echo direct_download_url_64=https://download.mozilla.org/?product=firefox-latest^&os=win64^&lang=en-US
    echo [MSI Afterburner]
    echo param=/S
    echo direct_download_url=http://download.msi.com/uti_exe/vga/MSIAfterburnerSetup.zip
    echo [Notepad++]
    echo param=/S
    echo [PowerShell Core]
    echo param=/passive /norestart ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1
    echo param_quiet=/quiet /norestart ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1
    echo [Rainmeter]
    echo param=/S
    echo [Recuva]
    echo param=/S
    echo [Snappy Driver Installer]
    echo ; installer_file=SDI_auto.bat
    echo param=-autoinstall
    echo wait=false
    echo [VLC Media Player]
    echo direct_download_url_32=http://download.videolan.org/pub/videolan/vlc/3.0.8/win32/vlc-3.0.8-win32.exe
    echo direct_download_url_32_msi=http://download.videolan.org/pub/videolan/vlc/3.0.8/win32/vlc-3.0.8-win32.msi
    echo direct_download_url_64=http://download.videolan.org/pub/videolan/vlc/3.0.8/win64/vlc-3.0.8-win64.exe
    echo direct_download_url_64_msi=http://download.videolan.org/pub/videolan/vlc/3.0.8/win64/vlc-3.0.8-win64.msi
    echo param=/S
    echo [WinRAR]
    echo param=/S /IEN
) >> "%filename%"

IF NOT EXIST "%filename%" (
    SET /A "exit_code=1"
    >&2 echo Can't create default INI file
)

:create_default_ini_file__end
(ENDLOCAL & REM -- RETURN VALUES
    REM IF "%retval%" NEQ "" SET "%retval%=%result%"
    EXIT /B %exit_code%
)
