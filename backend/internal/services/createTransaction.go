package services

import (
	"time"

	"github.com/Adam-Warlock09/SplitEase/backend/internal/models"
	"github.com/Adam-Warlock09/SplitEase/backend/internal/storage"
	"go.mongodb.org/mongo-driver/v2/bson"
)

type CreateTransactionRequest struct {
	GroupID  string  `json:"groupId"`
	Amount   float64 `json:"amount"`
	Notes    string  `json:"notes,omitempty"`
	FromUser string  `json:"fromUser"`
	ToUser   string  `json:"toUser"`
}

func CreateTransaction(transaction *CreateTransactionRequest, groupID bson.ObjectID) (*models.Transaction, error) {

	now := time.Now()

	fromUserID, err := bson.ObjectIDFromHex(transaction.FromUser)
	if err != nil {
		return nil, err
	}
	
	toUserID, err := bson.ObjectIDFromHex(transaction.ToUser)
	if err != nil {
		return nil, err
	}

	newTransaction := &models.Transaction{
		GroupID: groupID,
		FromUser: fromUserID,
		ToUser: toUserID,
		Amount: transaction.Amount,
		CreatedAt: now,
		Notes: transaction.Notes,
	}

	id, err := storage.CreateTransaction(newTransaction)
	if err != nil {
		return nil, err
	}

	newTransaction.ID = id

	return newTransaction, nil

}