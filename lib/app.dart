import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:omkar_sale/commons/cubits/agenda_cubit.dart';
import 'package:omkar_sale/commons/cubits/app_config_cubit.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';
import 'package:omkar_sale/features/location/service/background_sync_service.dart';
import 'package:omkar_sale/features/location/service/tracker_watchdog.dart';
import 'package:omkar_sale/features/shop/cubit/get_shop_cubit.dart';
import 'package:omkar_sale/utils/notification_utils/notification_utils.dart';

Future<Widget> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  }

  if (Firebase.apps.isNotEmpty) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } else {
    await Firebase.initializeApp();
  }
  await Hive.initFlutter();
  await NotificationService.instance.init();

  await SettingLocalRepository.instance.init();
  await AuthLocalRepository.instance.init();
  await LocationRepository.init();
  await TrackerWatchdog.initialize();

  // Open the clock in/out repository box
  await Hive.openBox(ClockInOutRepository.kClockInOutBoxName);

  // Start the background sync listener
  BackgroundSyncService.instance.initialize();

  HttpOverrides.global = MyHttpOverrides();

  EquatableConfig.stringify = false;

  return const MyApp();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final ts = DateTime.now().toIso8601String();
    print('🔄 LIFECYCLE [$ts]: $state');
    if (state == AppLifecycleState.detached) {
      print('⚠️ LIFECYCLE: detached — OS may kill process soon.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppConfigCubit>(create: (context) => AppConfigCubit()),
        BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),
        BlocProvider<AppLocalizationCubit>(create: (context) => AppLocalizationCubit(SettingLocalRepository.instance)),
        BlocProvider<AuthCubit>(create: (_) => AuthCubit()),
        BlocProvider<UserDetailsCubit>(create: (context) => UserDetailsCubit()),
        BlocProvider<LogOutCubit>(create: (context) => LogOutCubit(AuthRepository.instance)),
        BlocProvider<GetCartItemCubit>(create: (context) => GetCartItemCubit()),
        BlocProvider<GetShopCubit>(create: (context) => GetShopCubit()),
        BlocProvider<GetCategoryCubit>(create: (context) => GetCategoryCubit()),
        BlocProvider<GetProductCubit>(create: (context) => GetProductCubit()),
        BlocProvider<ClockInOutCubit>(create: (context) => ClockInOutCubit()),
        BlocProvider<GetAgendaCubit>(create: (context) => GetAgendaCubit()),
      ],
      child: Builder(
        builder: (context) {
          return DevicePreview(
            enabled: false,
            builder: (context) => Builder(
              builder: (context) {
                final currentTheme = context.watch<ThemeCubit>().state.appTheme;
                final currentLanguage = context.watch<AppLocalizationCubit>().state.language;
                return AnnotatedRegion<SystemUiOverlayStyle>(
                  value: (currentTheme == AppThemeType.light ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light).copyWith(statusBarColor: Colors.transparent),
                  child: MaterialApp(
                    builder: (_, widget) {
                      return MediaQuery(
                        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
                        child: ScrollConfiguration(
                          behavior: const _GlobalScrollBehavior(),
                          child: ColoredBox(
                            color: context.colorScheme.secondary,
                            child: SafeArea(top: false, bottom: Platform.isAndroid, child: widget!),
                          ),
                        ),
                      );
                    },
                    locale: currentLanguage,
                    theme: appThemeData[currentTheme],
                    debugShowCheckedModeBanner: false,
                    localizationsDelegates: const [AppLocalization.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
                    supportedLocales: supportedLocales.map(UiUtils.getLocaleFromLanguageCode).toList(),
                    initialRoute: Routes.splashScreen,
                    onGenerateRoute: Routes.onGenerateRouted,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (cert, host, port) => true;
  }
}

class _GlobalScrollBehavior extends ScrollBehavior {
  const _GlobalScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(_) => const BouncingScrollPhysics();
}
