package handlers

import (
	"encoding/json"
	"net/http"

	"github.com/Adam-Warlock09/SplitEase/backend/internal/middleware"
	"github.com/Adam-Warlock09/SplitEase/backend/internal/services"
	"github.com/gorilla/mux"
	"go.mongodb.org/mongo-driver/v2/bson"
)

func GetTransactionsHandler(w http.ResponseWriter, r *http.Request) {

	vars := mux.Vars(r)
	groupIDHex := vars["groupID"]

	groupID, err := bson.ObjectIDFromHex(groupIDHex)
	if err != nil {
		http.Error(w, "Invalid Group ID", http.StatusBadRequest)
		return
	}

	userIDHex := middleware.GetUserIDFromContext(r.Context())
	if userIDHex == "" {
		http.Error(w, "Failed to fetch user ID", http.StatusUnauthorized)
		return
	}

	userID, err := bson.ObjectIDFromHex(userIDHex)
	if err != nil {
		http.Error(w, "Invalid UserID", http.StatusUnauthorized)
		return
	}

	groupWithMembers, err := services.GetGroupWithNames(groupID)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	authorized := false
	for _, member := range groupWithMembers.Members{
		if member.ID == userID {
			authorized = true
			break
		}
	}

	if !authorized {
		http.Error(w, "User not a member of group", http.StatusUnauthorized)
		return
	}

	transactions, err := services.GetGroupTransactions(groupID)
	if err != nil {
		http.Error(w, "Failed to fetch transactions", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(transactions)

}