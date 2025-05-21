package config

import "os"

type ServerConfig struct {
	Port string
}

func LoadConfig() *ServerConfig {
	return &ServerConfig{
		Port: os.Getenv("PORT"),
	}
}