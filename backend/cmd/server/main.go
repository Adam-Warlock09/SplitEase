package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/Adam-Warlock09/SplitEase/backend/internal/config"
	"github.com/Adam-Warlock09/SplitEase/backend/internal/middleware"
	"github.com/Adam-Warlock09/SplitEase/backend/internal/router"

	"github.com/joho/godotenv"
)

func main() {

	if os.Getenv("RENDER") == "" {
		err := godotenv.Load()
		if err != nil {
			log.Fatal("Error loading .env file")
		}
	}

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