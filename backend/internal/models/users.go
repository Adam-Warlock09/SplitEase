package models

import (

	"go.mongodb.org/mongo-driver/v2/bson"

)

type User struct {

	ID bson.ObjectID `bson:"_id,omitempty" json:"id,omitempty"`
	Name string `bson:"name" json:"name"`
	Email string `bson:"email" json:"email"`
	Password string `bson:"password" json:"password"`

}