package main

import (
	"fmt"
	"net/http"
	"net/url"

	log "github.com/sirupsen/logrus"
)

func main() {
	http.HandleFunc("/hello", handleHelloEndpoint)
	http.ListenAndServe(":8080", nil)
}

func handleHelloEndpoint(responseWriter http.ResponseWriter, request *http.Request) {
	query, err := url.ParseQuery(request.URL.RawQuery)
	if err != nil {
		http.Error(responseWriter, "Malformed query string", http.StatusBadRequest)
		return
	}

	name := query.Get("name")
	if name == "" {
		http.Error(responseWriter, "Missing query parameter 'name'", http.StatusBadRequest)
		return
	}

	fmt.Fprintf(responseWriter, "Hello %s!", name)
	log.Infof(`Hello %s`, name)
	responseWriter.WriteHeader(http.StatusOK)
}
