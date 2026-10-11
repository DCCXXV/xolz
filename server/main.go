package main

import (
	"log"
	"net/http"
	"os"

	"github.com/go-chi/chi/v5"
)

func main() {
	dir := "build/web"
	if len(os.Args) > 1 {
		dir = os.Args[1]
	}

	r := chi.NewRouter()
	r.Handle("/*", http.FileServer(http.Dir(dir)))

	log.Println("serving", dir, "on :8080")
	log.Fatal(http.ListenAndServe(":8080", r))
}
