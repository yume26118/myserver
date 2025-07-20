@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo 🚀 开始部署到GitHub Container Registry...
echo.

REM 检查Docker是否安装
docker --version >nul 2>&1
if errorlevel 1 (
    echo ❌ 错误: Docker未安装，请先安装Docker
    pause
    exit /b 1
)

REM 检查Docker是否运行
docker info >nul 2>&1
if errorlevel 1 (
    echo ❌ 错误: Docker未运行，请启动Docker
    pause
    exit /b 1
)

REM 获取Git用户名
for /f "tokens=*" %%i in ('git config user.name 2^>nul') do set GITHUB_USER=%%i
if "!GITHUB_USER!"=="" (
    echo ❌ 错误: Git用户名未配置
    echo 请运行: git config --global user.name "你的GitHub用户名"
    pause
    exit /b 1
)

echo 📋 当前配置:
echo    GitHub用户: !GITHUB_USER!
echo    项目名称: myserver
echo    镜像标签: latest
echo.

echo 🔑 请确保你已经准备好GitHub Personal Access Token
echo    Token需要包含 'write:packages' 权限
echo    如果还没有创建，请访问: https://github.com/settings/tokens
echo.

set /p CONTINUE="是否继续? (y/N): "
if /i not "!CONTINUE!"=="y" (
    echo ❌ 部署已取消
    pause
    exit /b 1
)

echo.
echo 🔐 登录GitHub Container Registry...
echo 请输入你的GitHub Personal Access Token:
set /p TOKEN=

if "!TOKEN!"=="" (
    echo ❌ 错误: Token不能为空
    pause
    exit /b 1
)

REM 登录GitHub Container Registry
echo !TOKEN! | docker login ghcr.io -u "!GITHUB_USER!" --password-stdin
if errorlevel 1 (
    echo ❌ 登录失败，请检查用户名和Token
    pause
    exit /b 1
)

echo ✅ 登录成功!
echo.

REM 构建镜像
echo 🔨 构建Docker镜像...
make build
if errorlevel 1 (
    echo ❌ 镜像构建失败
    pause
    exit /b 1
)

echo ✅ 镜像构建成功!
echo.

REM 标记镜像
echo 🏷️  标记镜像...
make tag
if errorlevel 1 (
    echo ❌ 镜像标记失败
    pause
    exit /b 1
)

echo ✅ 镜像标记成功!
echo.

REM 推送镜像
echo 📤 推送镜像到GitHub Registry...
make push
if errorlevel 1 (
    echo ❌ 镜像推送失败
    pause
    exit /b 1
)

echo.
echo 🎉 部署成功!
echo.
echo 📋 部署信息:
echo    镜像地址: ghcr.io/!GITHUB_USER!/myserver:latest
echo    拉取命令: docker pull ghcr.io/!GITHUB_USER!/myserver:latest
echo    运行命令: docker run -p 8080:8080 ghcr.io/!GITHUB_USER!/myserver:latest
echo.
echo 🔗 查看镜像: https://github.com/!GITHUB_USER!?tab=packages
echo.
echo 💡 提示: 你也可以使用 'make deploy' 命令在其他机器上部署这个镜像
echo.
pause