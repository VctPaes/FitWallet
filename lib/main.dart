import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- Core & Services ---
import 'services/prefs_service.dart';

// --- Feature Transaction ---
import 'features/transaction/data/datasources/transaction_local_datasource.dart';
import 'features/transaction/data/mappers/transacao_mapper.dart';
import 'features/transaction/data/repositories/transaction_repository_impl.dart';
import 'features/transaction/domain/repositories/transaction_repository.dart';
import 'features/transaction/domain/usecases/add_transaction_usecase.dart';
import 'features/transaction/domain/usecases/delete_transaction_usecase.dart';
import 'features/transaction/domain/usecases/get_transactions_usecase.dart';
import 'features/transaction/domain/usecases/update_transaction_usecase.dart';
import 'features/transaction/presentation/providers/transaction_provider.dart';

// --- Feature Goal ---
import 'features/goal/data/datasources/meta_local_datasource.dart';
import 'features/goal/data/mappers/meta_mapper.dart';
import 'features/goal/data/repositories/meta_repository_impl.dart';
import 'features/goal/domain/repositories/meta_repository.dart';
import 'features/goal/domain/usecases/get_meta_usecase.dart';
import 'features/goal/domain/usecases/update_meta_usecase.dart';
import 'features/goal/presentation/providers/goal_provider.dart';

// --- Pages ---
import 'features/transaction/presentation/pages/add_gasto_page.dart';
import 'pages/splash_page.dart';
import 'pages/home_page.dart';
import 'pages/onboarding_page.dart';
import 'pages/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await PrefsService.init(); // Seu serviço antigo de configs
  final sharedPreferences = await SharedPreferences.getInstance(); // Instância crua para os DataSources

  runApp(
    MultiProvider(
      providers: [
        // ==========================================
        // FEATURE: TRANSACTION
        // ==========================================
        
        // 1. Data Layer
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

        // 2. Domain Layer (UseCases)
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

        // 3. Presentation Layer (State)
        ChangeNotifierProvider(
          create: (context) => TransactionProvider(
            getTransactionsUseCase: context.read<GetTransactionsUseCase>(),
            addTransactionUseCase: context.read<AddTransactionUseCase>(),
            updateTransactionUseCase: context.read<UpdateTransactionUseCase>(),
            deleteTransactionUseCase: context.read<DeleteTransactionUseCase>(),
          )..loadTransactions(), // Carrega ao iniciar
        ),

        // ==========================================
        // FEATURE: GOAL (META)
        // ==========================================

        // 1. Data Layer
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

        // 2. Domain Layer
        Provider<GetMetaUseCase>(
          create: (context) => GetMetaUseCase(context.read<MetaRepository>()),
        ),
        Provider<UpdateMetaUseCase>(
          create: (context) => UpdateMetaUseCase(context.read<MetaRepository>()),
        ),

        // 3. Presentation Layer
        ChangeNotifierProvider(
          create: (context) => GoalProvider(
            getMetaUseCase: context.read<GetMetaUseCase>(),
            updateMetaUseCase: context.read<UpdateMetaUseCase>(),
          )..loadMeta(),
        ),
      ],
      child: FitWalletApp(prefs: prefs),
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
        // Nota: AddGastoPage geralmente é chamada via push, mas se quiser rota nomeada:
        // '/add-gasto': (ctx) => const AddGastoPage(), 
      },
    );
  }
}