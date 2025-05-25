package storage

import (
	"context"
	"time"

	"github.com/Adam-Warlock09/SplitEase/backend/internal/config"
	"github.com/Adam-Warlock09/SplitEase/backend/internal/models"
	"go.mongodb.org/mongo-driver/v2/bson"
	"go.mongodb.org/mongo-driver/v2/mongo/options"
)

func GetExpensesByGroupID(groupID bson.ObjectID) ([]models.Expense, error) {

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	collection := config.MongoClient.Database("mydb").Collection("expenses")

	filter := bson.M{"groupId": groupID}
	opts := options.Find().SetSort(bson.M{"createdAt": -1})

	var expenses []models.Expense

	cursor, err := collection.Find(ctx, filter, opts)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	err = cursor.All(ctx, &expenses)
	if err != nil {
		return nil, err
	}

	return expenses, nil

}