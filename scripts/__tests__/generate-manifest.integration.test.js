// @ts-nocheck
const fs = require('fs');
const path = require('path');

describe('Manifest Generation Integration Tests', () => {
  let manifest;
  let packageJson;

  beforeAll(() => {
    // Load the actual manifest and package.json
    manifest = JSON.parse(
      fs.readFileSync(path.join(__dirname, '../../manifest.json'), 'utf8')
    );
    packageJson = JSON.parse(
      fs.readFileSync(path.join(__dirname, '../../package.json'), 'utf8')
    );
  });

  describe('Basic Structure', () => {
    it('should have valid JSON structure', () => {
      expect(manifest).toBeDefined();
      expect(typeof manifest).toBe('object');
    });

    it('should have all required top-level fields', () => {
      expect(manifest).toHaveProperty('version');
      expect(manifest).toHaveProperty('generatedAt');
      expect(manifest).toHaveProperty('totalRecipes');
      expect(manifest).toHaveProperty('recipes');
    });

    it('should have version matching package.json', () => {
      expect(manifest.version).toBe(packageJson.version);
    });

    it('should have valid ISO 8601 timestamp', () => {
      expect(manifest.generatedAt).toMatch(
        /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$/
      );
      const date = new Date(manifest.generatedAt);
      expect(date.toString()).not.toBe('Invalid Date');
    });

    it('should have correct recipe count', () => {
      expect(manifest.totalRecipes).toBe(manifest.recipes.length);
      expect(manifest.recipes.length).toBeGreaterThan(0);
    });
  });

  describe('Recipe Structure', () => {
    it('should have all recipes with required fields', () => {
      manifest.recipes.forEach((recipe) => {
        expect(recipe).toHaveProperty('id');
        expect(recipe).toHaveProperty('name');
        expect(recipe).toHaveProperty('path');
        expect(recipe).toHaveProperty('export');
        expect(recipe).toHaveProperty('code');

        expect(typeof recipe.id).toBe('string');
        expect(typeof recipe.name).toBe('string');
        expect(typeof recipe.path).toBe('string');
        expect(typeof recipe.export).toBe('string');
        expect(typeof recipe.code).toBe('string');
      });
    });

    it('should have non-empty code for all recipes', () => {
      manifest.recipes.forEach((recipe) => {
        expect(recipe.code.trim().length).toBeGreaterThan(0);
      });
    });

    it('should have valid recipe paths pointing to real files', () => {
      manifest.recipes.forEach((recipe) => {
        const filePath = path.join(__dirname, '../..', recipe.path);
        expect(fs.existsSync(filePath)).toBe(true);
      });
    });

    it('should have export keys matching convention', () => {
      manifest.recipes.forEach((recipe) => {
        expect(recipe.export).toBe(`./${recipe.id}`);
        expect(recipe.export).toMatch(/^\.\//);
      });
    });

    it('should have no duplicate recipe IDs', () => {
      const ids = manifest.recipes.map((r) => r.id);
      const uniqueIds = new Set(ids);
      expect(uniqueIds.size).toBe(ids.length);
    });
  });

  describe('Recipe Ordering', () => {
    it('should sort recipe-N folders numerically', () => {
      const recipeNIds = manifest.recipes
        .filter((r) => r.id.startsWith('recipe-'))
        .map((r) => r.id);

      for (let i = 1; i < recipeNIds.length; i++) {
        const prevNum = parseInt(recipeNIds[i - 1].split('/')[0].split('-')[1]);
        const currNum = parseInt(recipeNIds[i].split('/')[0].split('-')[1]);
        expect(currNum).toBeGreaterThan(prevNum);
      }
    });

    it('should place recipe-N folders before other folders', () => {
      const firstNonRecipe = manifest.recipes.findIndex(
        (r) => !r.id.startsWith('recipe-')
      );

      if (firstNonRecipe !== -1) {
        // All recipes before firstNonRecipe should start with 'recipe-'
        for (let i = 0; i < firstNonRecipe; i++) {
          expect(manifest.recipes[i].id).toMatch(/^recipe-\d+\//);
        }
      }
    });

    it('should sort non-recipe folders alphabetically', () => {
      const nonRecipeIds = manifest.recipes
        .filter((r) => !r.id.startsWith('recipe-'))
        .map((r) => r.id.split('/')[0]);

      const uniqueFolders = [...new Set(nonRecipeIds)];
      const sortedFolders = [...uniqueFolders].sort();
      expect(uniqueFolders).toEqual(sortedFolders);
    });
  });

  describe('Real Recipe Content', () => {
    it('should have recipe-1 with correct metadata', () => {
      const recipe1 = manifest.recipes.find((r) => r.id === 'recipe-1/policy');
      expect(recipe1).toBeDefined();
      expect(recipe1.name).toBeTruthy();
      expect(recipe1.code).toContain('package');
    });

    it('should have huggingface-recipes if they exist', () => {
      const hfRecipes = manifest.recipes.filter((r) =>
        r.id.startsWith('huggingface-recipes/')
      );

      if (hfRecipes.length > 0) {
        hfRecipes.forEach((recipe) => {
          expect(recipe.name).toBeTruthy();
          expect(recipe.code).toContain('package');
        });
      }
    });

    it('should have code content matching actual files', () => {
      // Sample check on first recipe
      const firstRecipe = manifest.recipes[0];
      const filePath = path.join(__dirname, '../..', firstRecipe.path);
      const actualCode = fs.readFileSync(filePath, 'utf8');
      expect(firstRecipe.code).toBe(actualCode);
    });
  });

  describe('Metadata Integration', () => {
    it('should include optional metadata fields when present', () => {
      const recipesWithTags = manifest.recipes.filter((r) => r.tags);
      const recipesWithAuthor = manifest.recipes.filter((r) => r.author);
      const recipesWithDescription = manifest.recipes.filter(
        (r) => r.description
      );

      // At least some recipes should have these fields
      expect(
        recipesWithTags.length +
          recipesWithAuthor.length +
          recipesWithDescription.length
      ).toBeGreaterThan(0);
    });

    it('should have valid tags structure when present', () => {
      manifest.recipes.forEach((recipe) => {
        if (recipe.tags) {
          expect(Array.isArray(recipe.tags)).toBe(true);
          recipe.tags.forEach((tag) => {
            expect(typeof tag).toBe('string');
          });
        }
      });
    });
  });

  describe('Path Normalization', () => {
    it('should use forward slashes in all paths', () => {
      manifest.recipes.forEach((recipe) => {
        expect(recipe.id).not.toContain('\\');
        expect(recipe.path).not.toContain('\\');
        expect(recipe.export).not.toContain('\\');
      });
    });

    it('should have path starting with ./', () => {
      manifest.recipes.forEach((recipe) => {
        expect(recipe.path).toMatch(/^\.\//);
      });
    });

    it('should have IDs without .rego extension', () => {
      manifest.recipes.forEach((recipe) => {
        expect(recipe.id).not.toContain('.rego');
      });
    });
  });
});
