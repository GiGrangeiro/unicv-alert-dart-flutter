import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaginaProfessor extends StatefulWidget {
  const PaginaProfessor({Key? key}) : super(key: key);

  @override
  _PaginaProfessorState createState() => _PaginaProfessorState();
}

class _PaginaProfessorState extends State<PaginaProfessor> {
  final List<String> _turmas = [];
  String _codigoTurma = '';
  String _recado = '';
  String? _turmaSelecionada;
  final TextEditingController _recadoController = TextEditingController();
  final TextEditingController _codigoTurmaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarTurmas();
  }

  Future<void> _carregarTurmas() async {
    CollectionReference turmas = FirebaseFirestore.instance.collection('turmas');
    QuerySnapshot querySnapshot = await turmas.get();
    setState(() {
      _turmas.addAll(querySnapshot.docs.map((doc) => doc['codigo'].toString()).toList());
    });
  }

  Future<void> adicionarTurma(String codigoTurma) async {
    try {
      CollectionReference turmas = FirebaseFirestore.instance.collection('turmas');
      await turmas.add({
        'codigo': codigoTurma,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Turma adicionada com sucesso!'),
          duration: Duration(seconds: 2),
        ),
      );

      setState(() {
        _turmas.add(codigoTurma);
        _codigoTurmaController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao adicionar turma!'),
        ),
      );
    }
  }

  Future<void> enviarRecado(String? turma, String recado, String professorId) async {
    try {
      if (recado.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('O recado não pode estar vazio!')),
        );
        return;
      }

      CollectionReference recados = FirebaseFirestore.instance.collection('recados');
      String professorId = FirebaseAuth.instance.currentUser!.uid;

      DocumentSnapshot professorSnapshot = await FirebaseFirestore.instance.collection('usuarios').doc(professorId).get();
      String professorNome = professorSnapshot.get('nome');

      await recados.add({
        'turma': turma,
        'recado': recado,
        'professorId': professorId,
        'professorNome': professorNome,
        'data': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recado enviado com sucesso!')),
      );
      _recadoController.clear();
      setState(() {
        _recado = '';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao enviar recado!')),
      );
    }
  }

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
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Sair'),
              onTap: () {
                Navigator.pushNamed(context, '/');
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
              controller: _codigoTurmaController,
              decoration: const InputDecoration(
                labelText: 'Código da Turma',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
              ),
              onChanged: (value) {
                _codigoTurma = value;
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  if (_codigoTurma.isNotEmpty) {
                    adicionarTurma(_codigoTurma);
                  }
                },
                child: const Text('Adicionar Turma', style: TextStyle(fontSize: 14)),
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
              controller: _recadoController,
              decoration: const InputDecoration(
                labelText: 'Recado',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
              ),
              maxLines: 5,
              onChanged: (value) {
                _recado = value;
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Escolha a Turma',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _turmaSelecionada,
              decoration: const InputDecoration(
                labelText: 'Turmas',
                border: OutlineInputBorder(),
              ),
              onChanged: (newValue) {
                setState(() {
                  _turmaSelecionada = newValue;
                });
              },
              items: _turmas.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, selecione a turma';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_turmaSelecionada != null) {
                      enviarRecado(_turmaSelecionada, _recado, FirebaseAuth.instance.currentUser!.uid);
                    }
                  },
                  child: const Text('Enviar Recado'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

