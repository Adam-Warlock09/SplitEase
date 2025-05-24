package services

import (
	"github.com/Adam-Warlock09/SplitEase/backend/internal/storage"
	"go.mongodb.org/mongo-driver/v2/bson"
)

func GetGroupCreator(groupID bson.ObjectID) (bson.ObjectID, error) {

	group, err := storage.GetGroupByID(groupID)
	if err != nil {
		return bson.NilObjectID, err
	}

	return group.CreatedBy, nil

}