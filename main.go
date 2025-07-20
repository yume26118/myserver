package main

import (
	"fmt"
	"log"
	"myserver/config"
	"myserver/controller"
	"myserver/db/mysql"
	"net/http"

	"github.com/gin-gonic/gin"
)

func main() {
	// Load configuration file
	cfg, err := config.LoadConfig("config.yaml")
	if err != nil {
		log.Fatalf("Failed to load config file: %v", err)
	}

	// Initialize database connection
	err = mysql.InitDB(&cfg.Database.MySQL)
	if err != nil {
		log.Fatalf("Failed to initialize database: %v", err)
	}
	defer mysql.CloseDB()

	// Auto migrate database tables
	err = mysql.AutoMigrate()
	if err != nil {
		log.Fatalf("Failed to migrate database: %v", err)
	}

	// Set Gin mode
	gin.SetMode(cfg.Server.Mode)

	// Create gin router
	r := gin.Default()

	// Create user controller instance
	userController := controller.NewUserController()

	// Basic routes
	r.GET("/", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message": "Hello, Gin with MySQL!",
			"status":  "success",
			"version": "1.0.0",
		})
	})

	// Health check endpoint
	r.GET("/health", func(c *gin.Context) {
		// Check database connection
		db := mysql.GetDB()
		sqlDB, err := db.DB()
		if err != nil || sqlDB.Ping() != nil {
			c.JSON(http.StatusServiceUnavailable, gin.H{
				"status":   "unhealthy",
				"database": "disconnected",
			})
			return
		}

		c.JSON(http.StatusOK, gin.H{
			"status":   "healthy",
			"database": "connected",
		})
	})

	// API version grouping
	v1 := r.Group("/api/v1")
	{
		// User related routes
		users := v1.Group("/users")
		{
			users.POST("", userController.CreateUser)                          // Create user
			users.GET("", userController.GetAllUsers)                          // Get all users (paginated)
			users.GET("/search", userController.SearchUsers)                   // Search users
			users.GET("/stats", userController.GetUserStats)                   // Get user statistics
			users.GET("/:id", userController.GetUser)                          // Get user by ID
			users.PUT("/:id", userController.UpdateUser)                       // Update user info
			users.DELETE("/:id", userController.DeleteUser)                    // Delete user
			users.GET("/username/:username", userController.GetUserByUsername) // Get user by username
		}
	}

	// Start server
	serverAddr := fmt.Sprintf(":%d", cfg.Server.Port)
	log.Printf("Server starting on port %d", cfg.Server.Port)
	log.Printf("API documentation: http://localhost:%d/api/v1/users", cfg.Server.Port)
	r.Run(serverAddr)
}
