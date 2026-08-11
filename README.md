# Cloudsmith policy as code recipes

This repository contains curated, production-ready Open Policy Agent (OPA) policies for use with Cloudsmith policy as code.

The goal of this repository is to define a clear, recommended secure baseline for Cloudsmith workspaces, along with a smaller set of advanced governance patterns.

---

## Design Principles

All policies in this repository:

- Are WASM-compatible  
- Use only supported Cloudsmith policy as code builtins  
- Avoid deprecated syntax (e.g. `import rego.v1`)  
- Follow OPA style guidelines  
- Are structured for composability using precedence  
- Are safe for production use  

These policies are intended to be readable, predictable, and suitable for enterprise environments.

---

## Repository Structure

```
recipes/
  date-time/
  format-name-version/
  hugging-face/
  license/
  metadata/
  vulnerability/
templates/
tests/
exemptions/
  allow.json
  update_policy.py
  templates/
    allowlist.rego.tpl
.github/workflows/
  opa-lint.yml
  apply-exemptions.yml
```

### recipes/

All Rego policies grouped by category:

- `date-time/` — cooldown windows and change freezes, based on publish and upload dates
- `format-name-version/` — allowlists, blocklists, minimum versions, filename conventions
- `hugging-face/` — model cards, risky file formats, security scan results, verified publishers
- `license/` — declared licenses and SBOM component licenses
- `metadata/` — architectures and tags
- `vulnerability/` — CVSS and EPSS scores, vulnerability ID blocklists, malware

---

### templates/

The subset of recipes that appear as templates in the Cloudsmith web app. Each entry is
a symlink to a file under `recipes/`.

These policies address common supply chain security requirements such as:

- Malware blocking  
- High-risk vulnerability control (CVSS / EPSS)  
- License compliance  
- Workflows using package age  
- Explicit allowlist and blocklist handling  

---

### tests/

Unit tests mirroring `recipes/`, so `tests/license/copyleft_licenses_test.rego` covers
`recipes/license/copyleft_licenses.rego`.

All policies use `package cloudsmith` and so cannot be compiled together. Run one policy
against its test:

```bash
opa test recipes/license/copyleft_licenses.rego tests/license/copyleft_licenses_test.rego
```

CI does the same thing for every test file, deriving the policy path from the test path,
which means a test only runs if a policy exists at the matching path. It also runs
`regal lint`, `opa fmt --fail` and `opa check` over both directories.

---

### exemptions/

A GitOps workflow for managing policy exemptions.

Rather than editing policies manually, exemptions are stored in `allow.json`, reviewed via pull requests, and automatically applied to Cloudsmith by GitHub Actions when changes are pushed to `main`.

See the [Managing Exemptions](#managing-exemptions-gitops-workflow) section for details.

---

## Policy ordering and precedence

Cloudsmith policy as code evaluates policies in precedence order (lowest precedence runs first).

All policies in this repository are designed to be non-terminal and composable.

A recommended precedence pattern for baseline deployments is:

1. Cooldown period (time-based quarantine)
2. License policy (tagging or governance)
3. High-risk vulnerability policy (quarantine based on thresholds)
4. Exact allowlist exemption (explicit override)
5. Exact blocklist (explicit deny)
6. Malware block (final quarantine safeguard)

All matched policy actions are applied within a single transaction.  
The package state visible to users reflects the final committed result.

For full policy as code documentation, see:  
https://docs.cloudsmith.com/supply-chain-security/epm

---

## Managing exemptions (GitOps workflow)

The allowlist policy in `templates/` supports a GitOps-based exemption workflow.
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

Policy as code embeds exemption data directly in Rego. Managing exemptions via Git provides auditability, an approval gate, rollback capability, and a scalable alternative to manual policy edits.

The allowlist exemption policy should be placed at a higher precedence than the vulnerability policy (position 4 in the recommended ordering above) so that explicitly approved packages bypass security enforcement.

---

## Deployment

Policies can be deployed using the Cloudsmith webapp, API and the Cloudsmith Terraform Provider. 

For additional information, visit our user documentation. 

https://docs.cloudsmith.com/supply-chain-security/epm

---

This repository is the single source of truth for:

- Policy templates
- Documentation examples
- Secure baseline recommendations


