import 'package:chimbinha/pagina_aluno.dart';
import 'package:chimbinha/pagina_professor.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    routes: {
      '/': (context) => const TelaLogin(),
      '/pagina_professor': (context) => const PaginaProfessor(),
      '/pagina_aluno': (context) => const PaginaAluno(),
      
    },
  ));
}

class Usuario {
  final String email;
  final String senha;
  final String nomeUsuario;
  final String tipo;

  Usuario({
    required this.email,
    required this.senha,
    required this.nomeUsuario,
    required this.tipo,
  });
}


class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final _chaveForm = GlobalKey<FormState>();
  String _emailInserido = '';
  String _senhaInserida = '';
  String _nomeUsuario = '';
  String _tipoUsuarioSelecionado = 'Professor';
  bool _modoLogin = true;

  final List<Usuario> _usuarios = [];

  void verificarUsuario(BuildContext context) {
    if (_modoLogin) {
      if (_usuarios.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nenhum usuário cadastrado!')));
      return;
    }
      final usuario = _usuarios.firstWhere(
        (user) =>
            user.email == _emailInserido &&
            user.senha == _senhaInserida &&
            user.tipo == _tipoUsuarioSelecionado,
        orElse: () => Usuario(email: '', senha: '', nomeUsuario: '', tipo: ''),
      );

      if (usuario.email.isNotEmpty && usuario.senha.isNotEmpty) {
        if (usuario.tipo == _tipoUsuarioSelecionado) {
          if (usuario.tipo == 'Professor') {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const PaginaProfessor())); 
          } else if (usuario.tipo == 'Aluno') {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const PaginaAluno()));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tipo de usuário incorreto!')));
            return;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email ou senha incorretos!')));
          return;
      }
    }
  }

  void adicionarUsuario(BuildContext context) {
    final usuarioExistente = _usuarios.any((user) =>
        user.email == _emailInserido && user.nomeUsuario == _nomeUsuario);

    if (usuarioExistente) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário já cadastrado!')),
      );
      return;
    }

    if (_tipoUsuarioSelecionado == 'Professor' &&
        !_emailInserido.startsWith('prof_')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Acesso negado, o email deve ser de professor')),
      );
      return;
    }

    Usuario novoUsuario = Usuario(
      email: _emailInserido,
      senha: _senhaInserida,
      nomeUsuario: _nomeUsuario,
      tipo: _tipoUsuarioSelecionado,
    );
    _usuarios.add(novoUsuario);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Usuário cadastrado com sucesso!')),
    );

    setState(() {
      _modoLogin = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Builder(builder: (context) {
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
                      key: _chaveForm,
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Endereço de Email'),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (valorEmail) {
                              if (valorEmail == null ||
                                  valorEmail.trim().isEmpty ||
                                  !valorEmail.contains('@')) {
                                return 'Por favor, insira um endereço de email válido.';
                              }
                              return null;
                            },
                            onSaved: (valor) {
                              _emailInserido = valor!;
                            },
                          ),
                          TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'Senha'),
                            obscureText: true,
                            validator: (valorSenha) {
                              if (valorSenha == null ||
                                  valorSenha.trim().length < 6) {
                                return 'A senha deve ter pelo menos 6 caracteres.';
                              }
                              return null;
                            },
                            onSaved: (valor) {
                              _senhaInserida = valor!;
                            },
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          DropdownButtonFormField<String>(
                            value: _tipoUsuarioSelecionado,
                            decoration: const InputDecoration(
                                labelText: 'Tipo de Usuário'),
                            onChanged: (newValue) {
                              setState(() {
                                _tipoUsuarioSelecionado = newValue!;
                              });
                            },
                            items: ['Professor', 'Aluno'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
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
                                  labelText: 'Nome do usuário'),
                              enableSuggestions: false,
                              validator: (value) {
                                if (value == null || value.trim().length < 4) {
                                  return 'Por favor, insira pelo manos 4 caractéres';
                                }
                                return null;
                              },
                              onSaved: (valor) {
                                _nomeUsuario = valor!;
                              },
                            ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  if (!_chaveForm.currentState!.validate()) {
                                    return;
                                  }

                                  _chaveForm.currentState!.save();
                                  
                                  if (_modoLogin) {
                                    verificarUsuario(context);
                                  } else {
                                    adicionarUsuario(context);
                                  }
                                },
                                child: Text(_modoLogin ? 'Entrar' : 'Salvar'),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _modoLogin = !_modoLogin;
                                  });
                                },
                                child: Text(_modoLogin
                                    ? 'Cadastrar'
                                    : 'Já tenho uma Conta'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )),
          ),
        );
      }),
    );
  }
}
