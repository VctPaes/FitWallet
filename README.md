# Fluxo Inicial Flutter

Este repositório implementa o fluxo inicial funcional solicitado:

- Splash configurado via **flutter_native_splash**
- Tela de Splash em Flutter que decide a rota inicial com base no `SharedPreferences`
- Onboarding com 4 páginas (Welcome, How it Works, Consentimento, Go to Access)
- Indicadores de progresso (dots)
- Controles de navegação (Avançar, Voltar, Pular) com visibilidade contextual
- Persistência com `SharedPreferences` (`onboarding_completed`, `marketing_consent`)

---

## Como rodar o projeto

1. Clone ou extraia este repositório em seu computador
2. Instale as dependências do Flutter:
   ```bash
   flutter pub get
   ```
3. Gere os assets de splash (se alterou o `pubspec.yaml` ou a imagem `assets/splash.png`):
   ```bash
   flutter pub run flutter_native_splash:create
   ```
4. Rode o app em um emulador ou dispositivo físico:
   ```bash
   flutter run
   ```

---

## Roteiro de testes

1. **Primeira execução**: deve abrir Splash -> Onboarding (com dots e botões corretos)
2. **Botão Pular**: leva diretamente à tela de Consentimento
3. **Consentimento**: botão Confirmar só habilita após interação com switch
4. **Finalizar Onboarding**: salva flag `onboarding_completed = true` e abre Home
5. **Reabrir app**: vai direto para Home (sem Onboarding)

---

## Observações LGPD / UX / A11Y

- Consentimento de marketing é **opt-in** (switch desligado por padrão, botão só ativa após interação)
- Flags de consentimento e onboarding salvas separadamente
- Botões contextuais evitam confusão mas mantêm previsibilidade para acessibilidade
- Layout responsivo e cores baseadas no `ColorScheme` do Material 3

---

## Estrutura de pastas

```
lib/
 ├─ main.dart
 ├─ pages/
 │   ├─ splash_page.dart
 │   ├─ onboarding_page.dart
 │   ├─ consent_page.dart
 │   ├─ go_to_access_page.dart
 │   └─ home_page.dart
 ├─ widgets/
 │   └─ dots_indicator.dart
 └─ services/
     └─ prefs_service.dart
```
