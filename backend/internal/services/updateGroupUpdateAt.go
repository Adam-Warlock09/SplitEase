package services

import (
	"github.com/Adam-Warlock09/SplitEase/backend/internal/storage"
	"go.mongodb.org/mongo-driver/v2/bson"
)

func UpdateGroupUpdatedAt(groupID bson.ObjectID) (error) {

	return storage.UpdateGroupUpdatedAt(groupID)

}