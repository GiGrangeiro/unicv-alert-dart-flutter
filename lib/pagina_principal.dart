import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaginaPrincipal extends StatefulWidget {
  const PaginaPrincipal({Key? key}) : super(key: key);

  @override
  _PaginaPrincipalState createState() => _PaginaPrincipalState();
}

class _PaginaPrincipalState extends State<PaginaPrincipal> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _email = '';
  String _senha = '';
  String _nome = '';
  String _tipoUsuario = 'Professor';
  bool _modoLogin = true;

  Future<void> _verificarUsuario(BuildContext context) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: _email,
        password: _senha,
      );

      final usuarioSnapshot = await _firestore
          .collection('usuarios')
          .doc(userCredential.user!.uid)
          .get();

      if (usuarioSnapshot.exists) {
        final usuario = usuarioSnapshot.data() as Map<String, dynamic>;
        if (usuario['tipo'] == 'Professor' && _tipoUsuario == 'Professor') {
          Navigator.pushNamed(context, '/pagina_professor');
        } else if (usuario['tipo'] == 'Aluno' && _tipoUsuario == 'Aluno') {
          Navigator.pushNamed(context, '/pagina_aluno');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tipo de usuário incorreto!')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário não encontrado!')),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Erro ao realizar login.';

      if (e.code == 'user-not-found') {
        errorMessage = 'Usuário não encontrado. Verifique e tente novamente.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Senha incorreta. Verifique e tente novamente.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Email inválido. Verifique e tente novamente.';
      } else {
        errorMessage = 'Erro desconhecido: ${e.message}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao verificar usuário: $e')),
      );
      print('Erro ao verificar usuário: $e');
    }
  }

  Future<void> _adicionarUsuario(BuildContext context) async {
    try {
      final usuarioExistente = await _firestore
          .collection('usuarios')
          .where('email', isEqualTo: _email)
          .get();

      if (usuarioExistente.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário já cadastrado!')),
        );
        return;
      }

      if (_tipoUsuario == 'Professor' && !_email.startsWith('prof_')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Acesso negado, o email deve ser de professor'),
          ),
        );
        return;
      }

      final newUserCredential = await _auth.createUserWithEmailAndPassword(
        email: _email,
        password: _senha,
      );

      final novoUsuario = {
        'email': _email,
        'senha': _senha,
        'nome': _nome,
        'tipo': _tipoUsuario,
      };

      await _firestore
          .collection('usuarios')
          .doc(newUserCredential.user!.uid)
          .set(novoUsuario);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário cadastrado com sucesso!')),
      );

      setState(() {
        _modoLogin = true;
      });
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Erro ao cadastrar usuário.';

      if (e.code == 'weak-password') {
        errorMessage = 'Senha fraca, escolha uma senha mais forte.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'Email já em uso. Use um email diferente.';
      } else if (e.code == 'operation-not-allowed') {
        errorMessage =
            'Operação não permitida. Entre em contato com o suporte.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Email inválido. Verifique e tente novamente.';
      } else {
        errorMessage = 'Erro desconhecido: ${e.message}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar usuário: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Unicv Alert',
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
      backgroundColor: Colors.green,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: 200,
                margin: const EdgeInsets.all(20),
                child: const Icon(
                  Icons.person_pin_circle_rounded,
                  size: 200,
                  color: Colors.white,
                ),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Endereço de Email',
                          ),
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                !value.contains('@')) {
                              return 'Por favor, insira um endereço de email válido.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _email = value!;
                          },
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Senha',
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Por favor, insira sua senha.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _senha = value!;
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _tipoUsuario,
                          decoration: const InputDecoration(
                            labelText: 'Tipo de Usuário',
                          ),
                          onChanged: (newValue) {
                            setState(() {
                              _tipoUsuario = newValue!;
                            });
                          },
                          items: ['Professor', 'Aluno']
                              .map((String value) => DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  ))
                              .toList(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor selecione o tipo de usuário';
                            }
                            return null;
                          },
                        ),
                        if (!_modoLogin)
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Nome',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Por favor, insira seu nome.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _nome = value!;
                            },
                          ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            final form = _formKey.currentState;
                            if (form != null && form.validate()) {
                              form.save();
                              if (_modoLogin) {
                                _verificarUsuario(context);
                              } else {
                                _adicionarUsuario(context);
                              }
                            }
                          },
                          child: Text(_modoLogin ? 'Entrar' : 'Cadastrar'),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _modoLogin = !_modoLogin;
                            });
                          },
                          child: Text(_modoLogin
                              ? 'Criar uma nova conta'
                              : 'Já tem uma conta? Faça login aqui'),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
