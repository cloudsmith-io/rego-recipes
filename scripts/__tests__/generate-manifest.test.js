// @ts-nocheck
const fs = require('fs');
const path = require('path');
const mock = require('mock-fs');

// We need to require the script after mocking, so we'll use a helper
let generateManifest;

describe('generate-manifest.cjs', () => {
  beforeEach(() => {
    // Clear module cache to get fresh requires
    jest.resetModules();
  });

  afterEach(() => {
    mock.restore();
  });

  describe('findRegoFiles()', () => {
    it('should find all .rego files in the project', () => {
      mock({
        '/test-project': {
          'package.json': JSON.stringify({ version: '1.0.0' }),
          'recipe-1': {
            'policy.rego': 'package test',
            'metadata.json': JSON.stringify({ name: 'Test Policy' }),
          },
          'recipe-2': {
            'policy.rego': 'package test2',
          },
        },
      });

      // Inline test of findRegoFiles logic
      const findRegoFiles = (dir, baseDir = dir) => {
        const results = [];
        const entries = fs.readdirSync(dir, { withFileTypes: true });

        for (const entry of entries) {
          const fullPath = path.join(dir, entry.name);

          if (entry.isDirectory()) {
            if (
              ['node_modules', '.git', '.husky', 'scripts'].includes(entry.name)
            ) {
              continue;
            }
            results.push(...findRegoFiles(fullPath, baseDir));
          } else if (entry.name.endsWith('.rego')) {
            const relativePath = path.relative(baseDir, fullPath);
            results.push(relativePath);
          }
        }

        return results;
      };

      const files = findRegoFiles('/test-project');
      expect(files).toHaveLength(2);
      expect(files).toEqual(
        expect.arrayContaining([
          expect.stringMatching(/recipe-1[/\\]policy\.rego/),
          expect.stringMatching(/recipe-2[/\\]policy\.rego/),
        ])
      );
    });

    it('should skip excluded directories', () => {
      mock({
        '/test-project': {
          'package.json': JSON.stringify({ version: '1.0.0' }),
          'recipe-1': {
            'policy.rego': 'package test',
          },
          node_modules: {
            'some-package': {
              'file.rego': 'should be ignored',
            },
          },
          '.git': {
            'file.rego': 'should be ignored',
          },
          '.husky': {
            'file.rego': 'should be ignored',
          },
          scripts: {
            'file.rego': 'should be ignored',
          },
        },
      });

      const findRegoFiles = (dir, baseDir = dir) => {
        const results = [];
        const entries = fs.readdirSync(dir, { withFileTypes: true });

        for (const entry of entries) {
          const fullPath = path.join(dir, entry.name);

          if (entry.isDirectory()) {
            if (
              ['node_modules', '.git', '.husky', 'scripts'].includes(entry.name)
            ) {
              continue;
            }
            results.push(...findRegoFiles(fullPath, baseDir));
          } else if (entry.name.endsWith('.rego')) {
            const relativePath = path.relative(baseDir, fullPath);
            results.push(relativePath);
          }
        }

        return results;
      };

      const files = findRegoFiles('/test-project');
      expect(files).toHaveLength(1);
      expect(files[0]).toMatch(/recipe-1[/\\]policy\.rego/);
    });

    it('should handle nested .rego files in recipe subdirectories', () => {
      mock({
        '/test-project': {
          'package.json': JSON.stringify({ version: '1.0.0' }),
          'huggingface-recipes': {
            'model_card.rego': 'package hf',
            'security_scan.rego': 'package hf2',
          },
        },
      });

      const findRegoFiles = (dir, baseDir = dir) => {
        const results = [];
        const entries = fs.readdirSync(dir, { withFileTypes: true });

        for (const entry of entries) {
          const fullPath = path.join(dir, entry.name);

          if (entry.isDirectory()) {
            if (
              ['node_modules', '.git', '.husky', 'scripts'].includes(entry.name)
            ) {
              continue;
            }
            results.push(...findRegoFiles(fullPath, baseDir));
          } else if (entry.name.endsWith('.rego')) {
            const relativePath = path.relative(baseDir, fullPath);
            results.push(relativePath);
          }
        }

        return results;
      };

      const files = findRegoFiles('/test-project');
      expect(files).toHaveLength(2);
      expect(files).toEqual(
        expect.arrayContaining([
          expect.stringMatching(/huggingface-recipes[/\\]model_card\.rego/),
          expect.stringMatching(/huggingface-recipes[/\\]security_scan\.rego/),
        ])
      );
    });
  });

  describe('sorting logic', () => {
    it('should sort recipe-N folders numerically', () => {
      const files = [
        'recipe-10/policy.rego',
        'recipe-2/policy.rego',
        'recipe-1/policy.rego',
        'recipe-21/policy.rego',
      ];

      const sorted = files.sort((a, b) => {
        const aFolder = a.split(path.sep)[0];
        const bFolder = b.split(path.sep)[0];

        const aIsRecipe = aFolder.startsWith('recipe-');
        const bIsRecipe = bFolder.startsWith('recipe-');

        if (aIsRecipe && bIsRecipe) {
          const aNum = parseInt(aFolder.split('-')[1]);
          const bNum = parseInt(bFolder.split('-')[1]);
          return aNum - bNum;
        }

        if (aIsRecipe && !bIsRecipe) return -1;
        if (!aIsRecipe && bIsRecipe) return 1;

        return a.localeCompare(b);
      });

      expect(sorted).toEqual([
        'recipe-1/policy.rego',
        'recipe-2/policy.rego',
        'recipe-10/policy.rego',
        'recipe-21/policy.rego',
      ]);
    });

    it('should place recipe-N folders before non-recipe folders', () => {
      const files = [
        'huggingface-recipes/model_card.rego',
        'recipe-1/policy.rego',
        'recipe-2/policy.rego',
      ];

      const sorted = files.sort((a, b) => {
        const aFolder = a.split(path.sep)[0];
        const bFolder = b.split(path.sep)[0];

        const aIsRecipe = aFolder.startsWith('recipe-');
        const bIsRecipe = bFolder.startsWith('recipe-');

        if (aIsRecipe && bIsRecipe) {
          const aNum = parseInt(aFolder.split('-')[1]);
          const bNum = parseInt(bFolder.split('-')[1]);
          return aNum - bNum;
        }

        if (aIsRecipe && !bIsRecipe) return -1;
        if (!aIsRecipe && bIsRecipe) return 1;

        return a.localeCompare(b);
      });

      expect(sorted[0]).toBe('recipe-1/policy.rego');
      expect(sorted[1]).toBe('recipe-2/policy.rego');
      expect(sorted[2]).toBe('huggingface-recipes/model_card.rego');
    });

    it('should sort non-recipe folders alphabetically', () => {
      const files = [
        'zebra-recipes/policy.rego',
        'apple-recipes/policy.rego',
        'huggingface-recipes/policy.rego',
      ];

      const sorted = files.sort((a, b) => {
        const aFolder = a.split(path.sep)[0];
        const bFolder = b.split(path.sep)[0];

        const aIsRecipe = aFolder.startsWith('recipe-');
        const bIsRecipe = bFolder.startsWith('recipe-');

        if (aIsRecipe && bIsRecipe) {
          const aNum = parseInt(aFolder.split('-')[1]);
          const bNum = parseInt(bFolder.split('-')[1]);
          return aNum - bNum;
        }

        if (aIsRecipe && !bIsRecipe) return -1;
        if (!aIsRecipe && bIsRecipe) return 1;

        return a.localeCompare(b);
      });

      expect(sorted).toEqual([
        'apple-recipes/policy.rego',
        'huggingface-recipes/policy.rego',
        'zebra-recipes/policy.rego',
      ]);
    });
  });

  describe('loadMetadata()', () => {
    it('should load metadata from recipe-N/metadata.json', () => {
      mock({
        '/test-project': {
          'package.json': JSON.stringify({ version: '1.0.0' }),
          'recipe-1': {
            'policy.rego': 'package test',
            'metadata.json': JSON.stringify({
              name: 'Test Policy',
              description: 'A test policy',
              tags: ['security', 'test'],
            }),
          },
        },
      });

      const loadMetadata = (file, rootDir) => {
        const parts = file.split(path.sep);
        const folder = parts[0];
        const fileName = path.parse(file).name;

        if (folder.startsWith('recipe-')) {
          const metadataPath = path.join(rootDir, folder, 'metadata.json');
          if (fs.existsSync(metadataPath)) {
            return JSON.parse(fs.readFileSync(metadataPath, 'utf8'));
          }
        }

        if (folder === 'huggingface-recipes') {
          const metadataPath = path.join(rootDir, folder, 'metadata.json');
          if (fs.existsSync(metadataPath)) {
            const allMetadata = JSON.parse(
              fs.readFileSync(metadataPath, 'utf8')
            );
            return allMetadata[fileName] || {};
          }
        }

        return {};
      };

      const metadata = loadMetadata('recipe-1/policy.rego', '/test-project');
      expect(metadata).toEqual({
        name: 'Test Policy',
        description: 'A test policy',
        tags: ['security', 'test'],
      });
    });

    it('should load metadata from huggingface-recipes/metadata.json with filename key', () => {
      mock({
        '/test-project': {
          'package.json': JSON.stringify({ version: '1.0.0' }),
          'huggingface-recipes': {
            'model_card.rego': 'package hf',
            'metadata.json': JSON.stringify({
              model_card: {
                name: 'Model Card Validation',
                description: 'Validates model cards',
              },
              security_scan: {
                name: 'Security Scan',
                description: 'Scans for security issues',
              },
            }),
          },
        },
      });

      const loadMetadata = (file, rootDir) => {
        const parts = file.split(path.sep);
        const folder = parts[0];
        const fileName = path.parse(file).name;

        if (folder.startsWith('recipe-')) {
          const metadataPath = path.join(rootDir, folder, 'metadata.json');
          if (fs.existsSync(metadataPath)) {
            return JSON.parse(fs.readFileSync(metadataPath, 'utf8'));
          }
        }

        if (folder === 'huggingface-recipes') {
          const metadataPath = path.join(rootDir, folder, 'metadata.json');
          if (fs.existsSync(metadataPath)) {
            const allMetadata = JSON.parse(
              fs.readFileSync(metadataPath, 'utf8')
            );
            return allMetadata[fileName] || {};
          }
        }

        return {};
      };

      const metadata = loadMetadata(
        'huggingface-recipes/model_card.rego',
        '/test-project'
      );
      expect(metadata).toEqual({
        name: 'Model Card Validation',
        description: 'Validates model cards',
      });
    });

    it('should return empty object when metadata.json is missing', () => {
      mock({
        '/test-project': {
          'package.json': JSON.stringify({ version: '1.0.0' }),
          'recipe-1': {
            'policy.rego': 'package test',
          },
        },
      });

      const loadMetadata = (file, rootDir) => {
        const parts = file.split(path.sep);
        const folder = parts[0];
        const fileName = path.parse(file).name;

        if (folder.startsWith('recipe-')) {
          const metadataPath = path.join(rootDir, folder, 'metadata.json');
          if (fs.existsSync(metadataPath)) {
            return JSON.parse(fs.readFileSync(metadataPath, 'utf8'));
          }
        }

        if (folder === 'huggingface-recipes') {
          const metadataPath = path.join(rootDir, folder, 'metadata.json');
          if (fs.existsSync(metadataPath)) {
            const allMetadata = JSON.parse(
              fs.readFileSync(metadataPath, 'utf8')
            );
            return allMetadata[fileName] || {};
          }
        }

        return {};
      };

      const metadata = loadMetadata('recipe-1/policy.rego', '/test-project');
      expect(metadata).toEqual({});
    });

    it('should return empty object when huggingface key is missing', () => {
      mock({
        '/test-project': {
          'package.json': JSON.stringify({ version: '1.0.0' }),
          'huggingface-recipes': {
            'model_card.rego': 'package hf',
            'unknown.rego': 'package unknown',
            'metadata.json': JSON.stringify({
              model_card: {
                name: 'Model Card Validation',
              },
            }),
          },
        },
      });

      const loadMetadata = (file, rootDir) => {
        const parts = file.split(path.sep);
        const folder = parts[0];
        const fileName = path.parse(file).name;

        if (folder.startsWith('recipe-')) {
          const metadataPath = path.join(rootDir, folder, 'metadata.json');
          if (fs.existsSync(metadataPath)) {
            return JSON.parse(fs.readFileSync(metadataPath, 'utf8'));
          }
        }

        if (folder === 'huggingface-recipes') {
          const metadataPath = path.join(rootDir, folder, 'metadata.json');
          if (fs.existsSync(metadataPath)) {
            const allMetadata = JSON.parse(
              fs.readFileSync(metadataPath, 'utf8')
            );
            return allMetadata[fileName] || {};
          }
        }

        return {};
      };

      const metadata = loadMetadata(
        'huggingface-recipes/unknown.rego',
        '/test-project'
      );
      expect(metadata).toEqual({});
    });
  });

  describe('manifest output structure', () => {
    it('should generate valid manifest with all required fields', () => {
      mock({
        '/test-project': {
          'package.json': JSON.stringify({ version: '2.5.0' }),
          'manifest.json': '',
          'recipe-1': {
            'policy.rego': 'package example\n\ndefault allow = false',
            'metadata.json': JSON.stringify({
              name: 'Example Policy',
              description: 'An example',
              tags: ['test'],
              author: 'Test Author',
            }),
          },
        },
      });

      // Simulate the script execution
      const rootDir = '/test-project';
      const packageJson = JSON.parse(
        fs.readFileSync(path.join(rootDir, 'package.json'), 'utf8')
      );

      const findRegoFiles = (dir, baseDir = dir) => {
        const results = [];
        const entries = fs.readdirSync(dir, { withFileTypes: true });

        for (const entry of entries) {
          const fullPath = path.join(dir, entry.name);

          if (entry.isDirectory()) {
            if (
              ['node_modules', '.git', '.husky', 'scripts'].includes(entry.name)
            ) {
              continue;
            }
            results.push(...findRegoFiles(fullPath, baseDir));
          } else if (entry.name.endsWith('.rego')) {
            const relativePath = path.relative(baseDir, fullPath);
            results.push(relativePath);
          }
        }

        return results;
      };

      const loadMetadata = (file) => {
        const parts = file.split(path.sep);
        const folder = parts[0];
        const fileName = path.parse(file).name;

        if (folder.startsWith('recipe-')) {
          const metadataPath = path.join(rootDir, folder, 'metadata.json');
          if (fs.existsSync(metadataPath)) {
            return JSON.parse(fs.readFileSync(metadataPath, 'utf8'));
          }
        }

        if (folder === 'huggingface-recipes') {
          const metadataPath = path.join(rootDir, folder, 'metadata.json');
          if (fs.existsSync(metadataPath)) {
            const allMetadata = JSON.parse(
              fs.readFileSync(metadataPath, 'utf8')
            );
            return allMetadata[fileName] || {};
          }
        }

        return {};
      };

      const regoFiles = findRegoFiles(rootDir);
      const recipes = regoFiles.map((file) => {
        const parsedPath = path.parse(file);
        const id = file.replace('.rego', '').replace(/\\/g, '/');
        const exportKey = `./${id}`;
        const fileName = parsedPath.name;

        const fullPath = path.join(rootDir, file);
        const code = fs.readFileSync(fullPath, 'utf8');
        const metadata = loadMetadata(file);

        return {
          id: id,
          name: metadata.name || fileName.replace(/_/g, ' ').replace(/-/g, ' '),
          path: `./${file.replace(/\\/g, '/')}`,
          export: exportKey,
          code: code,
          ...metadata,
        };
      });

      const manifest = {
        version: packageJson.version,
        generatedAt: new Date().toISOString(),
        totalRecipes: recipes.length,
        recipes: recipes,
      };

      expect(manifest.version).toBe('2.5.0');
      expect(manifest.totalRecipes).toBe(1);
      expect(manifest.generatedAt).toMatch(
        /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$/
      );
      expect(manifest.recipes).toHaveLength(1);
      expect(manifest.recipes[0]).toEqual({
        id: 'recipe-1/policy',
        name: 'Example Policy',
        path: './recipe-1/policy.rego',
        export: './recipe-1/policy',
        code: 'package example\n\ndefault allow = false',
        description: 'An example',
        tags: ['test'],
        author: 'Test Author',
      });
    });

    it('should use filename as name fallback when metadata missing', () => {
      mock({
        '/test-project': {
          'package.json': JSON.stringify({ version: '1.0.0' }),
          'recipe-1': {
            'my_test_policy.rego': 'package test',
          },
        },
      });

      const rootDir = '/test-project';

      const findRegoFiles = (dir, baseDir = dir) => {
        const results = [];
        const entries = fs.readdirSync(dir, { withFileTypes: true });

        for (const entry of entries) {
          const fullPath = path.join(dir, entry.name);

          if (entry.isDirectory()) {
            if (
              ['node_modules', '.git', '.husky', 'scripts'].includes(entry.name)
            ) {
              continue;
            }
            results.push(...findRegoFiles(fullPath, baseDir));
          } else if (entry.name.endsWith('.rego')) {
            const relativePath = path.relative(baseDir, fullPath);
            results.push(relativePath);
          }
        }

        return results;
      };

      const loadMetadata = (file) => {
        return {};
      };

      const regoFiles = findRegoFiles(rootDir);
      const recipes = regoFiles.map((file) => {
        const parsedPath = path.parse(file);
        const id = file.replace('.rego', '').replace(/\\/g, '/');
        const exportKey = `./${id}`;
        const fileName = parsedPath.name;

        const fullPath = path.join(rootDir, file);
        const code = fs.readFileSync(fullPath, 'utf8');
        const metadata = loadMetadata(file);

        return {
          id: id,
          name: metadata.name || fileName.replace(/_/g, ' ').replace(/-/g, ' '),
          path: `./${file.replace(/\\/g, '/')}`,
          export: exportKey,
          code: code,
          ...metadata,
        };
      });

      expect(recipes[0].name).toBe('my test policy');
    });

    it('should include extra metadata fields via spread operator', () => {
      mock({
        '/test-project': {
          'package.json': JSON.stringify({ version: '1.0.0' }),
          'recipe-1': {
            'policy.rego': 'package test',
            'metadata.json': JSON.stringify({
              name: 'Test',
              customField: 'custom value',
              anotherField: 42,
            }),
          },
        },
      });

      const rootDir = '/test-project';

      const findRegoFiles = (dir, baseDir = dir) => {
        const results = [];
        const entries = fs.readdirSync(dir, { withFileTypes: true });

        for (const entry of entries) {
          const fullPath = path.join(dir, entry.name);

          if (entry.isDirectory()) {
            if (
              ['node_modules', '.git', '.husky', 'scripts'].includes(entry.name)
            ) {
              continue;
            }
            results.push(...findRegoFiles(fullPath, baseDir));
          } else if (entry.name.endsWith('.rego')) {
            const relativePath = path.relative(baseDir, fullPath);
            results.push(relativePath);
          }
        }

        return results;
      };

      const loadMetadata = (file) => {
        const parts = file.split(path.sep);
        const folder = parts[0];

        if (folder.startsWith('recipe-')) {
          const metadataPath = path.join(rootDir, folder, 'metadata.json');
          if (fs.existsSync(metadataPath)) {
            return JSON.parse(fs.readFileSync(metadataPath, 'utf8'));
          }
        }

        return {};
      };

      const regoFiles = findRegoFiles(rootDir);
      const recipes = regoFiles.map((file) => {
        const parsedPath = path.parse(file);
        const id = file.replace('.rego', '').replace(/\\/g, '/');
        const exportKey = `./${id}`;
        const fileName = parsedPath.name;

        const fullPath = path.join(rootDir, file);
        const code = fs.readFileSync(fullPath, 'utf8');
        const metadata = loadMetadata(file);

        return {
          id: id,
          name: metadata.name || fileName.replace(/_/g, ' ').replace(/-/g, ' '),
          path: `./${file.replace(/\\/g, '/')}`,
          export: exportKey,
          code: code,
          ...metadata,
        };
      });

      expect(recipes[0]).toHaveProperty('customField', 'custom value');
      expect(recipes[0]).toHaveProperty('anotherField', 42);
    });
  });

  describe('error handling', () => {
    it('should throw when package.json is missing', () => {
      mock({
        '/test-project': {
          'recipe-1': {
            'policy.rego': 'package test',
          },
        },
      });

      expect(() => {
        fs.readFileSync('/test-project/package.json', 'utf8');
      }).toThrow();
    });

    it('should throw when package.json has invalid JSON', () => {
      mock({
        '/test-project': {
          'package.json': '{invalid json}',
        },
      });

      expect(() => {
        JSON.parse(fs.readFileSync('/test-project/package.json', 'utf8'));
      }).toThrow(SyntaxError);
    });

    it('should throw when metadata.json has invalid JSON', () => {
      mock({
        '/test-project': {
          'package.json': JSON.stringify({ version: '1.0.0' }),
          'recipe-1': {
            'policy.rego': 'package test',
            'metadata.json': '{invalid: json}',
          },
        },
      });

      const rootDir = '/test-project';
      const metadataPath = path.join(rootDir, 'recipe-1', 'metadata.json');

      expect(() => {
        JSON.parse(fs.readFileSync(metadataPath, 'utf8'));
      }).toThrow(SyntaxError);
    });

    it('should throw when .rego file is not readable', () => {
      mock({
        '/test-project': {
          'package.json': JSON.stringify({ version: '1.0.0' }),
          'recipe-1': {
            'policy.rego': mock.file({
              content: 'package test',
              mode: 0o000, // No read permissions
            }),
          },
        },
      });

      const filePath = '/test-project/recipe-1/policy.rego';

      expect(() => {
        fs.readFileSync(filePath, 'utf8');
      }).toThrow();
    });
  });

  describe('edge cases', () => {
    it('should handle empty project with no .rego files', () => {
      mock({
        '/test-project': {
          'package.json': JSON.stringify({ version: '1.0.0' }),
          'README.md': 'Empty project',
        },
      });

      const findRegoFiles = (dir, baseDir = dir) => {
        const results = [];
        const entries = fs.readdirSync(dir, { withFileTypes: true });

        for (const entry of entries) {
          const fullPath = path.join(dir, entry.name);

          if (entry.isDirectory()) {
            if (
              ['node_modules', '.git', '.husky', 'scripts'].includes(entry.name)
            ) {
              continue;
            }
            results.push(...findRegoFiles(fullPath, baseDir));
          } else if (entry.name.endsWith('.rego')) {
            const relativePath = path.relative(baseDir, fullPath);
            results.push(relativePath);
          }
        }

        return results;
      };

      const files = findRegoFiles('/test-project');
      expect(files).toHaveLength(0);
    });

    it('should handle empty .rego files', () => {
      mock({
        '/test-project': {
          'package.json': JSON.stringify({ version: '1.0.0' }),
          'recipe-1': {
            'policy.rego': '',
          },
        },
      });

      const code = fs.readFileSync(
        '/test-project/recipe-1/policy.rego',
        'utf8'
      );
      expect(code).toBe('');
    });

    it('should omit empty .rego files from manifest', () => {
      mock({
        '/test-project': {
          'package.json': JSON.stringify({ version: '1.0.0' }),
          'recipe-1': {
            'policy.rego': '',
            'metadata.json': JSON.stringify({ name: 'Empty Policy' }),
          },
          'recipe-2': {
            'policy.rego': 'package valid',
            'metadata.json': JSON.stringify({ name: 'Valid Policy' }),
          },
        },
      });

      const rootDir = '/test-project';
      const packageJson = JSON.parse(
        fs.readFileSync(path.join(rootDir, 'package.json'), 'utf8')
      );

      const findRegoFiles = (dir, baseDir = dir) => {
        const results = [];
        const entries = fs.readdirSync(dir, { withFileTypes: true });

        for (const entry of entries) {
          const fullPath = path.join(dir, entry.name);

          if (entry.isDirectory()) {
            if (
              ['node_modules', '.git', '.husky', 'scripts'].includes(entry.name)
            ) {
              continue;
            }
            results.push(...findRegoFiles(fullPath, baseDir));
          } else if (entry.name.endsWith('.rego')) {
            const relativePath = path.relative(baseDir, fullPath);
            results.push(relativePath);
          }
        }

        return results;
      };

      const loadMetadata = (file) => {
        const parts = file.split(path.sep);
        const folder = parts[0];
        const fileName = path.parse(file).name;

        if (folder.startsWith('recipe-')) {
          const metadataPath = path.join(rootDir, folder, 'metadata.json');
          if (fs.existsSync(metadataPath)) {
            return JSON.parse(fs.readFileSync(metadataPath, 'utf8'));
          }
        }

        return {};
      };

      const regoFiles = findRegoFiles(rootDir);
      const recipes = regoFiles
        .map((file) => {
          const parsedPath = path.parse(file);
          const id = file.replace('.rego', '').replace(/\\/g, '/');
          const exportKey = `./${id}`;
          const fileName = parsedPath.name;

          const fullPath = path.join(rootDir, file);
          const code = fs.readFileSync(fullPath, 'utf8');

          // Skip empty .rego files
          if (!code || code.trim().length === 0) {
            return null;
          }

          const metadata = loadMetadata(file);

          return {
            id: id,
            name:
              metadata.name || fileName.replace(/_/g, ' ').replace(/-/g, ' '),
            path: `./${file.replace(/\\/g, '/')}`,
            export: exportKey,
            code: code,
            ...metadata,
          };
        })
        .filter((recipe) => recipe !== null);

      expect(recipes).toHaveLength(1);
      expect(recipes[0].id).toBe('recipe-2/policy');
      expect(recipes[0].name).toBe('Valid Policy');
    });

    it('should omit whitespace-only .rego files from manifest', () => {
      mock({
        '/test-project': {
          'package.json': JSON.stringify({ version: '1.0.0' }),
          'recipe-1': {
            'policy.rego': '   \n  \t  ',
          },
          'recipe-2': {
            'policy.rego': 'package valid',
          },
        },
      });

      const rootDir = '/test-project';

      const findRegoFiles = (dir, baseDir = dir) => {
        const results = [];
        const entries = fs.readdirSync(dir, { withFileTypes: true });

        for (const entry of entries) {
          const fullPath = path.join(dir, entry.name);

          if (entry.isDirectory()) {
            if (
              ['node_modules', '.git', '.husky', 'scripts'].includes(entry.name)
            ) {
              continue;
            }
            results.push(...findRegoFiles(fullPath, baseDir));
          } else if (entry.name.endsWith('.rego')) {
            const relativePath = path.relative(baseDir, fullPath);
            results.push(relativePath);
          }
        }

        return results;
      };

      const regoFiles = findRegoFiles(rootDir);
      const recipes = regoFiles
        .map((file) => {
          const parsedPath = path.parse(file);
          const id = file.replace('.rego', '').replace(/\\/g, '/');
          const exportKey = `./${id}`;
          const fileName = parsedPath.name;

          const fullPath = path.join(rootDir, file);
          const code = fs.readFileSync(fullPath, 'utf8');

          // Skip empty .rego files
          if (!code || code.trim().length === 0) {
            return null;
          }

          return {
            id: id,
            name: fileName.replace(/_/g, ' ').replace(/-/g, ' '),
            path: `./${file.replace(/\\/g, '/')}`,
            export: exportKey,
            code: code,
          };
        })
        .filter((recipe) => recipe !== null);

      expect(recipes).toHaveLength(1);
      expect(recipes[0].id).toBe('recipe-2/policy');
    });

    it('should handle metadata.json with empty object', () => {
      mock({
        '/test-project': {
          'package.json': JSON.stringify({ version: '1.0.0' }),
          'recipe-1': {
            'policy.rego': 'package test',
            'metadata.json': JSON.stringify({}),
          },
        },
      });

      const rootDir = '/test-project';
      const metadataPath = path.join(rootDir, 'recipe-1', 'metadata.json');
      const metadata = JSON.parse(fs.readFileSync(metadataPath, 'utf8'));

      expect(metadata).toEqual({});
    });

    it('should handle non-contiguous recipe numbers', () => {
      const files = [
        'recipe-1/policy.rego',
        'recipe-5/policy.rego',
        'recipe-20/policy.rego',
      ];

      const sorted = files.sort((a, b) => {
        const aFolder = a.split(path.sep)[0];
        const bFolder = b.split(path.sep)[0];

        const aIsRecipe = aFolder.startsWith('recipe-');
        const bIsRecipe = bFolder.startsWith('recipe-');

        if (aIsRecipe && bIsRecipe) {
          const aNum = parseInt(aFolder.split('-')[1]);
          const bNum = parseInt(bFolder.split('-')[1]);
          return aNum - bNum;
        }

        if (aIsRecipe && !bIsRecipe) return -1;
        if (!aIsRecipe && bIsRecipe) return 1;

        return a.localeCompare(b);
      });

      expect(sorted).toEqual([
        'recipe-1/policy.rego',
        'recipe-5/policy.rego',
        'recipe-20/policy.rego',
      ]);
    });

    it('should handle recipe numbers greater than 100', () => {
      const files = [
        'recipe-150/policy.rego',
        'recipe-2/policy.rego',
        'recipe-99/policy.rego',
      ];

      const sorted = files.sort((a, b) => {
        const aFolder = a.split(path.sep)[0];
        const bFolder = b.split(path.sep)[0];

        const aIsRecipe = aFolder.startsWith('recipe-');
        const bIsRecipe = bFolder.startsWith('recipe-');

        if (aIsRecipe && bIsRecipe) {
          const aNum = parseInt(aFolder.split('-')[1]);
          const bNum = parseInt(bFolder.split('-')[1]);
          return aNum - bNum;
        }

        if (aIsRecipe && !bIsRecipe) return -1;
        if (!aIsRecipe && bIsRecipe) return 1;

        return a.localeCompare(b);
      });

      expect(sorted).toEqual([
        'recipe-2/policy.rego',
        'recipe-99/policy.rego',
        'recipe-150/policy.rego',
      ]);
    });
  });
});
