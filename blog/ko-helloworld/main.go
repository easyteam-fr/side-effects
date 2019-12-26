package main

import (
	"fmt"
	"net/http"
)

func main() {
	http.HandleFunc("/", HelloServer)
	http.ListenAndServe(":8080", nil)
}

func HelloServer(w http.ResponseWriter, r *http.Request) {
	if len(r.URL.Path[1:]) == 0 {
		fmt.Fprintf(w, "Hello, World")
		return
	}
	fmt.Fprintf(w, "Hello, %s!", r.URL.Path[1:])
}
