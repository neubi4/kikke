import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kikke/app_state.dart';
import 'package:kikke/controller/downtimescontroller.dart';
import 'package:kikke/controller/instancecontroller.dart';
import 'package:kikke/screens/settings.dart';
import 'package:kikke/time/timeago.dart';
import 'package:kikke/views/pages/detail.dart';
import 'package:kikke/views/pages/detail_perf_data.dart';
import 'package:kikke/views/pages/home.dart';
import 'package:kikke/views/pages/imprint.dart';
import 'package:kikke/views/pages/list.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:kikke/controller/appsettings.dart';
import 'package:kikke/controller/servicecontroller.dart';
import 'package:kikke/screens/login.dart';

import 'package:kikke/controller/hostcontroller.dart';
import 'package:kikke/controller/service_locator.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppSettings appSettings = new AppSettings();
  await appSettings.loadDataFromProvider();

  var initRoute = '/';
  if (appSettings.instances.instances.length < 1) {
    initRoute = '/settings';
  }

  InstanceController controller = new InstanceController.fromSettings(appSettings);

  ServiceController serviceController = new ServiceController(controller: controller);
  HostController hostController = new HostController(controller: controller);
  DowntimesController downtimesController = new DowntimesController(controller: controller);

  getIt.registerSingleton<InstanceController>(controller);
  getIt.registerSingleton<AppSettings>(appSettings);
  getIt.registerSingleton<ServiceController>(serviceController);
  getIt.registerSingleton<HostController>(hostController);
  getIt.registerSingleton<DowntimesController>(downtimesController);

  timeago.setLocaleMessages('en', EnMessages());
  timeago.setLocaleMessages('de', DeMessages());

  runApp(
    ChangeNotifierProvider<AppState>(
      create: (context) => AppState(appSettings.themeMode),
      child: KikkeApp(initRoute),
    ),
  );
}

class KikkeApp extends StatelessWidget {
  String initRoute;

  KikkeApp(this.initRoute);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return MaterialApp(
          localizationsDelegates: [
            // ... app-specific localization delegate[s] here
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            const Locale('en', ''),
            const Locale('de', ''),
            // ... other locales the app supports
          ],
          // Start the app with the "/" named route. In our case, the app will start
          // on the FirstScreen Widget
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            accentColor: Colors.lightBlueAccent,
          ),
          themeMode: appState.themeMode,
          initialRoute: initRoute,
          routes: {
            // When we navigate to the "/" route, build the FirstScreen Widget
            '/': (context) => AppHomePage(),
            '/lists/hosts': (context) => AppListPage(controller: getIt.get<HostController>(), title: "Hosts",),
            '/lists/services': (context) => AppListPage(controller: getIt.get<ServiceController>(), title: "Services",),
            '/lists/downtimes': (context) => AppListPage(controller: getIt.get<DowntimesController>(), title: "Downtimes",),
            '/detail': (context) => AppDetailPage(),
            '/detail/perfdata': (context) => AppDetailPerfdataPage(),
            '/settings': (context) => SettingsScreen(),
            '/settings/account': (context) => SettingsPage(),
            '/imprint': (context) => ImprintPage(),
          },
          title: 'Kikke',
        );
      },
    );
  }
}
