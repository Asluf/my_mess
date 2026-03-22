import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'themes/themes.dart';
import 'providers/project_provider.dart';
import 'providers/expense_provider.dart';
import 'screens/project_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
      ],
      child: MaterialApp(
        title: 'My Mess',
        debugShowCheckedModeBanner: false,
        theme: sunnyCitrusTheme,
        darkTheme: darkModeTheme,
        themeMode: ThemeMode.system,
        home: const ProjectListScreen(),
      ),
    );
  }
}
