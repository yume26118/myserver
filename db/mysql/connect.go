package mysql

import (
	"fmt"
	"log"
	"myserver/config"
	"time"

	"gorm.io/driver/mysql"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

var DB *gorm.DB

// InitDB Initialize database connection
func InitDB(cfg *config.MySQLConfig) error {
	// Build DSN
	dsn := cfg.GetDSN()

	// Configure GORM
	gormConfig := &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
	}

	// Connect to database
	var err error
	DB, err = gorm.Open(mysql.Open(dsn), gormConfig)
	if err != nil {
		return fmt.Errorf("failed to connect to MySQL database: %v", err)
	}

	// Get underlying sql.DB object for connection pool configuration
	sqlDB, err := DB.DB()
	if err != nil {
		return fmt.Errorf("failed to get database instance: %v", err)
	}

	// Set connection pool parameters
	sqlDB.SetMaxIdleConns(cfg.MaxIdleConns)                                    // Set maximum number of idle connections in the pool
	sqlDB.SetMaxOpenConns(cfg.MaxOpenConns)                                    // Set maximum number of open connections to the database
	sqlDB.SetConnMaxLifetime(time.Duration(cfg.ConnMaxLifetime) * time.Second) // Set maximum amount of time a connection may be reused

	// Test connection
	if err := sqlDB.Ping(); err != nil {
		return fmt.Errorf("database connection test failed: %v", err)
	}

	log.Println("MySQL database connected successfully")
	return nil
}

// GetDB 获取数据库实例
func GetDB() *gorm.DB {
	return DB
}

// CloseDB 关闭数据库连接
func CloseDB() error {
	if DB != nil {
		sqlDB, err := DB.DB()
		if err != nil {
			return err
		}
		return sqlDB.Close()
	}
	return nil
}

// 示例模型结构体
type User struct {
	ID        uint      `gorm:"primaryKey" json:"id"`
	Username  string    `gorm:"uniqueIndex;size:50;not null" json:"username"`
	Email     string    `gorm:"uniqueIndex;size:100;not null" json:"email"`
	Password  string    `gorm:"size:255;not null" json:"-"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

// AutoMigrate Auto migrate database tables
func AutoMigrate() error {
	if DB == nil {
		return fmt.Errorf("database connection not initialized")
	}

	// Auto migrate mode
	err := DB.AutoMigrate(&User{})
	if err != nil {
		return fmt.Errorf("database migration failed: %v", err)
	}

	log.Println("Database table migration completed")
	return nil
}
