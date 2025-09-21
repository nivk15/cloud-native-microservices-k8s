# Cloud-Native Microservices Application (Docker & Kubernetes)

A multi-service financial application that demonstrates **cloud-native microservices architecture** with Docker containerization and Kubernetes orchestration.  
Originally built as part of my Computer Science coursework and refined into a professional showcase of containerized, distributed application design.

---

## Overview
The application manages a simple stock portfolio and calculates capital gains.  
It consists of several containerized microservices running in a Kubernetes cluster, with persistence, scaling, and load balancing configured for high availability.

---

## Architecture
- **Stocks Service (3 replicas)** – REST API for managing stock data  
- **Capital-Gains Service** – calculates portfolio capital gains  
- **MongoDB** – database with persistent storage (PersistentVolumes)  
- **NGINX Reverse Proxy** – load balancing and routing between services  

<p align="center">
  <img src="architecture.png" alt="Architecture Diagram" width="600"/>
</p>

---

## Technologies
- **Docker** – containerization of all services  
- **Kubernetes** – orchestration with Deployments, Services, scaling, and PersistentVolumes  
- **NGINX** – reverse proxy for routing and load balancing  
- **MongoDB** – persistent storage for stock and portfolio data  

---

## Running the Project

### Prerequisites
- [Docker](https://www.docker.com/)  
- [Kind](https://kind.sigs.k8s.io/) (or [Minikube](https://minikube.sigs.k8s.io/))  
- [kubectl](https://kubernetes.io/docs/tasks/tools/)  
- [yq](https://mikefarah.gitbook.io/yq/) (YAML processor)  
- [curl](https://curl.se/)  

### Quick Start
From the project root:

```bash
# Run full setup + smoke test
./scripts/setup_and_smoke.sh
