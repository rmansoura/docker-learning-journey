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
