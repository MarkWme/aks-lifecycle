package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net"
	"net/http"
	"strings"
	"time"
)

type version struct {
	Application string
	Version     string
}

var ready bool = true

func getIP(w http.ResponseWriter, r *http.Request) {
	ip, err := getIPAddress(r)
	if err != nil {
		w.WriteHeader(400)
		w.Write([]byte("No valid ip"))
	}
	w.WriteHeader(200)
	w.Write([]byte(ip))
}

func getVersion(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(getVersionValue())
	log.Println("getVersion endpoint:", getVersionValue(), "from", r.RemoteAddr)
}

func get1KBFile(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/octet-stream")
	w.Header().Set("Content-Disposition", "attachment; filename=1kb.bin")
	w.WriteHeader(http.StatusOK)
	w.Write([]byte(strings.Repeat("X", 1024)))
	log.Println("get1KBFile endpoint")
}

func get1MBFile(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/octet-stream")
	w.Header().Set("Content-Disposition", "attachment; filename=1kb.bin")
	w.WriteHeader(http.StatusOK)
	w.Write([]byte(strings.Repeat("X", 1048576)))
	log.Println("get1MBFile endpoint")
}

func podTerminate(w http.ResponseWriter, r *http.Request) {
	log.Println("podTerminate endpoint: Starting 30 second waiting period ...")
	ready = false
	time.Sleep(30 * time.Second)
	log.Println("Waiting period complete")
}

func podReady(w http.ResponseWriter, r *http.Request) {
	if ready {
		log.Println("podReady endpoint: Ready")
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("OK"))
	} else {
		log.Println("podReady endpoint: Terminating")
		w.WriteHeader(http.StatusInternalServerError)
	}
}

func main() {
	http.HandleFunc("/api/getVersion", getVersion)
	http.HandleFunc("/api/get1KBFile", get1KBFile)
	http.HandleFunc("/api/get1MBFile", get1MBFile)
	http.HandleFunc("/api/podTerminate", podTerminate)
	http.HandleFunc("/api/podReady", podReady)
	http.HandleFunc("/api/getIp", getIP)
	srv := &http.Server{
		Addr:              ":3000",
		ReadTimeout:       10 * time.Second,
		WriteTimeout:      10 * time.Second,
		IdleTimeout:       30 * time.Second,
		ReadHeaderTimeout: 2 * time.Second,
	}
	log.Println("Starting HTTP server on port 3000")
	if err := srv.ListenAndServe(); err != nil {
		fmt.Printf("Server failed: %s\n", err)
	}
}

func getVersionValue() version {
	return version{"Simple API Server", "1.1.0"}
}

func getIPAddress(r *http.Request) (string, error) {
	//Get IP from the X-REAL-IP header
	ip := r.Header.Get("X-REAL-IP")
	netIP := net.ParseIP(ip)
	if netIP != nil {
		return ip, nil
	}

	//Get IP from X-FORWARDED-FOR header
	ips := r.Header.Get("X-FORWARDED-FOR")
	splitIps := strings.Split(ips, ",")
	for _, ip := range splitIps {
		netIP := net.ParseIP(ip)
		if netIP != nil {
			return ip, nil
		}
	}

	//Get IP from RemoteAddr
	ip, _, err := net.SplitHostPort(r.RemoteAddr)
	if err != nil {
		return "", err
	}
	netIP = net.ParseIP(ip)
	if netIP != nil {
		return ip, nil
	}
	return "", fmt.Errorf("No valid ip found")
}
