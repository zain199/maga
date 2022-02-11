import 'app_theme_data.dart';
import 'translations/codegen_loader.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'core/common/push_notification/push_notification_helper.dart';
import 'core/constants/appconstants.dart';
import 'core/datasource/local_data_source.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:rxdart/rxdart.dart';
import 'core/di/injection.dart';
import 'core/routes/routes.gr.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/colors.dart';

typedef F<T, R> = T Function(R);
const supportedLocales = const [
  Locale('en'),
  Locale('ar'),
  Locale('fr'),
  Locale('de'),
  Locale('it'),
  Locale('ru'),
  Locale('pt'),
  Locale('es'),
  Locale('tr'),
  Locale('nl'),
  Locale('uk'),
];
final appRouter = MyRouter();

final appThemeConstroller = BehaviorSubject<TextTheme>.seeded(appTextTheme);

Function(TextTheme) get changeAppTheme => appThemeConstroller.sink.add;
// insert_link_outlined
Stream<TextTheme> get appTheme => appThemeConstroller.stream;
LocalDataSource? localDataSource;
var isUserLoggedIn = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();
  AC.getInstance();
  await NativeDeviceOrientationCommunicator().orientation(useSensor: false);
  await configureDependencies();
  localDataSource = getIt<LocalDataSource>();
  isUserLoggedIn = await localDataSource!.isUserLoggedIn();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((value) async {
    await Future.delayed(const Duration(milliseconds: 500));
    runApp(
      EasyLocalization(
        assetLoader: CodegenLoader(),
        supportedLocales: supportedLocales,
        fallbackLocale: supportedLocales.first,
        path: 'assets/translations',
        child: MyApp(),
      ),
    );
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    PushNotificationHelper.configurePush();
    WidgetsBinding.instance!.addPostFrameCallback(
      (timeStamp) {
        EasyLoading.instance
          ..displayDuration = const Duration(milliseconds: 2000)
          ..indicatorType = EasyLoadingIndicatorType.ring
          ..loadingStyle = EasyLoadingStyle.custom
          ..indicatorSize = 45.0
          ..radius = 10.0
          ..maskType = EasyLoadingMaskType.custom
          ..maskColor = AppColors.colorPrimary.withOpacity(.2)
          ..indicatorColor = AppColors.colorPrimary
          ..progressColor = AppColors.colorPrimary
          ..textColor = AppColors.colorPrimary
          ..backgroundColor = Colors.transparent
          ..userInteractions = false;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth != 0) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          ScreenUtil.init(
            BoxConstraints(
              maxWidth: constraints.maxWidth,
              maxHeight: constraints.maxHeight,
            ),
            designSize: size,
          );
        }

        return MaterialApp.router(
          title: 'Mumblit',
          debugShowCheckedModeBanner: false,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          localeResolutionCallback: (locale, supportedLocales) {
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale!.languageCode &&
                  supportedLocale.countryCode == locale.countryCode) {
                return supportedLocale;
              }
            }
            return supportedLocales.first;
          },
          theme: AppThemeData.appThemeData(context),
          routerDelegate: appRouter.delegate(initialRoutes: [
            if (isUserLoggedIn) FeedScreenRoute(),
            if (!isUserLoggedIn) WelcomeScreenRoute(),
          ]),
          routeInformationParser: appRouter.defaultRouteParser(),
          builder: EasyLoading.init(),
        );
      },
    );
  }
}
