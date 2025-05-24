package services

import (
	"github.com/Adam-Warlock09/SplitEase/backend/internal/models"
	"github.com/Adam-Warlock09/SplitEase/backend/internal/storage"
	"go.mongodb.org/mongo-driver/v2/bson"
)

func GetGroupWithNames(groupID bson.ObjectID) (*models.GroupDetailed, error) {

	group, err := storage.GetGroupByID(groupID)
	if err != nil {
		return nil, err
	}

	creator, err := storage.GetUserByID(group.CreatedBy)
	if err != nil {
		return nil, err
	}

	var members []models.UserRef
	for _, memberID := range group.Members {
		user, err := storage.GetUserByID(memberID)
		if err != nil {
			return nil, err
		}

		members = append(members, models.UserRef{
			ID: user.ID,
			Name: user.Name,
			Email: user.Email,
		})
	}

	return &models.GroupDetailed{
		ID: group.ID,
		Name: group.Name,
		Description: group.Description,
		CreatedAt: group.CreatedAt,
		UpdatedAt: group.UpdatedAt,
		CreatedBy: models.UserRef{
			ID: group.CreatedBy,
			Name: creator.Name,
			Email: creator.Email,
		},
		Members: members,
	}, nil

}