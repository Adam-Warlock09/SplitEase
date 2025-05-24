package models

import (
	"go.mongodb.org/mongo-driver/v2/bson"
)

type UserRef struct {
	ID    bson.ObjectID `json:"id"`
	Name  string        `json:"name"`
	Email string        `json:"email"`
}
