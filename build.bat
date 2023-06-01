IF NOT EXIST ".\src\bin" MKDIR ".\src\bin"
xcopy ".\src\nes.cfg" "C:\cc65_customize\cfg\nes.cfg" /Y
"C:\cc65_customize\bin\cl65" -t nes -l .\src\bin\hello_world_nrom_383.list .\src\hello.asm -o .\src\bin\hello_world_nrom_383.nes
IF "%ERRORLEVEL%" == "0" GOTO next_thing_to_do

goto end_of_batch_file


:next_thing_to_do


dir ".\src\bin\*.*" /s

IF NOT EXIST ".\builds" MKDIR ".\builds"

echo %DATE%
echo %TIME%
set datetimef=%date:yyyy%_%date:mm%_%date:dd%__%time:hh%_%time:mm%_%time:ss%
echo %datetimef%


:end_of_batch_file
pause
