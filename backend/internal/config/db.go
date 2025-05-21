package config

import (

	"context"
	"fmt"
	"log"
	"time"

	"go.mongodb.org/mongo-driver/v2/mongo"
	"go.mongodb.org/mongo-driver/v2/mongo/options"
	
)

var MongoClient *mongo.Client

func ConnectDB() {

	uri := "mongodb+srv://aric1809:am180906@splitease.fpy5obs.mongodb.net/?retryWrites=true&w=majority&appName=splitease"
	
	serverAPI := options.ServerAPI(options.ServerAPIVersion1)
	clientOptions := options.Client().ApplyURI(uri).SetServerAPIOptions(serverAPI)
	
	client, err := mongo.Connect(clientOptions)
	if err != nil {
		log.Fatalf("Failed to connect to MongoDB: %v", err)
	}
	
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	err = client.Ping(ctx, nil)
	if err != nil {
		log.Fatalf("MongoDB ping error: %v", err)
	}

	fmt.Println("Successfully connected to MongoDB!")

	MongoClient = client


}