package services

import (
	"github.com/Adam-Warlock09/SplitEase/backend/internal/models"
	"github.com/Adam-Warlock09/SplitEase/backend/internal/storage"
	"go.mongodb.org/mongo-driver/v2/bson"
)

func GetTransactionByID(transactionID bson.ObjectID) (*models.Transaction, error) {

	transaction, err := storage.GetTransactionByID(transactionID)
	if err != nil {
		return nil, err
	}

	return transaction, nil

}