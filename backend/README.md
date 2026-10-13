# API Voz da Fé

Rails API-only, sem banco de dados e sem custo de IA para esta primeira versão.

\`\`\`sh
bundle install
bundle exec rails server
bundle exec rails test
\`\`\`

- POST \`/api/analyze\` (legado) e POST \`/api/v1/devotionals\`: JSON \`{"message":"Estou ansioso"}\`; máximo 500 caracteres.
- GET \`/health\`: healthcheck.
- Resposta: id, theme, title, verse_reference, reflection, prayer, practice, created_at.
- Erro 422: \`{"error":"..."}\`.
- Deploy: \`docker build -t vozdafe-api .\` e configure \`SECRET_KEY_BASE\`, \`ALLOWED_HOSTS\`, \`FORCE_SSL=true\` e \`CORS_ORIGINS\` no host HTTPS.
