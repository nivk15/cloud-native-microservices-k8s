# Cloud-Native Microservices Application (Docker & Kubernetes)

A multi-service financial application that demonstrates **cloud-native microservices architecture** with Docker containerization and Kubernetes orchestration.  
This project was implemented as part of my Computer Science coursework and refined to serve as a professional showcase of containerized, distributed application design.

---

##  Overview
The application manages a simple stock portfolio and capital gains calculation.  
It is built from several containerized microservices that communicate over a Kubernetes cluster, with persistence, scaling, and load balancing configured for high availability.

---

##  Architecture
- **Stocks Service (3 replicas)** – REST API for managing stock data  
- **Capital-Gains Service** – calculates portfolio capital gains  
- **MongoDB** – database with persistent storage (PersistentVolumes)  
- **NGINX Reverse Proxy** – load balancing and routing between services  

<p align="center">
  <img src="architecture.png" alt="Architecture Diagram" width="600"/>
</p>

---

##  Tech Highlights
- **Docker** – containerization of all services  
- **Kubernetes** – orchestration with Deployments, Services, scaling, and PersistentVolumes  
- **NGINX** – reverse proxy for routing and load balancing  
- **MongoDB** – persistent storage for stock and portfolio data  

---

## ⚙️ How to Run

### Prerequisites
- [Docker](https://www.docker.com/)  
- [Kind](https://kind.sigs.k8s.io/) or [Minikube](https://minikube.sigs.k8s.io/)  
- [kubectl](https://kubernetes.io/docs/tasks/tools/)  

### Setup
```bash
# Create Kubernetes cluster with kind
kind create cluster --config kind-config.yaml

# Apply namespace
kubectl apply -f namespace.yaml

# Deploy all services
kubectl apply -f .


