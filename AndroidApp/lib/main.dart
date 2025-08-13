import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/downloader/downloader_provider.dart';
import 'src/ui/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DownloaderProvider()),
      ],
      child: MaterialApp(
        title: 'YouTube Music Downloader',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00FF41),
            brightness: Brightness.dark,
            primary: const Color(0xFF00FF41),
            secondary: const Color(0xFF16537E),
          ),
          scaffoldBackgroundColor: const Color(0xFF1A1A2E),
          fontFamily: 'Roboto',
          useMaterial3: true,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00FF41),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

