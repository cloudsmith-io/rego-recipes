export interface Recipe {
  id: string;
  name: string;
  path: string;
  export: string;
  code: string;
  description?: string;
  tags?: string[];
  author?: string;
}

export interface Manifest {
  version: string;
  generatedAt: string;
  totalRecipes: number;
  recipes: Recipe[];
}

declare const manifest: Manifest;
export default manifest;
