import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://lhyuxcetpagvaqiirbaq.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxoeXV4Y2V0cGFndmFxaWlyYmFxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQwNzI0MDIsImV4cCI6MjA2OTY0ODQwMn0.qphRuNRmIomKtI97-FN7KAAzXurFJr3_rcBFLuXPAZ4',
  );
  runApp(const ProviderScope(child: TrainRidesApp()));
}
