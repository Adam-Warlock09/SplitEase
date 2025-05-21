package config

type ServerConfig struct {
	Port string
}

func LoadConfig() *ServerConfig {
	return &ServerConfig{
		Port: ":8080",
	}
}