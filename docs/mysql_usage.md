# MySQL 数据库使用指南

本文档展示如何使用项目中的 MySQL 数据库功能。

## 数据库连接

数据库连接在 `db/mysql/connect.go` 中的 `InitDB` 函数实现：

```go
func InitDB(cfg *config.MySQLConfig) error {
    // 构建DSN
    dsn := cfg.GetDSN()
    
    // 配置GORM
    gormConfig := &gorm.Config{
        Logger: logger.Default.LogMode(logger.Info),
    }
    
    // 连接数据库
    DB, err = gorm.Open(mysql.Open(dsn), gormConfig)
    // ... 其他配置
}
```

## API 使用示例

### 1. 创建用户

**请求:**
```bash
curl -X POST http://localhost:8080/api/v1/users \
  -H "Content-Type: application/json" \
  -d '{
    "username": "john_doe",
    "email": "john@example.com",
    "password": "password123"
  }'
```

**响应:**
```json
{
  "message": "用户创建成功",
  "data": {
    "id": 1,
    "username": "john_doe",
    "email": "john@example.com",
    "created_at": "2024-01-01T10:00:00Z",
    "updated_at": "2024-01-01T10:00:00Z"
  }
}
```

### 2. 获取用户列表（分页）

**请求:**
```bash
curl "http://localhost:8080/api/v1/users?page=1&page_size=10"
```

**响应:**
```json
{
  "data": {
    "users": [
      {
        "id": 1,
        "username": "john_doe",
        "email": "john@example.com",
        "created_at": "2024-01-01T10:00:00Z",
        "updated_at": "2024-01-01T10:00:00Z"
      }
    ],
    "total": 1,
    "page": 1,
    "page_size": 10
  }
}
```

### 3. 根据ID获取用户

**请求:**
```bash
curl http://localhost:8080/api/v1/users/1
```

**响应:**
```json
{
  "data": {
    "id": 1,
    "username": "john_doe",
    "email": "john@example.com",
    "created_at": "2024-01-01T10:00:00Z",
    "updated_at": "2024-01-01T10:00:00Z"
  }
}
```

### 4. 更新用户信息

**请求:**
```bash
curl -X PUT http://localhost:8080/api/v1/users/1 \
  -H "Content-Type: application/json" \
  -d '{
    "username": "john_updated",
    "email": "john_new@example.com"
  }'
```

**响应:**
```json
{
  "message": "用户更新成功",
  "data": {
    "id": 1,
    "username": "john_updated",
    "email": "john_new@example.com",
    "created_at": "2024-01-01T10:00:00Z",
    "updated_at": "2024-01-01T10:05:00Z"
  }
}
```

### 5. 搜索用户

**请求:**
```bash
curl "http://localhost:8080/api/v1/users/search?keyword=john&page=1&page_size=10"
```

**响应:**
```json
{
  "data": {
    "users": [
      {
        "id": 1,
        "username": "john_updated",
        "email": "john_new@example.com",
        "created_at": "2024-01-01T10:00:00Z",
        "updated_at": "2024-01-01T10:05:00Z"
      }
    ],
    "total": 1,
    "page": 1,
    "page_size": 10,
    "keyword": "john"
  }
}
```

### 6. 获取用户统计信息

**请求:**
```bash
curl http://localhost:8080/api/v1/users/stats
```

**响应:**
```json
{
  "data": {
    "total_users": 5,
    "today_users": 2
  }
}
```

### 7. 根据用户名获取用户

**请求:**
```bash
curl http://localhost:8080/api/v1/users/username/john_updated
```

**响应:**
```json
{
  "data": {
    "id": 1,
    "username": "john_updated",
    "email": "john_new@example.com",
    "created_at": "2024-01-01T10:00:00Z",
    "updated_at": "2024-01-01T10:05:00Z"
  }
}
```

### 8. 删除用户

**请求:**
```bash
curl -X DELETE http://localhost:8080/api/v1/users/1
```

**响应:**
```json
{
  "message": "用户删除成功"
}
```

## 数据库服务层使用

在代码中直接使用服务层：

```go
package main

import (
    "myserver/service"
    "log"
)

func example() {
    // 创建用户服务实例
    userService := service.NewUserService()
    
    // 创建用户
    user, err := userService.CreateUser("alice", "alice@example.com", "password123")
    if err != nil {
        log.Printf("创建用户失败: %v", err)
        return
    }
    log.Printf("创建用户成功: %+v", user)
    
    // 获取用户
    foundUser, err := userService.GetUserByID(user.ID)
    if err != nil {
        log.Printf("获取用户失败: %v", err)
        return
    }
    log.Printf("获取用户成功: %+v", foundUser)
    
    // 更新用户
    updates := map[string]interface{}{
        "username": "alice_updated",
    }
    updatedUser, err := userService.UpdateUser(user.ID, updates)
    if err != nil {
        log.Printf("更新用户失败: %v", err)
        return
    }
    log.Printf("更新用户成功: %+v", updatedUser)
    
    // 获取用户列表
    users, total, err := userService.GetAllUsers(1, 10)
    if err != nil {
        log.Printf("获取用户列表失败: %v", err)
        return
    }
    log.Printf("获取用户列表成功: 总数=%d, 用户=%+v", total, users)
}
```

## 直接使用GORM

如果需要更复杂的查询，可以直接使用GORM：

```go
package main

import (
    "myserver/db/mysql"
    "log"
)

func advancedQuery() {
    // 获取数据库实例
    db := mysql.GetDB()
    
    // 复杂查询示例
    var users []mysql.User
    
    // 条件查询
    err := db.Where("created_at > ?", "2024-01-01").
        Order("created_at desc").
        Limit(10).
        Find(&users).Error
    
    if err != nil {
        log.Printf("查询失败: %v", err)
        return
    }
    
    log.Printf("查询结果: %+v", users)
    
    // 聚合查询
    var count int64
    db.Model(&mysql.User{}).Where("created_at > ?", "2024-01-01").Count(&count)
    log.Printf("符合条件的用户数量: %d", count)
    
    // 原生SQL查询
    var result []map[string]interface{}
    db.Raw("SELECT username, COUNT(*) as count FROM users GROUP BY username").Scan(&result)
    log.Printf("用户名统计: %+v", result)
}
```

## 健康检查

检查数据库连接状态：

**请求:**
```bash
curl http://localhost:8080/health
```

**响应:**
```json
{
  "status": "healthy",
  "database": "connected"
}
```

## 启动服务器

使用以下命令启动服务器：

```bash
# 使用 make 命令
make dev

# 或直接使用 go run
go run main.go
```

服务器将在配置文件中指定的端口启动（默认8080）。