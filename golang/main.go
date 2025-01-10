package main

import (
	"net/http"

	log "github.com/sirupsen/logrus"
)

func main() {
	http.HandleFunc("/hello", handleHelloEndpoint)
	http.ListenAndServe(":8080", nil)
}

func handleHelloEndpoint(responseWriter http.ResponseWriter, request *http.Request) {
	log.Infof(`request: %v`, request)
	responseWriter.WriteHeader(http.StatusOK)
}
