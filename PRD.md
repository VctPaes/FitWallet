# PRD - FitWallet: Controle Financeiro Rápido

## 0) Metadados do Projeto

* **Nome do Produto/Projeto:** FitWallet
* **Responsável:** Victor Luiz de Oliveira Paes
* **Curso/Disciplina:** Ciências da Computação/Desenvolvimento de Aplicações Móveis
* **Versão do PRD:** v1.3
* **Data:** 2025-10-23

## 1) Visão Geral

* **Resumo:** O FitWallet é um aplicativo móvel (Flutter) focado em ajudar estudantes a organizar suas finanças pessoais de forma rápida e simples. Ele foca em duas ações principais: registrar gastos diários e acompanhar uma meta de gastos semanal.
* **Problemas que ataca:** Falta de controle financeiro simples; dificuldade em visualizar o progresso de metas de gastos; interfaces de apps financeiros muito complexas para necessidades básicas.
* **Resultado desejado:** Uma primeira experiência de usuário rápida (onboarding), coleta de consentimento de privacidade (LGPD), e uma tela inicial funcional que permite ao usuário adicionar um gasto ou verificar sua meta em segundos.

## 2) Personas & Cenários de Primeiro Acesso

* **Persona principal:** Estudante de graduação (ex: "Victor") com rotina corrida, precisa de um app "direto ao ponto" para saber *quanto* gastou e *quanto ainda pode* gastar na semana.
* **Cenário (Happy Path):** Abrir app → Splash (decide rota) → Onboarding (3-4 telas) → Visualizar Política de Privacidade → Dar consentimento explícito → Home → Adicionar primeiro gasto.
* **Cenários Alternativos:**
    * Pular onboarding para a tela de consentimento.
    * Revogar consentimento no Drawer (Configurações) → Retorna ao fluxo de consentimento.
    * Adicionar/Alterar/Remover foto de perfil no Drawer.

## 3) Identidade do Tema (Design)

### 3.1 Paleta e Direção Visual

* **Primária (Emerald):** `#059669`
* **Secundária (Navy):** `#0B1220`
* **Acento (Gray):** `#475569`
* **Superfície/Texto:** `#FFFFFF` (Branco)
* [cite_start]**Direção:** Flat minimalista, alto contraste, `useMaterial3: true`.

### 3.2 Prompts (Imagens/Ícone)

* **Ícone do app:** "App icon design. A thin-line vector illustration of a simple, open-flap wallet icon. The wallet should be outlined in a subtle gray. A smaller, emerald green checkmark is cleanly integrated within the wallet's space. White background. Minimalist, modern, suitable for a mobile app icon."
* **Onboarding Hero (Tela 1):** "A minimalist vector illustration of a friendly student smiling and holding a smartphone that displays a wallet icon with a green checkmark. Clean lines, isolated on a white background. Color palette: emerald green, deep navy blue, slate gray."

## 4) Jornada & Funcionalidades (Escopo)

### 4.1 Onboarding e Consentimento
* **RF-1 (Onboarding):** Fluxo de 4 telas em PageView (`Bem-vindo`, `Como Funciona`, `Privacidade/LGPD`, `Tudo Pronto!`). Inclui botão "Pular".
* **RF-2 (Consentimento):** Leitura de política (simulada) com rolagem forçada (`_showPrivacyPolicy`). Checkbox de aceite só habilita após a leitura.
* **RF-3 (Revogação):** Opção no Drawer para "Limpar Consentimento". Redireciona para o Onboarding na página de consentimento.

### 4.2 Perfil do Usuário (Avatar)
* [cite_start]**RF-4 (UI do Avatar):** O Drawer (lado esquerdo) exibe um `UserAccountsDrawerHeader`.
* [cite_start]**RF-5 (Exibição):** Mostra a foto do usuário (lida do `userPhotoPath`) usando `FileImage`.
* [cite_start]**RF-6 (Fallback):** Se a foto for nula, exibe um `CircleAvatar` com as iniciais do usuário (ex: "U").
* [cite_start]**RF-7 (Ação):** Um botão de "Editar" sobreposto ao avatar abre um `BottomSheet`.
* [cite_start]**RF-8 (Seleção):** O BottomSheet oferece "Câmera", "Galeria" e "Remover Foto".
* [cite_start]**RF-9 (Processamento):** Imagem selecionada é comprimida (máx 512x512, Q80) e metadados EXIF são removidos usando `flutter_image_compress`.
* [cite_start]**RF-10 (Persistência):** A imagem comprimida é salva localmente (`avatar.jpg`) e o caminho é armazenado no `PrefsService`.
* [cite_start]**RF-11 (Remoção):** Ação "Remover" apaga o arquivo local e limpa a chave no `PrefsService`.

### 4.3 Finanças (Core Loop)
* **RF-12 (Meta Semanal):** `HomePage` exibe um card com a meta de gastos.
* **RF-13 (Progresso):** Uma `LinearProgressIndicator` mostra o total gasto vs. a meta.
* **RF-14 (CRUD de Transação):** Usuário pode Adicionar (via FAB), Editar (via `ListTile`) e Remover (via `ListTile`) transações.
* **RF-15 (Lista):** `HomePage` exibe a lista de transações recentes.

## 5) Requisitos Não Funcionais (RNF)

* **RNF-1 (A11Y):** Áreas de toque $\ge 48$dp, `Semantics` e `Tooltip` no avatar.
* **RNF-2 (Privacidade):** Armazenamento da foto é local (MVP). Remoção de EXIF/GPS da imagem.
* **RNF-3 (Arquitetura):** Separação de responsabilidades:
    * `HomePage` (UI)
    * `FinanceService` (Estado das Finanças, via Provider)
    * `PrefsService` (Estado de Configurações, via `SharedPreferences`).
* **RNF-4 (Testabilidade):** Serviços mockáveis para testes de widget.

## 6) Dados & Persistência (Chaves `PrefsService`)

* `onboarding_completed: bool`
* `marketing_consent: bool`
* `user_photo_path: string | null`
* `metaSemanal: double` (Gerenciado pelo `FinanceService` via `SharedPreferences`)
* `transacoes: List<String>` (Lista de JSONs, gerenciada pelo `FinanceService` via `SharedPreferences`)

## 7) Roteamento

* `/` → `SplashPage` (Decide rota baseado em `onboarding_completed`) 
* `/onboarding` → `OnboardingPage`
* `/home` → `HomePage` 
* *(Navegação interna: `AddGastoPage` via `Navigator.push`)*
