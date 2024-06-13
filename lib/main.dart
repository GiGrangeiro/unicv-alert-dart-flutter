import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pagina_principal.dart';
import 'pagina_aluno.dart';
import 'pagina_professor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
    );

    
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const PaginaPrincipal(),
      routes: {
        '/pagina_aluno': (context) => const PaginaAluno(),
        '/pagina_professor': (context) => const PaginaProfessor(),
      },
    );
  }
}
