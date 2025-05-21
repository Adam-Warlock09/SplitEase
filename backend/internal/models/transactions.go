package models

import (
	"time"

	"go.mongodb.org/mongo-driver/v2/bson"
)

type Transaction struct {
	ID        bson.ObjectID `bson:"_id,omitempty" json:"id,omitempty"`
	GroupID   bson.ObjectID `bson:"groupId" json:"groupId"`
	FromUser  bson.ObjectID `bson:"fromUser" json:"fromUser"`
	ToUser    bson.ObjectID `bson:"toUser" json:"toUser"`
	Amount    float64       `bson:"amount" json:"amount"`
	CreatedAt time.Time     `bson:"createdAt" json:"createdAt"`
	Notes     string       `bson:"notes,omitempty" json:"notes,omitempty"`
}
