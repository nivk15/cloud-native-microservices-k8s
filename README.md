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