package handlers

import (
	"fmt"
	"net/http"

	"github.com/Adam-Warlock09/SplitEase/backend/internal/middleware"
)

func ProtectedHandler(w http.ResponseWriter, r *http.Request) {

	userID := middleware.GetUserIDFromContext(r.Context())
	if userID == "" {
		http.Error(w, "UserID missing in context", http.StatusUnauthorized)
		return
	}

	fmt.Printf("UserID confirmed : %v", userID)

}