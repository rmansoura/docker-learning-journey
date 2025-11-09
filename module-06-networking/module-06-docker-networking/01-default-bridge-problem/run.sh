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
