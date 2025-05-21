package main

import (
	"fmt"
	"log"
	"net/http"
	"context"

	"github.com/Adam-Warlock09/SplitEase/backend/internal/config"
	"github.com/Adam-Warlock09/SplitEase/backend/internal/router"
	"github.com/Adam-Warlock09/SplitEase/backend/internal/middleware"
)

func main() {

	config.ConnectDB()
	defer func() {
		if err := config.MongoClient.Disconnect(context.TODO()); err != nil {
			panic(err)
		}
	}()

	configurer := config.LoadConfig()
	router := router.NewRouter()
	handler := middleware.CORSMiddleware(router)

	fmt.Println("Server starting on http://localhost" + configurer.Port)
	
	err := http.ListenAndServe(configurer.Port, handler)

	if err != nil {
		log.Fatal("Server failed : ", err)
	}

}