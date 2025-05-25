package services

import (
	"time"

	"github.com/Adam-Warlock09/SplitEase/backend/internal/models"
	"github.com/Adam-Warlock09/SplitEase/backend/internal/storage"
	"go.mongodb.org/mongo-driver/v2/bson"
)

type ExpenseRequest struct {
	GroupID   string             `json:"groupId"`
	Title     string             `json:"title"`
	Amount    float64            `json:"amount"`
	PaidBy    string             `json:"paidBy"`
	SplitType string             `json:"splitType"`
	Splits    map[string]float64 `json:"splits"`
	Notes     string             `json:"notes,omitempty"`
}

func CreateExpense(expense *ExpenseRequest, groupID bson.ObjectID) (*models.Expense, error) {

	now := time.Now()

	userID, err := bson.ObjectIDFromHex(expense.PaidBy)
	if err != nil {
		return nil, err
	}

	newExpense := &models.Expense{
		GroupID: groupID,
		Title: expense.Title,
		Amount: expense.Amount,
		PaidBy: userID,
		SplitType: expense.SplitType,
		Splits: expense.Splits,
		CreatedAt: now,
		Notes: expense.Notes,
	}

	id, err := storage.CreateExpense(newExpense)
	if err != nil {
		return nil, err
	}

	newExpense.ID = id

	return newExpense, nil

}