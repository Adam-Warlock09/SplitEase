package handlers

import (
	"encoding/json"
	"net/http"

	"github.com/Adam-Warlock09/SplitEase/backend/internal/services"
)

type LoginRequest struct {

	Email string `json:"email"`
	Password string `json:"password"`

}

func LoginHandler(w http.ResponseWriter, r *http.Request) {

	if r.Method != http.MethodPost {
		http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		return
	}

	var req LoginRequest

	err := json.NewDecoder(r.Body).Decode(&req)

	if err != nil {
		http.Error(w, "Invalid request", http.StatusBadRequest)
		return
	}

	user, err := services.AuthenticateUser(req.Email, req.Password)
	if err != nil {
		http.Error(w, "Unauthorized User", http.StatusUnauthorized)
		return
	}

	token, err := services.GenerateJWT(user.ID.Hex())
	if err != nil {
		http.Error(w, "Could not generate token", http.StatusInternalServerError)
	}

	reponse := map[string]interface{}{
		"token": token,
		"user": map[string]interface{}{
			"id": user.ID.Hex(),
			"name": user.Name,
			"email": user.Email,
		},
	}



	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(reponse)

}