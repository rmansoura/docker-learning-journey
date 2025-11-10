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
