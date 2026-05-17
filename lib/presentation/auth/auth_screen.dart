import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:messenger/presentation/auth/bloc/auth_bloc.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _usernameController;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _usernameController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          final errorText = state.errorText;
          if (errorText != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(errorText), backgroundColor: Colors.red));
          }
        }
        // if (state is AuthSuccess) {
        //   Navigator.pushReplacement(
        //     context,
        //     MaterialPageRoute(builder: (_) => const ChatListProvider()), 
        //   );
        // }
      },
      builder: (context, state) {
        if (state is AuthInitial) {
          return Scaffold(
            body: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('welcome to aura messenger'),
                    SizedBox(height: 60,),
                    Text('enter your email'),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 30,),
                    Text('enter your password'),
                    TextField(
                      controller: _passwordController,
                      keyboardType: TextInputType.visiblePassword,
                    ),
                    SizedBox(height: 30,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(2)),
                              color: Colors.blue,
                            ),
                            height: 40,
                            width: 100,
                            alignment: Alignment(0, 0),
                            child: Text('log in'),
                          ),
                          onTap: () {
                            if (_passwordController.text.trim().isNotEmpty &&
                                _emailController.text.trim().isNotEmpty) {
                              context.read<AuthBloc>().add(
                                AuthSignInEmail(
                                  email: _emailController.text,
                                  password: _passwordController.text,
                                ),
                              );
                            }
                          },
                        ),
                        InkWell(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(2)),
                              color: Colors.blue,
                            ),
                            height: 40,
                            width: 100,
                            alignment: Alignment(0, 0),
                            child: Text('register'),
                          ),
                          onTap: () {
                            if (_passwordController.text.trim().isNotEmpty &&
                                _emailController.text.trim().isNotEmpty) {
                              context.read<AuthBloc>().add(
                                AuthGoToUsernameScreen(
                                  email: _emailController.text,
                                  password: _passwordController.text,
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        } else if (state is AuthLoading) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (state is AuthEnterUsername) {
          return Scaffold(
            body: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('enter your unique user tag'),
                    TextField(
                      controller: _usernameController,
                      keyboardType: TextInputType.visiblePassword,
                    ),
                    SizedBox(height: 30,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(2)),
                              color: Colors.blue,
                            ),
                            height: 40,
                            width: 100,
                            alignment: Alignment(0, 0),
                            child: Text('confirm'),
                          ),
                          onTap: () {
                            if (_usernameController.text.trim().isNotEmpty) {
                              context.read<AuthBloc>().add(
                                AuthSignUpEmail(
                                  username: _usernameController.text.trim(),
                                  email: state.email,
                                  password: state.password
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {return Scaffold(body: Center(child: CircularProgressIndicator()));}
      },
    );
  }
}
