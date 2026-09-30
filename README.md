# Cloud Platform Lab

A from-scratch, multi-cloud DevOps lab built to practice cloud platform
engineering end to end: infrastructure as code, containerization,
orchestration, CI/CD, load testing, and observability. Azure first, with AWS
and GCP planned as repeat builds of the same target system.

## Target system

A small, high-traffic API simulating betting-style spiky load: writes
transaction/ledger rows to Postgres, containerized and deployed on AKS,
secrets managed in Key Vault, load-tested for high-concurrency bursts, and
fronted by observability (Prometheus/Grafana locally, Azure Monitor/Log
Analytics in the cloud).

## Status

Built incrementally, step by step — see the roadmap below for what's done.

- [x] Local toolchain (az, terraform, kubectl, gh, helm, k6, docker)
- [x] Azure auth, subscription, resource provider registration
- [x] Bootstrap: resource group, Terraform remote state, GitHub→Azure OIDC
      (via a user-assigned managed identity, not an Azure AD app registration)
- [ ] GitHub repo structure + branch protection (branch protection live;
      this file is part of finishing the structure piece)
- [ ] Terraform: VNet → ACR → AKS → outputs
- [ ] Containerize the app, push to ACR
- [ ] Deploy to AKS via Helm + ingress
- [ ] CI/CD: GitHub Actions build→push→deploy via OIDC, environments, approval gate
- [ ] Load simulation with k6 + HPA autoscaling
- [ ] Observability + break/fix drills under load
- [ ] Database migrations with real rollback (expand-contract pattern)

## Repository structure

```
terraform/
  bootstrap/   # one-time setup: resource group import, Terraform remote-state
               # backend, GitHub OIDC identity. Runs with local state (chicken-
               # and-egg: it creates the remote backend everything else uses).
```

More folders (application code, additional Terraform, `.github/workflows/`)
are added as the roadmap reaches those steps, rather than pre-scaffolded.

## Notes

Solo, hands-on build — infrastructure is written and applied manually to
practice the tooling, not generated wholesale. Docs habit: an ADR per
significant decision and a runbook per operable thing are planned as the
build reaches operational maturity.
