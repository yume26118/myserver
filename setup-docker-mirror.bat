@echo off
echo Configuring Docker mirror...

echo.
echo Creating Docker daemon configuration file...

if not exist "%USERPROFILE%\.docker" mkdir "%USERPROFILE%\.docker"

echo {> "%USERPROFILE%\.docker\daemon.json"
echo   "registry-mirrors": [>> "%USERPROFILE%\.docker\daemon.json"
echo     "https://docker.mirrors.ustc.edu.cn",>> "%USERPROFILE%\.docker\daemon.json"
echo     "https://hub-mirror.c.163.com",>> "%USERPROFILE%\.docker\daemon.json"
echo     "https://mirror.baidubce.com">> "%USERPROFILE%\.docker\daemon.json"
echo   ],>> "%USERPROFILE%\.docker\daemon.json"
echo   "insecure-registries": [],>> "%USERPROFILE%\.docker\daemon.json"
echo   "debug": false,>> "%USERPROFILE%\.docker\daemon.json"
echo   "experimental": false>> "%USERPROFILE%\.docker\daemon.json"
echo }>> "%USERPROFILE%\.docker\daemon.json"

echo.
echo Docker mirror configuration completed!
echo Configuration file location: %USERPROFILE%\.docker\daemon.json
echo.
echo Please restart Docker Desktop to apply the configuration.
echo.
echo Configuration content:
type "%USERPROFILE%\.docker\daemon.json"
echo.
pause