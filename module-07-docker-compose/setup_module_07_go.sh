#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "--- Creating Module 07 Directory Structure with Go ---"

# Create the main directory and subdirectories
mkdir -p module-07-docker-compose/01-hello-world/site
mkdir -p module-07-docker-compose/02-go-web-db
mkdir -p module-07-docker-compose/03-go-db-redis

echo "--- Populating files with content ---"

# Create the main README.md
cat <<EOF > module-07-docker-compose/README.md
# Day 7: Docker Compose with Go

## The "Why": From Manual Commands to Elegant Code
So far, we've manually created networks, volumes, and containers. While this taught us the fundamentals, it's not practical for real-world applications. A modern application is a collection of services (web, database, cache, etc.), and managing them manually is complex and error-prone.

**Docker Compose is the solution.** It allows you to define your entire multi-container application in a single, easy-to-read YAML file. With one command (\`docker-compose up\`), you can build, create, and connect all the services your app needs.

This module automates everything you learned in Modules 5 (Volumes) and 6 (Networking), using the Go programming language for our web services.

## Why Go for Microservices?
Go is an excellent choice for building services to run in Docker:
*   **Single Binary:** Compiles to one static file with all dependencies included.
*   **Small Images:** Results in tiny, secure, and fast-downloading Docker images.
*   **High Performance:** Compiled language with low memory usage, perfect for microservices.

---

## Example 1: Hello World with Caddy
A simple introduction to the \`docker-compose.yml\` syntax using a single Caddy web server.

**How to Run:**
\`\`\`bash
cd 01-hello-world
docker-compose up -d
# Open http://localhost:8080
docker-compose down
\`\`\`

## Example 2: A Go Web App and a Database
This is the "Aha!" moment. We define a Go web application and a PostgreSQL database. Compose will build the Go app image, create a shared network, and set up a persistent volume for the database.

**How to Run:**
\`\`\`bash
cd 02-go-web-db
docker-compose up --build -d
# Open http://localhost:5000 and visit /init-db to create a table
# Then visit / to see the message from the database
docker-compose down
\`\`\`

## Example 3: Adding a Redis Cache
We expand on the previous example by adding a Redis caching service. This demonstrates how simple it is to add and connect new services to your stack.

**How to Run:**
\`\`\`bash
cd 03-go-db-redis
docker-compose up --build -d
# Open http://localhost:5000 and refresh the page. The visit count will be cached in Redis.
docker-compose down
\`\`\`
EOF

# --- Example 1: Hello World ---
cat <<'EOF' > module-07-docker-compose/01-hello-world/docker-compose.yml
version: '3.8'

services:
  web:
    image: caddy:alpine
    ports:
      - "8080:80"
    command: caddy file-server --listen :80 --root /usr/share/caddy
    volumes:
      - type: bind
        source: ./site
        target: /usr/share/caddy
EOF

echo "<h1>Hello from Docker Compose and Caddy!</h1>" > module-07-docker-compose/01-hello-world/site/index.html


# --- Example 2: Go Web App and DB ---
cat <<'EOF' > module-07-docker-compose/02-go-web-db/main.go
package main

import (
    "database/sql"
    "fmt"
    "log"
    "net/http"
    "os"

    _ "github.com/lib/pq"
    "github.com/gorilla/mux"
)

var db *sql.DB

func main() {
    // --- Database Connection ---
    dbHost := os.Getenv("DB_HOST")
    dbUser := os.Getenv("POSTGRES_USER")
    dbPassword := os.Getenv("POSTGRES_PASSWORD")
    dbName := os.Getenv("POSTGRES_DB")

    psqlInfo := fmt.Sprintf("host=%s user=%s password=%s dbname=%s sslmode=disable",
        dbHost, dbUser, dbPassword, dbName)

    var err error
    for i := 0; i < 5; i++ {
        db, err = sql.Open("postgres", psqlInfo)
        if err == nil {
            err = db.Ping()
            if err == nil {
                break
            }
        }
        log.Printf("Could not connect to database: %v. Retrying...", err)
    }
    if err != nil {
        log.Fatalf("Failed to connect to database after retries: %v", err)
    }
    defer db.Close()
    log.Println("Successfully connected to the database!")

    // --- Web Server ---
    r := mux.NewRouter()
    r.HandleFunc("/", indexHandler)
    r.HandleFunc("/init-db", initDbHandler)
    log.Println("Web server starting on port 5000...")
    log.Fatal(http.ListenAndServe(":5000", r))
}

func indexHandler(w http.ResponseWriter, r *http.Request) {
    var message string
    err := db.QueryRow("SELECT message FROM greetings LIMIT 1").Scan(&message)
    if err != nil {
        if err == sql.ErrNoRows {
            message = "No greeting found. Visit /init-db to create one."
        } else {
            http.Error(w, "Database query error", http.StatusInternalServerError)
            log.Printf("Query error: %v", err)
            return
        }
    }
    fmt.Fprintf(w, "<h1>%s</h1>", message)
}

func initDbHandler(w http.ResponseWriter, r *http.Request) {
    _, err := db.Exec("DROP TABLE IF EXISTS greetings;")
    if err != nil { http.Error(w, "DB Error", http.StatusInternalServerError); return }
    _, err = db.Exec("CREATE TABLE greetings (id SERIAL PRIMARY KEY, message TEXT);")
    if err != nil { http.Error(w, "DB Error", http.StatusInternalServerError); return }
    _, err = db.Exec("INSERT INTO greetings (message) VALUES ('Hello from the PostgreSQL database, served by Go!');")
    if err != nil { http.Error(w, "DB Error", http.StatusInternalServerError); return }
    fmt.Fprintln(w, "Database table 'greetings' created and populated! Go back to <a href='/'>/</a>.")
}
EOF

cat <<'EOF' > module-07-docker-compose/02-go-web-db/go.mod
module module07

go 1.19

require (
    github.com/gorilla/mux v1.8.0
    github.com/lib/pq v1.10.6
)
EOF

cat <<'EOF' > module-07-docker-compose/02-go-web-db/Dockerfile
# Stage 1: Build the Go binary
FROM golang:1.19-alpine AS builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o /app/server .

# Stage 2: Create the final, minimal image
FROM alpine:latest
WORKDIR /
COPY --from=builder /app/server .
EXPOSE 5000
CMD ["./server"]
EOF

cat <<'EOF' > module-07-docker-compose/02-go-web-db/docker-compose.yml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "5000:5000"
    environment:
      - DB_HOST=db
      - POSTGRES_DB=myappdb
      - POSTGRES_USER=myuser
      - POSTGRES_PASSWORD=mypassword
    depends_on:
      - db

  db:
    image: postgres:13
    environment:
      - POSTGRES_DB=myappdb
      - POSTGRES_USER=myuser
      - POSTGRES_PASSWORD=mypassword
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
EOF


# --- Example 3: Go, DB, and Redis ---
cat <<'EOF' > module-07-docker-compose/03-go-db-redis/main.go
package main

import (
    "context"
    "database/sql"
    "fmt"
    "log"
    "net/http"
    "os"
    "time"

    _ "github.com/lib/pq"
    "github.com/gorilla/mux"
    "github.com/go-redis/redis/v8"
)

var db *sql.DB
var rdb *redis.Client
var ctx = context.Background()

func main() {
    // --- Database Connection (same as before) ---
    dbHost := os.Getenv("DB_HOST")
    dbUser := os.Getenv("POSTGRES_USER")
    dbPassword := os.Getenv("POSTGRES_PASSWORD")
    dbName := os.Getenv("POSTGRES_DB")
    psqlInfo := fmt.Sprintf("host=%s user=%s password=%s dbname=%s sslmode=disable", dbHost, dbUser, dbPassword, dbName)
    var err error
    for i := 0; i < 5; i++ { /* ... retry logic ... */
        db, err = sql.Open("postgres", psqlInfo); if err == nil { if err = db.Ping(); err == nil { break } }
        log.Printf("Could not connect to DB: %v. Retrying...", err); time.Sleep(time.Second * 2)
    }
    if err != nil { log.Fatalf("Failed to connect to DB: %v", err) }
    defer db.Close()

    // --- Redis Connection ---
    rdb = redis.NewClient(&redis.Options{Addr: "redis:6379"})
    _, err = rdb.Ping(ctx).Result()
    if err != nil { log.Fatalf("Failed to connect to Redis: %v", err) }
    defer rdb.Close()
    log.Println("Successfully connected to Redis!")

    // --- Web Server ---
    r := mux.NewRouter()
    r.HandleFunc("/", indexHandlerWithRedis)
    r.HandleFunc("/init-db", initDbHandlerWithRedis)
    log.Println("Web server starting on port 5000...")
    log.Fatal(http.ListenAndServe(":5000", r))
}

func indexHandlerWithRedis(w http.ResponseWriter, r *http.Request) {
    visits, err := rdb.Incr(ctx, "visits").Result()
    if err != nil { http.Error(w, "Redis error", http.StatusInternalServerError); return }

    var message string
    err = db.QueryRow("SELECT message FROM greetings LIMIT 1").Scan(&message)
    if err != nil { message = "No greeting found." }
    
    fmt.Fprintf(w, "<h1>%s</h1><p>This page has been visited <strong>%d</strong> times.</p>", message, visits)
}

func initDbHandlerWithRedis(w http.ResponseWriter, r *http.Request) {
    // (same DB logic as before)
    db.Exec("DROP TABLE IF EXISTS greetings;"); db.Exec("CREATE TABLE greetings (id SERIAL PRIMARY KEY, message TEXT);")
    db.Exec("INSERT INTO greetings (message) VALUES ('Hello from Go, with visits tracked by Redis!');")
    
    // Reset Redis counter
    rdb.Set(ctx, "visits", 0, 0)
    fmt.Fprintln(w, "Database and Redis counter reset! Go back to <a href='/'>/</a>.")
}
EOF

cat <<'EOF' > module-07-docker-compose/03-go-db-redis/go.mod
module module07

go 1.19

require (
    github.com/gorilla/mux v1.8.0
    github.com/lib/pq v1.10.6
    github.com/go-redis/redis/v8 v8.11.5
)
EOF

# Copy Dockerfile from example 2
cp module-07-docker-compose/02-go-web-db/Dockerfile module-07-docker-compose/03-go-db-redis/Dockerfile

cat <<'EOF' > module-07-docker-compose/03-go-db-redis/docker-compose.yml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "5000:5000"
    environment:
      - DB_HOST=db
      - POSTGRES_DB=myappdb
      - POSTGRES_USER=myuser
      - POSTGRES_PASSWORD=mypassword
    depends_on:
      - db
      - redis

  db:
    image: postgres:13
    environment:
      - POSTGRES_DB=myappdb
      - POSTGRES_USER=myuser
      - POSTGRES_PASSWORD=mypassword
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:6-alpine

volumes:
  postgres_data:
EOF


echo "--- All done! Your module-07-docker-compose directory with Go is ready. ---"
