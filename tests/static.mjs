import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const read = (file) => fs.readFileSync(path.join(root, file), 'utf8');

const pins = [
  ['app/Dockerfile', /^FROM pipeshubai\/pipeshub-ai:\d+\.\d+\.\d+-slim@sha256:[a-f0-9]{64}$/m],
  ['mongodb/Dockerfile', /^FROM mongo:\d+\.\d+\.\d+@sha256:[a-f0-9]{64}$/m],
  ['redis/Dockerfile', /^FROM redis:\d+\.\d+\.\d+(?:-[a-z0-9.]+)?@sha256:[a-f0-9]{64}$/m],
  ['qdrant/Dockerfile', /^FROM qdrant\/qdrant:v\d+\.\d+\.\d+@sha256:[a-f0-9]{64}$/m],
  ['neo4j/Dockerfile', /^FROM neo4j:\d+\.\d+\.\d+@sha256:[a-f0-9]{64}$/m],
];

for (const [file, pin] of pins) {
  const text = read(file);
  assert.match(text, pin, `${file} must retain a digest-pinned image`);
  assert.ok(!/:latest(?:@|\s|$)/m.test(text), `${file} must not use latest`);
}

const readme = read('README.md');
const templateReadme = read('TEMPLATE_README.md');
assert.match(readme, /Safe code execution is unavailable/);
assert.match(readme, /PIPESHUB_ADMIN_EMAIL/);
assert.match(readme, /\[!\[Deploy on Railway\]\(https:\/\/railway\.com\/button\.svg\)\]\(https:\/\/railway\.com\/deploy\/pipeshub\)/);
assert.deepEqual([...readme.matchAll(/https:\/\/railway\.com\/deploy\/[^)\s]+/g)].map((match) => match[0]), ['https://railway.com/deploy/pipeshub']);

for (const heading of [
  '# Deploy and Host PipesHub on Railway',
  '## About Hosting PipesHub',
  '## Common Use Cases',
  '## Dependencies for PipesHub Hosting',
  '### Deployment Dependencies',
  '### Implementation Details',
  '### Why Deploy PipesHub on Railway?',
]) {
  assert.ok(templateReadme.includes(heading), `TEMPLATE_README.md is missing ${heading}`);
}

assert.match(read('mongodb/Dockerfile'), /CMD \[\"mongod\", \"--bind_ip_all\", \"--wiredTigerCacheSizeGB\", \"1\"\]/);

const appConfig = read('app/railway.toml');
assert.match(appConfig, /healthcheckPath="\/api\/v1\/health\/services"/);
assert.match(appConfig, /healthcheckTimeout=600/);
assert.ok(fs.existsSync(path.join(root, 'assets/pipeshub-icon-v060.png')));

console.log('Static template checks passed.');
