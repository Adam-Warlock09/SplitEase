package handlers

import (
	"encoding/json"
	"net/http"

	"github.com/Adam-Warlock09/SplitEase/backend/internal/middleware"
	"github.com/Adam-Warlock09/SplitEase/backend/internal/services"
)

func GetGroupsHandler(w http.ResponseWriter, r *http.Request) {
	
	userID := middleware.GetUserIDFromContext(r.Context())
	if userID == "" {
		http.Error(w, "UserID missing in context", http.StatusUnauthorized)
		return
	}

	groups, err := services.GetGroups(userID)

	if err != nil {
		http.Error(w, "Failed to fetch groups", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(groups)

}