@echo off
setLocal enableDelayedExpansion

set "command="
set "sq='"
set "dq=""

for %%i in (%*) do (
    set "param=%%i"
    if "!param:~0,1!" == "!sq!" if "!param:~-1!" == "!sq!" (
        set "param=!param:~1, -1!"
    )
    if "!param:~0,1!" == "!dq!" if "!param:~-1!" == "!dq!" (
        set "param=!param:~1, -1!"
    )
    if "!command!" == "" (
        set "command=!param:\=/!"
    ) else (
        set "command=!command! !param:\=/!"
    )
)

echo Command fixed, executing:
echo !command!
echo.

cmd /c !command!
exit /b 0
