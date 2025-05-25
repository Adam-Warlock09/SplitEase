package handlers

import (
	"encoding/json"
	"net/http"

	"github.com/Adam-Warlock09/SplitEase/backend/internal/middleware"
	"github.com/Adam-Warlock09/SplitEase/backend/internal/services"
	"github.com/gorilla/mux"
	"go.mongodb.org/mongo-driver/v2/bson"
)

func CreateExpenseHandler(w http.ResponseWriter, r *http.Request) {

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

	var req services.ExpenseRequest
	err = json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	if (groupIDHex != req.GroupID) {
		http.Error(w, "Invalid Request body", http.StatusBadRequest)
		return
	}

	for splitID := range req.Splits {

		userID, err := bson.ObjectIDFromHex(splitID)
		if err != nil {
			http.Error(w, "Invalid ObjectID in splits: " + splitID, http.StatusBadRequest)
            return
		}

		found := false
		for _, user := range groupWithMembers.Members {
			if user.ID == userID {
				found = true
				break
			}
		}

		if !found {
			http.Error(w, "User ID not found in members: " + splitID, http.StatusBadRequest)
            return
		}

	}

	expense, err := services.CreateExpense(&req, groupID)
	if err != nil {
		http.Error(w, "Failed to create expense", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(expense)

}