import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:popmeet/presentation/blocs/auth/auth_bloc.dart';
import 'package:popmeet/presentation/components/form_container.dart';
import 'package:popmeet/presentation/pages/auth/login.dart';
import 'package:popmeet/presentation/pages/getting_start/getting_start.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordController2 = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    passwordController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<AuthBloc>(context);

    return BlocListener<AuthBloc, AuthState>(
      bloc: authBloc,
      listener: (context, state) {
        if (state is AuthLoading) {
          showDialog(
              context: context,
              builder: (context) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              });
        }
        if (state is AuthSuccess) {
          print('User Register Success');
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => GettingStartPage()),
          );
        }
        if (state is AuthFailure) {
          print(state.message);
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                  child: SizedBox(
                      height: 200,
                      width: 200,
                      child: Image.asset('assets/images/logo.png'))),
              const SizedBox(
                height: 20,
              ),
              FormContainerWidget(
                hintText: 'Email',
                controller: emailController,
              ),
              const SizedBox(
                height: 20,
              ),
              FormContainerWidget(
                helperText: 'password',
                hintText: 'Password',
                isPasswordField: true,
                controller: passwordController,
              ),
              const SizedBox(
                height: 20,
              ),
              FormContainerWidget(
                helperText: 'password',
                hintText: 'Confirm password',
                isPasswordField: true,
                controller: passwordController2,
              ),
              const SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: () async {
                  if (passwordController.text == passwordController2.text) {
                    authBloc.add(AuthRegisterEvent(
                        email: emailController.text,
                        password: passwordController.text));
                  } else {
                    Fluttertoast.showToast(msg: 'Password doesn\'t match');
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(20)),
                  child: const Center(
                      child: Text(
                    'Register',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  )),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account ?'),
                  const SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                          (route) => false);
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blueAccent,
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
