package models

import "go.mongodb.org/mongo-driver/v2/bson"

type Settlement struct {
	FromUser  bson.ObjectID `bson:"fromUser" json:"fromID"`
	ToUser    bson.ObjectID `bson:"toUser" json:"toID"`
	Amount    float64       `bson:"amount" json:"amount"`
}