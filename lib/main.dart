import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/theme_manager.dart';
import 'core/services/notification_service.dart';
import 'core/services/backup_service.dart';
import 'core/services/power_service.dart';
import 'core/services/network_service.dart';
import 'screens/lock_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notificationService = NotificationService();
  final backupService = BackupService();
  final powerService = PowerService();
  final networkService = NetworkService();
  notificationService.init();
  await backupService.init();
  await powerService.init();
  await networkService.init();
  runApp(ZionOSApp(
    notificationService: notificationService,
    backupService: backupService,
    powerService: powerService,
    networkService: networkService,
  ));
}

class ZionOSApp extends StatelessWidget {
  final NotificationService notificationService;
  final BackupService backupService;
  final PowerService powerService;
  final NetworkService networkService;
  
  const ZionOSApp({
    super.key,
    required this.notificationService,
    required this.backupService,
    required this.powerService,
    required this.networkService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: notificationService),
        ChangeNotifierProvider.value(value: powerService),
        ChangeNotifierProvider.value(value: networkService),
        ChangeNotifierProvider(create: (_) => ThemeManager()),
        Provider.value(value: backupService),
      ],
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, child) {
          return MaterialApp(
            title: 'Zion OS 2027',
            debugShowCheckedModeBanner: false,
            theme: themeManager.getThemeData(),
            home: const LockScreen(),
          );
        },
      ),
    );
  }
}
