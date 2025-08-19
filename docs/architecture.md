# 🏗️ Architecture camps.ch

## Vue d'Ensemble

L'infrastructure camps.ch est basée sur Kubernetes managed par Infomaniak, avec une approche Infrastructure as Code utilisant Terraform et Helm.

## Composants Principaux

### Infrastructure
- **Provider**: Infomaniak Managed Kubernetes
- **Nodes**: 1x a1-ram-4 (4 vCPU, 8GB RAM) Phase 1
- **Storage**: Longhorn distributed storage (100GB)
- **Network**: Nginx Ingress + LoadBalancer Infomaniak

### Applications
- **Prometheus + Grafana**: Monitoring et métriques

### Sécurité
- **SSL**: cert-manager + Let's Encrypt automatique
- **Secrets**: Kubernetes secrets + GitLab Registry
- **Network**: Ingress avec DDoS protection Infomaniak

## Schéma Architecture

```
Internet
    │
    ▼
┌─────────────────┐
│   Cloudflare    │ (DNS + Proxy)
│   camps.ch      │
└─────────┬───────┘
          │
          ▼
┌─────────────────┐
│ Infomaniak LB   │ (LoadBalancer + DDoS)
│ + SSL Termination│
└─────────┬───────┘
          │
          ▼
┌─────────────────┐
│ Nginx Ingress   │ (Routing + SSL)
│   Controller    │
└─────────┬───────┘
          │
    ┌─────┴─────┐
    ▼           ▼
┌─────────┐ ┌─────────┐
│Monitoring│ │Monitoring│
│ Grafana │ │Prometheus│
└─────────┘ └─────────┘
```

## Namespaces

- `production`: Applications production
- `monitoring`: Prometheus + Grafana
- `longhorn-system`: Storage distribué
- `ingress-nginx`: Load balancer
- `cert-manager`: Gestion SSL

## Scaling Strategy

### Phase 1 (Actuel)
- 1 node shared prod/uat
- Longhorn 2 replicas
- Basic monitoring

### Phase 2 (Évolution)
- Clusters séparés prod/uat
- 3 nodes production (HA)
- Multi-AZ deployment
- Backup automatique S3

## Sécurité

### Actuelle
- SSL automatique Let's Encrypt
- Secrets Kubernetes
- Network isolation par namespace
- Container registry privé GitLab

### Future (Phase 2)
- External Secrets + Vault
- Network Policies
- Pod Security Standards
- Audit logging
- RBAC granulaire

## Monitoring

### Métriques Collectées
- Infrastructure: CPU, RAM, Disk, Network
- Applications: Response time, error rate, throughput
- Business: User connections, database queries

### Dashboards Grafana
- Kubernetes Cluster Overview
- Application Performance
- Database Metrics
- Ingress Controller

### Alerting
- Pod crashloop/restart
- High CPU/Memory usage
- Database connection issues
- SSL certificate expiration

## Backup Strategy

### Current
- Longhorn snapshots manuels
- Database dumps périodiques

### Future
- Automated Longhorn backup vers S3
- Point-in-time recovery PostgreSQL
- Cross-region replication
- Disaster recovery testing

## Performance

### Actuel
- Response time: < 200ms (90th percentile)
- Uptime: 99.5%
- Concurrent users: 100+

### Targets Phase 2
- Response time: < 100ms (95th percentile)
- Uptime: 99.9%
- Concurrent users: 1000+
- Auto-scaling workloads
