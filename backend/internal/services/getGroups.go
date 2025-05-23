package services

import (
	"github.com/Adam-Warlock09/SplitEase/backend/internal/models"
	"github.com/Adam-Warlock09/SplitEase/backend/internal/storage"
)

func GetGroups(userID string) ([]models.Group, error) {

	return storage.FindGroupsByMemberID(userID)

}