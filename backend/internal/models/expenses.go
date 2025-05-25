package models

import (
	"time"

	"go.mongodb.org/mongo-driver/v2/bson"
)

type Expense struct {
	ID        bson.ObjectID      `bson:"_id,omitempty" json:"id,omitempty"`
	GroupID   bson.ObjectID      `bson:"groupId" json:"groupId"`
	Title     string             `bson:"title" json:"title"`
	Amount    float64            `bson:"amount" json:"amount"`
	PaidBy    bson.ObjectID      `bson:"paidBy" json:"paidBy"`
	SplitType string             `bson:"splitType" json:"splitType"` // "equal", "percentage", "uneven"
	Splits    map[string]float64 `bson:"splits" json:"splits"`       // userId string -> share (amount)
	CreatedAt time.Time          `bson:"createdAt" json:"createdAt"`
	Notes     string             `bson:"notes,omitempty" json:"notes,omitempty"`
}
