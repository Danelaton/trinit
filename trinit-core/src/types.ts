// Shared types for Trinit

export interface ModelDefinition {
  name: string;
  tag: string;
  ollama_ref: string;
  size: string;
  context: number;
  input: ('text' | 'image')[];
  description: string;
  priority: number;
  doc: string;
}

export interface ModelManifest {
  models: ModelDefinition[];
}

export interface OllamaModel {
  name: string;
  model: string;
  size: number;
  digest: string;
  modified_at: string;
  details?: {
    parent_model?: string;
    format?: string;
    family?: string;
    families?: string[];
    parameter_size?: string;
    quantization_level?: string;
  };
}

export interface ListModelsResponse {
  models: OllamaModel[];
}

export interface PullProgress {
  status: string;
  digest?: string;
  total?: number;
  completed?: number;
}

export interface ChatMessage {
  role: 'system' | 'user' | 'assistant';
  content: string;
  images?: string[]; // base64 encoded
}

export interface ChatOptions {
  temperature?: number;
  top_p?: number;
  top_k?: number;
  num_predict?: number;
  seed?: number;
}

export interface ChatRequest {
  model: string;
  messages: ChatMessage[];
  stream?: boolean;
  options?: ChatOptions;
}

export interface ChatResponse {
  model: string;
  created_at: string;
  message: ChatMessage;
  done: boolean;
  total_duration?: number;
  load_duration?: number;
  prompt_eval_count?: number;
  prompt_eval_duration?: number;
  eval_count?: number;
  eval_duration?: number;
}

export interface HealthStatus {
  running: boolean;
  version?: string;
  error?: string;
}

export interface TrinitConfig {
  baseUrl?: string;
  modelsManifestPath?: string;
}
