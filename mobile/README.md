# Voz da Fé — Flutter

App Android/iOS/Web com fala para texto em pt-BR, leitura por voz, reflexões por tema, orações, favoritos locais e compartilhamento.

## Preparar

É necessário ter Flutter estável instalado. As pastas de plataforma são geradas localmente pelo Flutter, para evitar arquivos nativos desatualizados.

```sh
cd mobile
flutter create . --project-name vozdafe --platforms android,ios,web
python3 tool/prepare_native.py
flutter pub get
flutter test
flutter run
```

Para iniciar no navegador:
```sh
flutter run -d chrome
```

### API opcional

Sem configuração, os cinco temas são atendidos localmente e funcionam offline. Para solicitar reflexões à API Rails:

```sh
flutter run --dart-define=VOZ_DA_FE_API_URL=https://api.seu-dominio.com
```

No emulador Android com API local em desenvolvimento use `http://10.0.2.2:3000`, mas tráfego HTTP sem TLS pode ser bloqueado pelo sistema e não deve ser liberado na versão de produção. Prefira HTTPS.

### Permissões e voz

- Android: `RECORD_AUDIO`, `INTERNET` e descoberta do serviço de reconhecimento de fala.
- iOS: `NSMicrophoneUsageDescription` e `NSSpeechRecognitionUsageDescription`.
- Web: reconhecimento de voz depende da disponibilidade do navegador e, em geral, de contexto seguro HTTPS ou localhost.
- Voz é iniciada apenas por toque no botão. O sistema operacional ou seu serviço de reconhecimento pode processar áudio de acordo com as próprias políticas; este app não armazena gravações.

### Observações

O aplicativo oferece leitura **referenciada** (ex.: Filipenses 4:6-7), não publica o texto integral de traduções bíblicas com direitos autorais. Reflexões e orações são textos originais temáticos, não aconselhamento médico ou psicológico.

Para distribuição na App Store/Google Play ainda são necessários conta de desenvolvedor, metadados, política de privacidade publicada, assinaturas e testes reais em aparelhos. O código foi preparado sem os arquivos de plataforma binários e sem chaves privadas.
