package services

import (
	"github.com/Adam-Warlock09/SplitEase/backend/internal/models"
	"github.com/Adam-Warlock09/SplitEase/backend/internal/storage"
	"go.mongodb.org/mongo-driver/v2/bson"
)

func GetGroupTransactions(groupID bson.ObjectID) ([]models.Transaction, error) {

	return storage.GetTransactionsByGroupID(groupID);

}