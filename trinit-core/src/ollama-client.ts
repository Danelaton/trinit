import * as http from 'http';
import * as https from 'https';
import { URL } from 'url';
import {
  ListModelsResponse,
  PullProgress,
  ChatRequest,
  ChatResponse,
  HealthStatus,
} from './types';

export class OllamaClient {
  private baseUrl: string;

  constructor(baseUrl: string = 'http://localhost:11434') {
    this.baseUrl = baseUrl.replace(/\/$/, '');
  }

  // ── Health ──────────────────────────────────────────────

  async health(): Promise<HealthStatus> {
    try {
      const data = await this.get<any>('/');
      return { running: true, version: data?.version };
    } catch (err: any) {
      return { running: false, error: err.message };
    }
  }

  async check(): Promise<boolean> {
    const h = await this.health();
    return h.running;
  }

  // ── Models ──────────────────────────────────────────────

  async listModels(): Promise<ListModelsResponse> {
    return this.get<ListModelsResponse>('/api/tags');
  }

  async pullModel(
    name: string,
    onProgress?: (progress: PullProgress) => void
  ): Promise<void> {
    const body = JSON.stringify({ name, stream: true });
    await this.streamPost('/api/pull', body, (line) => {
      try {
        const data = JSON.parse(line);
        if (onProgress) onProgress(data);
      } catch {
        // skip unparseable lines
      }
    });
  }

  // ── Chat ────────────────────────────────────────────────

  async chat(request: ChatRequest): Promise<ChatResponse> {
    return this.post<ChatResponse>('/api/chat', { ...request, stream: false });
  }

  async chatStream(
    request: ChatRequest,
    onToken: (token: string) => void,
    onDone?: (response: ChatResponse) => void
  ): Promise<void> {
    const body = JSON.stringify({ ...request, stream: true });
    await this.streamPost('/api/chat', body, (line) => {
      try {
        const data = JSON.parse(line);
        if (data.message?.content) {
          onToken(data.message.content);
        }
        if (data.done && onDone) {
          onDone(data);
        }
      } catch {
        // skip
      }
    });
  }

  // ── HTTP helpers ────────────────────────────────────────

  private async get<T>(path: string): Promise<T> {
    return new Promise((resolve, reject) => {
      const url = new URL(path, this.baseUrl);
      const lib = url.protocol === 'https:' ? https : http;
      const req = lib.get(url, (res) => {
        let body = '';
        res.on('data', (chunk) => (body += chunk));
        res.on('end', () => {
          try {
            resolve(JSON.parse(body));
          } catch {
            resolve(body as unknown as T);
          }
        });
      });
      req.on('error', reject);
      req.setTimeout(10000, () => {
        req.destroy();
        reject(new Error('Request timeout'));
      });
    });
  }

  private async post<T>(path: string, data: unknown): Promise<T> {
    return new Promise((resolve, reject) => {
      const url = new URL(path, this.baseUrl);
      const body = JSON.stringify(data);
      const options: http.RequestOptions = {
        hostname: url.hostname,
        port: url.port,
        path: url.pathname,
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Content-Length': Buffer.byteLength(body),
        },
      };
      const lib = url.protocol === 'https:' ? https : http;
      const req = lib.request(options, (res) => {
        let responseBody = '';
        res.on('data', (chunk) => (responseBody += chunk));
        res.on('end', () => {
          try {
            resolve(JSON.parse(responseBody));
          } catch {
            resolve(responseBody as unknown as T);
          }
        });
      });
      req.on('error', reject);
      req.setTimeout(30000, () => {
        req.destroy();
        reject(new Error('Request timeout'));
      });
      req.write(body);
      req.end();
    });
  }

  private async streamPost(
    path: string,
    body: string,
    onLine: (line: string) => void
  ): Promise<void> {
    return new Promise((resolve, reject) => {
      const url = new URL(path, this.baseUrl);
      const options: http.RequestOptions = {
        hostname: url.hostname,
        port: url.port,
        path: url.pathname,
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Content-Length': Buffer.byteLength(body),
        },
      };
      const lib = url.protocol === 'https:' ? https : http;
      const req = lib.request(options, (res) => {
        let buffer = '';
        res.on('data', (chunk: Buffer) => {
          buffer += chunk.toString();
          const lines = buffer.split('\n');
          buffer = lines.pop() || '';
          for (const line of lines) {
            if (line.trim()) onLine(line.trim());
          }
        });
        res.on('end', () => {
          if (buffer.trim()) onLine(buffer.trim());
          resolve();
        });
      });
      req.on('error', reject);
      req.setTimeout(0); // no timeout for streaming pulls
      req.write(body);
      req.end();
    });
  }
}
