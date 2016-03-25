package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net"
	"net/http"
	"os"

	"github.com/gorilla/mux"
	"github.com/oschwald/geoip2-golang"
)

func main() {
	router := mux.NewRouter().StrictSlash(true)
	router.HandleFunc("/city/{ip}", Lookup)
	http.Handle("/", router)

	log.Fatal(http.ListenAndServe(":8080", nil))
}

func Lookup(w http.ResponseWriter, r *http.Request) {
	// Basic Auth
	username, password, ok := r.BasicAuth()

	if os.Getenv("GEOIP_BASIC_AUTH") == "true" {
		if !(ok &&
			(username == os.Getenv("GEOIP_USERNAME")) &&
			(password == os.Getenv("GEOIP_PASSWORD"))) {
			http.Error(w, "Unauthorized", 401)
			return
		}
	}

	ipStr := mux.Vars(r)["ip"]
	ip := net.ParseIP(ipStr)

	if ip == nil {
		http.Error(w, "IP address malformed", 400)
		return
	}

	db, err := geoip2.Open("GeoLite2-City.mmdb")

	if err != nil {
		http.Error(w, "Server error", 500)
		return
	}

	defer db.Close()

	record, err := db.City(ip)

	if err != nil {
		http.Error(w, "Server error", 500)
		return
	}

	j, err := json.Marshal(record)

	if err != nil {
		http.Error(w, "Server error", 500)
		return
	}

	fmt.Fprintf(w, string(j))
}
