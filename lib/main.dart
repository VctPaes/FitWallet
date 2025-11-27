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
import 'features/user/presentation/providers/user_provider.dart';

// --- Pages (Telas) ---
import 'pages/splash_page.dart';
import 'pages/home_page.dart';
import 'pages/onboarding_page.dart';
import 'pages/settings_page.dart';
// A AddGastoPage não precisa ser importada aqui se não for uma rota nomeada, 
// mas deixamos caso precise no futuro.
import 'features/transaction/presentation/pages/add_gasto_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inicialização de Serviços Externos
  // Mantemos o PrefsService legado para configurações simples (tema, onboarding)
  final prefsService = await PrefsService.init(); 
  
  // Instância crua do SharedPreferences para ser injetada nos DataSources da Clean Arch
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        // ==========================================
        // FEATURE: TRANSACTION
        // ==========================================
        
        // Data Layer
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

        // Domain Layer (UseCases)
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

        // Presentation Layer (State)
        ChangeNotifierProvider(
          create: (context) => TransactionProvider(
            getTransactionsUseCase: context.read<GetTransactionsUseCase>(),
            addTransactionUseCase: context.read<AddTransactionUseCase>(),
            updateTransactionUseCase: context.read<UpdateTransactionUseCase>(),
            deleteTransactionUseCase: context.read<DeleteTransactionUseCase>(),
          )..loadTransactions(), // Carrega dados ao iniciar o app
        ),

        // ==========================================
        // FEATURE: GOAL (META)
        // ==========================================

        // Data Layer
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

        // Domain Layer (UseCases)
        Provider<GetMetaUseCase>(
          create: (context) => GetMetaUseCase(context.read<MetaRepository>()),
        ),
        Provider<UpdateMetaUseCase>(
          create: (context) => UpdateMetaUseCase(context.read<MetaRepository>()),
        ),

        // Presentation Layer (State)
        ChangeNotifierProvider(
          create: (context) => GoalProvider(
            getMetaUseCase: context.read<GetMetaUseCase>(),
            updateMetaUseCase: context.read<UpdateMetaUseCase>(),
          )..loadMeta(), // Carrega dados ao iniciar o app
        ),

        // ==========================================
        // FEATURE: USER (USUÁRIO)
        // ==========================================
        
        // Data Layer
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

        // Domain Layer (UseCases)
        Provider<GetUsuarioUseCase>(
          create: (context) => GetUsuarioUseCase(context.read<UsuarioRepository>()),
        ),
        Provider<UpdateUsuarioFotoUseCase>(
          create: (context) => UpdateUsuarioFotoUseCase(context.read<UsuarioRepository>()),
        ),
        Provider<RemoveUsuarioFotoUseCase>(
          create: (context) => RemoveUsuarioFotoUseCase(context.read<UsuarioRepository>()),
        ),

        // Presentation Layer (State)
        ChangeNotifierProvider(
          create: (context) => UserProvider(
            getUsuarioUseCase: context.read<GetUsuarioUseCase>(),
            updateUsuarioFotoUseCase: context.read<UpdateUsuarioFotoUseCase>(),
            removeUsuarioFotoUseCase: context.read<RemoveUsuarioFotoUseCase>(),
          )..loadUsuario(), // Carrega dados ao iniciar o app
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
        '/home': (ctx) => HomePage(prefs: prefs),
        '/settings': (ctx) => SettingsPage(prefs: prefs),
      },
    );
  }
}