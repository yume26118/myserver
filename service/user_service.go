package service

import (
	"errors"
	"myserver/db/mysql"
	"time"

	"gorm.io/gorm"
)

// UserService 用户服务
type UserService struct {
	db *gorm.DB
}

// NewUserService 创建用户服务实例
func NewUserService() *UserService {
	return &UserService{
		db: mysql.GetDB(),
	}
}

// CreateUser 创建用户
func (s *UserService) CreateUser(username, email, password string) (*mysql.User, error) {
	user := &mysql.User{
		Username: username,
		Email:    email,
		Password: password,
	}

	// 检查用户名是否已存在
	var existingUser mysql.User
	if err := s.db.Where("username = ?", username).First(&existingUser).Error; err == nil {
		return nil, errors.New("用户名已存在")
	}

	// 检查邮箱是否已存在
	if err := s.db.Where("email = ?", email).First(&existingUser).Error; err == nil {
		return nil, errors.New("邮箱已存在")
	}

	// 创建用户
	if err := s.db.Create(user).Error; err != nil {
		return nil, err
	}

	return user, nil
}

// GetUserByID 根据ID获取用户
func (s *UserService) GetUserByID(id uint) (*mysql.User, error) {
	var user mysql.User
	if err := s.db.First(&user, id).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("用户不存在")
		}
		return nil, err
	}
	return &user, nil
}

// GetUserByUsername 根据用户名获取用户
func (s *UserService) GetUserByUsername(username string) (*mysql.User, error) {
	var user mysql.User
	if err := s.db.Where("username = ?", username).First(&user).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("用户不存在")
		}
		return nil, err
	}
	return &user, nil
}

// GetUserByEmail 根据邮箱获取用户
func (s *UserService) GetUserByEmail(email string) (*mysql.User, error) {
	var user mysql.User
	if err := s.db.Where("email = ?", email).First(&user).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("用户不存在")
		}
		return nil, err
	}
	return &user, nil
}

// GetAllUsers 获取所有用户（分页）
func (s *UserService) GetAllUsers(page, pageSize int) ([]mysql.User, int64, error) {
	var users []mysql.User
	var total int64

	// 计算总数
	if err := s.db.Model(&mysql.User{}).Count(&total).Error; err != nil {
		return nil, 0, err
	}

	// 分页查询
	offset := (page - 1) * pageSize
	if err := s.db.Offset(offset).Limit(pageSize).Find(&users).Error; err != nil {
		return nil, 0, err
	}

	return users, total, nil
}

// UpdateUser 更新用户信息
func (s *UserService) UpdateUser(id uint, updates map[string]interface{}) (*mysql.User, error) {
	var user mysql.User

	// 先查找用户
	if err := s.db.First(&user, id).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("用户不存在")
		}
		return nil, err
	}

	// 更新用户信息
	if err := s.db.Model(&user).Updates(updates).Error; err != nil {
		return nil, err
	}

	return &user, nil
}

// DeleteUser 删除用户
func (s *UserService) DeleteUser(id uint) error {
	result := s.db.Delete(&mysql.User{}, id)
	if result.Error != nil {
		return result.Error
	}

	if result.RowsAffected == 0 {
		return errors.New("用户不存在")
	}

	return nil
}

// SearchUsers 搜索用户
func (s *UserService) SearchUsers(keyword string, page, pageSize int) ([]mysql.User, int64, error) {
	var users []mysql.User
	var total int64

	query := s.db.Model(&mysql.User{}).Where("username LIKE ? OR email LIKE ?", "%"+keyword+"%", "%"+keyword+"%")

	// 计算总数
	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	// 分页查询
	offset := (page - 1) * pageSize
	if err := query.Offset(offset).Limit(pageSize).Find(&users).Error; err != nil {
		return nil, 0, err
	}

	return users, total, nil
}

// GetUserStats 获取用户统计信息
func (s *UserService) GetUserStats() (map[string]interface{}, error) {
	var totalUsers int64
	var todayUsers int64

	// 总用户数
	if err := s.db.Model(&mysql.User{}).Count(&totalUsers).Error; err != nil {
		return nil, err
	}

	// 今日注册用户数
	today := time.Now().Format("2006-01-02")
	if err := s.db.Model(&mysql.User{}).Where("DATE(created_at) = ?", today).Count(&todayUsers).Error; err != nil {
		return nil, err
	}

	stats := map[string]interface{}{
		"total_users": totalUsers,
		"today_users": todayUsers,
	}

	return stats, nil
}

// BatchCreateUsers 批量创建用户
func (s *UserService) BatchCreateUsers(users []mysql.User) error {
	// 使用事务批量插入
	return s.db.Transaction(func(tx *gorm.DB) error {
		for _, user := range users {
			if err := tx.Create(&user).Error; err != nil {
				return err
			}
		}
		return nil
	})
}

// UpdateUserPassword 更新用户密码
func (s *UserService) UpdateUserPassword(id uint, newPassword string) error {
	result := s.db.Model(&mysql.User{}).Where("id = ?", id).Update("password", newPassword)
	if result.Error != nil {
		return result.Error
	}

	if result.RowsAffected == 0 {
		return errors.New("用户不存在")
	}

	return nil
}
