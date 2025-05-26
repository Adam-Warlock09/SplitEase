package storage

import (
	"context"
	"errors"
	"time"

	"github.com/Adam-Warlock09/SplitEase/backend/internal/config"
	"github.com/Adam-Warlock09/SplitEase/backend/internal/models"
	"go.mongodb.org/mongo-driver/v2/bson"
	"go.mongodb.org/mongo-driver/v2/mongo"
	"go.mongodb.org/mongo-driver/v2/mongo/options"
)

func CreateTransaction(transaction *models.Transaction) (bson.ObjectID, error) {

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	collection := config.MongoClient.Database("mydb").Collection("transactions")

	result, err := collection.InsertOne(ctx, transaction)
	if err != nil {
		return bson.NilObjectID, err
	}

	insertedID, ok := result.InsertedID.(bson.ObjectID)
	if !ok {
		return bson.NilObjectID, errors.New("inserted ObjectId is not valid")
	}

	return insertedID, nil

}

func RemoveTransactionWithID(transactionID bson.ObjectID) error {

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	collection := config.MongoClient.Database("mydb").Collection("transactions")

	filter := bson.M{"_id" : transactionID}

	_, err := collection.DeleteOne(ctx, filter)
	return err

}

func GetTransactionByID(transactionID bson.ObjectID) (*models.Transaction, error) {

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	collection := config.MongoClient.Database("mydb").Collection("transactions")

	filter := bson.M{"_id" : transactionID}

	var transaction models.Transaction

	err := collection.FindOne(ctx, filter).Decode(&transaction)

	if err != nil {
		if err == mongo.ErrNoDocuments {
			return nil, errors.New("transaction not found")
		}
		return nil, err
	}

	return &transaction, nil

}

func GetTransactionsByGroupID(groupID bson.ObjectID) ([]models.Transaction, error) {

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	collection := config.MongoClient.Database("mydb").Collection("transactions")

	filter := bson.M{"groupId": groupID}
	opts := options.Find().SetSort(bson.M{"createdAt": -1})

	var transactions []models.Transaction

	cursor, err := collection.Find(ctx, filter, opts)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	err = cursor.All(ctx, &transactions)
	if err != nil {
		return nil, err
	}

	return transactions, nil

}