package services

import (
	"time"

	"github.com/Adam-Warlock09/SplitEase/backend/internal/models"
	"github.com/Adam-Warlock09/SplitEase/backend/internal/storage"
	"github.com/Adam-Warlock09/SplitEase/backend/internal/config"
)

func AddUser(name string, email string, password string) (*models.User, error) {

	HashedPassword, err := config.HashPassword(password)
	if err != nil {
		return nil, err
	}

	newUser := models.User{
		Name: name,
		Email: email,
		HashedPassword: HashedPassword,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}

	user, err := storage.AddUser(&newUser)

	if err != nil {
		return nil, err
	}

	return user, nil

}