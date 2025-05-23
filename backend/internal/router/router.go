package router

import (
	"fmt"
	"net/http"

	"github.com/gorilla/mux"

	"github.com/Adam-Warlock09/SplitEase/backend/internal/handlers"
	"github.com/Adam-Warlock09/SplitEase/backend/internal/middleware"

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

	// PROTECTED SUBROUTER
	protectedSubRouter := router.PathPrefix("/api").Subrouter()
	protectedSubRouter.Use(middleware.AuthMiddleware)

	protectedSubRouter.HandleFunc("/protected", handlers.ProtectedHandler).Methods("GET")
	protectedSubRouter.HandleFunc("/verify", handlers.VerificationHandler).Methods("GET")
	protectedSubRouter.HandleFunc("/groups", handlers.GetGroupsHandler).Methods("GET")

	return router

}