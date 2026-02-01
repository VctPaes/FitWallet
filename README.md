# FitWallet

![Built with Flutter](https://img.shields.io/badge/Built%20with-Flutter-02569B?logo=flutter)
![State Management](https://img.shields.io/badge/State-Provider-795548)
![Backend](https://img.shields.io/badge/Backend-Supabase-3ECF8E?logo=supabase)

**FitWallet** é uma aplicação de controle financeiro desenvolvida em Flutter, focada na experiência do usuário para registro rápido de despesas e acompanhamento de metas semanais. Este projeto demonstra a implementação de uma arquitetura robusta e escalável, integração com serviços em nuvem e manipulação avançada de mídia.

## Funcionalidades

O aplicativo foi desenhado para resolver o problema da complexidade em apps financeiros, oferecendo:

* **Gestão de Transações:** CRUD completo (Adicionar, Ler, Editar, Remover) de despesas diárias com categorização.
* **Meta Semanal Inteligente:** Visualização de progresso de gastos com feedback visual (`LinearProgressIndicator`) para controle orçamentário.
* **Autenticação Segura:** Sistema de Login e Cadastro de usuários integrado via Supabase.
* **Perfil e Avatar:**
    * Upload de foto via Câmera ou Galeria.
    * Compressão automática e redimensionamento de imagens para otimização de armazenamento.
    * Remoção de metadados sensíveis (EXIF) para privacidade.
* **Onboarding & Privacidade:** Fluxo de boas-vindas com coleta de consentimento explícito (LGPD) e persistência de preferências locais.

## Tecnologias e Ferramentas

O projeto utiliza um ecossistema moderno de desenvolvimento mobile:

* **Linguagem:** Dart (SDK >=2.18.0).
* **Framework:** Flutter (Material Design 3).
* **Gerência de Estado:** Provider.
* **Backend as a Service (BaaS):** Supabase (Autenticação e Banco de Dados).
* **Armazenamento Local:** Shared Preferences (para configurações e cache).
* **Multimídia:**
    * `image_picker` (Seleção de imagens).
    * `flutter_image_compress` (Compressão nativa).
* **Utilitários:** `flutter_dotenv` (Variáveis de ambiente), `url_launcher`.

## Arquitetura e Padrões de Projeto

Este projeto foi estruturado seguindo os princípios da **Clean Architecture** para garantir testabilidade e manutenibilidade:

* **Feature-First:** Organização por funcionalidades (`auth`, `transaction`, `goal`, `user`).
* **Camadas Separadas:**
    * **Domain:** Entidades, Casos de Uso (Use Cases) e Contratos de Repositório (sem dependências externas).
    * **Data:** Implementação dos Repositórios, Data Sources (Remote/Local), DTOs e Mappers.
    * **Presentation:** Pages, Widgets e Providers (Gerenciamento de Lógica de UI).
* **Padrões Aplicados:** Repository Pattern, Adapter Pattern (Mappers), Dependency Injection (via Provider).

## Habilidades Demonstradas

O desenvolvimento do FitWallet permitiu a aplicação prática das seguintes competências:

* Desenvolvimento de interfaces responsivas e fiéis ao protótipo (Pixel Perfect).
* Integração de APIs RESTful e serviços de Backend (Supabase).
* Manipulação de I/O de arquivos e hardware do dispositivo (Câmera).
* Gestão de ciclo de vida da aplicação e persistência de dados.
* Implementação de regras de negócio complexas isoladas da interface.

## Como Executar

1.  **Clone o repositório:**
    ```bash
    git clone [https://github.com/seu-usuario/fitwallet.git](https://github.com/seu-usuario/fitwallet.git)
    ```
2.  **Configure as Variáveis de Ambiente:**
    Crie um arquivo `.env` na raiz baseado no `.env.example` e adicione suas credenciais do Supabase.
3.  **Instale as dependências:**
    ```bash
    flutter pub get
    ```
4.  **Execute o app:**
    ```bash
    flutter run
    ```
