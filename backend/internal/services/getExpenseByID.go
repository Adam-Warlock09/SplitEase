package services

import (
	"github.com/Adam-Warlock09/SplitEase/backend/internal/models"
	"github.com/Adam-Warlock09/SplitEase/backend/internal/storage"
	"go.mongodb.org/mongo-driver/v2/bson"
)

func GetExpenseByID(expenseID bson.ObjectID) (*models.Expense, error) {

	expense, err := storage.GetExpenseByID(expenseID)
	if err != nil {
		return nil, err
	}

	return expense, nil

}