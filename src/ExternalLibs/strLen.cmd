:strLen String retvar
Setlocal EnableDelayedExpansion
             REM -- String  The string to be measured, surround in quotes if it contains spaces.
             REM -- RtnVar  An optional variable to be used to return the string length.
REM %ECHO_VERBOSE% :strLen %*
rem use chace
IF "!strLen_chace[%~1]!" NEQ "" (
    set len=!strLen_chace[%~1]!
    REM %ECHO_VERBOSE% Using chace !strLen_chace[%~1]!
    goto:strLen__end
)

Set "s=#%~1"
Set "len=0"
For %%N in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (
  if "!s:~%%N,1!" neq "" (
    set /a "len+=%%N"
    set "s=!s:~%%N!"
  )
)
:strLen__end
Endlocal&if "%~2" neq "" (
    set "%~2=%len%"
    set "strLen_chace[%~1]=%len%"
    ) else echo %len%
Exit /b
