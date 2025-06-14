package storage

import (
	"context"
	"errors"
	"time"

	"go.mongodb.org/mongo-driver/v2/bson"
	"go.mongodb.org/mongo-driver/v2/mongo"

	"github.com/Adam-Warlock09/SplitEase/backend/internal/config"
	"github.com/Adam-Warlock09/SplitEase/backend/internal/models"
)

func GetAllUsers() ([]models.User, error) {

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	collection := config.MongoClient.Database("mydb").Collection("users")

	cursor, err := collection.Find(ctx, bson.M{}, )
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var users []models.User
	for cursor.Next(ctx) {
		var user models.User
		err = cursor.Decode(&user)
		if err != nil {
			return nil, err
		}
		users = append(users, user)
	}

	return users, nil

}

func FindUserByEmail(email string) (*models.User, error) {

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	collection := config.MongoClient.Database("mydb").Collection("users")

	filter := bson.M{"email" : email}

	var user models.User

	err := collection.FindOne(ctx, filter).Decode(&user)

	if err != nil {
		if err == mongo.ErrNoDocuments {
			return nil, errors.New("user not found")
		}
		return nil, err
	}

	return &user, nil

}

func GetUserByID(userID bson.ObjectID) (*models.User, error) {

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	collection := config.MongoClient.Database("mydb").Collection("users")

	filter := bson.M{"_id" : userID}

	var user models.User

	err := collection.FindOne(ctx, filter).Decode(&user)

	if err != nil {
		if err == mongo.ErrNoDocuments {
			return nil, errors.New("user not found")
		}
		return nil, err
	}

	return &user, nil

}

func AddUser(user *models.User)  (*models.User, error) {

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	collection := config.MongoClient.Database("mydb").Collection("users")
	
	filter := bson.M{"email": user.Email}

	count, err := collection.CountDocuments(ctx, filter)

	if err != nil {
		return nil, err
	}

	if count > 0 {
		return nil, errors.New("user with this email already exists")
	}

	result, err := collection.InsertOne(ctx, user)
	if err != nil {
		return nil, err
	}

	filter = bson.M{"_id": result.InsertedID}
	
	var addedUser models.User

	err = collection.FindOne(ctx, filter).Decode(&addedUser)
	if err != nil {
		return nil, err
	}

	return &addedUser, nil

}