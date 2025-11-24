# Development Guild

This document outlines the development practices and guidelines for the Test DevOps application. It covers environment
setup, deployment strategies, and testing procedures to ensure a smooth development workflow.

## Development Environment Setup

- **Docker**: Ensure Docker is installed and running.
- **Kubernetes**: Set up a local Kubernetes cluster using Minikube or Kind.
- **Helm**: Install Helm for managing Kubernetes applications.
- **Kubectl**: Configure kubectl to interact with your Kubernetes cluster.
- **Datadog Agent**: Set up Datadog Agent for monitoring application metrics and logs.

# Build image

```bash
  make build
```

# Run compose localhost

Prerequisites

- *.env* file with the following variables set
  DD_API_KEY=your_datadog_api_key

start the application with datadog agent in docker compose

```bash
make run-compose-localhost
```

stop the application with datadog agent in docker compose

```bash
make stop-compose-localhost
```