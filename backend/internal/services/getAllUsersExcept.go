package services

import (
	"errors"

	"github.com/Adam-Warlock09/SplitEase/backend/internal/models"
	"github.com/Adam-Warlock09/SplitEase/backend/internal/storage"
	"go.mongodb.org/mongo-driver/v2/bson"
)

func notContainsObjectID(slice []bson.ObjectID, id bson.ObjectID) bool {
	for _, item := range slice {
		if item == id {
			return false
		}
	}
	return true
}

func GetAllUsersExcept(groupID bson.ObjectID, userID bson.ObjectID) ([]models.UserRef, error) {

	group, err := storage.GetGroupByID(groupID)
	if err != nil {
		return nil, err
	}

	present := false
	for _, member := range group.Members {
		if member == userID {
			present = true
			break
		}
	}

	if !present {
		return nil, errors.New("user not in group. Unauthorized")
	}

	users, err := storage.GetAllUsers()
	if err != nil {
		return nil, err
	}

	var result []models.UserRef
	for _, user := range users {

		if notContainsObjectID(group.Members, user.ID) {

			result = append(result, models.UserRef{
				ID:    user.ID,
				Name:  user.Name,
				Email: user.Email,
			})
		}
	}

	return result, nil

}
