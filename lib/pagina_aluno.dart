import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaginaAluno extends StatefulWidget {
  const PaginaAluno({Key? key}) : super(key: key);

  @override
  _PaginaAlunoState createState() => _PaginaAlunoState();
}

class _PaginaAlunoState extends State<PaginaAluno> {
  final TextEditingController _codigoTurmaController = TextEditingController();
  List<String> _turmasSalvas = [];
  String? _turmaSelecionada;
  List<Map<String, dynamic>> _recados = [];

  @override
  void initState() {
    super.initState();
    _carregarTurmasSalvas();
  }

  Future<void> _carregarTurmasSalvas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? turmasSalvas = prefs.getStringList('turmasSalvas');
    if (turmasSalvas != null) {
      setState(() {
        _turmasSalvas = turmasSalvas;
      });
    }
  }

  Future<void> _salvarTurmasSalvasLocalmente(List<String> turmas) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('turmasSalvas', turmas);
  }

  Future<void> _carregarRecados(String turmaSelecionada) async {
    CollectionReference recados = FirebaseFirestore.instance.collection('recados');
    QuerySnapshot querySnapshot = await recados.where('turma', isEqualTo: turmaSelecionada).get();
    setState(() {
      _recados = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }

  Future<void> _adicionarTurma(String codigoTurma) async {
    try {
      CollectionReference turmas = FirebaseFirestore.instance.collection('turmas');

      QuerySnapshot querySnapshot = await turmas.where('codigo', isEqualTo: codigoTurma).get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          if (!_turmasSalvas.contains(codigoTurma)) {
            _turmasSalvas.add(codigoTurma);
            _turmaSelecionada = codigoTurma; // Seleciona automaticamente a turma adicionada
          }
        });
        await _salvarTurmasSalvasLocalmente(_turmasSalvas); // Salvar as turmas salvas localmente
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Turma adicionada com sucesso!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Código da turma inválido!')),
        );
      }
    } catch (e) {
      print('Erro ao entrar na turma: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao entrar na turma!')),
      );
    }
  }

  @override
  void dispose() {
    _codigoTurmaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Área do Aluno',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
          ),
        ),
        elevation: 8,
        shadowColor: const Color.fromARGB(221, 14, 75, 1),
        backgroundColor: Colors.green, // Alterado para verde
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green, // Alterado para verde
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
              title: const Text(
                'Página Inicial',
                style: TextStyle(fontSize: 16),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text(
                'Sair',
                style: TextStyle(fontSize: 16),
              ),
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
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _codigoTurmaController,
                    decoration: const InputDecoration(
                      labelText: 'Código da Turma',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_codigoTurmaController.text.isNotEmpty) {
                        _adicionarTurma(_codigoTurmaController.text);
                        _codigoTurmaController.clear();
                      }
                    },
                    child: const Text('Adicionar'),
                  ),
                ),
              ],
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
                if (newValue != null) {
                  _carregarRecados(newValue);
                }
              },
              items: _turmasSalvas.map((String value) {
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
            Expanded(
              child: ListView.builder(
                itemCount: _recados.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                        _recados[index]['professorNome'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(_recados[index]['recado']),
                      trailing: Text(
                        _recados[index]['data'] != null
                            ? '${_recados[index]['data'].toDate().day}/${_recados[index]['data'].toDate().month}/${_recados[index]['data'].toDate().year}'
                            : '',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


