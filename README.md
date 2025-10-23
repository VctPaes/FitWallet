# FitWallet 💰

![Built with Flutter](https://img.shields.io/badge/Built%20with-Flutter-02569B?logo=flutter)

FitWallet é um aplicativo móvel de controle financeiro desenvolvido em Flutter. O projeto foi criado com foco em estudantes e usuários que precisam de uma forma rápida e simples de controlar seus gastos diários e acompanhar uma meta de gastos semanal.

## 📱 Telas Principais

(Em breve: Adicionar GIFs e screenshots das telas principais do app)

* Tela de Onboarding (com consentimento de privacidade)
* Tela Inicial (Home) com a Meta Semanal e a Lista de Gastos
* Fluxo de Adicionar/Editar Gasto (Modal)
* Drawer de Navegação com o Avatar do Usuário

## ✨ Funcionalidades

O FitWallet implementa um conjunto de funcionalidades focadas na simplicidade e na experiência do usuário:

* **Controle de Gastos:**
    * Adicione, edite e remova transações financeiras.
    * Visualize todos os gastos recentes em uma lista na tela inicial.
* **Meta Semanal:**
    * Defina uma meta de gastos semanal.
    * Acompanhe o progresso em relação à meta com uma barra visual.
* **Onboarding do Usuário:**
    * Um fluxo de introdução de várias etapas para novos usuários.
    * Coleta de consentimento de Política de Privacidade (simulando conformidade com a LGPD).
* **Perfil do Usuário com Avatar:**
    * Adicione uma foto de perfil personalizada tirando uma foto com a **Câmera** ou escolhendo da **Galeria**.
    * **Compressão de Imagem:** As imagens são redimensionadas (máx 512x512) e comprimidas (qualidade 80) antes de salvar.
    * **Privacidade:** Metadados sensíveis (EXIF) são removidos da imagem.
    * **Armazenamento Local:** A foto é salva com segurança no diretório de documentos do aplicativo.
    * Suporte para **remover** a foto e reverter para um avatar com as iniciais do usuário (fallback).
* **Persistência de Dados:**
    * Todas as transações, a meta semanal e o caminho da foto do avatar são salvos localmente usando `shared_preferences`.
    * Os dados persistem mesmo após o fechamento do aplicativo.

## 🛠️ Tecnologias Utilizadas

Este projeto utiliza um conjunto de pacotes modernos e recomendados para o desenvolvimento Flutter:

* **Framework:** [Flutter](https://flutter.dev/)
* **Gerenciamento de Estado:** [Provider](https://pub.dev/packages/provider)
* **Armazenamento Local:** [Shared Preferences](https://pub.dev/packages/shared_preferences)
* **Seleção de Imagem (Câmera/Galeria):** [image_picker](https://pub.dev/packages/image_picker)
* **Processamento de Imagem:** [flutter_image_compress](https://pub.dev/packages/flutter_image_compress)
* **Gerenciamento de Caminhos de Arquivo:** [path_provider](https://pub.dev/packages/path_provider)

## 🚀 Como Executar o Projeto

1.  **Clone o repositório:**
    ```bash
    git clone [URL_DO_SEU_REPOSITORIO]
    cd fitwallet
    ```

2.  **Instale as dependências:**
    ```bash
    flutter pub get
    ```

3.  **Configure as Permissões (para o Avatar):**
    * Certifique-se de que as permissões de Câmera e Galeria estão configuradas:
    * **iOS:** Adicione as chaves `NSPhotoLibraryUsageDescription` e `NSCameraUsageDescription` ao arquivo `ios/Runner/Info.plist`.
    * **Android:** Adicione a permissão `android.permission.CAMERA` ao `android/app/src/main/AndroidManifest.xml` (se necessário).

4.  **Execute o aplicativo:**
    ```bash
    flutter run
    ```

## 🎓 Contexto do Projeto

Este aplicativo foi desenvolvido como um projeto acadêmico, com o objetivo de aplicar conceitos de desenvolvimento móvel com Flutter. O foco foi construir um app funcional, desde o onboarding até a persistência de dados local, seguindo boas práticas de gerenciamento de estado e integração com APIs nativas (câmera e galeria).
