# Style and linting

- Use https://www.openpolicyagent.org/docs/style-guide for style when modifying or creating recipes
- Use/suggest `opa fmt` when finished e.g. `opa fmt -w .`

# Policy METADATA

- All policies should include METADATA comments at the top of the file
- Place METADATA before the `package` declaration

## Format

```rego
# METADATA
# title: <Display Title>
# description: <Brief description of what the policy does>
package cloudsmith
```

## Guidelines

- `title`: Short, human-readable display name in sentence case (e.g., "Malware block")
- `description`: One-line summary of policy behavior (e.g., "Block packages with detected malware vulnerabilities (MAL- prefix)")
- Keep descriptions concise and action-oriented
- Follow OPA METADATA annotations format: https://www.openpolicyagent.org/docs/policy-language#metadata
