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
