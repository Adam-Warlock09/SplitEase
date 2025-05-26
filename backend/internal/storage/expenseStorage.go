package storage

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/Adam-Warlock09/SplitEase/backend/internal/config"
	"github.com/Adam-Warlock09/SplitEase/backend/internal/models"
	"go.mongodb.org/mongo-driver/v2/bson"
	"go.mongodb.org/mongo-driver/v2/mongo"
	"go.mongodb.org/mongo-driver/v2/mongo/options"
)

func RemoveExpenseWithID(expenseID bson.ObjectID) error {

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	collection := config.MongoClient.Database("mydb").Collection("expenses")

	filter := bson.M{"_id" : expenseID}

	_, err := collection.DeleteOne(ctx, filter)
	return err

}

func GetExpenseByID(expenseID bson.ObjectID) (*models.Expense, error) {

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	collection := config.MongoClient.Database("mydb").Collection("expenses")

	filter := bson.M{"_id" : expenseID}

	var expense models.Expense

	err := collection.FindOne(ctx, filter).Decode(&expense)

	if err != nil {
		if err == mongo.ErrNoDocuments {
			return nil, errors.New("grexpenseoup not found")
		}
		return nil, err
	}

	return &expense, nil

}

func CreateExpense(expense *models.Expense) (bson.ObjectID, error) {

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	collection := config.MongoClient.Database("mydb").Collection("expenses")

	result, err := collection.InsertOne(ctx, expense)
	if err != nil {
		return bson.NilObjectID, err
	}

	insertedID, ok := result.InsertedID.(bson.ObjectID)
	if !ok {
		return bson.NilObjectID, fmt.Errorf("inserted ObjectId is not valid")
	}

	return insertedID, nil

}

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