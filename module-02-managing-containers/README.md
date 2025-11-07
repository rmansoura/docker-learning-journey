# module-02-managing-containers
# Module 2: Running and Managing Containers

## What I Learned
- How to run a container in detached mode using the `-d` flag.
- How to map ports from the host to the container using `-p <host>:<container>`.
- How to name a container with `--name` for easier management.
- The core lifecycle commands: `docker run`, `docker ps`, `docker stop`, `docker start`, `docker rm`.
- How to view a container's logs with `docker logs`.
- How to execute commands inside a running container with `docker exec -it <name> sh`.

## Commands I Used
- `docker pull caddy:latest`
- `docker run --name my-caddy-server -d -p 8080:80 caddy:latest`
- `docker ps` and `docker ps -a`
- `docker logs my-caddy-server`
- `docker stop my-caddy-server`
- `docker start my-caddy-server`
- `docker exec -it my-caddy-server sh`
- `docker rm my-caddy-server`

## Key Insight
Containers are ephemeral but manageable. I can start, stop, and inspect them easily. Getting a shell with `docker exec` is like SSHing into a lightweight VM, which is incredibly powerful for debugging.
