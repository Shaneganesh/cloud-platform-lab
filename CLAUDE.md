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
   GitHub→Azure OIDC federated identity   ✅ DONE
3. GitHub repo scaffold + structure + branch protection   ← CURRENT (repo
   created, pushed, and branch-protected already; folder structure/README
   still outstanding)
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
  - GitHub repo created (private, personal account Shaneganesh) and local repo
    pushed: https://github.com/Shaneganesh/cloud-platform-lab (remote `origin`,
    branch `main` tracking). This was pulled forward from Step 3 (just
    create+push) since OIDC federated credentials need the repo to exist first.
    Full Step 3 (repo structure, branch protection) still outstanding.
  - GitHub→Azure OIDC federated identity: DONE, via `terraform/bootstrap/oidc.tf`.
    IMPORTANT — the Media24 Azure AD tenant blocks self-service Azure AD app
    registration/service principal/federated-credential creation (403
    Authorization_RequestDenied; can't even delete an app you just registered —
    looks like an auto-applied Restricted Management Administrative Unit policy).
    Regular Azure RBAC roles (Contributor/Owner) do NOT grant Entra ID app-admin
    rights — separate permission systems. Worked around by using a **User-Assigned
    Managed Identity** (`azurerm_user_assigned_identity` +
    `azurerm_federated_identity_credential`, both pure Azure RBAC resources)
    instead of an Azure AD App Registration + Service Principal. Apply this same
    pattern for any future Azure AD identity needs in this tenant.
    Known leftover: one orphaned, unusable Azure AD app registration
    (display name `github-actions-cloud-platform-lab`, id
    `5d043a55-35df-4dd9-b0ac-7486da5cd348`) exists in the tenant, not tracked in
    Terraform state, cannot be deleted without tenant admin help. Harmless
    (no service principal, not referenced anywhere) — ignore or ask IT to
    clean up later.
- Step 2 status: ✅ DONE (RG imported, tfstate backend created, OIDC federated
  identity created via managed identity).
- Step 3 in progress:
  - Repo visibility changed private → PUBLIC. Reason: GitHub branch protection
    (both classic protection API and the newer Rulesets API) is gated behind
    GitHub Pro for private repos on personal accounts — 403 on both until the
    repo went public. Nothing sensitive is ever committed here (secrets stay
    out per .gitignore), and public also suits this repo's use as an interview
    portfolio piece.
  - Branch protection on `main` set via a Repository Ruleset (not classic
    protection): PR required before merging (0 approvals needed, since Shane
    is the sole contributor and can't approve his own PR), no force-push,
    no branch deletion, enforced for admins too (`current_user_can_bypass:
    never`). Created via `gh api --method POST .../rulesets` with a JSON
    payload (see chat history for exact JSON if recreating).
  - Remaining: repo folder structure / README (built as-needed per step,
    not pre-scaffolded).
- Working style note: Shane is learning Terraform for the first time and wants
  to type/edit .tf files himself — Claude presents file content/diffs in chat
  rather than writing them via tool calls. Copy/pasted content has repeatedly
  landed wrong (wrong directory, trailing dot in filename, whole chat messages
  pasted into files) — prefer giving a `cat > file << 'EOF' ... EOF` heredoc
  command over "paste this into your editor" instructions, since Shane runs it
  in the terminal himself and it can't go to the wrong file/location.

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
