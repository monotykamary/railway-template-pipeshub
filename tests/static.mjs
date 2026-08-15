import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const read = (file) => fs.readFileSync(path.join(root, file), 'utf8');

const pins = new Map([
  ['app/Dockerfile', 'pipeshubai/pipeshub-ai:0.6.0-slim@sha256:8bfc3fc47eee2968042338563f464d0853245a099c22731a5446f8b7e0325ad0'],
  ['mongodb/Dockerfile', 'mongo:8.0.17@sha256:9814652e33f0cf8b9fddea8b46dfc9d8e19b130dcfdd7b510ca58bb0d40c8b71'],
  ['redis/Dockerfile', 'redis:8.4.0-bookworm@sha256:c22af04bb576503bf16b3e34a1fd2fd82de0f765afd866d2e380145e0af30d78'],
  ['qdrant/Dockerfile', 'qdrant/qdrant:v1.15.5@sha256:0fb8897412abc81d1c0430a899b9a81eb8328aa634e7242d1bc804c1fe8fe863'],
  ['neo4j/Dockerfile', 'neo4j:5.26.0@sha256:5a015e53de1895e7eee1574ae0325cf8c4b89587222778108c594bdd45a474b5'],
]);

for (const [file, pin] of pins) {
  const text = read(file);
  assert.ok(text.includes(`FROM ${pin}`), `${file} must retain its verified image pin`);
  assert.ok(!/:latest(?:@|\s|$)/m.test(text), `${file} must not use latest`);
}

const readme = read('README.md');
const templateReadme = read('TEMPLATE_README.md');
assert.match(readme, /Safe code execution is unavailable/);
assert.match(readme, /PIPESHUB_ADMIN_EMAIL/);
assert.ok(!readme.includes('https://railway.com/deploy/'), 'Do not add a deploy URL before its rendered route is verified');

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

const appConfig = read('app/railway.toml');
assert.match(appConfig, /healthcheckPath="\/api\/v1\/health\/services"/);
assert.match(appConfig, /healthcheckTimeout=600/);
assert.ok(fs.existsSync(path.join(root, 'assets/pipeshub-icon-v060.png')));

console.log('Static template checks passed.');
