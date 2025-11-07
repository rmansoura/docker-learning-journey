# module-01-installation
# Module 1: Installation and First Container

## What I Learned
- Docker is a platform for containerizing applications.
- Containers are lightweight and share the host OS kernel, unlike VMs.
- Key concepts: Images (templates) and Containers (running instances).
- Docker Hub is the default registry for images.

## Commands I Used
- `curl -fsSL https://get.docker.com -o get-docker.sh`: Downloaded the Docker installation script.
- `sudo sh get-docker.sh`: Executed the installation script.
- `sudo usermod -aG docker ${USER}`: Added my user to the docker group to avoid using sudo.
- `docker run hello-world`: Ran my first container to verify the installation.

## Verification
The `hello-world` container ran successfully, outputting a welcome message from Docker. This confirms the Docker Engine is installed and running correctly on my Linux Mint system.

