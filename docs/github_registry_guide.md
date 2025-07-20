# GitHub Container Registry 部署指南

本指南将帮助你将Docker镜像推送到GitHub Container Registry (ghcr.io)。

## 前置条件

1. **安装Docker**: 确保你的系统已安装Docker
2. **GitHub账户**: 需要有GitHub账户
3. **Personal Access Token**: 需要创建GitHub Personal Access Token

## 步骤1: 创建GitHub Personal Access Token

1. 登录GitHub，进入 Settings > Developer settings > Personal access tokens > Tokens (classic)
2. 点击 "Generate new token (classic)"
3. 设置Token名称，例如: "Docker Registry Access"
4. 选择权限，至少需要以下权限：
   - `write:packages` - 允许上传包到GitHub Packages
   - `read:packages` - 允许下载包
   - `delete:packages` - 允许删除包（可选）
5. 点击 "Generate token"
6. **重要**: 复制并保存生成的token，离开页面后将无法再次查看

## 步骤2: 检查配置

确保你的Git配置正确：
```bash
git config user.name
git config user.email
```

如果没有配置，请设置：
```bash
git config --global user.name "你的GitHub用户名"
git config --global user.email "你的邮箱"
```

## 步骤3: 构建和推送镜像

### 方法1: 使用完整发布流程（推荐）
```bash
make publish
```
这个命令会：
1. 提示你登录GitHub Container Registry
2. 构建Docker镜像
3. 标记镜像
4. 推送到GitHub Registry

### 方法2: 分步执行
```bash
# 1. 登录GitHub Container Registry
make login

# 2. 构建镜像
make build

# 3. 标记镜像
make tag

# 4. 推送镜像
make push
```

## 步骤4: 验证推送

1. 访问你的GitHub仓库
2. 点击右侧的 "Packages" 标签
3. 你应该能看到推送的Docker镜像

## 步骤5: 使用镜像

### 拉取镜像
```bash
make pull
```

### 部署镜像
```bash
make deploy
```

## 常用命令

```bash
# 查看所有可用命令
make help

# 本地开发
make dev

# 构建镜像
make build

# 运行容器
make run

# 停止容器
make stop

# 清理镜像和容器
make clean

# 查看容器日志
make logs

# 健康检查
make health
```

## 镜像地址格式

你的镜像将被推送到：
```
ghcr.io/[你的GitHub用户名]/myserver:latest
```

## 故障排除

### 1. 登录失败
- 确保Personal Access Token有正确的权限
- 检查用户名是否正确
- 确保token没有过期

### 2. 推送失败
- 确保已经登录到GitHub Container Registry
- 检查网络连接
- 确保仓库名称符合规范（小写字母、数字、连字符）

### 3. 权限问题
- 确保token有 `write:packages` 权限
- 如果是组织仓库，确保有相应的组织权限

### 4. 镜像大小问题
- 当前Dockerfile使用多阶段构建，已经优化了镜像大小
- 如果仍然太大，可以考虑使用更小的基础镜像

## 安全建议

1. **不要在代码中硬编码token**
2. **定期轮换Personal Access Token**
3. **只给token必要的最小权限**
4. **使用环境变量存储敏感信息**

## 自动化部署

你可以使用GitHub Actions来自动化构建和推送过程。项目中已包含 `.github/workflows/docker-publish.yml` 文件。

## 示例使用

```bash
# 完整发布流程
make publish

# 在另一台机器上部署
make deploy

# 查看运行状态
make health
```

## 注意事项

1. 首次推送可能需要较长时间，取决于网络速度
2. GitHub Container Registry是免费的，但有存储限制
3. 公共仓库的镜像是公开可访问的
4. 私有仓库的镜像需要认证才能访问