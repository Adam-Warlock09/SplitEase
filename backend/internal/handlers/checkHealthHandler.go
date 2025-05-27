package handlers

import "net/http"

func CheckHealthHandler(w http.ResponseWriter, r *http.Request) {

	w.WriteHeader(http.StatusOK)
    w.Write([]byte("OK"))

}