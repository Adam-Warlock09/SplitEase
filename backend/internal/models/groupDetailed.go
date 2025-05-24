package models

import (
	"time"

	"go.mongodb.org/mongo-driver/v2/bson"
)

type GroupDetailed struct {
	ID          bson.ObjectID `json:"id"`
	Name        string        `json:"name"`
	Description string        `json:"description"`
	CreatedAt   time.Time     `json:"createdAt"`
	UpdatedAt   time.Time     `json:"updatedAt"`
	CreatedBy   UserRef       `json:"createdBy"`
	Members     []UserRef     `json:"members"`
}
