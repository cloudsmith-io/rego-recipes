# Using Rego Recipes as an npm Package

This repository can be consumed as an npm package in JavaScript/TypeScript applications to power policy management UIs.

---

## Installation

```bash
npm install github:cloudsmith-io/rego-recipes
```

Specify a branch/tag/commit:

```bash
npm install github:cloudsmith-io/rego-recipes#main
npm install github:cloudsmith-io/rego-recipes#v1.0.0
```

---

## Usage

```typescript
import {
  baselineMalwareBlock,
  baselinePolicies,
  allPolicies,
} from '@cloudsmith/rego-recipes';

// Access individual policy
console.log(baselineMalwareBlock.content); // The raw .rego file content

// Use collections
baselinePolicies.forEach((policy) => {
  console.log(policy.name, policy.path, policy.content);
});
```

---

## Available Exports

### Individual Policies

**Baseline:**

- `baselineExactAllowlistExemption`
- `baselineExactBlocklist`
- `baselineHighRiskVulnerability`
- `baselineLicenseCompliance`
- `baselineMalwareBlock`
- `baselinePackageAgeQuarantine`
- `baselinePackageAgeRestore`

**Advanced:**

- `advancedHuggingfaceRecipesModelCard`
- `advancedHuggingfaceRecipesRiskyFiles`
- `advancedHuggingfaceRecipesSecurityScan`
- `advancedHuggingfaceRecipesTrustedPublishers`

**Legacy:**

- `legacyRecipe1Policy` through `legacyRecipe21Policy` (deprecated)

### Collections

- `baselinePolicies` - All baseline policies
- `advancedPolicies` - All advanced policies
- `legacyPolicies` - All legacy policies (deprecated)
- `allPolicies` - All policies

### Policy Interface

```typescript
interface Policy {
  id: string; // unique identifier (same as path)
  name: string; // filename without .rego extension
  path: string; // relative path from package root
  content: string; // raw .rego file content
}
```

---

## Development

```bash
npm run build  # Generate dist/index.js and dist/index.d.ts
```
