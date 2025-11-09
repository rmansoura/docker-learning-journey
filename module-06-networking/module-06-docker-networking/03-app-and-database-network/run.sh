#!/bin/bash

echo "--- Step 1: Creating a network and a volume ---"
docker network create app-net
docker volume create pg-data

echo "--- Step 2: Running a PostgreSQL database on the network ---"
docker run -d --name my-db \
  --network app-net \
  -v pg-data:/var/lib/postgresql/data \
  -e POSTGRES_PASSWORD=mysecretpassword \
  postgres

echo "--- Waiting for database to initialize... ---"
sleep 15

echo "--- Step 3: Running a Caddy web server on the SAME network ---"
docker run -d -p 8080:80 --name my-web \
  --network app-net \
  caddy

echo "--- Step 4: Testing communication from the web container to the database container ---"
echo "Pinging 'my-db' by name from 'my-web' container..."
docker exec -it my-web ping -c 3 my-db && echo ">>> SUCCESS! Web container can reach the DB container. <<<"

echo "--- Inspecting the 'app-net' to see both containers listed ---"
docker network inspect app-net

echo "--- Cleaning up all resources ---"
docker stop my-web my-db
docker rm my-web my-db
docker network rm app-net
docker volume rm pg-data
