package services

import (

	"github.com/Adam-Warlock09/SplitEase/backend/internal/models"
	"github.com/Adam-Warlock09/SplitEase/backend/internal/storage"
	
)

func AddUser(name string, email string, password string) (*models.User, error) {

	newUser := models.User{
		Name: name,
		Email: email,
		Password: password,
	}

	user, err := storage.AddUser(&newUser)

	if err != nil {
		return nil, err
	}

	return user, nil

}