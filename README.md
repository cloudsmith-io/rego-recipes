# Cloudsmith EPM Recipes

This repository contains curated, production-ready Open Policy Agent (OPA) policies for use with Cloudsmith Enterprise Policy Management (EPM).

The goal of this repository is to define a clear, recommended secure baseline for Cloudsmith workspaces, along with a smaller set of advanced governance patterns.

---

## Design Principles

All policies in this repository:

- Are WASM-compatible  
- Use only supported Cloudsmith EPM builtins  
- Avoid deprecated syntax (e.g. `import rego.v1`)  
- Follow OPA style guidelines  
- Are structured for composability using precedence  
- Are safe for production use  

These policies are intended to be readable, predictable, and suitable for enterprise environments.

---

## Repository Structure

```
baseline/
advanced/
legacy/
exemptions/
  allow.json
  update_policy.py
  templates/
    allowlist.rego.tpl
.github/workflows/
  opa-lint.yml
  apply-exemptions.yml
```

### baseline/

Recommended secure defaults for production environments.

These policies address common supply chain security requirements such as:

- Malware blocking  
- High-risk vulnerability control (CVSS / EPSS)  
- License compliance  
- Workflows using package age  
- Explicit allowlist and blocklist handling  

If you are deploying EPM in a new workspace, start here.

---

### advanced/

Optional or format-specific policies that provide deeper governance controls.

These may include:

- Base image origin enforcement  
- SBOM-based controls  
- Model governance policies  
- Specialized workflow patterns  

Advanced policies are production-ready but not universally required.

---

### legacy/

Historical recipes and experimental policies retained for reference.

Policies in this directory:

- May use older patterns  
- May not reflect current schema or best practices  
- Are not recommended for new deployments  

They are preserved for documentation history and migration reference.

---

## Policy Ordering & Precedence

Cloudsmith EPM evaluates policies in precedence order (lowest precedence runs first).

All policies in this repository are designed to be non-terminal and composable.

A recommended precedence pattern for baseline deployments is:

1. Package age restore (make eligible packages available again)
2. Package age quarantine (time-based quarantine)
3. License policy (tagging or governance)
4. High-risk vulnerability policy (quarantine based on thresholds)
5. Exact allowlist exemption (explicit override)
6. Exact blocklist (explicit deny)
7. Malware block (final quarantine safeguard)

All matched policy actions are applied within a single transaction.  
The package state visible to users reflects the final committed result.

For full EPM documentation, see:  
https://docs.cloudsmith.com/supply-chain-security/epm

---

## Managing Exemptions (GitOps Workflow)

The allowlist policy in `baseline/` supports a GitOps-based exemption workflow.
Rather than editing policies manually, exemptions are stored in Git, reviewed via
Pull Requests, and automatically applied to Cloudsmith on merge.

### How it works

1. Maintain an exemption list in the format `format:name:version`:

```json
[
  "python:requests:2.6.4",
  "npm:left-pad:1.3.0"
]
```

2. Open a Pull Request for security/DevOps review.
3. On merge, a CI step regenerates the allowlist Rego policy from the exemption list and uploads it to Cloudsmith via the API.

### Why this approach

EPM policies embed exemption data directly in Rego. Managing exemptions via Git provides auditability, an approval gate, rollback capability, and a scalable alternative to manual policy edits.

The allowlist exemption policy should be placed at a higher precedence than the vulnerability policy (position 5 in the recommended ordering above) so that explicitly approved packages bypass security enforcement.

---

## Deployment

Policies can be deployed using the Cloudsmith API or CLI.

Refer to the official documentation for EPM policy management and simulation:

https://docs.cloudsmith.com/supply-chain-security/epm

---

This repository is the single source of truth for:

- Policy templates
- Documentation examples
- Secure baseline recommendations
- Enterprise EPM enablement guidance

