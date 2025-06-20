package services

import (
	"errors"

	"github.com/Adam-Warlock09/SplitEase/backend/internal/config"
	"github.com/Adam-Warlock09/SplitEase/backend/internal/models"
	"github.com/Adam-Warlock09/SplitEase/backend/internal/storage"

)

func AuthenticateUser(email string, password string) (*models.User, error) {

	user, err := storage.FindUserByEmail(email)

	if err != nil {
		return nil, errors.New("invalid email or password")
	}

	if !config.CheckPasswordHash(password, user.HashedPassword) {
		return nil, errors.New("invalid email or password")
	}

	return user, nil

}