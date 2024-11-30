import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list/screens/home_screen.dart';
import 'package:to_do_list/services/auth_service.dart';
import 'package:to_do_list/widgets/show_snack_bar.dart';
import 'package:to_do_list/providers/task_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmaController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();

  bool isEntrando = true;
  bool _isLoading = false;
  bool _obscurePassword1 = true;
  bool _obscurePassword2 = true;

  final _formKey = GlobalKey<FormState>();

  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmaController.dispose();
    _nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Center(
          child: SingleChildScrollView(
            child: AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Transform(
                  transform:
                      Matrix4.rotationY(2 * 3.14159 * _rotationAnimation.value),
                  alignment: Alignment.center,
                  child: child,
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          (isEntrando)
                              ? "Bem vindo ao To_do_List!"
                              : "Vamos começar?",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        (isEntrando)
                            ? "Faça login para criar suas tasks."
                            : "Faça seu cadastro para começar a criar suas tasks.",
                        textAlign: TextAlign.center,
                      ),
                      TextFormField(
                        controller: _emailController,
                        decoration:
                            const InputDecoration(label: Text("E-mail")),
                        validator: (value) {
                          if (value == null || value == "") {
                            return "O valor de e-mail deve ser preenchido";
                          }
                          if (!value.contains("@") ||
                              !value.contains(".") ||
                              value.length < 4) {
                            return "O valor do e-mail deve ser válido";
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _senhaController,
                        obscureText: _obscurePassword1,
                        decoration: InputDecoration(
                          label: Text("Senha"),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword1 = !_obscurePassword1;
                              });
                            },
                            icon: Icon(
                              _obscurePassword1
                                  ? Icons.remove_red_eye_outlined
                                  : Icons.visibility_off,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.length < 4) {
                            return "Insira uma senha válida.";
                          }
                          return null;
                        },
                      ),
                      Visibility(
                        visible: isEntrando,
                        child: TextButton(
                          onPressed: () {
                            esqueciMinhaSenhaClicado();
                          },
                          child: Text("Esqueci minha senha."),
                        ),
                      ),
                      Visibility(
                        visible: !isEntrando,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _confirmaController,
                              obscureText: _obscurePassword2,
                              decoration: InputDecoration(
                                label: Text("Confirme a senha"),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword2 = !_obscurePassword2;
                                    });
                                  },
                                  icon: Icon(
                                    _obscurePassword2
                                        ? Icons.remove_red_eye_outlined
                                        : Icons.visibility_off,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.length < 4) {
                                  return "Insira uma confirmação de senha válida.";
                                }
                                if (value != _senhaController.text) {
                                  return "As senhas devem ser iguais.";
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              controller: _nomeController,
                              decoration: const InputDecoration(
                                label: Text("Nome"),
                              ),
                              validator: (value) {
                                if (value == null || value.length < 3) {
                                  return "Insira um nome maior.";
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          botaoEnviarClicado();
                        },
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                ),
                              )
                            : Text((isEntrando) ? "Entrar" : "Cadastrar"),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: Center(
                          child: Text(
                            'Ou',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.purple),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(context,
                              MaterialPageRoute(builder: (context) {
                            return HomeScreen();
                          }), (Route<dynamic> route) => false);
                        },
                        child: const Text('Entrar sem conta'),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isEntrando = !isEntrando;
                            _animationController.forward(from: 0);
                          });
                        },
                        child: Text(
                          (isEntrando)
                              ? "Ainda não tem conta?\nClique aqui para cadastrar."
                              : "Já tem uma conta?\nClique aqui para entrar",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  botaoEnviarClicado() {
    String email = _emailController.text;
    String senha = _senhaController.text;
    String nome = _nomeController.text;

    if (_formKey.currentState!.validate()) {
      if (isEntrando) {
        _entrarUsuario(email: email, senha: senha);
      } else {
        _criarUsuario(email: email, senha: senha, nome: nome);
      }
    }
  }

  _entrarUsuario({required String email, required String senha}) {
    setState(() {
      _isLoading = true;
    });
    context.read<AuthService>().userLogin(
        context: context,
        email: email,
        senha: senha,
        onFail: (erro) {
          setState(() {
            _isLoading = false;
          });
        },
        onSuccess: () {
          setState(() {
            _isLoading = false;
          });
          Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (context) {
            return HomeScreen();
          }), (Route<dynamic> route) => false);
        });
  }

  _criarUsuario(
      {required String email, required String senha, required String nome}) {
    setState(() {
      _isLoading = true;
    });
    context
        .read<AuthService>()
        .cadastrarUsuario(
            email: email,
            password: senha,
            name: nome,
            onFail: (erro) {
              setState(() {
                _isLoading = false;
              });
            },
            onSuccess: () {
              setState(() {
                _isLoading = false;
                isEntrando = !isEntrando;
                _animationController.forward(from: 0);
              });
            })
        .then((String? erro) {
      if (erro != null) {
        showSnackBar(context: context, mensagem: erro);
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  esqueciMinhaSenhaClicado() {
    String email = _emailController.text;
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController redefinicaoSenhaController =
            TextEditingController(text: email);
        return AlertDialog(
          title: const Text("Confirme o e-mail para redefinição de senha."),
          content: TextFormField(
            controller: redefinicaoSenhaController,
            decoration: const InputDecoration(
              label: Text("Confirme o e-mail."),
            ),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.read<AuthService>().resetPassword(
                    email: redefinicaoSenhaController.text,
                    onFail: (erro) {
                      showSnackBar(context: context, mensagem: erro);
                      Navigator.pop(context);
                    },
                    onSuccess: () {
                      showSnackBar(
                        context: context,
                        mensagem: "E-mail de redefinição enviado!",
                        isErro: false,
                      );
                      Navigator.pop(context);
                    });
              },
              child: const Text("Redefinir senha."),
            )
          ],
        );
      },
    );
  }
}
