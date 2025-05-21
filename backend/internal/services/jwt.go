package services

import (

	"time"
	"os"
	"log"

	"github.com/golang-jwt/jwt/v5"

)

type JWTPayload struct {
	UserID string `json:"id"`
	jwt.RegisteredClaims
}

func GenerateJWT(userID string) (string, error) {

	secret := os.Getenv("JWT_SECRET")
	if secret == "" {
		log.Fatal("JWT_SECRET environment variable not set")
	}

	expirationTime := time.Now().Add(24 * time.Hour)

	payload := JWTPayload{
		UserID: userID,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(expirationTime),
			IssuedAt: jwt.NewNumericDate(time.Now()),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, payload)
	tokenString, err := token.SignedString([]byte(secret))
	if err != nil {
		return "", err
	}

	return tokenString, nil

}