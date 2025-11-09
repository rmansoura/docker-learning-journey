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
```bash
cd 01-volumes-example
chmod +x run.sh
./run.sh
```
Follow the prompts in the script to see the data persist.

## Example 2: Bind Mounts with Caddy
This example shows how to use a bind mount for live code reloading. We'll run a Caddy web server and serve an HTML file directly from your host machine.

**How to Run:**
```bash
cd 02-bind-mount-example
chmod +x run.sh
./run.sh
```
Then, open http://localhost:8080 in your browser. Edit the `index.html` file on your host machine and refresh the page to see the changes instantly.

## Example 3: Database Persistence
This is the most common use case for volumes. We'll run a PostgreSQL database, add some data, destroy the container, and then recover the data by attaching a new container to the same volume.

**How to Run:**
```bash
cd 03-database-persistence
chmod +x run.sh
./run.sh
```
Follow the script to interact with the database and witness the recovery.
