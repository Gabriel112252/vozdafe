# Voz da Fé

Aplicativo cristão para receber uma palavra bíblica, reflexão e oração a partir do que a pessoa está sentindo. Inclui entrada por voz, leitura em voz alta, compartilhamento e favoritos.

Este repositório tem **um app Flutter** (`mobile/`) e **uma API Rails** (`backend/`). O app funciona também sem conexão com a API, usando conteúdo temático integrado.

## Início rápido

### Aplicativo (Flutter)
1. Instale Flutter estável e entre em `mobile/`.
2. Execute `flutter create . --project-name vozdafe --platforms android,ios,web` (gera apenas as pastas nativas não versionadas).
3. Configure permissões de microfone e reconhecimento de fala conforme `mobile/README.md`.
4. Execute `flutter pub get && flutter run`.
5. Para usar a API: `flutter run --dart-define=VOZ_DA_FE_API_URL=http://SEU_IP:3000`.

### API (Ruby on Rails)
1. Ruby 3.2+, Bundler. Entre em `backend/`.
2. `bundle install && bundle exec rails server -b 0.0.0.0`.
3. Teste `curl -X POST http://localhost:3000/api/analyze -H 'Content-Type: application/json' -d '{"message":"Estou ansioso com o amanhã"}'`.

A API também atende `POST /api/v1/devotionals` e `GET /health`. Nenhuma chave de IA é necessária para a versão inicial: textos são curados e escolhidos por tema, sem inventar versículos.

## Privacidade e segurança

O aplicativo guarda os favoritos no dispositivo. O reconhecimento de fala usa os serviços disponíveis no sistema operacional; o comportamento de processamento por terceiros depende das configurações do aparelho. O texto é enviado à API configurada apenas quando o usuário solicita uma reflexão; sem API, o processamento temático fica no app. **Não é aconselhamento médico, psicológico ou pastoral profissional.**

## Escopo desta versão
- Escrever ou falar como está se sentindo
- Receber passagem para leitura, reflexão, oração e gesto prático
- Ouvir a reflexão/oração com voz pt-BR
- Salvar/remover favoritos, copiar/compartilhar
- API compatível com `/api/analyze` anterior, endpoint de saúde, testes
- Dockerfile para API

> O repositório estava vazio quando esta versão foi criada. Arquivos preexistentes apenas no computador local não foram substituídos nem incorporados.
