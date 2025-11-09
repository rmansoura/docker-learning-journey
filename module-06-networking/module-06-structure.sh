#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "--- Creating Module 06 Directory Structure ---"

# Create the main directory and subdirectories
mkdir -p module-06-docker-networking/01-default-bridge-problem
mkdir -p module-06-docker-networking/02-user-defined-bridge-solution
mkdir -p module-06-docker-networking/03-app-and-database-network

echo "--- Populating files with content ---"

# Create the main README.md
cat <<EOF > module-06-docker-networking/README.md
# Day 6: Docker Networking

## The "Why": Communication is Key
Modern applications are not a single monolithic block; they are a system of collaborating services (a web front-end, an API back-end, a database, a cache, etc.). Docker excels at running each of these services in its own isolated container.

But an isolated system is a useless system. **This module is about teaching those containers to communicate.** We will learn how to create private, secure networks for our containers so they can discover and talk to each other by name. This is the foundational skill for building any real-world, multi-container application.

---

## Core Concepts

*   **Default Bridge Network:** A basic network that all containers join by default. It's functional for accessing the internet, but it lacks a key feature: automatic service discovery (containers can't find each other by name).
*   **User-Defined Bridge Network:** This is the solution. You create your own private network. Docker provides a built-in DNS server on this network, allowing containers to easily find each other using simple names (e.g., 'web-app' can talk to 'postgres-db').
*   **Service Discovery:** The "magic" of resolving a container's name (like \`my-db\`) to its internal IP address. This is handled automatically for you on user-defined networks.

### Understanding \`docker network inspect\`
The \`docker network inspect <network_name>\` command is your primary tool for debugging and understanding networks. It provides a detailed JSON output. The most critical section is \`"Containers"\`, which lists every container on the network, its name, and its assigned IP address. This is the mapping that Docker's internal DNS uses to enable service discovery.

---

## Example 1: The Problem with the Default Network
This example demonstrates that two containers on the default network cannot resolve each other's names.

**How to Run:**
\`\`\`bash
cd 01-default-bridge-problem
chmod +x run.sh
./run.sh
\`\`\`
You will see the \`ping\` command fail.

## Example 2: The Solution with a User-Defined Network
Here, we create our own network and attach containers to it. You will see that name resolution works perfectly.

**How to Run:**
\`\`\`bash
cd 02-user-defined-bridge-solution
chmod +x run.sh
./run.sh
\`\`\`
The \`ping\` command will succeed, proving service discovery is working.

## Example 3: Real-World App + Database on a Private Network
This is the capstone example. We combine networking with volumes. We'll launch a Caddy web server and a PostgreSQL database on the same private network, and then verify they can communicate.

**How to Run:**
\`\`\`bash
cd 03-app-and-database-network
chmod +x run.sh
./run.sh
\`\`\`
This demonstrates a complete, albeit simple, multi-container application setup.
EOF

# Create the run.sh for the default bridge problem
cat <<'EOF' > module-06-docker-networking/01-default-bridge-problem/run.sh
#!/bin/bash

echo "--- Running two containers on the default network ---"
docker run -d --name container-a alpine sleep 3600
docker run -d --name container-b alpine sleep 3600

echo "--- Attempting to ping 'container-b' from 'container-a' ---"
echo "This should fail because name resolution is not enabled on the default bridge."
docker exec -it container-a ping -c 3 container-b || echo ">>> FAILED as expected! <<<"

echo "--- Cleaning up containers ---"
docker stop container-a container-b
docker rm container-a container-b
EOF

# Create the run.sh for the user-defined solution
cat <<'EOF' > module-06-docker-networking/02-user-defined-bridge-solution/run.sh
#!/bin/bash

echo "--- Creating a user-defined network ---"
docker network create my-awesome-network

echo "--- Running two containers on our new network ---"
docker run -d --name container-c --network my-awesome-network alpine sleep 3600
docker run -d --name container-d --network my-awesome-network alpine sleep 3600

echo "--- Attempting to ping 'container-d' from 'container-c' ---"
echo "This should SUCCEED because of service discovery on the user-defined network."
docker exec -it container-c ping -c 3 container-d && echo ">>> SUCCESS as expected! <<<"

echo "--- Inspecting the network to see the container details ---"
docker network inspect my-awesome-network

echo "--- Cleaning up ---"
docker stop container-c container-d
docker rm container-c container-d
docker network rm my-awesome-network
EOF

# Create the run.sh for the app and database example
cat <<'EOF' > module-06-docker-networking/03-app-and-database-network/run.sh
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
EOF


echo "--- Making all run.sh scripts executable ---"
chmod +x module-06-docker-networking/01-default-bridge-problem/run.sh
chmod +x module-06-docker-networking/02-user-defined-bridge-solution/run.sh
chmod +x module-06-docker-networking/03-app-and-database-network/run.sh

echo "--- All done! Your module-06-docker-networking directory is ready. ---"


