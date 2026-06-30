#!/usr/bin/env node
/**
 * Rebrand script — run after pulling upstream Zoo-Code updates.
 * Applies Trinit branding over Zoo Code.
 *
 * Usage: node scripts/rebrand.mjs
 */
import { readFileSync, writeFileSync } from 'fs';
import { globSync } from 'glob';

const REPLACEMENTS = [
  // Command prefix (MUST change — unique VS Code namespace)
  ['zoo-code.', 'trinit.'],
  ['zoo-code-', 'trinit-'],

  // Extension name in package.json
  ['"name": "zoo-code"', '"name": "trinit"'],
  ['"name": "roo-code"', '"name": "trinit"'],

  // Publisher
  ['"publisher": "ZooCodeOrganization"', '"publisher": "trinit"'],

  // Repository
  ['https://github.com/Zoo-Code-Org/Zoo-Code', 'https://github.com/USER/Trinit'],

  // Homepage
  ['https://zoocode.dev', 'https://trinit.dev'],

  // Display strings (package.nls.json and i18n)
  ['"Zoo Code"', '"Trinit"'],
  ['Zoo Code', 'Trinit'],
  ['zoocode.dev', 'trinit.dev'],

  // Root monorepo name
  ['"name": "roo-code"', '"name": "trinit-vscode"'],
];

const files = globSync('src/**/*.{ts,tsx,json}', {
  ignore: ['**/node_modules/**', '**/dist/**', '**/.git/**'],
});

let changed = 0;
for (const file of files) {
  let content = readFileSync(file, 'utf-8');
  let modified = false;

  for (const [from, to] of REPLACEMENTS) {
    if (content.includes(from)) {
      content = content.replaceAll(from, to);
      modified = true;
    }
  }

  if (modified) {
    writeFileSync(file, content);
    changed++;
    console.log(`  ✓ ${file}`);
  }
}

console.log(`\nRebranded ${changed} files.`);
