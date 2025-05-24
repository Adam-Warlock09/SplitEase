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

func RemoveMemberHandler(w http.ResponseWriter, r *http.Request) {

	vars := mux.Vars(r)
	groupIDHex := vars["groupID"]
	memberIDHex := vars["memberID"]

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

	if strings.TrimSpace(memberIDHex) == "" {
		http.Error(w, "MemberID is required", http.StatusBadRequest)
		return
	}

	memberID, err := bson.ObjectIDFromHex(memberIDHex);
	if err != nil {
		http.Error(w, "Invalid MemberID", http.StatusBadRequest)
		return
	}

	if (memberID == userID) {
		http.Error(w, "Can't remove Member from Group, because it's the client", http.StatusBadRequest)
		return
	}

	creatorID, err := services.GetGroupCreator(groupID)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	if (creatorID != userID) {
		http.Error(w, "User is not Creator. Permission Denied", http.StatusUnauthorized)
		return
	}

	err = services.RemoveMemberFromGroup(groupID, memberID)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	response := map[string]interface{}{
		"message": "Member removed Successfully",
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(response)

}