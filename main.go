package main

import (
	"encoding/json"
	"net/http"
	"time"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

type Response struct {
	Nome    string `json:"nome"`
	Horario string `json:"horario"`
}

var (
	requestsTotal = prometheus.NewCounterVec(
		prometheus.CounterOpts{
			Name: "http_requests_total",
			Help: "Total number of HTTP requests",
		},
		[]string{"method", "endpoint", "status"},
	)

	requestDuration = prometheus.NewHistogramVec(
		prometheus.HistogramOpts{
			Name:    "http_request_duration_seconds",
			Help:    "Duration of HTTP requests in seconds",
			Buckets: prometheus.DefBuckets,
		},
		[]string{"method", "endpoint"},
	)

	serviceUp = prometheus.NewGauge(
		prometheus.GaugeOpts{
			Name: "service_up",
			Help: "Service availability (1 = up, 0 = down)",
		},
	)
)

func init() {
	prometheus.MustRegister(requestsTotal, requestDuration, serviceUp)
	serviceUp.Set(1)
}

func handler(w http.ResponseWriter, r *http.Request) {
	start := time.Now()

	if r.URL.Path != "/projeto-korp" {
		http.NotFound(w, r)
		requestsTotal.WithLabelValues(r.Method, r.URL.Path, "404").Inc()
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(Response{
		Nome:    "Projeto Korp",
		Horario: time.Now().In(time.FixedZone("BRT", -3*3600)).Format(time.RFC3339),
	})

	duration := time.Since(start).Seconds()
	requestsTotal.WithLabelValues(r.Method, r.URL.Path, "200").Inc()
	requestDuration.WithLabelValues(r.Method, r.URL.Path).Observe(duration)
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{
		"status": "healthy",
		"service": "http-server-projeto-korp",
	})
}

func main() {
	http.HandleFunc("/projeto-korp", handler)
	http.HandleFunc("/health", healthHandler)
	http.Handle("/metrics", promhttp.Handler())
	http.ListenAndServe(":8080", nil)
}