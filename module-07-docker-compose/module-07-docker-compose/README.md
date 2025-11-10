# Day 7: Docker Compose with Go

## The "Why": From Manual Commands to Elegant Code
So far, we've manually created networks, volumes, and containers. While this taught us the fundamentals, it's not practical for real-world applications. A modern application is a collection of services (web, database, cache, etc.), and managing them manually is complex and error-prone.

**Docker Compose is the solution.** It allows you to define your entire multi-container application in a single, easy-to-read YAML file. With one command (`docker-compose up`), you can build, create, and connect all the services your app needs.

This module automates everything you learned in Modules 5 (Volumes) and 6 (Networking), using the Go programming language for our web services.

## Why Go for Microservices?
Go is an excellent choice for building services to run in Docker:
*   **Single Binary:** Compiles to one static file with all dependencies included.
*   **Small Images:** Results in tiny, secure, and fast-downloading Docker images.
*   **High Performance:** Compiled language with low memory usage, perfect for microservices.

---

## Example 1: Hello World with Caddy
A simple introduction to the `docker-compose.yml` syntax using a single Caddy web server.

**How to Run:**
```bash
cd 01-hello-world
docker-compose up -d
# Open http://localhost:8080
docker-compose down
```

## Example 2: A Go Web App and a Database
This is the "Aha!" moment. We define a Go web application and a PostgreSQL database. Compose will build the Go app image, create a shared network, and set up a persistent volume for the database.

**How to Run:**
```bash
cd 02-go-web-db
docker-compose up --build -d
# Open http://localhost:5000 and visit /init-db to create a table
# Then visit / to see the message from the database
docker-compose down
```

## Example 3: Adding a Redis Cache
We expand on the previous example by adding a Redis caching service. This demonstrates how simple it is to add and connect new services to your stack.

**How to Run:**
```bash
cd 03-go-db-redis
docker-compose up --build -d
# Open http://localhost:5000 and refresh the page. The visit count will be cached in Redis.
docker-compose down
```
