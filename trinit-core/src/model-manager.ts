import * as fs from 'fs';
import * as path from 'path';
import * as yaml from 'yaml';
import { OllamaClient } from './ollama-client';
import { ModelManifest, ModelDefinition, PullProgress } from './types';

export class ModelManager {
  private client: OllamaClient;
  private manifestPath: string;

  constructor(client: OllamaClient, manifestPath?: string) {
    this.client = client;
    this.manifestPath = manifestPath || path.resolve(__dirname, '..', '..', '..', 'models.yaml');
  }

  // ── Manifest ────────────────────────────────────────────

  loadManifest(): ModelManifest {
    const raw = fs.readFileSync(this.manifestPath, 'utf-8');
    return yaml.parse(raw) as ModelManifest;
  }

  getModels(): ModelDefinition[] {
    return this.loadManifest().models.sort((a, b) => a.priority - b.priority);
  }

  // ── Status ──────────────────────────────────────────────

  async getInstalledModels(): Promise<Set<string>> {
    try {
      const response = await this.client.listModels();
      return new Set(response.models.map((m) => m.name));
    } catch {
      return new Set();
    }
  }

  async modelStatus(): Promise<
    { model: ModelDefinition; installed: boolean; available: boolean }[]
  > {
    const installed = await this.getInstalledModels();
    const manifest = this.getModels();
    return manifest.map((model) => ({
      model,
      installed: installed.has(model.ollama_ref),
      available: true, // Ollama determines availability at pull time
    }));
  }

  // ── Pull ────────────────────────────────────────────────

  async pullModel(
    model: ModelDefinition,
    onProgress?: (progress: PullProgress) => void
  ): Promise<void> {
    await this.client.pullModel(model.ollama_ref, onProgress);
  }

  async pullAll(
    onModelStart?: (model: ModelDefinition) => void,
    onProgress?: (model: ModelDefinition, progress: PullProgress) => void,
    onModelDone?: (model: ModelDefinition) => void,
    onModelError?: (model: ModelDefinition, error: Error) => void
  ): Promise<void> {
    const models = this.getModels();
    const installed = await this.getInstalledModels();

    for (const model of models) {
      if (installed.has(model.ollama_ref)) {
        continue; // skip already installed
      }

      onModelStart?.(model);

      try {
        await this.client.pullModel(model.ollama_ref, (progress) => {
          onProgress?.(model, progress);
        });
        onModelDone?.(model);
      } catch (err) {
        onModelError?.(model, err as Error);
      }
    }
  }
}
