import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/mail_account.dart';
import '../cubit/auth_cubit.dart';

/// Outlook/Gmail-style login: just email + password. Server settings are
/// resolved by [AuthCubit]/[AuthRepository] behind the scenes, never asked
/// of the user. Reused for adding a second (third, ...) account.
class LoginScreen extends StatefulWidget {
  final bool isAddingAccount;

  const LoginScreen({super.key, this.isAddingAccount = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    context.read<AuthCubit>().login(LoginCredentials(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listenWhen: (p, c) => p.currentAccountId != c.currentAccountId && widget.isAddingAccount,
          listener: (context, state) {
            if (widget.isAddingAccount && state.currentAccountId != null) {
              Navigator.of(context).pop();
            }
          },
          builder: (context, state) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),
                      Center(
                        child: Column(
                          children: [
                            const Text('KAYDET',
                                style: TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -1)),
                            const SizedBox(height: 4),
                            Text(
                              widget.isAddingAccount ? 'Yeni Hesap Ekle' : 'Güvenli E-Posta İstemcisi',
                              style: TextStyle(
                                fontSize: 11,
                                letterSpacing: 1.5,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      _fieldLabel('E-POSTA ADRESİ'),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(hintText: 'ornek@sirket.com'),
                      ),
                      const SizedBox(height: 12),
                      _fieldLabel('ŞİFRE'),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        onSubmitted: (_) => state.isBusy ? null : _submit(),
                        decoration: const InputDecoration(hintText: '••••••'),
                      ),
                      if (state.errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(state.errorMessage!,
                            style: const TextStyle(color: Colors.red, fontSize: 12)),
                      ],
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: state.isBusy ? null : _submit,
                        child: state.isBusy
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(widget.isAddingAccount ? 'Hesabı Ekle' : 'Giriş Yap'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 4),
        child: Text(text,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
      );
}
