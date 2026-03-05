# Using Rego Recipes as an npm Package

This repository can be consumed as an npm package in JavaScript/TypeScript applications to power policy management UIs.

---

## Installation

Install directly from GitHub:

```bash
npm install github:cloudsmith-io/rego-recipes
```

Or with other package managers:

```bash
pnpm add github:cloudsmith-io/rego-recipes
yarn add github:cloudsmith-io/rego-recipes
```

Or specify a branch/tag/commit:

```bash
npm install github:cloudsmith-io/rego-recipes#main
npm install github:cloudsmith-io/rego-recipes#v1.0.0
npm install github:cloudsmith-io/rego-recipes#abc1234
```

---

## Usage

### Importing Policy Content in JavaScript/TypeScript

```typescript
import {
  baselineMalwareBlock,
  baselineHighRiskVulnerability,
  allPolicies,
} from '@cloudsmith/rego-recipes';

// Access individual policy
console.log(baselineMalwareBlock.name); // "malware-block"
console.log(baselineMalwareBlock.path); // "baseline/malware-block.rego"
console.log(baselineMalwareBlock.content); // The raw .rego file content

// Use in policy management UI
function displayPolicy(policy) {
  return {
    name: policy.name,
    path: policy.path,
    content: policy.content,
  };
}
```

### React Component Example

**PolicyList.tsx:**

```typescript
import { allPolicies } from '@cloudsmith/rego-recipes';

export default function PolicyList() {
  return (
    <div>
      <h1>Available Policies</h1>
      {allPolicies.map((policy) => (
        <div key={policy.name}>
          <h2>{policy.name}</h2>
          <p>Path: {policy.path}</p>
          <pre>{policy.content}</pre>
        </div>
      ))}
    </div>
  );
}
```

---

## Available Exports

All policy files from `baseline/`, `advanced/`, and `legacy/` directories are exported as named constants. Export names are generated from the full file path in camelCase to ensure uniqueness.

### Baseline Policies

- `baselineExactAllowlistExemption` - baseline/exact-allowlist-exemption.rego
- `baselineExactBlocklist` - baseline/exact-blocklist.rego
- `baselineHighRiskVulnerability` - baseline/high-risk-vulnerability.rego
- `baselineLicenseCompliance` - baseline/license-compliance.rego
- `baselineMalwareBlock` - baseline/malware-block.rego
- `baselinePackageAgeQuarantine` - baseline/package-age-quarantine.rego
- `baselinePackageAgeRestore` - baseline/package-age-restore.rego

### Advanced Policies

- `advancedHuggingfaceRecipesModelCard` - advanced/huggingface-recipes/model_card.rego
- `advancedHuggingfaceRecipesRiskyFiles` - advanced/huggingface-recipes/risky_files.rego
- `advancedHuggingfaceRecipesSecurityScan` - advanced/huggingface-recipes/security_scan.rego
- `advancedHuggingfaceRecipesTrustedPublishers` - advanced/huggingface-recipes/trusted_publishers.rego

### Legacy Policies

- `legacyRecipe1Policy` through `legacyRecipe21Policy` - legacy/recipe-\*/policy.rego
- **Note:** Legacy policies are deprecated and not recommended for new deployments

### Collections

- `allPolicies` - Array containing all 32 policies (baseline + advanced + legacy)

### Policy Object Structure

Each exported policy has the following TypeScript interface:

```typescript
interface Policy {
  /** The policy name (filename without .rego extension) */
  name: string;
  /** Relative path to the .rego file from package root */
  path: string;
  /** The raw .rego file content as a string */
  content: string;
}
```

---

## Development

### Building the Package

The package is automatically built on installation via the `prepare` script, but you can build it manually:

```bash
npm run build
```

This generates `dist/index.js` and `dist/index.d.ts` containing all policy exports.

### Testing Locally

To test the package in your application:

```bash
# In your project, install from local filesystem
npm install /path/to/local/rego-recipes

# Or use npm link
cd /path/to/rego-recipes
npm link

cd /path/to/your-app
npm link @cloudsmith/rego-recipes
```

### Linting & Validation

```bash
# Format check (OPA style guide)
npm run lint

# Validate policy syntax (checks each file individually)
npm run check
```

---

## Package Contents

When installed from GitHub, the package includes:

- `dist/` - Generated JavaScript exports with inlined .rego content (built automatically)
- `baseline/` - All baseline policy .rego files (source files)
- `advanced/` - All advanced policy .rego files (source files)
- `legacy/` - All legacy policy .rego files (source files, deprecated)
- `package.json` - Package metadata
- `NPM.md` - Package usage documentation

---

## TypeScript Support

The package includes TypeScript definitions in `dist/index.d.ts`. TypeScript users get full autocomplete and type checking:

```typescript
import { Policy, allPolicies } from '@cloudsmith/rego-recipes';

const policy: Policy = allPolicies[0];
// TypeScript knows: policy.name, policy.path, policy.content
```

---

## Troubleshooting

### Module not found

If you get module resolution errors:

1. Ensure the package is installed: `npm install github:cloudsmith-io/rego-recipes`
2. Restart your development server
3. Check that `package.json` lists the dependency

### Build errors

If the package fails to build on installation:

1. Ensure Node.js >= 18.0.0 is installed
2. Check that the `scripts/build.js` ran successfully
3. Verify `dist/` directory was created with `index.js` and `index.d.ts`

---

## Examples

### Filter Policies by Category

```typescript
import { allPolicies } from '@cloudsmith/rego-recipes';

// Get baseline policies
const baselinePolicies = allPolicies.filter((p) =>
  p.path.startsWith('baseline/'),
);

// Get HuggingFace-specific policies
const hfPolicies = allPolicies.filter((p) => p.path.includes('huggingface'));

// Get vulnerability-related policies
const vulnPolicies = allPolicies.filter(
  (p) => p.name.includes('vulnerability') || p.name.includes('malware'),
);
```

### Policy Selector Component

```typescript
import { allPolicies } from '@cloudsmith/rego-recipes';

export function PolicySelector({ onSelect }) {
  return (
    <select onChange={(e) => onSelect(allPolicies[e.target.value])}>
      {allPolicies.map((policy, index) => (
        <option key={policy.name} value={index}>
          {policy.name} ({policy.path})
        </option>
      ))}
    </select>
  );
}
```

### Policy Viewer Component

```typescript
import { useState } from 'react';
import { allPolicies } from '@cloudsmith/rego-recipes';

export function PolicyViewer() {
  const [selectedPolicy, setSelectedPolicy] = useState(allPolicies[0]);

  return (
    <div>
      <PolicySelector onSelect={setSelectedPolicy} />
      <div className="policy-details">
        <h2>{selectedPolicy.name}</h2>
        <p>File: {selectedPolicy.path}</p>
        <pre>
          <code>{selectedPolicy.content}</code>
        </pre>
      </div>
    </div>
  );
}
```
