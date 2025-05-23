package handlers

import (
	"encoding/json"
	"net/http"
	"strings"

	"github.com/Adam-Warlock09/SplitEase/backend/internal/middleware"
	"github.com/Adam-Warlock09/SplitEase/backend/internal/services"
	"go.mongodb.org/mongo-driver/v2/bson"
)

type CreateGroupRequest struct {
	Name        string `json:"name"`
	Description string `json:"description,omitempty"`
}

func CreateGroupHandler(w http.ResponseWriter, r *http.Request) {

	userIDHex := middleware.GetUserIDFromContext(r.Context())
	if userIDHex == "" {
		http.Error(w, "UserID missing in context", http.StatusUnauthorized)
		return
	}

	userID, err := bson.ObjectIDFromHex(userIDHex)
	if err != nil {
		http.Error(w, "Invalid UserID", http.StatusBadRequest)
		return
	}

	var req CreateGroupRequest
	err = json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		http.Error(w, "Invalid Request body", http.StatusBadRequest)
		return
	}

	if strings.TrimSpace(req.Name) == "" {
		http.Error(w, "Group Name is required", http.StatusBadRequest)
		return
	}

	group, err := services.CreateGroup(req.Name, req.Description, userID)
	if err != nil {
		http.Error(w, "Failed to create group", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(group)

}
