import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- Core & Services ---
import 'core/services/prefs_service.dart';
import 'core/presentation/providers/theme_provider.dart';

// --- Feature: Transaction ---
import 'features/transaction/data/datasources/transaction_local_datasource.dart';
import 'features/transaction/data/datasources/transaction_remote_datasource.dart';
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
import 'features/goal/data/datasources/meta_remote_datasource.dart';
import 'features/goal/data/mappers/meta_mapper.dart';
import 'features/goal/data/repositories/meta_repository_impl.dart';
import 'features/goal/domain/repositories/meta_repository.dart';
import 'features/goal/domain/usecases/get_meta_usecase.dart';
import 'features/goal/domain/usecases/update_meta_usecase.dart';
import 'features/goal/presentation/providers/goal_provider.dart';

// --- Feature: User (Usuário) ---
import 'features/user/data/datasources/usuario_local_datasource.dart';
import 'features/user/data/datasources/usuario_remote_datasource.dart';
import 'features/user/data/mappers/usuario_mapper.dart';
import 'features/user/data/repositories/usuario_repository_impl.dart';
import 'features/user/domain/repositories/usuario_repository.dart';
import 'features/user/domain/usecases/get_usuario_usecase.dart';
import 'features/user/domain/usecases/update_usuario_foto_usecase.dart';
import 'features/user/domain/usecases/remove_usuario_foto_usecase.dart';
import 'features/user/domain/usecases/update_usuario_nome_usecase.dart';
import 'features/user/presentation/providers/user_provider.dart';

// --- Feature: Category ---
import 'features/category/data/datasources/categoria_local_datasource.dart';
import 'features/category/data/mappers/categoria_mapper.dart';
import 'features/category/data/repositories/categoria_repository_impl.dart';
import 'features/category/domain/repositories/categoria_repository.dart';
import 'features/category/domain/usecases/get_categorias_usecase.dart';
import 'features/category/presentation/providers/category_provider.dart';

// --- Feature: Auth (NOVO) ---
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/sign_in_usecase.dart';
import 'features/auth/domain/usecases/sign_up_usecase.dart';
import 'features/auth/domain/usecases/sign_out_usecase.dart';
import 'features/auth/domain/usecases/get_current_user_usecase.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/pages/auth_page.dart';

// --- Pages ---
import 'features/splash/presentation/pages/splash_page.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';
import 'features/home/presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  final prefsService = await PrefsService.init();
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        // ==========================================
        // FEATURE: AUTH
        // ==========================================
        Provider<AuthRemoteDataSource>(
          create: (_) => AuthRemoteDataSourceImpl(Supabase.instance.client),
        ),
        Provider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(context.read<AuthRemoteDataSource>()),
        ),
        // UseCases Auth
        Provider<SignInUseCase>(create: (ctx) => SignInUseCase(ctx.read<AuthRepository>())),
        Provider<SignUpUseCase>(create: (ctx) => SignUpUseCase(ctx.read<AuthRepository>())),
        Provider<SignOutUseCase>(create: (ctx) => SignOutUseCase(ctx.read<AuthRepository>())),
        Provider<GetCurrentUserUseCase>(create: (ctx) => GetCurrentUserUseCase(ctx.read<AuthRepository>())),
        
        // Provider Auth (Presentation)
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            signInUseCase: context.read<SignInUseCase>(),
            signUpUseCase: context.read<SignUpUseCase>(),
            signOutUseCase: context.read<SignOutUseCase>(),
            getCurrentUserUseCase: context.read<GetCurrentUserUseCase>(),
          ),
        ),

        // ==========================================
        // FEATURE: TRANSACTION
        // ==========================================
        Provider<TransactionLocalDataSource>(
          create: (_) => TransactionLocalDataSourceImpl(sharedPreferences),
        ),
        Provider<TransactionRemoteDataSource>(
          create: (_) => TransactionRemoteDataSourceImpl(Supabase.instance.client),
        ),
        Provider<TransacaoMapper>(
          create: (_) => TransacaoMapper(),
        ),
        Provider<TransactionRepository>(
          create: (context) => TransactionRepositoryImpl(
            context.read<TransactionLocalDataSource>(),
            context.read<TransactionRemoteDataSource>(),
            context.read<TransacaoMapper>(),
          ),
        ),
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
        ChangeNotifierProvider(
          create: (context) => TransactionProvider(
            repository: context.read<TransactionRepository>(),
            addTransactionUseCase: context.read<AddTransactionUseCase>(),
            updateTransactionUseCase: context.read<UpdateTransactionUseCase>(),
            deleteTransactionUseCase: context.read<DeleteTransactionUseCase>(),
          )..loadTransactions(),
        ),

        // ==========================================
        // FEATURE: GOAL
        // ==========================================
        Provider<MetaLocalDataSource>(
          create: (_) => MetaLocalDataSourceImpl(sharedPreferences),
        ),
        Provider<MetaRemoteDataSource>(
          create: (_) => MetaRemoteDataSourceImpl(Supabase.instance.client),
        ),
        Provider<MetaMapper>(
          create: (_) => MetaMapper(),
        ),
        Provider<MetaRepository>(
          create: (context) => MetaRepositoryImpl(
            context.read<MetaLocalDataSource>(),
            context.read<MetaRemoteDataSource>(),
            context.read<MetaMapper>(),
          ),
        ),
        Provider<GetMetaUseCase>(
          create: (context) => GetMetaUseCase(context.read<MetaRepository>()),
        ),
        Provider<UpdateMetaUseCase>(
          create: (context) => UpdateMetaUseCase(context.read<MetaRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) => GoalProvider(
            getMetaUseCase: context.read<GetMetaUseCase>(),
            updateMetaUseCase: context.read<UpdateMetaUseCase>(),
          )..loadMeta(),
        ),

        // ==========================================
        // FEATURE: USER
        // ==========================================
        Provider<UsuarioLocalDataSource>(
          create: (_) => UsuarioLocalDataSourceImpl(sharedPreferences),
        ),
        Provider<UsuarioRemoteDataSource>(
          create: (_) => UsuarioRemoteDataSourceImpl(Supabase.instance.client),
        ),
        Provider<UsuarioMapper>(
          create: (_) => UsuarioMapper(),
        ),
        Provider<UsuarioRepository>(
          create: (context) => UsuarioRepositoryImpl(
            context.read<UsuarioLocalDataSource>(),
            context.read<UsuarioRemoteDataSource>(),
            context.read<UsuarioMapper>(),
          ),
        ),
        Provider<GetUsuarioUseCase>(
          create: (context) => GetUsuarioUseCase(context.read<UsuarioRepository>()),
        ),
        Provider<UpdateUsuarioFotoUseCase>(
          create: (context) => UpdateUsuarioFotoUseCase(context.read<UsuarioRepository>()),
        ),
        Provider<RemoveUsuarioFotoUseCase>(
          create: (context) => RemoveUsuarioFotoUseCase(context.read<UsuarioRepository>()),
        ),
        Provider<UpdateUsuarioNomeUseCase>(
          create: (context) => UpdateUsuarioNomeUseCase(context.read<UsuarioRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) => UserProvider(
            getUsuarioUseCase: context.read<GetUsuarioUseCase>(),
            updateUsuarioFotoUseCase: context.read<UpdateUsuarioFotoUseCase>(),
            removeUsuarioFotoUseCase: context.read<RemoveUsuarioFotoUseCase>(),
            updateUsuarioNomeUseCase: context.read<UpdateUsuarioNomeUseCase>(),
          )..loadUsuario(),
        ),

        // ==========================================
        // FEATURE: THEME
        // ==========================================
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(
            prefs: prefsService,
          )..loadTheme(),
        ),

        // ==========================================
        // FEATURE: CATEGORY
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
        Provider<GetCategoriasUseCase>(
          create: (context) => GetCategoriasUseCase(context.read<CategoriaRepository>()),
        ),
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
    final lightColorScheme = ColorScheme.fromSeed(
      seedColor: emerald,
      primary: emerald,
      secondary: gray,
      brightness: Brightness.light,
      surface: Colors.white,
    );

    final darkColorScheme = ColorScheme.fromSeed(
      seedColor: emerald,
      primary: emerald,
      secondary: gray,
      brightness: Brightness.dark,
      surface: const Color(0xFF121212), 
    );

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'FitWallet',
          
          themeMode: themeProvider.themeMode,
          
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightColorScheme,
            appBarTheme: const AppBarTheme(
              backgroundColor: navy,
              foregroundColor: Colors.white,
            ),
          ),
          
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkColorScheme,
            appBarTheme: AppBarTheme(
              backgroundColor: const Color(0xFF0F172A),
              foregroundColor: emerald,
            ),
            scaffoldBackgroundColor: const Color(0xFF121212),
          ),

          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          routes: {
            '/': (ctx) => SplashPage(prefs: prefs),
            '/onboarding': (ctx) => OnboardingPage(prefs: prefs),
            '/auth': (ctx) => const AuthPage(),
            '/settings': (ctx) => SettingsPage(prefs: prefs),
            '/home': (ctx) => HomePage(prefs: prefs),
          },
        );
      },
    );
  }
}