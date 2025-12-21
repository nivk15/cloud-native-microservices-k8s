# Cloud-Native Stock Portfolio System
A cloud-native microservices application deployed on Kubernetes.
The system manages a stock portfolio with full CRUD support, real-time stock pricing,
and capital gains calculation. It uses MongoDB for persistent storage and NGINX
as a single entry point for request routing.

## Services
- **stocks** (Flask, 2 replicas): portfolio CRUD + `/stock-value` + `/portfolio-value`
- **stocks** (Flask): service exposing portfolio CRUD and value endpoints ( /stocks , /stock-value , /portfolio-value ), with 2 replicas

- **capital-gains** (Flask): calculates capital gains by calling the stocks service ( /capital-gains )
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

```text
multi-service-app/
├── namespace.yaml
├── stocks/
│   ├── app.py
│   ├── Dockerfile
│   ├── deployment.yaml
│   └── service.yaml
├── capital-gains/
│   ├── app.py
│   ├── Dockerfile
│   ├── deployment.yaml
│   └── service.yaml
├── database/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── persistentVolume.yaml
│   └── persistentVolumeClaim.yaml
└── nginx/
    ├── deployment.yaml
    ├── service.yaml
    └── configmap.yaml
```


## Running and Testing

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
