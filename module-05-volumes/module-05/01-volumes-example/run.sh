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
