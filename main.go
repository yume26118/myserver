package main

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

func main() {
	// 创建gin路由器
	r := gin.Default()

	// 定义路由
	r.GET("/", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message": "Hello, Gin!",
			"status":  "success",
		})
	})

	// 添加一个健康检查端点
	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status": "healthy",
		})
	})

	// 添加一个带参数的路由
	r.GET("/user/:name", func(c *gin.Context) {
		name := c.Param("name")
		c.JSON(http.StatusOK, gin.H{
			"message": "Hello, " + name + "!",
			"user":    name,
		})
	})

	// 启动服务器在8080端口
	r.Run(":8080")
}
