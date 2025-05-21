package models

import (
	"time"

	"go.mongodb.org/mongo-driver/v2/bson"
)

type User struct {

	ID bson.ObjectID `bson:"_id,omitempty" json:"id,omitempty"`
	Name string `bson:"name" json:"name"`
	Email string `bson:"email" json:"email"`
	HashedPassword string `bson:"passwordHash" json:"password"`
	CreatedAt time.Time `bson:"createdAt" json:"createdAt"`
	UpdatedAt time.Time `bson:"updatedAt" json:"updatedAt"`
	Groups []bson.ObjectID `bson:"groups,omitempty" json:"groups,omitempty"`

}