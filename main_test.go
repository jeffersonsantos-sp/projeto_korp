package main

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/prometheus/client_golang/prometheus/promhttp"
)

func TestHandler(t *testing.T) {
	req, err := http.NewRequest("GET", "/projeto-korp", nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(handler)
	handler.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v want %v", status, http.StatusOK)
	}

	var response Response
	err = json.Unmarshal(rr.Body.Bytes(), &response)
	if err != nil {
		t.Errorf("handler returned invalid JSON: %v", err)
	}

	if response.Nome != "Projeto Korp" {
		t.Errorf("handler returned unexpected nome: got %v want %v", response.Nome, "Projeto Korp")
	}

	if response.Horario == "" {
		t.Errorf("handler returned empty horario")
	}
}

func TestMetricsEndpoint(t *testing.T) {
	req, err := http.NewRequest("GET", "/metrics", nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		promhttp.Handler().ServeHTTP(w, r)
	})
	handler.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusOK {
		t.Errorf("metrics handler returned wrong status code: got %v want %v", status, http.StatusOK)
	}
}

func TestHealthEndpoint(t *testing.T) {
	req, err := http.NewRequest("GET", "/health", nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(healthHandler)
	handler.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusOK {
		t.Errorf("health handler returned wrong status code: got %v want %v", status, http.StatusOK)
	}

	var response map[string]string
	err = json.Unmarshal(rr.Body.Bytes(), &response)
	if err != nil {
		t.Errorf("health handler returned invalid JSON: %v", err)
	}

	if response["status"] != "healthy" {
		t.Errorf("health handler returned unexpected status: got %v want %v", response["status"], "healthy")
	}
}
