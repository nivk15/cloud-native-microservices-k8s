# Cloud-Native Microservices App (Kubernetes + Docker)

A Kubernetes-deployed microservices system for managing a stock portfolio:
CRUD + live stock pricing + capital gains calculation. MongoDB provides persistence, and NGINX is a single entrypoint for routing.

## Services
- **stocks** (Flask, 2 replicas): portfolio CRUD + `/stock-value` + `/portfolio-value`
- **capital-gains** (Flask): calculates capital gains by calling the stocks service
- **mongo**: persistent storage using PV/PVC
- **nginx**: reverse proxy / routing to internal services

## Architecture
<p align="center">
  <img src="architecture.png" alt="Architecture Diagram" width="650"/>
</p>

## Highlights
- **Service discovery** via Kubernetes Services (DNS), not Pod IPs
- **Scaling**: `stocks` runs with 2 replicas behind a Service (load-balanced)
- **Persistence**: MongoDB uses PV/PVC so data survives Pod restarts
- **Single entrypoint**: NGINX routes requests by path

## Tech Stack
- Docker, Kubernetes (Deployments, Services, ConfigMaps, PV/PVC)
- Python (Flask)
- MongoDB
- NGINX

## Repo Structure
  cloud-computing-k8s-assignment/
  ├── multi-service-app/
  │ ├── namespace.yaml
  │ ├── stocks/
  │ │ ├── deployment.yaml
  │ │ ├── service.yaml
  │ │ └── app.py
  │ │ └── Dockerfile
  │ ├── capital-gains/
  │ │ ├── deployment.yaml
  │ │ ├── service.yaml
  │ │ └── app.py
  │ │ └── Dockerfile
  │ ├── database/
  │ │ ├── deployment.yaml
  │ │ ├── service.yaml
  │ │ ├── persistentVolume.yaml
  │ │ ├── persistentVolumeClaim.yaml
  │ ├── nginx/
  │ │ ├── deployment.yaml
  │ │ ├── service.yaml
  │ │ ├── configmap.yaml


## Running the project

### 1. Create the Kubernetes cluster and deploy all services
This script creates a local KIND cluster, builds the Docker images, and deploys all Kubernetes resources
(NGINX, stocks service, capital-gains service, MongoDB with PV/PVC).

```bash
bash test-submission.sh
```


### 2. Run end-to-end demo tests
This script validates the system end-to-end through the NGINX entry point (`localhost:80`):

- Verifies routing to `/stocks` and `/capital-gains`
- Demonstrates CRUD operations on the stocks API (create, read, update, delete)
- Calls `/stock-value/{id}` and `/portfolio-value`
- Calls `/capital-gains`
- Demonstrates persistence by restarting the MongoDB pod (data remains due to PV/PVC)
- Demonstrates resilience by deleting one stocks pod (Deployment recreates it)

**Note:** The demo script starts from a clean portfolio by deleting existing stocks via the API
(it does **not** recreate the cluster and does **not** delete the PV/PVC).

```bash
bash demo-tests-final.sh
