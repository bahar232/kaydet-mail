import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/data/repositories/mock_auth_repository.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/mail/data/repositories/mock_label_repository.dart';
import 'features/mail/data/repositories/mock_mail_repository.dart';
import 'features/mail/domain/repositories/label_repository.dart';
import 'features/mail/domain/repositories/mail_repository.dart';
import 'features/mail/presentation/cubit/label_cubit.dart';
import 'features/mail/presentation/cubit/mail_cubit.dart';
import 'features/mail/presentation/screens/home_screen.dart';
import 'features/settings/data/repositories/mock_settings_repository.dart';
import 'features/settings/domain/repositories/settings_repository.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';

/// Composition root: wires concrete (currently mock) repositories to the
/// cubits that depend on their abstract contracts.
///
/// To connect a real backend later, swap only the `RepositoryProvider`
/// values below (e.g. `MockMailRepository()` -> `ApiMailRepository(dio)`)
/// — no cubit, screen or widget needs to change.
class KaydetApp extends StatelessWidget {
  const KaydetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(create: (_) => MockAuthRepository()),
        RepositoryProvider<MailRepository>(create: (_) => MockMailRepository()),
        RepositoryProvider<LabelRepository>(create: (_) => MockLabelRepository()),
        RepositoryProvider<SettingsRepository>(create: (_) => MockSettingsRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(context.read<AuthRepository>())..checkSavedSession(),
          ),
          BlocProvider<MailCubit>(create: (context) => MailCubit(context.read<MailRepository>())),
          BlocProvider<LabelCubit>(
            create: (context) => LabelCubit(context.read<LabelRepository>())..loadLabels(),
          ),
          BlocProvider<SettingsCubit>(
            create: (context) => SettingsCubit(context.read<SettingsRepository>())..load(),
          ),
        ],
        child: MaterialApp(
          title: 'KAYDET Mail',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: const _AuthGate(),
        ),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (previous, current) => previous.currentAccountId != current.currentAccountId,
      listener: (context, state) {
        if (state.currentAccountId != null) {
          context.read<MailCubit>().loadForAccount(state.currentAccountId!);
        }
      },
      builder: (context, state) {
        switch (state.status) {
          case AuthStatus.initial:
            return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.black)));
          case AuthStatus.unauthenticated:
            return const LoginScreen();
          case AuthStatus.authenticated:
            return const HomeScreen();
        }
      },
    );
  }
}
