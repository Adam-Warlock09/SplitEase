package middleware

import (

	"context"
	"net/http"
	"strings"
	"os"

	"github.com/golang-jwt/jwt/v5"

)

type contextKey string

const userIDkey = contextKey("userId")

func AuthMiddleware(routerHandler http.Handler) http.Handler {

	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {

		authHeader := r.Header.Get("Authorization")

		if authHeader == "" || !strings.HasPrefix(authHeader, "Bearer ") {
			http.Error(w, "Missing or invalid Authorization Header", http.StatusUnauthorized)
			return
		}

		tokenString := strings.TrimPrefix(authHeader, "Bearer ")

		secret := []byte(os.Getenv("JWT_SECRET"))

		token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
			
			if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
				return nil, jwt.ErrSignatureInvalid
			}
			return secret, nil

		})

		if err != nil || !token.Valid {
			http.Error(w, "Invalid or expired token", http.StatusUnauthorized)
			return
		}

		claims, ok := token.Claims.(jwt.MapClaims)
		if !ok || claims["UserID"] == nil {
			http.Error(w, "Invalid token claims", http.StatusUnauthorized)
			return
		}

		ctx := context.WithValue(r.Context(), userIDkey, claims["UserID"].(string))
		routerHandler.ServeHTTP(w, r.WithContext(ctx))

	})

}

func GetUserIDFromContext(ctx context.Context) string {

	userID, ok := ctx.Value(userIDkey).(string)
	if !ok {
		return ""
	}
	return userID

}