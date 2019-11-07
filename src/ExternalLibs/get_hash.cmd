:get_hash file algorithm outVar
SET "%~3="
FOR /F "delims=" %%G in ('certutil -hashfile "%~1" %~2 ^| findstr /LV "hash CertUtil"') DO (
    SET "%~3=%%G"
)
EXIT /B