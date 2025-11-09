#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "--- Creating Module 05 Directory Structure ---"

# Create the main directory and subdirectories
mkdir -p module-05/01-volumes-example
mkdir -p module-05/02-bind-mount-example
mkdir -p module-05/03-database-persistence

echo "--- Populating files with content ---"

# Create the main README.md
cat <<EOF > module-05/README.md
# Day 5: Docker Volumes

## The Problem: Ephemeral Data
By default, containers are ephemeral. Any data written inside a container's filesystem is lost when the container is removed. This is a problem for stateful applications like databases or for storing user-uploaded content.

## The Solution: Data Persistence
Docker provides several ways to persist data beyond a container's lifetime. The two primary methods are:

1.  **Volumes:** The preferred, Docker-managed way. Docker creates and manages a special storage area on the host. Volumes are great for databases and other stateful services.
2.  **Bind Mounts:** A direct mapping from a file or directory on the host machine into the container. This is perfect for development, as you can edit code on your host and see changes reflected in the container in real-time.

---

## Example 1: Docker Volumes
This example demonstrates how to create a named volume and use it to persist data across two different containers.

**How to Run:**
\`\`\`bash
cd 01-volumes-example
chmod +x run.sh
./run.sh
\`\`\`
Follow the prompts in the script to see the data persist.

## Example 2: Bind Mounts with Caddy
This example shows how to use a bind mount for live code reloading. We'll run a Caddy web server and serve an HTML file directly from your host machine.

**How to Run:**
\`\`\`bash
cd 02-bind-mount-example
chmod +x run.sh
./run.sh
\`\`\`
Then, open http://localhost:8080 in your browser. Edit the \`index.html\` file on your host machine and refresh the page to see the changes instantly.

## Example 3: Database Persistence
This is the most common use case for volumes. We'll run a PostgreSQL database, add some data, destroy the container, and then recover the data by attaching a new container to the same volume.

**How to Run:**
\`\`\`bash
cd 03-database-persistence
chmod +x run.sh
./run.sh
\`\`\`
Follow the script to interact with the database and witness the recovery.
EOF

# Create the run.sh for volumes example
cat <<'EOF' > module-05/01-volumes-example/run.sh
#!/bin/bash

echo "--- Step 1: Creating a named volume ---"
docker volume create my-awesome-data

echo "--- Step 2: Running a container and creating data in the volume ---"
docker run -it --name volume-test-1 -v my-awesome-data:/app-data alpine sh -c "echo 'This data will survive!' > /app-data/persistent.txt && cat /app-data/persistent.txt"

echo "--- Step 3: Removing the container ---"
docker rm volume-test-1

echo "--- Step 4: Running a NEW container with the SAME volume ---"
echo "If the next command shows 'This data will survive!', it worked!"
docker run --rm -v my-awesome-data:/app-data alpine cat /app-data/persistent.txt

echo "--- Cleanup ---"
docker volume rm my-awesome-data
EOF

# Create the run.sh for bind mount example
cat <<'EOF' > module-05/02-bind-mount-example/run.sh
#!/bin/bash

# This script assumes it's run from the 02-bind-mount-example directory

echo "--- Creating a simple HTML file ---"
cat <<HTML > index.html
<!DOCTYPE html>
<html>
<head><title>Caddy Bind Mount</title></head>
<body>
  <h1>Hello from my Host Machine, served by Caddy!</h1>
  <p>Edit this file on your host and refresh the browser!</p>
</body>
</html>
HTML

echo "--- Running Caddy with a bind mount ---"
# The -v flag maps the current directory (.) on the host to /usr/share/caddy in the container
docker run -d -p 8080:80 --name my-caddy-server -v $(pwd):/usr/share/caddy caddy

echo "--- Caddy is running! Open http://localhost:8080 in your browser. ---"
echo "Press [CTRL+C] to stop this script and cleanup the container."

# Wait for the user to stop the script
trap 'echo "--- Stopping and removing Caddy container ---"; docker stop my-caddy-server && docker rm my-caddy-server; exit' INT
sleep infinity
EOF

# Create the index.html for bind mount example (it will be overwritten by run.sh, but good to have)
echo "<h1>Initial Caddy Content</h1>" > module-05/02-bind-mount-example/index.html

# Create the run.sh for database example
cat <<'EOF' > module-05/03-database-persistence/run.sh
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
EOF


echo "--- Making all run.sh scripts executable ---"
chmod +x module-05/01-volumes-example/run.sh
chmod +x module-05/02-bind-mount-example/run.sh
chmod +x module-05/03-database-persistence/run.sh

echo "--- All done! Your module-05 directory is ready. ---"

