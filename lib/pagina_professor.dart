
  import 'package:chimbinha/main.dart';
import 'package:flutter/material.dart';
  
  void main() {
    runApp(const PaginaProfessor());
  }

  class PaginaProfessor extends StatelessWidget {
    const PaginaProfessor({super.key});

  

    @override
    Widget build(BuildContext context) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MyHomePage(),
      );
    }
  }

  class MyHomePage extends StatefulWidget {
    const MyHomePage({super.key});

    @override
    // ignore: library_private_types_in_public_api
    _MyHomePageState createState() => _MyHomePageState();
  }

  class _MyHomePageState extends State<MyHomePage> {
    final TextEditingController _turmaController = TextEditingController();
    final TextEditingController _mensagemController = TextEditingController();
    final List<String> _turmas = [];
    String? _selectedClass;

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Área do Professor',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
            ),
          ),
          elevation: 8,
          shadowColor: const Color.fromARGB(221, 14, 75, 1),
          backgroundColor: Colors.green,
          centerTitle: true,
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.green,
                ),
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Página Inicial'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.disabled_by_default_sharp),
                title: const Text('Sair'),
                onTap: () {
                  Navigator.push(context,MaterialPageRoute(builder: (context) => const TelaLogin()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.help_center_sharp),
                title: const Text('Ajuda'),
                onTap: () {
                  // Implementar ação ao clicar na opção
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Código da Turma:',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _turmaController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0)),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _turmas.add(_turmaController.text);
                      _selectedClass = _turmaController.text;
                      _turmaController.clear();
                      _mensagemController.clear();
                    });
                  },
                  child: const Text('Adicionar Turma',
                      style: TextStyle(fontSize: 14)),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Escreva seu recado:',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _mensagemController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
                ),
                maxLines: 5,
              ),
              Text(
                'Escolha a Turma',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedClass,
                onChanged: (newValue) {
                  setState(() {
                    _selectedClass = newValue;
                  });
                },
                items: _turmas.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Enviar'),
              ),
            ],
          ),
        ),
      );
    }

    @override
    void dispose() {
      _turmaController.dispose();
      _mensagemController.dispose();
      super.dispose();
    }
  }
