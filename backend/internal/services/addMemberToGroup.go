package services

import (
	"errors"

	"github.com/Adam-Warlock09/SplitEase/backend/internal/models"
	"github.com/Adam-Warlock09/SplitEase/backend/internal/storage"
	"go.mongodb.org/mongo-driver/v2/bson"
)

func AddMemberToGroup(groupID bson.ObjectID, memberID bson.ObjectID) (*models.UserRef, error) {

	group, err := storage.GetGroupByID(groupID)
	if err != nil {
		return nil, err
	}

	for _, member := range group.Members {
		if member == memberID {
			return nil, errors.New("user is already a member")
		}
	}

	memberAdded, err := storage.AddMemberToGroup(groupID, memberID)
	if err != nil {
		return nil, err
	}

	return memberAdded, nil

}