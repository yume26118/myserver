# MyServer - Gin Web Server

一个使用Gin框架构建的简单Web服务器，支持MySQL数据库和完整的用户管理功能。

## 功能特性

- RESTful API端点
- MySQL数据库集成
- 用户CRUD操作
- 健康检查
- Docker容器化支持
- GitHub Actions自动构建
- GitHub Container Registry部署

## 快速开始

### 本地开发

```bash
# 安装依赖
go mod tidy

# 启动开发服务器
make dev

# 或者直接运行
go run main.go
```

### Docker部署

```bash
# 构建镜像
make build

# 运行容器
make run

# 查看日志
make logs

# 停止容器
make stop
```

### 部署到GitHub Container Registry

#### 方法1: 使用自动化脚本（推荐）

**Windows用户:**
```bash
deploy_to_github.bat
```

**Linux/Mac用户:**
```bash
chmod +x deploy_to_github.sh
./deploy_to_github.sh
```

#### 方法2: 使用Makefile命令

```bash
# 完整发布流程
make publish

# 或者分步执行
make login    # 登录GitHub Container Registry
make build    # 构建镜像
make tag      # 标记镜像
make push     # 推送镜像
```

## API端点

### 基础端点
- `GET /` - 欢迎页面
- `GET /health` - 健康检查

### 用户管理API
- `POST /api/v1/users` - 创建用户
- `GET /api/v1/users` - 获取所有用户
- `GET /api/v1/users/:id` - 获取指定用户
- `PUT /api/v1/users/:id` - 更新用户
- `DELETE /api/v1/users/:id` - 删除用户
- `GET /api/v1/users/search` - 搜索用户
- `GET /api/v1/users/stats` - 用户统计
- `GET /api/v1/users/username/:username` - 按用户名获取用户

## 配置

项目使用YAML配置文件 `config.yaml`：

```yaml
database:
  host: localhost
  port: 3306
  username: root
  password: "your_password"
  dbname: myserver
  charset: utf8mb4
  max_idle_conns: 10
  max_open_conns: 100
  conn_max_lifetime: 3600

server:
  port: 8080
  mode: debug
```

## 数据库

项目使用MySQL数据库，支持自动迁移。确保MySQL服务正在运行并且配置正确。

详细的数据库使用说明请参考: [MySQL使用指南](docs/mysql_usage.md)

## 部署指南

详细的GitHub Container Registry部署指南请参考: [GitHub Registry部署指南](docs/github_registry_guide.md)

## 可用命令

```bash
make help          # 查看所有可用命令
make dev           # 开发模式运行
make build         # 构建Docker镜像
make run           # 运行Docker容器
make stop          # 停止Docker容器
make logs          # 查看容器日志
make clean         # 清理镜像和容器
make health        # 健康检查
make login         # 登录GitHub Container Registry
make tag           # 标记镜像
make push          # 推送镜像到GitHub Registry
make pull          # 从GitHub Registry拉取镜像
make deploy        # 部署镜像
make publish       # 完整发布流程
```

## 开发

### 项目结构

```
myserver/
├── main.go                 # 主程序入口
├── config.yaml            # 配置文件
├── Dockerfile             # Docker构建文件
├── Makefile              # 构建和部署命令
├── config/               # 配置管理
├── db/mysql/            # 数据库连接
├── models/              # 数据模型
├── service/             # 业务逻辑层
├── controller/          # 控制器层
├── docs/               # 文档
└── deploy_to_github.*  # 部署脚本
```

### 测试

```bash
# 运行所有测试
go test ./...

# 运行特定包的测试
go test ./config
go test ./db/mysql
```

## 许可证

MIT License