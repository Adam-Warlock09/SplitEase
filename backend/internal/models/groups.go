package models

import (
	"time"

	"go.mongodb.org/mongo-driver/v2/bson"
)

type Group struct {
	ID          bson.ObjectID   `bson:"_id,omitempty" json:"id,omitempty"`
	Name        string          `bson:"name" json:"name"`
	Description string          `bson:"description,omitempty" json:"description,omitempty"`
	CreatedAt   time.Time       `bson:"createdAt" json:"createdAt"`
	UpdatedAt   time.Time       `bson:"updatedAt" json:"updatedAt"`
	Members     []bson.ObjectID `bson:"members" json:"members"`
	Expenses    []bson.ObjectID `bson:"expenses,omitempty" json:"expenses,omitempty"`
	CreatedBy   bson.ObjectID   `bson:"createdBy" json:"createdBy"`
}
