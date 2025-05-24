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

func RemoveMemberFromGroup(groupID bson.ObjectID, memberID bson.ObjectID) error {

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	collection := config.MongoClient.Database("mydb").Collection("groups")

	filter := bson.M{"_id": groupID}
	update := bson.M{
		"$pull": bson.M{"members": memberID},
		"$set":  bson.M{"updatedAt": time.Now()},
	}

	_, err := collection.UpdateOne(ctx, filter, update)
	return err

}

func AddMemberToGroup(groupID bson.ObjectID, memberID bson.ObjectID) (*models.UserRef, error) {

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	collection := config.MongoClient.Database("mydb").Collection("groups")

	user, err := GetUserByID(memberID)
	if err != nil {
		return nil, err
	}

	userDetailed := &models.UserRef{
		ID: user.ID,
		Name: user.Name,
		Email: user.Email,
	}

	filter := bson.M{"_id" : groupID}
	update := bson.M{
		"$addToSet": bson.M{"members" : memberID},
		"$set": bson.M{"updatedAt" : time.Now()},
	}

	_, err = collection.UpdateOne(ctx, filter, update)
	return userDetailed, err

}

func GetGroupByID(groupID bson.ObjectID) (*models.Group, error) {

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	collection := config.MongoClient.Database("mydb").Collection("groups")

	filter := bson.M{"_id" : groupID}

	var group models.Group

	err := collection.FindOne(ctx, filter).Decode(&group)

	if err != nil {
		if err == mongo.ErrNoDocuments {
			return nil, errors.New("group not found")
		}
		return nil, err
	}

	return &group, nil

}

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