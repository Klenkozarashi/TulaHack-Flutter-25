import 'package:flutter/material.dart';
import 'package:test_flut/presentation/logo.dart';
import 'package:test_flut/presentation/registration.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Имитация процесса входа
      Future.delayed(const Duration(seconds: 2), () {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Вход выполнен успешно!')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SplashScreen(),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(39, 41, 39, 1),
      appBar: AppBar(backgroundColor: Color.fromRGBO(39, 41, 39, 1)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 70),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                      padding: EdgeInsets.fromLTRB(10, 40, 3, 10),
                      child: Text(
                        "Добро пожаловать в",
                        style: TextStyle(
                            fontSize: 32,
                            fontFamily: "Jost",
                            fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      )),
                ],
              ),
              Padding(
                  padding: EdgeInsets.fromLTRB(0, 40, 10, 10),
                  child: Text(
                    "SQL!",
                    style: TextStyle(
                      fontSize: 32,
                      fontFamily: "Jost",
                      fontWeight: FontWeight.w500,
                      color: Color.fromRGBO(183, 88, 255, 1),
                    ),
                    textAlign: TextAlign.center,
                  )),
              const SizedBox(height: 30),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.fromLTRB(15, 31, 15, 20),
                  labelText: "Адрес электронной почты",
                  labelStyle: TextStyle(
                      fontFamily: "Jost",
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      fontSize: 16),
                  enabledBorder: new OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromRGBO(0, 0, 0, 1),
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(50)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromRGBO(183, 88, 255, 1),
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(50)),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromRGBO(0, 0, 0, 1),
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromRGBO(183, 88, 255, 1),
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  errorStyle: TextStyle(
                    color: Colors.red,
                    fontFamily: "Jost",
                    fontSize: 14,
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Введите корректный email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(15, 31, 15, 20),
                    labelStyle: TextStyle(
                        fontFamily: "Jost",
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        fontSize: 16),
                    enabledBorder: new OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromRGBO(0, 0, 0, 1),
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(50)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromRGBO(183, 88, 255, 1),
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(50)),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromRGBO(0, 0, 0, 1),
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromRGBO(183, 88, 255, 1),
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    errorStyle: TextStyle(
                      color: Colors.red,
                      fontFamily: "Jost",
                      fontSize: 14,
                    ),
                    labelText: 'Пароль',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          key: ValueKey<bool>(_obscurePassword),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    )),
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите пароль';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Войти',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Нет аккаунта?'),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text('Зарегистрируйтесь'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
