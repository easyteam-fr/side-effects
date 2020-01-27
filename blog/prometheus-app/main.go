package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

type message struct {
	Text *string `json:"text,omitempty"`
}

var (
	invocations = prometheus.NewCounterVec(prometheus.CounterOpts{
		Name: "app_requests_by_uri",
		Help: "Number of calls by URL",
	},
		[]string{"url"},
	)
	up = prometheus.NewCounter(prometheus.CounterOpts{
		Name: "up",
		Help: "shows if the process is up",
	})
)

func init() {
	up.Inc()
	prometheus.MustRegister(invocations)
	prometheus.MustRegister(up)

}

func handler(w http.ResponseWriter, r *http.Request) {
	invocations.WithLabelValues(r.URL.Path).Inc()
	text := "Helloworld!"
	msg := &message{
		Text: &text,
	}
	output, err := json.Marshal(msg)
	if err != nil {
		log.Panicf("error %v", err)
	}
	fmt.Fprintln(w, string(output))
}

func main() {
	finish := make(chan bool)

	server1 := http.NewServeMux()
	server2 := http.NewServeMux()

	server2.Handle("/metrics", promhttp.Handler())
	server1.HandleFunc("/url1", handler)
	server1.HandleFunc("/url2", handler)

	go func() { log.Fatal(http.ListenAndServe(":8080", server1)) }()
	go func() { log.Fatal(http.ListenAndServe(":8081", server2)) }()

	<-finish
}
