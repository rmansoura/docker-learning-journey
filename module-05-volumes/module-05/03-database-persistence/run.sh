#!/bin/bash

echo "--- Step 1: Running a PostgreSQL container with a volume ---"
docker run -d --name pg-db-1 -e POSTGRES_PASSWORD=mysecretpassword -v pgdata:/var/lib/postgresql/data postgres

echo "--- Waiting for database to start... ---"
sleep 10

echo "--- Step 2: Connecting and creating a table with data ---"
docker exec -it pg-db-1 psql -U postgres -c "CREATE TABLE users (id SERIAL PRIMARY KEY, username VARCHAR(50));"
docker exec -it pg-db-1 psql -U postgres -c "INSERT INTO users (username) VALUES ('rmansoura');"
echo "--- Data inserted. Listing users: ---"
docker exec -it pg-db-1 psql -U postgres -c "SELECT * FROM users;"

echo "--- Step 3: Simulating a disaster - removing the container ---"
docker stop pg-db-1
docker rm pg-db-1
echo "Container removed. The data should be safe in the 'pgdata' volume."

echo "--- Step 4: Recovering the data with a NEW container ---"
docker run -d --name pg-db-recovered -e POSTGRES_PASSWORD=mysecretpassword -v pgdata:/var/lib/postgresql/data postgres
echo "--- Waiting for recovered database to start... ---"
sleep 10

echo "--- Step 5: Verifying the data is still there! ---"
echo "If the next command shows the 'users' table with 'rmansoura', recovery was successful!"
docker exec -it pg-db-recovered psql -U postgres -c "SELECT * FROM users;"

echo "--- Cleanup ---"
docker stop pg-db-recovered
docker rm pg-db-recovered
docker volume rm pgdata
