import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- Core & Services ---
import 'core/services/prefs_service.dart';

// --- Feature: Transaction (Transações) ---
import 'features/transaction/data/datasources/transaction_local_datasource.dart';
import 'features/transaction/data/mappers/transacao_mapper.dart';
import 'features/transaction/data/repositories/transaction_repository_impl.dart';
import 'features/transaction/domain/repositories/transaction_repository.dart';
import 'features/transaction/domain/usecases/add_transaction_usecase.dart';
import 'features/transaction/domain/usecases/delete_transaction_usecase.dart';
import 'features/transaction/domain/usecases/get_transactions_usecase.dart';
import 'features/transaction/domain/usecases/update_transaction_usecase.dart';
import 'features/transaction/presentation/providers/transaction_provider.dart';

// --- Feature: Goal (Meta) ---
import 'features/goal/data/datasources/meta_local_datasource.dart';
import 'features/goal/data/mappers/meta_mapper.dart';
import 'features/goal/data/repositories/meta_repository_impl.dart';
import 'features/goal/domain/repositories/meta_repository.dart';
import 'features/goal/domain/usecases/get_meta_usecase.dart';
import 'features/goal/domain/usecases/update_meta_usecase.dart';
import 'features/goal/presentation/providers/goal_provider.dart';

// --- Feature: User (Usuário) ---
import 'features/user/data/datasources/usuario_local_datasource.dart';
import 'features/user/data/mappers/usuario_mapper.dart';
import 'features/user/data/repositories/usuario_repository_impl.dart';
import 'features/user/domain/repositories/usuario_repository.dart';
import 'features/user/domain/usecases/get_usuario_usecase.dart';
import 'features/user/domain/usecases/update_usuario_foto_usecase.dart';
import 'features/user/domain/usecases/remove_usuario_foto_usecase.dart';
import 'features/user/domain/usecases/update_usuario_nome_usecase.dart'; // <--- Importado aqui
import 'features/user/presentation/providers/user_provider.dart';

// --- Feature: Category (Categoria) ---
import 'features/category/data/datasources/categoria_local_datasource.dart';
import 'features/category/data/mappers/categoria_mapper.dart';
import 'features/category/data/repositories/categoria_repository_impl.dart';
import 'features/category/domain/repositories/categoria_repository.dart';
import 'features/category/domain/usecases/get_categorias_usecase.dart';
import 'features/category/presentation/providers/category_provider.dart';

// --- Pages (Telas) ---
import 'features/splash/presentation/pages/splash_page.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';
import 'features/home/presentation/pages/home_page.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inicialização de Serviços Externos
  final prefsService = await PrefsService.init();
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        // ==========================================
        // FEATURE: TRANSACTION
        // ==========================================
        Provider<TransactionLocalDataSource>(
          create: (_) => TransactionLocalDataSourceImpl(sharedPreferences),
        ),
        Provider<TransacaoMapper>(
          create: (_) => TransacaoMapper(),
        ),
        Provider<TransactionRepository>(
          create: (context) => TransactionRepositoryImpl(
            context.read<TransactionLocalDataSource>(),
            context.read<TransacaoMapper>(),
          ),
        ),
        // UseCases
        Provider<GetTransactionsUseCase>(
          create: (context) => GetTransactionsUseCase(context.read<TransactionRepository>()),
        ),
        Provider<AddTransactionUseCase>(
          create: (context) => AddTransactionUseCase(context.read<TransactionRepository>()),
        ),
        Provider<UpdateTransactionUseCase>(
          create: (context) => UpdateTransactionUseCase(context.read<TransactionRepository>()),
        ),
        Provider<DeleteTransactionUseCase>(
          create: (context) => DeleteTransactionUseCase(context.read<TransactionRepository>()),
        ),
        // Provider (Presentation)
        ChangeNotifierProvider(
          create: (context) => TransactionProvider(
            repository: context.read<TransactionRepository>(),
            addTransactionUseCase: context.read<AddTransactionUseCase>(),
            updateTransactionUseCase: context.read<UpdateTransactionUseCase>(),
            deleteTransactionUseCase: context.read<DeleteTransactionUseCase>(),
          )..loadTransactions(),
        ),

        // ==========================================
        // FEATURE: GOAL (META)
        // ==========================================
        Provider<MetaLocalDataSource>(
          create: (_) => MetaLocalDataSourceImpl(sharedPreferences),
        ),
        Provider<MetaMapper>(
          create: (_) => MetaMapper(),
        ),
        Provider<MetaRepository>(
          create: (context) => MetaRepositoryImpl(
            context.read<MetaLocalDataSource>(),
            context.read<MetaMapper>(),
          ),
        ),
        // UseCases
        Provider<GetMetaUseCase>(
          create: (context) => GetMetaUseCase(context.read<MetaRepository>()),
        ),
        Provider<UpdateMetaUseCase>(
          create: (context) => UpdateMetaUseCase(context.read<MetaRepository>()),
        ),
        // Provider (Presentation)
        ChangeNotifierProvider(
          create: (context) => GoalProvider(
            getMetaUseCase: context.read<GetMetaUseCase>(),
            updateMetaUseCase: context.read<UpdateMetaUseCase>(),
          )..loadMeta(),
        ),

        // ==========================================
        // FEATURE: USER (USUÁRIO)
        // ==========================================
        Provider<UsuarioLocalDataSource>(
          create: (_) => UsuarioLocalDataSourceImpl(sharedPreferences),
        ),
        Provider<UsuarioMapper>(
          create: (_) => UsuarioMapper(),
        ),
        Provider<UsuarioRepository>(
          create: (context) => UsuarioRepositoryImpl(
            context.read<UsuarioLocalDataSource>(),
            context.read<UsuarioMapper>(),
          ),
        ),
        // UseCases
        Provider<GetUsuarioUseCase>(
          create: (context) => GetUsuarioUseCase(context.read<UsuarioRepository>()),
        ),
        Provider<UpdateUsuarioFotoUseCase>(
          create: (context) => UpdateUsuarioFotoUseCase(context.read<UsuarioRepository>()),
        ),
        Provider<RemoveUsuarioFotoUseCase>(
          create: (context) => RemoveUsuarioFotoUseCase(context.read<UsuarioRepository>()),
        ),
        // --- Novo UseCase para Editar Nome ---
        Provider<UpdateUsuarioNomeUseCase>(
          create: (context) => UpdateUsuarioNomeUseCase(context.read<UsuarioRepository>()),
        ),
        
        // Provider (Presentation)
        ChangeNotifierProvider(
          create: (context) => UserProvider(
            getUsuarioUseCase: context.read<GetUsuarioUseCase>(),
            updateUsuarioFotoUseCase: context.read<UpdateUsuarioFotoUseCase>(),
            removeUsuarioFotoUseCase: context.read<RemoveUsuarioFotoUseCase>(),
            // Injete o novo UseCase aqui:
            updateUsuarioNomeUseCase: context.read<UpdateUsuarioNomeUseCase>(),
          )..loadUsuario(),
        ),

        // ==========================================
        // FEATURE: CATEGORY (CATEGORIA)
        // ==========================================
        Provider<CategoriaLocalDataSource>(
          create: (_) => CategoriaLocalDataSourceImpl(sharedPreferences),
        ),
        Provider<CategoriaMapper>(
          create: (_) => CategoriaMapper(),
        ),
        Provider<CategoriaRepository>(
          create: (context) => CategoriaRepositoryImpl(
            context.read<CategoriaLocalDataSource>(),
            context.read<CategoriaMapper>(),
          ),
        ),
        // UseCases
        Provider<GetCategoriasUseCase>(
          create: (context) => GetCategoriasUseCase(context.read<CategoriaRepository>()),
        ),
        // Provider (Presentation)
        ChangeNotifierProvider(
          create: (context) => CategoryProvider(
            getCategoriasUseCase: context.read<GetCategoriasUseCase>(),
          )..loadCategorias(),
        ),
      ],
      child: FitWalletApp(prefs: prefsService),
    ),
  );
}

class FitWalletApp extends StatelessWidget {
  final PrefsService prefs;
  const FitWalletApp({super.key, required this.prefs});

  static const emerald = Color(0xFF059669);
  static const navy = Color(0xFF0B1220);
  static const gray = Color(0xFF475569);

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: emerald,
      primary: emerald,
      secondary: gray,
      background: Colors.white,
      surface: Colors.white,
    );

    return MaterialApp(
      title: 'FitWallet',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        appBarTheme: const AppBarTheme(
          backgroundColor: navy,
          foregroundColor: Colors.white,
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (ctx) => SplashPage(prefs: prefs),
        '/onboarding': (ctx) => OnboardingPage(prefs: prefs),
        '/settings': (ctx) => SettingsPage(prefs: prefs),
        '/home': (ctx) => HomePage(prefs: prefs),
      },
    );
  }
}