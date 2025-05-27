package config

import "os"

type ServerConfig struct {
	Port string
}

func LoadConfig() *ServerConfig {

	port := os.Getenv("PORT")
	if len(port) > 0 && port[0] != ':' {
		port = ":" + port
	}
	
	return &ServerConfig{
		Port: os.Getenv("PORT"),
	}
}