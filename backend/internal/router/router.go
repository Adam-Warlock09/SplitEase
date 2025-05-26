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
	protectedSubRouter.HandleFunc("/group", handlers.CreateGroupHandler).Methods("POST")
	protectedSubRouter.HandleFunc("/group/{groupID}", handlers.GetGroupDetailsHandler).Methods("GET")
	protectedSubRouter.HandleFunc("/group/{groupID}/member", handlers.AddMemberHandler).Methods("POST")
	protectedSubRouter.HandleFunc("/group/{groupID}/member/{memberID}", handlers.RemoveMemberHandler).Methods("DELETE")
	protectedSubRouter.HandleFunc("/group/{groupID}/users", handlers.GetOtherUsersHandler).Methods("GET")
	protectedSubRouter.HandleFunc("/group/{groupID}/expenses", handlers.GetExpensesHandler).Methods("GET")
	protectedSubRouter.HandleFunc("/group/{groupID}/expenses", handlers.CreateExpenseHandler).Methods("POST")
	protectedSubRouter.HandleFunc("/group/{groupID}/expenses/{expenseID}", handlers.RemoveExpenseHandler).Methods("DELETE")
	protectedSubRouter.HandleFunc("/group/{groupID}/transactions", handlers.GetTransactionsHandler).Methods("GET")
	protectedSubRouter.HandleFunc("/group/{groupID}/transactions", handlers.CreateTransactionHandler).Methods("POST")
	protectedSubRouter.HandleFunc("/group/{groupID}/transactions/{transactionID}", handlers.RemoveTransactionHandler).Methods("DELETE")
	protectedSubRouter.HandleFunc("/group/{groupID}/settle", handlers.GetSettlementsHandler).Methods("GET")

	return router

}