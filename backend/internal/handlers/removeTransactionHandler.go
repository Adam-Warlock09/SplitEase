package handlers

import (
	"encoding/json"
	"net/http"
	"strings"

	"github.com/Adam-Warlock09/SplitEase/backend/internal/middleware"
	"github.com/Adam-Warlock09/SplitEase/backend/internal/services"
	"github.com/gorilla/mux"
	"go.mongodb.org/mongo-driver/v2/bson"
)

func RemoveTransactionHandler(w http.ResponseWriter, r *http.Request) {

	vars := mux.Vars(r)
	groupIDHex := vars["groupID"]
	transactionIDHex := vars["transactionID"]

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

	if strings.TrimSpace(transactionIDHex) == "" {
		http.Error(w, "ExpenseID is required", http.StatusBadRequest)
		return
	}

	transactionID, err := bson.ObjectIDFromHex(transactionIDHex);
	if err != nil {
		http.Error(w, "Invalid MemberID", http.StatusBadRequest)
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

	trasaction, err := services.GetTransactionByID(transactionID)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	if (trasaction.FromUser != userID && trasaction.ToUser != userID) {
		http.Error(w, "User is not part of transaction. Unauthorized", http.StatusUnauthorized)
		return
	}

	if (trasaction.GroupID != groupID) {
		http.Error(w, "Expense given isn't a part of the group given.", http.StatusBadRequest)
		return
	}

	err = services.RemoveTransactionWithID(transactionID)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	err = services.UpdateGroupUpdatedAt(groupID)
	var response map[string]interface{}
	if err != nil {
		response = map[string]interface{}{
			"message": "Expense removed Successfully. Group Not Updated",
		}
	} else {
		response = map[string]interface{}{
			"message": "Expense removed Successfully",
		}
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(response)

}