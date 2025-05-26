package handlers

import (
	"encoding/json"
	"net/http"

	"github.com/Adam-Warlock09/SplitEase/backend/internal/middleware"
	"github.com/Adam-Warlock09/SplitEase/backend/internal/services"
	"github.com/gorilla/mux"
	"go.mongodb.org/mongo-driver/v2/bson"
)

func CreateTransactionHandler(w http.ResponseWriter, r *http.Request) {

	vars := mux.Vars(r)
	groupIDHex := vars["groupID"]

	groupID, err := bson.ObjectIDFromHex(groupIDHex)
	if err != nil {
		http.Error(w, "Invalid Group ID", http.StatusBadRequest)
		return
	}

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

	groupWithMembers, err := services.GetGroupWithNames(groupID)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	authorized := false
	for _, member := range groupWithMembers.Members {
		if member.ID == userID {
			authorized = true
			break
		}
	}

	if !authorized {
		http.Error(w, "User not a member of group", http.StatusUnauthorized)
		return
	}

	var req services.CreateTransactionRequest
	err = json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	if (req.FromUser == req.ToUser) {
		http.Error(w, "Invalid Request body, both recipient and Payer can't be same", http.StatusBadRequest)
		return
	}

	if (groupIDHex != req.GroupID) {
		http.Error(w, "Invalid Request body, groupID's don't match", http.StatusBadRequest)
		return
	}

	if (req.FromUser != userIDHex && req.ToUser != userIDHex) {
		http.Error(w, "Invalid Request body, userID doesn't match neither recipient not payer.", http.StatusBadRequest)
		return
	}

	var otherUserIDHex string
	if (req.FromUser == userIDHex) {
		otherUserIDHex = req.ToUser
	} else {
		otherUserIDHex = req.FromUser
	}

	otherUserID, err := bson.ObjectIDFromHex(otherUserIDHex)
	if err != nil {
		http.Error(w, "Invalid otherUserID", http.StatusBadRequest)
		return
	}

	present := false
	for _, member := range groupWithMembers.Members {
		if member.ID == otherUserID {
			present = true
			break
		}
	}

	if !present {
		http.Error(w, "Other user not a member of group", http.StatusUnauthorized)
		return
	}

	transaction, err := services.CreateTransaction(&req, groupID)
	if err != nil {
		http.Error(w, "Failed to create transaction", http.StatusInternalServerError)
		return
	}

	_ = services.UpdateGroupUpdatedAt(groupID)

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(transaction)

}
