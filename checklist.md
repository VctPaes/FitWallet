# Checklist de Entrega - Arquitetura de Domínio

Projeto: **FitWallet**
Aluno: **{{Seu Nome Aqui}}**

Este checklist confirma a implementação da arquitetura Entity/DTO/Mapper para as quatro entidades de domínio solicitadas.

---

### 1. Entidade: `Usuario`
- [x] **Entity:** `lib/features/user/domain/entities/usuario.dart`
- [x] **Value Object:** `lib/features/user/domain/value_objects/email.dart` (Garante tipo forte e invariante)
- [x] **DTO:** `lib/features/user/data/dtos/usuario_dto.dart`
- [x] **Mapper:** `lib/features/user/data/mappers/usuario_mapper.dart` (Converte `String` ↔ `Email`)
- [x] **Exemplo/Teste:** `lib/example_mapper_test.dart` (Função `runMapperExamples()`)

### 2. Entidade: `Transacao`
- [x] **Entity:** `lib/features/transaction/domain/entities/transacao.dart` (Garante valor positivo)
- [x] **DTO:** `lib/features/transaction/data/dtos/transacao_dto.dart`
- [x] **Mapper:** `lib/features/transaction/data/mappers/transacao_mapper.dart` (Converte `String` Data ↔ `DateTime`)
- [x] **Exemplo/Teste:** `lib/example_mapper_test.dart` (Função `runMapperExamples()`)

### 3. Entidade: `Categoria`
- [x] **Entity:** `lib/features/category/domain/entities/categoria.dart` (Usa tipos puros `int` para ícone/cor, sem `IconData` do Flutter)
- [x] **DTO:** `lib/features/category/data/dtos/categoria_dto.dart`
- [x] **Mapper:** `lib/features/category/data/mappers/categoria_mapper.dart`
- [x] **Exemplo/Teste:** `lib/example_mapper_test.dart` (Função `runMapperExamples()`)

### 4. Entidade: `Meta`
- [x] **Entity:** `lib/features/goal/domain/entities/meta.dart` (Garante valor positivo)
- [x] **DTO:** `lib/features/goal/data/dtos/meta_dto.dart`
- [x] **Mapper:** `lib/features/goal/data/mappers/meta_mapper.dart`
- [x] **Exemplo/Teste:** `lib/example_mapper_test.dart` (Função `runMapperExamples()`)