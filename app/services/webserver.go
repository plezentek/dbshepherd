// Copyright 2021 Plezentek, Inc. All rights reserved
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package services

import (
	"bytes"
	"context"
	"fmt"
	"html/template"
	"log"
	"net"
	"net/http"
	"strings"
	"time"

	"github.com/fsnotify/fsnotify"
	"github.com/improbable-eng/grpc-web/go/grpcweb"
	pb "github.com/plezentek/dbshepherd/api"
	"github.com/plezentek/dbshepherd/common"
	"github.com/plezentek/dbshepherd/dbsui"
	"github.com/rs/cors"
	"github.com/unrolled/logger"
	"golang.org/x/net/http2"
	"golang.org/x/net/http2/h2c"
	"google.golang.org/grpc"
	"k8s.io/klog"
)

var startupTime time.Time
var staticRoot string

func init() {
	startupTime = time.Now()
	for k, _ := range dbsui.Data {
		if strings.HasSuffix(k, "/index.html") {
			staticRoot = k[0:strings.LastIndex(k, "/")]
			return
		}
	}
	staticRoot = ""
}

type WebServer struct {
	Closer             common.CancelContext
	port               string
	Health             *HealthService
	MigrationApiServer *MigrationApiServer
	GrpcServer         *grpc.Server
	GrpcWebServer      *grpcweb.WrappedGrpcServer
	HttpHandler        http.HandlerFunc
	DevMode            bool
	UserDb             *UserDb
	cert               string
	key                string
}

const (
	HTML5 = `
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<title>{{.Title}}</title>
	<script src="none.js"></script>
</head>
<body>
<h1>{{.Body}}</h1>
</body>
</html>
`
)

type Page struct {
	Title string
	Body  string
}

var templates = template.Must(template.New("HTML5").Parse(HTML5))

func (ws *WebServer) healthz(w http.ResponseWriter, r *http.Request) {
	if ws.Health.CheckHealthy() {
		fmt.Fprintf(w, "ok")
	} else {
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte("notok"))
	}
}

func root(w http.ResponseWriter, r *http.Request) {
	page := &Page{Title: "Serve And Forget", Body: "Oh, hai!"}
	err := templates.ExecuteTemplate(w, "HTML5", page)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

func (ws *WebServer) grpcMux(w http.ResponseWriter, r *http.Request) {
	if ws.GrpcWebServer.IsGrpcWebRequest(r) {
		ws.GrpcWebServer.ServeHTTP(w, r)
		return
	}

	if r.ProtoMajor == 2 && strings.Contains(r.Header.Get("Content-Type"), "application/grpc") {
		ws.GrpcServer.ServeHTTP(w, r)
		return
	}

	ws.staticFiles(w, r)
}

func (ws *WebServer) staticFiles(w http.ResponseWriter, r *http.Request) {
	// Ugly hack, but fixing the go_embed_rule will take some time
	indexKey := "bazel-out/k8-fastbuild/bin/dbsui/build/web" + r.URL.Path
	if strings.HasSuffix(indexKey, "/") {
		indexKey = indexKey + "index.html"
	}
	if f, ok := dbsui.Data[indexKey]; ok {
		http.ServeContent(w, r, r.URL.Path, startupTime, bytes.NewReader(f))
		return
	}

	// Fallback to normal web handler
	ws.HttpHandler.ServeHTTP(w, r)
}

func (ws *WebServer) basicAuth(w http.ResponseWriter, r *http.Request) {
	// Ugly hack, but fixing the go_embed_rule will take some time
	if ws.UserDb.AuthEnabled() {
		if r.URL.Path == "/logout" {
			w.WriteHeader(401)
			w.Header().Set("Content-Type", "text;html; charset=utf-8")
			fmt.Fprint(w, "<!doctype html><meta charset=utf-8><script>window.location.replace(\"/\");</script><title>logout</title>", 401)
			return
		}
		w.Header().Set("WWW-Authenticate", `Basic realm="Restricted"`)
		if user, pass, ok := r.BasicAuth(); !ok {
			http.Error(w, "Unauthorized", 401)
			return
		} else if !ws.UserDb.IsAuthenticated(user, pass) {
			http.Error(w, "Unauthorized", 401)
			return
		}
	}

	// Fallback to normal web handler
	ws.grpcMux(w, r)
}

func (ws *WebServer) Start(st common.ServiceTracker) {
	st.AddService()
	defer st.ShutdownService()

	// Setup HTTP Routes
	httpRoutes := http.NewServeMux()
	httpRoutes.HandleFunc("/", root)
	httpRoutes.HandleFunc("/healthz", ws.healthz)
	ws.HttpHandler = httpRoutes.ServeHTTP

	// Setup GRPC and GRPC-WEB servers
	ws.GrpcServer = grpc.NewServer()
	ws.GrpcWebServer = grpcweb.WrapServer(ws.GrpcServer)

	// Register the GRPC services
	pb.RegisterMigrateServer(ws.GrpcServer, ws.MigrationApiServer)

	// http2 Server
	h2s := &http2.Server{}

	// Setup HTTP Logger
	myLogger := logger.New(logger.Options{
		Prefix:               "Backend",
		RemoteAddressHeaders: []string{"X-Forwarded-For"},
		OutputFlags:          log.LstdFlags,
	})

	rootMux := http.Handler(http.HandlerFunc(ws.basicAuth))
	klog.Infof("Cert: %s Key: %s", ws.cert, ws.key)
	if ws.cert == "" || ws.key == "" {
		rootMux = h2c.NewHandler(rootMux, h2s)
	}

	// We set a permissive CORS policy in dev mode to make it possible to use a
	// frontend separate from the backend
	if ws.DevMode {
		rootMux = cors.AllowAll().Handler(rootMux)
	}
	app := myLogger.Handler(rootMux)

	// http Server with h2c (http2 cleartext) support
	hserver := &http.Server{
		Handler:      app,
		ReadTimeout:  5 * time.Second,
		WriteTimeout: 10 * time.Second,
	}

	backgrounder := make(chan struct{})
	// With buffer so it can be handled asynchronously
	restarter := make(chan struct{}, 1)
	go func() {
		defer close(backgrounder)
		keepRunning := true
		for keepRunning {
			ipv4listener, err := net.Listen("tcp4", ":"+ws.port)
			if err != nil {
				klog.Fatalf("Unable to listen on port ':%s' error: %s", ws.port, err)
			}

			if ws.cert == "" || ws.key == "" {
				err = hserver.Serve(ipv4listener)
			} else {
				err = hserver.ServeTLS(ipv4listener, ws.cert, ws.key)
			}
			if err != nil && err != http.ErrServerClosed {
				keepRunning = false
				klog.Errorf("Listening Error: %s", err)
			}
			select {
			case _, ok := <-restarter:
				if !ok {
					keepRunning = false
					klog.Errorf("Error upon detecting changes in certificate file: %s", ok)
				} else {
					klog.Infoln("Change in certificate file, restarting")
					// Reinitialize server structure
					hserver = &http.Server{
						Handler:      app,
						ReadTimeout:  5 * time.Second,
						WriteTimeout: 10 * time.Second,
					}
				}
				break
			default:
				keepRunning = false
				klog.Infoln("Shutting down web server")
			}
		}
	}()

	if ws.cert != "" && ws.key != "" {
		watcher, err := fsnotify.NewWatcher()
		if err != nil {
			klog.Errorf("Error creating file watcher for certificate: %s", err)
		} else {
			defer watcher.Close()

			go func() {
				for {
					select {
					case <-backgrounder:
						// Only succeeds on a closed channel, which happens when http
						// server stopped externally
						return
					case event, ok := <-watcher.Events:
						if !ok {
							return
						}
						if event.Op&fsnotify.Write == fsnotify.Write {
							// go func() { restarter <- true }()
							restarter <- struct{}{}
							hserver.Shutdown(context.Background())
						}
						break
					case err, ok := <-watcher.Errors:
						if !ok {
							return
						}
						klog.Infof("error: %s", err)
					}
				}
			}()

			err = watcher.Add(ws.cert)
			if err != nil {
				klog.Errorf("File system watcher failure, unable to watch certificate for updates: %s", err)
			}
		}
	}

	// Shutdown on request, or on server failure
	for {
		select {
		case <-backgrounder:
			// Only succeeds on a closed channel, which happens when http
			// server stopped externally
		case <-ws.Closer.Done():
			klog.Infoln("Gracefully shutting down web server")
			graceful, _ := context.WithTimeout(context.Background(), 150*time.Millisecond)
			hserver.Shutdown(graceful)
			return
		}
	}
}
