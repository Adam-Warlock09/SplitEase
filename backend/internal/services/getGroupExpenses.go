package services

import (
	"github.com/Adam-Warlock09/SplitEase/backend/internal/models"
	"github.com/Adam-Warlock09/SplitEase/backend/internal/storage"
	"go.mongodb.org/mongo-driver/v2/bson"
)

func GetGroupExpenses(groupID bson.ObjectID) ([]models.Expense, error) {

	return storage.GetExpensesByGroupID(groupID);

}