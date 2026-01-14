#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const rootDir = path.join(__dirname, '..');
const manifestPath = path.join(rootDir, 'manifest.json');
const packageJsonPath = path.join(rootDir, 'package.json');

// Read package.json for version
const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));

// Recursively find all .rego files
function findRegoFiles(dir, baseDir = dir) {
  const results = [];
  const entries = fs.readdirSync(dir, { withFileTypes: true });

  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);

    if (entry.isDirectory()) {
      if (['node_modules', '.git', '.husky', 'scripts'].includes(entry.name)) {
        continue;
      }
      results.push(...findRegoFiles(fullPath, baseDir));
    } else if (entry.name.endsWith('.rego')) {
      const relativePath = path.relative(baseDir, fullPath);
      results.push(relativePath);
    }
  }

  return results;
}

const regoFiles = findRegoFiles(rootDir);

// Sort files: recipe-N numerically first, then huggingface-recipes alphabetically
const sortedRegoFiles = regoFiles.sort((a, b) => {
  const aFolder = a.split(path.sep)[0];
  const bFolder = b.split(path.sep)[0];

  const aIsRecipe = aFolder.startsWith('recipe-');
  const bIsRecipe = bFolder.startsWith('recipe-');

  // Both are recipe-N: sort numerically by N
  if (aIsRecipe && bIsRecipe) {
    const aNum = parseInt(aFolder.split('-')[1]);
    const bNum = parseInt(bFolder.split('-')[1]);
    return aNum - bNum;
  }

  // Recipe comes before huggingface
  if (aIsRecipe && !bIsRecipe) return -1;
  if (!aIsRecipe && bIsRecipe) return 1;

  // Both are huggingface: sort alphabetically
  return a.localeCompare(b);
});

// Helper to load metadata
function loadMetadata(file) {
  const parts = file.split(path.sep);
  const folder = parts[0];
  const fileName = path.parse(file).name;

  // For recipe-N directories, look for metadata.json in that directory
  if (folder.startsWith('recipe-')) {
    const metadataPath = path.join(rootDir, folder, 'metadata.json');
    if (fs.existsSync(metadataPath)) {
      return JSON.parse(fs.readFileSync(metadataPath, 'utf8'));
    }
  }

  // For huggingface-recipes, look for folder/metadata.json with keys per file
  if (folder === 'huggingface-recipes') {
    const metadataPath = path.join(rootDir, folder, 'metadata.json');
    if (fs.existsSync(metadataPath)) {
      const allMetadata = JSON.parse(fs.readFileSync(metadataPath, 'utf8'));
      return allMetadata[fileName] || {};
    }
  }

  return {};
}

// Build manifest
const recipes = sortedRegoFiles.map((file) => {
  const parsedPath = path.parse(file);
  const id = file.replace('.rego', '').replace(/\\/g, '/');
  const exportKey = `./${id}`;

  const parts = file.split(path.sep);
  const folder = parts[0];
  const fileName = parsedPath.name;

  // Read the .rego file contents
  const fullPath = path.join(rootDir, file);
  const code = fs.readFileSync(fullPath, 'utf8');

  // Load metadata if available
  const metadata = loadMetadata(file);

  return {
    id: id,
    name: metadata.name || fileName.replace(/_/g, ' ').replace(/-/g, ' '),
    path: `./${file.replace(/\\/g, '/')}`,
    export: exportKey,
    code: code,
    ...metadata, // Spread any additional metadata fields
  };
});

const manifest = {
  version: packageJson.version,
  generatedAt: new Date().toISOString(),
  totalRecipes: recipes.length,
  recipes: recipes,
};

// Write manifest JSON
fs.writeFileSync(manifestPath, JSON.stringify(manifest, null, 2) + '\n');

console.log(`✓ Generated manifest with ${recipes.length} recipes`);
