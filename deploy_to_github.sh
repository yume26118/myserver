#!/bin/bash

# GitHub Container Registry 快速部署脚本
# 使用方法: ./deploy_to_github.sh

set -e

echo "🚀 开始部署到GitHub Container Registry..."

# 检查Docker是否安装
if ! command -v docker &> /dev/null; then
    echo "❌ 错误: Docker未安装，请先安装Docker"
    exit 1
fi

# 检查Docker是否运行
if ! docker info &> /dev/null; then
    echo "❌ 错误: Docker未运行，请启动Docker"
    exit 1
fi

# 检查Git配置
GITHUB_USER=$(git config user.name)
if [ -z "$GITHUB_USER" ]; then
    echo "❌ 错误: Git用户名未配置"
    echo "请运行: git config --global user.name '你的GitHub用户名'"
    exit 1
fi

echo "📋 当前配置:"
echo "   GitHub用户: $GITHUB_USER"
echo "   项目名称: myserver"
echo "   镜像标签: latest"
echo ""

# 提示用户准备Personal Access Token
echo "🔑 请确保你已经准备好GitHub Personal Access Token"
echo "   Token需要包含 'write:packages' 权限"
echo "   如果还没有创建，请访问: https://github.com/settings/tokens"
echo ""

read -p "是否继续? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ 部署已取消"
    exit 1
fi

echo ""
echo "🔐 登录GitHub Container Registry..."
echo "请输入你的GitHub Personal Access Token:"
read -s TOKEN

if [ -z "$TOKEN" ]; then
    echo "❌ 错误: Token不能为空"
    exit 1
fi

# 登录GitHub Container Registry
echo "$TOKEN" | docker login ghcr.io -u "$GITHUB_USER" --password-stdin

if [ $? -ne 0 ]; then
    echo "❌ 登录失败，请检查用户名和Token"
    exit 1
fi

echo "✅ 登录成功!"
echo ""

# 构建镜像
echo "🔨 构建Docker镜像..."
make build

if [ $? -ne 0 ]; then
    echo "❌ 镜像构建失败"
    exit 1
fi

echo "✅ 镜像构建成功!"
echo ""

# 标记镜像
echo "🏷️  标记镜像..."
make tag

if [ $? -ne 0 ]; then
    echo "❌ 镜像标记失败"
    exit 1
fi

echo "✅ 镜像标记成功!"
echo ""

# 推送镜像
echo "📤 推送镜像到GitHub Registry..."
make push

if [ $? -ne 0 ]; then
    echo "❌ 镜像推送失败"
    exit 1
fi

echo ""
echo "🎉 部署成功!"
echo ""
echo "📋 部署信息:"
echo "   镜像地址: ghcr.io/$GITHUB_USER/myserver:latest"
echo "   拉取命令: docker pull ghcr.io/$GITHUB_USER/myserver:latest"
echo "   运行命令: docker run -p 8080:8080 ghcr.io/$GITHUB_USER/myserver:latest"
echo ""
echo "🔗 查看镜像: https://github.com/$GITHUB_USER?tab=packages"
echo ""
echo "💡 提示: 你也可以使用 'make deploy' 命令在其他机器上部署这个镜像"