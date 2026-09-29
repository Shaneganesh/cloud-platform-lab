# Cloud Platform Lab — Personal Practice Build

A from-scratch, multi-cloud DevOps lab to practice cloud platform engineering
end to end. **Azure first**, then AWS and GCP. Built entirely by Shane —
Claude guides, Claude does not build it for him.

## Working agreement (READ FIRST — do not violate)
- **One command at a time.** Give a single command, or one small file skeleton,
  then wait for output, verify it, and only then proceed. Never batch steps.
- **No auto-fill.** Do NOT invent or fill in names, resource IDs, regions,
  CIDRs, SKUs, or config values. Explain what each value is and why it matters,
  then let Shane choose and type it. Blanks in file skeletons are intentional.
- **Verify before proceeding.** Check the pasted output of each step before the next.
- **CLI/terminal-first.** Prefer `az` / `terraform` / `kubectl` / `gh` over portal clicks.
- **Concise.** No backstory or filler. Teach the *why* — this is for learning and interviews.

## Environment
- MacBook Air M1 (corporate-managed, MDM restrictions).
- VS Code + Claude Code CLI. Docker Desktop installed. colima available.
- Azure: Visual Studio Professional subscription (~$50/month credit — treat as scarce).
- Access to GitHub and Azure DevOps (ADO).
- Azure certs held: AZ-900, AZ-104, AZ-400, AZ-305 — assume solid Azure fundamentals.

## Cost discipline
- Local-first: kind/colima, Docker, Prometheus/Grafana are free — do most work there.
- Spend credit only on periodic end-to-end runs (AKS + ACR + Key Vault + Postgres Flex + Monitor).
- Tear down every session: smallest single node, `az aks stop` or `terraform destroy`,
  Postgres on Burstable B1ms stopped when idle. Check spend with `az consumption`.

## Target system
One small high-traffic service (betting-style spiky load): an API writing
transaction/ledger rows to Postgres, containerized, on AKS, secrets in Key Vault,
load-tested for high-concurrency bursts, fronted by observability.

## Roadmap (Azure first)
0. Local toolchain — az, terraform, kubectl, gh, helm, k6, docker   ✅ DONE
1. Azure auth + subscription + provider registration   ✅ DONE
2. Bootstrap — resource group, Terraform remote state (storage account + container),
   GitHub→Azure OIDC federated identity   ← CURRENT
3. GitHub repo scaffold + structure + branch protection
4. Terraform: VNet → ACR → AKS (Free-tier control plane, small node) → outputs
5. Containerize app (multi-stage Dockerfile) → push to ACR
6. Deploy to AKS (Helm) + ingress
7. CI/CD: GitHub Actions build→push→deploy via OIDC, environments, approval gate
   (mirror in ADO later)
8. Load sim — k6 spiky betting-style traffic (event-kickoff spikes, high concurrency)
   + HPA autoscaling
9. Observability + break/fix drills under load (Prometheus/Grafana/Alertmanager local;
   Container Insights + Log Analytics / KQL in Azure)
10. DB migrations with real rollback (forward + down as a gated CI stage; deliberately
    break one; practice expand-contract)
- Later: repeat the foundation on AWS (EKS) and GCP (GKE).
- Throughout: docs habit — ADR per decision, runbook per operable thing,
  incident write-up per break/fix drill.

## Current status
- Step 0 (local toolchain) complete — all tools present (brew, az, terraform, kubectl, docker,
  gh, helm, k6, colima).
- Logged into Azure already (`az account show` confirmed) — subscription
  "Visual Studio Pro - Shane Ganesh", tenant Media24 Head Office.
- Step 1 complete — all required resource providers confirmed Registered:
  Microsoft.ContainerService, Microsoft.ContainerRegistry, Microsoft.KeyVault,
  Microsoft.DBforPostgreSQL, Microsoft.Storage, Microsoft.Insights.
- Step 2 in progress:
  - Resource group `rg-cloud-platform-lab` (southafricanorth) created via az cli,
    then imported into Terraform state (`terraform/bootstrap/`).
  - Terraform remote-state backend created via Terraform (local state, one-time):
    storage account `stcloudplatformlab` (Standard_LRS, TLS1.2 min, no anonymous
    blob access, public network access enabled for own-identity access) + blob
    container `tfstate` (private). This bootstrap config stays on local state
    permanently; all future Terraform configs use remote state pointed at this
    storage account.
  - Remaining: GitHub→Azure OIDC federated identity.
- Working style note: Shane is learning Terraform for the first time and wants
  to type/edit .tf files himself — Claude presents file content/diffs in chat
  rather than writing them via tool calls.

## Repo structure
Build it as we go, per step — do not pre-create empty scaffolding.

## Session state (handoff from chat)
- Repo now lives at ~/practice-labs/cloud-platform-lab — moved OUT of OneDrive
  (was ~/Library/CloudStorage/OneDrive-Media24HeadOffice/src/cloud-platform-lab).
  Reason: OneDrive sync risked corrupting rapidly-changing files (.terraform state,
  kubeconfig, Docker artifacts) and would have synced secrets/tfstate to corporate cloud.
  git + GitHub (personal account) is now the sole portability/sync layer for this repo.
- `~/practice-labs` is the new parent folder for ALL personal projects (not just this one).
  Six other personal folders were moved there too from the OneDrive `src` folder: AWS,
  Github - lab, Github Actions Labs, Terraform Virtual machine, cloud-native-platform,
  infra-assessment-Azure. More may be moved in later as identified.
- VS Code multi-root workspace created at ~/all-projects.code-workspace, listing both
  the OneDrive `src` folder (Media24 work) and `~/practice-labs` (personal) as separate
  roots in one window — each keeps its own independent git history.
- Done: git init, .gitignore created, first commit made (.gitignore + CLAUDE.md).
- Done: Step 0 tool inventory — all tools present, none needed installing except
  helm and k6, both now installed via brew.
- Done: confirmed Azure login via `az account show` — correct subscription active.
- Next: Step 1 — check/register Azure resource providers, then continue roadmap from there.
- IMPORTANT: if starting a fresh Claude Code session, launch it from
  ~/practice-labs/cloud-platform-lab (not the old OneDrive path, which no longer exists).
