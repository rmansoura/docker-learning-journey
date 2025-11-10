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
