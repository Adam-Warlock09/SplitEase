package router

import (
	"net/http"
	"github.com/gorilla/mux"
	"fmt"

	"github.com/Adam-Warlock09/SplitEase/backend/internal/handlers"
)

func NewRouter() *mux.Router {

	router := mux.NewRouter()

	// BASE ROUTE
	router.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintln(w, "Backend is running with router!")
	}).Methods("GET")

	// LOGIN ROUTE
	router.HandleFunc("/login", handlers.LoginHandler).Methods("POST")
	router.HandleFunc("/signup", handlers.SignupHandler).Methods("POST")

	return router

}