package storage

import (
	"context"
	"fmt"
	"time"

	"github.com/Adam-Warlock09/SplitEase/backend/internal/config"
	"github.com/Adam-Warlock09/SplitEase/backend/internal/models"
	"go.mongodb.org/mongo-driver/v2/bson"
	"go.mongodb.org/mongo-driver/v2/mongo/options"
)

func CreateGroup(group *models.Group) (bson.ObjectID, error) {

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	collection := config.MongoClient.Database("mydb").Collection("groups")

	result, err := collection.InsertOne(ctx, group)
	if err != nil {
		return bson.NilObjectID, err
	}

	insertedID, ok := result.InsertedID.(bson.ObjectID)
	if !ok {
		return bson.NilObjectID, fmt.Errorf("inserted ObjectId is not valid")
	}

	return insertedID, nil

}

func FindGroupsByMemberID(userId string) ([]models.Group, error) {

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	collection := config.MongoClient.Database("mydb").Collection("groups")

	userID, err := bson.ObjectIDFromHex(userId)
	if err != nil {
		return nil, err
	}

	filter := bson.M{"members": userID}
	opts := options.Find().SetSort(bson.M{"updatedAt": -1})

	var groups []models.Group

	cursor, err := collection.Find(ctx, filter, opts)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	err = cursor.All(ctx, &groups)
	if err != nil {
		return nil, err
	}

	return groups, nil

}