package services

import (
	"time"

	"github.com/Adam-Warlock09/SplitEase/backend/internal/models"
	"github.com/Adam-Warlock09/SplitEase/backend/internal/storage"
	"go.mongodb.org/mongo-driver/v2/bson"
)

func CreateGroup(name string, description string, createdBy bson.ObjectID) (*models.Group, error) {

	now := time.Now()

	group := &models.Group{
		Name: name,
		Description: description,
		CreatedAt: now,
		UpdatedAt: now,
		Members: []bson.ObjectID{createdBy},
		CreatedBy: createdBy,
	}

	id, err := storage.CreateGroup(group)
	if err != nil {
		return nil, err
	}

	group.ID = id

	return group, nil

}