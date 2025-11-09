# Day 6: Docker Networking

## The "Why": Communication is Key
Modern applications are not a single monolithic block; they are a system of collaborating services (a web front-end, an API back-end, a database, a cache, etc.). Docker excels at running each of these services in its own isolated container.

But an isolated system is a useless system. **This module is about teaching those containers to communicate.** We will learn how to create private, secure networks for our containers so they can discover and talk to each other by name. This is the foundational skill for building any real-world, multi-container application.

---

## Core Concepts

*   **Default Bridge Network:** A basic network that all containers join by default. It's functional for accessing the internet, but it lacks a key feature: automatic service discovery (containers can't find each other by name).
*   **User-Defined Bridge Network:** This is the solution. You create your own private network. Docker provides a built-in DNS server on this network, allowing containers to easily find each other using simple names (e.g., 'web-app' can talk to 'postgres-db').
*   **Service Discovery:** The "magic" of resolving a container's name (like `my-db`) to its internal IP address. This is handled automatically for you on user-defined networks.

### Understanding `docker network inspect`
The `docker network inspect <network_name>` command is your primary tool for debugging and understanding networks. It provides a detailed JSON output. The most critical section is `"Containers"`, which lists every container on the network, its name, and its assigned IP address. This is the mapping that Docker's internal DNS uses to enable service discovery.

---

## Example 1: The Problem with the Default Network
This example demonstrates that two containers on the default network cannot resolve each other's names.

**How to Run:**
```bash
cd 01-default-bridge-problem
chmod +x run.sh
./run.sh
```
You will see the `ping` command fail.

## Example 2: The Solution with a User-Defined Network
Here, we create our own network and attach containers to it. You will see that name resolution works perfectly.

**How to Run:**
```bash
cd 02-user-defined-bridge-solution
chmod +x run.sh
./run.sh
```
The `ping` command will succeed, proving service discovery is working.

## Example 3: Real-World App + Database on a Private Network
This is the capstone example. We combine networking with volumes. We'll launch a Caddy web server and a PostgreSQL database on the same private network, and then verify they can communicate.

**How to Run:**
```bash
cd 03-app-and-database-network
chmod +x run.sh
./run.sh
```
This demonstrates a complete, albeit simple, multi-container application setup.
