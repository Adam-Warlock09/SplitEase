package services

import (
	"errors"

	"github.com/Adam-Warlock09/SplitEase/backend/internal/storage"
	"go.mongodb.org/mongo-driver/v2/bson"
)

func RemoveMemberFromGroup(groupID bson.ObjectID, memberID bson.ObjectID) error {

	group, err := storage.GetGroupByID(groupID)
	if err != nil {
		return err
	}

	present := false
	for _, member := range group.Members {
		if member == memberID {
			present = true
			break
		}
	}

	if !present {
		return errors.New("user not present in group. Cant't remove")
	}

	err = storage.RemoveMemberFromGroup(groupID, memberID)
	if err != nil {
		return err
	}

	return nil

}