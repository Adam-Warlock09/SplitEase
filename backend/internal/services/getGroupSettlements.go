package services

import (
	"math"
	"sort"

	"github.com/Adam-Warlock09/SplitEase/backend/internal/models"
	"go.mongodb.org/mongo-driver/v2/bson"
)

type UserBalance struct {
	UserID bson.ObjectID
	Amount float64
}

func GetGroupSettlements(expenses []models.Expense, transactions []models.Transaction, members []models.UserRef) ([]models.Settlement, error) {

	balances := map[bson.ObjectID]float64{}

	for _, expense := range expenses {
		payer := expense.PaidBy
		balances[payer] += expense.Amount

		for userIDHex, owed := range expense.Splits {
			userID, err := bson.ObjectIDFromHex(userIDHex)
			if err != nil {
				return nil, err
			}

			balances[userID] -= owed
		}

	}

	for _, transaction := range transactions {
		balances[transaction.FromUser] += transaction.Amount
		balances[transaction.ToUser] -= transaction.Amount
	}

	creditors := []UserBalance{}
	debtors := []UserBalance{}

	for userID, balance := range balances {

		if math.Abs(balance) < 0.01 {
			continue
		}

		if balance > 0 {
			creditors = append(creditors, UserBalance{
				UserID: userID,
				Amount: balance,
			})
		} else {
			debtors = append(debtors, UserBalance{
				UserID: userID,
				Amount: balance,
			})
		}
		
	}

	sort.Slice(creditors, func(i, j int) bool {
		return creditors[i].Amount > creditors[j].Amount
	})
	sort.Slice(debtors, func(i, j int) bool {
		return debtors[i].Amount < debtors[j].Amount
	})

	settlements := []models.Settlement{}
	i, j := 0, 0

	for i < len(debtors) && j < len(creditors) {

		d := &debtors[i]
		c := &creditors[j]

		amount := math.Min(-d.Amount, c.Amount)

		settlements = append(settlements, models.Settlement{
			FromUser: d.UserID,
			ToUser:   c.UserID,
			Amount:   math.Round(amount*100) / 100,
		})

		d.Amount += amount
		c.Amount -= amount

		if math.Abs(d.Amount) < 0.01 {
			i++
		}
		if math.Abs(c.Amount) < 0.01 {
			j++
		}

	}

	return settlements, nil

}